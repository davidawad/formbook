# W.D. Pa. (pawd): motion-brief (memorandum of law supporting a motion to dismiss)

Doc type **motion-brief** in the United States District Court for the Western District of Pennsylvania (`pawd`, Third Circuit). The covered case is a Fed. R. Civ. P. 12(b)(6) motion to dismiss with its memorandum of law (the rules require the memorandum to be a separate document from the motion, LCvR 5.1.F).
Folder: `courts/third-circuit/pennsylvania/federal/western-district/motion-brief/`. Built by the wave-3 unit fb-595.31.16 (Haiku); the court root `typst/` and `samples/` were not touched.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-albright-3-21-cv-00112-memorandum.pdf` (primary, transcribed in part) and `exemplars/FILED-EXAMPLE-north-american-dental-2-23-cv-01202-memorandum.pdf` (second filer, saved for comparison, not transcribed). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-albright-memorandum.md` (an excerpt: caption, introduction with footnote 2, part of the factual background, legal standard, the punitive-damages section, signature block; see Known gaps) |
| render | ok: `samples/OUTPUT-albright-memorandum.pdf`, 8 pages (caption page, TOC page ii, body pages 1 to 6), typst 0.15.0, vendored EB Garamond only, no typst warnings (`tools/render.sh` exit 0) |
| overlay | ok: `samples/OVERLAY-albright-memorandum.pdf` and `samples/OVERLAY-albright-memorandum.txt` (`tools/overlay.sh` exit 0) |
| pages reviewed | 8 of 8: every page rendered at 60 dpi (`pdftoppm -r 60`) and viewed after the last template change |

File names: as in the complaint folder, the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf` (not `<id>.pdf` and `<id>-overlay.pdf`). The sample id is `albright-memorandum`.

## Governing rules

Checked 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCvR 5.1.A-B (W.D. Pa. Local Rules, manual at https://www.pawd.uscourts.gov/sites/pawd/files/lrmanual20181101.pdf, the text headed "November 1, 2016") | Letter paper, white; type not smaller than 12 point; double-spaced; quotations over two lines may be indented and single-spaced; headings and footnotes may be single-spaced; footnotes in the same font and size as the body; margins at least one inch on all four sides. | `paper: "us-letter"`; `type-size = 13pt`; `leading: 1.35em` (26 pt pitch); `margin: 1in`; footnotes set to the body size (`show footnote.entry`), single-spaced; block quotations indented 1 in on both sides and single-spaced. |
| LCvR 5.1.F (same) | Each motion and each brief is a separate document. | Only the memorandum is produced here; the motion itself and the proposed order are separate files. |
| LCvR 5.2.B (same) | Under the signature line: name, address, telephone, fax, email (if applicable), and bar number with the state's postal abbreviation as prefix. | `signature` block: "Jaime S. Tuite (PA 87566)" and so on, with telephone and fax lines. |
| LCvR 7.A (same) | Motions comply with the Federal Rules, the Local Rules, and the assigned judge's orders and practices (posted on the court's chambers pages). | The judge's practices are **not** checked (see Known gaps 2). The caption gives the judge as a line. |
| LCvR 7.D (same) | Every motion is accompanied by a proposed order. | Not produced here (a separate document). |
| Fed. R. Civ. P. 12(b)(6) (https://www.law.cornell.edu/rules/frcp/rule_12, currency "amended Apr. 2, 2024, eff. Dec. 1, 2024") | A motion asserting "failure to state a claim upon which relief can be granted". | Title of the memorandum (frontmatter `title`); the legal standard in the sample. |
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10, "as amended Apr. 30, 2007, eff. Dec. 1, 2007") | Caption: court name, title, file number, and Rule 7(a) designation. | `caption()`: court title, the parties column, "Case No." (`case_label`) and the number, judge line, "Electronically Filed", and the title. |

Not produced by this template: the motion, the proposed order (LCvR 7.D), the table of authorities (see Known gaps 1), and a certificate of service (LCvR 5.3 says the filing itself represents service).

## Layout

- Page 1 (the caption page, numbered "i" but not printed): court title, caption grid, the memorandum title centered in bold capitals.
- Pages "ii" onward: "TABLE OF CONTENTS", generated from the headings, with dotted leaders and page numbers (roman for the front matter).
- Body from page 1 (arabic): level 1 headings are centered bold capitals with roman numerals (I., II., ...); level 2 are flush-left bold with letters (A., B., ...), with a hanging indent of 0.5 in; level 3 numbers (1., 2.) and level 4 letters (a., b.) are supported but not used by the sample. The template numbers every heading; the sample does not contain numbers.
- Paragraphs: first-line indent 0.5 in, double-spaced; block quotations single-spaced and indented.
- Footnotes: numbered by typst, in the body size, single-spaced at the foot of the page.
- Signature block: "Date:" line, "Respectfully submitted," and the signer's "s/" line with the attorney lines (names, bar numbers, email, firm, address, telephone and fax, and the "Attorneys for" line), single-spaced at the right half of the page.

## Markdown contract (for samples)

- YAML frontmatter: `case_label` (default "Civil Action No."), `case_number`, `judge` (optional), `caption` (a list of `{names, designation}`), `electronically_filed` (bool), `title`, `date`, `signature` (`lead`, optional `firm`, `signer`, `lines`).
- Body: `#` = section (level 1), `##` = level 2, `###` = level 3, `####` = level 4; a paragraph is any other chunk between blank lines; a chunk starting "> " is a block quotation; footnotes are `text[^key]` with a definition line `[^key]: text` anywhere in the file (the template attaches each definition to the paragraph that cites its key).
- Case names and signals in italics (`*Ashcroft v. Iqbal*`, `*Id.*`, `*See*`), as the markdown convention; the template does not guess which text is a case name.
- Not supported: tables, images, raw typst. Table of authorities: not generated (Known gaps 1).

