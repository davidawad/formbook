# casd: motion-brief

Doc type: **motion-brief**, the memorandum of points and authorities in support of a Rule 12(b)(6) motion to dismiss, in the United States District Court for the Southern District of California (`casd`).
Folder: `courts/ninth-circuit/california/federal/southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (a portion of the 42-page attachment: cover, TOC, TOA, introduction, factual background, standard of review, arguments I, II and III, conclusion, signature) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-sager-motion-brief.pdf` and `OVERLAY-sager-motion-brief.txt` |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed; the cover was re-checked after the last change; all 8 re-viewed on 2026-10-15 in the typeface pass, no template change) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| S.D. Cal. Civil L.R. 5.1 | Papers typed double-spaced on one side, line-numbered in the left margin, not more than 28 lines per page, letter size. | `lines-per-page = 28`, `line-pitch = 24pt`, `page-w = 8.5in`, `pleading-background()`. |
| S.D. Cal. Civil L.R. 5.1 | Proportional font such as Times New Roman at 14-point; no smaller type for text, footnotes or quotations. | `type-size = 14pt` for body, headings, caption and counsel. Footer 10 pt (gap 3). |
| S.D. Cal. Civil L.R. 5.1 (typeface) | No face is required. "Such as Times New Roman" is an example, not a requirement, so the court-named-face substitution does not apply. | Face required: none. Font: **EB Garamond** (kept; `font-family` in `casd-motion-brief.typ`). Substitute not used, so the fit column is n/a. |
| S.D. Cal. Civil L.R. 7.1 | Memorandum length and form for motions. | **Not verified** (see below). The template enforces no page limit. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `court`, `caption`, `case_number` on the cover. |
| Fed. R. Civ. P. 12(b)(6), 8 | Rule text used by the memorandum; not a formatting rule. | Body text only. |

Rule text: Fed. R. Civ. P. 10 fetched from https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14 (amended 2007-12-01).

