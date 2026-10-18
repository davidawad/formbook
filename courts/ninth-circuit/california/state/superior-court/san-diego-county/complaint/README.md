# calsuperct-sandiego: complaint

Doc type `complaint` for the Superior Court of California, County of San Diego (alias `calsuperct-sandiego`). A civil complaint on pleading paper. Template: `typst/calsuperct-sandiego-complaint.typ`, entry `typst/main.typ`.

Status: **typst only**. latex and docx are not built for this doc type. Exemplar found; render and overlay run; every page of the sample was rendered and looked at (see the review below). Open tier-2 items are listed below.

## Exemplar

`usage/SAMPLE-calsuperct-sandiego-complaint-sweetwater25cu033612n.pdf`: the Attorney General's complaint in *People v. Sweetwater Care OpCo, LLC, et al.*, Case No. 25CU033612N, filed in this court on 2025-06-23 (39 pages, text-based). Provenance in `usage/SOURCE.md`. The brief suggested a People v. Sun Healthcare complaint; no San Diego filing under that name was found (see Searches).

## Governing rules

Verified 2026-10-15 unless the row says otherwise. Quotations are from the fetched pages; re-check the Judicial Council and court pages before any filing.

| Rule | Requirement | Used for | Source |
|---|---|---|---|
| CRC 2.100-2.119 | Format of papers (scope) | whole document | https://www.courts.ca.gov/cms/rules/index/two/rule2_100 |
| CRC 2.104 | "Unless otherwise specified in these rules, all papers filed must be prepared using a font size not smaller than 12 points." (amended 2017-01-01) | `type-size = 12pt` | https://www.courts.ca.gov/cms/rules/index/two/rule2_104 |
| CRC 2.105 | "The font style must be essentially equivalent to Courier, Times New Roman, or Arial." (amended 2017-01-01) | Times New Roman row: **Liberation Serif** (see Typeface) | https://www.courts.ca.gov/cms/rules/index/two/rule2_105 |
| CRC 2.107 | Left margin at least 1 inch; right margin at least ½ inch (verified 2026-10-13 by the sibling complaint; not re-fetched today) | `left-margin = 1.5in`, `right-margin = 0.5in` | https://www.courts.ca.gov/cms/rules/index/two/rule2_107 |
| CRC 2.108 | Lines one-and-one-half or double spaced, numbered consecutively at the left margin; at least 3 numbers per vertical inch (verified 2026-10-13; not re-fetched today) | 24 pt pitch, 28 numbers, double rule | https://www.courts.ca.gov/cms/rules/index/two/rule2_108 |
| CRC 2.109 | Pages numbered consecutively at the bottom, Arabic numerals (verified 2026-10-13; not re-fetched today) | footer page number | https://www.courts.ca.gov/cms/rules/index/two/rule2_109 |
| CRC 2.110 | Footer below the page number, divided from the page by a printed line; title of the paper in at least 10-point type (verified 2026-10-13; not re-fetched today) | footer, 10 pt title | https://www.courts.ca.gov/cms/rules/index/two/rule2_110 |
| CRC 2.111(1)-(2) | Attorney information from line 1, 1 inch from the top, left of center; clerk's space on the right of lines 1-7 (verified 2026-10-15, summarized) | attorney block in lines 1-7 (168 pt), 4.2 in wide | https://www.courts.ca.gov/cms/rules/index/two/rule2_111 |
| CRC 2.111(3) | Court title on line 8, at or below 3⅓ inches from the top (verified 2026-10-15) | court title at 240 pt = 3⅓ in | same |
| CRC 2.111(4)-(6) | Case title left; case number right, opposite; nature of the paper below the number; complaints also state the type of action (verified 2026-10-15) | caption | same |
| CRC 2.111(7) | Judge and department below the nature of the paper, if assigned (verified 2026-10-15) | optional `judge` / `dept` fields | same |
| CRC 2.111(9) | Limited civil complaint: "Amount demanded exceeds …" / "does not exceed …" (verified 2026-10-15, summarized; the fetched text says $10,000; CCP § 85 has since changed the limit, see Known gaps) | optional `amount_demanded` | same |
| CRC 2.111(10) | "Limited Civil Case" in the caption of a limited civil case (verified 2026-10-15, summarized) | optional `limited_civil` | same |
| CRC 2.112 | Each separately stated cause of action states its number, nature, the party asserting it, and the party it is against (verified 2026-10-13; not re-fetched today) | headings in body | https://www.courts.ca.gov/cms/rules/index/two/rule2_112 |
| SD Local Rule 2.1.2(H) | Gov. Code § 6103 exempt filer: the label goes in the **upper right-hand corner, above the caption, where it does not interfere with the clerk's file stamp** (Local Rules, Division II, effective 1/1/2026, p. 2) | `fee_exempt` label, top right of lines 1-2 | https://www.sdcourt.ca.gov/sites/default/files/sdcourt/generalinformation/localrulesofcourt/division_ii_-_civil_2026.pdf |
| SD Local Rule 2.1.4.1(D) | E-filed documents: PDF, **text-searchable (OCR)**. Verified by `pdftotext` on the sample render. | the sample render is text-searchable | same |
| SD Local Rule 2.1.4.1(C) | E-filed exhibits need bookmarks (no exhibits in this sample) | not implemented | same |

