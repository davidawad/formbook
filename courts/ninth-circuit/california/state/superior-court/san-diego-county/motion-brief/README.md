# calsuperct-sandiego: motion-brief

Doc type `motion-brief` for the Superior Court of California, County of San Diego (alias `calsuperct-sandiego`). A motion (notice and memorandum of points and authorities) on pleading paper. Template: `typst/calsuperct-sandiego-motion-brief.typ`, entry `typst/main.typ`.

**Exemplar: found.** One filed San Diego Superior Court motion, `exemplars/FILED-EXAMPLE-atamian-olaplex-37-2024-00018492-motion-brief.pdf` (pp. 1-24 of the packet: notice, TOC, TOA, memorandum, signature). Case *Atamian v. Olaplex, Inc.*, No. 37-2024-00018492-CU-BT-CTL, filed 2025-04-21. Source and fetch date: `exemplars/SOURCE.md`. It is a single filer's brief, so tier 2 cannot be finished here (see below).

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
| CRC 3.1113(f) | A memorandum that exceeds 10 pages must include a table of contents and a table of authorities (verified 2026-10-15 against the rule text) | **not implemented** (see Known gaps) | same |
| SD Local Rule 2.1.2(H) | Gov. Code § 6103 exempt filer: label top right, above the caption (Local Rules, Division II, effective 1/1/2026) | optional `fee_exempt` | https://www.sdcourt.ca.gov/sites/default/files/sdcourt/generalinformation/localrulesofcourt/division_ii_-_civil_2026.pdf |
| SD Local Rule 2.1.4.1(D) | E-filed documents: PDF, text-searchable | the sample render is text-searchable (verify with `pdftotext`) | same |
| SD Local Rule 2.1.19(A) | A motion must have a hearing date reserved (online system or the judge's calendar clerk) before filing; a motion without a reserved date will not be heard | the `hearing.date` field must be a reserved date | same |

The memorandum's substantive content (CCP, CRC 3.1113 contents) is not checked by this template.

## Layout

The same as `../complaint/`: a 28-line pleading grid, double-spaced, 12 pt Liberation Serif, footer title, attorney block in lines 1-7 (measured at the absolute text width, not 100%, which mis-measures inside `layout()`). The caption's right column prints the hearing block under the nature of the paper: `Date:`, `Time:`, `Dept.:`, `Judge:`, then `Action filed:` and `Trial date:`.

No case-specific text is in the template. No coordinate was measured off the exemplar; the template was not changed in this pass. Every difference from the exemplar that is listed below is either a rule-driven match already in place, or is left open for a second exemplar to settle.

## Markdown contract

As `../complaint/README.md`, plus:

| Field | Required | Feeds |
|---|---|---|
| `caption.hearing` | yes for a motion | map with `date`, `time`, `dept`, `judge` (CRC 3.1110(b)) |
| `caption.action_filed` | yes | `Action filed:` (CRC 3.1110(b)) |
| `caption.trial_date` | no | `Trial date:` (CRC 3.1110(b)) |

Quote any YAML value containing `: `.

**Footer length.** The footer title must fit on one line at 10 pt, or it is clipped at the page edge (the second line falls off the page). The first draft of the sample used a 117-character title and was clipped on every page; the sample now uses the filer's own one-line footer. The template does not guard this; a footer title longer than one line is a sample error.

## Samples

### `samples/INPUT-atamian-motion-brief.md`: transcription of the exemplar (excerpt)

Caption and notice of motion (the filed text), the memorandum from the Introduction through the first paragraph of section III.C.2 (the lodestar), and the signature block. It is an **excerpt**: the memorandum's table of contents and table of authorities are not transcribed (the template cannot produce them), the filed footnotes are omitted, and the rest of III.C.2 and the later sections are not transcribed. Some OCR errors in the filed text were corrected (for example "loadstar" to "lodestar", "23 Cal. 429" to "23 Cal. 4th 429"). The sample is not a template; its text is the filer's.

### `samples/INPUT-synthetic-motion-brief.md`: synthetic (older)

Fictional parties, counsel and case number, placeholder argument. Kept from the rules-only pass; it has no OUTPUT or OVERLAY and is not compared with any exemplar.

## Commands

```sh
export PATH="$HOME/tb/bin:$PATH"
D=courts/ninth-circuit/california/state/superior-court/san-diego-county/motion-brief
sh tools/render.sh $D samples/INPUT-atamian-motion-brief.md
sh tools/overlay.sh $D atamian-motion-brief
pdftoppm -r 60 -png $D/samples/OUTPUT-atamian-motion-brief.pdf /work/artifacts/motion-brief/ours
```

`tools/check.sh` is not run for this doc type: there is no `checks.yaml` or `rules.md` in the folder yet, so the gates have nothing to check against.

## Results

- **render=ok.** `samples/OUTPUT-atamian-motion-brief.pdf`, 8 pages, US Letter. typst exit 0, no warnings. Fonts embedded: LiberationSerif, -Bold and -BoldItalic (vendored).
- **overlay=ok.** `samples/OVERLAY-atamian-motion-brief.pdf` (8 pages) and `.txt` (page map). The map pairs our pages 1-6 with filed pages 1, 2, 9, 10, 11, 12; ours 7 and 8 both pair with filed 14, which is a pairing artifact of the word-overlap match, not an alignment. The exemplar's broken xref makes poppler print warnings while it reads the exemplar; the overlay still exits 0.

### Gate 2 review: every page of the 8-page output rendered at 60 dpi and looked at

Also looked at: filed pp. 1, 2, 9 and 11 (the exemplar's first page, notice, and two memorandum pages), and all 8 pages of the overlay (its line-level detail is too small to read at 60 dpi; the page pairing is what was checked).

| Page | Finding |
|---|---|
| 1 | Attorney block lines 1-5 (single-spaced); court title lines 8-9; caption with the case number, the title, `CLASS ACTION`, the judge line, the `[Filed concurrently...]` line, and the hearing block (Date, Time, Dept., Action filed); the notice starts on line 23; footer title on one line. Pass. Not in ours, and filer- or clerk-specific: the clerk's "ELECTRONICALLY FILED" stamp, the "[IMAGED FILE]" tag, the firm's vertical logo, and the "Reservation Confirmation" line. Recorded as ACCEPTED (not rule-required; a second exemplar would decide). |
| 2 | Notice text continues, the "MEMORANDUM OF POINTS AND AUTHORITIES" heading (centered caps), and "I. INTRODUCTION" (centered caps). Pass on the grid. OPEN (tier 2, one filer only): the filed memorandum sets "I." flush left, not centered. |
| 3 | "II. BRIEF FACTUAL AND PROCEDURAL POSTURE" centered caps; body on lines 1-28. Pass. |
| 4 | "III." three-line centered caps heading, then the bold left "A." heading. The filed "A." heading uses a hanging indent (second line aligned under the title, not flush left). OPEN (tier 2, one filer). The page ends at line 28 with the paragraph continuing. Pass on the grid. |
| 5 | Body text on the grid, citations and italics. Pass. |
| 6 | Bold "B." heading, body. Pass. |
| 7 | "C." heading (bold, two lines), bold italic "1." heading, expense paragraph. Pass. |
| 8 | "2." heading, lodestar paragraph, `Dated: April 21, 2025`, `Respectfully submitted,` and the firm at the right at 3.1 in, `By:` line with the signer and role. Pass. The filed signature block has the same order. |

Overlay: the filed pages carry more space around headings than ours, so the line positions drift on pages 4-8 (diagnostic only; tier 3 unless a second filer shows the same).

Open tier-2 items (not decided here, because one filer is not a convention):

- Level-1 heading alignment (centered in ours, flush left in the filed).
- Level-3 heading hanging indent (filed has it, ours is flush left).
- Footer: the filed footer is bold caps, with the case number on a second line. The template's footer has one line, not bold, and no case number.
- Caption: the filed caption has the `Reservation Confirmation` line and the imaged-file tag; the template has neither.

**Tier 2 cannot be finished** for this court: EVAL-LOOP requires two or three exemplars from different filers, and this is one filer.

## Known gaps

- **Table of contents and table of authorities (tier 1).** CRC 3.1113(f) requires both for a memorandum over 10 pages. The template does not produce either. A memorandum past page 10 printed with this template is non-compliant. This is the largest gap, and it is a template feature, not a choice the rules leave open, so it needs its own bead.
- **Footnotes.** The filed memorandum has footnotes; the sample omits them, so footnote layout is untested.
- **Exemplar tier 2.** One filer only (see above).
- **Page limit.** CRC 3.1113(d) is a filer's check, not enforced. The filed memorandum (pp. 9-24 of the packet) is within it only if its page count excludes the TOC, TOA and signature page; not verified here.
- **Hearing reservation.** SD LR 2.1.19(A): the date must be reserved; the template cannot check that.
- **Notice vs memorandum.** A motion packet has a notice of motion, a memorandum, and often a separate statement and declarations. This template produces one paper.
- **Latex and docx.** Not built for this doc type.
- **Exemplar size.** `FILED-EXAMPLE-...pdf` is 6.7 MB (24 pages of an OCR'd scan). The repo carries no other exemplar PDFs; it is kept because the eval loop overlays against the real page.
- **Notice vs memorandum.** A motion packet has a notice of motion, a memorandum, and often a separate statement and declarations. This template produces one paper; a notice of motion is not a separate template here.
- **Latex.** Not built for this doc type. **Docx:** see Engines.

## Engines

**typst** is the primary form (above). **docx** (`docx/`) and **latex** (not built) are secondary.

**docx** (`docx/`): the same build as the complaint's (`build-reference.sh`, the same pleading grid, footer and line numbering), with `calsuperct-sandiego-motion-brief.lua` for the first page, the hearing block (Date, Time, Dept., Judge, Action filed, Trial date), the jury line and the signature block. `render.sh` fills the footer title from `footer_title`. Output: `samples/OUTPUT-synthetic-motion-brief.docx`.

- Matches typst: as the complaint, plus the hearing block in the caption.
- Differs: as the complaint (line numbers skip table rows; page borders span the text area; footnotes single-spaced; attorney row at least 168 pt). No exemplar exists, so there is no tier-2 comparison for Word either.
- BLOCKED (docx.pdf gates): LibreOffice is not installed, so `samples/OUTPUT-synthetic-motion-brief.docx.pdf` cannot be made; Gates 0-3 on the docx.pdf were not run. No docx page was viewed (`pages_reviewed=0`).
- BLOCKED by construction: CRC 2.108 consecutive numbering on every line, as in the complaint (table rows on page 1 are not numbered).
