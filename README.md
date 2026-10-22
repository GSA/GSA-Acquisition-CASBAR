# GSA-Acquisition-CASBAR

Cost Accounting Standards Board Acquisition Regulation (Title 48, Chapter 99).

The `dita/Chapter_99_T48_7010.ditamap` covers all seven parts, 241 sections, three subparts, two subchapters, and Appendix B. The repository retains its VolumeChapter cover topic. The DITA includes 54 tables and references 70 chapter graphics in `Graphics/`.

## Source and conversion

`source/chapter-99-source.xml` is an extract from the Title 48 eCFR XML downloaded from [GovInfo](https://www.govinfo.gov/bulkdata/ECFR/title-48/ECFR-title48.xml) on October 21, 2026. GovInfo reported the XML last modified October 20, 2026, 21:44:56 GMT; the eCFR titles API reported Title 48's latest issue date as October 19, 2026. SHA-256 of the full Title 48 XML: `f9c167666322e602154638f028866aab6bb9ba7b39c83aacb9b25b54c2debbd5`.

The CASBAR-only conversion, publishing, and synchronization scripts are in [`scripts/`](scripts/). They use the shared Saxon 9.7, XSLT, and DITA-OT 2.5.4 installation from a sibling `GSA-Acquisition-FCS-Drupal-docker` checkout. If the checkouts are elsewhere, set `GSA_TOOLING_ROOT` to that repository's absolute path.

Run `./scripts/run_casbar.sh` to download current Title 48 XML and graphics from GovInfo, convert Chapter 99, retain the existing VolumeChapter cover, and publish all formats. The scripts accept `--source` and `--graphics-zip` to use saved inputs. `source/conversion-metadata.json` records URLs, modification dates, hashes, and retrieval time. The CASBAR-specific XSLT copies are in `scripts/xslt/`; unchanged shared XSLT stays in the tooling repository. The old Windows batch scripts are retained in `scripts/legacy/` for reference.

## Publications

DITA-OT builds standard HTML5 in `html5/`, GSA copy/paste HTML in `html/copypaste-FullParts/`, `html/copypaste-AllTopic/`, and `html/copypaste-Subparts/`, a GSA eCFR-style PDF in `pdf/CASBAR.pdf`, a Word document in `docx/Chapter_99_T48_7010.docx`, and an EPUB in `epub/Chapter_99_T48_7010.epub`. The PDF uses the bundled FOP renderer after DITA-OT generates formatting objects because this installation's PDF Ant task references an old absent FOP jar.

## Validation

All 256 DITAMAP references and 70 image references resolve. All DITA files are well-formed XML. Every section body and the appendix text match the source XML after whitespace normalization. The bundled DITA-OT 2.5.4 publishes the formats listed above.
