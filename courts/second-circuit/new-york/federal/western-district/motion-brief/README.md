# nywd: motion-brief

Doc type: **motion-brief**: a memorandum of law in support of a motion to dismiss under Fed. R. Civ. P. 12(b)(6), in the United States District Court for the Western District of New York (`nywd`).
Folder: `courts/second-circuit/new-york/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (Defendants' memorandum, one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the memorandum's text from the text layer, body complete except footnotes; see Known gaps) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 13 pages (cover, table of contents, 11 pages of text), typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-kerrick-motion-brief.pdf` and `usage/OVERLAY-kerrick-motion-brief.txt` |
| pages reviewed | 13 of 13 rendered at 60 dpi and viewed, in the final state (pages 1 to 9 viewed before the last text change, which does not reach them; pages 10 to 13 re-viewed after it) |

## Governing rules

Primary sources, fetched 2026-10-14:

- W.D.N.Y. Local Civil Rules (2025 edition, "2025 Local Rules of Civil Procedure FINAL - v3-1.pdf"), https://www.nywd.uscourts.gov/sites/nywd/files/2025%20Local%20Rules%20of%20Civil%20Procedure%20FINAL%20-%20v3-1.pdf, linked from https://www.nywd.uscourts.gov/rules-individual-local-federal. No later edition was found on that page on the fetch date. Rules 7 and 10 are used here.
- Fed. R. Civ. P. 7(b), 11(a) and 12(b), from the Legal Information Institute (https://www.law.cornell.edu/rules/frcp/rule_7, `rule_12`), fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| L.R. Civ. P. 7(a)(1) | A notice of motion is required for all motions; it states the relief, the grounds, and the papers submitted. | Not produced (a separate filing; see Known gaps). |
| L.R. Civ. P. 7(a)(2)(A) | On a motion under Rule 12, the moving party files a memorandum of law. | This template is that memorandum. |
| L.R. Civ. P. 7(a)(2)(C) | A memorandum in support of a motion may not exceed 25 pages; tables of contents and tables of authorities are not counted. | The template does not count pages. The sample body is 11 pages. The cover, TOC and TOA are not counted (the TOA is not generated; see Known gaps). |
| L.R. Civ. P. 10(a)(1) | All text and footnotes at least 12-point type. | `type-size = 12pt` everywhere. |
| L.R. Civ. P. 10(a)(2) | Body text double-spaced; block quotations and footnotes may be single-spaced. | `body-leading = 1.35em` with paragraph spacing of the same amount (24 pt pitch at 12 pt). Block quotations single-spaced and indented. |
| L.R. Civ. P. 10(a)(3) | Footnotes and block quotes may not circumvent page limits. | No footnotes are supported by the template. |
| L.R. Civ. P. 10(a)(4) | At least one-inch margins on all four sides. | `margin = 1in`. |
| L.R. Civ. P. 10(a)(5) | Pages consecutively numbered. | Front matter (TOC) numbered in roman numerals, the body in arabic from 1. The cover is unnumbered. This reading of "consecutively" is a judgment (see Known gaps). |
| Fed. R. Civ. P. 7(b)(1) | A request for a court order must be made by motion, in writing, stating the grounds and the relief sought. | The memorandum's Conclusion states the relief; the grounds are in the body. The motion itself is the notice of motion (not produced). |
| Fed. R. Civ. P. 12(b)(6) | Defense of failure to state a claim, made by motion. | Content only (the sample argues Rule 12(b)(6) in the legal standard and the conclusion). |
| Fed. R. Civ. P. 11(a) | Signer's name, address, telephone and email on the paper. | Signature block after the Conclusion: `Dated:`, firm, `By:`, signer, lines. |

Court-mandated (tier 1): type size, double spacing, margins, page numbers, the 25-page limit (checked by a person, not the template), and the signature block. Convention (tier 2): the cover (court title, caption box, counsel block at right), the TOC generated from the headings, and the heading styles.

## Layout

- Cover (unnumbered): court title, caption box (parties left, `Case No.` right), the title in capitals, the counsel block at right.
- Table of contents (roman numeral page): generated from the headings with leader dots and page numbers.
- Body (arabic from 1): `#` is a section (centered bold capitals: PRELIMINARY STATEMENT, ALLEGATIONS IN THE COMPLAINT, PROCEDURAL HISTORY, ARGUMENT, CONCLUSION). `##` is numbered I., II., III. (bold, hanging); `###` is numbered A., B., C. (bold, indented). The numbers are counted by the template, not written in the sample. Paragraphs are not numbered, and the first line is indented. A `> ` line is a single-spaced indented block quotation.
- Signature block after the Conclusion: `Dated:` at left, firm and signer at right, kept together.

Markdown contract for samples: YAML frontmatter (`case_number`, `caption.parties`, `title`, `counsel` (a list of groups with `names` (the first is the bold firm line) and `lines`), `date`, `signature` with `firm`, `by`, `signer`, `lines`), then the body. Blank lines separate blocks. `*text*` is italic, so a literal star (the LEXIS star-page cite, "at \*4") is written `\*`.

## Overlay

`usage/OVERLAY-kerrick-motion-brief.pdf`: red is our render only, blue is the filed exemplar only, black is both. Pairing (`usage/OVERLAY-kerrick-motion-brief.txt`): ours 1 to 13 pair with filed 1, 2, 6, 8, 9, 10, 12, 13, 14, 15, 17, 18, 19. The cover and the TOC pair with the filed cover and TOC; the body pairs with the filed body pages by shared words. Filed pages 3, 4, 5, 7, 11 and 16 are not paired: filed pages 3 and 4 are the table of authorities, which the sample does not have. The pairing is by text, so the overlay is a diagnostic and not a score.

## Known gaps and open choices

1. **Table of authorities not generated.** The exemplar has one (filed pages 3 and 4). The rules do not require one; building it needs a registry of every authority and its page, which is not in place. The TOA is absent from the render, and the filed TOA pages are not paired in the overlay.
2. **Footnotes not supported and not transcribed.** The filed memorandum has four footnotes: (1) the note that page references are to the New York State Courts Electronic Filing System pagination, (2) the reservation of the res judicata defense (with a citation to *Weston Funding*), (3) the note that the Article 78 filings are attached to the Lefkowitz Declaration, and (4) the alternative accrual date in Section III.A. The template has no footnote support and the sample leaves all four out. Local Rule 10(a)(3) limits footnotes, and footnote text would need 12 pt type if added.
3. **Notice of motion and declaration not produced** (L.R. Civ. P. 7(a)(1); the Lefkowitz declaration is a separate filing).
4. **Page limit not checked.** The 25-page limit of L.R. Civ. P. 7(a)(2)(C) applies to the text; the template does not count it. The sample is 11 pages of text.
5. **Page numbering.** The front matter is roman and the body arabic from 1. Local Rule 10(a)(5) says "consecutively numbered"; the rule text does not say whether front matter continues the arabic sequence. Recorded as a judgment.
6. **Font.** The rules name no typeface. EB Garamond (vendored) is used; it reads smaller than the Calisto/Times exemplar at 12 pt. Meets the rule as written.
7. **Italics** in the sample were applied by reading the exemplar's text layer and its italic font runs. The filed memorandum italicizes case names and signals; those in the sample are italic, the rest roman. Not verified glyph by glyph.


## Review of the rendered pages (Gate 2)

Every page was rendered with `pdftoppm -r 60` and viewed. PDF page numbers are used below (the body starts at PDF page 3).

- PDF page 1 (cover): court title, caption box with `Case No. 6:26-cv-06006 (MAV)`, title in capitals (wraps "DISMISS" to a second line), counsel block at right. Pass.
- PDF page 2 (table of contents, roman "i"): all section and sub-section headings with leader dots and page numbers that match the body (1 to 11). Pass. (First render numbered it "ii"; fixed by resetting the page counter.)
- PDF page 3 (body 1): PRELIMINARY STATEMENT and I. Plaintiff's Employment (start). Pass.
- PDF page 4 (body 2): II. Events, III. Post-Termination, PROCEDURAL HISTORY. Pass.
- PDF page 5 (body 3): ARGUMENT, I. Legal Standard; star pin cites ("at \*4", "at \*10") print correctly. Pass.
- PDF page 6 (body 4): II. heading (two lines, hanging), A. heading, and the Peters pin cite "at \*9" prints. Pass.
- PDF page 7 (body 5): B. heading and the Henry case introduced at the foot of the page. Pass.
- PDF page 8 (body 6): Henry block quote (single-spaced, indented); Wolfe pin cite "at \*9"; C. heading. Pass.
- PDF page 9 (body 7): actual notice and opportunity to respond. Pass.
- PDF page 10 (body 8): constitutionally sufficient process; III. heading. Pass.
- PDF page 11 (body 9): III.A heading, notice-of-claim law. Pass.
- PDF page 12 (body 10): the notice-of-claim analysis and III.B heading. Pass (re-viewed after removing footnote text).
- PDF page 13 (body 11): CONCLUSION, `Dated: March 23, 2026`, firm and signer block. Pass.

## Rebuild

From the repo root, with the toolchain on PATH (see the brief's install lines):

```sh
sh tools/render.sh courts/second-circuit/new-york/federal/western-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/second-circuit/new-york/federal/western-district/motion-brief kerrick-motion-brief
```

`tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` reads it and writes `OVERLAY-<id>.pdf/.txt`. This folder keeps the names in the brief, so after the overlay run: `mv usage/OUTPUT-<id>.pdf usage/<id>.pdf`, `mv usage/OVERLAY-<id>.pdf usage/<id>-overlay.pdf`, `mv usage/OVERLAY-<id>.txt usage/<id>-overlay.txt`.

## Engines

DOCX (`docx/`): `docx/build-reference.sh` builds `docx/reference.docx` (EB Garamond, exact 24 pt body pitch, 15.6 pt single lines, headings at 17, 14.5 and 12 pt, three footers: none on the cover, lower roman on the table of contents, arabic from 1 on the body); `docx/nywd-motion-brief.lua` builds the cover, the table of contents (a TOC field with cached entries and dot leaders), the numbered headings (I., II., A.), the block quotations and the signature block; `docx/render.sh` runs two passes so that the table of contents shows page numbers: pass 1 is converted to PDF, each heading is found on its page, and pass 2 writes the `.docx`. Output: `usage/OUTPUT-motion-brief.docx` and `usage/OUTPUT-motion-brief.docx.pdf` (LibreOffice; converts with no error; 13 pages).

- Matches typst: the 13-page layout, cover contents, the table of contents entries and their page numbers (all 16 match the typst render), roman and arabic numbering, heading sizes per level, body pitch, block quotation, signature block.
- Differs: the table of contents is a Word TOC field whose page numbers were computed from the LibreOffice PDF; Word may paginate slightly differently, and an update of the field in Word would regenerate the entries from the headings. A heading's label is followed by a tab (text aligned at 0.5 in for level 2 and 1 in for level 3); typst leaves a small gap. The cover's counsel block and the space above the signature block differ by a few points. No table of authorities (as in typst; see Known gaps).
- Pages looked at: all 13 pages of `usage/OUTPUT-motion-brief.docx.pdf`, side by side with the typst render at 60 dpi.
- BLOCKED: `tools/check.sh --engine docx` cannot run for this folder: there is no `checks.yaml` (and no `court.json` at the doc-type level), so every Gate 0 to 3 check ID is BLOCKED, not passed. No stamp is written.
