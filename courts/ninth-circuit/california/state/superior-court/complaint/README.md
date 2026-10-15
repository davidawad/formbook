# calsuperct: complaint

Doc type `complaint` for the California Superior Courts (court alias `calsuperct`). A civil complaint on pleading paper, filed in a superior court. Template: `typst/calsuperct-complaint.typ`, entry `typst/main.typ`.

Status: **typst only**. latex and docx are not built for this doc type. The first-page layout, the pleading grid and the caption are done; the tier-2 review is recorded below and has open items.

## Governing rules

Verified 2026-10-13 against the Judicial Council rule pages. Quotations are from those pages as shown by the fetch; the rule text should be re-checked against the Judicial Council pages before any filing.

| Rule | Requirement | Used for | Source |
|---|---|---|---|
| CRC 2.100-2.119 | Format of papers (scope) | whole document | https://www.courts.ca.gov/cms/rules/index/two/rule2_100 |
| CRC 2.103 | Papers 8½ × 11 inches; opaque white or unbleached, 20 lb (not e-filed) | page size (`us-letter`) | https://www.courts.ca.gov/cms/rules/index/two/rule2_103 |
| CRC 2.104 | Font size not smaller than 12 points | `type-size = 12pt` | https://www.courts.ca.gov/cms/rules/index/two/rule2_104 |
| CRC 2.105 | Font style essentially equivalent to Courier, Times New Roman, or Arial | Times New Roman named; substitute `Liberation Serif` (vendored, metric-compatible; `docs/FONTS.md`). Typeface row: face required → vendored substitute → metric-compatible. See Known gaps 1. | https://www.courts.ca.gov/cms/rules/index/two/rule2_105 |
| CRC 2.107 | Left margin at least 1 inch; right margin at least ½ inch | `left-margin = 1.5in`, `right-margin = 0.5in` | https://www.courts.ca.gov/cms/rules/index/two/rule2_107 |
| CRC 2.108 | Lines one-and-one-half or double spaced and numbered consecutively; numbers at the left margin, separated from the text by a space of at least ⅕ inch or a single or double vertical line; at least 3 numbers per vertical inch | double spacing (24 pt pitch), 28 numbers, double rule | https://www.courts.ca.gov/cms/rules/index/two/rule2_108 |
| CRC 2.109 | Pages numbered consecutively at the bottom, Arabic numerals only, starting with the first page | footer page number, no roman numerals | https://www.courts.ca.gov/cms/rules/index/two/rule2_109 |
| CRC 2.110 | Footer below the page number, divided from the page by a printed line; the title of the paper in at least 10-point type | footer | https://www.courts.ca.gov/cms/rules/index/two/rule2_110 |
| CRC 2.111(1) | Attorney information starting at line 1, 1 inch from the top, left of center | attorney block, lines 1-7 | https://www.courts.ca.gov/cms/rules/index/two/rule2_111 |
| CRC 2.111(2) | Blank space for the clerk, first 2 inches between lines 1 and 7, right of center | left clear | same |
| CRC 2.111(3) | Title of the court on line 8, at or below 3⅓ inches from the top | court title on line 8 (240 pt = 3⅓ in) | same |
| CRC 2.111(4)-(6) | Case title below the court title on the left; case number to the right; nature of the paper below the case number (complaints also state the type of action) | caption | same |
| CRC 2.111(7) | Judge and department below the nature of the paper, if assigned | not used in a complaint (no judge assigned) | same |
| CRC 2.111(9) | Limited civil complaint: statement of the amount demanded ("Amount demanded exceeds …" / "does not exceed …") | optional `amount_demanded` in the caption; wording comes from the filer | same. The fetched text reads "$10,000". CCP § 85 has set the limited civil ceiling at $35,000 for cases filed on or after 2024-01-01 (see the Known gaps). |
| CRC 2.111(10) | "Limited Civil Case" in the caption of a limited civil case | not implemented | same |
| CRC 2.112 | Each separately stated cause of action states its number, its nature, the party asserting it, and the party it is directed against | `First Cause of Action` / `[By Plaintiff against All Defendants]` headings in the sample | https://www.courts.ca.gov/cms/rules/index/two/rule2_112 |

