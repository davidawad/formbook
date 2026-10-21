# uscgcoca: opening brief (Appellant's Assignments of Error and Brief)

- Court: U.S. Coast Guard Court of Criminal Appeals (CGCCA), `courts/military/coast-guard-court-of-criminal-appeals/`.
- Doc type: the appellant's brief, which the CGCCA lists as "Appellant's Assignments of Error" (Rule 18(a); Rule 17.2(a) "Assignment of Error Briefs").
- Exemplar: `usage/FILED-EXAMPLE-opening-brief.pdf`, an 8-page extract of *United States v. Steen*, Dkt. 1464, Appellant's Assignment of Error and Brief, dated 4 April 2019, published by the court (source and page map: `usage/SOURCE.md`). Found on the fourth pass (2026-10-16, bead fb-595.20.21) via the Internet Archive.
- Samples: `usage/INPUT-opening-brief.md` (transcription of the extract); `usage/INPUT-opening-brief-2.md` (placeholder, kept).
- Template: `typst/uscgcoca-opening-brief.typ` (entry `typst/main.typ`).
- Status (2026-10-21): rule text read and applied; render ok (8 pages); overlay ok; all 8 output pages and all 8 overlay pages rasterized at 60 dpi and reviewed. Rendered with Typst 0.15.1; no warnings. No `checks.yaml`, so `tools/check.sh` was not run and no stamp is claimed. `court.json` untouched.

## Governing rules

Source: *United States Coast Guard Rules of Appellate Procedure*, Rev. 03/25, published with the Joint Rules of Appellate Procedure (eff. 27 May 2024), approved by Chief Judge L. I. McClelland 26 March 2025. URL `https://www.uscg.mil/Portals/0/Headquarters/Legal/cca/CGCCA%20Rules%20of%20Appellate%20Procedure%20with%20JRAP%20(March%202025).pdf`; uscg.mil returns 403 here, so read from the Wayback capture `https://web.archive.org/web/20250428115614id_/<that URL>` on 2026-10-16. Cross-checked against the 1 January 2019 edition (capture 20191130041821), which the exemplar was filed under.

| Rule | Requirement (quoted or close paraphrase) | Template |
|---|---|---|
| R. 17.1 | "All pleadings shall appear in proportional type such as Times New Roman, at least 12-point, typed and with at least 15-point spacing so as to produce a clear black image on a single side of white 8.5-inch by 11-inch paper. Margins must be at least one inch on all four sides." (2019 edition: "12-point, typed and double-spaced".) | `typeface = "Liberation Serif"` (Times New Roman substitute, `docs/FONTS.md`), `body-size = 12pt` everywhere (body, headings, footnotes), body baseline pitch 27.6 pt (double spacing, as filed; satisfies "at least 15-point"), single-spaced caption/quotes/footnotes, `margin = 1in`, `us-letter`. |
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

`sh tools/overlay.sh courts/military/coast-guard-court-of-criminal-appeals/opening-brief opening-brief` exit 0; overlay at `.overlay/courts/military/coast-guard-court-of-criminal-appeals/opening-brief/OVERLAY-opening-brief.pdf` (gitignored):

| Ours | Filed (extract) | Overlap | Note |
|---|---|---|---|
| 1 | 1 | 97.9% | Caption and Statement of the Case |
| 2 | 2 | 73.1% | |
| 3 | 3 | 77.7% | |
| 4 | 4 | 64.3% | Summary of Argument |
| 5 | 6 | 72.0% | Issues Presented and Argument I start on one page in ours (filed: pp. 11 and 12) |
| 6 | 7 | 59.8% | |
| 7 | 8 | 74.6% | Conclusion |
| 8 | 1 | 4.2% | Our Certificates of Compliance and Service: the published copy has no certificate page (no counterpart; the low score is noise). |

The text block, margins and line pitch coincide closely: the filer used Times New Roman 12 pt double-spaced, which Liberation Serif matches metrically.

## Page review (Gate 2), 2026-10-21

All 8 pages of `OUTPUT-opening-brief.typst.pdf` and all 8 of `.overlay/.../OVERLAY-opening-brief.pdf` rasterized at 60 dpi and viewed. Output SHA-256: `e910fdf3f9b57e96158db7500cde23dad055b26601bd15d057dc6fc08f957354`. Fonts: Liberation Serif Regular, Bold, Italic, BoldItalic only; no typst warnings.

| Page | Result |
|---|---|
| 1 | OK. Caption columns, date, title, docket lines, tried-at, rule, address line, Statement of the Case. ACCEPTED (tier 3): the filer broke the court line over two lines and set the title in plain capitals; ours is one bold line and a bold title. |
| 2-3 | OK. Lettered fact headings bold flush left; the block quotation is single-spaced and indented both sides, as filed. |
| 4 | OK. Summary of Argument. |
| 5 | OK. Issues Presented in bold capitals. ACCEPTED (tier 3): the filer indented the issue text as a narrower centered block; ours is full width. Argument I follows on the same page (the filer started it on a new page). |
| 6 | OK. Numbered quotation renders as an indented single-spaced list. |
| 7 | OK. Conclusion. |
| 8 | OK. Certificate of Compliance (R. 17.3) and Certificate of Service; the certifier line is blank because the published copy omits the signature page (the sample has no `signature`). |

## Known gaps

1. TOC, table of authorities and summary of argument for briefs over 30 pages (R. 17.3) are not generated or checked; the 20,000-word limit is printed, not enforced.
2. The word count is computed from the markdown and is approximate (footnote labels and markup removed); give `word_count` to certify an exact figure.
3. The exemplar was filed under the 2019 edition, which had no word-count certificate; the template adds it because R. 17.3 (2025) requires it.
4. The docx engine (`docx/`) was not changed in this pass (bead scope); it still builds the earlier EB Garamond form, and `usage/OUTPUT-opening-brief-2.docx*` come from it.
5. No `checks.yaml`; `tools/check.sh` not run.

## Engines

**docx** (`docx/`): unchanged since the earlier pass (EB Garamond 12 pt, caption from the earlier skeleton); now out of step with the typst form (Known gaps 4). BLOCKED: `tools/check.sh --engine docx` cannot run on this doc-type folder (no `checks.yaml`).

## History

- 2026-10-14 and 2026-10-15: BLOCKED (uscg.mil 403; no exemplar; rules unread); skeleton template with UNVERIFIED values (EB Garamond).
- 2026-10-16 (bead fb-595.20.21): briefs index, Steen filings and the rules recovered from the Internet Archive; template moved to R. 17.1-17.3 and R. 14; Steen sample, render and overlay added; smoke sample re-rendered (2 pages, viewed).
