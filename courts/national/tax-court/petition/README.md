# Tax Court: petition (Rule 34(b))

**Exemplar: 1 of 2 filers.** One real filed petition is in `exemplars/`: *Lawrence v. Commissioner*, Tax Court Docket No. 20370-09 (pro se, amended petition, Form 1 items; 52 pages, OCR text layer added). Source and search history: [exemplars/SOURCE.md](exemplars/SOURCE.md). Tier 2 is judged against this one filer only, which `docs/EVAL-LOOP.md` says cannot finish tier 2; a second petition from a different filer is still needed.

| Check | Result |
|---|---|
| Exemplar | yes: `exemplars/FILED-EXAMPLE-lawrence-20370-09-petition.pdf` (1 filer) |
| Render (`tools/render.sh`) | ok: `samples/OUTPUT-lawrence-20370-09-petition.pdf`, 8 pages, EB Garamond only, no typst warnings. `samples/OUTPUT-generic-petition.pdf` (fictional sample, 3 pages) still renders as before |
| Overlay (`tools/overlay.sh`) | ok: `samples/OVERLAY-lawrence-20370-09-petition.pdf` and `.txt` (page map: pages 2 to 7 pair with filed pages 2, 3, 4, 6, 7, 8; page 1 and page 8 pair with filed page 51, because the caption and signature text is mostly unreadable in the OCR) |
| Pages reviewed | 8 of 8 for the transcribed sample (Gate 2, below); 3 of 3 for the fictional sample |

## What is here

| Path | What |
|---|---|
| `typst/tax-petition.typ` | The template: `tax-petition(meta, body)`. Every number is a named parameter at the top, and each traces to a rule. |
| `typst/main.typ` | Entry point. Reads `--input sample=...`, splits frontmatter from body, calls the template. |
| `samples/INPUT-lawrence-20370-09-petition.md` | Transcribed from the exemplar: caption, Form 1 items 1 to 6, sections I to IV (pages 1 to 8 of the filing, in page order), the omitted pages marked, the prayer and the signature block (page 51). The filer's text is reproduced for layout only. Address and telephone are placeholders. |
| `samples/OUTPUT-lawrence-20370-09-petition.pdf` | The render of that sample. |
| `samples/OVERLAY-lawrence-20370-09-petition.pdf`, `.txt` | The red/blue overlay against the exemplar, and its page map. |
| `samples/INPUT-generic-petition.md` | Fictional sample: two petitioners, the notice of deficiency, assignments of error, facts, special matters, the prayer, the signature block. Kept as a second, structurally different sample. |
| `samples/OUTPUT-generic-petition.pdf` | The render of the fictional sample. |
| `exemplars/FILED-EXAMPLE-lawrence-20370-09-petition.pdf`, `exemplars/SOURCE.md` | The exemplar (filed as Exhibit 6 to a public bankruptcy filing) and its source record. |

Naming: the repo tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, and read the `INPUT-<id>.md` file name. This folder follows that, not the `<id>.pdf` names in the task brief.

Build (from the repo root, with the toolchain on PATH):

```sh
sh tools/render.sh courts/national/tax-court/petition samples/INPUT-lawrence-20370-09-petition.md
sh tools/overlay.sh courts/national/tax-court/petition lawrence-20370-09-petition
sh tools/render.sh courts/national/tax-court/petition samples/INPUT-generic-petition.md
```

## Governing rules

Verified 2026-10-14 against the primary text.

