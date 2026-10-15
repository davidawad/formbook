# innd: motion-brief

Doc type: **motion-brief**, the supporting memorandum for a Fed. R. Civ. P. 12 motion, in the United States District
Court for the Northern District of Indiana (`innd`). Folder: `courts/seventh-circuit/indiana/federal/northern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-mcgonigle-1-25-cv-398-motion-brief.pdf` (sampled; 15 pages), plus `exemplars/FILED-EXAMPLE-nowak-3-24-cv-950-motion-brief.pdf` (second filer; 20 pages). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-mcgonigle-motion-brief.md`: the whole memorandum transcribed (caption, I–IV headings with A/B and 1–3 sub-headings, 13 footnotes, one block quotation, conclusion, signature block, certificate of service). |
| typeface | No face named by the rule: EB Garamond (vendored), per `docs/FONTS.md` ("No face named"). Embedded per `pdffonts`: EBGaramond Regular, Bold, Italic, BoldItalic. See Known gaps 1. |
| render | ok: `samples/OUTPUT-mcgonigle-motion-brief.pdf`, 13 pages, typst 0.15.0, vendored fonts only, no warnings (re-rendered 2026-10-15) |
| overlay | ok: `samples/OVERLAY-mcgonigle-motion-brief.pdf` and `OVERLAY-mcgonigle-motion-brief.txt` (rebuilt 2026-10-15) |
| pages reviewed | 13 of 13 (every page rasterized and viewed on the 2026-10-15 build) |

File names follow `CLAUDE.md` and the `tools/` defaults (`INPUT-`, `OUTPUT-`, `OVERLAY-`); see `../complaint/README.md`.

## Governing rules

Primary sources. Sources checked on 2026-10-14:

- **N.D. Ind. L.R. 5-4(a)** (format of papers) and **L.R. 7-1** (motion practice), text from the court's Local Rules
  compilation `LocalRulesMaster2016Jan19(rev2).pdf` at https://www.innd.uscourts.gov/sites/innd/files/LocalRulesMaster2016Jan19%28rev2%29.pdf,
  pp. 12 (5-4) and 16–17 (7-1). This is the most recent version I could retrieve. **The current revision has not been
  checked against the court's current rules; verify before this template is treated as final.** The court's local-rules
  page returned 404 to the fetch tool and courtrules.net returned 403.
- **Fed. R. Civ. P. 10(a)** (caption), https://www.law.cornell.edu/rules/frcp/rule_10 (amended 2007), fetched 2026-10-14.
- **Fed. R. Civ. P. 12(b)** (defense of failure to state a claim, 12(b)(6)), https://www.law.cornell.edu/rules/frcp/rule_12, fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| L.R. 5-4(a)(2) | 8.5 × 11 inch pages. | `paper: "us-letter"`. |
| L.R. 5-4(a)(3) | At least 1-inch margins. | `margin = 1in`. |
| L.R. 5-4(a)(4) | At least 12-point type in the body; at least 10-point in footnotes. | `type-size = 12pt`; `note-size = 10pt` (`show footnote.entry`). |
| L.R. 5-4(a) (typeface) | No typeface is named. The rule sets only the 12-point and 10-point minimums above. | EB Garamond, the default in `docs/FONTS.md`; see Known gaps 1. |
| L.R. 5-4(a)(5) | Double spaced, except headings, footnotes and quoted material. | `pitch = 27.6pt`, `body-leading = 1.65em`; headings, footnotes and the block quotation are single spaced or set off by pitch. Body baselines measure 27.6 pt apart. |
| L.R. 5-4(a)(6) | Consecutively numbered pages. | Centered arabic footer on every page. |
| L.R. 5-4(a)(7) | A title on the first page. | `paper-title(meta)`: "DEFENDANT MORIARTY GEM CORP.’S MEMORANDUM IN SUPPORT OF ITS MOTION TO DISMISS UNDER RULE 12(b)(6)". |
| L.R. 5-4(a)(9) | Filer's name, address, telephone, fax (if any) and e-mail. | `signature.counsel` at the end of the memorandum (the exemplar's practice). A fax line is not in the exemplar. |
| L.R. 7-1(b)(1) | A Rule 12 motion must be filed with a supporting brief. | The template is the brief; the motion itself is a separate paper (L.R. 7-1(a)). |
| L.R. 7-1(e)(1) | Supporting briefs ordinarily at most 25 pages, excluding tables of contents, tables of authorities and appendices. | Not enforced by the template. The sample is 13 pages of text (under the limit). A longer brief needs the tables required by L.R. 7-1(e)(2). |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, file number and Rule 7(a) designation. | Court lines, division, `Case No.`, party block, title. |
| Fed. R. Civ. P. 12(b)(6) | The defense of failure to state a claim is raised by motion. | Content only; the template does not check the motion's wording. |

Not produced by this template (separate filings): the motion itself, the proposed order, any declarations or exhibits (L.R. 5-4(a)(8) index applies above four exhibits), and the Rule 7.1 disclosure statement.

## Layout

- Court lines and division centered in bold, single spaced, at the top of page 1.
- Caption: party block left (3.2 in), closed by a right rule and a bottom rule; "v." between parties; the designation indented. Right column: `Case No. ...`, and `Judge ...` when `judge` is given.
- Title: centered bold caps after the caption.
- Body: unnumbered paragraphs with a 0.5 in first-line indent, no space between paragraphs (the double spacing is the spacing). Headings: level 1 centered bold caps (`I. INTRODUCTION`); level 2 bold, left (`A. A Text Message is Not a “Telephone Call.”`); level 3 bold italic, left (`1. The FCC’s 2003 TCPA Order ...`).
- Footnotes: real typst footnotes at 10 pt, single spaced.
- Block quotation: indented 0.5 in on each side, single spaced.
- The signature block and the certificate of service are kept on one page with the last body chunk, so neither stands alone.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `case_number`; `court` (list of lines); `division` (optional); `caption.parties` (list of `{names: [...], designation}`); `title`; `signature` (`dated`, `party` (optional), `by`, `role` (optional), `counsel` (lines; `""` is a blank line)); `certificate` (`title`, `text`, `counsel`) (optional).
- Body chunks are separated by blank lines:
  - `# TEXT` is a level 1 heading; `## TEXT` a level 2 heading; `### TEXT` a level 3 heading.
  - A list is rendered with `1.` lettering (not used by this sample).
  - `> text` is a block quotation.
  - Any other chunk is a paragraph.
  - Footnotes: the marker `[^n]` in the text, and a chunk `[^n]: text` anywhere in the body (usually at the end). The template renders them as real footnotes.
