# msnd: complaint

Doc type: **complaint** in the United States District Court for the Northern District of Mississippi (`msnd`).
Folder: `courts/fifth-circuit/mississippi/federal/northern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer, 20 pp; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (transcription of the complaint's caption, parties, jurisdiction, background, Counts I–III, prayer, jury demand and signature; the figures are noted, not reproduced) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 13 pages (11 on the earlier EB Garamond render, before fb-595.68), typst 0.15.0, pinned Times New Roman only, no warnings (`sh tools/render.sh <this dir> usage/INPUT-complaint.md`) |
| overlay | ok: `usage/OVERLAY-haas-complaint.pdf` and `OVERLAY-haas-complaint.txt` (`sh tools/overlay.sh <this dir> haas-complaint`) |
| pages reviewed | 11 of 11 on the earlier EB Garamond render, before fb-595.68 (every page rendered at 60 dpi and viewed after the last template change) |

File names follow `tools/render.sh` and `tools/overlay.sh` (`OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`/`.txt`), so the sample is `INPUT-<id>.md` and the id is `haas-complaint`.

## Governing rules

The court's own local rules are the N.D. and S.D. Mississippi Local Uniform Civil Rules, the joint "2024 Local Civil Rules MSSD MSND" compilation: https://www.mssd.uscourts.gov/sites/mssd/files/2024%20Local%20Civil%20Rules%20MSSD%20MSND%20(.pdf) (fetched 2026-10-14; 164 pages). The federal rules are from Cornell LII (https://www.law.cornell.edu/rules/frcp/), fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the complaint's title names all the parties. | `court-title()`, `caption()`, `cover()`: court name lines in the template, division and case number from the sample. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each paragraph is numbered by the template. The sample does not type paragraph numbers. |
| Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required for a paper served by filing it with the electronic-filing system. | No certificate is produced. |
| L.U.Civ.R. 11(a) | Signed papers carry counsel's name, address, telephone, fax, e-mail and bar number. | `signature-block()`: "By: /s/" line and the counsel lines from the sample's `signature.counsel`. |
| L.U.Civ.R. 5(a)(1) | A civil cover sheet (Form JS 44) must be filed with each original complaint. | Not produced here (a separate filing). |
| L.U.Civ.R. 7(c) | A non-governmental corporate party files a corporate disclosure statement as a separate pleading with its first pleading. | Not produced here (a separate filing). |

**What the local rules do not say.** The compilation's table of contents has no Rule 10 (its rules run 5, 5.2, 7, 11, 15, 16 …). A text search of the whole compilation for typeface, point size, double spacing and margins found only L.U.Civ.R. 7(b)(5), which governs memorandum briefs. The complaint template takes its layout from that rule (8½ × 11, double-spaced, at least 1-inch margins, a proportional serif at 12 pt) as a choice, not as a requirement. Any different layout for complaints would be a template change, and the choice is recorded here.

## Layout

- Court title (three lines, bold, centered): "IN THE UNITED STATES DISTRICT COURT / FOR THE NORTHERN DISTRICT OF MISSISSIPPI / <DIVISION> DIVISION".
- Caption: parties in the left column (names, designation, "v." between parties), a rule closing the column at right and bottom; the right column has "CIVIL ACTION NO.:" with the case number, and "JURY TRIAL DEMANDED" when `jury_demand` is set.
- Title of the pleading, centered bold caps.
- Body double-spaced (27.6 pt pitch at 12 pt, Word's double), first-line indent 0.5 in; numbered paragraphs with the number at the indent; headings centered bold caps (level 1) or centered bold (level 2); the lead-in paragraph is unnumbered.
- A paragraph that starts with "WHEREFORE" is unnumbered (the prayer's lead-in); the prayer is a numbered list (1., 2., …). Sub-items within a list item are separated by hard line breaks.
- Footnotes: a `[^key]` mark in a paragraph becomes a typst footnote, set at 11 pt.
- Signature block: "Dated:" at left, "Respectfully submitted," and the signing counsel at right. Jury demand: a "JURY DEMAND" heading and paragraph after the prayer, before the signature.
- Margins 1 inch; page number centered at the foot of each page. No line numbers and no footer title (no local rule requires them).

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1, centered caps), a `##` heading (centered bold), a list (`1.` items, which are the prayer), or a paragraph (numbered by the template).
- Do **not** type paragraph numbers in paragraphs: a line that begins "12. " is taken as a list item, not a numbered paragraph. (The first draft of this sample did this; the footnote and numbering were lost. Fixed in the sample.)
- Frontmatter: `division`, `case_number`, `title`, `caption.parties` (list of `{names, designation}`), `jury_demand` (true puts "JURY TRIAL DEMANDED" in the caption), `lead_in` (unnumbered), `jury_demand_text` (the jury demand paragraph), `date`, `signature` (`signer` and `counsel` lines).
- Footnotes: `[^key]` in the text and `[^key]: text` in its own chunk.

## Known gaps and open choices

