"""Find the local checkout containing CASBAR's shared conversion tools."""

import os
from pathlib import Path


def find_tool_root() -> Path:
    marker = Path("regulation-tools/TOOLS/SaxonHE9-7-0-20J/saxon9he.jar")
    configured = os.environ.get("GSA_TOOLING_ROOT")
    if configured:
        candidate = Path(configured).expanduser().resolve()
        if (candidate / marker).is_file():
            return candidate
        raise FileNotFoundError(f"GSA_TOOLING_ROOT has no shared tools: {candidate}")
    script = Path(__file__).resolve()
    for parent in script.parents:
        if (parent / marker).is_file():
            return parent
        sibling = parent / "GSA-Acquisition-FCS-Drupal-docker"
        if (sibling / marker).is_file():
            return sibling
    raise FileNotFoundError("Set GSA_TOOLING_ROOT to the GSA-Acquisition-FCS-Drupal-docker checkout")
