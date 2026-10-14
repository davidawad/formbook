# Tax Court: petition (Rule 34(b))

**BLOCKED: no exemplar.** No public, filed petition was found (searches and results: [exemplars/SOURCE.md](exemplars/SOURCE.md)). The template is built from the rules, and the sample is fictional. The overlay cannot run without an exemplar.

| Check | Result |
|---|---|
| Exemplar | no |
| Render (`tools/render.sh`) | ok: `samples/OUTPUT-generic-petition.pdf`, 3 pages, no typst warnings |
| Overlay (`tools/overlay.sh`) | fail: no exemplar PDF in `exemplars/` (no overlay written) |
| Pages reviewed | 3 of 3 (Gate 2 log below) |

## What is here

| Path | What |
|---|---|
| `typst/tax-petition.typ` | The template: `tax-petition(meta, body)`. Every number is a named parameter at the top, and each traces to a rule. |
| `typst/main.typ` | Entry point. Reads `--input sample=...`, splits frontmatter from body, calls the template. |
| `samples/INPUT-generic-petition.md` | Fictional sample: two petitioners, the notice of deficiency, assignments of error, facts, special matters, the prayer, the signature block. |
| `samples/OUTPUT-generic-petition.pdf` | The render. |
| `exemplars/SOURCE.md` | The exemplar search: what was searched, what came back, why nothing was used. |

Naming: the repo tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, and read the `INPUT-<id>.md` file name. This folder follows that, not the `<id>.pdf` names in the task brief.

Build (from the repo root, with the toolchain on PATH):

```sh
sh tools/render.sh courts/national/tax-court/petition samples/INPUT-generic-petition.md
sh tools/overlay.sh courts/national/tax-court/petition generic-petition   # fails until an exemplar is in exemplars/
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
- **Typeface.** EB Garamond at 14 pt, the only vendored serif. Rule 23(d)(2) allows 14-point proportional type; the rule's examples (Times, Century Schoolbook) are not vendored and are not needed.

## Calibration

- EB Garamond at 14 pt has a line box of about 9.1 pt, so the leading is set in `em` (not `pt`): double spacing is `1.07em` of leading, which gives a baseline pitch of 24.08 pt (3.0 lines to the inch, the Rule 23(d)(3) maximum). Measured with `pdftotext -bbox-layout` on page 2: 18 consecutive body-line deltas of 24.08 pt.
- Paragraph spacing equals the leading. Typst's paragraph spacing does not include the leading, so with zero spacing the first line of each paragraph overlapped the last line of the previous one (fixed; see Gate 2).
- Single spacing is `0.4em` of leading: a single pitch of 14.7 pt (4.9 lines to the inch, inside the Rule 23(d)(3) limit of 6).

## Margins

Measured from the text boxes of the final render (all pages, `pdftotext -bbox-layout`), in points from each edge: left 72.0, right 72.3 to 72.6, top 67.0 (the caption's line box; the body margin is 1 inch), bottom 55.8 (the page number). Rule 23(d)(1) requires side margins of at least 72 and top and bottom of at least 54. All pass.

The page number is not typst's `footer`. In typst 0.15 the footer's position did not move monotonically with `footer-descent` (measured: 1.5 in gave a higher line than 0.75 in; the number sat 4.7 pt from the edge at 0.75 in). The number is placed with `page(foreground: place(bottom + center, dy: -footer-distance, ...))`, and `footer-distance` is 0.75 inch plus 6 pt, which puts the number's line box 55.8 pt from the edge.

## Gate 2: visual review of the current PDF

Reviewed 2026-10-14. sha256 of `samples/OUTPUT-generic-petition.pdf`: `d4dd59aab768151e776c78233d74879ecd0347b98a83137ac49cd9a32079cde8`. Every page was rendered at 60 dpi and looked at. Page 1 is compared with the rules, since there is no exemplar.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | rules (Rule 23(a), 23(d), 34(b)(1)(A)-(F)) | Caption: names, ")" column, "Docket No. ____" line blank (Clerk assigns). Paragraph overlap in the first render (paragraph spacing 0): FIXED by paragraph spacing = leading. Caption rows colliding in the first render (no row gutter): FIXED with a single-spacing row gutter. Left caption column wrapped "COMMISSIONER OF INTERNAL REVENUE,": FIXED by widening it to 4.0 in. Page number 4.7 pt from the edge: FIXED (see Margins). Final: caption clean, numbered paragraphs 1 to 4 double-spaced and aligned. | PASS |
| 2 | rules (34(b)(1)(G)-(H)) | Assignments and facts: first paragraph after a heading lost its first-line indent in the first render: FIXED with `first-line-indent: (amount, all: true)`. Final: lettered (a)-(d) and (a)-(f) subparagraphs indented, headings centered and bold. | PASS |
| 3 | rules (34(b)(1)(I)-(K), 23(a)(2)-(3)) | Special matters, prayer, date line, signature block (rule, name, bar number, firm, address, phone, email, "Counsel for Petitioners"). Signature rule overlapped the name in the first render: FIXED with spacing around the rule. Final: clean. | PASS |

No row is `OPEN`. The overlay (tier 3, a diagnostic) cannot be produced without an exemplar.

## Open choices and gaps

- **No exemplar** (BLOCKED, see top). Tier 2 (house conventions across filers) is not judged; the layout follows the rule text and the choices above.
- The sample is fictional and three pages long. A petition is short; the brief's 8 to 14 page target applies to a long exemplar and does not apply here.
- No footnotes or tables in the template (not used in a petition; cmarker would render them, untested).
- The mechanical gates of `tools/check.sh` (`checks.yaml`) were not written for this doc type. Checks run by hand here: render (no warnings), font names (`pdffonts`: EB Garamond only), margins (bounding boxes), line pitch (bounding boxes), and the Gate 2 review above.
- Not checked: Word or LibreOffice output (not a court-required engine for this doc type in this task).
