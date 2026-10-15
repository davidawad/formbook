# Tax Court: pretrial memorandum (Rule 131(b), Standing Pretrial Order)

**Exemplar: 1 of 2 filers.** One real filed pretrial memorandum is in `exemplars/`: the respondent's, *Duffy v. Commissioner*, Tax Court Docket No. 8711-16 (Trial Calendar Portland, Oregon, December 10, 2018; OCR text layer added). Source and search history: [exemplars/SOURCE.md](exemplars/SOURCE.md). Tier 2 is judged against this one filer only, which `docs/EVAL-LOOP.md` says cannot finish tier 2; a petitioner-side memorandum from a different filer is still needed.

| Check | Result |
|---|---|
| Exemplar | yes: `exemplars/FILED-EXAMPLE-duffy-8711-16-pretrial-memorandum.pdf` (1 filer, respondent) |
| Render (`tools/render.sh`) | ok: `samples/OUTPUT-duffy-8711-16-pretrial-memorandum.pdf`, 7 pages, EB Garamond only, no typst warnings. `samples/OUTPUT-generic-pretrial-memorandum.pdf` (fictional sample, 3 pages) still renders as before |
| Overlay (`tools/overlay.sh`) | ok: `samples/OVERLAY-duffy-8711-16-pretrial-memorandum.pdf` and `.txt`. Page map (sample page to exemplar page; exemplar pages are memorandum pages 1 to 23): 1→2, 2→3, 3→4, 4→13, 5→20, 6→21, 7→23. The pairing is by word overlap and is diagnostic only: pages 4 to 7 pair with later memorandum pages because the sample omits memorandum pages 7 to 21 |
| Pages reviewed | 7 of 7 for the transcribed sample (Gate 2, below); 3 of 3 for the fictional sample |

The brief's target for an exemplar this long was 8 to 14 rendered pages. The sample is 7 pages: the memorandum's summary of facts, its analysis of the issues and its later pages do not OCR cleanly (the tables and the argument are scrambled in the text layer), so they are marked omitted in the sample. This is a shortfall against the target, and it is stated here rather than padded.

## What is here

| Path | What |
|---|---|
| `typst/tax-pretrial-memorandum.typ` | The template: `tax-pretrial-memorandum(meta, body)`. Every number is a named parameter at the top, and each traces to a rule or a style choice. |
| `typst/main.typ` | Entry point. Reads `--input sample=...`, splits frontmatter from body, calls the template. |
| `samples/INPUT-duffy-8711-16-pretrial-memorandum.md` | Transcribed from the exemplar: the caption, the form fields (attorneys, amounts table, status boxes, trial time, stipulation), motions, issues 1 to 6, the witness table, the start of the summary of facts, the respondent's adjustment positions, the partnership passage, the penalties paragraph, the evidentiary-problems paragraph, and the certificate of service. Omitted pages are marked. The attorney's email and bar number are placeholders (not legible in the scan); taxpayers' address is a placeholder. |
| `samples/OUTPUT-duffy-8711-16-pretrial-memorandum.pdf`, `samples/OVERLAY-duffy-8711-16-pretrial-memorandum.pdf`, `.txt` | The render, the overlay against the exemplar, and its page map. |
| `samples/INPUT-generic-pretrial-memorandum.md` | Fictional sample: two petitioners, both attorneys, one amounts row, a status box, a witness table, the issues, the summary of facts, a signature block. Kept as a second, structurally different sample. |
| `samples/OUTPUT-generic-pretrial-memorandum.pdf` | The render of the fictional sample. |
| `exemplars/FILED-EXAMPLE-duffy-8711-16-pretrial-memorandum.pdf`, `exemplars/SOURCE.md` | The exemplar (pages 4 to 26 of a public bankruptcy filing) and its source record. |

Naming: the repo tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, and read the `INPUT-<id>.md` file name. This folder follows that, not the `<id>.pdf` names in the task brief.