The complaint's substantive content (CCP § 425.10 and following) is not checked by this template.

## Typeface

CRC 2.105 names no single face; it names the **essential equivalent of Courier, Times New Roman, or Arial**. Per `docs/FONTS.md` ("Times New Roman, Times" row) the substitute is **Liberation Serif** (SIL OFL 1.1, metric-compatible with Times New Roman, so line breaks and page count track a Times filing). EB Garamond is not used here: the rule names a Times-family face, and the FONTS table says a court-named face uses its substitute, not EB Garamond. `pdffonts` on the render: the embedded families are `LiberationSerif` only.

## Layout

- **Pleading grid.** Lines 24 pt apart (double spacing). Each text line is a 1 em box (`top-edge: 0.7em`, `bottom-edge: -0.3em`), so the leading sets the pitch. The 28 line numbers use the same box, so each number sits on the baseline of its text line.
- **Bottom margin.** 46 pt: 28 lines fit, 29 do not. The footer sits 14 pt above the page edge.
- **Rules.** A double vertical rule at 1.22-1.25 in, between numbers and text. A single rule at 8.1 in.
- **First page.** Attorney block single-spaced in a fixed 168 pt box (lines 1-7); the template panics if it is taller. The fee label (when given) sits in a 2.3 in column at the top right. Court title in a 48 pt box (lines 8-9). Caption starts on line 11; left column 3.6 in with a right and bottom rule; right column holds the case number, the title (bold), the details, and the optional judge/department and amount lines.
- **Body.** Paragraphs first-line-indent 0.5 in. Level-1 and -2 headings centered and bold caps; level 3 bold; level 4 bold italic.
- **Signature.** "Dated:" at left; the signature block at 3.1 in; the "By:" line with the signer's name and role below it.

No case-specific text is in the template. The parties, court, title, attorney block and fee label come from the sample's frontmatter. No coordinate was measured off the exemplar. Line breaks appear only between the lines of the attorney block, court title, caption and signature block (inputs from frontmatter), never inside body text.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block, then the body.

| Field | Required | Feeds |
|---|---|---|
| `footer_title` | yes | footer title, 10 pt (CRC 2.110) |
| `fee_exempt` | no | list of lines for the upper-right fee label (SD LR 2.1.2(H)) |
| `attorney` | yes | lines from line 1 (CRC 2.111(1)). Quote any item containing `: ` (YAML) |
| `court` | yes | lines for the court title on line 8 |
| `caption.left` | yes | party lines; leading spaces are an indent |
| `caption.case_number` | no | right column (quote it: it contains `: `) |
| `caption.limited_civil` | no | `true` prints LIMITED CIVIL CASE (CRC 2.111(10)) |
| `caption.title` | yes | nature of the paper, bold |
| `caption.details` | no | type of action |
| `caption.judge`, `caption.dept` | no | CRC 2.111(7) |
| `caption.amount_demanded` | no | CRC 2.111(9) |
| `jury_demand` | no | centered caps line before the signature block |
| `signature` | yes | `dated`, `lines`, `signer`, `role` |

Body: a paragraph beginning with a number and a period escapes the period (`1\.`). Headings: `##` for centered caps headings (`## I. INTRODUCTION`).

## Sample

`usage/INPUT-calsuperct-sandiego-complaint-sweetwater.md`: transcribed from the exemplar. It covers the caption and attorney block (abridged to the lines that fit on lines 1-7: the Chief and Senior AAG lines are dropped), the introduction (¶¶ 1-9), the parties (¶¶ 10-16), ¶ 14 through subparagraph c)(v), and the signature block. It is an **excerpt**: the exemplar's remaining paragraphs (¶ 14 c)(vi) onward, causes of action, prayer) are not transcribed. Its signature block is the template's, placed after ¶ 16, not the exemplar's signature page.