- Literal asterisks (LEXIS star pages, "at \*3") are escaped as `\*` in the markdown so they do not open emphasis.
- Case names, "Id." and signals (*See*, *see also*, *cf.*) are italic (`*...*`), as in the filing.
- Not supported: tables, raw typst.

## Known gaps and open choices

1. **Font.** No typeface is named by N.D. Ind. L.R. 5-4(a) (checked 2026-10-15 against the 2016 local-rules compilation; see Governing rules), so the template keeps EB Garamond, the no-face default in `docs/FONTS.md`. The filers use Times New Roman, but the rules do not require it, so that is a tier-2 difference: EB Garamond at 12 pt has a smaller x-height than Times, and the text looks smaller than the exemplar. The 12-point minimum is met. If the court's current rules name a face, switch to that face's substitute from `docs/FONTS.md` (Liberation Serif for Times New Roman).
2. **Caption.** A rule-closed party block, not a ")" column. The sampled filer used no column at all; the second exemplar's caption is different again. Recorded as ACCEPTED.
3. **Heading case.** The sample's level 2 and 3 headings follow the filing's own capitalization (for example "is Not", "did Not", "did not"); the filing is not consistent and the template does not normalize it.
4. **Quotation citation.** The citation that follows the block quotation (`2003 TCPA Order, 18 FCC Rcd. 14014 ¶ 166 (emphasis added).`) is a continuation paragraph with an indent; in the filing it continues the text flush left. Tier-2 cosmetic difference.
5. **Non-breaking spaces.** `¶` and the number after it can break across lines (for example "Compl. ¶ / 62"). The template does not set non-breaking spaces; the filing does not seem to either.
6. **Page limit not enforced** (see the rules table).
7. **Second exemplar not compared page by page.** The Nowak memorandum (20 pages) is in `exemplars/`; its first and last pages were read for structure and the certificate was checked, but it was not rendered side by side with our output. Tier-2 rests on the sampled filing and the rules.
8. **Gate scripts not run** (same reason as the complaint: `tools/check.sh` expects a court folder with `court.json`; the brief forbids touching `tools/`).
9. **Current local rules unverified** (see Governing rules).

