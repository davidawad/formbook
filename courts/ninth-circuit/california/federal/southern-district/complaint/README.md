# casd: complaint

Doc type: **complaint** in the United States District Court for the Southern District of California (`casd`).
Folder: `courts/ninth-circuit/california/federal/southern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-bachman-3-26-cv-04862-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-bachman-complaint.md` (a portion of the 35-page filing, see its header comment) |
| render | ok: `samples/OUTPUT-bachman-complaint.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-bachman-complaint.pdf` and `OVERLAY-bachman-complaint.txt` |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed; pages 6 to 8 re-viewed after the last template change; all 8 re-viewed on 2026-10-15 in the typeface pass, no template change) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| S.D. Cal. Civil L.R. 5.1 | Papers typed double-spaced on one side, line-numbered in the left margin, not more than 28 lines per page, letter size. | `lines-per-page = 28`, `pitch = 24pt`, `page-w = 8.5in`, `line-numbers()`. |
| S.D. Cal. Civil L.R. 5.1 | Proportional font such as Times New Roman at 14-point; no smaller type for text, footnotes or quotations. | `type-size = 14pt` for all body text, headings, caption and counsel. The footer is 10 pt (see gap 4). |
| S.D. Cal. Civil L.R. 5.1 (typeface) | No face is required. "Such as Times New Roman" is an example, not a requirement, so the court-named-face substitution does not apply. | Face required: none. Font: **EB Garamond** (kept; `font-family` in `casd-complaint.typ`). Substitute not used, so the fit column is n/a. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `court-title`, `caption` (case number on the right, title below it). |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers each body paragraph; headings, lists and the PRAYER and DEMAND paragraphs are not numbered. |

Rule text: Fed. R. Civ. P. 10 fetched from https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14 (the amended text, eff. 2007-12-01; "Rule 10(a)" and "Rule 10(b)" quoted from it).