Files and names: the shared tools name files `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (the brief's `<id>.pdf` and `<id>-overlay.pdf` names are not what `tools/render.sh` and `tools/overlay.sh` write). `<id>` is `sweetwater-complaint`; the input is `INPUT-calsuperct-sandiego-complaint-sweetwater.md`, which the tools strip to the id.

## Commands

```sh
export PATH="$HOME/tb/bin:$PATH"
sh tools/render.sh courts/ninth-circuit/california/state/superior-court/san-diego-county/complaint usage/INPUT-calsuperct-sandiego-complaint-sweetwater.md
sh tools/overlay.sh courts/ninth-circuit/california/state/superior-court/san-diego-county/complaint sweetwater-complaint
```

## Results

- **render=ok.** `usage/OUTPUT-calsuperct-sandiego-complaint-sweetwater.typst.pdf`, 10 pages, US Letter. typst exit 0, no warnings (the render tool fails on any). Fonts: vendored Liberation Serif only (`--ignore-system-fonts`).
- **overlay=ok.** `usage/OVERLAY-sweetwater-complaint.pdf` and `OVERLAY-sweetwater-complaint.txt`. Page map: ours p.1-p.7 match filed p.1-p.7 (word overlap 73-85%); ours p.8 matches filed p.9; ours p.9 matches filed p.10; ours p.10 (signature) matches filed p.39 at 30%, as expected for a signature page the excerpt does not reproduce. The overlay is a diagnostic, not a score.

### Gate 2 review: every page rendered at 60 dpi and looked at

| Page | Finding |
|---|---|
| 1 | Attorney block lines 1-7 (ends at line 7); fee label top right; court title lines 8-9; caption from line 11; footer clean. Pass. |
| 2 | Body text sits on the pleading numbers; double-spaced; first-line indent; heading "I. INTRODUCTION" centered caps. Pass. |
| 3 | Same grid. Pass. |
| 4 | Heading "II. PARTIES" centered. Pass. |
| 5 | Pass. |
| 6 | Pass. |
| 7 | Pass. |
| 8 | Pass. |
| 9 | Pass. The last body line is line 27; line 28 blank. |
| 10 | Fixed 2026-10-16: the template now keeps the last body paragraph (¶ 16) on the page with `Dated:` and the signature block; page 10 holds ¶ 16 and the signature. Re-rendered (10 pages, exit 0) and pages 8-10 viewed again. Pass. |

### Open tier-2 items

1. ~~Page 10: orphaned signature page~~: fixed 2026-10-16 (last paragraph kept with the signature).
2. The attorney block in the sample is abridged; the exemplar's full counsel list (Chief and Senior AAG lines) does not fit lines 1-7 at 12 pt. A real filer with a long counsel list would hit the template's panic. Not a rule breach; a limit of the grid.

## Known gaps

- **Limited civil amount.** CRC 2.111(9) as fetched says "$10,000". CCP § 85 has since set the limited civil ceiling at $35,000 for cases filed on or after 2024-01-01 (not verified in this run). The template only prints the amount line the filer supplies; the wording is the filer's.
- **E-filing.** SD LR 2.1.4.1(A) requires serving the SDSC General Order and form CIV-409 with a complaint; not produced here. Bookmarks for exhibits (2.1.4.1(C)) are not implemented: no exhibits are in the sample.
- **Cover sheet.** The civil case cover sheet (CM-010) and summons are separate forms, not generated.
- **Latex.** Not built for this doc type. **Docx:** see Engines.

## Searches

- `People v. Sun Healthcare complaint San Diego Superior Court`: no San Diego filing under that name. Sun Healthcare matters found were in other venues (San Mateo, 2001 and 2005).
- Found instead: the AG complaint in *People v. Sweetwater Care OpCo, LLC* (25CU033612N), used as the exemplar.
- San Diego Local Rules, Division II (effective 1/1/2026): the caption rules above. The fetched PDF was read locally with `pdftotext`.

## Engines

**typst** is the primary form (above). **docx** (`docx/`) and **latex** (not built) are secondary.

**docx** (`docx/`): `build-reference.sh` makes `docx/reference.docx` from pandoc's default (Liberation Serif 12 pt; body lines exact 24 pt; letter; top 1 in, bottom 46 pt, left 1.5 in, right 0.5 in; footer with a printed rule, a PAGE field and the title at 10 pt; line numbers restart each page; page borders as double left and single right rules). `calsuperct-sandiego-complaint.lua` builds the first page (attorney block in a 168 pt row, fee label, court title, caption table with its rules), the jury line and the signature block from the frontmatter. `render.sh` runs pandoc and fills the footer title from `footer_title`. Output: `usage/OUTPUT-calsuperct-sandiego-complaint-sweetwater.docx`.

- Matches typst: font and size, exact 24 pt grid, margins, attorney block height, court title on line 8, caption layout, footer, signature block.
- Differs (Word and LibreOffice paginate differently; judge on a render, not on this list):
  - Line numbers are Word section line numbering. They number text lines only, so the attorney block and caption on page 1 (table rows) carry no numbers, and a page with fewer than 28 text lines shows fewer numbers. Typst always shows 28.
  - Page borders run the height of the text area, not the full page height.
  - Footnotes are single-spaced (CRC 2.108(3) allows it); typst double-spaces them.
  - Caption indents come from the leading spaces in the frontmatter, read from the sample file.
  - The attorney row is "at least" 168 pt: a longer block grows the row instead of failing as typst does.
- BLOCKED (docx.pdf gates): LibreOffice is not installed on this box, so `usage/OUTPUT-sweetwater-complaint.docx.pdf` cannot be made and Gates 0-3 on the docx.pdf were not run. No docx page was viewed (`pages_reviewed=0`).
- BLOCKED by construction: CRC 2.108 consecutive numbering on every line of every page. Table rows (attorney block, caption) are not numbered by Word section numbering, so page 1 lines 1-10 cannot pass without a per-page numbered frame. Not verifiable here.
