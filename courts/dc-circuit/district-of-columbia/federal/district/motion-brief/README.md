# dcd: motion-brief

Doc type: **motion-brief** (a memorandum of points and authorities supporting a Rule 12(b)(6) motion to dismiss) in the United States District Court for the District of Columbia (`dcd`).
Folder: `courts/dc-circuit/district-of-columbia/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer, see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: caption and title, the table of contents (generated), introduction, facts A to G, legal standard, argument I (A, B), argument IV, conclusion and signature block. Exemplar pages 1, 7 to 16, and 25 to 26 |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 14 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-estrada-motion-to-dismiss.pdf` and `OVERLAY-estrada-motion-to-dismiss.txt` |
| pages reviewed | 14 of 14 (every page rendered at 60 dpi and viewed). Pages 1 and 2 (caption, table of contents) were viewed before the last two template edits (paragraph indent, keep-with-signature), which do not touch the caption or the contents page; the other twelve pages were viewed after them |

File names: the render and overlay names follow `tools/render.sh` and `tools/overlay.sh` (`OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`), not the `<id>.pdf` and `<id>-overlay.pdf` names in the task brief. The tools are shared and were not edited.

## Governing rules

Primary sources, verified 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCvR 7(a) (D.D.C.) | Each motion is accompanied by a statement of the specific points of law and authority supporting it, including where appropriate a concise statement of facts. | The memorandum itself (this template). The motion and proposed order are separate filings. |
| LCvR 7(c) | Each motion is accompanied by a proposed order. | Not produced here (a separate document; see Known gaps). |
| LCvR 7(e) | A memorandum in support of a motion may not exceed 45 pages without prior approval of the Court. | Not enforced by the template (the page count is shown by the render). |
| LCvR 7(m) | Duty to confer applies to nondispositive motions only. A motion under Rule 12(b)(6) is dispositive, so no conferral statement is required by this rule. | Not in the template. |
| LCvR 5.1(c)(1) | Attorney-signed documents carry the attorney's name, address, telephone number and D.C. Bar identification number. | The signature block: each signer's name with bar number, firm, address, telephone and email. |
| LCvR 5.1(d) | Typed double-spaced on 8 1/2 by 11 inch paper; a heading under the caption naming the document; the case number followed by the judge's initials once assigned; **all pleadings in 12-pt type and double-spaced; footnotes 12-pt**. | `type-size = 12pt`, `body-leading = 1.35em` (24 pt pitch), `page-w`/`page-h`, `case_number` in the caption with the judge's initials, `brief_title` centered under the caption. |
| Typeface (LCvR 5.1(d), no face named) | Rule names only "12-pt. font" and double spacing; no typeface is required. | `font-family = "EB Garamond"` in `typst/dcd-motion-brief.typ`: no court-named face, so the default face under `docs/FONTS.md` (no substitution). Checked against the April 2017 text of LCvR 5.1(d). |
| Fed. R. Civ. P. 12(b)(6) | Defense of failure to state a claim; the standard the memorandum argues. | Author content. The template does not check the argument. |

Sources: the D.D.C. Local Civil Rules at https://www.dcd.uscourts.gov/sites/dcd/files/LocalRulesApril2017.pdf (the April 2017 edition, the most recent edition the court site served to this box; **the current edition was not confirmed**, see Known gaps 1). FRCP 12(b)(6) is cited from the rule as it appears in the exemplar and the standard it names; the rule text was not separately fetched.

Table of contents: LCvR 7(a) refers to a table of cases only in its last sentence ("If a table of cases is provided, counsel shall place asterisks..."); no rule requires a table of contents or a table of authorities. The exemplar has both; this template generates the contents and does not generate the authorities table (see Known gaps 3).

## Layout