The caption and the first-page rules come from CRC 2.111. The complaint's substantive content (CCP §§ 425.10 et seq.) is not checked by this template.

## Layout

- **Pleading grid.** Lines are 24 pt apart (double spacing). Each text line is a 1 em box (`top-edge: 0.7em`, `bottom-edge: -0.3em`), so the leading sets the pitch: 12 pt is single spacing, 24 pt is double spacing. The 28 line numbers in the background use the same box settings, so each number's baseline is the baseline of its text line. Checked with `pdftotext -bbox`: line 1 is at y = 68.3 pt, line 28 at y = 716.3 pt, and 28 body lines fit on each page.
- **Bottom margin.** 46 pt. 28 lines (672 pt) fit and 29 lines (696 pt) do not. The footer sits 14 pt above the page edge.
- **Rules.** A double vertical rule at 1.22-1.25 in, between the numbers and the text. A single rule at 8.1 in, outside the right margin.
- **First page.** Attorney block in a fixed 168 pt box (lines 1-7); the template panics if the block is taller. Court title in a 48 pt box (lines 8-9). Caption starts on line 11. The caption's left column is 3.6 in, with a right rule and a bottom rule. The right column holds the case number, the title (bold), the optional details line and the optional amount-demanded line.
- **Body.** Paragraphs first-line-indent 0.5 in, including the first paragraph after a heading. Headings are centered and bold (levels 1 and 2, uppercase), or bold left (level 3), or bold italic left (level 4). Footnotes are 12 pt, single-spaced.
- **Signature.** "Dated:" at the left; the signature block at 3.1 in; the "By:" line with the signer's name and role below it.

No case-specific text is in the template; the parties, the court, the title and the attorney block come from the frontmatter of the sample. No coordinate was measured off the exemplar. The template inserts line breaks only between the lines of the attorney block, court title, caption and signature block, never inside body text.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block, then the body.

| Field | Required | Feeds |
|---|---|---|
| `footer_title` | yes | Footer title, at least 10 pt (CRC 2.110) |
| `attorney` | yes | List of lines, starting at line 1 (CRC 2.111(1)). Inline markdown is allowed. |
| `court` | yes | List of lines for the court title on line 8 (CRC 2.111(3)) |
| `caption.left` | yes | List of lines for the parties. Leading spaces become an indent (0.25 em per space). |
| `caption.case_number` | no | Case number, right column (CRC 2.111(5)) |
| `caption.title` | yes | Nature of the paper, bold, right column (CRC 2.111(6)) |
| `caption.details` | no | Type of action, right column |
| `caption.amount_demanded` | no | Amount-demanded statement (CRC 2.111(9)) |
| `jury_demand` | no | A centered caps line before the signature block |
| `signature` | yes | `dated`, `lines` (printed at the right, above the signature line), `signer` (bold caps), `role` |

Body: a paragraph whose first characters are a number followed by a period must escape the period (`1\.`), so the number is kept as typed. Headings: `#` for level 1 and `##` for level 2 (both centered), `###` for level 3, `####` for level 4. Footnotes: `[^key]` and `[^key]: text`.

## Build and check

From the repo root:

```sh
export PATH=/work/artifacts/bin:$PATH   # only if typst, poppler and magick are not installed system-wide
sh tools/render.sh courts/ninth-circuit/california/state/superior-court/complaint samples/INPUT-sweetwater-complaint.md
sh tools/overlay.sh courts/ninth-circuit/california/state/superior-court/complaint sweetwater-complaint
```