S.D. Cal. Civil L.R. 5.1: **not verified against the court's primary text.** The court's own site returned 404 to every fetch made on 2026-10-14 (`www.casd.uscourts.gov`, including `_assets/pdf/rules/Local%20Rules.pdf` and the Local Rules page the search engine listed). The text used here is the search-engine excerpt of CivLR 5.1 on courtrules.net (https://www.courtrules.net/courts/federal/southern-district-california/local-rules/27072; that page returned 403 to the fetch tool), which summarizes the rule as: double space on one side, line numbers in the left margin, no more than 28 lines per page, letter size, and a proportional font such as Times New Roman at 14-point. The exemplar uses 14-point Times New Roman (type height measured from the text layer; see the layout notes below). Before this doc type is marked done, check CivLR 5.1 against the court's current Local Rules PDF.

Not checked: CivLR 7.1 and CivLR 3 (the complaint's first-page requirements, if any beyond Rule 10). No CASD-specific caption or cover rule was confirmed, so the caption follows the exemplar and Rule 10(a). The civil cover sheet (JS-44), the Certification of Interested Entities or Persons, and the summons are separate filings and are not produced here.

## Layout

- Numbered lines 1 to 28 down the left margin, a double rule at the text's left edge and a single rule at its right (the pleading form).
- Top margin 1 inch: line 1 sits on the top margin, so the 28 lines end at 10.33 inches and the footer is in the bottom margin.
- Body leading `14.9pt` gives a 24 pt baseline pitch at 14 pt EB Garamond (measured with `pdftotext -bbox` on a test page: pitch 24.00 pt on all lines; natural line box 9.1 pt). The cand template's 12 pt leading does not carry over.
- Counsel block single-spaced (`single-leading = 3.5pt`, pitch about 12.6 pt) on lines 1 to 7; the template grows the block for longer counsel lists.
- Court title on line 8 (UNITED STATES DISTRICT COURT, SOUTHERN DISTRICT OF CALIFORNIA), caption from line 11.
- Every block of text is a whole number of 24 pt rows (`on-grid`), so headings, paragraphs and signature blocks land on the numbered lines.
- Paragraphs are numbered 1, 2, ... by the template; a heading stays with the paragraph after it (`heading-line` + the grouping in `allegations()`). Paragraphs under a heading starting with PRAYER or DEMAND are not numbered (the filed complaint leaves those unnumbered).
- Prayer items (markdown numbered list) are lettered (a), (b), ... as in the filing.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1 centered caps; level 2 centered bold; level 3 bold italic left), a numbered list (`1.` items, lettered by the template), or a paragraph (numbered by the template).
- Frontmatter fields: `case_number`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `footer_title`, `counsel` (lines), `lead_in` (unnumbered lead-in paragraph, optional), `jury_demand` (puts "DEMAND FOR JURY TRIAL" in the caption), `legend` (optional, e.g. "Class Action"), `division` (optional), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Not supported: tables, footnotes, raw typst. The sample omits footnote text.
- The sample must not put the numbering in the text: the template numbers the allegations.

## Known gaps and open choices

1. **Only one exemplar.** Tier 2 asks for 2 or 3 filers. The CourtListener API search (`type=r`, `court=casd`, complaints filed 2026-09-08 to 2026-10-11) found other S.D. Cal. complaints (e.g. Novick v. Capricor Therapeutics, 3:26-cv-05568, Pomerantz LLP; Alo, LLC v. Derco, LLC, 3:26-cv-04957, Name Game IP, PC), not downloaded. Tier 2 is therefore **not** judged against two filers yet.
2. **Font.** CivLR 5.1 names Times New Roman only as an example ("a proportional font such as Times New Roman"), so the rule names no face and this template keeps EB Garamond at 14 pt. `fonts/liberation-serif/` (the Times New Roman substitute, metric-compatible per `docs/FONTS.md`) is vendored, so switching is a one-line change in `font-family` if David reads the exemplar's Times as the clerk's convention. EB Garamond has a smaller x-height than Times, so the sample reads smaller than the exemplar even at the same nominal size. Question for David: should the S.D. Cal. templates keep EB Garamond (the rule's text allows any proportional font) or use Liberation Serif (the exemplar's face)?
3. **Footer type size.** The footer is 10 pt (case number and title). The 14-point rule is written for text; footers are logged as an interpretation, the same as in the cand template.
4. **Caption.** The party column is closed by a rule (right and bottom), not the column of ")" marks in the exemplar. ACCEPTED as a tier-2 convention choice.
5. **Overlay names.** `tools/overlay.sh` reads `samples/OUTPUT-<id>.pdf` and writes `samples/OVERLAY-<id>.pdf` and `.txt`; the render is `OUTPUT-<id>.pdf` (the default of `tools/render.sh`). These are the names the tools use, so they are used here in place of `<id>.pdf` and `<id>-overlay.pdf`.
6. **Overlay pairing.** The sample is a portion of the 35-page filing (paragraphs 1 to 28, the prayer, the jury demand and the signature block; the CLRA venue declaration is not transcribed). The overlay pairs each sample page with the exemplar page sharing the most words; pages 6 to 8 pair with exemplar pages 10, 12 and 33 because the sample skips the filing's pages between. The overlay is a diagnostic, not a score.
7. **Paragraph numbers differ.** The sample numbers its allegations from 1; the filed numbers are not transcribed.
8. **Ragged right.** Body text is left-aligned, not justified. The exemplar's justification could not be read from the text layer; not asserted.
9. **Keep-with-next.** A heading and the paragraph after it are kept together as one unbreakable block, so a heading can leave a short gap at the foot of a page (page 4 of the sample: five empty lines before JURISDICTION AND VENUE). Accepted as the cost of never ending a page on a heading.
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court directory with `court.json` and `rules.md`, and this doc-type folder does not have that shape. The gates were not run; render and overlay were run, and the review above is the Gate 2 equivalent for this doc type.
11. **Headings must fit one line.** `heading-line` asserts a single numbered line; a two-line heading fails the build with a message.
12. **Signature block.** One signature block, after the jury demand. The filing repeats the signature under its own jury-demand page; the template does not produce that second signature.

## Review of the rendered pages (current PDF)

- Page 1: counsel on lines 1 to 7 (single-spaced), court title on lines 8 and 9, caption on lines 11 to 17, the title, CLASS ACTION legend and DEMAND FOR JURY TRIAL at the right, footer with title and case number. Pass.
- Page 2: the body begins on the page after the caption with ¶1 (the opening paragraph), the INTRODUCTION heading centered bold, ¶¶1 to 5. Text on the numbered lines. Pass.
- Page 3: ¶¶6 to 10; PARTIES heading and the Plaintiff sub-heading (bold italic) at the foot, with ¶11 starting on line 28. Pass.
- Page 4: ¶¶11 to 14 (Plaintiff, Defendant); lines 24 to 28 empty before JURISDICTION AND VENUE, which moved to page 5 with its paragraph (gap 9). Pass with the noted gap.
- Page 5: JURISDICTION AND VENUE, ¶¶15 to 17, FACTUAL ALLEGATIONS, sub-heading A (bold italic), ¶¶18 to 19. Pass.
- Page 6: ¶¶20 to 26 (the ¶23 and ¶24 website paragraphs). No heading at the foot. Pass.
- Page 7: ¶27, sub-heading B, ¶28, PRAYER FOR RELIEF (centered bold), the unnumbered WHEREFORE paragraph, items (a) to (c). Pass.
- Page 8: items (d) to (h), DEMAND FOR JURY TRIAL (centered bold, unnumbered paragraph), the date, the signature block (single-spaced, "By: /s/" and the signer). Pass.

Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).