1. **One exemplar.** Tier 2 is not yet judged against two or three filers. The search (CourtListener RECAP, `court=msnd`, complaints filed 2025-08 to 2026-07) also found *Fulmer v. EZ Auto, Inc.* (3:26-cv-00121, 11 pp), whose text layer stops after page 1, and *Smith v. Southern Bancorp Bank* (3:26-cv-00038, 15 pp), not downloaded further. See `usage/SOURCE.md`.
2. **Font.** The rule names no complaint typeface. The template kept EB Garamond until fb-595.68; it is now Times New Roman 12 pt, the house standard where no face is named (`docs/FONTS.md` rule 6), which is also the exemplar's face.
3. **Figures.** The exemplar's comparison figures (paragraphs 15 and 17) are noted in the sample, not reproduced. The overlay therefore pairs sample page 4 with exemplar page 11, a figure page with little text.
4. **Paragraph numbers.** The sample's numbers are the template's (1 to 40), which match the exemplar's numbering. The exhibits are not reproduced.
5. **Caption style.** The party column is closed by a rule at right and bottom, not the ")" column some filers use. Recorded as a layout choice; both styles appear in this district's filings.
6. **Overlay pairing.** The overlay pairs pages by shared words. A page with figures has few words, so its pairing is weak. The overlay is a diagnostic, not a score.
7. **Not produced:** civil cover sheet, corporate disclosure statement (L.U.Civ.R. 7(c)), summons, and the filing fee.
8. **Gates.** `tools/check.sh` and `tools/check-selftest.sh` need a court folder with `court.json` and `rules.md`; this doc-type folder does not have that shape, and the brief forbids touching `tools/`. The gates were not run. Render, overlay and the page review above are the checks for this doc type.

## Review of the rendered pages (`OUTPUT-complaint.typst.pdf`, 11 pages, the earlier EB Garamond render, before fb-595.68)

- Page 1: court title lines 1–3, caption with the party column closed by a rule and the right column (case number, jury demand), title centered, lead-in, paragraphs 1–5 on the double-spaced grid. Pass.
- Page 2: BACKGROUND and Haas' Intellectual Property headings, paragraphs 6–7 with footnote 1 at the foot of the page, "Defendant's Infringing Products" heading with paragraph 8. Pass.
- Page 3: paragraphs 8–14; no heading at a page foot. Pass.
- Page 4: paragraphs 14–19; the bracketed figure notes sit on the grid. Pass.
- Page 5: paragraphs 19–23. Pass.
- Page 6: paragraphs 24–26, COUNT I heading and its subhead, paragraphs 27–28. Pass.
- Page 7: paragraphs 28–33, COUNT II heading. Pass.
- Page 8: paragraphs 34–40, COUNT III heading; the page ends with paragraph 40. Pass.
- Page 9: PRAYER FOR RELIEF heading, WHEREFORE lead-in (unnumbered), prayer items 1 and 2 with sub-items a–c on separate lines. Pass.
- Page 10: prayer sub-item d, items 3–11. Pass.
- Page 11: JURY DEMAND heading and paragraph, date, "Respectfully submitted", the signature line and counsel block (Rule 11(a) details). Pass.

Layout defects found during review and fixed in the template (not in the sample): (a) a numbered paragraph's last line overlapped the next paragraph, because a paragraph inside a loop or an auto-height block loses its later lines; numbered paragraphs now use the CAND template's `on-grid` (measure, then round up to whole 24-pt rows); (b) headings came out at typst's default heading size, now 12 pt; (c) the case number wrapped inside its caption line, now on its own line below "CIVIL ACTION NO.:"; (d) footnote marks were left as literal text, now typst footnotes at 11 pt.

## Review limits

The page review checks the layout of the render. Text fidelity to the exemplar rests on the transcription and on the overlay's word pairing (70–90% on text pages). The filed page images were not compared pixel by pixel, and the figure pages (paragraphs 15 and 17) are noted, not reproduced.

## Engines

Two engines are built from the same sample: typst (primary, `typst/`) and docx (`docx/`). This doc type has no latex template yet.

**docx** (`docx/`): `docx/reference.xml` (`base="xengine"`: `fb render --engine docx` builds the reference document from it, the shared cross-engine recipe in the typst template's face) and the Lua filter `docx/msnd-complaint.lua` (pandoc, CommonMark reader). Render with `sh tools/render.sh --engine docx <this dir> usage/INPUT-complaint.md`; it writes `usage/OUTPUT-complaint.docx` and `usage/OUTPUT-complaint.docx.pdf` (LibreOffice 26.8.1; `SOFFICE` must point at `soffice`). Its 13 pages match the typst render's 13. The lists below were checked on the earlier EB Garamond build (`docx/make-reference.sh` and `docx/render.sh`, since retired into fb render), except the face, sizes and pitch, which are read from the current files.

What matches typst, checked on the LibreOffice PDF:

- Times New Roman only (`pdffonts`); body 12 pt; footnotes 11 pt.
- Body double-spaced at an exact 27.6 pt (24 pt before fb-595.68); first-line indent 0.5 in; letter paper with 1-inch margins; page number centered at the foot of each page.
- Court title, caption (party column closed by a rule at right and bottom), title, lead-in, numbered paragraphs 1–40 (numbered by the filter), prayer items 1–11 with sub-items a–d on their own lines, JURY DEMAND, and the signature block.

What differs:

- Pagination (earlier build): 12 pages against typst's 11. The single-spaced lines (caption, signature) are an exact 14 pt, close to typst but not identical, and a heading stays with its next paragraph, so page 1 ends after paragraph 2 with room for about three lines. No page break is forced.
- Numbered paragraphs: the text starts at a 0.9 in tab stop. Typst places it 0.3 in after the number, which is about 0.92 in for "1." and about 0.99 in for "10.".
- The title sits lower under the caption than in typst.

docx BLOCKED items:

- No check IDs: this doc type has no `rules.md` or `checks.yaml` (Known gaps, item 8), so `tools/check.sh --engine docx` has nothing to run here. The docx was reviewed by page, not by gate.
- Font (before fb-595.68): EB Garamond was vendored as OpenType CFF (`.otf`), which Word cannot embed; the docx is now Times New Roman. Not verified in Word.
- Word: the file was converted by LibreOffice without error but was not opened in Word, so the "no repair prompt" check is not done.

Review of the docx PDF (the earlier EB Garamond build, before fb-595.68): all 12 pages rendered at 60 dpi and viewed after the last change. Typst pages compared: 1 (caption), 9 (prayer) and 11 (signature).