The render fails on any typst warning. The font is the vendored `Liberation Serif` (`fonts/liberation-serif`), the substitute for Times New Roman; `--ignore-system-fonts` is used, so nothing falls back to a system font. `pdffonts` on the output lists `LiberationSerif` and `LiberationSerif-Bold`, both embedded. The page count is 5 with both EB Garamond and Liberation Serif (checked before and after the switch).

## Samples and exemplar

- `samples/INPUT-sweetwater-complaint.md`: transcribed from the exemplar: caption, first page, the introduction (paragraphs 1-3), the first and second causes of action (paragraphs 75-80, abridged), the prayer (items 1-12) and the signature. Paragraphs 4-74 and the rest of the causes of action are not transcribed. Footnote 10 of the exemplar is transcribed as a footnote.
- `samples/OUTPUT-sweetwater-complaint.pdf`: the render, 5 pages.
- `samples/OVERLAY-sweetwater-complaint.pdf` and `-overlay.txt`: the red/blue overlay against `exemplars/FILED-EXAMPLE-people-v-sweetwater-care-25CU033612N-complaint.pdf`. The page map from `overlay.sh`:

  ```
  ours p.1  filed p.1   word-overlap 72.1%
  ours p.2  filed p.2   word-overlap 87.5%
  ours p.3  filed p.36  word-overlap 56.7%
  ours p.4  filed p.38  word-overlap 62.8%
  ours p.5  filed p.39  word-overlap 65.4%
  ```

  The map is a text-similarity pairing, not a score. Pages 3-5 pair with the exemplar's later pages because the sample is an excerpt. The overlay is a diagnostic (tier 3). The exemplar PDF is not stored in the repo (`exemplars/` holds `SOURCE.md` only); this overlay was run against a copy fetched from the URL in `exemplars/SOURCE.md` on 2026-10-15, kept outside the repo.

- Exemplar and sources: `exemplars/SOURCE.md`.

## Gate 2: page review (sample `sweetwater-complaint`, 5 pages, `pdftoppm -r 70`, Liberation Serif)

Each page of the current PDF was rendered and viewed. Compared with: the exemplar's page 1 for the caption, page 2 for the body, pages 37-39 for the causes of action, the prayer and the signature.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Attorney block on lines 1-7; court title on lines 8-9; caption begins on line 11; the parties' list fits on the page and "Defendants." is on page 1. Left rule clear of the text. | PASS |
| 2 | exemplar p.2 | Body text on the grid; the first paragraph after the heading is indented (fixed by `first-line-indent: (all: true)`); the centered "I. INTRODUCTION" heading is bold caps. | PASS |
| 3 | exemplar p.36-37 | Both cause headings are centered, bold caps, and set on the grid. Paragraph 79's footnote sits at the foot of the page, and the body above it stays on the grid. | PASS |
| 4 | exemplar p.38 | Prayer items 1-7 are on the grid, each item first-line-indented; the page ends at item 7. | PASS |
| 5 | exemplar p.39 | Prayer items 8-12, then "Dated", "Respectfully Submitted", "By:" with the signer and role, on the page. With Liberation Serif the signature no longer stands alone (the earlier EB Garamond render left it alone on page 5). | PASS |

Every page passes. CRC 2.111 is met on every page.

## Known gaps

