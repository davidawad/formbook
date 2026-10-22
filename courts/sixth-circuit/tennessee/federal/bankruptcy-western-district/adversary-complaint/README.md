# tnwb: adversary-complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the Western District of Tennessee (`tnwb`), Eastern and Western Divisions.
Folder: `courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md` (21-page complaint transcribed: caption, intro, paragraphs 1–70 with transfer tables and footnotes, the prayer and the signature; paragraphs 71–116 omitted and marked in the sample) |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf` and `usage/OUTPUT-adversary-complaint.docx.pdf`, 12 pages each, US Letter, Times New Roman (vendored), no typst warnings |
| overlay | `just overlay <dir>` writes `.overlay/<doc path>/OVERLAY-adversary-complaint.pdf` (gitignored, not committed) |
| pages reviewed | 12 of 12, typst and docx (every page rasterized at 60 dpi and viewed; fb-595.68.31) |
| tier 2 | not met: one filer only (see Known gaps 1) |
| typeface | face required by the rules: none (Known gaps 2) -> the exemplar's Times New Roman (vendored, `("Times New Roman", "Liberation Serif")`) |

Commands (from the repo root, toolchain on PATH):

```sh
sh tools/check.sh courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/adversary-complaint                 # typst: render and gates
sh tools/check.sh courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/adversary-complaint --engine docx   # docx: render, gates, XENG
just overlay courts/sixth-circuit/tennessee/federal/bankruptcy-western-district/adversary-complaint
```

## Governing rules

Dates verified 2026-10-14.

| Rule | Requirement | Source | Where in the template |
|---|---|---|---|
| TNWB LBR 1001-3(h) (Local Rules eff. April 3, 2017) | Every pleading must bear the signature of an attorney of record and the attorney's address, zip, telephone, email, fax if any, and state bar disciplinary number. | https://www.tnwb.uscourts.gov/PDFs/BK/LocalRules.4.3.17.pdf | `signature` frontmatter (`firm`, `signer`, `name_line`, `lines`). See Known gaps 5 for the bar number. |
| FRBP 9004(a), (b) (restyled eff. Dec. 1, 2024) | Papers must be clearly legible. A document must have a caption with the court's name, the case title, the case number and adversary-proceeding number, and a brief designation of the document. | https://www.law.cornell.edu/rules/frbp/rule_9004 | `court-heading`, `caption` (`case_number`, `adversary_number`, `title`). |
| FRBP 7010 | "Fed. R. Civ. P. 10 applies in an adversary proceeding"; the caption "must substantially conform to the appropriate version of Form 416." | https://www.law.cornell.edu/rules/frbp/rule_7010 | `caption`: court, division line, debtor and case number, all parties, adversary number, title. Form 416 itself was not fetched (Known gaps 3). |
| FRCP 10(a) (via FRBP 7010) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the title of the complaint must name all the parties. | https://www.law.cornell.edu/rules/frcp/rule_10 (text checked 2026-10-14) | `caption` lists every plaintiff and defendant; the title `COMPLAINT` is in the caption block. |
| FRCP 10(b) (via FRBP 7010) | Claims are stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances; claims from separate transactions go in separate counts. | same | `pleading-body`: allegations are numbered 1, 2, ...; claim headings are author content (`#` lines) and are not numbered. |
| FRBP 7001 (types of adversary proceeding), 7003 and 7004 | The complaint commences the proceeding; summons and cover sheet are separate filings. | https://www.law.cornell.edu/rules/frbp/rule_7001 | Not generated: the cover sheet (Official Form 104) and the summons (Local Form 010, `https://www.tnwb.uscourts.gov/Forms/LocalForms/DOC/LF010.doc`) are separate filings. |

Not produced by this template (separate filings): the adversary cover sheet, the summons, the exhibits (including Exhibit A, the loan agreement), and any statement the court's current forms require.

## Layout

