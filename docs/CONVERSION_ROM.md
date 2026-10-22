# Chapter 99 (CASBAR) XML-to-DITA and Drupal conversion: prospective ROM

## Scope and assumptions

Estimate a new workflow that downloads current Title 48 eCFR XML and graphics, extracts Chapter 99, converts it to DITA topics and a DITAMAP, produces HTML5, three GSA HTML variants, PDF, DOCX, and EPUB through DITA-OT, validates the outputs, and commits and pushes generated content to a prepared CASBAR Git repository. The conversion can start with one local Bash command or from an authorized Drupal admin action. A Drupal worker runs the long conversion on the server, reports status and errors, and imports the resulting CASBAR content and publication links into Drupal.

The estimate assumes one developer familiar with Drupal, XML/XSLT, Python, Bash, Git, and DITA-OT; a prepared CASBAR repository and writable remote branch; working CAR/JAR examples; an existing shared Saxon and DITA-OT installation with the needed publishing plugins; and the current Drupal job queue and DITA processing modules as a starting point. It covers Chapter 99-specific work, not rebuilding shared tools. Formal legal review, editorial acceptance of the regulation, repository creation, and infrastructure procurement are excluded. Hours are labor hours, not elapsed download or build time.

## Task estimate

| Task | Lowest fair hours | Average hours |
| --- | ---: | ---: |
| 1. Confirm source, coverage, cadence, and use terms | 2 | 2 |
| 2. Prepare and smoke-test the local toolchain | 4 | 6 |
| 3. Adapt XSLT and create the Chapter 99 DITA hierarchy | 20 | 30 |
| 4. Convert full content, tables, appendix, and graphics | 24 | 36 |
| 5. Integrate the CASBAR repository layout | 8 | 12 |
| 6. Configure and verify seven publication formats | 24 | 32 |
| 7. Validate content and output quality | 16 | 24 |
| 8. Build the Bash runner and Git delivery | 8 | 12 |
| 9. Document operation and recovery | 4 | 4 |
| **Conversion and local command subtotal** | **110** | **158** |
| 10. Design the Drupal execution flow and configuration | 4 | 6 |
| 11. Add the authorized CASBAR admin action | 8 | 12 |
| 12. Run conversion through a background worker | 12 | 18 |
| 13. Prepare the server runtime and writable workspace | 8 | 14 |
| 14. Handle server-side Git authentication and delivery | 8 | 12 |
| 15. Import CASBAR content and publication links into Drupal | 12 | 20 |
| 16. Show job status, logs, and recovery actions | 6 | 10 |
| 17. Test the Drupal-to-Git-to-Drupal workflow | 12 | 18 |
| **Drupal addition** | **70** | **110** |
| **Combined total** | **180** | **268** |

At eight labor hours per day, the combined estimate is approximately **22.5 developer days (4.5 weeks)** at the lowest fair estimate and **33.5 developer days (6.7 weeks)** at the average estimate. The average of **268 hours** is the recommended planning figure. A separate 15% schedule reserve would make the average planning allowance about **308 hours**, if the project requires a risk buffer; it is not included in the table total.

### 1. Confirm source, coverage, cadence, and use terms — 2 hours

- Locate the current official XML endpoint and graphics package; note source dates and how freshness is exposed (0.5 hour).
- Confirm that Chapter 99 can be isolated and inventory its parts, sections, appendix, tables, and images (0.75 hour).
- Record the expected update cadence or a practical freshness check for each run (0.5 hour).
- Check published use terms and attribution requirements; route unresolved legal questions outside this estimate (0.25 hour).

### 2. Prepare and smoke-test the local toolchain — 4–6 hours

- Check Java, Python, Bash, curl, Git, Saxon, DITA-OT, and required plugins (1–1.5 hours).
- Configure paths and run a small XML-to-DITA and DITA-to-publication sample (2–3 hours).
- Resolve local classpath, executable, and plugin loading issues found in the smoke test (1–1.5 hours).

### 3. Adapt XSLT and create the Chapter 99 DITA hierarchy — 20–30 hours

- Map eCFR Chapter 99 structure to the CAR/JAR conversion stages and identify Chapter 99-only differences (4–6 hours).
- Add or adapt XSLT templates for chapter, subchapter, part, subpart, and section structure (10–16 hours).
- Generate stable topic filenames and a complete DITAMAP with correct titles and references (6–8 hours).

### 4. Convert full content, tables, appendix, and graphics — 24–36 hours

- Convert all section bodies and inline formatting without dropping source text (8–12 hours).
- Handle tables, merged cells, headings, notes, and citations in valid DITA (8–12 hours).
- Convert appendix content and any special block structures (4–6 hours).
- Extract referenced graphics and create valid relative image links (4–6 hours).

### 5. Integrate the CASBAR repository layout — 8–12 hours

- Map DITA, graphics, source snapshots, and publication outputs to repository directories; preserve any cover or existing map conventions (3–4 hours).
- Copy or replace generated files safely, including obsolete-file handling and selected-format behavior (3–5 hours).
- Record source URL, retrieval date, and hashes for traceability (2–3 hours).

