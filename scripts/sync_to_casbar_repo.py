#!/usr/bin/env python3
"""Copy validated Chapter 99 DITA into the existing CASBAR content repository."""

import argparse
import copy
import shutil
import xml.etree.ElementTree as ET
from pathlib import Path

from publish_chapter import FORMATS, publish


HERE = Path(__file__).resolve().parent.parent
MAP_NAME = "Chapter_99_T48_7010.ditamap"
PUBLICATIONS = {
    "html5": "html5",
    "html-parts": "html/copypaste-FullParts",
    "html-all": "html/copypaste-AllTopic",
    "html-subparts": "html/copypaste-Subparts",
    "pdf": "pdf",
    "docx": "docx",
    "epub": "epub",
}


def replace_tree(source: Path, target: Path) -> None:
    if not source.is_dir():
        raise FileNotFoundError(f"Missing generated CASBAR output: {source}")
    if target.exists():
        shutil.rmtree(target)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(source, target, ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("repository", type=Path)
    parser.add_argument("--from-output", type=Path,
                        help="Converted CASBAR output directory (default: alongside this script)")
    parser.add_argument("--formats", nargs="+", choices=FORMATS, default=list(FORMATS))
    args = parser.parse_args()
    repository = args.repository.resolve()
    source_output = args.from_output.resolve() if args.from_output else HERE
    if repository == source_output:
        raise ValueError("Source output and CASBAR repository must be different directories")
    old_map_path = repository / "dita" / MAP_NAME
    new_map_path = source_output / "dita" / MAP_NAME
    old_map = ET.parse(old_map_path)
    new_map = ET.parse(new_map_path)

    # Preserve the existing VolumeChapter cover and metadata used by CASBAR.
    old_root = old_map.getroot()
    new_root = new_map.getroot()
    new_part = next(node for node in new_root.iter("topicref") if node.get("href", "").startswith("Part_9900_"))
    if not any(node.get("href") == new_part.get("href") for node in old_root.iter("topicref")):
        old_root.insert(2, copy.deepcopy(new_part))
    new_appendix = next(node for node in new_root.iter("topicref") if node.get("outputclass") == "Appendix")
    old_part_9904 = next(node for node in old_root.iter("topicref") if node.get("href", "").startswith("Part_9904_"))
    if not any(node.get("href") == new_appendix.get("href") for node in old_root.iter("topicref")):
        old_part_9904.append(copy.deepcopy(new_appendix))

    for topic in (source_output / "dita").glob("*.dita"):
        shutil.copy2(topic, repository / "dita" / topic.name)
    for graphic in (source_output / "Graphics").iterdir():
        shutil.copy2(graphic, repository / "Graphics" / graphic.name)
    source_dir = repository / "source"
    source_dir.mkdir(exist_ok=True)
    shutil.copy2(source_output / "chapter-99-source.xml", source_dir / "chapter-99-source.xml")
    shutil.copy2(source_output / "conversion-metadata.json", source_dir / "conversion-metadata.json")

    ET.indent(old_root)
    old_map_path.write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<!DOCTYPE map PUBLIC "-//OASIS//DTD DITA Map//EN" "map.dtd">\n'
        + ET.tostring(old_root, encoding="unicode") + "\n",
        encoding="utf-8",
    )
    if HERE != repository:
        replace_tree(HERE / "scripts", repository / "scripts")
    # Publish the target map so its existing VolumeChapter cover is included.
    publish(repository, args.formats)
    for format_name in args.formats:
        relative = PUBLICATIONS[format_name]
        replace_tree(repository / "published" / format_name, repository / relative)
    shutil.copy2(repository / "published/publication-metadata.json",
                 repository / "publication-metadata.json")
    shutil.rmtree(repository / "published")
    print(f"Updated CASBAR content in {repository}")


if __name__ == "__main__":
    main()
