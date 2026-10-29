# dcd: motion-brief

Doc type: **motion-brief** (a memorandum of points and authorities supporting a Rule 12(b)(6) motion to dismiss) in the United States District Court for the District of Columbia (`dcd`).
Folder: `courts/dc-circuit/district-of-columbia/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (Estrada; Saul Ewing LLP) and `usage/FILED-EXAMPLE-motion-brief-2.pdf` (Esrati; FEC Office of General Counsel): two filers, see `usage/SOURCE.md` |
| sample md | `usage/INPUT-motion-brief.md`: caption and title, the table of contents (generated), introduction, facts A to G, legal standard, argument I (A, B), argument IV, conclusion and signature block. Exemplar pages 1, 7 to 16, and 25 to 26 |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 16 pages each, vendored Times New Roman only, no warnings |
| pages reviewed | 16 of 16 per engine (every page of the three renders viewed side by side at 40 dpi after the last change; fb-595.17.1) |

## Governing rules

Primary sources, verified 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCvR 7(a) (D.D.C.) | Each motion is accompanied by a statement of the specific points of law and authority supporting it, including where appropriate a concise statement of facts. | The memorandum itself (this template). The motion and proposed order are separate filings. |
| LCvR 7(c) | Each motion is accompanied by a proposed order. | Not produced here (a separate document; see Known gaps). |
| LCvR 7(e) | A memorandum in support of a motion may not exceed 45 pages without prior approval of the Court. | `eval.yaml` `params.page_limit: 45` (DEF-LEN-001 on every render). |
| LCvR 7(m) | Duty to confer applies to nondispositive motions only. A motion under Rule 12(b)(6) is dispositive, so no conferral statement is required by this rule. | Not in the template. |
| LCvR 5.1(c)(1) | Attorney-signed documents carry the attorney's name, address, telephone number and D.C. Bar identification number. | The signature block (`closing` in `typst/layout.yaml`): each signer's lines from `signature.blocks`. |
| LCvR 5.1(d) | Typed double-spaced on 8 1/2 by 11 inch paper; a heading under the caption naming the document; the case number followed by the judge's initials once assigned; **all pleadings in 12-pt type and double-spaced; footnotes 12-pt**. | The base: letter paper, `size: 12`, `footnote.size: 12`; the overlay: `pitch.body: 27.6` (Word's double spacing in this face, as both exemplars set it), quotations at the body pitch, `case_number` in the caption with the judge's initials, `brief_title` centered under the caption. |
| Typeface (LCvR 5.1(d), no face named) | Rule names only "12-pt. font" and double spacing; no typeface is required. | `font-family = ("Times New Roman", "Liberation Serif")` in `typst/dcd-motion-brief.typ`: no court-named face, so the house standard (fb-9fyu), the face of both filed exemplars; latex and docx take the same face (generated). Checked against the April 2017 text of LCvR 5.1(d). |
| Fed. R. Civ. P. 7(b), 10(a), 11(a), 12(b)(6) | The paper's form (caption with the court's name, the title of the action, the file number and the paper's designation; signed by an attorney of record); the defense the memorandum argues. | 7(b), 10(a), 11(a): the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml`; 12(b)(6) is author content. |

Sources: the D.D.C. Local Civil Rules at https://www.dcd.uscourts.gov/sites/dcd/files/LocalRulesApril2017.pdf (the April 2017 edition, the most recent edition the court site served to this box; **the current edition was not confirmed**, see Known gaps 1). FRCP 12(b)(6) is cited from the rule as it appears in the exemplar and the standard it names; the rule text was not separately fetched.

Table of contents: LCvR 7(a) refers to a table of cases only in its last sentence ("If a table of cases is provided, counsel shall place asterisks..."); no rule requires a table of contents or a table of authorities. Both exemplars have both; this template generates the contents (`toc: true`) and does not generate the authorities table (see Known gaps 3).

## Layout

On the generic federal district brief (fb-595.17, fb-595.17.1): `typst/layout.yaml` names `base: /lib/layouts/frcp-motion-brief.yaml` and overlays only what D.D.C. sets differently, each with its rule or the exemplars that settle it. The shared document model sets it (`lib/typst/xdoc.typ`); `latex/` and `docx/` are generated from the merged layout by `fb engines gen` (do not edit them; change the layout and generate again).

- From the base: US Letter, 1-inch margins (a convention here; LCvR 5.1 names no margin), 12-pt type and footnotes, 0.5-inch first-line indent, headings (level 1 centered bold capitals, level 2 bold at the margin, level 3 bold italic half an inch in), page numbers centered at the foot, the last paragraph kept with the signature.
- Overlay: body at a 27.6 pt pitch (LCvR 5.1(d) double spacing, Word's double line as both exemplars set it); block quotations at the body pitch (LCvR 5.1(d) excepts nothing), indented half an inch each side.
- Overlay, cover (both exemplars put the caption alone on page 1, before their tables): the court's name centered bold in two lines; the party block ruled above, at its right and below, each designation 1.5 in in under its names, "v." between the parties; "Civil Action No." with the case number (and judge's initials) beside it, centered on its height; the title bold and centered, not underlined. Unnumbered.
- Overlay: the table of contents when the sample sets `toc: true`, on pages numbered i, ii ..; the body from 1 (`page_number.front: lower-roman`).
- Overlay, signature (both exemplars close "Respectfully submitted," over the signers, the date at the left): the date line in a column at the left; "Respectfully submitted,", the firm in bold, the signature line, the `/s/` signature and one group of lines per signer at the right.