### 6. Configure and verify seven publication formats — 24–32 hours

- Build HTML5 and three GSA HTML variants, checking relative links and output layout (8–10 hours).
- Build the GSA PDF and resolve typography, FOP, or legacy toolkit compatibility issues (8–12 hours).
- Build and open DOCX and EPUB outputs (6–8 hours).
- Normalize final filenames and directory placement (2 hours).

### 7. Validate content and output quality — 16–24 hours

- Compare chapter coverage and representative source text against the XML (4–6 hours).
- Check DITAMAP references, XML parsing, table/image counts, and graphic paths (4–6 hours).
- Open or inspect representative HTML, PDF, DOCX, and EPUB results (4–6 hours).
- Repair conversion defects found by these checks and rerun affected outputs (4–6 hours).

### 8. Build the Bash runner and Git delivery — 8–12 hours

- Add command options for live download, saved XML/graphics, selected formats, and local-only runs; check prerequisites (2–3 hours).
- Orchestrate download, conversion, validation, publication, and temporary files with clear failure behavior (2–3 hours).
- Check branch/upstream state, stage only generated paths, commit changed results, and push to the prepared remote (3–4 hours).
- Test a successful push and failure/recovery paths, including remote changes or an interrupted build (1–2 hours).

### 9. Document operation and recovery — 4 hours

- Write local and Drupal prerequisites and copyable commands for default, offline, and selected-format runs (2 hours).
- Describe job logs, failed build cleanup, and failed push recovery (1 hour).
- Record output locations, Drupal result locations, and a brief handoff checklist (1 hour).

### 10. Design the Drupal execution flow and configuration — 4–6 hours

- Review the existing `agov_job_queue` form, queue records, Drush worker, and `agov_dita_processing` flow for reusable boundaries (2–3 hours).
- Define CASBAR job states, configurable repository/branch paths, artifact locations, and the handoff between conversion and Drupal import (2–3 hours).

### 11. Add the authorized CASBAR admin action — 8–12 hours

- Add CASBAR to the regulation and repository selections with constrained branch settings (3–4 hours).
- Add a “Run now” action with Drupal permission and request validation; submit a job rather than executing the conversion in the HTTP request (3–5 hours).
- Show the queued job identifier and link to its status page (2–3 hours).

### 12. Run conversion through a background worker — 12–18 hours

- Register CASBAR with the queue/Drush dispatch and map the job to the conversion command (4–6 hours).
- Execute the Bash entry point in an isolated server workspace, capture exit code and logs, and prevent overlapping CASBAR runs (4–6 hours).
- Apply timeouts, failure states, and cleanup so a stopped worker can be retried safely (4–6 hours).

### 13. Prepare the server runtime and writable workspace — 8–14 hours

- Make Python, Java, Saxon, DITA-OT, plugins, and Git available to the worker in each target environment (3–5 hours).
- Configure persistent repository checkout, writable temporary space, file ownership, and sufficient disk/memory (3–5 hours).
- Smoke-test downloads and a sample build under the actual worker account (2–4 hours).

### 14. Handle server-side Git authentication and delivery — 8–12 hours

- Supply least-privilege push credentials to the worker without writing them into logs or Drupal configuration exports (3–4 hours).
- Provision a clean server-side checkout and invoke the Git delivery from task 8 with the configured remote and branch (3–5 hours).
- Handle remote branch movement, push failure, and duplicate reruns without silently overwriting work (2–3 hours).

### 15. Import CASBAR content and publication links into Drupal — 12–20 hours

- Register CASBAR, its DITAMAP, content type mapping, and output directories with the existing DITA import conventions (4–6 hours).
- Import the generated HTML and expose PDF, DOCX, EPUB, and other publication links in the expected Drupal locations (4–7 hours).
- Check topic order, internal links, images, existing-node updates, and search/index behavior after import (4–7 hours).

### 16. Show job status, logs, and recovery actions — 6–10 hours

- Record source version, job phases, Git commit, output paths, and actionable errors (2–3 hours).
- Show queued/running/succeeded/failed states and publication links in the admin UI (2–4 hours).
- Provide a controlled retry/recovery path for failed conversion or push (2–3 hours).

### 17. Test the Drupal-to-Git-to-Drupal workflow — 12–18 hours

- Test form permissions, input validation, and queue transitions (3–5 hours).
- Test worker failure, concurrent requests, missing runtime, and Git rejection cases (4–6 hours).
- Run a staging end-to-end test from Drupal submission through all seven outputs, Git push, and Drupal import (5–7 hours).

## Main estimating risks

The largest conversion uncertainty is source-specific content that does not fit the CAR/JAR templates, especially complex tables and PDF layout. Drupal uncertainty centers on the server runtime: the current Drupal job form and Drush worker process imported DITA from Git, so the source download, conversion, publishing, and push must be wired into a long-running background job. The current local Docker image includes Java and Git but does not visibly install Python for the conversion worker. If runtime provisioning, Git credentials, or Drupal content mapping differ materially from these assumptions, revise tasks 12–17 before committing to a delivery date.
