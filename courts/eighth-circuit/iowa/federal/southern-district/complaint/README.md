# iasd: complaint

Doc type: **complaint** (complaint and jury demand) in the United States District Court for the Southern District of Iowa (`iasd`), Central Division.
Folder: `courts/eighth-circuit/iowa/federal/southern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: a transcription of the filing (caption, paragraphs 1 to 61, Division I, relief, jury demand, signature). Monell (Division II) and Division III are not transcribed. |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only (embedded), no warnings |
| overlay | ok: `usage/OVERLAY-white-complaint.pdf` and `OVERLAY-white-complaint.txt` (page map) |
| typeface | face required by the court: **none** (LR 10(b) has no typeface or point-size rule; checked 2026-10-14 in the PDF text, see Governing rules). Vendored substitute: none needed; **EB Garamond kept** (`docs/FONTS.md`: a court that names no face gets EB Garamond). Metric compatibility: n/a. Tier 2 question on the exemplar's Times New Roman, Known gaps 2. |
| pages reviewed | 11 of 11, on the final PDF (sha256 `f94d58a6...`, see the review table below) |
| `tools/check.sh` | not run: the check gates expect a court folder with `court.json` and `rules.md`, which a doc-type folder is not (see Known gaps) |

## Governing rules

Primary source: **Local Rules of the United States District Courts for the Northern and Southern Districts of Iowa, effective December 7, 2020** (N.D. Administrative Order 20-AO000-13-P; S.D. Administrative Order 20-AO-23-P). Full PDF: https://www.iasd.uscourts.gov/sites/iasd/files/Local%20Rules%20-%20Final%2012142020.pdf (linked from https://www.iasd.uscourts.gov/local-rules). Read and quoted on 2026-10-14 from a text extract of that PDF. The court's site itself refused direct requests from this box, so the copy was taken through the WebFetch tool, which saved the full PDF (106 pages).

A proposed 2026 red-line of the joint rules is also on the court's site (`Proposed Joint Local Rules - Red Line.pdf`). It is marked proposed, it could not be read here (the saved copy did not extract as text), and it is not used.

Fed. R. Civ. P. text is cited by number. Those rules were **not fetched in this pass**; the Local Rules cross-refer to Rule 10(a) (LR 10(d)) and Rule 5.2 (LR 10(g)), and nothing here relies on wording beyond that.

| ID | Rule | Kind | Requirement | Where it lives |
|---|---|---|---|---|
| IASD-FORM-001 | LR 10(a) | M | 8½ × 11 inch paper; electronic filings formatted the same way. | `typst/iasd-complaint.typ`, `page` setup (`us-letter`) |
| IASD-FORM-002 | LR 10(b)(1) | M | Double spaced. | `body-leading` (24 pt baseline pitch at 12 pt, measured) |
| IASD-FORM-003 | LR 10(b)(2) | M | Printed on one side of the page. | Output is a single-sided PDF page sequence. |
| IASD-FORM-004 | LR 10(b)(3) | M | Top margin of at least 1 inch on each page. | `margin-top = 1in` |
| IASD-FORM-005 | LR 10(b) (last sentence) | M | A document of more than one page is numbered at the bottom of each page. | `numbering: "1"`, `number-align: center + bottom` |
| IASD-CAP-001 | LR 10(d) | M | Caption shows the district and division, the case number, the party names as Fed. R. Civ. P. 10(a) requires, a designation of the content, and the party filing. | `court-title()`, `caption()`; frontmatter `division`, `case_number`, `caption`, `title` |
| IASD-SIG-001 | LR 11 | M | Under the signature: name, law firm, mailing address, telephone number, email address; lead counsel identified if more than one lawyer. | `signature-block()`; frontmatter `signature.lines` (sample lists the name, firm, address, telephone, email under the `/s/`) |
| IASD-FRCP-010 | Fed. R. Civ. P. 10(b) | M | Claims stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `body-blocks()` numbers each paragraph; headings, lists and the relief are not numbered; the relief section and the jury demand are not numbered (`unnumbered-after`). |
| IASD-FRCP-038 | Fed. R. Civ. P. 38(b) | T | Jury demand (court practice: "Complaint and Jury Demand" caption and a demand paragraph). | frontmatter `title`; the demand is the last heading in the sample. |
| IASD-TIER2-001 | none in the Local Rules (LR 10(b) checked 2026-10-14) | C | Typeface and size. The Local Rules give none. The exemplar is Times New Roman 12 pt. | `font-family = "EB Garamond"`, `type-size = 12pt` (see Known gaps 2). |
| IASD-TIER2-002 | none | C | Side margins 1 inch; paragraph first-line indent 0.5 inch; headings centered bold capitals (level 1), centered bold (level 2). | `margin-left`, `para-indent`, `heading-block()` |
| IASD-TIER2-003 | LR 7.1(a) | M (for the plaintiff, separate filing) | Plaintiff's disclosure statement within 21 days after the complaint is filed. Not part of this document. | Not in the template (separate filing). |

Not produced by this template (separate filings): the civil cover sheet (JS-44), the Rule 7.1 disclosure statement (LR 7.1(a)), the summons (LR 5A(g)(2): the Clerk issues it). These may be required with the first filing.

## Layout

- Court title on the first page: the district, then the division (LR 10(d)), three centered bold lines.
- Caption: party column (left, with a right and bottom rule), the case number and title (right). No counsel block at the top of page 1: the Local Rules put counsel's identification under the signature (LR 11), and the exemplar follows that.
- Body: double spaced; numbered paragraphs from the template; lettered list items for the damages and the relief; one-line headings.
- Signature block: indented to the caption's party column, single spaced, then the optional filing note (`Original filed via CM/ECF.`, as in the exemplar).
- Page numbers at the bottom centre, arabic from 1 on page 1 (the exemplar does the same).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `division`, `caption` (`parties`: list of `{names, designation}`; `versus`), `case_number`, `title`, `lead_in` (unnumbered first paragraph, optional), `filing_note` (optional), `signature.lines` (list; `""` for a blank line).
- Body: blank-line-separated chunks. `#` = level 1 heading (centered bold capitals); `##` = level 2 (centered bold); `###` = level 3 (bold, at the margin). A list starting `1. ` is lettered `(a)`, `(b)`, … by the template. A paragraph is numbered by the template; a paragraph after a `# Requested Relief` or `# Jury Demand` heading is not.
- The sample must not put the numbering in the text: the template numbers the paragraphs. A `>` block quotation is single spaced and indented.
- Not supported: tables, footnotes, raw typst. Section and paragraph signs are kept on the line of their number (no-break space).