## Review of the rendered pages (final build)

- Page 1: caption, the title, the Introduction. Footnote 1 at the foot of the page. Pass. As in the complaint, the division line overlapped the second court line in the 2026-10-14 build; fixed in `cover()` (same single-spaced stack) and checked at 110 dpi.
- Page 2: Introduction (continued), II. STANDARD OF REVIEW, III. heading (two lines), A. heading. Pass.
- Page 3: A. text, footnotes 2 and 3 at the foot. Pass.
- Page 4: the end of Section III.A text; footnote 4 begins at the foot (it continues on page 5). Pass.
- Page 5: the end of III.A, the B. heading (two lines), the first paragraph of B.; the continuation of footnote 4 at the foot. Pass.
- Page 6: the 2023 TCPA Order citation and the 1991–1992 rulemaking discussion; footnote 5 at the foot. Pass.
- Page 7: the Congressional private-right discussion and the 2003 Order paragraph; footnotes 6 and 7 at the foot. Pass.
- Page 8: B.1. heading (bold italic), footnotes 8 and 9. Pass.
- Page 9: B.2. heading, footnotes 10 and 11, the start of the block-quotation paragraph. Pass.
- Page 10: the block quotation (single spaced, indented), the citation paragraph, B.3. heading, footnote 12. Pass.
- Page 11: the 2023 Order reasoning, footnote 13 (Loper Bright). Pass.
- Page 12: the Chevron and FEC paragraphs; conclusion of B.3. Pass.
- Page 13: IV. CONCLUSION, the signature block (Dated; Respectfully submitted; By; the counsel lines including the second firm), and the certificate of service with its signature. No page holds the signature alone. Pass.

Earlier builds had two defects, fixed and re-rendered: (a) a space after a footnote marker was lost ("call.’”¹If"), because the inline renderer trims spaces at its edges (fixed: `seg()` restores the space); (b) the same leading defect as the complaint (fixed: `below: body-leading` on every block).

Overlay: `samples/OVERLAY-mcgonigle-motion-brief.txt` pairs our pages 1–13 with filed pages 1–6 and 8–14. Filed page 7 and filed page 15 are not the best match for any page of ours; filed page 15 is the certificate of service, which our page 13 carries. Word overlap 47–87%. The overlay is a diagnostic, not a score.

## Engines

DOCX (`docx/`): pandoc on `docx/reference.docx` (built by `sh docx/build-reference.sh docx/reference.docx`) with the filter `docx/innd.lua`. Output: `samples/OUTPUT-mcgonigle-motion-brief.docx`.

- Matches the typst form: EB Garamond 12 pt body, exact 27.6 pt double line pitch, 0.5 in first-line indent, 1 in margins on letter paper, 10 pt single-spaced footnotes, 13.8 pt single lines in the caption and signature, centered page-number footer, headings (level 1 centered caps, level 2 bold, level 3 bold italic), single-spaced block quotes, "1." labelled lists, caption table with a right and bottom rule on the party column, certificate of service after the signature.
- Differs or unverified: paragraph gap (19.8 pt) is set as space-after; the signature and certificate blocks are tables, so they are not kept on one page with the last paragraph as typst does (no keep-with-next); the list tab stop approximates typst's label gap; table border weights and cell padding are not compared against the typst layout.
- BLOCKED on this box: the `.docx.pdf` (LibreOffice conversion) was not produced because `soffice` is not installed. No page was rendered or reviewed, so no Gate 0/1 result exists for docx. Checked: the `.docx` zip is intact and every XML part is well-formed. Word and LibreOffice open-without-repair is not verified.
- No table of contents or table of authorities in this doc type, so no field update is needed.