- US Letter, 1-inch margins on all sides (a convention; LCvR 5.1(d) names no margin size).
- Page 1 (the caption page, unnumbered): court title centered bold, caption as a two-column table (parties with a rule on the right and bottom; "Civil Action No." with the case number and judge's initials on the right), the title of the paper centered bold below the caption.
- Table of contents page(s) numbered in lower-case roman (i, ii, ...), generated from the headings with dot leaders and page numbers in the body's arabic numbering.
- Body numbered from 1 in arabic. Paragraphs are unnumbered, first-line indented 0.5 inch, double-spaced at a 24 pt pitch. A `>` line is a block quotation indented 0.5 inch from both margins, double-spaced (LCvR 5.1(d) does not except quotations, so the template does not single-space them).
- Headings: level 1 centered bold caps ("INTRODUCTION", "ARGUMENT", "CONCLUSION"); level 2 bold, left (argument headings, "I. ..."); level 3 bold, left (sub-headings "A. ..."). A heading stays with the text after it.
- Signature block: "Dated" on the left; "Respectfully submitted," the firm name, the signature line, the signature text, and one block of lines per signer (name with bar number, address, telephone, email). The last paragraph is kept with the signature block so a signature never stands alone on a page.
- Page numbers centered at the foot of each page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1), `##` (level 2) or `###` (level 3), a `>` block quotation, or a paragraph. Lists are not supported in this template.
- Frontmatter: `case_number` (for example `"26-cv-00603-ABJ"`; blank prints a blank line), `caption.parties` (list of `{names, designation}`), `brief_title`, `toc` (true prints a table of contents), `date` (printed as "Dated: ..."), `signature` (`firm`, `signature` (the `/s/` line), `blocks` (list of lists of lines, one per signer)).
- Not supported: tables, footnotes, raw typst, numbered paragraphs (the memorandum is not numbered).

## Known gaps and open choices

1. **Rules edition.** The local rules fetched are the April 2017 edition (`LocalRulesApril2017.pdf`), the most recent the court site served to this box. A newer edition may exist; LCvR 5.1(c), 5.1(d) and 7 should be checked against the current edition before this template is treated as final. Recorded for David.
2. **One exemplar.** The brief asks for 2 or 3 filers for tier 2. The search (CourtListener RECAP, `court=dcd`, motions to dismiss filed in 2026) found several other DDC memoranda (*Shaw v. American Academy of Pediatrics*, 1:26-cv-00171; *Brown v. DeLeeuw*, 1:26-cv-01249; *Greater DC Diaper Bank v. WWDC Industrial Park*, 1:26-cv-02900); they were checked by docket listing, not downloaded. Tier 2 is therefore judged against one filer.
3. **Table of authorities.** The exemplar has one (pages iii and iv, with page numbers). The template does not generate one: it would need each citation tagged in the sample or a citation-by-citation search, and neither is in place. The contents table is generated and matches the body headings.
4. **Excerpted sample.** The sample transcribes exemplar pages 1, 7 to 16 (introduction, facts A to G, legal standard, the first argument heading, sub-sections A and B) and 25 to 26 (conclusion and signature). Argument sections II and III and the rest of section IV's text are not transcribed. In the sample, the argument headings run "I", then "IV". The overlay pairs pages by text, so the excluded pages show as gaps.
5. **Footnote 3 has no text in the exemplar.** The exemplar marks footnote 3 after "attached hereto." (body page 6), but neither its text layer nor its page image carries the footnote text. The sample keeps the marker "3" as printed and has no footnote text. Footnotes are not supported by the template; LCvR 5.1(d) requires 12-pt footnotes, which the template would need to add if a sample used them.
6. **Italics.** The exemplar's case names and "*Id.*" are italic; the text layer has no italic markup, so the sample is roman. The template italicizes `*...*` markdown, so future samples can carry italics.
7. **Date as printed.** The exemplar's signature date reads "March 19, 2025" in a filing dated 2026 on its docket (ECF 9-1, filed 03/19/26). The sample transcribes the date as printed; this is a filing error in the exemplar, not a template choice.
8. **Caption.** The party block is closed by a rule on its right and bottom, not the column of ")" marks some filers use. This is a tier-2 convention choice (accepted; both forms appear in D.D.C. filings).
9. **Ragged right.** Body text is left-aligned, not justified. The exemplar's justification is not asserted; this is a tier-2/3 choice.
10. **Proposed order and certificate of service.** Not part of this template. LCvR 7(c) requires the proposed order; a certificate of service is not in the exemplar and is not required by the local rules reviewed here.
11. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape. The brief forbids touching `tools/`, so the gates were not run. Render and overlay were run; the page review below is the Gate 2 equivalent for this doc type.

## Review of the rendered pages (current PDF, 14 pages)

Rendered with `pdftoppm -r 60` and viewed page by page. Page numbers below are the PDF pages; the body number is in brackets.

