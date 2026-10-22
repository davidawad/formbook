# uscgcoca: opening brief (Appellant's Assignments of Error and Brief)

- Court: U.S. Coast Guard Court of Criminal Appeals (CGCCA), `courts/military/coast-guard-court-of-criminal-appeals/`.
- Doc type: the appellant's brief, which the CGCCA lists as "Appellant's Assignments of Error" (Rule 18(a); Rule 17.2(a) "Assignment of Error Briefs").
- Exemplar: `usage/FILED-EXAMPLE-opening-brief.pdf`, an 8-page extract of *United States v. Steen*, Dkt. 1464, Appellant's Assignment of Error and Brief, dated 4 April 2019, published by the court (source and page map: `usage/SOURCE.md`). Found on the fourth pass (2026-10-16, bead fb-595.20.21) via the Internet Archive.
- Samples: `usage/INPUT-opening-brief.md` (transcription of the extract); `usage/INPUT-opening-brief-2.md` (placeholder, kept).
- Template: `typst/uscgcoca-opening-brief.typ` (entry `typst/main.typ`).
- Status (2026-10-22, bead fb-595.54.7): typst and docx on the shared cross-engine layout model and gated (`eval.yaml`: `params.cross_engine: gate`); `tools/check.sh` 16 passed 0 failed (typst) and 24 passed 0 failed (docx, XENG-001..003 PASS on both samples). `court.json` untouched.

## Governing rules

Source: *United States Coast Guard Rules of Appellate Procedure*, Rev. 03/25, published with the Joint Rules of Appellate Procedure (eff. 27 May 2024), approved by Chief Judge L. I. McClelland 26 March 2025. URL `https://www.uscg.mil/Portals/0/Headquarters/Legal/cca/CGCCA%20Rules%20of%20Appellate%20Procedure%20with%20JRAP%20(March%202025).pdf`; uscg.mil returns 403 here, so read from the Wayback capture `https://web.archive.org/web/20250428115614id_/<that URL>` on 2026-10-16. Cross-checked against the 1 January 2019 edition (capture 20191130041821), which the exemplar was filed under.

| Rule | Requirement (quoted or close paraphrase) | Template |
|---|---|---|
| R. 17.1 | "All pleadings shall appear in proportional type such as Times New Roman, at least 12-point, typed and with at least 15-point spacing so as to produce a clear black image on a single side of white 8.5-inch by 11-inch paper. Margins must be at least one inch on all four sides." (2019 edition: "12-point, typed and double-spaced".) | `typeface = ("Times New Roman", "Liberation Serif")` (the pinned Times New Roman, embedded), `body-size = 12pt` everywhere (body, headings, footnotes), body pitch 28 pt (`pitch-body`, double spacing, as filed), single-spaced caption, headings, quotations, footnotes and signature at 15 pt (`pitch-single`, the "at least 15-point spacing" floor), `margin = 1in`, `us-letter`. |
| R. 17.2(a) | Minimum content: (1) Statement of the Case with jurisdiction; (2) Assignments of Error or Issues Presented; (3) Statement of Facts; (4) Argument with standard of review, contentions, reasons, authority and relief sought for each error; (5) Certificate of Service. | Body sections come from the markdown; the template adds the Certificate of Service. |
| R. 17.2(b) | No victim/witness names, SSNs, addresses, etc. unless filed under seal. | Author's duty (the sample keeps the court's redactions). |
| R. 17.3 | Over 30 pages: tables of contents and authorities and a summary of argument. Briefs and answers at most 20,000 words (headings, footnotes, quotations count; index, tables, certificates do not). "All briefs, answers, and replies shall include a certificate stating that the number of words complies." | Certificate of Compliance printed before the Certificate of Service, with a word count computed from the markdown body (markup and footnote labels stripped) or `word_count` from the frontmatter. TOC/TOA not generated (Known gaps). |
| R. 14 | Signed; at a minimum the signer's name, military grade (if any), email address, and capacity. | `signature` (one signer, or a list printed side by side). |
| R. 13.1(e) | Filing by email in PDF, "preferably converted, not scanned". | Typst PDF. |

The rules prescribe no caption form. The caption follows the filed exemplars (both Steen filings): court line; two columns, parties on the left (UNITED STATES, Appellee / v. / name, rate, service, Appellant), on the right date, title, docket lines and "Tried at ..."; a rule; then "TO THE HONORABLE, THE JUDGES OF THE UNITED STATES COAST GUARD COURT OF CRIMINAL APPEALS".

## Markdown contract

Frontmatter: `case_number`; optional `docket_label` (default "Docket No."; the appellant wrote "Dkt."); optional `case_lines` (further lines under the docket, e.g. "Case No. SP 24978", "Before ..." panel); `date` (caption and certificate date); `caption` (list of `{names: [...], designation}`, printed in order with "v." between); `brief_title`; `proceeding` ("Tried at ..."); `signature` (`{signer, lines}` or a list of them); optional `certificate` (`method`, default "delivered"; `recipient`, default "the Court and opposing counsel"; `signer`); optional `word_count`. `counsel` is accepted but not printed by typst (the exemplars carry counsel only in the signature).

Body: `#` centered bold section headings; `##` bold flush-left error/issue headings and lettered sub-headings; `###` centered bold sub-headings (Roman numerals, "Standard of review", "Analysis").

## Overlay

