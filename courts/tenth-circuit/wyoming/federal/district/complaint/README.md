# District of Wyoming (wyd): complaint

- Court: `wyd`, United States District Court for the District of Wyoming (`courts/tenth-circuit/wyoming/federal/district/`)
- Doc type: `complaint`. An original complaint with numbered paragraphs, a caption and the attorney information block; no separate certificate (see Governing rules).
- Exemplar: `usage/FILED-EXAMPLE-complaint.pdf` (*On Q Financial, LLC v. Jorns & Associates LLC and Justin Ward Jorns*, No. 1:26-cv-00277, filed 2026-09-28, 17 pages; provenance in `usage/SOURCE.md`). One filer (plaintiff's counsel). This is one exemplar, not the tier-2 pair of 2 or 3 from different filers; see Known gaps.
- Sample: `usage/INPUT-complaint.md` (transcription of the complaint from the caption through the prayer for relief, with the signature block in the frontmatter).
- Status: typst and docx on the shared cross-engine layout model (fb-595.68.33): Times New Roman 12 pt on both engines, the docx breaks every line and page where the typst render does (XENG-001..003 PASS, `params.cross_engine: gate` in `eval.yaml`); `sh tools/check.sh <this folder>` typst 9 and `--engine docx` 13 checks passed, 0 failed. Every page of both renders viewed (11 + 11). `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `wyd-complaint`. |
| `typst/wyd-complaint.typ` | Template. Parameter block at the top: Times New Roman 12 pt, exact 24 pt double pitch (`pitch-body`) and 13.8 pt single lines (`pitch-single`), one-inch margins, 8½ × 11; `lib/typst/xengine.typ` sets the shared layout model. |
| `docx/reference.xml` | The Word styles, declarative: the cross-engine recipe (`base="xengine"`) in the typst face (`{font}`), 12 pt, 480/276 twip line boxes, the page-number footer. `fb render` builds the reference document from it. |
| `docx/wyd.lua` | Builds the whole document as Word paragraphs from the frontmatter (as written, `$FORMBOOK_META`) and the sample body read chunk by chunk, as the typst template reads it; `lib/docx/xengine.lua` for the runs and paragraph spacing. |
| `eval.yaml` | `params.cross_engine: gate`. |
| `usage/INPUT-complaint.md` | Markdown contract sample (frontmatter: caption, attorney block, date, signature; body: paragraphs, headings, numbered allegations, prayer). |
| `usage/OUTPUT-complaint.typst.pdf`, `OUTPUT-complaint.docx`, `OUTPUT-complaint.docx.pdf` | `sh tools/check.sh <this folder>` and `--engine docx` (11 pages each, no typst warnings). |
| `usage/FILED-EXAMPLE-complaint.pdf`, `usage/SOURCE.md` | The filed exemplar and where it came from. |

Overlays are not committed: `just overlay <this folder>` writes `.overlay/<this folder>/OVERLAY-complaint.pdf` and `.txt`.

## Governing rules

Primary sources, read 2026-10-14:

- D. Wyo. Local Civil Rule 10.1(a) (filing format) and 10.1(b) (caption and attorney information block): <https://www.wyd.uscourts.gov/sites/wyd/files/local_rules/localrules-cv22.pdf>, the Civil Local Rules, January 2022 edition, printed p. 12 (text extracted with `pdftotext`). The court's current-rules web page returned 404 on the day of review, so this January 2022 edition is the newest text retrieved; the May 2017 edition at `localrules-cv.pdf` is superseded. Rule 10.1(a): "typed, double spaced, single-sided, on eight and one-half (8½) x eleven (11) inch paper ... with a one (1) inch margin on all sides ... not less than 12 point font." Rule 10.1(b): caption per Fed. R. Civ. P. 10(a) plus the attorney information block (name, bar number, firm, address, telephone, email).
- Fed. R. Civ. P. 10(a) (caption: court name, title, file number, Rule 7(a) designation; the complaint's title names all the parties) and 10(b) (numbered paragraphs, each limited as far as practicable to a single set of circumstances): <https://www.law.cornell.edu/rules/frcp/rule_10> (fetched 2026-10-14; the page shows the amendment date 2007, no current-as-of date).
- Fed. R. Civ. P. 5(d)(1)(B): "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system" (<https://www.law.cornell.edu/rules/frcp/rule_5>, fetched 2026-10-14). The complaint template has no certificate of service, so nothing is lost by this rule.

Where the rules leave the layout open (the caption's column widths, the position of the signature block), the template follows the filed exemplar (the party designations indented 1 in, the signature block from 2.5 in).

## Typeface

| Face required by the rule | Rule (primary source) | Vendored face | Fit |
|---|---|---|---|
| None named. LR 10.1(a) requires only "not less than 12 point font" | D. Wyo. LR 10.1(a), January 2022 edition (see Governing rules) | Times New Roman (`fonts/`), declared `("Times New Roman", "Liberation Serif")` | n/a |

The rule names no face, so the template sets Times New Roman 12 pt, the house standard (`docs/FONTS.md`), on both engines; `data/exemplar-fonts.json` carries `template_face: Times New Roman` for this folder. The typst template had set TeX Gyre Pagella (the audited exemplar's face is one filer's style, tier 3) and the docx EB Garamond 13 pt (DEF-FONT-002 failed on the docx).

## Layout (typst and docx alike)

- Shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; `docs/EVAL-LOOP.md`, "Cross-engine gate"): first-fit ragged-right lines, no kerning, ligatures or hyphenation, every line an exact box of its pitch. Word twips = 20 × the typst points.
- Double spacing (LR 10.1(a)): body paragraphs, headings and lettered items in exact 24 pt line boxes, no extra space between paragraphs. Single-spaced 13.8 pt lines for the attorney block, the court name, the caption, the title and the signature block.
- Attorney information block (LR 10.1(b)) at the top: one column per firm group, 0.3 in apart; a long line wraps in its column.
- Court name two centered bold lines 18 pt below it; the caption 18 pt below that: the party column (3.1 in; designations "Plaintiff," and "Defendants." indented 1 in, as in the filed exemplar), a 0.35 in column of ")" marks (one per caption line), "Case No." and "JURY TRIAL DEMANDED" (bold, when `jury_demand: true`) on the right; "vs." between the parties. One row per caption line, so a name that wraps pushes its row down.
- Title centered, bold capitals, 18 pt below the caption; the body 12 pt below the title.
- Headings centered and kept with the text after them, 12 pt above (dropped at the top of a page): `#` bold capitals, `##` bold, `###` italic.
- Numbered paragraphs (Fed. R. Civ. P. 10(b)): the number in a 0.5 in box after the 0.5 in first-line indent; not numbered: paragraphs before the first heading, a paragraph that begins "WHEREFORE", and every paragraph after the prayer heading. A markdown numbered list becomes lettered items (a), (b), ... with the label in a 0.5 in box after the 0.5 in indent and the lines hanging at 1 in.
- Signature block 24 pt below the last chunk: "Dated: <date>", then from 2.5 in "Respectfully submitted,", the "/s/" line and the signer's lines, the role, two blank single lines between the groups. Kept on one page and kept with the last chunk of the body.
- Page number centered at the foot, 12 pt, in a single-pitch line box ending 0.5 in above the page edge (docx: footer 720 twips).
- docx only: a web address breaks where typst breaks it (zero-width spaces at typst's link break points, as the ca10 reply brief does), and a slash before a letter allows a break; neither shows in the PDF text.

## Page review (Gate 2)

Every page of `OUTPUT-complaint.typst.pdf` and `OUTPUT-complaint.docx.pdf` was rendered at 50 dpi and viewed side by side (11 of 11 each, fb-595.68.33). The two engines set every page alike (XENG-001..003 PASS: 280/280 lines, 11 = 11 pages).

| Page | Content | Result |
|---|---|---|
| 1 | Attorney block (two columns), court name, caption with "Case No." and "JURY TRIAL DEMANDED", title, lead-in, "INTRODUCTION", ¶¶ 1–2 | OK. Single-spaced block and caption; designations indented. |
| 2 | ¶¶ 2–3, "PARTIES", ¶¶ 4–9 | OK. |
| 3 | "JURISDICTION AND VENUE", ¶¶ 10–17 | OK. |
| 4 | "FACTUAL BACKGROUND", ¶¶ 18–23 with lettered items (a)–(c) | OK. The web address in (b) breaks after "https://www." in both engines. |
| 5 | (d), ¶¶ 24–29 | OK. |
| 6 | ¶¶ 30–38 | OK. |
| 7 | ¶¶ 38–43, "COUNT I" with its italic subtitle | OK. About three lines left free at the foot: "COUNT II", its subtitle and ¶ 44 are kept together. |
| 8 | "COUNT II", ¶¶ 44–49 | OK. |
| 9 | "COUNT III", ¶¶ 50–57, "PRAYER FOR RELIEF", WHEREFORE | OK. |
| 10 | Counts I–III prayers with items (a)–(d) | OK. |
| 11 | Last prayer item, "Dated", signature block | OK. The last item is kept with the signature block, so the block never stands alone. |

Tier-2 findings (OPEN or ACCEPTED):

- p.1 ACCEPTED: the typeface is Times New Roman, as the filed complaint's Times-family type; the rule names none.
- p.1 ACCEPTED: the attorney block sits above the court name, in two columns, as in the filed exemplar; LR 10.1(b) requires the block, not its position.
- p.1 ACCEPTED: a caption name that wraps ("JORNS & ASSOCIATES LLC and JUSTIN / WARD JORNS,") has one ")" for its row, not one per line; the filed exemplar draws a vertical rule instead of ")" marks (one filer's style).
- p.11 ACCEPTED: the sample stops at the prayer for relief, so the signature block is built from the frontmatter and placed after the prayer.

## Known gaps

1. Exemplar count. The one exemplar is a single filer's complaint (plaintiff's counsel). Tier 2 calls for 2 or 3 exemplars from different filers; a second complaint was not searched for in this pass, so tier 2 is judged against one filer only.
2. Sample scope. The sample transcribes the complaint from the caption through the prayer, not the exhibit list. The filed complaint is 17 pages; the render is 11 pages.
3. Italics. The text layer does not carry font style, so the italics in the sample (*pro hac vice*, the count subtitles) follow convention and were not checked glyph by glyph against the filed page.
4. Local rule edition. The rules are the January 2022 edition (see Governing rules). A newer edition, if any, has not been checked.

## Engines

- **typst** (primary, `typst/`): the reference for the form and for the other engine's breaks.
- **docx** (`docx/`): `docx/reference.xml` and `docx/wyd.lua` (no shell, no committed `reference.docx`; `docs/DOCX.md`, "The docx template without shell"). `sh tools/check.sh <this folder> --engine docx`: 13 checks passed, 0 failed, XENG-001..003 PASS (gated). Paragraph and item numbers are typed text with a tab, not Word list numbering, so they will not renumber if an allegation is inserted; the attorney block and caption are borderless fixed-width tables.
- **latex**: none for this doc type.