## The overlay

`usage/OVERLAY-white-complaint.pdf`: red = our render, blue = the filed exemplar, black = both agree. The filed PDF is not stored in `usage/` in this snapshot (only `SOURCE.md`), so the overlay was built against a copy fetched from the URL in `usage/SOURCE.md` on 2026-10-14 (21 pages, sha256 `9947bbaf04afececbeafacef9ef1f0e5b7355dddefaf9224cbf530e52e491585`). Pages are paired by word overlap (`OVERLAY-white-complaint.txt`):

| ours | filed | overlap |
|---|---|---|
| 1 | 1 | 81.9% |
| 2 | 2 | 82.0% |
| 3 | 4 | 51.1% |
| 4 | 5 | 76.5% |
| 5 | 7 | 57.8% |
| 6 | 8 | 82.2% |
| 7 | 9 | 80.5% |
| 8 | 11 | 49.5% |
| 9 | 12 | 79.8% |
| 10 | 13 | 42.5% |
| 11 | 21 | 56.4% |

What the overlay shows, which is expected: the caption lines and the body text lie on the same positions (the blue and red text coincide in the caption block and the first page's paragraphs); the exemplar's ECF header line (`Case 4:26-cv-00430-RGE-HCA Document 1 Filed 09/28/26 Page 1 of 21`) is blue only, because that header is added by the court's ECF system, not by the filer's document. The paragraph numbers differ on purpose (see Known gaps 4). The overlay is a diagnostic, not a score.

## Gate 2 review (every page of the final PDF, rendered at 60 dpi and looked at)

sha256 of the reviewed PDF: `f94d58a6976b5961a74ba4f57e5f32820cce4a4fec20e7e114438884e6f76f17`. Re-rendered 2026-10-14 for the fonts pass (no font change: the template keeps EB Garamond); all 11 pages were rendered at 60 dpi and looked at again on this PDF, and the layout matches the rows below. The earlier PDF's hash (`58114f5a…`) is not reproducible because typst stamps a creation date into each render.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court title on lines 1–3, caption, title at right, `Case No.` at top right, lead-in, paragraphs 1–3. The `§` now stays with its number (`28 U.S.C. § 1331` on one line, previously split). | FIXED (no-break space after `§`) |
| 2 | exemplar p.2 | Paragraphs 4–13; `PARTIES` heading centered bold. | PASS |
| 3 | exemplar p.3 | Paragraphs 14–23; `FACTUAL ALLEGATIONS` and sub-heading `The Response and Initial Encounter` centered bold. | PASS |
| 4 | exemplar p.4 | Paragraphs 24–35; `White's Surrender` sub-heading. | PASS |
| 5 | exemplar p.5 | Paragraphs 36–47; `The Force Applied After Surrender` sub-heading. | PASS |
| 6 | exemplar p.6 | Paragraphs 48–55; `DAMAGES COMMON TO ALL COUNTS`; lettered list (a)–(f). The list items wrapped with a gap after the first line in the first build; they are now single paragraphs and the wrap is flush at the margin. | FIXED (list layout); wrapped list lines flush left, tier 2 |
| 7 | exemplar p.7 | `LAW COMMON TO ALL COUNTS`, paragraphs 56–62; italic case names; `See` signals italic. | PASS |
| 8 | exemplar p.8 | Paragraphs 63–68; `DIVISION I` and its two-line heading centered; sub-heading `Defendants Andersen, Oswald, and Purcell` at the margin. | PASS |
| 9 | exemplar p.9 | Paragraphs 69–75. | PASS |
| 10 | exemplar p.10 | Paragraphs 76–78; `REQUESTED RELIEF`, WHEREFORE paragraph (unnumbered), lettered relief (a)–(f); `JURY DEMAND` heading and unnumbered demand. | FIXED (list layout, as p.6); PASS after the fix |
| 11 | exemplar p.21 | Signature block at the top of page 11 with `Original filed via CM/ECF.`; the page holds only the signature. | ACCEPTED: the signature block falls on its own page because the demand ends page 10. The exemplar also ends on a signature-only page. Tier 2 choice. |

Every page is recorded above; none is `OPEN`.

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP tier 2 asks for two or three filers. The search (CourtListener RECAP, `type=r`, `court=iasd`, complaints filed in the 2026-09-28 to 2026-10-09 window) found one usable S.D. Iowa complaint with a text layer: this one. Serenity Therapy LLC v. UnitedHealth Group (4:26-cv-00219, 134 pp.) has a RECAP PDF but is too long for a reference. Tier 2 is therefore **not judged against two filers** for this doc type.
2. **Typeface.** The Local Rules give no typeface or size rule. Checked again on 2026-10-14 against the text layer of the Local Rules PDF (LR 10(b) lists double spacing, one side, top margin, numbering; nothing on face or point size). So `docs/FONTS.md` rule 3 does not apply (no court face to substitute) and EB Garamond stays. The exemplar is Times New Roman 12 pt. The only serif in `fonts/` is EB Garamond, which sets smaller than Times at the same size; the text is 12 pt as the exemplar's. A Times-metric font would need a shared change to `fonts/` (not done here). **Question for David:** is EB Garamond acceptable, or should a Times-metric font be vendored?
3. **Line numbering.** Not required by the S.D. Iowa rules (the exemplar has none), so none is drawn. The N.D. Cal. template has pleading-paper numbering; this one does not.
4. **Paragraph numbers differ from the filed numbers.** The sample numbers its paragraphs from 1 (the template numbers them). Division I is paragraphs 65–78 in our render and 62–75 in the exemplar, because the Monell section (Division II, ¶¶ 76–90 in the filing) and Division III are not transcribed and the numbering runs on from the sample's text. A complete filing would number itself by the template and the filed numbers would not appear.
5. **Excerpt.** The sample transcribes the filing's paragraphs 1–61 (the jurisdiction, the parties, the facts, the damages, the law common to all counts), Division I, the relief and the jury demand, and the signature. Division II (Monell, ¶¶ 76–90) and Division III (assault and battery, ¶¶ 91–102) are not transcribed. The render is 11 pages, which is inside the 8–14 page target.
6. **Caption borders.** The party column is closed by a right and bottom rule. The exemplar's party column is not drawn with a rule in the text layer, so this is a tier 2 choice. ACCEPTED on this basis; not checked against a second filer.
7. **No certificate of service.** A complaint is served with the summons (Fed. R. Civ. P. 4), so none is generated. If a later filing is served on a non-registrant, LR 5(a) requires a certificate showing the time and manner of service and one of the three forms listed there (acknowledgment, certification by a member of the bar, or a declaration under 28 U.S.C. § 1746). That is for the motion-brief doc type and any other paper, not this template.
8. **Counsel block.** Not at the top of page 1 (as in the exemplar; the Local Rules put it under the signature). A template that needs counsel at the top would be a change; not made.
9. **Tool checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`. This doc-type folder is not that shape, and `tools/` is shared, so the gates were not run. Render, overlay and the page review above are the Gate 2 record for this doc type.
10. **Overlay file names.** `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf` and `.txt` (its default names). The overlay is therefore `OVERLAY-white-complaint.pdf`, not `white-complaint-overlay.pdf`; the tool is shared and was not changed.

## Engines

Doc type `complaint`, in this folder. The typst template above is the primary engine and is unchanged.

| Engine | State |
|---|---|
| typst | `typst/`, as above. |
| latex | not built in this change (`latex/` has no template for this doc type). |
| docx | `docx/reference.docx` (built by `docx/make-reference.sh`) and `docx/iasd-complaint.lua`. `usage/OUTPUT-complaint.docx` is written by `tools/render.sh --engine docx`. The `.docx.pdf` is **not produced**: LibreOffice cannot be installed on the box that built this (not on conda-forge, no root), so the LibreOffice-based checks are BLOCKED. Pages reviewed as rendered PDF: 0. |

**docx: what the template sets, from the same parameters as the typst form.** Letter paper, 1-inch margins; EB Garamond 12 pt, the body at 24 pt exact line spacing (double) with a half-inch first-line indent; headings level 1 centered bold capitals, level 2 centered bold, level 3 bold at the margin; the caption as a borderless table with a right and bottom rule on the party column (3.25 in, as typst); the court title and the case number and title as in the typst cover; numbered paragraphs (1., 2., ...) typed by the filter, unnumbered after "Requested Relief" and "Jury Demand"; lettered relief (a), (b), ... with the text at the next tab stop; the signature block at 3.45 in; the filing note at the margin; footer page number centered, arabic from 1. The `.docx` passes the zip and XML checks in `tools/render-docx.sh` and reads back in pandoc with the same text. It has **not** been opened in Word or LibreOffice, so "no repair prompt" is unverified.

**docx: what differs, or is not verified.**
- Pagination and line breaks are **not verified** (no renderer). Word may break lines and paginate differently from the typst PDF. The page-by-page comparison with the typst OUTPUT is not done for docx.
- Numbering uses a tab, not the typst gap of 0.25 in: the text starts at the next default tab stop (1.0 in), so a number and its text sit slightly differently from typst.
- Lettered relief items wrap flush at the margin, as in typst (tier 2).
- Fonts: the docx names EB Garamond; it must be installed on the machine that opens the file, or Word substitutes silently (`docs/DOCX.md`).
- No pleading-paper numbering and no certificate, as in typst.

**docx: BLOCKED** (`docs/DOCX.md`, "Checking a docx"):
- `tools/check.sh --engine docx` (Gates 0 to 3 on `usage/OUTPUT-white-complaint.docx.pdf`): BLOCKED, because the `.docx.pdf` cannot be made here (no LibreOffice). No `.check-docx.txt` stamp is written.
- The page review of the `.docx` in LibreOffice and Word (`docs/DOCX.md`, step 3): BLOCKED for the same reason; no page was looked at.
