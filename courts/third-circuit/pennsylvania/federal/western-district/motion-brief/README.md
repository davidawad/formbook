# W.D. Pa. (pawd): motion-brief (memorandum of law supporting a motion to dismiss)

Doc type **motion-brief** in the United States District Court for the Western District of Pennsylvania (`pawd`, Third Circuit). The covered case is a Fed. R. Civ. P. 12(b)(6) motion to dismiss with its memorandum of law (the rules require the memorandum to be a separate document from the motion, LCvR 5.1.F).
Folder: `courts/third-circuit/pennsylvania/federal/western-district/motion-brief/`. Built by the wave-3 unit fb-595.31.16 (Haiku); the court root `typst/` and `usage/` were not touched.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (primary, transcribed in part) and `usage/FILED-EXAMPLE-motion-brief-2.pdf` (second filer, saved for comparison, not transcribed). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md` (an excerpt: caption, introduction with footnote 2, part of the factual background, legal standard, the punitive-damages section, signature block; see Known gaps) |
| typeface | LCvR 5.1.B names no face and asks at least 12 point, footnotes too. Font: **Times New Roman** 12 pt (vendored, docs/FONTS.md), the exemplar's face and the house standard, in the typst PDF, the docx and its LibreOffice PDF (`fb lint fonts` does not report the folder) |
| render | ok (2026-10-22): `usage/OUTPUT-motion-brief.typst.pdf`, 8 pages (caption page, contents page ii, body pages 1 to 6), and `usage/OUTPUT-motion-brief.docx` with its LibreOffice PDF, 8 pages; `fb render`, vendored fonts only, no warnings |
| overlay | `just overlay` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` (not committed); a diagnostic, not a score |
| pages reviewed | 8 of 8, both engines, side by side at 50 dpi (2026-10-22, the renders of fb-595.68.35) |

## Governing rules

Checked 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCvR 5.1.A-B (W.D. Pa. Local Rules, manual at https://www.pawd.uscourts.gov/sites/pawd/files/lrmanual20181101.pdf, the text headed "November 1, 2016") | Letter paper, white; type not smaller than 12 point; double-spaced; quotations over two lines may be indented and single-spaced; headings and footnotes may be single-spaced; footnotes in the same font and size as the body; margins at least one inch on all four sides. | `paper: "us-letter"`; `type-size = 12pt`; `pitch-body = 24pt` (double spacing: every body line a 24 pt box); `margin = 1in`; footnotes at the body size (`show footnote.entry`), single-spaced (13.8 pt lines); block quotations half an inch in on both sides and single-spaced; headings single-spaced. |
| LCvR 5.1.F (same) | Each motion and each brief is a separate document. | Only the memorandum is produced here; the motion itself and the proposed order are separate files. |
| LCvR 5.2.B (same) | Under the signature line: name, address, telephone, fax, email (if applicable), and bar number with the state's postal abbreviation as prefix. | `signature` block: "Jaime S. Tuite (PA 87566)" and so on, with telephone and fax lines. |
| LCvR 7.A (same) | Motions comply with the Federal Rules, the Local Rules, and the assigned judge's orders and practices (posted on the court's chambers pages). | The judge's practices are **not** checked (see Known gaps 2). The caption gives the judge as a line. |
| LCvR 7.D (same) | Every motion is accompanied by a proposed order. | Not produced here (a separate document). |
| Fed. R. Civ. P. 12(b)(6) (https://www.law.cornell.edu/rules/frcp/rule_12, currency "amended Apr. 2, 2024, eff. Dec. 1, 2024") | A motion asserting "failure to state a claim upon which relief can be granted". | Title of the memorandum (frontmatter `title`); the legal standard in the sample. |
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10, "as amended Apr. 30, 2007, eff. Dec. 1, 2007") | Caption: court name, title, file number, and Rule 7(a) designation. | `caption()`: court title, the parties column, "Case No." (`case_label`) and the number, judge line, "Electronically Filed", and the title. |

Not produced by this template: the motion, the proposed order (LCvR 7.D), the table of authorities (see Known gaps 1), and a certificate of service (LCvR 5.3 says the filing itself represents service).

## Layout

