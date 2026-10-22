# calsuperct-sandiego: complaint

Doc type `complaint` for the Superior Court of California, County of San Diego (alias `calsuperct-sandiego`). A civil complaint on pleading paper. Template: `typst/calsuperct-sandiego-complaint.typ`, entry `typst/main.typ`.

Status: **typst and docx** (latex is not built for this doc type). Both engines on the shared cross-engine layout model; the docx breaks every line and page where typst does (Gate 4 gated, `eval.yaml`). Exemplar found; render and overlay run; every page of the sample was rendered and looked at (see the review below). Open tier-2 items are listed below.

## Exemplar

`usage/FILED-EXAMPLE-complaint.pdf`: the Attorney General's complaint in *People v. Sweetwater Care OpCo, LLC, et al.*, Case No. 25CU033612N, filed in this court on 2025-06-23 (39 pages, text-based). Provenance in `usage/SOURCE.md`. The brief suggested a People v. Sun Healthcare complaint; no San Diego filing under that name was found (see Searches).

## Governing rules

Verified 2026-10-15 unless the row says otherwise. Quotations are from the fetched pages; re-check the Judicial Council and court pages before any filing.

| Rule | Requirement | Used for | Source |
|---|---|---|---|
| CRC 2.100-2.119 | Format of papers (scope) | whole document | https://www.courts.ca.gov/cms/rules/index/two/rule2_100 |
| CRC 2.104 | "Unless otherwise specified in these rules, all papers filed must be prepared using a font size not smaller than 12 points." (amended 2017-01-01) | `type-size = 12pt` | https://www.courts.ca.gov/cms/rules/index/two/rule2_104 |
| CRC 2.105 | "The font style must be essentially equivalent to Courier, Times New Roman, or Arial." (amended 2017-01-01) | **Times New Roman** (see Typeface) | https://www.courts.ca.gov/cms/rules/index/two/rule2_105 |
| CRC 2.107 | Left margin at least 1 inch; right margin at least ½ inch (verified 2026-10-13 by the sibling complaint; not re-fetched today) | `left-margin = 1.5in`, `right-margin = 0.5in` | https://www.courts.ca.gov/cms/rules/index/two/rule2_107 |
| CRC 2.108 | Lines one-and-one-half or double spaced, numbered consecutively at the left margin; at least 3 numbers per vertical inch (verified 2026-10-13; not re-fetched today) | 24 pt pitch, 28 numbers, double rule | https://www.courts.ca.gov/cms/rules/index/two/rule2_108 |
| CRC 2.109 | Pages numbered consecutively at the bottom, Arabic numerals (verified 2026-10-13; not re-fetched today) | footer page number | https://www.courts.ca.gov/cms/rules/index/two/rule2_109 |
| CRC 2.110 | Footer below the page number, divided from the page by a printed line; title of the paper in at least 10-point type (verified 2026-10-13; not re-fetched today) | footer, 10 pt title | https://www.courts.ca.gov/cms/rules/index/two/rule2_110 |
| CRC 2.111(1)-(2) | Attorney information from line 1, 1 inch from the top, left of center; clerk's space on the right of lines 1-7 (verified 2026-10-15, summarized) | attorney block from line 1, on lines 1-7 at least (grows to the next numbered line when longer); fee label in a 2.3 in column at the right | https://www.courts.ca.gov/cms/rules/index/two/rule2_111 |
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

CRC 2.105 names no single face; it names the **essential equivalent of Courier, Times New Roman, or Arial**. The template sets **Times New Roman** (the house standard; `font-family = ("Times New Roman", "Liberation Serif")`, the metric twin as the fallback) at 12 pt, and the docx names the same face through `{font}` in `docx/reference.xml`. `pdffonts` on both renders: Times New Roman (regular and bold) only.

## Layout

Cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box of its pitch with the baseline at 0.8 of it, the boxes touching, the spaces between blocks explicit; the docx sets the same pitches and spaces in twips.

- **Pleading grid.** 28 numbered lines of 24 pt (double spacing, CRC 2.108(1)) from 1 in; the numbers on the same 24 pt boxes as the body (the docx: a fixed 1-28 grid in a page-anchored frame of the footer, so every line of every page is numbered, the first page too).
- **Bottom margin.** 48 pt below line 28: the footer's rule 4 pt below the last line, the page number (12 pt line) and the title in 10 pt (CRC 2.109, 2.110). `eval.yaml` sets `margin_bottom_pt: 48` (CRC 2.107 sets no top or bottom margin).
- **Rules.** A double vertical rule left of the text and a single rule right of it (`lib/typst/pleading-paper.typ`; the docx: page borders, which run the height of the text area).
- **Single lines.** The attorney block, the caption and the signature block are 12 pt lines, each group starting 9.6 pt below a numbered line's top (`single-drop`), so every second single line stands level with a line number.
- **First page.** Attorney block from line 1 on lines 1-7 at least (CRC 2.111(1), (2)); a longer block pushes the court title to the next numbered line. The fee label (when given) sits right-aligned in a 2.3 in column at the top right (SD LR 2.1.2(H)). Court title centered and bold, one numbered line each, from line 8. Caption a numbered line below: left column 3.6 in ruled at its right and foot; right column the case number, the title (bold), the details, and the optional judge/department and amount lines, a single line apart.
- **Body.** A numbered line below the caption. Each chunk of the markdown (text between blank lines) is a paragraph with a 0.5 in first-line indent, or a heading on one numbered line (levels 1 and 2 centered bold capitals, 3 bold, 4 bold italic) kept with the chunk after it.
- **Signature.** A numbered line below the text: "Dated:" at the left; the signature lines at 3.1 in; a numbered line, "By:" and a 2.7 in signature line; the signer's name (bold capitals) and role 0.3 in further in. The last body chunk stays on the page with the signature block, which never splits.