- PDF 1 (caption page, no number): court title, caption with party block and "Civil Action No. 26-cv-00603-ABJ", title centered bold in three lines. Pass.
- PDF 2 (roman i): "TABLE OF CONTENTS" with the headings, dot leaders and page numbers (1 to 12 in the body); sub-headings indented; no heading split from its entry. Pass.
- PDF 3 (body 1): "INTRODUCTION" centered bold; paragraphs first-line indented; heading "ALLEGED FACTS AND PROCEDURAL BACKGROUND" and sub-heading A. Pass.
- PDF 4 (body 2): sub-headings B and C, paragraph flow. Pass.
- PDF 5 (body 3): sub-heading C and D, paragraph flow. Pass.
- PDF 6 (body 4): sub-heading D, paragraphs. Pass.
- PDF 7 (body 5): sub-headings E and F (F wraps to two lines, bold, left). Pass.
- PDF 8 (body 6): text and sub-heading G, bottom third of the page blank (the next page starts with the legal standard). Pass (layout).
- PDF 9 (body 7): "LEGAL STANDARD" centered bold; "ARGUMENT" centered; "I. THE COURT SHOULD DISMISS..." bold, two lines. Pass.
- PDF 10 (body 8): sub-heading A and the block quotation (indented from both margins). Pass.
- PDF 11 (body 9): block quotation continues, paragraphs, sub-heading B (two lines). Pass.
- PDF 12 (body 10): paragraphs, "IV. THE COURT SHOULD DISMISS..." bold, two lines. Pass.
- PDF 13 (body 11): paragraphs to the end of the argument; blank space at the foot. Pass.
- PDF 14 (body 12): "CONCLUSION" centered bold, its paragraph, "Dated", "Respectfully submitted," firm name, signature line, /s/ line, and both signer blocks. The conclusion and the signature are on the same page. Pass.

Defects found during review and fixed in the template: body paragraphs had no first-line indent (the indent set on `par` did not reach the cmarker output; the indent is now an inline space); a signature block stood alone on a page (the last paragraph is now kept with it).

## Engines

The typst template (`typst/`) is the reference. The docx engine is `docx/` (`reference.docx` from `make-reference.sh`, `motion-brief.lua`, and `render.sh`, which owns the build), rendered by `sh tools/render.sh --engine docx motion-brief usage/INPUT-motion-brief.md` into `usage/OUTPUT-motion-brief.docx` and `usage/OUTPUT-motion-brief.docx.pdf` (LibreOffice 26.8.1.1; the vendored EB Garamond installed for it). The docx.pdf is 14 pages, the same count as the typst render; every page was rendered at 60 dpi and compared with the typst render.

- **What matches the rules:** US Letter, 1-inch margins; 12-point EB Garamond; double spacing at an exact 24-pt pitch; the caption page with no page number; the contents on a page numbered in lower-case roman; the body numbered in arabic from 1; the caption and the title below it; first-line indented paragraphs; block quotations indented 0.5 inch from both margins; a heading that stays with the text after it; the last paragraph kept with the signature block, and the signature block laid out as in typst (Dated, Respectfully submitted, the firm, the `/s/` line and each signer's block).
- **What differs from typst, and why:**
  - Headings are 12 pt in the docx; the typst headings come out at its default heading size (about 17 pt), larger than the 12-point type LCvR 5.1(d) asks for. As for the complaint, this is for David to decide on the typst side.
  - Contents: the docx lists each heading with dot leaders and a page number. The entries are typed text from the LibreOffice layout of a first pass (`render.sh` writes the numbers, then checks that the second pass lays out to the same pages), not a TOC field, so Word's "Update field" does not refresh them. Re-run `sh docx/render.sh` after any edit to the body. The entries are set more tightly than typst's.
  - Body pagination: the same 12 body pages, but line breaks differ, so some headings fall on a different page (for example "ALLEGED FACTS AND PROCEDURAL BACKGROUND" is on body page 1 in the docx, page 2 in typst). The contents numbers follow the docx layout.
  - No table of authorities: the template does not generate one either, so the docx matches typst here (see Known gaps 3).
- **docx BLOCKED items:** none. The contents page numbers are computed from LibreOffice's layout; Word may paginate a line or two differently and so may place a heading one page off in the contents (`docs/DOCX.md`, Known limits). The docx has not been opened in Microsoft Word (none here).
- **Not verified:** Word; the font is named, not embedded (`docs/DOCX.md`, Fonts).
- **Gates:** `tools/check.sh` was not run for this folder (no `rules.md`; not the gate shape; see Known gaps 11 above, which applies here too).
