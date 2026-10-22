# calsuperct: complaint

Doc type `complaint` for the California Superior Courts (court alias `calsuperct`). A civil complaint on pleading paper, filed in a superior court. Template: `typst/calsuperct-complaint.typ`, entry `typst/main.typ`.

Status: **typst and docx** (no latex). Both engines on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): the docx breaks every line and page where typst does (`eval.yaml`: `cross_engine: gate`).

## Governing rules

Verified 2026-10-13 against the Judicial Council rule pages. Quotations are from those pages as shown by the fetch; the rule text should be re-checked against the Judicial Council pages before any filing.

| Rule | Requirement | Used for | Source |
|---|---|---|---|
| CRC 2.100-2.119 | Format of papers (scope) | whole document | https://www.courts.ca.gov/cms/rules/index/two/rule2_100 |
| CRC 2.103 | Papers 8½ × 11 inches; opaque white or unbleached, 20 lb (not e-filed) | page size (`us-letter`) | https://www.courts.ca.gov/cms/rules/index/two/rule2_103 |
| CRC 2.104 | Font size not smaller than 12 points | `type-size = 12pt` | https://www.courts.ca.gov/cms/rules/index/two/rule2_104 |
| CRC 2.105 | Font style essentially equivalent to Courier, Times New Roman, or Arial | Times New Roman (typst: `("Times New Roman", "Liberation Serif")`, the vendored metric twin; the docx names Times New Roman through `{font}` in `docx/reference.xml`) | https://www.courts.ca.gov/cms/rules/index/two/rule2_105 |
| CRC 2.107 | Left margin at least 1 inch; right margin at least ½ inch | `left-margin = 1.5in`, `right-margin = 0.5in` | https://www.courts.ca.gov/cms/rules/index/two/rule2_107 |
| CRC 2.108 | Lines one-and-one-half or double spaced and numbered consecutively; numbers at the left margin, separated from the text by a space of at least ⅕ inch or a single or double vertical line; at least 3 numbers per vertical inch | double spacing (24 pt pitch), 28 numbers, double rule | https://www.courts.ca.gov/cms/rules/index/two/rule2_108 |
| CRC 2.109 | Pages numbered consecutively at the bottom, Arabic numerals only, starting with the first page | footer page number, no roman numerals | https://www.courts.ca.gov/cms/rules/index/two/rule2_109 |
| CRC 2.110 | Footer below the page number, divided from the page by a printed line; the title of the paper in at least 10-point type | footer | https://www.courts.ca.gov/cms/rules/index/two/rule2_110 |
| CRC 2.111(1) | Attorney information starting at line 1, 1 inch from the top, left of center | attorney block from line 1, each line left of center (the template stops on a line that does not fit) | https://www.courts.ca.gov/cms/rules/index/two/rule2_111 |
| CRC 2.111(2) | Blank space for the clerk, first 2 inches between lines 1 and 7, right of center | left clear | same |
| CRC 2.111(3) | Title of the court on line 8, at or below 3⅓ inches from the top | court title on line 8 (240 pt = 3⅓ in), or the first numbered line below a longer attorney block | same |
| CRC 2.111(4)-(6) | Case title below the court title on the left; case number to the right; nature of the paper below the case number (complaints also state the type of action) | caption | same |
| CRC 2.111(7) | Judge and department below the nature of the paper, if assigned | not used in a complaint (no judge assigned) | same |
| CRC 2.111(9) | Limited civil complaint: statement of the amount demanded ("Amount demanded exceeds …" / "does not exceed …") | optional `amount_demanded` in the caption; wording comes from the filer | same. The fetched text reads "$10,000". CCP § 85 has set the limited civil ceiling at $35,000 for cases filed on or after 2024-01-01 (see the Known gaps). |
| CRC 2.111(10) | "Limited Civil Case" in the caption of a limited civil case | not implemented | same |
| CRC 2.112 | Each separately stated cause of action states its number, its nature, the party asserting it, and the party it is directed against | `First Cause of Action` / `[By Plaintiff against All Defendants]` headings in the sample | https://www.courts.ca.gov/cms/rules/index/two/rule2_112 |

The caption and the first-page rules come from CRC 2.111. The complaint's substantive content (CCP §§ 425.10 et seq.) is not checked by this template.

## Layout

Every number is in `typst/calsuperct-complaint.typ` (parameters at the top) and, in twips, in `docx/calsuperct.lua`.