No case-specific text is in the template. The parties, court, title, attorney block and fee label come from the sample's frontmatter. No coordinate was measured off the exemplar. Each frontmatter list item is its own line (attorney block, court title, caption, signature lines); body text is never broken by the template.

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

`usage/INPUT-complaint.md`: transcribed from the exemplar. It covers the caption and attorney block (abridged to the lines that fit on lines 1-7: the Chief and Senior AAG lines are dropped), the introduction (¶¶ 1-9), the parties (¶¶ 10-16), ¶ 14 through subparagraph c)(v), and the signature block. It is an **excerpt**: the exemplar's remaining paragraphs (¶ 14 c)(vi) onward, causes of action, prayer) are not transcribed. Its signature block is the template's, placed after ¶ 16, not the exemplar's signature page.

Files and names: the shared tools name files `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (the brief's `<id>.pdf` and `<id>-overlay.pdf` names are not what `tools/render.sh` and `tools/overlay.sh` write). `<id>` is `sweetwater-complaint`; the input is `INPUT-complaint.md`, which the tools strip to the id.

## Commands

```sh
export PATH="$HOME/tb/bin:$PATH"
sh tools/render.sh courts/ninth-circuit/california/state/superior-court/san-diego-county/complaint usage/INPUT-complaint.md
sh tools/overlay.sh courts/ninth-circuit/california/state/superior-court/san-diego-county/complaint sweetwater-complaint
```

## Results

- **render=ok.** `usage/OUTPUT-complaint.typst.pdf`, 10 pages, US Letter, typst exit 0, no warnings (the render tool fails on any); `usage/OUTPUT-complaint.docx` and `.docx.pdf` (fb render, LibreOffice), the same 10 pages.
- **check.** `sh tools/check.sh <dir>`: 8 checks passed, 0 failed; `--engine docx`: 12 checks passed, 0 failed, XENG-001..003 PASS (326/326 lines alike, 10 = 10 pages).
- **overlay** (2026-10-16, before the cross-engine port): page map ours p.1-p.7 to filed p.1-p.7; the overlay is a diagnostic, not a score.

### Gate 2 review: every page rendered at 50 dpi and looked at, typst and docx side by side (fb-595.68.37)

| Page | Finding |
|---|---|
| 1 | Attorney block lines 1-6 single spaced, every second line level with a number; fee label top right; court title lines 8-9; caption from line 11, party column ruled at right and foot; footer rule, page number, title. Same on docx. Pass. |
| 2 | Body text on the pleading numbers; double-spaced; first-line indent; heading "I. INTRODUCTION" centered bold on line 6. Same on docx. Pass. |
| 3-9 | Same grid, every line on a number; "II. PARTIES" centered. Same breaks on docx. Pass. |
| 10 | ¶ 16 kept on the page with `Dated:` and the signature block. Same on docx. Pass. |

The docx's pleading rules run the height of the text area (page borders), typst's the full page: accepted (tier 2, both read as pleading paper).

### Open tier-2 items

1. The attorney block in the sample is abridged (the exemplar's Chief and Senior AAG lines are dropped). A longer block now pushes the court title down a numbered line instead of failing.

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

**typst** is the primary form (above). **docx** (`docx/`) follows it line for line; **latex** is not built.

**docx** (`docx/`, no shell): `reference.xml` is the cross-engine style recipe (`base="xengine"`) in `{font}` (the typst face) at 12 pt, body 480 twips, single 240 twips. `calsuperct-sandiego-complaint.lua` writes every paragraph with exact spacing in the typst pitches: the first page (attorney block and fee label in a row of exact height, court title, caption table with its rules), the body read chunk by chunk from the sample as typst reads it, the jury line and the signature block (all frontmatter read as written, `$FORMBOOK_META`, so a caption line's leading spaces survive), the footer (the 28 line numbers in a page-anchored frame, a rule, the PAGE field, the title at 10 pt; `$FORMBOOK_FOOTERS`) and the last section (letter, the typst margins, the pleading rules as page borders; `$FORMBOOK_FINAL`). `fb render` builds the reference document, runs pandoc and LibreOffice and packs the archive. Output: `usage/OUTPUT-complaint.docx`, `usage/OUTPUT-complaint.docx.pdf`.

- Gate 4: `params.cross_engine: gate`; XENG-001..003 pass.
- Differs (tier 2, accepted): the pleading rules run the height of the text area, not the full page. Word may paginate differently from LibreOffice; the checked PDF is LibreOffice's.
