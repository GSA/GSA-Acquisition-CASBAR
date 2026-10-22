#!/usr/bin/env python3
"""Run the existing eCFR XSLT pipeline on all of Chapter 99."""

import argparse
import copy
import hashlib
import json
import re
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from pathlib import Path

from complete_chapter import complete
from publish_chapter import FORMATS, publish
from tool_root import find_tool_root


ROOT = find_tool_root()
HERE = Path(__file__).resolve().parent.parent
XSL = ROOT / "regulation-tools/TOOLS/StructureGSA_FAR/xml/DITA_1.2/app/technicalContent/xslt/ECFRConversion2DITA_Tools"
CASBAR_XSL = Path(__file__).resolve().parent / "xslt"
SAXON = ROOT / "regulation-tools/TOOLS/SaxonHE9-7-0-20J/saxon9he.jar"
XML_URL = "https://www.govinfo.gov/bulkdata/ECFR/title-48/ECFR-title48.xml"
GRAPHICS_URL = "https://www.govinfo.gov/bulkdata/ECFR/title-48/ECFR-title48-graphics.zip"


def download(url: str, target: Path, headers: Path) -> str | None:
    subprocess.run(
        ["curl", "--fail", "--location", "--silent", "--show-error", "--retry", "3",
         "--max-time", "120", "--dump-header", str(headers), "--output", str(target), url],
        check=True,
    )
    matches = re.findall(r"^last-modified:\s*(.+)$", headers.read_text(), re.I | re.M)
    return matches[-1].strip() if matches else None


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def without_external_doctype(source: Path, target: Path) -> None:
    text = source.read_text(encoding="utf-8")
    target.write_text(re.sub(r"<!DOCTYPE[^>]+>", "", text, count=1), encoding="utf-8")


def transform(source: Path, stylesheet: str, target: Path, cwd: Path) -> None:
    stylesheet_path = CASBAR_XSL / stylesheet
    if not stylesheet_path.exists():
        stylesheet_path = XSL / stylesheet
    subprocess.run(
        ["java", "-cp", str(SAXON), "net.sf.saxon.Transform",
         f"-s:{source}", f"-xsl:{stylesheet_path}", f"-o:{target}"],
        cwd=cwd, check=True,
    )


def extract_chapter(source: Path, target: Path, pad_volume: bool = False) -> None:
    tree = ET.parse(source)
    root = tree.getroot()
    parent = {child: node for node in root.iter() for child in node}
    chapter = next(
        node for node in root.iter("DIV3")
        if node.get("TYPE") == "CHAPTER" and node.get("N") == "99"
    )
    volume = parent[chapter]
    browse = parent[volume]
    body = parent[browse]
    for child in list(body):
        if child is not browse:
            body.remove(child)
    if pad_volume:
        # The legacy Volume 7 stylesheet selects the seventh ECFRBRWS element.
        for index in range(6):
            body.insert(index, ET.Element("ECFRBRWS"))
    for child in list(browse):
        if child is not volume:
            browse.remove(child)
    for child in list(volume):
        if child is not chapter:
            volume.remove(child)
    tree.write(target, encoding="utf-8", xml_declaration=True)


def validate(dita_dir: Path, source: Path) -> None:
    map_path = dita_dir / "Chapter_99_T48_7010.ditamap"
    refs = [node.get("href") for node in ET.parse(map_path).getroot().iter("topicref")]
    topics = list(dita_dir.glob("*.dita"))
    if len(refs) != len(topics) or len(refs) != len(set(refs)):
        raise ValueError("DITAMAP references do not match generated topics")
    source_root = ET.parse(source).getroot()
    source_tables = len(list(source_root.iter("TABLE")))
    source_images = len(list(source_root.iter("img")))
    table_count = image_count = 0
    for topic in topics:
        root = ET.parse(topic).getroot()
        table_count += len(list(root.iter("table")))
        for image in root.iter("image"):
            image_count += 1
            if not (dita_dir / image.get("href", "")).exists():
                raise ValueError(f"Missing image referenced by {topic.name}: {image.get('href')}")
    if any(not (dita_dir / ref).exists() for ref in refs):
        raise ValueError("DITAMAP references a missing topic")
    if (table_count, image_count) != (source_tables, source_images):
        raise ValueError("Generated table or image count differs from the eCFR XML")
    print(f"Validated {len(topics)} topics, {table_count} tables, and {image_count} images")


