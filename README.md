# GSA-Acquisition-CASBAR

Cost Accounting Standards Board Acquisition Regulation (Title 48, Chapter 99).

The `dita/Chapter_99_T48_7010.ditamap` covers all seven parts, 241 sections, three subparts, two subchapters, and Appendix B. The repository retains its VolumeChapter cover topic. The DITA includes 54 tables and references 70 chapter graphics in `Graphics/`.

## Source and conversion

`source/chapter-99-source.xml` is an extract from the Title 48 eCFR XML downloaded from [GovInfo](https://www.govinfo.gov/bulkdata/ECFR/title-48/ECFR-title48.xml) on October 21, 2026. GovInfo reported the XML last modified October 20, 2026, 21:44:56 GMT; the eCFR titles API reported Title 48's latest issue date as October 19, 2026. SHA-256 of the full Title 48 XML: `f9c167666322e602154638f028866aab6bb9ba7b39c83aacb9b25b54c2debbd5`.

The conversion and synchronization scripts are in `regulation-tools/casbar/` of the GSA-Acquisition-FCS-Drupal-docker repository, branch `codex/casbar-full-conversion`. They use the repository's Saxon 9.7 JAR and eCFR XSLT, then preserve Chapter 99 tables, images, notes, and source text in the DITA topics.

## Validation

All 256 DITAMAP references and 70 image references resolve. All DITA files are well-formed XML. Every section body and the appendix text match the source XML after whitespace normalization. The bundled DITA-OT 2.5.4 completed an HTML5 build of the DITAMAP.
