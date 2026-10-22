# Chapter 99 (CASBAR) XML-to-DITA conversion: prospective ROM

## Scope and assumptions

Estimate a new local command-line workflow that downloads current Title 48 eCFR XML and graphics, extracts Chapter 99, converts it to DITA topics and a DITAMAP, produces HTML5, three GSA HTML variants, PDF, DOCX, and EPUB through DITA-OT, validates the outputs, and commits and pushes generated content to a prepared CASBAR Git repository. The user starts it on demand with one Bash command. Drupal integration is excluded.

The estimate assumes one developer familiar with XML/XSLT, Python, Bash, Git, and DITA-OT; a prepared CASBAR repository and writable remote branch; working CAR/JAR examples; and an existing shared Saxon and DITA-OT installation with the needed publishing plugins. It covers Chapter 99-specific work, not rebuilding shared tools. Formal legal review, editorial acceptance of the regulation, repository creation, and Drupal UI or server work are excluded. Hours are labor hours, not elapsed download or build time.

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
| **Total** | **110** | **158** |

At eight labor hours per day, these are approximately **14 developer days (2.75 weeks)** at the lowest fair estimate and **20 developer days (4 weeks)** at the average estimate. The average is the recommended planning figure. A separate 15% schedule reserve would make the average planning allowance about **182 hours**, if the project requires a risk buffer; it is not included in the table total.

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

- Write prerequisites and copyable commands for default, offline, and selected-format runs (2 hours).
- Describe logs, failed build cleanup, and failed push recovery (1 hour).
- Record output locations and a brief handoff checklist (1 hour).

## Main estimating risks

The largest uncertainty is source-specific content that does not fit the CAR/JAR templates, especially complex tables and PDF layout. If the available DITA-OT plugins or the prepared Git repository differ materially from the assumptions, revise tasks 2, 5, 6, and 8 before committing to a delivery date.
