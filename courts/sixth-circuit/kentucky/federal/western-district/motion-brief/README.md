# kywd: motion-brief (Rule 12(b) motion to dismiss with memorandum)

Doc type: **motion-brief** in the United States District Court for the Western District of Kentucky (`kywd`): a Rule 12(b)(6) motion to dismiss with its memorandum of law. Under the joint local rules the motion and its supporting memorandum are one filing (LR 7.1(a), merged by JGO 2017-01A); the template covers that combined document.
Folder: `courts/sixth-circuit/kentucky/federal/western-district/motion-brief/` (self-contained: `usage/`, `usage/`, `typst/`, this README).

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief-2.pdf` (memorandum, 19 pages, 1 filer; see `usage/SOURCE.md`). Companion: `usage/FILED-EXAMPLE-motion-brief-3.pdf` (the 2-page motion, same filer). Second filer for comparison: `usage/FILED-EXAMPLE-motion-brief.pdf` (30-page memorandum, different filer). |
| sample md | `usage/INPUT-motion-brief.md`: the whole memorandum (caption, introduction, statement of facts, all of Law & Argument I to VIII, conclusion, signature). The motion page and the certificate of service are not transcribed. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 17 pages, typst 0.15, vendored Times New Roman only, no warnings (`sh tools/render.sh <this-dir> usage/INPUT-motion-brief.md`). |
| overlay | ok: `usage/OVERLAY-zoeller-memorandum.pdf` and `usage/OVERLAY-zoeller-memorandum.txt` (`sh tools/overlay.sh <this-dir> zoeller-memorandum usage/FILED-EXAMPLE-motion-brief-2.pdf`). The tool's default exemplar is the first PDF in `usage/` alphabetically, which is the Glantz file; pass the Zoeller file explicitly. |
| pages reviewed | 16 of 16 (every page rendered at 60 dpi and viewed). Pages 1 to 15 were viewed after the final caption-width change (page 16 was viewed before it). That change moved only the caption and left the pagination at 16 pages. |
| checks | `tools/check.sh` is not run for this folder (it expects a court folder with `court.json` and `rules.md`; the brief forbids touching `tools/`). The review below is the Gate 2 equivalent. |

## Governing rules

| Rule | Requirement | Where in the template | Source, verified |
|---|---|---|---|
| LR 5.2(a) (Joint Local Rules) | 8 1/2 x 11 inch page; margins of at least one inch on all sides; text double spaced (except block quotes, headings and footnotes); at least 12-point proportionately spaced font. | `margin = 1in`, `type-size = 12pt`, `pitch-body = 24pt`. | Text read from Joint General Order No. 2026-01 (https://www.kywd.uscourts.gov/sites/kywd/files/Joint%20General%20Order%2026-01-1.pdf). Same text in JGO 2018-02 (as LR 5.1(b)). Fetched 2026-10-14. |
| LR 7.1(a) | A motion must state with particularity the grounds, the relief sought and the legal argument necessary to support it (routine motions excepted). | Content, not layout. The template does not check it. | JGO 2017-01A (https://www.kyed.uscourts.gov/sites/kyed/files/JGO17-01A.pdf), which amended LR 7.1 to merge motions and memoranda. Fetched 2026-10-14. |
| LR 7.1(d) | Motions and responses may not exceed 25 pages without leave; replies may not exceed 15 pages without leave. | Not enforced by the template (the count is not a layout property). See gap 3. | JGO 2018-02 (https://www.kywd.uscourts.gov/sites/kywd/files/general-ordes/Joint_General_Order_2018-02.pdf), which reduced the cap from 40 to 25 pages. JGO 2017-01A had 40 and 15. Fetched 2026-10-14. |
| LR 7.1(e) | A party filing a motion must also file a separate proposed order. | Not part of this file (a separate document). | JGO 2017-01A. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, title, file number and Rule 7(a) designation. | `court`, `caption`, `case_number`, `case_label`, `title`. | https://www.law.cornell.edu/rules/frcp/rule_10, fetched 2026-10-14. |
| Fed. R. Civ. P. 12(b)(6) | Defense of failure to state a claim. | Content, not layout. | Not fetched in this pass; the exemplar cites it throughout. |

Not verified in this pass and not asserted by the template: the consolidated W.D. Ky. local rule text as of 2026 (the courtrules.net and kywd.uscourts.gov rule pages returned 403/404 to this environment; the rule text above comes from the joint orders); Fed. R. Civ. P. 5(d)(1)(B) (certificate of service; the optional `certificate` block in the template exists for a filing that carries one, and the exemplar memorandum has none).

## Layout

- Court title centered and bold on three lines, from `court`.
- Caption: party column, then a column of ")" marks, one per row; "vs." between parties; designations indented; `CIVIL ACTION NO.` (from `case_label`) plus `case_number` on the first row that is "vs.". The ")" column and the number column are the convention the Zoeller and Glantz filers use (checked in their text layers).
- Title of the paper centered and bold below the caption.
- Body paragraphs: **not numbered** (a memorandum is not a complaint; Rule 10(b) does not apply). Each paragraph has a 0.5 inch first-line indent, double spaced.
- Headings: level 1 centered bold caps (INTRODUCTION, STATEMENT OF FACTS, LAW & ARGUMENT, CONCLUSION); level 2 bold, left, roman numerals (I., II., ...); level 3 bold, left, letters (A., B., ...). Each heading is kept with the paragraph after it.
- Lists: markdown lists render with a hanging indent (not used by the sample).
- Signature block: "Respectfully submitted," then "/s/ NAME" and `signature.lines`, starting 3.25 inch from the left margin, single spaced, not split across pages.
- Optional certificate: `certificate` (`heading`, `text`) with a repeated signature block, when a filing carries one.
- Footer: bare page number, centered, 12 pt.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number`; `case_label` (default "CASE NO."); `court` (lines); `caption.parties` (list of `{names, designation}`; "vs." between parties); `title`; `signature` (`by`, `lines`; "" is a blank line); `certificate` (optional: `heading`, `text`).
- Body: blank-line-separated chunks. `#` heading (level 1 centered caps; level 2 bold roman; level 3 bold letter); a list; or a paragraph (unnumbered, first-line indent).
- Italic case names are supported by markdown (`*Name*`). The Zoeller sample uses roman type because the exemplar's text layer has no italic markup.
- Not supported: tables, footnotes, raw typst. The sample has none.