| Rule | Requirement | Kind | Source |
|---|---|---|---|
| 23(a)(1) | Caption with the full name and surname of each individual petitioner, no prefixes. An estate or fiduciary is named as "Estate of X, Deceased, Y, Executor." | M | Rule 23, as amended effective March 20, 2023: https://www.ustaxcourt.gov/resources/ropp/Rule-23_Amended_03202023.pdf |
| 23(a)(2) | Date of signature on the paper. | M | same |
| 23(a)(3) | Signature, then typed name, mailing address, email, telephone and Tax Court bar number beneath it. | M | same |
| 23(d)(1) | 8.5 x 11 inches. Side margins at least 1 inch. Top and bottom margins at least 3/4 inch. One side of opaque paper. | M | same |
| 23(d)(2) | One consistent typeface: 12 cpi or 12-point nonproportional, or 14-point proportional (e.g. Times New Roman, Century Schoolbook). Double spacing between lines of text. Single spacing for indented quotations and footnotes. Quotations over five lines set off and indented. | M | same |
| 23(d)(3) | Double-spaced lines no more than 3 to the vertical inch. Single-spaced lines no more than 6 to the vertical inch. | M | same |
| 23(e) | No back or cover on a paper filed in paper form. The petition therefore has no cover sheet; the caption starts page 1. | M | same |
| 23(f) | Case names underscored or italic. (The template does not italicize; the author marks case names in the markdown.) | M | same |
| 34(a) | The petition must identify the issues presented, or the case may be dismissed. | M | Complete rules, Rule 34(a): https://ustaxcourt.gov/files/documents/Complete-Rules-of-Practice-and-Procedure.pdf (as amended through August 2024) |
| 34(b)(1)(A) | Individual petitioner's name and State of legal residence. | M | same |
| 34(b)(1)(C) | Mailing address, and the IRS office where the period's return was filed. | M | same |
| 34(b)(1)(D) | Date of the notice of deficiency, and the city and State of the IRS office that issued it. | M | same |
| 34(b)(1)(E) | If the petitioner's name differs from the notice, the reasons. | M | same |
| 34(b)(1)(F) | Amount of the deficiency, the nature of the tax, and the years. If only part is disputed, the approximate amount in dispute. | M | same |
| 34(b)(1)(G) | Separately lettered assignments of each error. Any issue not assigned is conceded. | M | same |
| 34(b)(1)(H) | Separately lettered statements of the facts relied on (not for errors the Commissioner must prove). | M | same |
| 34(b)(1)(I) | Special matters required by Rule 39. | M | same |
| 34(b)(1)(J) | The relief sought. | M | same |
| 34(b)(1)(K) | Signature, mailing address, email and telephone of each petitioner or counsel, and the bar number. | M | same |
| 34(b)(2) | A copy of the notice of deficiency attached. (Author responsibility: the template does not attach it; the sample refers to Exhibit A.) | A | same |
| 20(b) | A statement of taxpayer identification number, substantially in accordance with Form 4, submitted with the petition. (Separate filing, not in this template.) | A | same |
| 20(d) | Filing fee of $60, or a waiver request. (Not in this template.) | A | same |
| Form 1 (Appendix I) | "Substantially in accordance" with Form 1 (Rule 34(b)(1)). The form is a scanned image in the rules PDF with no text layer, so its layout was not compared; the content list above is the rule text. | M (content) | same |

Known rule version gap: the compilation is "as amended through August 2024" and the Rule 23 text is the March 20, 2023 amendment. No later amendment was found in the searches run on 2026-10-14. Recheck the Court's rules page before filing reliance.

## Tier 2 choices (conventions, and what the template does)

- **Caption.** Names on the left, a ")" column, and "Docket No." on the right on the "v." line. The respondent line is fixed text ("COMMISSIONER OF INTERNAL REVENUE, Respondent."), because Rule 34 sues the Commissioner. The docket number is blank ("Docket No. __________") unless the frontmatter gives one: the Clerk assigns it on filing.
- **Title.** "PETITION", bold, centered, after the caption.
- **Body.** Numbered paragraphs typed by the author (`1\.`), indented. Lettered subparagraphs typed by the author as `(a)`. Headings (`#`) are bold and centered. Paragraphs are double-spaced with a first-line indent of 0.5 inch, and the first paragraph after a heading is indented too.
- **Signature block.** Right half of the page, the rule above the name, then the bar number and contact lines. It is kept on one page (not split).
- **Page numbers.** Centered at the foot of each page, on the 3/4-inch line (see Margins).
- **Typeface.** EB Garamond at 14 pt. Rule 23(d)(2) requires one consistent typeface, 14-point proportional (or 12-point nonproportional); it names no face as a requirement, and its examples are introduced by "e.g." (Times New Roman, Century Schoolbook). Any proportional face therefore meets the rule, so the template keeps EB Garamond. The vendored substitutes for the examples are Liberation Serif (Times New Roman) and TeX Gyre Schola (Century Schoolbook) in `docs/FONTS.md`; switch to one only if a court or the Clerk asks for that face. Face required: no. Font: EB Garamond. Render: metric-independent (no change of face, so no line-count change).

## Calibration