Build (from the repo root, with the toolchain on PATH):

```sh
sh tools/render.sh courts/national/tax-court/pretrial-memorandum samples/INPUT-duffy-8711-16-pretrial-memorandum.md
sh tools/overlay.sh courts/national/tax-court/pretrial-memorandum duffy-8711-16-pretrial-memorandum
sh tools/render.sh courts/national/tax-court/pretrial-memorandum samples/INPUT-generic-pretrial-memorandum.md
```

## Governing rules

Verified 2026-10-14 against the primary text.

A pretrial memorandum is not described in the Rules' text. It is called for by the Standing Pretrial Order that the Clerk includes with the notice of trial under Rule 131(b). So the content comes from the order's form, and the form-and-style rules come from Rule 23.

| Rule | Requirement | Kind | Source |
|---|---|---|---|
| 131(b) | At the trial judge's direction, the Clerk includes a Standing Pretrial Order or other instructions with the notice of trial. Unexcused failure to comply may subject a party or counsel to sanctions (Rules 104, 123, 202). | M (the order) | Complete rules, Rule 131(b), as amended through August 2024: https://ustaxcourt.gov/files/documents/Complete-Rules-of-Practice-and-Procedure.pdf |
| 131(b) order | The sample order (regular case) says each party must file a Pretrial Memorandum no later than 21 days before the first day of the trial session, that a Pretrial Memorandum form is attached, and that witnesses must be identified in it with a brief summary of their anticipated testimony. Unidentified witnesses are not permitted to testify without good cause. The date is set by each order, so the template does not hard-code it. | M (each order) | SPTO regular sample: https://www.ustaxcourt.gov/resources/taxpayer/SPTO_regular_sample.pdf |
| 131(b) form | The form's fields: name of case; docket number(s); attorneys for each side with telephone and email; amounts in dispute (year(s)/period(s), deficiencies/liabilities, additions/penalties); status of case (probable settlement, probable trial, definite trial); current estimate of trial time; motions expected; status of the stipulation of facts; issues; witnesses expected (name and summary); summary of facts (chronological narrative, attached pages allowed). | M (the form's own fields) | same (form attached to the sample order) |
| 23(a)(1)-(3) | Caption with full names; date of signature; name, mailing address, email, telephone and Tax Court bar number beneath the signature. | M | Rule 23, as amended effective March 20, 2023: https://www.ustaxcourt.gov/resources/ropp/Rule-23_Amended_03202023.pdf |
| 23(d)(1) | 8.5 x 11 inches. Side margins at least 1 inch. Top and bottom at least 3/4 inch. | M | same |
| 23(d)(2) | One consistent typeface: 14-point proportional, or 12 cpi or 12-point nonproportional. Double spacing for text; single spacing for indented quotations and footnotes. | M | same |
| 23(d)(3) | Double-spaced lines no more than 3 to the vertical inch; single-spaced no more than 6. | M | same |
| 23(e) | No back or cover on a paper filed in paper form. No cover sheet; the caption starts page 1. | M | same |
| 23(f) | Case names underscored or italic. (Author responsibility in the markdown.) | M | same |

Known gaps: the form in the sample order is a 2000-era layout with placeholder values, and the Court's current Pretrial Memorandum form PDF (https://www.ustaxcourt.gov/resources/forms/Pretrial_Memorandum_Form.pdf) could not be downloaded (HTTP error page). Its current fields have not been compared with this template. Recheck the current form and the current sample order before filing reliance.

## Tier 2 choices (conventions, and what the template does)

