# Tax Court: pretrial memorandum (Rule 131(b), Standing Pretrial Order)

**BLOCKED: no exemplar.** No public, filed pretrial memorandum was found (searches and results: [exemplars/SOURCE.md](exemplars/SOURCE.md)). The field set follows the Court's form as printed in its sample Standing Pretrial Order. The sample is fictional. The overlay cannot run without an exemplar.

| Check | Result |
|---|---|
| Exemplar | no |
| Render (`tools/render.sh`) | ok: `samples/OUTPUT-generic-pretrial-memorandum.pdf`, 3 pages, no typst warnings |
| Overlay (`tools/overlay.sh`) | fail: no exemplar PDF in `exemplars/` (no overlay written) |
| Pages reviewed | 3 of 3 (Gate 2 log below) |

## What is here

| Path | What |
|---|---|
| `typst/tax-pretrial-memorandum.typ` | The template: `tax-pretrial-memorandum(meta, body)`. Every number is a named parameter at the top, and each traces to a rule or a style choice. |
| `typst/main.typ` | Entry point. Reads `--input sample=...`, splits frontmatter from body, calls the template. |
| `samples/INPUT-generic-pretrial-memorandum.md` | Fictional sample: two petitioners, both attorneys, one amounts row, a status box, a witness table, the issues, the summary of facts, a signature block. |
| `samples/OUTPUT-generic-pretrial-memorandum.pdf` | The render. |
| `exemplars/SOURCE.md` | The exemplar search. |

Naming: the repo tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, and read the `INPUT-<id>.md` file name. This folder follows that, not the `<id>.pdf` names in the task brief.

Build (from the repo root, with the toolchain on PATH):

```sh
sh tools/render.sh courts/national/tax-court/pretrial-memorandum samples/INPUT-generic-pretrial-memorandum.md
sh tools/overlay.sh courts/national/tax-court/pretrial-memorandum generic-pretrial-memorandum   # fails until an exemplar is in exemplars/
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

## Open choices and gaps

- **No exemplar** (BLOCKED, see top). Tier 2 (conventions across filers) is not judged; the layout follows the form's fields and the rules.
- The sample is fictional and three pages long. The brief's 8 to 14 page target applies to a long exemplar and does not apply here.
- The trial calendar and the date of the trial session are frontmatter values. The template does not compute the 21-day deadline or any other date.
- The mechanical gates of `tools/check.sh` (`checks.yaml`) were not written for this doc type. Checks run by hand here: render (no warnings), font names (`pdffonts`: EB Garamond only), margins (bounding boxes), line pitch (bounding boxes), and the Gate 2 review above.
