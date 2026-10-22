#!/usr/bin/env python3
"""Publish the converted CASBAR map with the bundled DITA Open Toolkit."""

import argparse
import json
import re
import shutil
import subprocess
import tempfile
from datetime import datetime, timezone
from pathlib import Path

from tool_root import find_tool_root


CASBAR = Path(__file__).resolve().parent.parent
ROOT = find_tool_root()
DITA = ROOT / "regulation-tools/TOOLS/DITA-OT/dita-ot-2.5.4/bin/dita"
MAP = "Chapter_99_T48_7010.ditamap"
TRANSTYPES = {
    "html5": "html5",
    "html-parts": "gsa-copypaste.html",
    "html-all": "gsa-copypaste.html.all",
    "html-subparts": "gsa-copypaste.html.subpart",
    "pdf": "gsa-ecfr.pdf",
    "docx": "docx",
    "epub": "epub",
}
FORMATS = tuple(TRANSTYPES)
EXTENSIONS = {"pdf": ".pdf", "docx": ".docx", "epub": ".epub"}
PDF_PLUGIN = DITA.parents[1] / "plugins/org.dita.pdf2.fop"


def pdf_shell(target: Path) -> None:
    """Supply one missing variable in the bundled PDF flagging extension."""
    original = PDF_PLUGIN / "xsl/fo/topic2fo_shell_fop.xsl"
    target.write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">\n'
        f'<xsl:import href="{original.as_uri()}"/>\n'
        '<xsl:param name="doTraceTopicHandling" select="false()"/>\n'
        '</xsl:stylesheet>\n', encoding="utf-8")


def flatten_html(result_dir: Path) -> None:
    """Match the flat HTML layout and links used by the CAR/JAR repositories."""
    nested = result_dir / "dita"
    if not nested.is_dir():
        return
    for page in nested.iterdir():
        if not page.is_file() or page.suffix.lower() != ".html":
            raise RuntimeError(f"Unexpected DITA-OT HTML output: {page}")
        content = page.read_text(encoding="utf-8")
        (result_dir / page.name).write_text(
            content.replace('src="../Graphics/', 'src="Graphics/'), encoding="utf-8")
    shutil.rmtree(nested)
    index = result_dir / "index.html"
    if not index.is_file():
        raise RuntimeError("DITA-OT HTML output has no index.html")
    linked = re.findall(r'href="([^"#]+\.html)(?:#[^"]*)?"', index.read_text(encoding="utf-8"))
    missing = [href for href in linked if not (result_dir / href).is_file()]
    if missing:
        raise RuntimeError(f"DITA-OT HTML index has missing topic links: {missing[:3]}")


def publish(output: Path, formats: list[str]) -> None:
    output = output.resolve()
    source_map = output / "dita" / MAP
    if not source_map.is_file():
        raise FileNotFoundError(f"CASBAR DITAMAP is missing: {source_map}")
    if not DITA.is_file():
        raise FileNotFoundError(f"Bundled DITA-OT launcher is missing: {DITA}")
    published = output / "published"
    published.mkdir(parents=True, exist_ok=True)
    for format_name in dict.fromkeys(formats):
        if format_name not in FORMATS:
            raise ValueError(f"Unsupported format: {format_name}")
        with tempfile.TemporaryDirectory(prefix=f"casbar-{format_name}-", dir=output) as temp:
            temp_path = Path(temp)
            result_dir = temp_path / "result"
            command = [str(DITA), "-i", str(source_map), "-f", TRANSTYPES[format_name],
                       "-o", str(result_dir), "-t", str(temp_path / "work")]
            if format_name == "pdf":
                shell = temp_path / "casbar-pdf-shell.xsl"
                pdf_shell(shell)
                command.append(f"--args.xsl.pdf={shell}")
            print(f"Publishing CASBAR {format_name}...", flush=True)
            result = subprocess.run(command, text=True, stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT)
            log_path = published / f"{format_name}.log"
            log = result.stdout
            if format_name == "pdf" and result.returncode and "taskdef class org.apache.fop.tools.anttasks.Fop cannot be found" in log:
                # The bundled OT has FOP 2.10 jars but its old Ant task still
                # names a removed fop-2.2 jar. Render the FO it produced with
                # that same bundled FOP directly.
                fo = temp_path / "work/topic.fo"
                result_dir.mkdir(parents=True, exist_ok=True)
                render = subprocess.run(
                    ["java", "-cp", str(PDF_PLUGIN / "lib/*"), "org.apache.fop.cli.Main",
                     "-c", str(DITA.parents[1] / "plugins/gov.gsa.far.pdf/cfg/fo/fop.conf"),
                     "-fo", str(fo), "-pdf", str(result_dir / "CASBAR.pdf")],
                    text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                log += "\nCASBAR bundled FOP renderer:\n" + render.stdout
                result = render
            log_path.write_text(log, encoding="utf-8")
            if result.returncode:
                raise RuntimeError(f"DITA-OT {format_name} failed; see {log_path}")
            if format_name.startswith("html"):
                flatten_html(result_dir)
            files = [path for path in result_dir.rglob("*") if path.is_file()]
            if not files or (format_name in EXTENSIONS and
                             not any(path.suffix.lower() == EXTENSIONS[format_name] for path in files)):
                raise RuntimeError(f"DITA-OT {format_name} produced no expected output; see {log_path}")
            destination = published / format_name
            if destination.exists():
                shutil.rmtree(destination)
            shutil.move(str(result_dir), str(destination))
            print(f"Published {format_name} to {destination}", flush=True)
    manifest = {
        "published_at_utc": datetime.now(timezone.utc).isoformat(),
        "source_map": str(source_map),
        "formats": list(dict.fromkeys(formats)),
    }
    (published / "publication-metadata.json").write_text(json.dumps(manifest, indent=2) + "\n")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=CASBAR,
                        help="CASBAR output directory containing dita/ and Graphics/")
    parser.add_argument("--formats", nargs="+", choices=FORMATS, default=list(FORMATS))
    args = parser.parse_args()
    publish(args.output, args.formats)


if __name__ == "__main__":
    main()