- The cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line a box of its pitch, 24 pt for the body, 13.8 pt for single lines (court title, caption, headings, contents, footnotes, quotations, signature, footer); the spaces between blocks explicit. Times New Roman 12 pt.
- Page 1 (the caption page, counted as "i", no number printed): court title in two centred bold single lines; 24 pt below, the caption: the parties (single lines) with a ")" per line, and on the right the case number, the judge and "Electronically Filed", a blank single line apart; the memorandum title centred in bold on the body pitch, 24 pt below.
- Page "ii": "TABLE OF CONTENTS" and a bold "Page" label, rows generated from the headings (levels 1 and 2), 12 pt apart: the label in a half-inch box after the level's step, the title hanging after it, a dot leader to the page number in the last 36 pt.
- Body from page 1 (arabic): headings single-spaced in bold, 24 pt above and 12 pt below, kept with the next block. Level 1 centred, its roman numeral and a space before the text (I., II., ...); level 2 at the margin, the letter (A., B., ...) in a half-inch box, the text hanging; levels 3 (1., 2.) and 4 (a., b.) half an inch further in each, not used by the sample. The template numbers every heading; the sample does not contain numbers.
- Paragraphs: first-line indent 0.5 in, double-spaced; block quotations single-spaced, half an inch in on both sides, 12 pt off the text.
- Footnotes: numbered in order, in the body size, single-spaced, 7 pt apart, under a 30 % rule; a note is kept whole on the page of its mark.
- Signature block, kept with the last paragraph: "Date:" at the margin, then from 3.0 in "Respectfully submitted," and the signer's "s/" line with the attorney lines (names, bar numbers, email, firm, address, telephone and fax, and the "Attorneys for" line), single-spaced, 24 pt between the groups.
- Footer: the page number centred in a single line ending 0.5 in above the page edge; none on the caption page.

## Markdown contract (for samples)

