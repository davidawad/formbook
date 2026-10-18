# kywd: complaint

Doc type: **complaint** in the United States District Court for the Western District of Kentucky (`kywd`).
Folder: `courts/sixth-circuit/kentucky/federal/western-district/complaint/` (self-contained: `usage/`, `usage/`, `typst/`, this README).

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (12 pages, 1 filer; see `usage/SOURCE.md`). Second filer saved for comparison: `usage/FILED-EXAMPLE-complaint-2.pdf` (6 pages). |
| sample md | `usage/INPUT-complaint.md`: the whole filed complaint (caption, headings, all 68 paragraphs, prayer, jury demand, both signature blocks). |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh <this-dir> usage/INPUT-complaint.md`). |
| overlay | ok: `usage/OVERLAY-lott-complaint.pdf` and `usage/OVERLAY-lott-complaint.txt` (`sh tools/overlay.sh <this-dir> lott-complaint <exemplar>`). |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed). Page 1 was viewed again after the caption-column width change; pages 2 to 10 were viewed before it. That change moved only the caption, and the page count stayed at 10. |
| checks | `tools/check.sh` is not run for this folder (it expects a court folder with `court.json` and `rules.md`; the brief forbids touching `tools/`). The review below is the Gate 2 equivalent. |

## Governing rules

| Rule | Requirement | Where in the template | Source, verified |
|---|---|---|---|
| LR 5.2(a) (Joint Local Rules, Eastern and Western Districts of Kentucky) | 8 1/2 x 11 inch page; margins of at least one inch on all sides; text double spaced (except block quotes, headings and footnotes); at least 12-point proportionately spaced font. | `margin = 1in`, `type-size = 12pt`, `body-leading = 1.35em` (24 pt baseline pitch at 12 pt), `page-w`/`page-h`. | Text read from Joint General Order No. 2026-01 (https://www.kywd.uscourts.gov/sites/kywd/files/Joint%20General%20Order%2026-01-1.pdf), which re-states LR 5.2(a). Same text in JGO 2018-02, where it was LR 5.1(b). Fetched 2026-10-14. |
| LR 5.2(b) (added by JGO 2026-01) | Filings in English unless translated, with a certificate of accuracy for translations. | Not a layout rule; not checked by the template. | JGO 2026-01. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, the title, the file number and the Rule 7(a) designation; the title names all the parties. | `court`, `caption`, `case_number`, `title` in the frontmatter; the caption is drawn by the template. | https://www.law.cornell.edu/rules/frcp/rule_10, fetched 2026-10-14 (page shows "As amended Apr. 30, 2007, eff. Dec. 1, 2007"; no later update date shown). |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each body paragraph is numbered 1, 2, ...; headings and lists are not. | Same page as above. |

Not verified in this pass, and not asserted by the template: Fed. R. Civ. P. 8(a) (short and plain statement); Fed. R. Civ. P. 38(b) (the jury demand); LR 3.1 (jury divisions; the Louisville jury division appears in the exemplar's caption as "LOUISVILLE JURY DIVISION" on one filing and "LOUISVILLE DIVISION" on another); civil cover sheet and Rule 7.1 disclosure (separate filings).

## Layout

- Court title centered and bold on three lines, from `court` in the frontmatter.
- Caption: party column, then a column of ")" marks, one per row; "vs." between parties; designations indented; the file number (`CASE NO.` plus `case_number`) on the "vs." row. The ")" column and the case-number column are the same convention both filers use (Lott and Scales; checked in their text layers).
- The title of the paper is centered and bold below the caption.
- Body paragraphs: numbered (Rule 10(b)), first-line indent 0.5 inch, number then a 0.5 inch gap.
- Headings: level 1 centered bold caps; level 2 bold, left; level 3 bold italic. Each heading is kept with the paragraph after it.
- A paragraph beginning "WHEREFORE" is unnumbered (the prayer lead-in), as in the exemplar. This is a rule of the template, keyed on the standard pleading word, not on the case.
- Prayer items: markdown list, rendered as 1., 2., ... with a hanging indent.
- Jury demand: `jury_demand` in the frontmatter gives the centered heading and the sentence; the signature block repeats after it.
- Signature block: "Respectfully submitted," then "By: /s/ NAME" and the lines from `signature.lines`, starting at 3.25 inch from the left margin, single spaced; the block does not split across pages.
- Footer: bare page number, centered, 12 pt.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number`; `court` (lines); `caption.parties` (list of `{names, designation}`; "vs." is placed between parties); `title`; `signature` (`by`, `lines`; an empty string in `lines` is a blank line); `jury_demand` (`heading`, `text`; optional).
- Body: blank-line-separated chunks. `#` heading (level 1 centered caps; level 2 bold; level 3 bold italic); a `1.` list; or a paragraph (numbered by the template, except one that begins "WHEREFORE").
- Not supported: tables, footnotes, raw typst. None is used in the sample.
- The sample does not put paragraph numbers in the text.

