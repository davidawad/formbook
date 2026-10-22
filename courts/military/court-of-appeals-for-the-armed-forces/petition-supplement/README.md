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
| `typst/armfor-petition-supplement.typ` | The template: `armfor-petition-supplement(meta, md)`. Content-agnostic: no case text, no coordinates, no forced line breaks, the pinned Times New Roman only (`docs/FONTS.md` rule 1; Liberation Serif from `fonts/` as the named fallback; `fallback: false`). |
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

- Render: **ok**. `tools/render.sh` ran and wrote `usage/OUTPUT-petition-supplement.typst.pdf` with no typst warnings. Fonts (2026-10-22 render): `TimesNewRomanPSMT`, `-BoldMT`, `-ItalicMT`, all embedded.
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
- **Typeface (CAAF-SUP-005): face=none named, font=Times New Roman.** Rule 37(a) requires "proportional type, e.g., Times New Roman, in fourteen-point type". The "e.g." makes Times New Roman an example, not a requirement, so the rule names no face. The template now sets Times New Roman, the house standard (`docs/FONTS.md` rule 6); when this review was written it kept EB Garamond per the then "No face named" row. The exemplars use Century Schoolbook (Cooper, Muller), Times New Roman (Pinkerton) and a Times-style face (Hernandez): they agree on a proportional serif at 14 points, not on a face. Font choice is tier 2 and does not change any mandated requirement. Page count was unchanged by that review (no font change then; 12 pages rendered on the earlier EB Garamond render).
- **Double spacing for electronic filing.** Rule 37(a) requires double spacing for papers "not filed electronically". The template double-spaces every filing, as the exemplars do (CAAF-SUP-006).
- **No mechanical checks.** This doc type has no `checks.yaml` and no pass stamp; `tools/check.sh` does not run on it. The requirements above are checked by reading the rendered pages, not by a gate.
- **Front matter.** The index takes the first roman page and the table of authorities the second. A longer authorities list would take a third roman page; the template does not limit it.
- **Not implemented.** Sealed material (Rule 35A), classified material (Rule 12), and a motion to file out of time are not part of this template.
- **Rule currency.** Checked against the Sept. 26, 2025 amended-through rules only (see Governing rules).

## Engines

**typst** (`typst/`, primary; the reference for the form) and **docx** (`docx/`). No LaTeX engine.

Both are on the shared cross-engine layout model (fb-595.54.7; `lib/typst/xengine.typ`, `lib/docx/xengine.lua` and the `base="xengine"` reference recipe in `tools/fb/src/docxxengine.rs`; docs/EVAL-LOOP.md, "Adopting the reference breaker"): Times New Roman 14 pt in both engines (Rule 37(a), footnotes included), body text in 25.9 pt line boxes (double-spaced), headings, cover, quotations, footnotes, index, authorities and certificates in 14.4 pt boxes; first-fit line breaking with no kerning, ligatures or hyphenation. The docx render breaks every line and page where the typst render does, and `eval.yaml` gates it (`params.cross_engine: gate`, XENG-001..003 PASS: 11 pages, every line alike). The re-render changed the typst layout from the earlier version of this README (pitches instead of leadings); the Gate 2 table above was written on that earlier render. All 11 pages of the new typst and docx PDFs were rendered at 60 dpi and looked at on 2026-10-22 (cover, index, authorities, body headings, block quotation, footnotes, signature, certificates): no tier 1 defect; the two engines are visually the same page for page.

- **typst** (`typst/armfor-petition-supplement.typ`): `show: xengine.with(pitch: pitch-double)`; index and authorities rows through `listing-row` (36 pt page column for the index, 56 pt or the page list's width for the authorities); every cover, signature and certificate line a block with its own space above.
- **docx** (`docx/`): `armfor.lua` (shared by both CAAF doc types; the doc type is the folder name) on the reference document `fb render` builds from `docx/reference.xml` (`base="xengine"`, the shared cross-engine recipe, in the typst face at 14 pt). Index and authorities page numbers come from `fb render`'s multi-pass engine (needles written to `$FORMBOOK_NEEDLES`, footers `rIdFtrNone` and `rIdFtrPage`, last section through `$FORMBOOK_FINAL`), so the former `docx/render.sh`, `build-reference.sh` and `make-reference.sh` are gone. The certificate counts the words of the markdown as the typst template does (1303, the same in both engines). A table row keeps at least three spaces before its leader with four-per-em spaces bound by word joiners rather than `xe.LEAD`'s no-break spaces (LibreOffice wraps a last word 4.6 pt early when the row ends in no-break spaces); a "502(c)(3)" token is bound by a word joiner, as typst boxes it. The counsel block on the cover is a table anchored to the foot of the text area.
- The `.docx` has not been opened in Microsoft Word (no Word here); LibreOffice opened it and rendered the PDF that is checked. Word may paginate differently.