def chapter_map(volume_map: Path, target: Path) -> None:
    root = ET.parse(volume_map).getroot()
    chapter = next(
        node for node in root.findall("topicref")
        if node.get("href") == "Chapter_99_T48_7010.dita"
    )
    output = ET.Element("map")
    ET.SubElement(output, "title").text = "Chapter 99—Cost Accounting Standards Board"
    output.append(copy.deepcopy(chapter))
    ET.indent(output)
    xml = ET.tostring(output, encoding="unicode")
    target.write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<!DOCTYPE map PUBLIC "-//OASIS//DTD DITA Map//EN" "map.dtd">\n'
        + xml + "\n", encoding="utf-8",
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, help="Use a local Title 48 or Chapter 99 XML file")
    parser.add_argument("--graphics-zip", type=Path, help="Use a local GovInfo graphics ZIP")
    parser.add_argument("--output", type=Path, default=HERE, help="Directory for dita/, Graphics/, and the source extract")
    parser.add_argument("--formats", nargs="+", default=list(FORMATS),
                        choices=FORMATS, help="DITA-OT publishing formats (default: all seven)")
    parser.add_argument("--skip-publish", action="store_true",
                        help="Stage DITA for synchronization into a CASBAR content checkout")
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="casbar-full-") as directory:
        work = Path(directory)
        if args.source:
            source = args.source.resolve()
            xml_modified = None
        else:
            source = work / "ECFR-title48.xml"
            print("Downloading current Title 48 XML from GovInfo...")
            xml_modified = download(XML_URL, source, work / "xml-headers.txt")
        if args.graphics_zip:
            graphics_zip = args.graphics_zip.resolve()
            graphics_modified = None
        else:
            graphics_zip = work / "ECFR-title48-graphics.zip"
            print("Downloading Title 48 graphics from GovInfo...")
            graphics_modified = download(GRAPHICS_URL, graphics_zip, work / "graphics-headers.txt")
        artifact = work / "artifact"
        dita_dir = artifact / "dita"
        dita_dir.mkdir(parents=True)
        clean_source = artifact / "chapter-99-source.xml"
        extract_chapter(source, clean_source)
        extract_chapter(clean_source, work / "input.xml", pad_volume=True)
        transform(work / "input.xml", "ECFRxmlPreFix.xsl", work / "prefix.xml", work)
        without_external_doctype(work / "prefix.xml", work / "prefix-nodtd.xml")
        transform(work / "prefix-nodtd.xml", "ECFRxmlFixVolume7.xsl", work / "fixed.xml", work)
        without_external_doctype(work / "fixed.xml", work / "fixed-nodtd.xml")
        transform(work / "fixed-nodtd.xml", "conversion_stage0.xsl", work / "stage0.xml", work)
        transform(work / "stage0.xml", "conversion_stage1.xsl", work / "stage1.xml", work)
        transform(work / "stage1.xml", "conversion_stage2.xsl", work / "all.ditamap", work)
        for generated in work.glob("*.dita"):
            shutil.copy2(generated, dita_dir / generated.name)
        chapter_map(work / "Volume_7_T48_7.ditamap", dita_dir / "Chapter_99_T48_7010.ditamap")
        complete(clean_source, dita_dir, graphics_zip)
        validate(dita_dir, clean_source)
        metadata = {
            "converted_at_utc": datetime.now(timezone.utc).isoformat(),
            "xml_source": str(source) if args.source else XML_URL,
            "xml_sha256": sha256(source),
            "xml_last_modified": xml_modified,
            "graphics_source": str(graphics_zip) if args.graphics_zip else GRAPHICS_URL,
            "graphics_sha256": sha256(graphics_zip),
            "graphics_last_modified": graphics_modified,
        }
        (artifact / "conversion-metadata.json").write_text(json.dumps(metadata, indent=2) + "\n")
        output = args.output.resolve()
        output.mkdir(parents=True, exist_ok=True)
        for name in ("dita", "Graphics"):
            destination = output / name
            if destination.exists():
                shutil.rmtree(destination)
            shutil.copytree(artifact / name, destination)
        for name in ("chapter-99-source.xml", "conversion-metadata.json"):
            shutil.copy2(artifact / name, output / name)
    print(f"Wrote Chapter 99 DITA to {output / 'dita'}", flush=True)
    if not args.skip_publish:
        publish(output, args.formats)


if __name__ == "__main__":
    main()