## Engines

### docx

Built by `docx/make-reference.sh` (writes `docx/reference.docx` from pandoc's default reference) and `docx/casd.lua` (the filter). Sample: `samples/OUTPUT-bachman-complaint.docx` (zip and XML parts checked with `unzip -t` and `xmllint`; the LibreOffice PDF was not made).

Set in `styles.xml` and `sectPr` only, **not rendered** (no LibreOffice on the build box):

- EB Garamond 14 pt in every style (Normal, Body Text, Heading 1 to 3, Compact, Block Text, Footnote Text), black text.
- 24 pt exact line spacing (`w:line="480"`, `exact`) on body, heading, list and block text; no space before or after; paragraphs run on without gaps.
- First-line indent 0.5 in on body paragraphs; numbered allegations are `N.` plus a tab (the filter), prayer items `(a)`, `(b)` in the "Prayer Item" style (hanging indent).
- Headings: level 1 and level 2 centered bold, level 3 bold italic at the margin.
- US Letter; top 1 in, left 1.5 in, right 0.75 in, bottom 48 pt (so 28 lines of 24 pt fill the text area exactly).
- Word line numbering (`w:lnNumType`, restart each page), and a double rule at the left and a single rule at the right of the text (`w:pgBorders`).

What differs from the typst template:

- No footer: no page number, footer title or case number (typst prints all three). Not in the reference.
- The caption is paragraphs, not the bordered party box; the case number sits at the right on its own line.
- The counsel block is single spaced but not on the 24 pt grid, so the numbered lines in Word may not line up with the typst lines on page 1.
- Word numbers text lines (`lnNumType`), not a fixed grid of 1 to 28 on every page; blank space may not be numbered. The numbering of allegations is typed text, not a Word list.
- Footnote Text is single spaced (a convention, not verified); no footnotes in the sample.
- `date` is written as "Dated:" in the signature block; the typst block is the same in content.

BLOCKED for this engine:

- `docx.pdf` gates 0 to 3: BLOCKED, no `soffice` on the build box (LibreOffice is not on conda-forge). The `.docx` is written, not converted.
- Pages reviewed for docx: 0. No docx page was rendered or looked at. The typst render of the same sample was viewed page by page as the comparison.
- Footer (page number, footer title): not produced (see above).
- Word fidelity (repair prompt, line-number placement, border offsets): not checked in Word.