## Markdown contract (for samples)

- YAML frontmatter, then the body in markdown: `#`, `##`, `###` headings, paragraphs, `>` block quotations, lists and footnotes (`[^n]`) as the shared model sets them.
- Frontmatter: `case_number` (for example `"26-cv-00603-ABJ"`; missing prints a blank line), `case_label` (default "Civil Action No."), `caption.parties` (list of `{names, designation}`), `brief_title`, `toc` (true prints a table of contents), `signature` (`date_line` as printed, `firm`, `signature` (the `/s/` line), `blocks` (list of lists of lines, one per signer), optional `counsel_for`).

## Known gaps and open choices

1. **Rules edition.** The local rules fetched are the April 2017 edition (`LocalRulesApril2017.pdf`), the most recent the court site served to this box. A newer edition may exist; LCvR 5.1(c), 5.1(d) and 7 should be checked against the current edition before this template is treated as final. Recorded for David.
2. **Exemplars.** Two filers (Estrada, Saul Ewing LLP; Esrati, FEC Office of General Counsel). Esrati's cover carries the counsel block and a ")" column beside the party block; Estrada's has neither: the template follows Estrada's cover (tier 3 for the other).
3. **Table of authorities.** Both exemplars have one. The template does not generate one: the shared model can (`authorities`), but the sample tags no citations. The contents table is generated and matches the body headings.
4. **Excerpted sample.** The sample transcribes exemplar pages 1, 7 to 16 (introduction, facts A to G, legal standard, the first argument heading, sub-sections A and B) and 25 to 26 (conclusion and signature). Argument sections II and III and the rest of section IV's text are not transcribed. In the sample, the argument headings run "I", then "IV". The overlay pairs pages by text, so the excluded pages show as gaps.
5. **Footnote 3 has no text in the exemplar.** The exemplar marks footnote 3 after "attached hereto." (body page 6), but neither its text layer nor its page image carries the footnote text. The sample keeps the marker "3" as printed and has no footnote text. The base sets footnotes at 12 pt (LCvR 5.1(d)) when a sample has them.
6. **Italics.** The exemplar's case names and "*Id.*" are italic; the text layer has no italic markup, so the sample is roman. The template italicizes `*...*` markdown, so future samples can carry italics.
7. **Date as printed.** The exemplar's signature date reads "March 19, 2025" in a filing dated 2026 on its docket (ECF 9-1, filed 03/19/26). The sample transcribes the date as printed; this is a filing error in the exemplar, not a template choice. Neither exemplar prints "Dated:", so the date line is the date alone.
8. **Ragged right.** Body text is left-aligned, not justified. The exemplar's justification is not asserted; this is a tier-2/3 choice.
9. **Proposed order and certificate of service.** Not part of this template. LCvR 7(c) requires the proposed order; a certificate of service is not in the exemplar and is not required by the local rules reviewed here.

## Review of the rendered pages (fb-595.17.1, 16 pages per engine)

Rendered with `pdftoppm -r 40`; every page of the typst, latex and docx renders viewed side by side after the last change.

- Page 1 (cover, unnumbered): court name, the party block ruled above, right and below with the designations indented, the case number at the right, the bold centered title. Pass on all three.
- Page i: TABLE OF CONTENTS, one row per heading (levels stepped 18 pt), dot leaders, page numbers in a 36 pt column; the numbers match the body pages (CONCLUSION 14). Pass on all three.
- Pages 1 to 13: headings as the base sets them, a single line above and below; paragraphs at the double pitch with a 0.5-inch first-line indent; the block quotation on page 10 indented from both margins at the body pitch; no heading at a page foot. Pass on all three.
- Page 14: CONCLUSION, its paragraph and the signature block together (the last paragraph kept with it). Pass on all three.

## Engines

The typst template (`typst/dcd-motion-brief.typ`, `typst/layout.yaml`) is the reference; `latex/` (`template.tex`, `xdoc.lua`) and `docx/` (`reference.xml`, `xdoc.lua`) are generated by `fb engines gen` from the merged layout. The old per-folder typst code and `docx/motion-brief.lua` are gone.

- **check.sh:** typst `RESULT: 12 checks passed, 0 failed`; latex `RESULT: 15 checks passed, 0 failed`; docx `RESULT: 16 checks passed, 0 failed`. DEF-COVER-001 and DEF-COVER-002 pass on all three (the folder's lines in `data/cover-structure-baseline.txt` removed).
- **Gate 4:** `params.cross_engine: gate` (`eval.yaml`): XENG-001..003 pass for latex and docx (16 pages).
- **The party block's rules** are three nested boxes, one side each: typst draws a box's adjoining sides as one filled outline, which DEF-COVER-002 does not read as rules.
- **docx and latex BLOCKED items:** none. The contents are typed text with the laid-out numbers, not a TOC field (re-render after editing).
- **Not verified:** the `.docx` has not been opened in Microsoft Word (none here); it converts without error in LibreOffice (DEF-DOCX-OPEN).
- **Selftest:** `tools/check-selftest.sh` does not apply (no folder `checks.yaml` and no `court.json` in a doc folder).
