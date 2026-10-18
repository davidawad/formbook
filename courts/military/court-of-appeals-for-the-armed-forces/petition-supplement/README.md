# CAAF: supplement to petition for grant of review (`petition-supplement`)

Court: United States Court of Appeals for the Armed Forces (`armfor`). Doc type: the supplement to a petition for grant of review, Rule 21. Status: **template built; not a court-level status.** `court.json` is not touched (only David sets `done`).

## Governing rules

Primary source for every requirement: **CAAF Rules of Practice and Procedure, effective October 1, 2024, as amended through September 26, 2025**, https://www.armfor.uscourts.gov/library/Rules/Rules2025SepAmendedThrough26September2025.pdf. Fetched and read on 2026-10-14 (text layer, `pdftotext`). Rule 21 was read in full; Rules 24, 37, 38 and 39 were read in the parts cited below. The court posted a 2026 Federal Register notice of a proposed redrafting of these rules (seen in search results, not retrieved). If a redrafted version is adopted, Rule 21 must be re-checked before this template is used.

Kinds: **M** mandated by a court rule; **C** convention (taken from the filed exemplars, the rules leave it open); **A** author responsibility (not generated).

| ID | Requirement | Source | Kind | Where in the template |
|---|---|---|---|---|
| CAAF-SUP-001 | Supplement and any answer may not exceed 9,000 words. Headings, footnotes and quotations count. | Rule 21(b), 37(d) | M | `word-limit`; `armfor-petition-supplement()` panics over the limit |
| CAAF-SUP-002 | Required contents, in order: (1) assigned errors, (2) statutory jurisdiction, (3) chronology (statement of the case), (4) facts with record page references, (5) good-cause argument. | Rule 21(b)(1)-(5) | M | `required-sections`; `check-structure()` panics if missing or out of order |
| CAAF-SUP-003 | Certificate stating the word count complies with the type-volume limit of Rule 21 and Rule 37. | Rule 21(b)(6) | M | `certificate-of-compliance()` |
| CAAF-SUP-004 | Appendix with an official copy of the Court of Criminal Appeals decision. | Rule 21(b) | A | Not generated (see Known gaps) |
| CAAF-SUP-005 | Typeface: proportional type, 14-point, printed matter including footnotes; margins at least one inch on all four sides; page numbers may sit in the margin, no text in the margin. | Rule 37(a) | M | `type-size`, `page-margin`, footnote style |
| CAAF-SUP-006 | Double spacing. The rule text says "typewritten and double-spaced" for papers not filed electronically. For electronic filing the rule does not say it; the filed exemplars are double-spaced. | Rule 37(a); exemplars | C | `body-leading`, calibrated as in ca9 |
| CAAF-SUP-007 | Index of the matter with page references and a table of cases, statutes and other authorities, for any pleading of ten or more pages. Authorities alphabetical within their groups, with the pages cited. | Rule 37(c)(1) | M | `index-section()`, `toa-section()` |
| CAAF-SUP-008 | Citations conform to The Bluebook. Record references include page numbers or exhibit designations. No incorporation by reference. | Rule 37(c)(2)-(4) | A | Author; not machine-checked |
| CAAF-SUP-009 | Signature of counsel of record: name, address, email, telephone, Court Bar number, grade, capacity; electronic filings carry `/s/`. | Rule 38(a), (c) | M | `signature-block()`, `/s/` prefix |
| CAAF-SUP-010 | Proof of service in substantially the Rule 39(c)(2) form: means of delivery to the Court and to the party, the address, and the date. | Rule 39(c)(1)-(2) | M | `certificate-of-service()` |
| CAAF-SUP-011 | Cover: court caption, party captions, title, Crim. App. docket number and USCA docket number, counsel block. The cover is not numbered. | Rule 24(a) form (applied to supplements by the exemplars) | C | `cover()` |
| CAAF-SUP-012 | Front matter in lowercase roman, the body in Arabic from 1 on the first page of the Issue. | Convention of the exemplars | C | `set page(numbering:)` |

Rules that do not apply to the supplement: Rule 24(a)'s "Relevant Authorities" and "References to the Record" headings are optional for a brief, and no rule makes them mandatory for a supplement. Rule 24(b) (13,000 words) is the brief limit and is in `../opening-brief/`.

## Layout