S.D. Cal. Civil L.R. 5.1: **not verified against the court's primary text.** The court's own site returned 404 to every fetch made on 2026-10-14. The text used is the search-engine excerpt of CivLR 5.1 from courtrules.net (https://www.courtrules.net/courts/federal/southern-district-california/local-rules/27072; that page returned 403 to the fetch tool): double space on one side, line numbers in the left margin, no more than 28 lines per page, letter size, and a proportional font such as Times New Roman at 14-point. The exemplar's body text measures 14-point (FontBBox-based estimate from the text layer). Before this doc type is marked done, check CivLR 5.1 and 7.1 against the court's current Local Rules PDF (the casd.uscourts.gov Local Rules PDF was listed by the search engine but returned 404 from every path tried).

Not produced by this template, and not checked: a table of authorities listing every authority (only the linked ones, gap 6); the notice of motion (a separate filing that the exemplar's cover refers to as "Filed concurrently"); a proposed order; the statement of word or page count, if required.

## Layout

- Pleading paper as the complaint (`../complaint/`): numbered lines 1 to 28, double rule at the text's left edge and a single rule at its right, footer below line 28.
- Top margin 72 pt, so line 1 sits on the top margin and line 28 ends at 10.33 inches. The footer (page number, title, case number) sits in the bottom margin.
- Line pitch 24 pt. Body leading `14.9pt` gives that pitch at 14 pt EB Garamond with the cap-height / baseline text edges (measured: 24.00 pt on every body line; counsel and caption single-spaced at 12.6 pt).
- Paragraphs have paragraph spacing equal to the leading (`pleading-par`), so a paragraph of n lines is n × 24 pt less 14.9 pt, and the spacing restores the grid. A heading block has `above: body-leading` and is sized to whole lines (`on-grid`), so the text after it stays on the grid.
- Front matter: cover (no number), table of contents (roman `i`), table of authorities (roman `ii`), body (arabic from 1). The page number is drawn once, by the pleading footer (`footer-block`); the default page-number footer is turned off (`footer: none`).
- Headings: level 1 centered caps (INTRODUCTION, CONCLUSION); level 2 `I.`, `II.` with a hanging indent; level 3 `A.`, `B.` (not used in the sample). The table of contents is built from the heading elements; the table of authorities from `toa:` links in the body.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number`, `court` (list of lines, centered over the caption), `counsel` (lines, single-spaced at the upper left), `counsel_role` (italic line under the counsel), `caption` (list of `{names, designation}`), `brief_title`, `footer_title`, `hearing` (`date`, `time`, `place`, `judge`; each optional except the template prints whichever are present), `authorities` (map of key to `{kind, name, cite}`; kinds `case`, `rule`, `statute`, `regulation`, `other`), `signature` (`preamble` lines, `signer`, `lines`), `date`.
- Body: `#` centered caps heading, `##` numbered heading (`I.`), `###` lettered heading (`A.`), paragraphs, italic with `*...*`. Authorities: `[*Name*](toa:key)` marks the first citation for the TOA; a `toa:` key with no entry in `authorities:` fails the render.
- Not supported in the sample: footnotes (omitted; the cand footnote rules were not tested here), tables.

## Known gaps and open choices

1. **Only one exemplar.** Tier 2 asks for 2 or 3 filers. The CourtListener search found other S.D. Cal. motions to dismiss in 2026 (e.g. Wright v. Last Brand, Inc., 3:26-cv-04009, Davis Wright Tremaine LLP, doc 9; Nietz v. LPL Financial LLC, 3:26-cv-03383, Bursor & Fisher, doc 20), not downloaded. Tier 2 is therefore **not** judged against two filers yet.
2. **Font.** CivLR 5.1 names Times New Roman only as an example ("a proportional font such as Times New Roman"), so the rule names no face and this template keeps EB Garamond at 14 pt. `fonts/liberation-serif/` (the Times New Roman substitute, metric-compatible per `docs/FONTS.md`) is vendored, so switching is a one-line change in `font-family` if David reads the exemplar's Times as the clerk's convention. EB Garamond has a smaller x-height than Times, so the sample reads smaller than the exemplar at the same nominal size. Question for David: should the S.D. Cal. templates keep EB Garamond (the rule's text allows any proportional font) or use Liberation Serif (the exemplar's face)?
3. **Footer type size.** 10 pt (title and case number). Logged as an interpretation, as in the complaint template.
4. **Length.** The sample is 8 pages: cover, two front-matter pages, five body pages. The brief's target was 8 to 14 pages; the filed memorandum is 42 pages and the transcription covers its introduction, factual background, standard of review, three argument sections and the conclusion. Transcribing more body text would bring the sample into the target range. The template handles longer bodies (the TOC and TOA are generated).
5. **Cover contents.** The cover follows the exemplar: counsel at the upper left, court title, caption, title, hearing block. The exemplar's "[Filed concurrently with ...]" line and the chambers note on oral argument are omitted from the sample's hearing block (the "Time" entry is "Under Submission").
6. **Table of authorities is partial.** It lists only the authorities the sample links with `toa:` keys. The filed TOA lists every authority; the sample's authorities are the ones it cites with a link (about ten). Cites in the sample that are not linked (for example Gilead, Barzen, Graff) do not appear in the TOA.
7. **TOA wrap.** A long TOA entry (ServiceMaster) wraps its page number onto a second line. Cosmetic; the entry is in the TOA but the layout could use a grid like the TOC.
8. **Signature block.** The template prints "Respectfully submitted," and the firm name (from `signature.preamble`); the exemplar has the date, the firm and the "By: /s/" line without "Respectfully submitted". Convention, not a rule; logged.
9. **Heading placement.** The grid rule adds `body-leading` of space above each heading, so a heading at the top of a page is 15 pt below the grid line; accepted.
10. **Overlay names.** `tools/overlay.sh` reads `usage/OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf` and `.txt`; these are the names the tools use, not `<id>.pdf` and `<id>-overlay.pdf`.
11. **Overlay pairing.** Pages are paired by shared words: sample p.1 (cover) with filed p.1; p.2 (TOC) with filed p.2; p.3 (TOA) with filed p.5 (the TOA page); p.4 and p.5 (body) with filed pp.12 and 13; p.6 with filed p.15; p.7 and p.8 (unjust enrichment and conclusion) with filed pp.40 and 41. The pairings are a diagnostic, not a score.
12. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court directory with `court.json` and `rules.md`, and this doc-type folder does not have that shape. The gates were not run; render and overlay were run, and the review below is the Gate 2 equivalent for this doc type.

## Review of the rendered pages (current PDF)

- Page 1 (cover): counsel block lines 1 to 12 (single-spaced, the role line in italics), court title, caption with the party column closed by a rule, the title in bold caps at the right, the hearing block (date, time, place, judge). Footer: title and case number. The caption fits on page 1 (an earlier version spilled two lines onto page 2; the cover spacing was reduced). Pass.
- Page 2 (table of contents, roman `i`): TOC entries with dot leaders and page numbers that match the body (INTRODUCTION 1, FACTUAL BACKGROUND 1, STANDARD OF REVIEW 2, ARGUMENT 3, I. 3, II. 3, III. 4, CONCLUSION 5). Pass.
- Page 3 (table of authorities, roman `ii`): cases and federal rules, page numbers from the body. The ServiceMaster entry wraps its page number (gap 7). Pass with the noted gap.
- Page 4 (body 1): INTRODUCTION heading, ¶¶ of the introduction, FACTUAL BACKGROUND heading after the introduction (no overlap), paragraphs on the numbered lines. Pass.
- Page 5 (body 2): cash sweep background, STANDARD OF REVIEW heading, the Iqbal and Twombly quotations. Pass.
- Page 6 (body 3): ARGUMENT heading, the I. heading (three lines, two rows), its paragraph, the II. heading and its paragraph. Pass.
- Page 7 (body 4): III. heading (two lines), the unjust enrichment paragraphs, quotations, the Wright citation starting at the foot. Pass.
- Page 8 (body 5): the end of the Wright paragraph, CONCLUSION heading, the conclusion, the date, the firm line, "/s/" signature block with the signer and attorney lines. Pass.

Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).

## Engines

### docx

`docx/reference.xml` holds the Word styles and the page setup; fb render builds `reference.docx` from it and pandoc's default reference (`tools/fb/src/docxref.rs`). `docx/casd.lua` is the filter. Sample: `usage/OUTPUT-motion-brief.docx` and its LibreOffice PDF `usage/OUTPUT-motion-brief.docx.pdf` (9 pages, as typst).

As the typst template (fb-595.63, 2026-10-21):

- Times New Roman 14 pt in every style (the typst face), black text.
- 24 pt exact line spacing on body, heading, list and block text; no space before or after; paragraphs run on without gaps. First-line indent 0.5 in on body paragraphs.
- Headings: level 1 centered bold; level 2 (`I.`) bold with a 0.5 in hanging indent; level 3 (`A.`) bold italic with a hanging indent at 1 in. The labels are typed text (`I.` plus a tab), written by the filter.
- US Letter; top, right and bottom 1 in, left 1.5 in: 27 lines of 24 pt, as typst's `lines-per-page` (CivLR 5.1 allows 28). The right margin was 0.75 in and the bottom 48 pt (28 lines), so the last line and long lines ran into the 1 in margins (DEF-FORM-002, DEF-CONT-001).
- Word line numbering (`w:lnNumType`, restart each page), ending 1 in from the page edge as typst's numbers do, and a double rule at the left and a single rule at the right of the text (`w:pgBorders`).
- Three sections: the cover (footer without a page number), the contents and authorities (i, ii), the memorandum (1, 2 ...). The footer (10 pt, centered below the last line): the page number, the paper's title in capitals and the case number, written by the filter from the sample (`FORMBOOK_FOOTERS`).
- The cover: counsel, the court in bold capitals, then the caption table: the parties at the left, closed by a rule at its right and bottom, and the case number, the title in bold capitals and the noticed hearing (Date, Time, Place, judge) at the right.
- The table of contents (levels 1 to 4, with labels) and the table of authorities (Cases, Federal Statutes, Federal Rules, Federal Regulations, Other Authorities, as typst) carry dot leaders and page numbers (`passim` from 7 pages), from fb render's multi-pass docx engine (`tools/fb/src/docxpass.rs`, as ca9; the pleading line numbers in the text flow are left out when the pages are searched, `tools/fb/src/docxpages.rs`).
- The closing paragraph is kept with the signature block ("Dated:", "Respectfully submitted," the firm, "By: /s/" and the signer).

What differs from the typst template:

- Word numbers text lines (`lnNumType`), not a fixed grid on every page: lines inside the caption table and single-spaced lines (counsel, tables) are numbered one by one or not at all. Word does not number lines in a table (docs/DOCX.md).
- Word may paginate slightly differently from the LibreOffice PDF the page numbers come from.
- Footnote Text is single spaced (a convention, not verified); no footnotes in the sample.

`sh tools/check.sh courts/ninth-circuit/california/federal/southern-district/motion-brief --engine docx`: RESULT 8 checks passed, 0 failed. Every page of the 9-page `.docx.pdf` was viewed. Word fidelity (repair prompt, line-number placement, border offsets) is not checked in Word.
