# Bankruptcy Court, District of the Northern Mariana Islands (nmib): motion with memorandum

Doc type: **motion-brief** (motion with a memorandum of law under the Bankruptcy Rules and the court's local bankruptcy rules).
Folder: `courts/ninth-circuit/northern-mariana-islands/federal/bankruptcy-district/motion-brief/`. Nothing here sets `court.json` status.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-nmib-motion-brief-imperialpacific24bk00002.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-nmib-motion-brief-imperialpacificmemo.md` (portion of the filing: cover, TOC, TOA, preliminary statement, ¶¶ 1–17, Argument A opening, conclusion, signature) |
| render | ok: `usage/OUTPUT-nmib-motion-brief-imperialpacificmemo.typst.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only (`pdffonts`), no warnings |
| typeface | face required: none (LR 5.2(a): "serif font"); font kept: EB Garamond (serif, vendored); no substitute needed |
| overlay | ok: `usage/OVERLAY-imperial-pacific-memo.pdf` and `OVERLAY-imperial-pacific-memo.txt` (exemplar re-fetched 2026-10-15 from the URL in `usage/SOURCE.md`; the PDF was missing from the snapshot) |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed on 2026-10-15) |
| tier 2 | not judged against a second filer (none found for this court; see gaps) |

File names: the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (the names `tools/render.sh` and `tools/overlay.sh` use), so the sample is `INPUT-<id>.md` and the outputs follow the tool names, not `<id>.pdf` / `<id>-overlay.pdf`.

## Governing rules