- YAML frontmatter: `case_label` (default "Civil Action No."), `case_number`, `judge` (optional), `caption` (a list of `{names, designation}`), `electronically_filed` (bool), `title`, `date`, `signature` (`lead`, optional `firm`, `signer`, `lines`).
- Body: `#` = section (level 1), `##` = level 2, `###` = level 3, `####` = level 4; a paragraph is any other chunk between blank lines; a chunk starting "> " is a block quotation; footnotes are `text[^key]` with a definition line `[^key]: text` anywhere in the file (cmarker and pandoc's CommonMark reader both resolve them).
- Case names and signals in italics (`*Ashcroft v. Iqbal*`, `*Id.*`, `*See*`), as the markdown convention; the template does not guess which text is a case name.
- Not supported: tables, images, raw typst. Table of authorities: not generated (Known gaps 1).

## What the overlay shows

`just overlay <this folder>` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` and `.txt` (not committed): each page red (our render) multiplied over blue (the filed exemplar's page with the most shared words), black where both agree, the pages paired by word overlap. The overlay is a diagnostic, not a score. The sample is an excerpt of the filing, so the pages it pairs with are the pages its text came from, not a page-for-page copy.

## Known gaps and open choices

1. **No table of authorities.** The exemplar has one (pages iii to v). The rules checked (LCvR 5.1, 7) do not require it, and the judge's practices were not checked, so it is not generated. Adding it needs a citation registry and a page-tracking pass (as in the ca9 template); it is a tier-2 convention gap, recorded as OPEN.
2. **Judge practices not checked.** LCvR 7.A makes each judge's practices apply, and some judges set page or format rules. The chambers pages were not retrieved. The Albright exemplar's memorandum is 23 pages with a table of contents and table of authorities; no page limit was verified.
3. **Excerpt, and section letter.** The sample includes the introduction and the first section of the factual background, the legal standard, and the punitive-damages section. In the filing that section is "E."; the template numbers the first level-2 heading under ARGUMENT as "A.". The filing's other argument sections are not transcribed, so the letter cannot match without them. Recorded as ACCEPTED for the sample; it is a numbering consequence of the excerpt.
4. **Footnote number.** The sample transcribes one footnote (the filing's footnote 2), so it prints as "1". The filing prints it as "2" because its footnote 1 is not transcribed.
5. **Italics added.** The exemplar's text layer carries no italics, so the sample's case names and signals are italic by convention (FRAP-style case-name italics, as in the ca9 sample). The exemplar may use italics or underscoring; this is a convention, not a rule text.
6. **Reconstructed words.** The introduction's last paragraph starts "The Court should dismiss CTC Foundation as a party." in the sample; in the filing that sentence begins on the next page, and its first word is not visible in the text layer. The sample uses the sentence without a bracketed "[T]he".
7. **No conclusion section in the sample.** The filing ends its argument with the punitive-damages paragraph and then the signature; the template prints no "Conclusion" heading unless the sample has one. This follows the exemplar.
8. **Filing's own typos kept.** The exemplar's text has "cannot not provide" and "560 U.S. 242 ," and "2015 WL 56740 192"; the transcription keeps them, because the sample is a transcription.
9. **Caption.** The caption closes with a ")" column (as the exemplar does). Accepted as a convention choice.

## Review of the rendered pages (Gate 2 rows; all 8 pages, typst and docx side by side at 50 dpi, 2026-10-22)

"Body n" is the printed footer; the front matter is the caption page (no number) and the table of contents (ii).

| Page | What it is | Finding |
|---|---|---|
| 1 (no number) | Court title, caption with the ")" column, "Case No. 3:21-cv-00112-SLH", "Judge Stephanie L. Haines", "Electronically Filed", the title (two lines) | OK, both engines alike. |
| ii | TABLE OF CONTENTS, "Page"; I. (1) with A. (1, its title wrapped and hanging), B. (2), C. (2); II. (3) with A. (3); III. (3); IV. (4) with A. (4) | OK; the page numbers match the body headings in both engines (the docx's from fb render's passes). |
| Body 1 | I. INTRODUCTION, its paragraph, A. heading, the paragraphs of A. | OK. |
| Body 2 | End of A., B. and its paragraph, C. and the start of its paragraph | OK. Ends two lines early: the paragraph's last two lines, one carrying the footnote mark, move on together with the whole note. |
| Body 3 | C. paragraph's last lines with the footnote mark, II. FACTUAL BACKGROUND, A. and its two paragraphs, III. LEGAL STANDARD; footnote 1 whole at the foot | OK. |
| Body 4 | Legal standard continued, IV. ARGUMENT, A. heading, the first punitive-damages paragraphs | OK. |
| Body 5 | The Restatement, *Smith v. Brown*, *Salvio* and *Allergino* paragraphs | OK. Ends short: the last paragraph is kept with the signature. |
| Body 6 | "Therefore, ..." paragraph, "Date:", the signature block | OK; the signature never stands alone. |

The docx PDF breaks every line and page where the typst PDF does (XENG-001..003: 167/167 lines, 8/8 pages).

Defects of the earlier template (fixed by the cross-engine port, fb-595.68.35): em leadings and `set block(spacing)` instead of line boxes, 13 pt EB Garamond in the docx, a docx contents page without its roman number and contents entries without page numbers (a TOC field), the caption's right column centred on the rows, and a split footnote whose first lines typst set on the page before its mark.

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): the docx render breaks every line and every page where the typst render does, and `eval.yaml` gates it (`params.cross_engine: gate`, fb-595.68.35).

- **typst** (primary, `typst/pawd-motion-brief.typ`): the reference for the court's form.
- **docx** (`docx/`): `docx/reference.xml` (`base="xengine"`, the typst face `{font}` = Times New Roman, 12 pt, footnotes included; Body Text in exact 24 pt line boxes with a 0.5 in first-line indent; single lines, footnotes and quotations 13.8 pt; Footnote Text kept whole and 7 pt apart; Block Text half an inch in on both sides; "Body Text Keep" for the paragraph kept with the signature; pandoc reads the sample as CommonMark, as cmarker does) and `docx/pawd-motion-brief.lua` on `lib/docx/xengine.lua`, which writes the caption page, the contents with real page numbers (needles for each heading with the words after it, found by fb render in the LibreOffice PDF), the numbered headings, the signature block, the page-number footer (`$FORMBOOK_FOOTERS`) and three sections: the caption page without a number, the contents in lower roman from ii, the body in arabic from 1 (`$FORMBOOK_FINAL`). No shell script (fb-595.68).
- Checks (2026-10-22): typst 9 passed, 0 failed; docx 13 passed, 0 failed, XENG-001..003 PASS (167/167 lines, 8/8 pages); DEF-COVER-001 and DEF-TOC-001 pass on both.
- Word: not available here. The file converts in LibreOffice with no error; Word may paginate slightly differently (docs/DOCX.md), and its contents page numbers are the LibreOffice ones.