## Known gaps and open choices

1. **Typeface.** Face required: none. LR 5.2(a) (JGO 2026-01, re-read 2026-10-15) asks for "at least 12-point proportionately-spaced font" and names no typeface. Substitute: none; EB Garamond stays as the no-face default (`docs/FONTS.md`). Metric-compatible or visual-only: n/a. The exemplars use Times New Roman, and EB Garamond at 12 pt has a smaller x-height than Times at 12 pt, so the text looks smaller than the exemplar. The 12-point minimum is met. `Liberation Serif` (Times-metric) is available if David wants the exemplar look; it is not used here, because no rule requires it.
2. **Judge initials** after the file number (`3:26-CV-653-RGJ`). This is a convention seen in both filers' captions, not a rule; the template prints whatever `case_number` holds.
3. **Caption date and signature date.** The exemplar has no date line in the signature block; the template has none.
4. **Filer's typo kept out of the sample.** The filed caption reads "FOR THE WSTERN DISTRICT OF KENTUCKY"; the sample says "WESTERN" (noted in the sample's frontmatter comment).
5. **Two sources for LR 5.2 numbering.** JGO 2018-02 numbers the format rule LR 5.1(b); JGO 2026-01 numbers it LR 5.2(a). The text is the same. The current consolidated rulebook was not fetched (the W.D. Ky. and courtrules.net pages returned 403/404 to this environment), so the rule text above is from the two orders, not from a consolidated copy.
6. **Only two exemplars**: Lott (12 pages) and Scales (6 pages); both have the ")" caption, the same court title, and the same signature layout. A third (Thomas v. Southern Baptist Theological Seminary, 17 pages) was checked and not saved. Tier 2 is judged against these.
7. **Overlay pairing.** The sample is the whole filing; the overlay pairs pages by text. Page 10 of the render pairs with page 11 of the exemplar because the render is shorter. The overlay is a diagnostic, not a score.
8. **Length.** The render (10 pages) is shorter than the exemplar (12 pages). The likely cause is leading and the caption layout, not missing text, but the word-level comparison was not run as a gate (Gate 0 is a `check.sh` function and was not run here). The overlay's word-overlap figures are the only text comparison made.
9. **File names.** `tools/render.sh` writes `usage/OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `usage/OVERLAY-<id>.pdf` and `.txt`; these are the names the tools use, so they are the names used here (not `<id>.pdf` or `<id>-overlay.pdf`).

## Review of the rendered pages (usage/OUTPUT-complaint.typst.pdf)

- Page 1: court title (3 lines), caption with ")" column, CASE NO. on the vs. row, title centered; numbered paragraphs 1 to 4 start on the page; footer page number. Pass.
- Page 2: heading III (JURISDICTION AND VENUE) centered; paragraphs 5 to 15 numbered and double spaced; no heading at the foot of the page. Pass.
- Page 3: heading IV centered; subheading A bold left; paragraphs 16 to 19. Pass.
- Page 4: paragraphs 20 to 27; subheading B; paragraph 22 incorporates the earlier paragraphs. Pass.
- Page 5: paragraphs 28 to 36; subheading C at the foot of the page is followed by its paragraph 35 on the same page. Pass.
- Page 6: paragraphs 37 to 44. Pass.
- Page 7: heading V centered; COUNT I and COUNT II headings centered bold; paragraphs 45 to 56. Pass.
- Page 8: COUNT III and COUNT IV headings centered (COUNT IV wraps to two centered lines); paragraphs 57 to 66. Pass.
- Page 9: paragraphs 67 and 68; heading VI; WHEREFORE paragraph unnumbered; prayer items 1 to 8 with hanging indents. Pass.
- Page 10: the signature block (Respectfully submitted, By: /s/, attorney lines, "Attorneys for Plaintiffs") does not split; DEMAND FOR JURY TRIAL heading centered; demand sentence; second signature block. Pass.

Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).

## Engines

**docx** (`docx/`): `reference.docx` (built by `sh docx/build-reference.sh reference.docx`), `kywd-complaint.lua` (court title, caption table, paragraph numbers, signature blocks, jury demand), `render.sh` (pandoc, then the reference's styles, page setup and footer are restored into the output). Render: `sh tools/render.sh --engine docx <this-dir> usage/INPUT-complaint.md`. It writes `usage/OUTPUT-complaint.docx` and then stops at the soffice step (see BLOCKED).

What matches typst (set in `reference.docx`):
- Letter paper, 1 in margins on all four sides (LR 5.2(a)).
- EB Garamond 12 pt, the only face (vendored). Measured in the typst render: `pdffonts` shows EBGaramond Regular and Bold, embedded; 10 pages.
- Body: exact 24 pt line pitch. Measured on the typst render with `pdftotext -bbox-layout`: 24.0 pt between body lines, and no extra gap between paragraphs.
- Single lines (caption, title, court title, signature): exact 13.8 pt. Measured on the typst caption rows and signature lines.
- Paragraph numbers 1., 2., ... with the text at 0.5 in after the number (tab stop at 1620 twips, from the typst placement of the number). Prayer paragraph "WHEREFORE" unnumbered.
- Signature block at 3.25 in (4680 twips). Jury demand heading and its own signature block.
- Footer: bare page number, centered, 12 pt, `PAGE` field with cached result.
- Headings: level 1 centered bold caps (`caps`), level 2 bold left, level 3 bold italic left; keep with next.

What differs from typst or is not verified:
- Heading spacing: `before` and `after` are 6 pt in the reference. Not measured against the typst headings (typst uses its own above and below spacing); the difference is a few points per heading, and it is not verified.
- Prayer list (markdown list): pandoc's own list numbering, so the hanging indent is pandoc's, not the 0.5 in of the typst template. Not measured.
- Certificate and jury-demand text: plain text (inline markup in them is dropped).
- Pagination: not measured (there is no LibreOffice PDF of the docx). The page count of the docx is unknown; the typst render is 10 pages.

docx BLOCKED items (no pass claimed):
- `docx.pdf` and page review (Gates 0 to 3 and the per-page Gate 2 review): soffice is not installed on this box (`/opt/homebrew/bin/soffice: not found`). No LibreOffice PDF exists, so pages reviewed = 0.
- Open-in-Word and open-in-LibreOffice check (no repair prompt): not done; neither application is on this box. The package check passed: a valid zip, no duplicate entries, every XML part well formed.
- TOC, TOA and cross-reference fields: none in this template, so no field-update issue (docs/DOCX.md).
- Pleading line numbers and vertical rules: not required by LR 5.2(a) and not in the typst template; no `w:lnNumType` or page borders are set.
