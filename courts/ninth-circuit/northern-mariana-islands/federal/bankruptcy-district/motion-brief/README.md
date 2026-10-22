# Bankruptcy Court, District of the Northern Mariana Islands (nmib): motion with memorandum

Doc type: **motion-brief** (motion with a memorandum of law under the Bankruptcy Rules and the court's local bankruptcy rules).
Folder: `courts/ninth-circuit/northern-mariana-islands/federal/bankruptcy-district/motion-brief/`. Nothing here sets `court.json` status.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (portion of the filing: cover, TOC, TOA, preliminary statement, ¶¶ 1–17, Argument A opening, conclusion, signature) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` and `usage/OUTPUT-motion-brief.docx` / `.docx.pdf`, 9 pages each, typst 0.15.0 and LibreOffice, vendored Times New Roman only (`pdffonts`), no warnings |
| typeface | face required: none (LR 5.2(a): 12 point or larger, "serif font"); font set: Times New Roman 12 pt (the house standard and the exemplar's face), typst `("Times New Roman", "Liberation Serif")`, the docx through `{font}` in `docx/reference.xml` |
| checks | `sh tools/check.sh <dir>`: 9 passed, 0 failed; `--engine docx`: 13 passed, 0 failed, XENG-001..003 PASS (248/248 lines), `params.cross_engine: gate` |
| overlay | ok: `usage/OVERLAY-imperial-pacific-memo.pdf` and `OVERLAY-imperial-pacific-memo.txt` (exemplar re-fetched 2026-10-15 from the URL in `usage/SOURCE.md`; the PDF was missing from the snapshot) |
| pages reviewed | 9 of 9 on both engines (every page rendered at 60 dpi and viewed on 2026-10-22) |
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
| NMIB-FORM-002 | LR 5.2(a) (District Court local rules, LR20171101.pdf, read 2026-10-15; LBR 9004-1 cross-refers to it) | "12-point type or larger and in a serif font". No face named. | **Primary text** (court's own PDF); the courtrules.net summary above is consistent with it. | `font-family` (Times New Roman, the house standard and the exemplar's face; any serif satisfies the rule), `type-size` 12 pt |
| NMIB-FORM-003 | LR 5.2 (summary above) | Double spacing, one body line per numbered line. | same summary | `pitch` 24 pt (exact line boxes, `lib/typst/xengine.typ`); single lines `pitch-single` 12 pt |
| NMIB-FORM-004 | LR 5.2 summary and the filed exemplar | Numbering down the left margin, 24 lines per page (the exemplar has 24). | summary + exemplar | `line-numbers()`, `pleading-rules()`, `lines-per-page` |
| NMIB-MOT-001 | LBR 9013-1(c)(1) | A filing that requires a hearing shows the hearing date on its first page (LR 5.2(e), LR 7.1). The filing party gives notice not later than 34 days before the hearing. | primary LBR text, read 2026-10-14 | cover (`hearing`); the 34-day notice is the author's duty, not checked |
| NMIB-MOT-002 | FRBP 9013 (Cornell LII, read 2026-10-14) | A motion must state its grounds with particularity and set out the relief requested. | Fed. R. Bankr. P. 9013 | body (author-written; not checked) |
| NMIB-MOT-003 | LR 7.1 (summary: 25-page cap on memoranda) and LBR 9013-1(d)(4) (cross-refers to LBR 9013-2) | Memorandum length limit. | LR 7.1 summary (aggregator, unverified); LBR 9013-2 text not found in the PDF copy | not checked (no page counter) |
| NMIB-CONT-001 | Convention (exemplar) | Table of contents and table of authorities, generated from headings and `toa:` links. The rules do not require them for this court; the filed exemplar has both. | exemplar | `toc-section`, `toa-section` |
| NMIB-CONT-002 | Convention (exemplar) | Argument sub-headings lettered A., B. and numbered 1., 2. and lettered a., b. | exemplar | `heading-num` |

Not generated here: a notice of motion (the exemplar is the memorandum only; a motion and a proposed order are separate filings); the certificate of service (LBR 7004-1 applies to service of process in adversary proceedings, not to motions in a case); a declaration (separate). The signature block is a convention drawn from the exemplar: the rules do not prescribe its form.

## Layout

- Numbered lines 1 to 24 down the left margin, a double rule at the text's left edge and a single rule at its right (pleading form).
- Top margin 1.5 in, 24 numbered lines of 24 pt, so the bottom margin is 1.5 in (at least the 1 in of LR 5.2; `eval.yaml` `margin_bottom_pt: 108`); left 1.3 in, right 1 in. The shared cross-engine layout model (`lib/typst/xengine.typ`): every line a box of its pitch with the baseline at 0.8 of it, body baselines on the numbers.
- Single-spaced parts (counsel block, caption, tables of contents and authorities, signature) are 12 pt lines whose odd lines stand on the numbers (the counsel block starts 9.6 pt down) and whose even lines fall halfway between.
- Headings are numbered lines with a numbered line above, kept with the text. Level 1 (PRELIMINARY STATEMENT, JURISDICTION AND VENUE, BACKGROUND, ARGUMENT, CONCLUSION) centered bold caps. Level 2 lettered (A., B.), level 3 numbered (1.), level 4 lettered (a.): bold, the label in a half-inch box, the lines after the first hanging.
- Tables of contents and authorities: a blank single line between entries; the text wraps before a page column (36 pt contents, 72 pt authorities), a dot leader to the page.
- Paragraphs: the sample types the paragraph numbers as filed (`1\.`), and the template does not number them.
- Footer: the page number only, 6 pt under line 24 (none on the cover; i, ii on the tables; 1, 2 on the memorandum). The court's ECF header is not reproduced.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`; `chapter`; `court` (list of lines, centered caps); `counsel` (lines, single-spaced); `counsel_role` (italic line under the counsel block); `caption` (list of sides, each `names` and `designation`; "v." is inserted between sides); `brief_title`; `hearing` (`date`, `time`, `judge`; omit the block if the document is not the subject of a hearing); `signature` (list of signers, each `signer` and `lines`); `date`; `authorities` (registry, see below).
- Body: `# Heading` (level 1, centered caps); `## Heading` (level 2, lettered); `### Heading` (level 3, numbered); paragraphs; `**bold lead-in**` as a standalone paragraph for unnumbered sub-headings (the exemplar's background sub-heads are of that kind).
- Authorities: cite with a link whose target is `toa:KEY`, e.g. `[11 U.S.C. § 361](toa:usc-361)`. Each `KEY` is in `authorities:`; an unknown key stops the build. `kind` is `case`, `statute`, `rule`, `local` or `other`. Cases print the `name` in italics, then `cite`. An authority cited on 7 or more pages prints "passim".
- Paragraph numbers typed in the body as `1\.`; the escape is needed because markdown would otherwise make a numbered list.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"
sh tools/render.sh courts/ninth-circuit/northern-mariana-islands/federal/bankruptcy-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/ninth-circuit/northern-mariana-islands/federal/bankruptcy-district/motion-brief imperial-pacific-memo \
  courts/ninth-circuit/northern-mariana-islands/federal/bankruptcy-district/motion-brief/usage/FILED-EXAMPLE-motion-brief.pdf
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

### Gate 2 review of the current renders (fb-595.68.23, 2026-10-22)

The committed `usage/OUTPUT-motion-brief.typst.pdf` and `.docx.pdf`, every page rasterized at 60 dpi (`pdftoppm -r 60`) and viewed side by side. Page numbers below are PDF pages (printed label in brackets).

| Page | Engine | What it is | Finding | Status |
|---|---|---|---|---|
| 1 (cover) | typst | counsel blocks and role (lines 1 to 6), court title (lines 8 to 9), caption with hearing data | Counsel on and between the numbers; "In re" once (was printed twice); party column ruled at right and foot over the full row; title bold caps; hearing date, time and judge; no page number. | OK |
| 1 (cover) | docx | the same | Same lines and positions as typst (baselines 0.00 pt apart). | OK |
| 2 (i) | typst | table of contents | "Page" over the column; entries one per number; argument entry A. wraps under its title; leader to the page column; pages 1, 2, 3, 5, 5, 5. | OK |
| 2 (i) | docx | the same | Same entries, breaks and pages (from the needles); Word's leader runs to the number (documented design difference, not a word difference). | ACCEPTED |
| 3 (ii) | typst | table of authorities | Cases, statutes, rules, local rules as groups; "2, 6" for 11 U.S.C. § 361. | OK |
| 3 (ii) | docx | the same | Same entries and pages; leader as on page 2. | ACCEPTED |
| 4 (1) | typst | preliminary statement | Every line on a number; first-line indents. | OK |
| 4 (1) | docx | the same | Identical breaks. | OK |
| 5 (2) | typst | end of preliminary statement, jurisdiction and venue ¶¶ 1 to 4 | Heading with a numbered line above. | OK |
| 5 (2) | docx | the same | Identical breaks. | OK |
| 6 (3) | typst | background ¶¶ 5 to 10, "Fanter's Judgment…" | Bold lead-in paragraph; italic case name. | OK |
| 6 (3) | docx | the same | Identical breaks. | OK |
| 7 (4) | typst | background ¶¶ 10 to 15, "Gray's Judgment…" | Unnumbered "Movants are advised" paragraph as filed. | OK |
| 7 (4) | docx | the same | Identical breaks. | OK |
| 8 (5) | typst | ¶¶ 16 to 17, ARGUMENT, heading A. (three lines, hanging), ¶ 40, CONCLUSION | Label in its box, heading lines hang; numbered line above each heading. | OK |
| 8 (5) | docx | the same | Identical breaks. | OK |
| 9 (6) | typst | end of conclusion (11 lines) and signature block | Signature follows the conclusion's last lines on the same page; three signers with ruled signature lines. | OK |
| 9 (6) | docx | the same | Identical; the signature line is an underlined tab. | OK |

## Known gaps and open choices

1. **Signature with the final text.** Fixed in the current render: with 24 lines a page the conclusion runs onto page 9 (6) and the signature block follows it there. The template still has no rule that keeps the last paragraph with the signature block (the block itself is unbreakable); a sample whose text ends at a page foot could leave the signature alone on its page.
2. **LR 5.2 and LR 7.1 are from a third-party summary.** The courtrules.net page returned HTTP 403, so the margins, the 12-point serif floor and the 24 numbered lines come from the search-result summary and the filed exemplar. Verify against the District Court's LR 5.2 text before this template is treated as complete.
3. **Local bankruptcy rules: version.** The PDF read (`lbkr20181217.pdf`, titled "Local Bankruptcy Rules", 69 pp.) is the document the court published; the adopting order (General Order 19-00003, effective April 15, 2019) adopts the rules "as published on the court's website." The file name indicates the December 17, 2018 version; the adopted text was not checked against it.
4. **Memorandum length (LR 7.1, 25 pages; LBR 9013-2).** Not checked: the template has no page counter. LBR 9013-2 is cross-referenced from LBR 9013-1(d)(4) but its text was not in the PDF copy read.
5. **Font.** Times New Roman 12 pt on both engines (fb-595.68.23; typst was Times New Roman 13 pt, the docx EB Garamond 13 pt). LR 5.2(a) (District Court local rules, LR20171101.pdf, read 2026-10-15) requires "12-point type or larger and in a serif font" and names no face; Times New Roman is the house standard and the filing's face.
6. **Chapter line.** The filed exemplar's caption shows no chapter line; LBR 5005-1(b)(1) (primary text read) requires it. The template and sample include "Chapter 11". Transcribed text otherwise follows the filing.
7. **Exemplar errors reproduced in the sample, not in the template.** The filing repeats "(iv)" in the conclusion's relief list (the sample keeps it as filed); the body cites "No. 21-cv-0035" for *Fanter v. IPI* while the TOA cites "20-cv-0035" (the sample keeps both as filed).
8. **Grid.** Body lines and headings stand on the numbers; the single-spaced parts (cover, tables, signature) put every other line on a number and the rest halfway between.
9. **Tier 2 (second filer).** One exemplar. Searches for a second NMI bankruptcy motion or memorandum with text: Justia `nmib` listing (7 cases; only this one has a motion-type PDF), CourtListener search (403), and web searches for the court's motions (returned rules and general orders only). Not done.
10. **Checks.** `sh tools/check.sh <dir>` (typst 9 passed, 0 failed) and `--engine docx` (13 passed, 0 failed, DEF-TOC-001 and DEF-COVER-001 included) run on this folder. `tools/check-selftest.sh` needs a `court.json` in the folder and does not run on a doc-type folder.
11. **Footnotes in the docx.** The typst template sets footnotes; the docx filter does not handle them yet (a note's text would be run into its paragraph). The sample has none, so the gate is not affected; a sample with footnotes needs the filter extended first.

## Engines

- **typst** (primary): `typst/`, as above, on the shared cross-engine layout model (`lib/typst/xengine.typ`).
- **docx** (fb-595.68.23): no shell and no committed `reference.docx`. `fb render` builds the reference document from `docx/reference.xml` (`base="xengine"`: Times New Roman through `{font}`, 12 pt, 24 pt body lines, 12 pt single lines, half-inch indent). `docx/nmib-motion-brief.lua` (on `require("docx.xengine")`) writes every paragraph with the typst pitches and spacings: cover, caption table, tables of contents and authorities, labelled headings, body and signature table, in three sections (cover unnumbered, tables i, ii, memorandum 1, 2). The table pages are real: the filter writes needles (`FORMBOOK_NEEDLES`: the contents' title, each heading with its label and the words after it, each `toa:` link with the words after it), and `fb render` feeds their pages in the LibreOffice PDF back (`FORMBOOK_PAGES`) until they settle; "passim" from 7 pages. Footers through `FORMBOOK_FOOTERS` (the numbers 1 to 24 in a frame where typst draws them, the pleading rules the full page height as VML lines, the page number) and the last section through `FORMBOOK_FINAL`. Known gap: footnotes (gap 11).
- **Cross-engine gate:** XENG-001..003 PASS (248/248 typst lines broken alike, baselines 0.00 pt apart); `eval.yaml` sets `params.cross_engine: gate`. Every page of `usage/OUTPUT-motion-brief.docx.pdf` viewed (Gate 2 table above). Word itself was not opened; Word may paginate slightly differently from LibreOffice.