- **Caption.** The same as the petition's, with the docket number filled in (the Clerk has assigned it by this stage). The respondent line is fixed text.
- **Title.** "PRETRIAL MEMORANDUM FOR PETITIONER" (or RESPONDENT), from the frontmatter `party`.
- **Form fields.** Labels bold, values in a second column, single-spaced, as on the Court's form. Checkboxes are drawn (not font glyphs). Attorneys are set side by side. Amounts and witnesses are tables, with the body typeface and size.
- **Narrative.** Issues, motions, witnesses and summary of facts are markdown sections (`#`), bold and flush left, with double-spaced text and a first-line indent.
- **Open choice (flagged):** the form fields are single-spaced. Rule 23(d)(2) requires double spacing "between each line of text", and it is not settled whether a labeled form field or a table cell is "text" for that purpose. The template follows the Court's form, which is single-spaced. If the Court reads the rule to cover the fields, change `field`, `form-block` and the tables to `double-leading`; the page count grows.
- **Signature block.** As in the petition: the date, a rule above the name, the bar number and contact lines. Kept on one page.
- **Page numbers.** Centered at the foot of each page on the 3/4-inch line (see Margins).
- **Typeface.** EB Garamond at 14 pt. Rule 23(d)(2) requires one consistent typeface, 14-point proportional (or 12-point nonproportional); it names no face as a requirement (its examples, Times New Roman and Century Schoolbook, are introduced by "e.g." in the petition's copy of the rule). Any proportional face therefore meets the rule, so the template keeps EB Garamond. The vendored substitutes are in `docs/FONTS.md`; switch only if the Court or the trial judge asks for another face. Face required: no. Font: EB Garamond.

## Calibration

The same as the petition: double leading `1.07em` gives a 24.08 pt baseline pitch (measured on page 2, 18 consecutive body-line deltas), and single leading `0.4em` gives 14.7 pt. Paragraph spacing equals the leading, so each new paragraph starts one double-spaced pitch below the last line.

## Margins

Measured from the text boxes of the final render, in points from each edge: left 72.0; right 72.3 to 84.5 (page 2's text is shorter on the right, which is within the margin); top 67.0 (the caption's line box); bottom 55.8 (the page number). Rule 23(d)(1) needs at least 72 on the sides and at least 54 top and bottom. All pass.

The page number is placed with `page(foreground: place(bottom + center, dy: -footer-distance, ...))`, not typst's `footer`, for the same reason as in the petition (see that README). `footer-distance` is 0.75 inch plus 6 pt.

## Gate 2: visual review of the current PDF

Reviewed 2026-10-14. sha256 of `samples/OUTPUT-generic-pretrial-memorandum.pdf`: `bb43d4cc3e1bf22125147e73386e4e48aebd331ed683c126ea054c28b89c8271` (re-rendered 2026-10-14 for the fonts pass; the face is unchanged, and the pages were looked at again). Every page was rendered at 60 dpi and looked at. There is no exemplar, so the pages are compared with the form's fields and the rules.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | form fields (name of case, docket, attorneys, amounts, status, trial time, stipulation) | First render: the "CURRENT ESTIMATE OF TRIAL TIME:" label wrapped in its column: FIXED by making that field one line. The field label column was widened to 3.5 inch. Attorneys, amounts table, and the three checkboxes are aligned and legible. Page number 4.7 pt from the edge: FIXED (see Margins). | PASS |
| 2 | narrative (motions, issues, witnesses, summary) | First render: the first numbered issue had no first-line indent: FIXED with `first-line-indent: (amount, all: true)`. Witness table: three rows, the header row, readable. Final: clean. | PASS |
| 3 | summary of facts, signature block | Summary continues from page 2; the signature block follows it on page 3, with the rule above the name and the bar number and contact lines below. Final: clean. | PASS |

No row is `OPEN`. The overlay cannot be produced without an exemplar.

## Gate 2 for the transcribed sample (Duffy exemplar), 2026-10-15

Reviewed 2026-10-15. sha256 of `samples/OUTPUT-duffy-8711-16-pretrial-memorandum.pdf`: `1860ff364d1293c394d1a8cfeb48303c4369e52f42199fbaefe3526f1d21072a`. Every page was rendered at 60 dpi (`pdftoppm -r 60`) and looked at, after the last edit. Compared with the exemplar's memorandum pages as read from the scan (memorandum page numbers are the filing's own "Docket No. 8711-16 - N -").

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar memo p.1 (caption, NAME OF CASE, attorneys, amounts) | Caption and title "PRETRIAL MEMORANDUM FOR RESPONDENT" match. Form fields and the amounts table match the filing's six years. The filing's "Petitioners: Pro Se" and "Respondent: Nhi T. Luu" match. The filing does not print an email for the respondent in the scan; the sample shows "[email not legible in the scanned copy]". | PASS |
| 2 | exemplar memo p.2 (status, trial time, motions, stipulation, issues 1 and 2) | First render showed "3-4 hours hour(s)": the template appends "hour(s)" to the value, so the value was changed to "3-4" (FIXED, re-viewed). Status boxes: "Definite Trial" and "In Progress" checked, as in the filing. | FIXED, then PASS |
| 3 | exemplar memo p.3 (issues 3 to 6, witness table) | Issues numbered and indented as the filing's. Witness table: header row and two rows, readable. | PASS |
| 4 | exemplar memo p.4 (summary of facts, respondent's positions, analysis heading) | Summary of facts opens as the filing does; the omitted-pages note is in italics. Primary and secondary positions are the filing's, as read from the scan. The entity name is not legible in the text layer, so it is a bracketed placeholder. | PASS |
| 5 | exemplar memo p.20 (partnership analysis) | Partnership paragraphs with section citations, double-spaced. The text is from the text layer and checked against the page image. | PASS |
| 6 | exemplar memo p.21 (penalties, evidentiary problems) | First render had the body signature block run into one paragraph ("NHI T. LUU Senior Attorney ... Telephone"). FIXED by removing the body copy: the template's signature block (page 7) carries the signature and date. Certificate of service heading now starts on this page. | FIXED, then PASS |
| 7 | exemplar memo p.23 (certificate of service, signature) | Certificate text, then the template's signature block with the rule and the bar-number placeholder. The filing signs the memorandum and then the certificate; the template prints one signature block at the end of the document, after the certificate. | ACCEPTED (template signature placement: one block at the end, as the form's own layout puts the signature last) |

