# U.S. Army Court of Criminal Appeals (acca): opening brief (brief on behalf of the appellant)

- Court: `acca`, U.S. Army Court of Criminal Appeals (`courts/military/army-court-of-criminal-appeals/`)
- Doc type: `opening-brief`. The appellant's brief (assignments of error and argument), ACCA Rule 17.1(a) and Appendix A ("Format for Brief on Behalf of Appellant").
- Exemplar: `usage/FILED-EXAMPLE-opening-brief.pdf`, an 11-page extract of *United States v. Akbar*, Army Dkt. 20050514, Brief on Behalf of Appellant, filed 1 February 2010 by the Defense Appellate Division (source, page map: `usage/SOURCE.md`). Found on the fourth search pass (2026-10-16, bead fb-595.20.20).
- Samples: `usage/INPUT-opening-brief.md` (transcription of the extract); `usage/INPUT-opening-brief-2.md` (FICTIONAL structural fixture, kept).
- Template: `typst/acca-opening-brief.typ` (entry `typst/main.typ`).
- Status (2026-10-16): rule text retrieved and applied (Times New Roman 14 pt via Liberation Serif, double-spaced, 1 in margins, Appendix A caption). Render ok (10 pages), overlay ok, every page reviewed. `tools/check.sh` not run (no `checks.yaml` here). `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...`, calls `acca-brief`. |
| `typst/acca-opening-brief.typ` | Template. Parameter block at the top: `brief-title`, `court-line`, `address-line`, `font-family`, `type-size`, `pitch-body`, `pitch-single`, the spaces between blocks, `page-margin`. |
| `usage/INPUT-opening-brief.md` | Transcription of the exemplar extract (brief pp. 1, 17-22, 481-483 and the certificate). |
| `usage/OUTPUT-opening-brief.typst.pdf` | `sh tools/render.sh courts/military/army-court-of-criminal-appeals/opening-brief usage/INPUT-opening-brief.md` (10 pages). |
| `usage/OVERLAY-opening-brief.pdf`, `.txt` | `sh tools/overlay.sh courts/military/army-court-of-criminal-appeals/opening-brief akbar-opening-brief`. |
| `usage/INPUT-opening-brief-2.md`, `OUTPUT-opening-brief-2.typst.pdf` | FICTIONAL fixture and its render (5 pages). No overlay (it is not a transcription). |
| `usage/SOURCE.md` | Exemplar record, page map, and every search pass. |

## Markdown contract

Frontmatter (YAML, first block of the file):

- `docket`: docket number as printed after "Docket No." (e.g. `ARMY 20050514`).
- `appellant`: `rank`, `name` (printed bold, as the filer writes it), `service`.
- `trial`: `place`, `dates`, `court-type` ("general", "special"), `convening`, optional `judge` (printed as ", <judge> presiding"). Appendix A: "Tried at [trial location], on [date(s)], before a [general/special] court-martial appointed by [convening authority], [military judge] presiding."
- `panel`: optional; printed at the foot of page 1 (Appendix A "Panel X").
- `signature`: lines of the signature block; an empty string `""` puts a gap between signers.
- `certificate`: `date`, `signature` lines, optional `method` (default "sent via electronic submission") and `recipient` (default "the Government Appellate Division"). Appendix A wording: "I certify that a copy of the foregoing was (mailed) (delivered) (sent via electronic submission) to ___ ... on ___."
- `appendix`: optional list of strings (Appendix A "Appendix"); empty list: no appendix page.
- `counsel`: accepted but not printed by the typst template (Appendix A has no counsel block on the caption); the docx filter does not print it either.

Body (Markdown): `#` section headings (Assignment(s) of Error, Statement of the Case, Statement of Facts, Argument), centered bold; `##` each assignment of error, bold, flush left (Appendix A: "capitalized and in bold type", numbered with Roman numerals); `###` centered bold sub-headings ("Assignment of Error I.", "Standard of Review"). The WHEREFORE prayer is body text.

## Governing rules