- EB Garamond at 14 pt has a line box of about 9.1 pt, so the leading is set in `em` (not `pt`): double spacing is `1.07em` of leading, which gives a baseline pitch of 24.08 pt (3.0 lines to the inch, the Rule 23(d)(3) maximum). Measured with `pdftotext -bbox-layout` on page 2: 18 consecutive body-line deltas of 24.08 pt.
- Paragraph spacing equals the leading. Typst's paragraph spacing does not include the leading, so with zero spacing the first line of each paragraph overlapped the last line of the previous one (fixed; see Gate 2).
- Single spacing is `0.4em` of leading: a single pitch of 14.7 pt (4.9 lines to the inch, inside the Rule 23(d)(3) limit of 6).

## Margins

Measured from the text boxes of the final render (all pages, `pdftotext -bbox-layout`), in points from each edge: left 72.0, right 72.3 to 72.6, top 67.0 (the caption's line box; the body margin is 1 inch), bottom 55.8 (the page number). Rule 23(d)(1) requires side margins of at least 72 and top and bottom of at least 54. All pass.

The page number is not typst's `footer`. In typst 0.15 the footer's position did not move monotonically with `footer-descent` (measured: 1.5 in gave a higher line than 0.75 in; the number sat 4.7 pt from the edge at 0.75 in). The number is placed with `page(foreground: place(bottom + center, dy: -footer-distance, ...))`, and `footer-distance` is 0.75 inch plus 6 pt, which puts the number's line box 55.8 pt from the edge.

## Gate 2: visual review of the current PDF

Reviewed 2026-10-14. sha256 of `samples/OUTPUT-generic-petition.pdf`: `89edd40d9cbfd0c4eeebb68d212b2dbb2702b5004a1baf9c1fc089a0a7c69e2c` (re-rendered 2026-10-14 for the fonts pass; the face is unchanged, and the pages were looked at again). Every page was rendered at 60 dpi and looked at. Page 1 is compared with the rules, since there is no exemplar.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | rules (Rule 23(a), 23(d), 34(b)(1)(A)-(F)) | Caption: names, ")" column, "Docket No. ____" line blank (Clerk assigns). Paragraph overlap in the first render (paragraph spacing 0): FIXED by paragraph spacing = leading. Caption rows colliding in the first render (no row gutter): FIXED with a single-spacing row gutter. Left caption column wrapped "COMMISSIONER OF INTERNAL REVENUE,": FIXED by widening it to 4.0 in. Page number 4.7 pt from the edge: FIXED (see Margins). Final: caption clean, numbered paragraphs 1 to 4 double-spaced and aligned. | PASS |
| 2 | rules (34(b)(1)(G)-(H)) | Assignments and facts: first paragraph after a heading lost its first-line indent in the first render: FIXED with `first-line-indent: (amount, all: true)`. Final: lettered (a)-(d) and (a)-(f) subparagraphs indented, headings centered and bold. | PASS |
| 3 | rules (34(b)(1)(I)-(K), 23(a)(2)-(3)) | Special matters, prayer, date line, signature block (rule, name, bar number, firm, address, phone, email, "Counsel for Petitioners"). Signature rule overlapped the name in the first render: FIXED with spacing around the rule. Final: clean. | PASS |

No row is `OPEN`. The overlay (tier 3, a diagnostic) cannot be produced without an exemplar.

## Gate 2 for the transcribed sample (Lawrence exemplar), 2026-10-15

Reviewed 2026-10-15. sha256 of `samples/OUTPUT-lawrence-20370-09-petition.pdf`: `3a403f42895d3dd6df530b6fbea9c181f94116c7e5cf7b51c49a4e3143b57c32`. Every page was rendered at 60 dpi (`pdftoppm -r 60`) and looked at, after the last edit. Compared with the exemplar's pages as read from the scans (exemplar page numbers are the filing's own "Page X of 52").

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 (caption, Form items 1 to 5) | Caption, ")" column and "Docket No. 20370-09" match. Items 1 to 5 are typed as numbered paragraphs, not the Form's check boxes; the boxes are typed as `[x]` and `[ ]`. The filing's title is "AMENDED PETITION"; the template prints "PETITION" (fixed by the template, see Tier 2 choices). | ACCEPTED (title: template is fixed to "PETITION"; the amended form is the same Form 1 petition, and the rules name no title) |
| 2 | exemplar p.2 (Form item 6, section I, section II) | Heading "II. Introduction of Credible Evidence" is bold and centered as in the filing. The lone "I." is a paragraph at the left margin in our render; the filing centers it. The template has no rule for a bare roman numeral, so it is left as typed. | ACCEPTED (a lone roman numeral is the filer's layout; the template's heading style is the convention) |
| 3 | exemplar p.3 (section II, continued; section III heading) | Section III heading wraps to three centered lines, as the filing's heading does. Case name *Rendall v. Commissioner* is italic (Rule 23(f): case names underscored or italic, which the markdown sample supplies). | PASS |
| 4 | exemplar p.4 (paragraphs A and B) | Lettered paragraphs are indented as normal paragraphs. The filing hangs the letter in the margin. | ACCEPTED (tier 2: the filing's hanging letters are one filer's layout; the template's `(a)` convention is not the Form's; rules leave the lettering open) |
| 5 | exemplar p.6 (paragraphs C to F) | Same as page 4. Paragraphs are double-spaced at 24.1 pt pitch. | PASS |
| 6 | exemplar p.7 (paragraph G; the constructive-receipt argument) | First render had a blank line in the middle of paragraph G, which split it: FIXED by joining the paragraph in the sample. Re-viewed: continuous, first-line indent on each paragraph. | FIXED, then PASS |
| 7 | exemplar p.8 (section IV, paragraphs A to C) | Heading "IV. Assignments of Error..." bold and centered in three lines, as the filing. | PASS |
| 8 | exemplar p.51 (prayer, enclosures, signature) | Prayer, ENCLOSURES paragraph, date and signature block with the rule above the name. The filing has a handwritten signature and a handwritten address (replaced by placeholders in the sample). Signature is typed in the template; that is the template's convention, not a rule point. | ACCEPTED (handwritten signature in the filing; template typed block) |