1. **Font style (CRC 2.105): Times New Roman, substituted.** CRC 2.105 allows Courier, Times New Roman, or Arial. The template uses Times New Roman's vendored substitute, `Liberation Serif` (`fonts/liberation-serif`, SIL OFL 1.1, metric-compatible; `docs/FONTS.md`), set in `typst/calsuperct-complaint.typ` (`font-family`). Times New Roman was chosen because it is a proportional serif that keeps the template's serif look; the rule allows Courier or Arial equally, and switching to either is a one-line change. EB Garamond remains in `fonts/` for other courts; it is not used here.
2. **Amount demanded (CRC 2.111(9)).** The fetched rule text reads "$10,000", but CCP § 85 (as amended by Stats. 2023, ch. 861) has set the limited civil ceiling at $35,000 for cases filed on or after 2024-01-01. The template takes the wording from the frontmatter and does not print a threshold; the sample has no `amount_demanded`.
3. **"Limited Civil Case" (CRC 2.111(10))** is not printed; the template has no field for it.
4. **"EXEMPT FROM FEES" line** (the exemplar's right-hand note on line 1) is not implemented.
5. **Page 5 signature** was an orphan under EB Garamond; under Liberation Serif it is on the page with prayer items 8-12 (see Gate 2).
6. **Exemplars: one.** The brief asks for one exemplar per doc type. The EFF complaint options were not searched for in depth; a second filer's complaint would let tier-2 choices be judged against two filers.
7. **Verification, proof of service and summons** are not generated. Only the complaint body and caption are covered.
8. **Footnotes** shift the body above them; the body lines below a footnote stay on the grid, but a footnote that splits across pages is not checked.
9. **Tier-1 checks** are not in `checks.yaml` form for this doc type (the brief did not ask for them). The only mechanical guard is the attorney-block height panic.

[Court folder](../README.md) | [Formbook index](../../../../../../README.md)

## Engines

### docx (built, not rendered here)

Built by `docx/make-reference.sh` (writes `docx/reference.docx`, run once) and the Lua filter `docx/calsuperct.lua`. `tools/render.sh --engine docx` writes `samples/OUTPUT-<id>.docx`; the LibreOffice PDF step is BLOCKED on this box (see below).

What the docx sets (in `styles.xml`, `sectPr`, `footer1.xml`, or the filter). Set in styles.xml/sectPr, not rendered:

- Font: Liberation Serif 12 pt in every style; text black.
- Body: exact 24 pt line spacing, no paragraph spacing, 0.5 in first-line indent. Headings: exact 24 pt, bold; levels 1-2 centered; level 4 bold italic. Footnote Text single-spaced. Block quotes 0.5 in both sides, exact 12 pt.
- Page: US Letter; top 1 in, bottom 48 pt (28 lines of 24 pt fit), left 1.5 in, right 0.5 in; footer 14.4 pt from the bottom edge.
- Pleading rules: page borders (double rule 18 pt left of the text, single rule 7 pt right of it). Word line numbering: every line of body text, restarted each page, 0.45 in left of the text.
- Footer: a printed rule, the PAGE field at 12 pt, then the SUBJECT field at 10 pt. The filter copies `footer_title` into the document subject, so no case text is in the template.
- First page (filter): attorney block single-spaced from line 1; court title at line 8 (space computed from the number of attorney lines); caption as a borderless table, 3.6 in left cell with bottom and right rules, 2.9 in right cell. Leading spaces in `caption.left` are read from the sample's raw frontmatter (Pandoc drops them) and become 60 twips per space, as in the typst template.
- Signature block at 3.1 in; the "By:" line is a tab with an underscore leader.

Differs from typst:

- Line numbers are Word's, not drawn: Word numbers the body paragraphs (including the attorney block lines) and skips the caption table, so 1-28 may not line up with the typst grid. Typst draws 28 fixed numbers in the margin.
- Rules are page borders spanning the text area, not the full-height drawn lines of the typst template.
- Caption cell padding and the gaps between caption groups are approximate.
- The footer subject depends on the application updating fields (SUBJECT).
- Pagination follows Word or LibreOffice, not typst.

BLOCKED:

- docx.pdf gates 0-3: BLOCKED. soffice is not installed on the build box, so no LibreOffice PDF exists and no docx page was viewed (pages_reviewed = 0 for docx).
- Pleading line numbers on 28 lines per page (CRC 2.108): BLOCKED, as above, until a LibreOffice render confirms the numbering.
- Footer SUBJECT field (CRC 2.110 title on every page): BLOCKED until a LibreOffice render shows the title.