- **Pleading grid (CRC 2.108).** 28 numbered lines of 24 pt from 1 in below the top edge (double spacing); single-spaced lines (attorney block, caption, signature, footnotes; CRC 2.108(3)) are 12 pt, two to a numbered line, each group starting 9.6 pt below a numbered line's top so every other single line stands level with a number. The bottom margin is the 48 pt left under the 28th line. Every line is a box of its pitch with the baseline at 0.8 of it (the cross-engine model).
- **Numbers and rules.** The numbers 1-28 right-aligned 1 in from the page edge on the body's line boxes (typst: `lib/typst/pleading-paper.typ`; docx: a page-anchored frame in the footer); a double rule left of the text and a single rule right of it (docx: page borders).
- **Footer (CRC 2.109, 2.110).** 2 pt below the 28th line: the page number (12 pt), a printed line, the paper's title in capitals at 10 pt. In the docx both sit in a page-anchored frame (in the footer's flow, LibreOffice grows the footer into the 28th line), the line an underlined tab (LibreOffice drops a framed paragraph's border).
- **First page (CRC 2.111).** The attorney block from line 1, one line per item, left of center (the template stops on an item that does not fit, so the clerk's space stays clear); the court title, bold and centered, on line 8 or on the first numbered line after a longer block; one numbered line below it the caption: the case title in the left half, ruled at its right and foot (it may run over a page end, as the exemplar's does); in the right column the case number, the nature of the paper (bold), the details and the amount demanded, a numbered line apart. The body starts on the first numbered line at least 12 pt below the caption's foot (typst measures where the caption ended; the docx filter counts the party column's lines with the vendored face's advances, `docx/lib/measure.lua`).
- **Body.** Each blank-line-separated chunk is a heading or a paragraph (the author numbers the allegations, `1\.`). Paragraphs indent their first line 0.5 in. Headings sit on one numbered line with no space of their own, kept with the text: levels 1 and 2 centered bold capitals, level 3 bold, level 4 bold italic. Footnotes at 12 pt in 12 pt lines, 6 pt apart, under a 2 in rule; a paragraph that anchors one has no widow or orphan rule on either engine (docx: Body Text Note).
- **Signature.** A numbered line below the last paragraph, kept on one page with it: "Dated:" at the margin, the signature lines from 3.1 in, a numbered line lower "By:" and a 2.7 in signature line, the signer (bold capitals) and role 0.3 in further in.

No case-specific text, no coordinate measured off the exemplar, no forced line break: the attorney lines, the court lines and the caption lines are the frontmatter's own list items.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block, then the body.

| Field | Required | Feeds |
|---|---|---|
| `footer_title` | yes | Footer title, at least 10 pt (CRC 2.110) |
| `attorney` | yes | List of lines, starting at line 1 (CRC 2.111(1)); each must fit left of center (split a long one). Inline markdown is allowed. |
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
sh tools/check.sh courts/ninth-circuit/california/state/superior-court/complaint                 # typst
sh tools/check.sh courts/ninth-circuit/california/state/superior-court/complaint --engine docx   # docx, XENG gated
just overlay courts/ninth-circuit/california/state/superior-court/complaint
```

Typst renders with the vendored fonts only (`--ignore-system-fonts`; any warning fails): Liberation Serif, the metric twin of Times New Roman. The docx names Times New Roman; its LibreOffice PDF embeds it.

## Samples and exemplar

- `usage/INPUT-complaint.md`: transcribed from the exemplar: the attorney block (line for line as filed), the caption, the introduction (paragraphs 1-3), the first and second causes of action (paragraphs 75-80, abridged), the prayer (items 1-12) and the signature. Footnote 10 of the exemplar is transcribed as a footnote.
- `usage/OUTPUT-complaint.typst.pdf`, `usage/OUTPUT-complaint.docx`, `usage/OUTPUT-complaint.docx.pdf`: 5 pages each.
- Exemplar and source: `usage/FILED-EXAMPLE-complaint.pdf`, `usage/SOURCE.md` (Office of the Attorney General, 2025).

## Gate 2: page review (typst and docx, 5 pages each, `pdftoppm -r 60`)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Attorney block lines 1-10, left of center, as the exemplar's; court title on line 11 (the exemplar's); caption from line 14, the party column ruled at its right and foot, running over to page 2 as the exemplar's does. docx alike line for line. | PASS |
| 2 | exemplar p.2 | Caption's last lines and rule, the body from line 4 on the numbered lines, "I. INTRODUCTION" on its line with no space around it (as the exemplar). docx alike. | PASS |
| 3 | exemplar p.36-37 | Cause headings, "[By Plaintiff against All Defendants]", paragraphs 75-79; footnote under a 2 in rule at the foot. docx alike. | PASS |
| 4 | exemplar p.38 | Paragraph 80, the prayer heading, items 1-7. docx alike. | PASS |
| 5 | exemplar p.39 | Items 8-12, then the signature block a numbered line below. docx alike. | PASS |
| all | | docx: the pleading rules are page borders, which LibreOffice draws from the top margin to the footer, not the full page height as typst draws them. | ACCEPTED |

## Known gaps

1. **Amount demanded (CRC 2.111(9)).** The fetched rule text reads "$10,000", but CCP § 85 (as amended by Stats. 2023, ch. 861) has set the limited civil ceiling at $35,000 for cases filed on or after 2024-01-01. The template takes the wording from the frontmatter and does not print a threshold; the sample has no `amount_demanded`.
2. **"Limited Civil Case" (CRC 2.111(10))** is not printed; the template has no field for it.
3. **"EXEMPT FROM FEES" line** (the exemplar's right-hand note on line 1) is not implemented.
4. **Exemplars: one.** A second filer's complaint would let tier-2 choices be judged against two filers.
5. **Verification, proof of service and summons** are not generated.
6. **docx caption line count.** The filter counts the party column's lines from the face's advances, breaking at spaces only; a party name that typst breaks elsewhere (inside a long word) would put the body off the numbered lines in the docx (XENG would show it).

## Engines

- **typst** (primary): `typst/main.typ`, `typst/calsuperct-complaint.typ`.
- **docx**: `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face) and `docx/calsuperct.lua` (every paragraph, the caption table, the signature, the footers via `FORMBOOK_FOOTERS` and the page via `FORMBOOK_FINAL`), `docx/lib/measure.lua`. `fb render` builds the reference document and the archive; no shell script. Gated against typst (XENG-001..003).
- **latex**: not built for this doc type.

[Court folder](../README.md) | [Formbook index](../../../../../../README.md)
