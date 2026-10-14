# msnd: motion-brief

Doc type: **motion-brief**, the memorandum (brief) in support of a motion to dismiss under Fed. R. Civ. P. 12(b), in the United States District Court for the Northern District of Mississippi (`msnd`).
Folder: `courts/fifth-circuit/mississippi/federal/northern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-stokes-3-25-cv-307-motion-brief.pdf` (1 filer, 12 pp; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-stokes-motion-brief.md` (transcription of the brief: caption, the introduction, facts, standard, the argument with its three headings, conclusion, footnotes 1–3, the signature block and the OF COUNSEL block) |
| render | ok: `samples/OUTPUT-stokes-motion-brief.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh <this dir> samples/INPUT-stokes-motion-brief.md`) |
| overlay | ok: `samples/OVERLAY-stokes-motion-brief.pdf` and `OVERLAY-stokes-motion-brief.txt` (`sh tools/overlay.sh <this dir> stokes-motion-brief`) |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed after the last template change) |

File names follow `tools/render.sh` and `tools/overlay.sh` (`OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`/`.txt`), so the sample is `INPUT-<id>.md` and the id is `stokes-motion-brief`.

## Governing rules

Primary sources: the joint 2024 Local Civil Rules for the Southern and Northern Districts of Mississippi, https://www.mssd.uscourts.gov/sites/mssd/files/2024%20Local%20Civil%20Rules%20MSSD%20MSND%20(.pdf) (fetched 2026-10-14; 164 pages), and the Federal Rules of Civil Procedure from Cornell LII (https://www.law.cornell.edu/rules/frcp/), fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| L.U.Civ.R. 7(b)(5)(A) | 8½ × 11 inch paper; text double-spaced (quotations may be indented and single-spaced; headings and footnotes may be single-spaced); margins at least 1 inch on all four sides; page numbers may be placed in the margins, but no text may appear there. | `margin = 1in`, `pitch = 24pt` and `on-grid` for body text, a footer page number only (`page-number()`). Headings and quotations are kept double-spaced (permitted, not required). |
| L.U.Civ.R. 7(b)(5)(B) | A proportionally spaced or monospaced face; a proportional face must have serifs (sans-serif is allowed in headings and captions); text 12-point or larger; footnotes 11-point or larger. | `font-family = "EB Garamond"` (serif, vendored), `type-size = 12pt`, `footnote-size = 11pt` (`show footnote.entry`). |
| L.U.Civ.R. 7(b)(5)(C) | Plain roman type; case names italicized or underlined. | The template italicizes `*...*` markup; the sample italicizes case names, *Id.* and signals (see Known gaps). |
| L.U.Civ.R. 7(b)(5) | Movant's original and rebuttal memoranda together may not exceed 35 pages; the respondent's memorandum may not exceed 35 pages. | Not enforced by the template (it is a length rule, not a format rule). The exemplar is 12 pages. |
| L.U.Civ.R. 7(b)(2) | The memorandum brief is a separate docket item from the motion; it may not be made an exhibit to the motion. | Not a format element of the brief; the template produces the brief only. |
| L.U.Civ.R. 11(a) | Signed papers carry counsel's name, address, telephone number, fax number, e-mail address and bar membership number. | `signature-block()`: the signing party and signer, the counsel block (name, bar number, "Attorneys for Defendant") and the OF COUNSEL block (firm, address, telephone and fax, e-mail). |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `court-title()`, `caption()`, `cover()`: court name lines in the template, division and case number from the sample. |
| Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system. | No certificate is produced (the exemplar has none). |

**What the local rules do not say.** I read Rules 5, 7 and 11 in full and searched the whole compilation for typeface, point size, double spacing and margins; the only match is L.U.Civ.R. 7(b)(5). I did not find a local rule on a brief's table of contents, table of authorities or certificate of service. The exemplar has none of them, and the template does not add them.

## Layout

- Court title (three lines, bold, centered): "IN THE UNITED STATES DISTRICT COURT / FOR THE NORTHERN DISTRICT OF MISSISSIPPI / <DIVISION> DIVISION".
- Caption: parties in the left column (names, designation, "v." between parties), a rule closing the column at right and bottom; "CIVIL ACTION NO.:" with the case number at right.
- Title of the paper, centered bold caps.
- Body double-spaced (24 pt pitch at 12 pt), first-line indent 0.5 in, paragraphs not numbered.
- Headings: level 1 centered bold caps (FACTS, STANDARD, ARGUMENT, CONCLUSION); level 2 bold, left (argument headings "1. …", "2. …"); level 3 bold italic left (not used in the sample).
- Block quotations: indented 0.5 in on both sides, kept double-spaced.
- Footnotes: a `[^key]` mark becomes a typst footnote at 11 pt.
- Signature block: "This, the __ day of __" line, "Respectfully submitted," and the party and signer at right; the OF COUNSEL block at left below.
- Margins 1 inch; page number centered at the foot of each page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: `#` heading (level 1), `##` heading (level 2), `>` block quotation, a list, or a paragraph. A paragraph is never numbered.
- Escape a star page: write `at \*7` (not `at *7`), so markdown does not read the asterisk as emphasis.
- Frontmatter: `division`, `case_number`, `title`, `caption.parties` (list of `{names, designation}`), `date_line`, `signature` (`party`, `signer`, `counsel` and `of_counsel` lines).
- Footnotes: `[^key]` in the text and `[^key]: text` in its own chunk.

## Known gaps and open choices

1. **One exemplar.** Tier 2 is not yet judged against two or three filers. *Haley v. X.AI Corp.*, 3:26-cv-00148-DMB-RP, ECF 51 (27 pp; a defendant's memorandum in support of a motion to dismiss, text layer present) is the next candidate; it is longer than the 8–14 page target and was not used. See `exemplars/SOURCE.md`.
2. **Font.** L.U.Civ.R. 7(b)(5)(B) names no face (only "a proportionally spaced or monospaced face" with serifs for a proportional one), so `docs/FONTS.md` keeps EB Garamond here; no Times-family substitute is required. The exemplar is Times New Roman, which the rule does not require. EB Garamond at 12 pt has a smaller x-height, so the text looks smaller than the filed page. The 12-point size and the footnote size are kept.
3. **Case names.** The exemplar's text layer has no italic markup, so the italics in the sample (case names, *Id.*, signals such as *See*, *see also*, *Compare* … *with*) are a transcription choice following Rule 7(b)(5)(C), not a reading of the filed PDF.
4. **Paragraph split at a page break.** A paragraph that continues onto the next page can leave one blank line at the top of that page (page 6 of the render). Paragraphs are set in fixed-height blocks (`on-grid`), and a block that breaks across a page keeps the height of its leftover lines. The alternative, plain flow, lays out paragraphs in a loop incorrectly in typst 0.15 (lines of one paragraph overlapped the next), so the fixed-height form was kept. The gap is cosmetic and is recorded here rather than fixed.
5. **Overlay pairing.** Pages pair by shared words: pages 1–10 pair at 51–91%; page 11 (the signature block) pairs with exemplar page 12 at 30%, because the signature is short. The overlay is a diagnostic, not a score.
6. **Not produced:** a table of contents or table of authorities (none in the exemplar), a certificate of service (Rule 5(d)(1)(B): none needed for e-filed papers), a proposed order (L.U.Civ.R. 7(b)(2)(F): needed only for ex parte or consent motions), the motion itself (L.U.Civ.R. 7(b)(2)(B): a motion may not exceed four pages), and the ECF header the exemplar carries.
7. **Page limit.** The 35-page limit (L.U.Civ.R. 7(b)(5)) is a length rule; the template does not check it. The exemplar is 12 pages, within it.
8. **Gates.** `tools/check.sh` and `tools/check-selftest.sh` need a court folder with `court.json` and `rules.md`; this doc-type folder does not have that shape, and the brief forbids touching `tools/`. The gates were not run. Render, overlay and the page review above are the checks for this doc type.
9. **Footnote 1 is long** (a judicial-notice cite and a parenthetical). It is set at 11 pt, as the rule allows.

## Review of the rendered pages (`OUTPUT-stokes-motion-brief.pdf`, 11 pages)

- Page 1: court title, caption (party column closed by a rule; the right column with "CIVIL ACTION NO.: 3:25-cv-307-GHD-RP"), the title, and the introduction. Pass.
- Page 2: FACTS heading and the first two fact paragraphs with footnotes 1 and 2 at the foot of the page. Pass.
- Page 3: the remaining facts paragraph; the STANDARD heading; footnote 3 at the foot of the page. Pass.
- Page 4: the ARGUMENT heading, argument heading 1 and the first two paragraphs of argument 1 (case names italic). Pass.
- Page 5: the rest of argument 1, argument heading 2. Pass.
- Page 6: argument 2 paragraphs; a continuation paragraph starts the page with a one-line gap (gap 4 above). Pass with that recorded gap.
- Page 7: argument 2 ends; argument heading 3 with its first paragraph. Pass.
- Page 8: argument 3 paragraphs and the block quotation (indented both sides, double-spaced). Pass.
- Page 9: argument 3, the *McLin* paragraphs. Pass.
- Page 10: the *Compare* / *with* citation paragraph, qualified-immunity conclusion, CONCLUSION heading. Pass.
- Page 11: "This, the 10th day of December 2025.", "Respectfully submitted," the party, signer and counsel block, and the OF COUNSEL block. Pass.

Defects found during review and fixed in the template: (a) headings came out at typst's default heading size, now 12 pt; (b) footnote marks were literal text in the first draft, now typst footnotes at 11 pt; (c) star pages (`at *7`) were read as emphasis, so the sample escapes them. The layout defect in gap 4 is recorded, not fixed.

## Review limits

The page review checks the layout of the render. Text fidelity to the exemplar rests on the transcription and the overlay's word pairing; the exemplar's filed page images were not compared pixel by pixel.