Source: U.S. Army Court of Criminal Appeals, *Rules of Appellate Procedure*, effective 15 January 2019, published together with the Joint Rules of Appellate Procedure. URL `https://www.jagcnet.army.mil/Home/assets/pdf/court/RulesofCourt.pdf` (the court's current posting; the live URL returns an access-denied page to this box, so the text was read from the Wayback capture `https://web.archive.org/web/20250729125903id_/https://www.jagcnet.army.mil/Home/assets/pdf/court/RulesofCourt.pdf`, 68 pp., OCR layer). Read and verified 2026-10-16.

| Rule | Requirement (quoted or close paraphrase) | Template |
|---|---|---|
| ACCA R. 13.2 | Electronic filing: a single PDF, "without scanning, if practical", "typed, and double-spaced", "Times New Roman 14-point", 8.5 x 11 in, "margins shall be set to 1-inch on all four sides". | `font-family = ("Times New Roman", "Liberation Serif")` (the pinned Times New Roman, Liberation Serif fallback, `docs/FONTS.md`), `type-size = 14pt` (body, headings and footnotes), `pitch-body = 32.8pt` (double-spaced; Word exact line spacing at the same pitch), `page-margin = 1in`, `us-letter`. |
| ACCA R. 17.1(a) | Pleadings raising or addressing an assignment of error follow Rule 13 and Appendix A. | Caption and order below. |
| ACCA R. 17.1(b) | Paper: body double-spaced, 14-point Times New Roman, 1-inch margins. | Same values. |
| ACCA R. 17.3(a)-(b) | Over 30 pages: table of contents and table of authorities; 50-page limit excluding tables and appendices. | Not generated or checked (Known gaps). |
| ACCA App. A | Caption: court line; left: "UNITED STATES, Appellee / v. / [Rank] [NAME] United States Army, Appellant"; right: "BRIEF ON BEHALF OF APPELLANT", "Docket No. ARMY ...", "Tried at ... presiding."; then "TO THE HONORABLE, THE JUDGES OF THE UNITED STATES ARMY COURT OF CRIMINAL APPEALS"; Assignment(s) of Error; Statement of the Case; Statement of Facts; Argument (standard of review and prayer for each error); Appendix; signature (name, rank, branch, title, organization); "Panel X" at the foot of page 1; Certificate of Service on its own page. | `caption`, footer of page 1, `closing`. |

Superseded: the earlier stand-ins (32 CFR 150.15 and App. B, AFCCA Rule 17.1, EB Garamond 12 pt) are no longer used.

## Overlay

`sh tools/overlay.sh courts/military/army-court-of-criminal-appeals/opening-brief akbar-opening-brief` exit 0. Page map (`usage/OVERLAY-opening-brief.txt`):

| Ours | Filed (extract) | Word overlap | Note |
|---|---|---|---|
| 1 | 3 | 8.8% | Mispaired: the filed caption page (extract p. 1) has no OCR text, so it cannot be matched by words. Compared by eye instead (below). |
| 2 | 2 | 75.4% | Part Four summary |
| 3 | 3 | 65.8% | |
| 4 | 4 | 46.5% | |
| 5 | 6 | 40.6% | |
| 6 | 7 | 38.5% | |
| 7 | 8 | 37.5% | Assignment LVII starts |
| 8 | 8 | 61.8% | Assignment LVIII |
| 9 | 10 | 34.3% | Signature blocks |
| 10 | 11 | 50.0% | Certificate of Service |

The filed brief is Courier 12 pt (pre-2019 rules); ours is Times-metric 14 pt per the current rule, so lines do not coincide. Margins, the double-spaced body grid, the caption columns and the page-number position line up.

## Page review (Gate 2), 2026-10-16

Every page of `OUTPUT-opening-brief.typst.pdf` (10) and `OVERLAY-opening-brief.pdf` (10) rasterized at 60 dpi and viewed; the filed extract's 11 pages viewed too. Fonts embedded: Liberation Serif Regular, Bold, Italic, BoldItalic only (the 2026-10-16 render; the committed render now embeds Times New Roman). Typst printed no warnings.

| Page | Content | Result |
|---|---|---|
| 1 | Caption (court line, two columns, title, docket, tried-at), "TO THE HONORABLE ...", Part One heading, intro, footnotes 1-2, "Panel No. 2" at the foot | OK against App. A and filed p. 1 (same column structure). ACCEPTED: the two adjacent footnote marks print as "12"; the filer wrote "1,2" (tier 3). ACCEPTED: the transcription stops mid-sentence where the extract stops, and the next headings move to p. 2, leaving space at the foot. |
| 2 | ASSIGNMENTS OF ERROR AND ARGUMENT, Part Four, Summary | OK |
| 3 | Summary end; Assignment of Error I heading and error text in bold capitals | OK |
| 4-6 | Argument with case citations (italic case names) | OK |
| 7 | WHEREFORE; Assignment LVII | OK |
| 8 | Assignment LVIII; closing prayers | OK |
| 9 | Signature blocks (five signers) | OPEN (tier 2): the signature block is kept whole, so it moves to its own page and leaves p. 8 short. The filer also put the signatures on their own page (483), so this matches the exemplar here, but a shorter brief would show a gap. |
| 10 | Certificate of Service | OK (App. A wording, own page). The filer's form with Assignment/Motion/Other boxes is a local form, not in App. A; not reproduced (tier 3). |

## Known gaps

1. TOC and table of authorities (R. 17.3(a), briefs over 30 pages) are not generated; the 50-page limit (R. 17.3(b)) is not checked.
2. The exemplar predates the 2019 rules (Courier, title page style of 2010). The 2019 Appendix A form decides the layout; no post-2019 ACCA brief was found.
3. Extract p. 1 of the exemplar has no text layer, so the overlay pairs ours p. 1 by eye only.
4. No `checks.yaml`: `tools/check.sh` runs the default checks with `eval.yaml` (2026-10-22: typst and docx 0 failed).
5. (Resolved 2026-10-22, fb-595.54.7: the docx engine now builds the R. 13.2 / App. A form; see "Engines".)

## History

- 2026-10-14 (unit acca-32.22) and 2026-10-15 (bead fb-595.20.4): no exemplar; template built from 32 CFR 150 with PROVISIONAL AFCCA values (EB Garamond 12 pt, cover page). Searches in `usage/SOURCE.md`.
- 2026-10-16 (bead fb-595.20.20): ACCA rules and the *Akbar* briefs found via the Internet Archive; template changed to R. 13.2 / 17.1 / App. A; *Akbar* sample, render and overlay added.

## Engines

Both engines on the shared cross-engine layout model (fb-595.54.7; `lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Adopting the reference breaker"): Times New Roman 14 pt everywhere (footnotes included), body lines in 32.8 pt boxes (double-spaced), caption, headings, block quotations, footnotes, signature and footer in 16 pt boxes, every space between blocks explicit and the same in both engines. The docx breaks every line and page where the typst render does, and `eval.yaml` gates it (`params.cross_engine: gate`, XENG-001..003 PASS on both samples).

- **typst** (`typst/`): the reference. The signature block now stays with the last paragraph (it no longer moves to a page of its own).
- **docx** (`docx/`): `reference.xml` (the Word styles; fb render builds the reference document from it) and `acca-brief.lua` (the Appendix A caption as a borderless two-column table, block quotations, signature block, appendix, Certificate of Service, and the section with its two footers: "Panel X" flush right on page 1, the page number centered after it, through `$FORMBOOK_FOOTERS` and `$FORMBOOK_FINAL`). A word joiner keeps tokens such as "922(B)(2)" whole, as typst does. The old EB Garamond 12 pt cover-page form (`build-reference.sh`, `reference.docx`) is retired. `tools/check.sh --engine docx`: 0 failed. Opened in LibreOffice (DEF-DOCX-OPEN); not opened in Word, which may paginate slightly differently.

## Refreshed exemplar run (2026-10-21)

The filed exhibit is a public ACCA-hosted filing recovered from the Internet Archive; its source URL, case, Army docket, filer, filed date, and retrieval date are recorded in `usage/SOURCE.md`. The transcription remains paired with `FILED-EXAMPLE-opening-brief.pdf` as `INPUT-opening-brief.md`. No template change was needed: Appendix A controls the caption and the exemplar predates those current rules.

Rendered with `sh tools/render.sh` and compared with `sh tools/overlay.sh`; both completed successfully. Rasterized every page of the render, filed exhibit, and overlay at 60 dpi and visually reviewed every page. The overlay is `.overlay/courts/military/army-court-of-criminal-appeals/opening-brief/OVERLAY-opening-brief.pdf` (generated, not committed). Render SHA-256: `f8220f78ac2edff373b4255e6d2726a1f6a2f50b58ed0b153a7ee452225a4257`.

| Render page | Filed page | Finding | Status |
|---:|---:|---|---|
| 1 | 1 (caption viewed directly; overlay text pairing is inaccurate because the filed caption has no OCR layer) | Caption and body start follow Appendix A; filed form is the earlier Courier form. | ACCEPTED |
| 2 | 2 | Assignment summary and body structure render cleanly. | PASS |
| 3 | 3 | Assignment heading is distinct and readable. | PASS |
| 4 | 4 | Argument text and citations render cleanly. | PASS |
| 5 | 6 | Argument text and citations render cleanly; current 14 pt rule changes pagination. | ACCEPTED |
| 6 | 7 | Argument text and citations render cleanly. | PASS |
| 7 | 8 | Argument and assignment heading render cleanly. | PASS |
| 8 | 8 | Closing prayer and assignment heading render cleanly. | PASS |
| 9 | 10 | Signature block is kept together and lands on its own page, matching this long exemplar. | ACCEPTED |
| 10 | 11 | Certificate of service is on its own page and legible. | PASS |

This is one filer and a pre-2019 filing; it supports only open-choice diagnostics. The remaining known issues are unchanged: no TOC/TOA or length-limit check, no `checks.yaml`, and the DOCX template is outside this pass.

## Cross-engine port and page review (2026-10-22, fb-595.54.7)

Renders after the port (typst 11 and 6 pages, docx the same): `OUTPUT-opening-brief.typst.pdf` SHA-256 `cbb62a03658f08e2a11a4abf38469de529463ddd73466c6720b7655b73034881`, `OUTPUT-opening-brief-2.typst.pdf` `0498382b36b467d04892cffb8dc5e18b1aa82a9686e5841fd1e5f8f51edb06a3`. Every page of both typst renders and both docx PDFs rasterized (50 dpi) and viewed side by side; `fb diff --engines`: 207/207 and 97/97 lines with the same break, every page alike. Fonts embedded: Times New Roman Regular, Bold, Italic, BoldItalic (both engines).

| Page (sample 1) | Content | Result |
|---|---|---|
| 1 | Caption, "TO THE HONORABLE ...", Part One, footnotes 1-2, "Panel No. 2" | PASS (typst and docx alike) |
| 2-8 | Part Four, Summary, Assignments of Error I and LVII, argument with italic case names | PASS. ACCEPTED: p. 3 and p. 8 end short where a heading is kept with its text. |
| 9 | Assignment LVIII, WHEREFORE | PASS |
| 10 | Last WHEREFORE with the signature block (five signers) | PASS: the signature block stays with the last paragraph. |
| 11 | Certificate of Service | PASS |

Sample 2 (FICTIONAL, 6 pages): caption, block quotation (Q./A.) single-spaced and indented, footnote, headings, signature with the WHEREFORE paragraph on p. 5 (p. 4 ends short: ACCEPTED, the block is kept whole), certificate on p. 6: PASS in both engines. The docx footnote separator is LibreOffice's own (slightly heavier than typst's 0.5 pt rule): ACCEPTED, tier 3.
