# calsuperct-sandiego: motion-brief

Doc type `motion-brief` for the Superior Court of California, County of San Diego (alias `calsuperct-sandiego`). A motion (notice and memorandum of points and authorities) on pleading paper. Template: `typst/calsuperct-sandiego-motion-brief.typ`, entry `typst/main.typ`.

**Exemplar: found.** One filed San Diego Superior Court motion, `usage/SAMPLE-calsuperct-sandiego-motion-brief-atamianolaplex37202400018492.pdf` (pp. 1-24 of the packet: notice, TOC, TOA, memorandum, signature). Case *Atamian v. Olaplex, Inc.*, No. 37-2024-00018492-CU-BT-CTL, filed 2025-04-21. Source and fetch date: `usage/SOURCE.md`. It is a single filer's brief, so tier 2 cannot be finished here (see below).

## Searches

Before the exemplar was found (earlier session):

1. `People v. Sun Healthcare complaint San Diego Superior Court filed pdf` (standard): no San Diego filing under that name.
2. `San Diego Superior Court motion pleading paper pdf "Superior Court of California, County of San Diego" memorandum of points and authorities filed` (standard): general guidance only.
3. Extended: `"County of San Diego" "Superior Court" memorandum of points and authorities ... 25CU033612N`: San Diego practice guides, no filings.
4. https://oag.ca.gov/node/30187: a 2005 Sweetwater complaint and injunction, not a motion.

This session:

5. CourtListener API v4 search (anonymous, no key set): `"County of San Diego" "memorandum of points and authorities" motion`, `"Superior Court of California" "County of San Diego" "notice of motion and motion"`, and `"San Diego Superior Court" "memorandum of points and authorities"`. Returned federal dockets (S.D. Cal.) and unrelated cases only.
6. CourtListener search for `Sweetwater Care OpCo`: federal and bankruptcy dockets only.
7. oag.ca.gov pages for the Sweetwater case (`node/604371`, `node/627201`, the 2026 press release): the complaint and a proposed stipulated final judgment. No motion is posted.
8. WebSearch (standard and extended) for San Diego motions, memoranda and `37-2024`/`37-2025` filings: one usable hit, the Atamian motion, hosted by the claims administrator (Simpluris). Fetched, checked as a text PDF with a 2025-04-21 filing stamp in San Diego Dept. C-72, and saved as the exemplar.

Not yet tried: the court's own case-search portal (requires a case number and is not indexed), Trellis (paywalled).

## Governing rules

Verified 2026-10-15 unless the row says otherwise.