## What the overlay shows

`samples/OVERLAY-albright-memorandum.pdf`: each page is red (our render) multiplied over blue (the filed exemplar's page with the most shared words). Black is where both agree. The pairing is by word overlap, not index (`samples/OVERLAY-albright-memorandum.txt`). Final map: ours p.1 to filed p.1 (94%), p.2 to p.2 (39%, the table of contents against the filing's table of authorities), p.3 to p.6 (91%), p.4 to p.7 (78%), p.5 to p.8 (50%), p.6 to p.21 (57%), p.7 to p.22 (95%), p.8 to p.23 (84%). The overlay is a diagnostic, not a score. The sample is an excerpt of the filing, so the pages it pairs with are the pages its text came from, not a page-for-page copy.

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

## Review of the rendered pages (Gate 2 rows, final PDF, 60 dpi)

Each page was rendered and viewed after the last template change (the heading-size and signature-offset changes). "Body n" is the printed footer; the front matter is the caption page (no number) and the table of contents (ii).

- Page 1 (caption, no number): court title, caption with the ")" column, the title, "Case No. 3:21-cv-00112-SLH", "Judge Stephanie L. Haines", "Electronically Filed". PASS.
- Page ii: TABLE OF CONTENTS; I. INTRODUCTION (1) with A. (1), B. (2), C. (2); II. FACTUAL BACKGROUND (3) with A. (3); III. LEGAL STANDARD (3); IV. ARGUMENT (4) with A. (4). Page numbers match the body headings on each page. PASS.
- Body 1: I. INTRODUCTION (centered, bold, body size); the introduction paragraph; A. heading (bold, flush left, wrapped line hangs); the two paragraphs of A. PASS.
- Body 2: the end of A.; B. heading and its paragraph (italic *Id.* and *See*); C. heading and its paragraph; the footnote reference "1" after "payable"; the footnote's first lines at the foot of the page. PASS.
- Body 3: the C. paragraph's last sentence and the footnote's last line ("calculation."); II. FACTUAL BACKGROUND (two lines, centered); A. Plaintiffs' Employment with CTC and its two paragraphs; III. LEGAL STANDARD heading and the start of its paragraph. PASS.
- Body 4: the legal-standard paragraph continues (Twombly, Iqbal, Fowler, Iqbal at 678); IV. ARGUMENT (centered); A. heading; the first punitive-damages paragraph with the *Northridge*, *Johnson*, *Mozzo*, *Hardt* and *Sunshine* citations. PASS.
- Body 5: the *Sunshine* citation's end; the Restatement paragraph (*Feld*, *Chambers*); the *Smith v. Brown* paragraph (with the "Pls. Compl. at p. 25" citation); the *Salvio* and *Allergino* paragraph. PASS.
- Body 6: the closing "Therefore, the Court should dismiss..." paragraph; "Date: September 7, 2021"; "Respectfully submitted,"; the signature block (s/ line, attorney names and bar numbers, firm, address, telephone and fax, "Attorneys for Defendants"). PASS.

Earlier review passes found and fixed: headings larger than the body text (the heading show rule had no size), a hanging indent missing for wrapped headings, a footnote-definition chunk printed as a paragraph (now attached to the citing paragraph), and a signature line that wrapped mid-name (the left offset was narrowed).

## Engines

- **typst** (primary, `typst/`): the reference for the court's form.
- **docx** (`docx/reference.docx`, `docx/pawd.lua`, `docx/build-reference.sh`; sample `samples/OUTPUT-albright-memorandum.docx`): built with pandoc 3.6.4 on the reference. Matches the typst template: EB Garamond 13 pt, exact 26 pt (double) line pitch, 1 in margins on US Letter, 0.5 in first-line indent, footnotes at the body size and single-spaced, headings numbered by the filter (I., A., 1., a.) with the typst indents, block quotations indented 1 in on both sides, the caption (a borderless table), the title, the "Date:" line and the signature block at 3 in, page number centered in the footer from 1 at the Introduction.
- Differences from typst: the contents page has no printed roman number (the caption page and the contents share a section without a footer, because a second footer needs a relationship id that pandoc assigns at build time); the contents entries have no page numbers (a TOC field, updated in Word or LibreOffice); the caption rows are spaced by the table, not the typst grid.
- **BLOCKED** (docx): no `checks.yaml` exists for this court, so no gate check ID can be listed. Every check measured on `samples/OUTPUT-albright-memorandum.docx.pdf` is BLOCKED with the reason "LibreOffice cannot run in the build box, so the .docx.pdf cannot be produced or checked". Also BLOCKED: the contents page numbers (TOC field, needs a field update, and LibreOffice cannot be run here to check them). The `.docx` passes the package checks run here (ziptool reads every entry, xmllint on every XML part, no duplicate style ids); it was not opened in Word or LibreOffice.
