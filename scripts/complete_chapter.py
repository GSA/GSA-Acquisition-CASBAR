"""Finish Chapter 99 topics while preserving eCFR tables, figures, and notes."""

import re
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path


def compact(value: str) -> str:
    return " ".join(value.split())


def add_text(parent: ET.Element, value: str | None) -> None:
    if not value:
        return
    if len(parent):
        parent[-1].tail = (parent[-1].tail or "") + value
    else:
        parent.text = (parent.text or "") + value


def inline(source: ET.Element, target: ET.Element) -> None:
    add_text(target, source.text)
    for child in source:
        if child.tag == "br":
            add_text(target, "\n")
        else:
            name = {"I": "i", "E": "b", "sup": "sup", "SU": "sup"}.get(child.tag, "ph")
            inline(child, ET.SubElement(target, name))
        add_text(target, child.tail)


def table(source: ET.Element, target: ET.Element) -> None:
    rows = list(source.iter("TR"))
    columns = max(sum(int(cell.get("colspan", "1")) for cell in row) for row in rows)
    dita_table = ET.SubElement(target, "table")
    group = ET.SubElement(dita_table, "tgroup", {"cols": str(columns)})
    for index in range(columns):
        ET.SubElement(group, "colspec", {"colnum": str(index + 1), "colname": f"c{index + 1}"})
    # FO table headers cannot span into tbody. Keep such source rows together
    # in tbody while preserving their visual emphasis.
    head = (bool(rows) and all(cell.tag == "TH" for cell in rows[0])
            and not any(int(cell.get("rowspan", "1")) > 1 for cell in rows[0]))
    parent = ET.SubElement(group, "thead") if head else ET.SubElement(group, "tbody")
    occupied = [0] * columns
    for number, row in enumerate(rows):
        if number == 1 and head:
            parent = ET.SubElement(group, "tbody")
        dita_row = ET.SubElement(parent, "row")
        position = 0
        for cell in row:
            while position < columns and occupied[position] > 0:
                position += 1
            span = int(cell.get("colspan", "1"))
            depth = int(cell.get("rowspan", "1"))
            if position + span > columns:
                raise ValueError("Source table has more cells than declared columns")
            attrs = {}
            if span > 1:
                attrs.update(namest=f"c{position + 1}", nameend=f"c{position + span}")
            if depth > 1:
                attrs["morerows"] = str(depth - 1)
            entry = ET.SubElement(dita_row, "entry", attrs)
            paragraph = ET.SubElement(entry, "p")
            inline(cell, ET.SubElement(paragraph, "b") if cell.tag == "TH" and not head else paragraph)
            for column in range(position, position + span):
                occupied[column] = depth
            position += span
        occupied = [max(value - 1, 0) for value in occupied]


def blocks(source: ET.Element, target: ET.Element) -> None:
    for child in source:
        tag = child.tag
        if tag in {"HEAD", "CITA"} and source.tag in {"DIV8", "DIV9"} and tag == "HEAD":
            continue
        if tag == "P":
            inline(child, ET.SubElement(target, "p"))
        elif tag == "TABLE":
            table(child, target)
        elif tag == "img":
            figure = ET.SubElement(target, "fig")
            ET.SubElement(figure, "image", {"href": "../Graphics/" + child.get("src", "").split("/")[-1]})
        elif tag == "NOTE":
            note = ET.SubElement(target, "note")
            blocks(child, note)
        elif tag in {"HD1", "HD2", "HD3", "HED", "CITA"}:
            inline(child, ET.SubElement(target, "p", {"outputclass": "citation" if tag == "CITA" else "heading"}))
        elif len(child):
            blocks(child, target)
        elif compact(child.text or ""):
            inline(child, ET.SubElement(target, "p"))


def write_topic(target: Path, root: ET.Element) -> None:
    ET.indent(root)
    xml = re.sub(r"[ \t]+(?=\r?\n)", "", ET.tostring(root, encoding="unicode"))
    target.write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<!DOCTYPE dita PUBLIC "-//OASIS//DTD DITA Composite//EN" "ditabase.dtd">\n'
        + xml + "\n", encoding="utf-8",
    )


def complete(source_path: Path, dita_dir: Path, graphics_zip: Path | None) -> None:
    root = ET.parse(source_path).getroot()
    chapter = next(node for node in root.iter("DIV3") if node.get("N") == "99")
    sections = {compact(node.findtext("HEAD") or ""): node for node in chapter.iter("DIV8")}
    map_path = dita_dir / "Chapter_99_T48_7010.ditamap"
    dita_map = ET.parse(map_path)
    references = [node for node in dita_map.iter("topicref") if node.get("outputclass") == "Section"]
    if len(references) != len(sections):
        raise ValueError(f"Expected {len(sections)} section references, found {len(references)}")
    for reference in references:
        key = compact(reference.get("navtitle") or "")
        section = sections.pop(key)
        topic = ET.Element("dita")
        concept = ET.SubElement(topic, "concept", {
            "id": "section_" + re.sub(r"[^A-Za-z0-9_]+", "_", reference.get("href", "")),
            "outputclass": "Section",
        })
        ET.SubElement(concept, "title").text = key
        blocks(section, ET.SubElement(concept, "conbody"))
        write_topic(dita_dir / reference.get("href"), topic)
    if sections:
        raise ValueError(f"Unconverted sections: {list(sections)[:5]}")

    appendices = list(chapter.iter("DIV9"))
    appendix_refs = [node for node in dita_map.iter("topicref") if node.get("outputclass") == "Appendix"]
    if len(appendices) != len(appendix_refs):
        raise ValueError(f"Expected {len(appendices)} appendix references, found {len(appendix_refs)}")
    for appendix, reference in zip(appendices, appendix_refs):
        topic = ET.Element("dita")
        content = ET.SubElement(topic, "topic", {
            "id": "appendix_" + re.sub(r"[^A-Za-z0-9_]+", "_", reference.get("href", "")),
            "outputclass": "Appendix",
        })
        ET.SubElement(content, "title").text = compact(appendix.findtext("HEAD") or "")
        blocks(appendix, ET.SubElement(content, "body"))
        write_topic(dita_dir / reference.get("href"), topic)

    if graphics_zip:
        names = {image.get("src", "").split("/")[-1] for image in chapter.iter("img")}
        destination = dita_dir.parent / "Graphics"
        destination.mkdir(exist_ok=True)
        with zipfile.ZipFile(graphics_zip) as archive:
            for name in names:
                (destination / name).write_bytes(archive.read(name))
    else:
        missing = [image.get("src", "").split("/")[-1] for image in chapter.iter("img")
                   if not (dita_dir.parent / "Graphics" / image.get("src", "").split("/")[-1]).exists()]
        if missing:
            raise ValueError("Missing graphics; pass --graphics-zip: " + ", ".join(missing[:5]))