| Path | What |
|---|---|
| `typst/armfor-petition-supplement.typ` | The template: `armfor-petition-supplement(meta, md)`. Content-agnostic: no case text, no coordinates, no forced line breaks, the vendored EB Garamond only (`fallback: false`). |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...` and passes it to the template. |
| `usage/INPUT-petition-supplement.md` | The markdown transcription of the Cooper exemplar: frontmatter (caption, counsel, signature, service, authorities), then the Issue, jurisdiction, chronology, facts, the good-cause argument and point I with its sub-headings, and the conclusion. About a third of the filed text. |
| `usage/OUTPUT-petition-supplement.typst.pdf` | The render, 12 pages. |
| `usage/OVERLAY-cooper-supplement.pdf`, `.txt` | The red/blue comparison and its page map. |
| `usage/FILED-EXAMPLE-petition-supplement.pdf` | Filed exemplar 1 (Air Force). |
| `usage/FILED-EXAMPLE-petition-supplement-2.pdf` | Filed exemplar 2 (Marine Corps), for the tier-2 cross-check. |
| `usage/SOURCE.md` | URL, case, docket, filer, date filed, date fetched, for both exemplars. |

File names follow the repository's file-role convention (`INPUT-`, `OUTPUT-`, `OVERLAY-`) because `tools/render.sh` and `tools/overlay.sh` read and write those names by default. The brief asked for `usage/<id>.md` and `<id>-overlay.pdf`; the tools cannot produce those names without an edit to shared tools, which this box does not make.

Commands, from the repository root:

```sh
export PATH="$HOME/tb/bin:$PATH"   # toolchain from the box setup (typst 0.15.0, poppler, ImageMagick)
sh tools/render.sh courts/military/court-of-appeals-for-the-armed-forces/petition-supplement usage/INPUT-petition-supplement.md
sh tools/overlay.sh courts/military/court-of-appeals-for-the-armed-forces/petition-supplement cooper-supplement
```

## Results

- Render: **ok**. `tools/render.sh` ran and wrote `usage/OUTPUT-petition-supplement.typst.pdf` with no typst warnings. Fonts: `EBGaramond-Regular`, `-Bold`, `-Italic`, all embedded; nothing else.
- Overlay: **ok**. `tools/overlay.sh` ran against Cooper (the first exemplar by name) and wrote `OVERLAY-cooper-supplement.pdf`. Page map in `OVERLAY-cooper-supplement.txt`: the cover and index pair with the exemplar's first pages, and the body pairs with the exemplar's body pages (filed pages 6 to 9, 12, 14, 22 and 25 by text overlap). The lowest word overlaps are ours p.3 (31%, the table of authorities, which the exemplar lays out differently), ours p.9 (34%, the page that ends in white space) and ours p.2 (47%, the index). The overlay is a diagnostic, not a score; the differences it shows on these pages were read from the render above and accepted or fixed there.
- Pages reviewed: **12 of 12**. Each page of the current PDF was rendered at 60 dpi and looked at.

## Gate 2: visual review of `usage/OUTPUT-petition-supplement.typst.pdf`

Every page of the 12-page PDF was rendered at 60 dpi and looked at. "PDF p." is the page of the render; "body" is the page number printed in the footer. "Compared with" is the Cooper exemplar page that the overlay pairs with it (`OVERLAY-cooper-supplement.txt`).

| PDF p. (printed) | Compared with | Finding | Status |
|---|---|---|---|
| 1 (cover) | exemplar p.1 | Caption, party roles, title, both docket numbers and the counsel block fit on one page. The counsel name wraps ("PAIGE F. MARKLEY DENTON, Capt, / USAF") because the counsel column is narrow at this width. | ACCEPTED (name wrap in an author-supplied block; tier 2, no rule) |
| 2 (i) | exemplar p.2 | Index of Brief with a page column. The first render wrapped the page number of the "B." row onto its own line; the number box was narrowed, the file re-rendered and the page re-viewed. | FIXED |
| 3 (ii) | exemplar p.3 | Table of Cases, Statutes, and Other Authorities, grouped by court, statute and rule, with page columns and dot leaders. | PASS |
| 4 (body 1) | exemplar p.6 | Issue Presented in bold sentence case; Statement of Statutory Jurisdiction; Statement of the Case. Double spaced, 14-point, centered section headings. | PASS |
| 5 (body 2) | exemplar p.7 | Statement of Facts; sub-heading A in bold with a hanging label. | PASS |
| 6 (body 3) | exemplar p.8 | Sub-heading B; inline record citations; italic *Id.* | PASS |
| 7 (body 4) | exemplar p.9 | Block quotation (DAFI 51-101) indented and single-spaced; the Argument heading is centered; the good-cause paragraph. | PASS |
| 8 (body 5) | exemplar p.12 | Point I centered, bold, with the roman numeral; sub-heading A with its hanging label; short-form citations in italic. | PASS |
| 9 (body 6) | exemplar p.14 | Sub-heading B, "Standard of Review and Applicable Legal Test", and the citation after it. The page ends with white space because the Conclusion and its signature block are kept together and moved to the next page. | ACCEPTED (the rule that keeps the signature with its text causes the space; the filing itself is not defective) |
| 10 (body 7) | exemplar p.22 | Conclusion; `/s/` signature block with the counsel's lines and the date. | PASS |
| 11 (8) | exemplar p.25 | Certificate of Compliance (Rule 21(b)(6)) with the computed word count and the `/s/` signature. | PASS |
| 12 (9) | exemplar p.25 | Certificate of Filing and Service in the Rule 39(c)(2) form, with the served address and the date. | PASS |

Overall visual result: the cover fits one page, the index and authorities are populated with page numbers that match the body, and no page has a defect that is tier 1 or tier 2.

## Known gaps

- **Appendix (CAAF-SUP-004).** Rule 21(b) requires the Court of Criminal Appeals decision as an appendix. The template does not generate it; the author attaches the decision. The exemplar's appendix is a copy of the CCA opinion.
- **Word count (CAAF-SUP-001, -003).** The count is computed from the markdown body by the template: headings, footnotes and quotations are counted; cover, index, authorities, certificates and signature are not. It is an approximation of a word processor's count (Rule 37(d) lets the preparer use the processor's count). The author must confirm it before filing, and the sample's count (1,303 words) is for the transcription only.
- **Sample is an excerpt.** The Cooper transcription covers the cover, index, issue, jurisdiction, chronology, the first two fact sections, the good-cause argument, the first part of point I, the conclusion and the certificates. It does not reproduce the full filing (the filed PDF runs to about 5,200 words including its index, authorities and appendix). The sample is a visual and structural reference, not the whole brief.
- **Typeface (CAAF-SUP-005): face=none named, font=EB Garamond.** Rule 37(a) requires "proportional type, e.g., Times New Roman, in fourteen-point type". The "e.g." makes Times New Roman an example, not a requirement, so the rule names no face. Per `docs/FONTS.md` ("No face named" row) the template keeps EB Garamond. The exemplars use Century Schoolbook (Cooper, Muller), Times New Roman (Pinkerton) and a Times-style face (Hernandez): they agree on a proportional serif at 14 points, not on a face. Font choice is tier 2 and does not change any mandated requirement. Page count is unchanged by this review (no font change; 12 pages rendered).
- **Double spacing for electronic filing.** Rule 37(a) requires double spacing for papers "not filed electronically". The template double-spaces every filing, as the exemplars do (CAAF-SUP-006).
- **No mechanical checks.** This doc type has no `checks.yaml` and no pass stamp; `tools/check.sh` does not run on it. The requirements above are checked by reading the rendered pages, not by a gate.
- **Front matter.** The index takes the first roman page and the table of authorities the second. A longer authorities list would take a third roman page; the template does not limit it.
- **Not implemented.** Sealed material (Rule 35A), classified material (Rule 12), and a motion to file out of time are not part of this template.
- **Rule currency.** Checked against the Sept. 26, 2025 amended-through rules only (see Governing rules).

## Engines

**typst** (`typst/`, primary; the reference for the form) and **docx** (`docx/`). No LaTeX engine.

**docx** (`docx/`): `sh docx/render.sh` (called by `tools/render-docx.sh`) runs pandoc with `docx/armfor.lua` on `docx/reference.docx`. `docx/build-reference.sh` builds the reference (EB Garamond styles, footer page numbers; byte-identical across runs). The index and the table of authorities print body page numbers, so the render runs three passes: a first render to PDF, a search of the body pages for each heading and authority link, a final render, and a second search that must give the same pages.

- Matches the typst form: EB Garamond 14 pt throughout (footnotes 14 pt, single-spaced); body lines exact 31.4 pt (double) with a 0.5 in first-line indent; letter paper, 1 in margins; the cover (caption, title, dockets, counsel block at the foot of the text area); index and table in roman numerals; the body from page 1, with the numbering of the Issue, Argument and sub-headings and hanging headings; the signature kept with the last paragraph; the certificate of compliance and the certificate of filing and service.
- Differs: line and page breaks are LibreOffice's (the PDF that is checked), not typst's, so the page numbers in the index and the table are those of the LibreOffice PDF; Word may paginate differently. The certificate's word count is counted from the docx text (1301); the typst render counts the markdown (1303). The author confirms the figure before filing. The cover's caption spacing is tighter. The counsel block sits at the foot of the text area in LibreOffice; Word's placement of the floating table is not checked.
- Pages reviewed: 12 of 12 (docx PDF), each rendered at 60 dpi and looked at, with the typst pages compared.
- BLOCKED (gates cannot run, no check IDs run): `sh tools/check.sh <court-dir> --engine docx` exits 2 with `Error: open .../petition-supplement/checks.yaml: no such file or directory` (this snapshot has no `checks.yaml` for this court). The `.docx` has not been opened in Microsoft Word (no Word here); LibreOffice opened it and rendered the PDF.