No row is `OPEN`. The sample transcribes pages 1 to 8 and 51 of the 52-page petition; pages 9 to 50 are marked omitted in the sample body, so the sample is 8 rendered pages (the brief's 8-to-14 range for an exemplar this long).

## Gate 2 for the fictional sample

Unchanged from 2026-10-14 (the earlier pass above, sha256 `89edd40d...` of the old `OUTPUT-generic-petition.pdf`). It has no exemplar, so no overlay exists for it.

## Open choices and gaps

- **One filer only.** The tier-2 judgement is against one pro se petition (Lawrence). A second petition from a different filer is needed before tier 2 can be called done (docs/EVAL-LOOP.md: fewer than 2 exemplars cannot finish tier 2). The ACCEPTED rows above are judged against this one filer, so they are provisional.
- The exemplar's form is the amended petition by a pro se filer, with long legal argument. The template models the Rule 34(b) deficiency petition. The overlay pairs by word overlap and is diagnostic only; its page 1 pairs with a different page because the OCR text of the caption is scrambled.
- The OCR text layer on the exemplar is machine-made (tesseract, English); words in the caption and in handwritten areas are not reliable. The sample transcription was checked against the page images, not the OCR.
- The sample is fictional and three pages long. A petition is short; the brief's 8 to 14 page target applies to a long exemplar and does not apply here.
- No footnotes or tables in the template (not used in a petition; cmarker would render them, untested).
- The mechanical gates of `tools/check.sh` (`checks.yaml`) were not written for this doc type. Checks run by hand here: render (no warnings), font names (`pdffonts`: EB Garamond only), margins (bounding boxes), line pitch (bounding boxes), and the Gate 2 review above.
- Not checked: Word or LibreOffice output (not a court-required engine for this doc type in this task).

## Engines

**docx** (`docx/reference.docx` from `docx/build-reference.sh`, and `docx/tax-petition.lua`). Output: `samples/OUTPUT-generic-petition.docx` and `samples/OUTPUT-generic-petition.docx.pdf` (LibreOffice conversion, 3 pages).

- Matches the typst output: EB Garamond 14 pt throughout (`pdffonts` shows only EBGaramond-Regular and EBGaramond-Bold); letter, 1 in side margins, 1 in top and bottom; double spacing as exact 24.1 pt lines and single as exact 14.7 pt; 0.5 in first-line indent; caption with the ")" column and "Docket No."; centered bold headings; signature block with the rule above the name; centered page number. Page breaks are the same as the typst render (6(d) ends page 2, 6(e) starts page 3). Word text of both renders matches.
- Differs: the caption, title and signature block are built by the filter as borderless tables, so their positions differ from typst by a few points. The page number sits at the footer distance (0.75 in), not at typst's exact 55.8 pt from the edge.
- Pages reviewed: 1-3 of 3 (`.docx.pdf`), at 60 dpi.
- BLOCKED: none. `tools/check.sh --engine docx` cannot run yet: `checks.yaml` is not in the court folder. The docx was checked by hand (fonts, word text, page images); Word itself was not available, so the file was opened in LibreOffice only.