| Rule | Requirement | Used for | Source |
|---|---|---|---|
| CRC 2.104 | Font size not smaller than 12 points (amended 2017-01-01) | `type-size = 12pt` | https://www.courts.ca.gov/cms/rules/index/two/rule2_104 |
| CRC 2.105 | Font style essentially equivalent to Courier, Times New Roman, or Arial (amended 2017-01-01) | **Liberation Serif** (Times New Roman row of `docs/FONTS.md`) | https://www.courts.ca.gov/cms/rules/index/two/rule2_105 |
| CRC 2.107, 2.108, 2.109, 2.110 | Margins; double-spaced numbered lines; page numbers; footer title ≥10 pt (verified 2026-10-13 by the sibling complaint; not re-fetched today) | the same grid as `../complaint/` | https://www.courts.ca.gov/cms/rules/index/two/rule2_107 (and 2_108, 2_109, 2_110) |
| CRC 2.111(1)-(7) | First-page format: attorney block lines 1-7, court title on line 8, caption, case number, nature of the paper, judge and department (verified 2026-10-15, summarized) | first page | https://www.courts.ca.gov/cms/rules/index/two/rule2_111 |
| CRC 3.1110(b) | First page of each paper states the date, time and place of any scheduled hearing, the hearing judge if ascertainable, the title, the filing date of the action, and the trial date if set (verified 2026-10-15, summarized; amended 2017-01-01) | the caption's `hearing`, `action_filed`, `trial_date` fields | https://www.courts.ca.gov/cms/rules/index/three/rule3_1110 |
| CRC 3.1113(d) | Opening or responding memorandum: no more than 15 pages, except summary judgment and summary adjudication motions (verified 2026-10-15; amended 2017-01-01). The template does not count pages; the limit is a check for the filer. | not enforced by the template | https://www.courts.ca.gov/cms/rules/index/three/rule3_1113 |
| CRC 3.1113(f) | A memorandum that exceeds 10 pages must include a table of contents and a table of authorities (verified 2026-10-15 against the rule text) | `authorities:` builds both tables; without them, a memorandum over 10 pages stops the render (see Layout) | same |
| SD Local Rule 2.1.2(H) | Gov. Code § 6103 exempt filer: label top right, above the caption (Local Rules, Division II, effective 1/1/2026) | optional `fee_exempt` | https://www.sdcourt.ca.gov/sites/default/files/sdcourt/generalinformation/localrulesofcourt/division_ii_-_civil_2026.pdf |
| SD Local Rule 2.1.4.1(D) | E-filed documents: PDF, text-searchable | the sample render is text-searchable (verify with `pdftotext`) | same |
| SD Local Rule 2.1.19(A) | A motion must have a hearing date reserved (online system or the judge's calendar clerk) before filing; a motion without a reserved date will not be heard | the `hearing.date` field must be a reserved date | same |

The memorandum's substantive content (CCP, CRC 3.1113 contents) is not checked by this template.

## Layout

The same as `../complaint/`: a 28-line pleading grid, double-spaced, 12 pt Liberation Serif, footer title, attorney block in lines 1-7 (measured at the absolute text width, not 100%, which mis-measures inside `layout()`). The caption's right column prints the hearing block under the nature of the paper: `Date:`, `Time:`, `Dept.:`, `Judge:`, then `Action filed:` and `Trial date:`.

**Tables (CRC 3.1113(f), added 2026-10-16).** When the frontmatter has `authorities:`, the paper gets a table of contents and a table of authorities. Order: caption page (any notice of motion text follows the caption), then the TOC on a new page, the TOA on a new page, then the memorandum. The caption page, notice and tables are numbered in lowercase roman (i, ii, ...); the memorandum restarts at 1 (CRC 2.109 asks for consecutive numbering at the bottom; the roman front matter is the exemplar's convention, which numbers its TOC "i"). A body with a `## MEMORANDUM OF POINTS AND AUTHORITIES` heading is split there (notice before, memorandum after); without that heading the whole body is the memorandum. The TOC lists every heading of the memorandum, indented 0.5 in per level below the top one, dot leader, page number. The TOA groups authorities as CASES, CONSTITUTIONAL PROVISIONS, STATUTES, REGULATIONS, RULES, OTHER AUTHORITIES (bold caps, flush left), each case name in italics with the citation on the next line (0.25 in hang), dot leader and every page that cites it. Every row of both tables sits on the 24 pt pleading grid.

**Length check.** Without `authorities:`, the template measures the memorandum (from its first line to the signature) and stops with an error when it runs over 10 pages, quoting CRC 3.1113(f). Tested 2026-10-16: the atamian sample with its `authorities:` block removed fails with "the memorandum runs 11 pages; CRC 3.1113(f) requires a table of contents and a table of authorities over 10".

**Signature kept with the text.** The memorandum's last paragraph is kept on the page with the signature block, so the signature never stands alone (trailing footnote definitions stay with the body; a last paragraph that is a heading, a quotation or carries a footnote reference is not split off).

No case-specific text is in the template. No coordinate was measured off the exemplar. Every difference from the exemplar listed below is either a rule-driven match already in place, or is left open for a second exemplar to settle.

## Markdown contract

As `../complaint/README.md`, plus:

| Field | Required | Feeds |
|---|---|---|
| `caption.hearing` | yes for a motion | map with `date`, `time`, `dept`, `judge` (CRC 3.1110(b)) |
| `caption.action_filed` | yes | `Action filed:` (CRC 3.1110(b)) |
| `caption.trial_date` | no | `Trial date:` (CRC 3.1110(b)) |
| `authorities` | yes when the memorandum exceeds 10 pages | map `key: {kind, name?, cite, sort?}`; `kind` is `case`, `constitution`, `statute`, `regulation`, `rule` or `other`. A citation in the body is a link `[text](toa:key)`; a key with no entry stops the render. Citation links are not allowed in headings. |

Quote any YAML value containing `: `.

**Footer length.** The footer title must fit on one line at 10 pt, or it is clipped at the page edge. The template does not guard this; a footer title longer than one line is a sample error.

## Samples

### `usage/INPUT-calsuperct-sandiego-motion-brief-atamian.md`: transcription of the exemplar's memorandum (excerpt)

Rewritten 2026-10-16 (bead batch fb-afcu). The filed packet holds two papers: the notice of motion (filed pp. 1-2, its own caption and signature) and the memorandum (filed p. 3 caption, TOC p. i, TOA pp. ii-v, body pp. 1-16). The sample now transcribes the **memorandum** paper: its caption page (title, `CLASS ACTION`, judge line, `[IMAGED FILE]`, hearing block), the memorandum from I. Introduction through the end of section III.C.2.i (the 3.45 multiplier), footnotes 2-6 of the filing (numbered 1-5 here, because the notice's footnote 1 is in the other paper), and the signature block. The TOC and TOA are generated by the template from the headings and the 28 `toa:` citations; they list only the authorities cited in the transcribed part. Not transcribed: sections III.C.2.ii-vi, IV-VI, the hours table, and the additional-counsel block. OCR errors in the filed text were corrected where the reading is certain ("23 Cal. 429" to "23 Cal. 4th 429"). Case names are italicized (the scan's text layer carries no styling). The notice of motion is not in this sample; it renders with the same template as a paper without tables.

### `usage/INPUT-calsuperct-sandiego-motion-brief-synthetic.md`: synthetic (older)

Fictional parties, counsel and case number, placeholder argument, no `authorities:`. Kept from the rules-only pass to exercise the no-tables path (2 pages, arabic page numbers); not compared with any exemplar.

## Commands

```sh
export PATH="$HOME/tb/bin:$PATH"
D=courts/ninth-circuit/california/state/superior-court/san-diego-county/motion-brief
sh tools/render.sh $D usage/INPUT-calsuperct-sandiego-motion-brief-atamian.md
sh tools/overlay.sh $D atamian-motion-brief
pdftoppm -r 60 -png $D/usage/OUTPUT-atamian-motion-brief.pdf /tmp/sd/p
```

`tools/check.sh` is not run for this doc type: there is no `checks.yaml` or `rules.md` in the folder yet, so the gates have nothing to check against.

## Results (2026-10-16)

- **render=ok.** `usage/OUTPUT-calsuperct-sandiego-motion-brief-atamian.typst.pdf`, 14 pages (i-iv front matter, 1-10 memorandum), US Letter. typst exit 0, no warnings. `usage/OUTPUT-calsuperct-sandiego-motion-brief-synthetic.typst.pdf`, 2 pages, exit 0.
- **overlay=ok.** `usage/OVERLAY-atamian-motion-brief.pdf` (14 pages) and `.txt`. Page map: ours 1 (caption) to filed 3 (88%); ours 2 (TOC) to filed 4 (63%); ours 3-4 (TOA) to filed 5 and 7 (42%, 60%: our TOA lists 21 of the filed 45 cases); ours 5-13 (memorandum pp. 1-9) to filed 9-17 in order (59-95%); ours 14 (memorandum p. 10: the end of III.C.2.i and the signature) to filed 17 again (38%), because the filed brief continues with section ii where our excerpt stops. The exemplar's broken xref makes poppler print warnings while reading it; the overlay exits 0.

### Gate 2 review: all 14 pages rendered at 60 dpi and looked at (2026-10-16), plus all 14 overlay pages

| Page | Finding |
|---|---|
| i | Attorney block lines 1-5; court title lines 8-9; caption from line 11 with case number, the four-line bold title, `CLASS ACTION`, judge line, `[IMAGED FILE]`, hearing block; footer `i`. No body text, as in the filed caption page. Pass. |
| ii | TABLE OF CONTENTS centered bold on line 1; entries from line 2, one grid line each, nested 0.5 in per level, wrapped lines hang under the entry, dot leaders, page numbers 1-8 right-aligned. Pass. |
| iii | TABLE OF AUTHORITIES centered bold; CASES bold caps; each case: italic name line, citation on the next grid line with leader and pages. Rows on the grid. Pass. |
| iv | Cases continue (Serrano ... Walker); STATUTES and REGULATIONS groups. Pass. |
| 1 | I. INTRODUCTION, II. heading, body double-spaced on lines 1-28. Pass. |
| 2 | Body continues; ends at line 27 because the three-line III. heading moves to the next page with its first paragraph. Pass. |
| 3 | III. heading (four lines, centered bold caps), A. heading, body. Pass. |
| 4-5 | Body, citations italic; B. heading on p. 4. Pass. |
| 6 | C. heading, bold italic 1. heading, footnotes 1-2 single-spaced at 12 pt under a short rule, below line 26. Pass. |
| 7-9 | Body, footnotes 3-5, 2. and i. headings. Pass. |
| 10 | Last two paragraphs, then `Dated:` and the signature block at 3.1 in with `By:` line, signer, role. Pass. |

Open tier-2 items (one filer, so not decided):

- Level-1 heading alignment (centered in ours, flush left in the filed); level-3 hanging indent (filed has it).
- Footer: the filed footer is bold caps, with the case number on a second line; ours is one line, not bold.
- Caption order: the filed puts `CLASS ACTION` and the judge line above the title, and has a `Reservation Confirmation` line.
- TOC: the filed TOC starts on line 3 (a blank line after the title) and prints no page for its I. entry; TOA: the filed puts a blank line between some entries. ACCEPTED as tier 3.
- Front-matter numbering: the filed caption page carries no page number and the TOC is "i"; ours numbers the caption page "i". ACCEPTED (both are consecutive; rules leave it open).

**Tier 2 cannot be finished** for this court: EVAL-LOOP requires two or three exemplars from different filers, and this is one filer.

## Known gaps

- **Footnote numbering across papers.** The filed memorandum continues the notice's footnote numbers (2-6); the template numbers each paper from 1.
- **Exemplar tier 2.** One filer only (see above).
- **Page limit.** CRC 3.1113(d) (15 pages, excluding caption page, tables, exhibits) is a filer's check, not enforced. The filed memorandum body is 16 pages.
- **Hearing reservation.** SD LR 2.1.19(A): the date must be reserved; the template cannot check that.
- **Notice vs memorandum.** A packet often has a separate notice, a memorandum, a separate statement and declarations; this template produces one paper at a time (a notice, a memorandum, or a combined notice and memorandum).
- **Exemplar size.** `SAMPLE-...pdf` is 6.7 MB (24 pages of an OCR'd scan); kept because the eval loop overlays against the real page.
- **Latex.** Not built for this doc type. **Docx:** see Engines; the docx filter does not build the TOC and TOA (paused, typst-only batch).

## Engines

**typst** is the primary form (above). **docx** (`docx/`) and **latex** (not built) are secondary.

**docx** (`docx/`): the same build as the complaint's (`build-reference.sh`, the same pleading grid, footer and line numbering), with `calsuperct-sandiego-motion-brief.lua` for the first page, the hearing block (Date, Time, Dept., Judge, Action filed, Trial date), the jury line and the signature block. `render.sh` fills the footer title from `footer_title`. Output: `usage/OUTPUT-calsuperct-sandiego-motion-brief-synthetic.docx`.

- Matches typst: as the complaint, plus the hearing block in the caption.
- Differs: as the complaint (line numbers skip table rows; page borders span the text area; footnotes single-spaced; attorney row at least 168 pt). No exemplar exists, so there is no tier-2 comparison for Word either.
- BLOCKED (docx.pdf gates): LibreOffice is not installed, so `usage/OUTPUT-synthetic-motion-brief.docx.pdf` cannot be made; Gates 0-3 on the docx.pdf were not run. No docx page was viewed (`pages_reviewed=0`).
- BLOCKED by construction: CRC 2.108 consecutive numbering on every line, as in the complaint (table rows on page 1 are not numbered).
