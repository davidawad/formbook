# M.D.N.C. (ncmd): complaint

Doc type: **complaint** in the United States District Court for the Middle District of North Carolina (`ncmd`).
Folder: `courts/fourth-circuit/north-carolina/federal/middle-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-ncmd-complaint-prillaman26cv01154.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-ncmd-complaint-prillaman.md` (the whole complaint text, 78 allegations, prayer, signature) |
| render | ok: `usage/OUTPUT-ncmd-complaint-prillaman.typst.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-prillaman-complaint.pdf` and `OVERLAY-prillaman-complaint.txt` |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed; see the table below) |
| tier 2 | one exemplar only, so tier 2 is not judged against two or three filers (see gaps) |

## Governing rules

Primary source: M.D.N.C. Local Civil Rules, effective June 1, 2026 (adopted by the order of May 27, 2026). PDF: https://www.ncmd.uscourts.gov/sites/ncmd/files/mdnc%20local%20civil%20rules%2020260601.pdf (linked from https://www.ncmd.uscourts.gov/local-rules-and-orders). Fetched 2026-10-14; rule text read from that PDF with `pdftotext`.

Federal rules: Fed. R. Civ. P. 10(a) and 10(b), fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_10.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| NCMD-FORM-001 | LR 7.1(a) | Letter-size paper; single-sided; unfolded and bound at the top; numbered at the bottom; no manuscript cover. | `page` settings (paper, numbered footer) |
| NCMD-FORM-002 | LR 7.1(a) | "fixed-pitch type size no smaller than ten characters per inch or in a proportional font size no smaller than 13 point." This is a proportional font, so 13 pt. | `type-size = 13pt`, `font-family` |
| NCMD-FORM-003 | LR 7.1(a) | "Typewritten ... documents shall be double spaced." and "no more than 27 lines of regularly spaced text on a page." | `lines-per-page = 27`, `pitch = 23pt`, `body-leading` (see gap 2) |
| NCMD-FORM-004 | LR 7.1(a) | Margins: top "not less than one and one-quarter inches"; bottom, left and right "not less than one inch." | `top-margin = 1.25in`, `bottom-margin`, `side-margin` |
| NCMD-FIRST-001 | LR 7.1(b) | Signing party or attorney states telephone number, mailing address and e-mail address; attorneys state state bar number. | `signature` block; the template refuses to build without `bar_number`, `address`, `phone`, `email`, `role` |
| NCMD-FIRST-002 | Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `court`, `caption`, `case_number` (rendered as "Civil Action No."), `brief_title` |
| NCMD-PLD-001 | Fed. R. Civ. P. 10(b) | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." | `allegations()` numbers every paragraph, FRCP 10(b). The single-circumstance limit is an author check, not a template check. |
| NCMD-PLD-002 | Fed. R. Civ. P. 38(b) | Jury demand. | `jury_demand` puts "(Jury Trial Demanded)" in the caption; the demand is in the prayer, as in the exemplar. A separate demand paragraph is an author choice. |
| NCMD-PLD-003 | Fed. R. Civ. P. 8 | Statement of the grounds for jurisdiction, the claims and the relief sought. | Author content (not checked by the template). |

Not produced by this template (separate papers, not the complaint): the civil cover sheet (JS 44); the corporate-affiliation / Rule 7.1 disclosure statement (LR 7.7, Fed. R. Civ. P. 7.1); summonses. These may be required with the first filing and are not generated here.

## Layout