Requirement IDs are `NMIB-...`. Each row says where the rule text came from. Two sources are primary (the court's local bankruptcy rules, and the Federal Rules of Bankruptcy Procedure); one is a third-party summary (LR 5.2 and LR 7.1), flagged.

| ID | Rule | Requirement | Source (date read) | Where in the template |
|---|---|---|---|---|
| NMIB-SRC-001 | LBR 1001-1 | The local bankruptcy rules govern all bankruptcy cases and proceedings in the District Court for the Northern Mariana Islands; cited as "LBR". | Court PDF `nmid.uscourts.gov/sites/nmid/files/lbkr20181217.pdf` (69 pp., title "Local Bankruptcy Rules"), read 2026-10-14 | — |
| NMIB-CAP-001 | LBR 5005-1(b)(1) | The caption includes the chapter of the Bankruptcy Code under which the case is pending. | same PDF | `chapter` field; cover, "Chapter 11" in the right column |
| NMIB-CAP-002 | LBR 5005-1(b)(2) | If the document is the subject of a hearing: the date and time and the presiding judge, in the caption. | same PDF | `hearing` field (date, time, judge); cover right column |
| NMIB-FORM-001 | LBR 9004-1 → LR 5.2 (form of papers) | Documents comply with LR 5.2 and Appendix A. Summary of the bankruptcy-court LR 5.2: 8½ × 11 in white paper; double-spaced text with numbering down the left margin (block quotes, footnotes and headings may be single-spaced); serif text at least 12 point; top margin at least 1.5 in, bottom at least 1 in, right at least 0.5 in, left at least 1 in; the top 3 in of the first page's upper right corner reserved for the clerk. | **Third-party summary** (courtrules.net LR 5.2 page; the page itself returned HTTP 403 to the tool, the figures are from the search result summary). Not verified against the court's text. | `margins` and `page-w`/`page-h` constants; `top-margin` 1.5 in |
| NMIB-FORM-002 | LR 5.2(a) (District Court local rules, LR20171101.pdf, read 2026-10-15; LBR 9004-1 cross-refers to it) | "12-point type or larger and in a serif font". No face named. | **Primary text** (court's own PDF); the courtrules.net summary above is consistent with it. | `font-family` (EB Garamond, vendored; any serif satisfies the rule, so no substitute), `type-size` 13 pt (style choice; see gaps) |
| NMIB-FORM-003 | LR 5.2 (summary above) | Double spacing, one body line per numbered line. | same summary | `pitch` 24 pt, `body-leading` |
| NMIB-FORM-004 | LR 5.2 summary and the filed exemplar | Numbering down the left margin, 24 lines per page (the exemplar has 24). | summary + exemplar | `line-numbers()`, `pleading-rules()`, `lines-per-page` |
| NMIB-MOT-001 | LBR 9013-1(c)(1) | A filing that requires a hearing shows the hearing date on its first page (LR 5.2(e), LR 7.1). The filing party gives notice not later than 34 days before the hearing. | primary LBR text, read 2026-10-14 | cover (`hearing`); the 34-day notice is the author's duty, not checked |
| NMIB-MOT-002 | FRBP 9013 (Cornell LII, read 2026-10-14) | A motion must state its grounds with particularity and set out the relief requested. | Fed. R. Bankr. P. 9013 | body (author-written; not checked) |
| NMIB-MOT-003 | LR 7.1 (summary: 25-page cap on memoranda) and LBR 9013-1(d)(4) (cross-refers to LBR 9013-2) | Memorandum length limit. | LR 7.1 summary (aggregator, unverified); LBR 9013-2 text not found in the PDF copy | not checked (no page counter) |
| NMIB-CONT-001 | Convention (exemplar) | Table of contents and table of authorities, generated from headings and `toa:` links. The rules do not require them for this court; the filed exemplar has both. | exemplar | `toc-section`, `toa-section` |
| NMIB-CONT-002 | Convention (exemplar) | Argument sub-headings lettered A., B. and numbered 1., 2. and lettered a., b. | exemplar | `heading-num` |

Not generated here: a notice of motion (the exemplar is the memorandum only; a motion and a proposed order are separate filings); the certificate of service (LBR 7004-1 applies to service of process in adversary proceedings, not to motions in a case); a declaration (separate). The signature block is a convention drawn from the exemplar: the rules do not prescribe its form.

## Layout

- Numbered lines 1 to 24 down the left margin, a double rule at the text's left edge and a single rule at its right (pleading form).
- Top margin 1.5 in, bottom 1 in, left 1.3 in, right 1 in. Body text is double-spaced on the 24 pt pitch; sub-headings and single-spaced blocks are rounded up to whole pitches (`on-grid`) so the body stays on the numbers.
- Level 1 headings (PRELIMINARY STATEMENT, JURISDICTION AND VENUE, BACKGROUND, ARGUMENT, CONCLUSION) are centered bold caps on one numbered line. Level 2 headings are lettered (A., B.), bold, hanging. Level 3 is numbered (1.), level 4 lettered (a.).
- Paragraphs: the sample types the paragraph numbers as filed (`1\.`), and the template does not number them. The cover, TOC and TOA are single-spaced and sit off the grid; the numbers still run down the margin.
- Footer: the page number only (no paper title; the court's ECF header is not reproduced).

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`; `chapter`; `court` (list of lines, centered caps); `counsel` (lines, single-spaced); `counsel_role` (italic line under the counsel block); `caption` (list of sides, each `names` and `designation`; "v." is inserted between sides); `brief_title`; `hearing` (`date`, `time`, `judge`; omit the block if the document is not the subject of a hearing); `signature` (list of signers, each `signer` and `lines`); `date`; `authorities` (registry, see below).
- Body: `# Heading` (level 1, centered caps); `## Heading` (level 2, lettered); `### Heading` (level 3, numbered); paragraphs; `**bold lead-in**` as a standalone paragraph for unnumbered sub-headings (the exemplar's background sub-heads are of that kind).
- Authorities: cite with a link whose target is `toa:KEY`, e.g. `[11 U.S.C. § 361](toa:usc-361)`. Each `KEY` is in `authorities:`; an unknown key stops the build. `kind` is `case`, `statute`, `rule`, `local` or `other`. Cases print the `name` in italics, then `cite`. An authority cited on 7 or more pages prints "passim".
- Paragraph numbers typed in the body as `1\.`; the escape is needed because markdown would otherwise make a numbered list.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"
sh tools/render.sh courts/ninth-circuit/northern-mariana-islands/federal/bankruptcy-district/motion-brief usage/INPUT-nmib-motion-brief-imperialpacificmemo.md
sh tools/overlay.sh courts/ninth-circuit/northern-mariana-islands/federal/bankruptcy-district/motion-brief imperial-pacific-memo \
  courts/ninth-circuit/northern-mariana-islands/federal/bankruptcy-district/motion-brief/usage/SAMPLE-nmib-motion-brief-imperialpacific24bk00002.pdf
```

Overlay page map (`usage/OVERLAY-imperial-pacific-memo.txt`): ours p.1 ↔ filed p.1 (89.5%); p.2 ↔ p.2 (30.5%, the cover and TOC share few words); p.3 ↔ p.4 (13.4%, the TOA against the filed TOA); p.4 ↔ p.7; p.5 ↔ p.8; p.6 ↔ p.9; p.7 ↔ p.10; p.8 ↔ p.15 (59%); p.9 ↔ p.31 (20.5%, the signature page against the filed signature page). Red is our render; blue is the filed exemplar; black is both. The overlay is a diagnostic, not a score: the filing is a Word document with its own line spacing, and only the sample's transcribed pages have a counterpart.

## Visual review (Gate 2 record, all 9 pages, rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 (cover) | Counsel block, court title, caption, title, hearing | OK after two fixes: the designation indent (wrapped "Debtor and Debtor-in-Possession" badly at 1.8 in; now 1.0 in) and the chapter line added. Line numbers run down the margin. |
| i (TOC) | Table of contents | OK. Page numbers in their own column; the lettered argument entry wraps under its title. |
| ii (TOA) | Table of authorities | OK. Cases, statutes, rules and local rules in separate groups; "2, 5" for a multiply-cited statute. |
| 1 | Preliminary statement | OK. Text sits on the numbered lines; first-line indent; heading centered. |
| 2 | Jurisdiction and venue; background ¶¶ 5–6 | OK after the level-1 heading gap (a full line above) and sub-heading spacing were fixed (see the change log below). |
| 3 | Background ¶¶ 7–12, the sub-heading "Fanter's Judgment…" | OK. Bold sub-heading, numbered paragraphs, the "Movants are advised" paragraph unnumbered as filed. |
| 4 | Background ¶¶ 13–17, sub-heading "Gray's Judgment…" | OK. Italic case names and *Id.* throughout. |
| 5 | Argument heading A (level 2, hanging), ¶ 40, conclusion | OK. The argument heading is bold and hangs; the conclusion follows with a full line above its heading. |
| 6 | Signature block | Defect, not fixed: the signature block is alone on its page. The conclusion ends on page 5, and the block does not fit beneath it. A "keep with last paragraph" rule is not in the template (see gaps). |

Change log for this review (each change re-rendered and re-viewed): (1) caption designation indent 1.8 → 1.0 in; (2) heading text forced to the body size (headings had inherited a larger default); (3) signature line drawn as a rule under "/s/" (was the reverse order and used underscores, which typst reads as emphasis markers and fails on); (4) level-1 headings get one line above; (5) level-2 headings snap to whole pitches (`on-grid`), so body text stays on the numbers after them.

Reviewed pages: 9 of 9.

## Known gaps and open choices

1. **Signature alone on the final page (page 6).** The template does not keep the last paragraph with the signature block. A court filing usually keeps some text with its signature; the fix is a template rule (e.g. pulling the last paragraph onto the signature page) or a short final paragraph in the author's text. Not done; flagged for David.
2. **LR 5.2 and LR 7.1 are from a third-party summary.** The courtrules.net page returned HTTP 403, so the margins, the 12-point serif floor and the 24 numbered lines come from the search-result summary and the filed exemplar. Verify against the District Court's LR 5.2 text before this template is treated as complete.
3. **Local bankruptcy rules: version.** The PDF read (`lbkr20181217.pdf`, titled "Local Bankruptcy Rules", 69 pp.) is the document the court published; the adopting order (General Order 19-00003, effective April 15, 2019) adopts the rules "as published on the court's website." The file name indicates the December 17, 2018 version; the adopted text was not checked against it.
4. **Memorandum length (LR 7.1, 25 pages; LBR 9013-2).** Not checked: the template has no page counter. LBR 9013-2 is cross-referenced from LBR 9013-1(d)(4) but its text was not in the PDF copy read.
5. **Font.** EB Garamond at 13 pt (vendored, OFL), not Times New Roman as in the filing. LR 5.2(a) (District Court local rules, LR20171101.pdf, read 2026-10-15) requires "12-point type or larger and in a serif font" and names no face, so EB Garamond is kept and no Times substitute is used. EB Garamond sets smaller at the same size, so 13 pt is a style choice. The minimum in NMIB-FORM-002 is 12 pt.
6. **Chapter line.** The filed exemplar's caption shows no chapter line; LBR 5005-1(b)(1) (primary text read) requires it. The template and sample include "Chapter 11". Transcribed text otherwise follows the filing.
7. **Exemplar errors reproduced in the sample, not in the template.** The filing repeats "(iv)" in the conclusion's relief list (the sample keeps it as filed); the body cites "No. 21-cv-0035" for *Fanter v. IPI* while the TOA cites "20-cv-0035" (the sample keeps both as filed).
8. **Grid.** The cover, TOC and TOA are single-spaced and sit off the numbered grid. The body is on the grid, except the single-spaced counsel block and caption.
9. **Tier 2 (second filer).** One exemplar. Searches for a second NMI bankruptcy motion or memorandum with text: Justia `nmib` listing (7 cases; only this one has a motion-type PDF), CourtListener search (403), and web searches for the court's motions (returned rules and general orders only). Not done.
10. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder does not have that shape, and the brief forbids edits to `tools/`. The render (`tools/render.sh`, warnings fail) and the overlay were run; the review above is the Gate 2 equivalent for this doc type.

## Engines

- **typst** (primary): `typst/`, as above.
- **docx**: `docx/build-reference.sh` builds `docx/reference.docx` from pandoc's default reference (EB Garamond 13 pt, exact 24 pt line spacing, 0.5 in first-line indent, letter, margins 1.5 in top, 1 in bottom, 1.3 in left, 1 in right, pleading rules as page borders, line numbers 1 to 24 restarting each page, page number centered in the footer at 11 pt, footnotes 13 pt single spaced, headings centered caps (level 1) or bold with hanging labels (levels 2 to 4)). `docx/nmib-motion-brief.lua` writes the cover and the caption table, the table of contents field and the table of authorities, the heading labels (A., 1., a.) and the signature block, and makes three sections: the cover (no number), the front matter (i, ii, ...), the body (1, 2, ...). Built 2026-10-15: `usage/OUTPUT-nmib-motion-brief-imperialpacificmemo.docx` written by `tools/render.sh --engine docx`; `unzip -tq` OK; every XML part `xmllint --noout` OK. `docx/reference.docx` is built by `docx/build-reference.sh`.
- **Matches the typst form:** typeface and size, double spacing, indents, margins, pleading rules, numbers 1 to 24, page-number format per section, footnote size, heading style and labels, cover and caption layout, signature block.
- **Differs from the typst form:**
  - Table of contents: a TOC field. Its page numbers appear only after the fields are updated; the file asks Word to update fields on open (`w:updateFields`). The cached text says so.
  - Table of authorities: lists each authority the body cites, grouped as in the typst form, without page numbers and without "passim".
  - Word's line numbering skips tables, so the caption and signature table rows carry no line numbers; the counsel block and the caption are single spaced, not on the 24-point grid.
  - Word and LibreOffice paginate differently; page numbers may be off by a page in one of them.
- **BLOCKED (docx.pdf gates 0 and 1, and the page review):** LibreOffice (`soffice`) is not installed on this box, so `usage/OUTPUT-imperial-pacific-memo.docx.pdf` was not made and no page of the `.docx` was viewed; the `.docx` was not opened in Word either. Checks that cannot pass by construction: the TOC page numbers (field, updated only on open), the TOA page numbers (a TOA field is not honored by LibreOffice, and the filter writes no page numbers), and line numbers on the caption and signature tables.
