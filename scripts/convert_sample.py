#!/usr/bin/env python3
"""Run the existing eCFR XSLT pipeline on a small Chapter 99 XML fixture."""

import argparse
import copy
import re
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

from tool_root import find_tool_root


ROOT = find_tool_root()
HERE = ROOT / "regulation-tools/samples/casbar-part-9900"
XSL = ROOT / "regulation-tools/TOOLS/StructureGSA_FAR/xml/DITA_1.2/app/technicalContent/xslt/ECFRConversion2DITA_Tools"
CASBAR_XSL = Path(__file__).resolve().parent / "xslt"
SAXON = ROOT / "regulation-tools/TOOLS/SaxonHE9-7-0-20J/saxon9he.jar"


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


def extract_part(source: Path, target: Path) -> None:
    tree = ET.parse(source)
    root = tree.getroot()
    parent = {child: node for node in root.iter() for child in node}
    chapter = next(
        node for node in root.iter("DIV3")
        if node.get("TYPE") == "CHAPTER" and node.get("N") == "99"
    )
    part = next(
        node for node in chapter.iter("DIV5")
        if node.get("TYPE") == "PART" and node.get("N") == "9900"
    )
    volume = parent[chapter]
    browse = parent[volume]
    body = parent[browse]
    for child in list(body):
        if child is not browse:
            body.remove(child)
    # The legacy Volume 7 stylesheet selects the seventh ECFRBRWS element.
    for index in range(6):
        body.insert(index, ET.Element("ECFRBRWS"))
    for child in list(browse):
        if child is not volume:
            browse.remove(child)
    for child in list(volume):
        if child is not chapter:
            volume.remove(child)
    for child in list(chapter):
        if child.tag not in {"HEAD", "P"} and child is not part:
            chapter.remove(child)
    tree.write(target, encoding="utf-8", xml_declaration=True)


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
    parser.add_argument("--source", type=Path, default=HERE / "part-9900-source.xml")
    args = parser.parse_args()
    output = HERE / "dita"
    output.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="casbar-sample-") as directory:
        work = Path(directory)
        extract_part(args.source, work / "input.xml")
        transform(work / "input.xml", "ECFRxmlPreFix.xsl", work / "prefix.xml", work)
        without_external_doctype(work / "prefix.xml", work / "prefix-nodtd.xml")
        transform(work / "prefix-nodtd.xml", "ECFRxmlFixVolume7.xsl", work / "fixed.xml", work)
        without_external_doctype(work / "fixed.xml", work / "fixed-nodtd.xml")
        transform(work / "fixed-nodtd.xml", "conversion_stage0.xsl", work / "stage0.xml", work)
        transform(work / "stage0.xml", "conversion_stage1.xsl", work / "stage1.xml", work)
        transform(work / "stage1.xml", "conversion_stage2.xsl", work / "all.ditamap", work)
        for generated in work.glob("*.dita"):
            shutil.copy2(generated, output / generated.name)
        chapter_map(work / "Volume_7_T48_7.ditamap", output / "Chapter_99_T48_7010.ditamap")
    print(f"Wrote sample DITA to {output}")


if __name__ == "__main__":
    main()