## Known gaps and open choices

1. **Typeface.** Face required: none. Same as the complaint: LR 5.2(a) names no typeface (re-read 2026-10-15). Times New Roman (vendored), the house default (`docs/FONTS.md`), in every engine; the exemplars use it too. The 12-point minimum is met.
2. **Motion and memorandum are one document here.** The exemplar is two documents (2-page motion; 19-page memorandum), and the court's merged-filing rule (LR 7.1(a)) allows either. The template draws the memorandum with its caption and title. A separate motion page (for a motion-only filing) is not templated; the proposed order (LR 7.1(e)) is not templated.
3. **Page limit (LR 7.1(d)).** The template does not count pages against the 25-page cap. The Zoeller memorandum (19 pages, with the 2-page motion, about 21 pages in total) is under the cap. The Glantz memorandum (30 pages, Document 11-1) is over 25 pages on its face; whether the cap counts caption, tables and signature pages is not verified here, so this is an observation about the exemplar, not a finding.
4. **Page count vs. exemplar.** The render is 16 pages against the exemplar's 19. The sample transcribes the whole memorandum; the difference is leading and the caption layout, not missing text (the word-level comparison was not run as a gate; the overlay's word-overlap figures are the only text comparison made).
5. **Filer's typographical errors** ("Gregrory", "emogional", "Wyndam", "E.D.K.Y.") are kept as filed in the sample. The one line-wrap artifact in the filed text ("106364", a broken "1063-64") is transcribed as "1063-64".
6. **Heading depth.** Level 2 and level 3 are both bold, left. The exemplar sub-headings are bold; whether its sub-heading italics are a convention is not checked (tier 3).
7. **Certificate of service.** Not in the exemplar memorandum (the companion motion carries one). The template supports it; the sample does not use it.
8. **Overlay default.** `tools/overlay.sh` picks the first exemplar alphabetically (Glantz). Pass the Zoeller memorandum explicitly, as shown in the table above.
9. **File names.** `tools/render.sh` writes `usage/OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `usage/OVERLAY-<id>.pdf` and `.txt`; these are the names used here.

## Review of the rendered pages (usage/OUTPUT-motion-brief.typst.pdf)

The rows below are the review of the earlier 16-page render. The cross-engine adoption (fb-595.68.29) re-laid the pages: 17 pages, every one viewed against its docx page (see "Engines"); the structure noted per page holds, shifted by up to a page.

- Page 1: court title (3 lines), caption with ")" column, `CIVIL ACTION NO. 3:25-CV-00740-DJH` on the vs. row (one line), title centered bold, opening paragraph, INTRODUCTION centered. Pass.
- Page 2: introduction paragraphs; STATEMENT OF FACTS centered; paragraphs unnumbered with first-line indent. Pass.
- Page 3: statement of facts continues; LAW & ARGUMENT centered; I. STANDARD OF REVIEW level-2 heading bold left. Pass.
- Page 4: standard of review; II. PLAINTIFF LACKS STANDING; the heading is kept with its text. Pass.
- Page 5: standing argument continues; III heading wraps to two bold lines (ALTERNATIVELY, CLAIM UNDER FOURTEENTH AMENDMENT FAILS ON ITS MERITS). Pass.
- Page 6: A. heading (level 3) bold, left; paragraphs double spaced; B. heading bold. Pass.
- Page 7: C. and D. headings bold left, D. wraps to two lines; paragraphs double spaced. Pass.
- Page 8: E. heading bold; agency argument. Pass.
- Page 9: IV heading (wraps to two lines: "IV. PLAINTIFF FAILS TO SUFFICIENTLY PLEAD A § 1983 / CONSPIRACY CLAIM"). Pass.
- Page 10: conspiracy argument continues; V. MONELL heading. Pass.
- Page 11: Monell argument. Pass.
- Page 12: VI. NEGLIGENCE heading; negligent supervision argument. Pass.
- Page 13: VII. heading (two lines); VIII. heading; immunity text begins. Pass.
- Page 14: immunity argument (sovereign immunity; Yanero; KRS 70.040). Pass.
- Page 15: qualified immunity; CONCLUSION centered. Pass.
- Page 16: conclusion paragraph; "Respectfully submitted," then "/s/ Carol Schureck Petitt", the attorney block and the counsel line, at 3.25 inch; the block is not split. Pass.

Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).

## Engines

**typst** (`typst/`, the reference): on the shared cross-engine layout model (`lib/typst/xengine.typ`; docs/EVAL-LOOP.md, "Cross-engine gate"): Times New Roman 12 pt (vendored), every line a box of its pitch (body, headings and list items 24 pt, LR 5.2(a) double spacing; court title, caption, title, block quotations and signature 13.8 pt single lines), the spaces between blocks explicit (`court-below`, `title-above`, `title-below`, `heading-above`, `quote-space`, `sig-above`, `sig-gap`), first-fit ragged-right lines without kerning, ligatures or hyphenation. Headings at the type size (level 1 in capitals). List items with the label in a half-inch box at the indent, the text hanging at 1 in; block quotations single spaced, 0.5 in in on both sides. A doubled section or pilcrow sign ("¶¶ 32-33") stays with its number, as one sign does. The page number centred in a single line whose box ends 0.5 in above the page edge. 17 pages.

**docx** (`docx/`): `reference.xml` (the Word styles: `base="xengine"` in the typst face `{font}`, the heading levels, List Para, Block Text, the footer; fb render builds `reference.docx` from it) and `kywd-motion-brief.lua` (court title, caption table with the ")" column and the case label, title, list items, signature block, optional certificate; `require("docx.xengine")` for the line boxes and break rules, and the doubled-sign binding). No shell script: `fb render` runs pandoc, converts with LibreOffice and packs the archive. Render: `sh tools/render.sh --engine docx <this-dir> usage/INPUT-motion-brief.md` writes `usage/OUTPUT-motion-brief.docx` and `usage/OUTPUT-motion-brief.docx.pdf`.

Cross-engine gate: `eval.yaml` sets `params.cross_engine: gate`; the docx breaks every line and page as typst does (XENG-001..003: 17 of 17 pages, 457/457 lines; fb-595.68.29). Every page of both renders viewed side by side at 40 dpi.

Not applicable to the docx: TOC, TOA and cross-reference fields (none in this template); pleading line numbers and vertical rules (not required by LR 5.2(a)).