- Letter paper, 1.25 in top margin, 1 in bottom, left and right margins.
- Body is 13 pt EB Garamond on a 23 pt line pitch: 27 lines of text fit in the 630 pt text height (621 pt used). Measured with `pdftotext -bbox` on the render: 23.00 pt pitch on every body line.
- Caption: court title centred in two lines; a two-column caption, party names left (closed by a right and bottom rule), "Civil Action No.", title and "(Jury Trial Demanded)" right. No counsel block at the top of page 1: the exemplar has none, and LR 7.1(b) is met in the signature block.
- Headings: level 1 centred bold capitals; level 2 bold at the margin (sub-sections A. to H.); a heading is kept with the paragraph after it.
- Paragraphs are numbered 1, 2, ... with a 0.5 in first-line indent. A paragraph that ends with a colon stays with the list it introduces.
- The prayer and any heading named in `unnumbered_sections` are not numbered. The prayer list is numbered 1., 2., ... in the sample (the exemplar uses 1) ...).
- The last chunk (the prayer list) is kept with the signature block, so the sign-off never stands alone on a page.
- Footnotes are real typst footnotes (the exemplar has one, footnote 1).

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1, centred caps, not numbered if listed in `unnumbered_sections`), a `##` heading (sub-heading), a list (`- ` or `1. ` items), or a paragraph (numbered).
- A footnote definition sits on the line directly after the paragraph that references it, with no blank line between (so both are one chunk).
- Frontmatter fields: `case_number` (the number after "Civil Action No."), `court` (list of lines), `division` (optional), `caption.parties` (list of `{names, designation}`), `brief_title`, `jury_demand` (bool), `unnumbered_sections` (list), `date_line` (text after "This the"), `signature` (`firm`, `signer`, `bar_number`, `address` (list), `phone`, `email`, `role`).
- The sample does not type the paragraph numbers: the template numbers them.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/fourth-circuit/north-carolina/federal/middle-district/complaint usage/INPUT-ncmd-complaint-prillaman.md
sh tools/overlay.sh courts/fourth-circuit/north-carolina/federal/middle-district/complaint prillaman-complaint
```

- `usage/OUTPUT-ncmd-complaint-prillaman.typst.pdf`: 11 pages. typst compiled with no warnings. Fonts: EBGaramond-Regular, -Italic, -Bold only (`pdffonts`).
- `usage/OVERLAY-prillaman-complaint.pdf` and `.txt`: red is our render, blue the exemplar, black where both agree. The page map pairs pages by word overlap: ours p.1 to p.11 pair with filed p.1, 3, 4, 6, 8, 9, 11, 12, 14, 15, 15. The overlay is a diagnostic, not a score: the exemplar is Times with a different line grid, so the lines will not coincide.

## Visual review (every page rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption, title, "(Jury Trial Demanded)"; INTRODUCTION, paragraphs 1 to 4 | OK. Caption rule right and bottom; numbers and text on the grid. |
| 2 | Paragraphs 5 to 12; PARTIES, JURISDICTION AND VENUE headings | OK. Headings centred, kept with the next paragraph. |
| 3 | Paragraphs 13 to 21; ADMINISTRATIVE PREREQUISITES, FACTUAL ALLEGATIONS, A. | OK. |
| 4 | Paragraphs 22 to 32; B. and C. headings | OK. |
| 5 | Paragraphs 33 to 40; D. heading; footnote 1 at the foot of the page | OK. Footnote reads "1 Prillaman's husband was covered ...". |
| 6 | Paragraphs 41 to 50; E. and F. headings | OK. Paragraph 42 ends without a full stop, as in the filed text (transcribed, not corrected). |
| 7 | Paragraphs 51 to 58; G. heading (two lines) | OK. Two-line heading sits on the grid. |
| 8 | Paragraphs 59 to 66; H. heading; the bullet list; FIRST CLAIM FOR RELIEF heading | OK. Bullets are not numbered, as the exemplar's are not. |
| 9 | Paragraphs 67 to 75; SECOND CLAIM FOR RELIEF | OK. |
| 10 | Paragraphs 76 to 78; then white space | Expected: the prayer, WHEREFORE line, list and signature are kept together and moved to page 11. Not a defect. |
| 11 | PRAYER FOR RELIEF, WHEREFORE, items 1 to 5, date line, signature block | OK. The signature block holds bar number, address, phone and e-mail (LR 7.1(b)). |

Reviewed pages: 11 of 11. Pages 1 to 9 were reviewed on the render that carried the final body leading; later edits changed only the prayer and signature (page 10 onward).

## Known gaps and open choices

1. **One exemplar.** EVAL-LOOP's tier-2 rule asks for two or three filers. The search found three more MDNC complaints with text layers (listed in `usage/SOURCE.md`); they are not saved. Tier 2 is therefore **not** judged against two filers yet.
2. **"Double spaced" versus 27 lines.** The rule requires both double spacing and no more than 27 lines per page. At 13 pt a true double space (about 34 pt pitch) gives only 18 lines per page, which breaks the 27-line cap. The template uses the cap: 23 pt pitch, 27 lines, which is how 27-line filings are normally set. Whether the court reads "double spaced" as a fixed ratio is a question for David.
3. **Font (typeface: none required; EB Garamond kept).** LR 7.1(a) sets a size floor for a proportional font (13 pt) and names no face. The quoted rule text (NCMD-FORM-002) names no face, so `docs/FONTS.md` ("No face named") keeps EB Garamond. The exemplar is Times New Roman (body) with Century Schoolbook headings, which the rule does not require. The earlier note that the rule's examples are Times-type was not supported by the quoted rule text and has been removed; a court-named face would need a citation first. The x-height is smaller than Times, so the text looks lighter than the exemplar. The filer's own Times choice is a visual-only difference, not a rule difference.
4. **Caption style.** The party column is closed by a rule (right and bottom) and there is no column of ")" marks as in some filings in this district (Richardson-McGriff, USConnect). Tier-2 choice, recorded as ACCEPTED.
5. **Jury demand.** The exemplar puts its demand in the prayer and in the caption. The template does the same; a separate "DEMAND FOR JURY TRIAL" section is not generated.
6. **Paragraph numbers.** The template numbers the allegations 1 to 78, which matches the filed paragraph numbers (checked page by page against the exemplar text). The overlay pairs pages by words, not paragraph numbers.
7. **Single-circumstance rule (FRCP 10(b)).** Not checked by the template; the author must limit each numbered paragraph to one set of circumstances.
8. **Separate filings.** The civil cover sheet, the corporate disclosure statement (LR 7.7; Rule 7.1) and summonses are not generated (see Governing rules).
9. **Gate scripts.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder has neither, and the brief forbids editing `tools/`. The gates were not run; render and overlay were run and the review above is the Gate 2 equivalent for this doc type.

## Engines

Checked on the final renders of `usage/OUTPUT-ncmd-complaint-prillaman.docx.pdf` (12 pages, LibreOffice) against `usage/OUTPUT-ncmd-complaint-prillaman.typst.pdf` (typst, 11 pages). Every page of both PDFs was rendered at 60 dpi and viewed: docx pages 1 to 12, typst pages 1 to 11.

- **docx** (`docx/reference.docx`, `docx/make-reference.sh`, `docx/ncmd-complaint.lua`, `docx/render.sh`). Output: `usage/OUTPUT-ncmd-complaint-prillaman.docx` and `.docx.pdf`. The `.docx` passes `unzip -tq` and every XML part is well formed (`xmllint`). LibreOffice converted it without error. Not opened in Word.
  - *Matches typst:* EB Garamond 13 pt (the PDF embeds only EB Garamond; OpenSymbol is used only for the bullets of the list on page 9); letter paper; top margin 1.25 in and the other margins 1 in; body on a 23.0 pt line pitch (measured); the caption with the party column closed by a right and a bottom rule; numbered allegations 1 to 78 with the prayer unnumbered; the prayer, WHEREFORE line, list and signature block kept together (docx page 12, as typst page 11); the footnote at the foot of its page; page number centred in the footer.
  - *Differs:* 12 pages against typst's 11. Headings take a little more space, so the page breaks fall earlier (docx page 1 ends in paragraph 4, typst page 1 ends after paragraph 4). The footnote sits on page 6 of the docx and page 5 of typst. Paragraph numbers are typed text with a tab, not Word list numbering. The bullets are a LibreOffice list.
  - *BLOCKED:* none found. This folder has no `checks.yaml`, so no gate ID exists to block; the review above is by eye.