`sh tools/overlay.sh courts/military/coast-guard-court-of-criminal-appeals/opening-brief opening-brief` exit 0 (2026-10-22, re-run on the cross-engine render); overlay at `.overlay/courts/military/coast-guard-court-of-criminal-appeals/opening-brief/OVERLAY-opening-brief.pdf` (gitignored; all 9 pages viewed as 50 dpi thumbnails):

| Ours | Filed (extract) | Overlap | Note |
|---|---|---|---|
| 1 | 1 | 97.9% | Caption and Statement of the Case |
| 2 | 2 | 76.2% | |
| 3 | 3 | 83.4% | |
| 4 | 4 | 74.5% | Summary of Argument |
| 5 | 5 | 65.4% | Issues Presented and Argument I start on one page in ours (filed: pp. 11 and 12) |
| 6 | 7 | 44.0% | |
| 7 | 8 | 56.6% | Conclusion |
| 8 | 8 | 13.4% | The last two lines of the Conclusion |
| 9 | 1 | 4.2% | Our Certificates of Compliance and Service: the published copy has no certificate page (no counterpart; the low score is noise). |

The text block, margins and body pitch coincide closely with the filing (Times New Roman 12 pt, double-spaced). Since the cross-engine port the space under a heading is the body line's own box (the model sets every line in a box of its pitch), so ours runs one page longer than before (9, was 8).

## Page review (Gate 2), 2026-10-22

All 9 pages of `OUTPUT-opening-brief.typst.pdf` and of `OUTPUT-opening-brief.docx.pdf`, and all 3 of each render of `INPUT-opening-brief-2.md`, rasterized at 60 dpi and viewed side by side. Typst SHA-256: `a763bb83f71d27997faec7f967afece0f21b58dac37f72a19e6b13c58b64e736` (opening-brief), `5a84634068b8f470879f1a9b82244f6ca2815b1b9f8e52c85d002679a4122b4a` (opening-brief-2). Fonts: Times New Roman Regular, Bold, Italic, BoldItalic (both engines); no typst warnings.

| Page | Result |
|---|---|
| 1 | OK. Caption columns, date, title, docket lines, tried-at, rule, address line, Statement of the Case. ACCEPTED (tier 3): the filer broke the court line over two lines and set the title in plain capitals; ours is one bold line and a bold title. |
| 2-3 | OK. Lettered fact headings bold flush left; the block quotation is single-spaced and indented both sides, as filed. |
| 4 | OK. Summary of Argument. |
| 5 | OK. Issues Presented in bold capitals. ACCEPTED (tier 3): the filer indented the issue text as a narrower centered block; ours is full width. Argument I follows on the same page (the filer started it on a new page). |
| 6 | OK. The numbered quotation: the number in a half-inch box inside the quotation's indent, the text hanging. |
| 7 | OK. |
| 8 | ACCEPTED (open choice): the last two lines of the Conclusion run onto the page (two lines, not a widow; the rules do not prescribe pagination). |
| 9 | OK. Certificate of Compliance (R. 17.3) and Certificate of Service; the certifier line is blank because the published copy omits the signature page (the sample has no `signature`). |
| -2: 1-3 | OK. Caption, headings, the last paragraph kept with the signature on p. 2, certificates on p. 3. |

The docx renders show the same pages line for line (XENG-001..003 PASS).

## Known gaps

1. TOC, table of authorities and summary of argument for briefs over 30 pages (R. 17.3) are not generated or checked; the 20,000-word limit is printed, not enforced.
2. The word count is computed from the markdown and is approximate (footnote labels and markup removed); give `word_count` to certify an exact figure. Both engines count the same way.
3. The exemplar was filed under the 2019 edition, which had no word-count certificate; the template adds it because R. 17.3 (2025) requires it.

## Engines

**Cross-engine layout model (fb-595.54.7).** The typst template imports `lib/typst/xengine.typ` and the docx filter `docx/uscgcoca.lua` uses `lib/docx/xengine.lua`, so the LibreOffice PDF of the `.docx` breaks every line and page where the typst render does; `eval.yaml` sets `params.cross_engine: gate`. One face, Times New Roman 12 pt (the pinned face, embedded by both engines). Every line is a box of its pitch: 28 pt body (560 twips), 15 pt single-spaced caption, headings, quotations, footnotes and signature (300 twips); the spaces between blocks are the same numbers in both (`sp-*` in the typst file, `SP_*` in the filter). The caption and a list of signers are two columns (a typst grid; a Word table with a gutter column), the rules empty 10 pt paragraphs with a bottom border. The typst footnote area is 8 pt over the separator and 7 pt under it, the 15 pt LibreOffice gives a Word footnote separator. Lists are the template's own rows (a loose list item holds paragraph breaks, which `xengine`'s list paragraph cannot). The Word styles are `docx/reference.xml` (built by `fb render`; the old `build-reference.sh` and its EB Garamond `reference.docx` are retired).

**docx** (`docx/`): `tools/check.sh --engine docx` 24 passed, 0 failed (XENG-001..003 PASS on both samples).

## History

- 2026-10-14 and 2026-10-15: BLOCKED (uscg.mil 403; no exemplar; rules unread); skeleton template with UNVERIFIED values (EB Garamond).
- 2026-10-16 (bead fb-595.20.21): briefs index, Steen filings and the rules recovered from the Internet Archive; template moved to R. 17.1-17.3 and R. 14; Steen sample, render and overlay added; smoke sample re-rendered (2 pages, viewed).
- 2026-10-22 (bead fb-595.54.7): typst and docx ported onto the shared cross-engine layout model (Times New Roman, 28/15 pt pitches); docx rewritten from the typst template; gated.