The shared cross-engine layout model (`lib/typst/xengine.typ`; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box of its pitch with the baseline at 0.8 of it, the boxes touching, explicit spaces between blocks; first fit, ragged right, no kerning, ligatures or hyphenation. The docx sets the same pitches and spaces in twips (`docx/reference.xml`, `docx/tnwb-adversary-complaint.lua`). No TNWB rule sets any of these numbers (TNWB-FORM-002): they are the exemplar's conventions.

- Letter paper, 1 in margins. Times New Roman 12 pt; body double spaced (24 pt pitch), first-line indent 0.5 in; single lines 13.8 pt (Word's single line at 12 pt).
- Court heading centered, plain capitals (as filed): `UNITED STATES BANKRUPTCY COURT`, `WESTERN DISTRICT OF TENNESSEE`, and the division if given; a body line below.
- Caption (as filed): a three-column table, one single line per row: the parties on the left (names in capitals; `DEBTOR.`, `Plaintiff,` and `Defendants.` 1.5 in in, `vs.` 0.5 in in), a section mark (§) on every row in a 0.5 in column, `CASE NO.:` and the chapter lines beside the debtor, `ADVERSARY PROCEEDING NO.:` beside the first plaintiff; a 0.5 pt rule under the debtor block and under the parties (left and § columns). A name that wraps takes two lines in its row, with one §.
- Title centered bold capitals, half a body line (12 pt) above and below.
- Allegations numbered by the template: the number in a half-inch box at the half-inch indent, the text from 1 in, wrapping to the margin (as filed). The first paragraph (the introduction), the prayer lead-in (`WHEREFORE`, kept with the prayer) and an editorial note in italics within square brackets (`*[...]*`) are not numbered.
- `#` headings: centered bold underlined capitals (as filed); `##`: centered bold, mixed case; `###`: bold at the margin. Single lines, 12 pt above and below, kept with the text after them.
- Prayer items (`- ` list) lettered A., B., ... in the number's box, laid out as the allegations (as filed).
- Transfer tables (markdown pipe tables): centered, 60 % of the text width, the columns equal, 0.5 pt rules, 8 pt / 3 pt cell padding, single lines, the header row bold and centered; 12 pt above and below; rows are not split and the header row is not repeated on the next page.
- Quotations (`>`): single lines, 0.5 in in on both sides, 12 pt above and below.
- Footnotes: 10 pt in 11.5 pt lines, 6 pt apart, a 30 % rule 7.8 pt above (with the 6 pt, Word's 13.8 pt separator line).
- Signature: the closing ("Respectfully submitted ...") on a body line at the indent; then, 12 pt below and 2.5 in from the margin (as filed), single lines: firm (bold), `/s/` signer, name line, address and contact lines, role (italic). The last allegation or prayer item is kept on one page with the signature block.
- Page number centered in the footer, in a 13.8 pt line.

## Markdown contract (for samples)

YAML frontmatter, then the body.

| Field | Required | Feeds |
|---|---|---|
| `division` | no | third caption line (`EASTERN DIVISION`) |
| `debtor` (list of lines) | yes | `IN RE:` block |
| `case_number` | yes | `CASE NO.:` |
| `chapter` (list of lines) | yes | chapter lines on the right of the debtor block |
| `adversary_number` | yes | `ADVERSARY PROCEEDING NO.:` |
| `plaintiffs`, `defendants` (lists) | yes | adversary block |
| `title` | yes | document title, centered in capitals |
| `signature` | yes | `closing` (e.g. "Respectfully submitted this 19th day of September, 2025."), `firm`, `signer`, optional `name_line` (defaults to `signer`), `lines`, `role` |

Body: blank-line separated blocks. `#` / `##` / `###` headings; `- ` list items (lettered); `|` tables; `>` quotations (single spaced, indented); any other block is a paragraph, numbered unless it is the first block or starts with `WHEREFORE` or `*[`. Case names and signals are italic in the markdown (`*Tabas v. Lehman*`). Escape a literal `*` (`at \*8`).

Not supported: raw typst, images, nested lists.

## Known gaps and open choices

1. **One exemplar, not two or three.** The tier-2 test (2 or 3 filers) is not met. The search (CourtListener RECAP, `court=tnwb`, adversary complaints 2019–2025) found Springfield 19-00070 and Reed 20-00136 (pro se, 2–3 pages, not representative) and Butcher Shop of Cordova 21-00106 (44 pages, mostly scanned exhibits, little text). None was saved.
2. **No court typeface, margin or spacing rule found.** The W.D. Tenn. bankruptcy local rules (2017 text, `LocalRules.4.3.17.pdf`, re-read 2026-10-15 as extracted text: no font, size, spacing or margin requirement) contain none, and FRBP 9004 (restyled 2024) has none either. The template uses the exemplar's conventions: 12 pt, double spaced, 1 in margins. These are conventions, not court requirements. The court's current local rules may have changed since 2017 and were not verified. A search snippet reports that the Middle District's 2025 amendments moved LBR 9013-1 instructions to the court's website; nothing was found for TNWB either way.
3. **Form 416 was not fetched.** FRBP 7010 requires the caption to substantially conform to Official Form 416. The caption follows the exemplar and the rule's stated contents; the form text itself is unverified.
4. **Font.** The rules name no face (Known gaps 2); the template sets the exemplar's Times New Roman (vendored), in every engine (the docx names the typst face through `{font}`; until fb-595.68.31 the docx was EB Garamond and failed DEF-FONT-002 and TNR-EMBEDDED). A decision for David if the court's face should be another.
5. **State bar number.** LBR 1001-3(h) requires the state bar disciplinary number. The exemplar's counsel block has none (its counsel is a New York firm), so the sample has none either. The template prints `name_line` if given and does not check for it.
6. **Italics.** The exemplar's text layer does not show italics. The sample italicizes case names and signals as a convention, not from the filing.
7. **Transcription.** The sample is the exemplar's text transcribed from its text layer, with the exemplar's own errors kept: the stray quotation mark in the introduction (`“hereinafter referred to as “Bassuk”)`), "should be avoided under as it did not" (paragraph 51), and "a constructively fraudulent conveyances" (paragraph 66). Paragraphs 71–116 are omitted and marked; the prayer is transcribed as filed and still refers to the omitted Fourth and Fifth Claims.
8. **Justification.** Body text is ragged right (the cross-engine model: first fit, no hyphenation). The exemplar's justification could not be read from the text layer; not asserted.
9. **Overlay.** The overlay (`just overlay`) pairs pages by word overlap; the exemplar sets its tables and caption in a different vertical rhythm, so the layers do not line up on the table pages. The overlay is a diagnostic, not a score.
10. **Caption section marks.** A party name that wraps in the caption takes two lines in its row with one § beside it (the exemplar types a § on every line); the rows hold the frontmatter lines, not measured lines. Tier 2, ACCEPTED.
11. **Cover sheet, summons and exhibits** are separate filings and are not generated (see Governing rules).

## Review of the rendered pages (final render, 12 pages, typst and docx; fb-595.68.31)

Rendered at 60 dpi with `pdftoppm -r 60` and viewed page by page, typst beside docx. The docx breaks every line and page as the typst render (XENG-001..003, 330/330 lines); the findings hold for both.

| Page | Content | Result |
|---|---|---|
| 1 | Court heading, caption (debtor and adversary blocks, § column, two rules), title, introduction, PARTIES heading, paragraphs 1–4 | Pass. Wrapped debtor and plaintiff names keep their rows (Known gaps 10, ACCEPTED). |
| 2 | Paragraphs 5–12; GENERAL ALLEGATIONS and THE AGREEMENT headings | Pass. Headings kept with the following paragraph. |
| 3 | Paragraphs 13–24 | Pass. |
| 4 | Paragraphs 25–27 and their transfer tables | Pass. Paragraph 28 and its table move to page 5 (the space left is less than the 12 pt above a table and a body line). |
| 5 | Paragraphs 28–31; table 28 and the start of table 31 | Pass. Table 31 breaks between rows; no row split. |
| 6 | The rest of table 31; paragraph 32 | Pass. Header row not repeated on the continuation (both engines). |
| 7 | Paragraphs 33–41; INSOLVENCY; footnotes 1 and 2 | Pass. |
| 8 | Paragraphs 42–49; FIRST CLAIM FOR RELIEF and its parenthetical; footnotes 3 and 4 | Pass. |
| 9 | Paragraphs 50–57; SECOND CLAIM FOR RELIEF and its parenthetical | Pass. |
| 10 | Paragraphs 58–65 | Pass. Italic case names in paragraph 59. |
| 11 | Paragraphs 66–70; THIRD CLAIM FOR RELIEF; the omission note (unnumbered); WHEREFORE; prayer A–C | Pass. |
| 12 | Prayer D–G; closing; signature block | Pass. Item G kept with the closing and signature block. |

Open tier-2 findings: none. ACCEPTED: Known gaps 10 (one § per wrapped caption row).

## Engines

- **typst** (primary, `typst/tnwb-adversary-complaint.typ`): the reference for the form, on `lib/typst/xengine.typ` (`xengine.with(pitch: 24pt)`, single lines in `edges(13.8pt)` boxes, footnotes in `edges(11.5pt)`).
- **docx** (`docx/reference.xml`, `docx/tnwb-adversary-complaint.lua`; built by `fb render`, no shell): `reference.xml` is the cross-engine recipe (`base="xengine"`, `{font}` = the typst face; Body Text 480-twip lines with a 720-twip indent, 276-twip single lines, headings 240 twips from the text, footnotes 10 pt in 230-twip lines 120 twips apart, the page number in a 276-twip footer line 735 twips from the page foot) plus "Numbered Paragraph" (tab at 1 in) with its "Note" (no widow control, for a paragraph that anchors a footnote) and "Keep" variants, "Body Text Note" and "Body Keep". The filter (`require("docx.xengine")`) writes the court heading, the caption table, title, headings, transfer tables, quotations and the signature block with the typst spacing in twips; the introduction, allegations, WHEREFORE and prayer items go to pandoc in those styles (footnotes stay Word footnotes). Break rules as typst: no break inside ")(", a break after a slash before a letter, `§§` bound to its number. Until fb-595.68.31 the docx was EB Garamond from `docx/build-reference.sh` (TNR-EMBEDDED and DEF-FONT-002 failed).
- Checks (fb-595.68.31): typst `RESULT: 9 checks passed, 0 failed`; docx `RESULT: 13 checks passed, 0 failed`, XENG-001..003 PASS (12 pages each, 330/330 lines). `eval.yaml` sets `params.cross_engine: gate`.
- **latex**: no latex template for this doc type.