No row is `OPEN`. The sample transcribes parts of memorandum pages 1 to 6, 12 to 13, 19 to 21 and 22 to 23 of the 23-page memorandum; the rest is marked omitted. The sample is 7 rendered pages, one short of the brief's 8-page floor for an exemplar this long (see the top of this README).

## Gate 2 for the fictional sample

Unchanged from 2026-10-14 (the pass above, sha256 `bb43d4cc...` of the old `OUTPUT-generic-pretrial-memorandum.pdf`). It has no exemplar, so no overlay exists for it.

## Open choices and gaps

- **One filer only.** Tier 2 is judged against one respondent's memorandum. A petitioner-side memorandum from a different filer is needed before tier 2 can be called done (docs/EVAL-LOOP.md). Earlier leads (*Blum*, Docket No. 5313-16; *GFS Holding Inc.*, Docket No. 11800-22) were HTTP 403 from this box on 2026-10-14 and were not retried on 2026-10-15; they remain the first check. The 2026-10-15 CourtListener searches for petitioner-side memoranda (by caption and by form field labels) returned nothing usable.
- The exemplar is a respondent's memorandum from a bankruptcy docket (the DOJ cover letter is pages 1 to 3 of the filing and is not in the exemplar file). The form's field labels match the filing's; the narrative sections follow the filing.
- The sample is fictional and three pages long. The brief's 8 to 14 page target applies to a long exemplar and does not apply here.
- The trial calendar and the date of the trial session are frontmatter values. The template does not compute the 21-day deadline or any other date.
- The mechanical gates of `tools/check.sh` (`checks.yaml`) were not written for this doc type. Checks run by hand here: render (no warnings), font names (`pdffonts`: EB Garamond only), margins (bounding boxes), line pitch (bounding boxes), and the Gate 2 review above.
