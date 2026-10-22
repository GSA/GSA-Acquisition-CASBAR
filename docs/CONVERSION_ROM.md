# CASBAR Chapter 99 local conversion: scope and rough order of magnitude

## Scope and current status

The local command `./scripts/run_casbar.sh` downloads the current Title 48 eCFR bulk XML and graphics ZIP from GovInfo, extracts Chapter 99, creates DITA topics and a DITAMAP, validates topic and image references, publishes seven formats, synchronizes generated files into this CASBAR checkout, commits them, and pushes the current branch to `origin`. Drupal integration is outside this scope.

This workflow is implemented. It was exercised with saved GovInfo inputs through DITA, HTML5, a temporary Git commit, and a push to a local bare remote. Earlier full publication runs covered the three GSA HTML variants, PDF, DOCX, and EPUB. A live rerun depends on GovInfo availability and valid Git credentials.

## Local operation

Requirements: a CASBAR Git checkout on a named branch tracking `origin/<same-name>`; a clean checkout and an up-to-date remote branch; configured Git author and push credentials; Python 3.10 or later, Java, Bash, curl, and Git; the sibling `GSA-Acquisition-FCS-Drupal-docker` checkout containing Saxon 9.7 and DITA-OT 2.5.4. If the tooling checkout is elsewhere, set `GSA_TOOLING_ROOT` to its absolute path. The bundled toolkit contains the required GSA HTML/PDF, DOCX, and EPUB plugins.

```bash
cd /Users/stevengebremariam/Sites/aws/stage/GSA-Acquisition-CASBAR
./scripts/run_casbar.sh
```

For a local preview, use `./scripts/run_casbar.sh --no-git`. For an offline run, add `--source /absolute/path/to/title48.xml --graphics-zip /absolute/path/to/title48-graphics.zip`. Add `--formats html5 pdf docx epub` to select formats; the default publishes `html5`, `html-parts`, `html-all`, `html-subparts`, `pdf`, `docx`, and `epub`. `--output /absolute/path` creates standalone conversion output without syncing or pushing.

The Git preflight checks branch tracking, checkout cleanliness, and equality with the fetched upstream. The runner checks the remote again before staging generated paths. It commits only when generated files differ. A push failure leaves the commit locally; resolve the push before another default run. `--no-git` leaves generated changes locally, so commit, restore, or review those changes before the next default run.

## Implemented components

| Component | Files | Responsibility |
| --- | --- | --- |
| Local entry point and Git delivery | `scripts/run_casbar.sh` | Preflight, temporary work area, conversion, sync, generated-file commit and push. |
| Source and XSLT pipeline | `scripts/convert_chapter.py`, `scripts/xslt/*.xsl` | Download bulk XML and graphics, extract Chapter 99, run Saxon stages, create the chapter map, record source hashes and dates. |
| Chapter completion | `scripts/complete_chapter.py` | Fill section and appendix bodies, tables, notes, and figures; extract referenced images. |
| Tool discovery | `scripts/tool_root.py` | Find the shared tooling checkout. |
| Repository sync | `scripts/sync_to_casbar_repo.py` | Preserve the existing VolumeChapter cover, copy DITA/graphics/source, publish from the CASBAR map, copy final artifacts. |
| DITA-OT publishing | `scripts/publish_chapter.py` | Build HTML5, three GSA HTML variants, GSA PDF, DOCX, and EPUB. Uses bundled FOP directly for the old PDF Ant classpath mismatch. |
| Sample/legacy aids | `scripts/convert_sample.py`, `scripts/legacy/*.bat` | Initial sample converter and historical Windows scripts; not called by the full local runner. |

Shared conversion XSLT and DITA-OT plugins remain in the FCS tooling checkout. CASBAR-specific XSLT copies are under `scripts/xslt/`. The tooling checkout also contains a copy of the CASBAR scripts at `regulation-tools/casbar/scripts/`.

The generated map has 255 Chapter 99 topic references plus the repository's existing VolumeChapter cover. Current source coverage includes seven parts, 241 sections, three subparts, two subchapters, Appendix B, 54 tables, and 70 images. Outputs are in `dita/`, `Graphics/`, `source/`, `html5/`, `html/`, `pdf/`, `docx/`, and `epub/`.

## If this had to be built from scratch

One experienced developer, eight-hour working days. Hours include implementation and focused verification, but exclude Drupal work, external repository provisioning, and legal/editorial approval of regulation content.

| Task | Deliverable | ROM hours |
| --- | --- | ---: |
| Confirm source, chapter coverage, update cadence, and licensing | Source inventory and sample XML | 8–16 |
| Prepare Java, Saxon, DITA-OT, plugins, and local Git checkouts | Reproducible local prerequisites | 4–8 |
| Adapt the shared XSLT and construct Chapter 99 map and topic hierarchy | Base DITA and map | 24–40 |
| Complete sections, appendix, tables, notes, citations, and graphics | Full content conversion | 24–48 |
| Integrate CASBAR repository layout and retain VolumeChapter cover | Sync workflow | 8–16 |
| Configure and repair seven DITA-OT output builds | HTML, PDF, DOCX, EPUB | 24–40 |
| Validate source coverage, links, media, and publication artifacts | QA evidence and repairs | 16–32 |
| Add Bash orchestration, metadata, Git preflight, commit, and push | On-demand local command | 8–16 |
| Document operation, recovery, and handoff | README and runbook | 4–8 |
| **Base total** | | **120–224** |

Allow roughly 20% contingency for source changes, legacy toolkit incompatibilities, and publication layout fixes: **144–269 hours, or about 18–34 working days (approximately 4–7 weeks for one developer)**. This is a planning range, not a quote or a record of time already spent.

The requested local workflow is implemented. Optional follow-up hardening is about **8–24 hours**: make identical-source reruns fully reproducible, add a compact content regression fixture and automated publication checks, and test on any additional local operating systems or Java versions the team uses. Editorial review of the generated regulation and branch merge/release decisions remain separate activities.

## Operational boundaries

- The default runner pushes to the current tracked branch; it does not create a repository, branch, or pull request.
- A rerun can create a new commit for unchanged source because conversion and publication metadata include timestamps, and generated files may differ in formatting or packaging.
- The automatic validation checks topic references, XML well-formedness, table and image counts, and image targets. Source-to-DITA text comparison and visual review were performed during initial implementation but are not automatic gates on every run.
- A failed build stops before the Git commit. Files copied during synchronization may need review or restoration before rerunning.
