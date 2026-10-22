# okd (District of Oklahoma): complaint

Doc type: **complaint** in a United States District Court in Oklahoma (folder `district`, alias `okd`). The district is named by each sample's `court:` frontmatter, so the template carries no court name.
Folder: `courts/tenth-circuit/oklahoma/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (a portion of the 15-page filing; see below) |
| typeface | rule: LCvR7.1(d) names no face (13-point minimum and margins only; read from the rules PDF 2026-10-15). Substitute: none; Times New Roman 13 pt, the house standard (`docs/FONTS.md` rule 6; was EB Garamond), typst and docx alike. Fit: n/a (the rules name no face); see gap 3 |
| render | ok (re-rendered 2026-10-15, on the earlier EB Garamond template): `usage/OUTPUT-complaint.typst.pdf`, 10 pages (unchanged), typst 0.15.0, `pdffonts`: EB Garamond Regular and Bold only, embedded; no warnings |
| overlay | **fail**: not regenerated. `usage/` holds only `SOURCE.md` (the filed PDF named there is not in the repo), so `tools/overlay.sh` cannot run. `OVERLAY-pilf-ziriax-complaint.pdf` is absent and the `.txt` is from an earlier render, so it does not match the current OUTPUT |
| pages reviewed | 10 of 10 on the 2026-10-15 render (every page rasterized at 60 dpi and viewed; no layout change) |
| tools/check.sh, check-selftest.sh | not run: they expect a court folder with `court.json` and `rules.md`; this doc-type folder has neither shape (the brief forbids editing `tools/`) |

## Governing rules

Verified 2026-10-14.

| Rule | Requirement | Where it is in the template | Source |
|---|---|---|---|
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the complaint's title names all the parties. | `court`, `caption`, `brief_title`, `case_number`. | https://www.law.cornell.edu/rules/frcp/rule_10 |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each body paragraph is numbered by the template; headings, lists, quotations and the PRAYER/JURY sections are not. | same |
| Fed. R. Civ. P. 10(c) | A written instrument attached as an exhibit is part of the pleading. | Not a layout rule; exhibits are not produced. | same |
| W.D. Okla. LCvR3.1 | Counsel number each party separately in the caption of the initiating document, plaintiffs consecutively and defendants consecutively. A civil cover sheet (JS-44) must accompany the complaint. | Party rows in `caption`; the sample numbers nothing because the exemplar has one party per side. The cover sheet is not produced. | https://okwd.uscourts.gov/sites/okwd/files/LocalRules2026.pdf (local rules effective April 2026) |
| W.D. Okla. LCvR5.2(a) | Papers 8 1/2 by 11 inches, double-spaced if typewritten, clearly legible. | `page-w`, `page-h`, `pitch` = 27.5 pt (see below). | same |
| W.D. Okla. LCvR7.1(d) | 13-point type or larger, footnotes included; margins of at least one inch on the top, bottom and sides. | `type-size = 13pt`; `margin = 1in`; the footer page number is 13 pt. | same |

Not produced by this template (separate filings): the civil cover sheet (JS-44, LCvR3.1), the summons, the LLC disclosure statement (LCvR7.1.1), any notice of related cases (LCvR3.7), and the redaction of personal identifiers (Fed. R. Civ. P. 5.2), which the author must do.

## Layout

- Court name in bold capitals, centered, on the first lines; caption with a ")" column between the party names and the case information (`Case No.` at the top right; `JURY TRIAL DEMANDED` under it when `jury_demand` is true).
- Title in bold capitals, centered, below the caption.
- Body: double spacing, first-line indent, numbered paragraphs (Rule 10(b)) from 1; headings centered bold capitals (level 1), bold (level 2) and bold italic (level 3); a PRAYER or JURY heading turns numbering off for the paragraphs under it.
- Prayer items are numbered 1., 2., ...; quotations are indented and single-spaced.
- Signature block: `Dated:` on the left, the party line, the signer's `/s/` block and any further counsel on the right; footnote lines (for example a pro hac vice note) after them.
- Page furniture: no pleading paper (the exemplar has none); a centered page number in the bottom margin.

### Measured line pitch

The filed exemplar's double-spaced baseline pitch is 27.5 pt (measured on page 3 of the exemplar with `pdftotext -bbox`). The template uses the same pitch (`pitch = 27.5pt`, `body-leading = 1.46em`, with Liberation Serif's 0.655 em line box at 13 pt); the render measured 27.5 pt (on the earlier EB Garamond render) on every body line. LCvR5.2(a) says only "double-spaced", so the exemplar settles the number.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `court` (list of lines; uppercased by the template), `case_number`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties; each name line must fit the 3.6 in party column, and the template fails the build if one does not), `brief_title`, `jury_demand`, `lead_in` (unnumbered opening paragraph, optional), `date`, `signature` (`party` lines, `groups` each with `lines`, and an optional `note`).
- Body: blank-line-separated chunks. `# Heading` is a centered section; `## Heading` bold; `### Heading` bold italic. A chunk starting with `>` is an unnumbered quotation. A list is lettered by markdown (`1.`) and is not numbered as a paragraph. Any other chunk is one numbered paragraph.
- Do not type paragraph numbers in the text: the template numbers the allegations.
- Escape a markdown marker at the start of a paragraph that is not a list (for example `\*` in a line that must begin with an asterisk).
- Not supported: tables, raw typst.

## What the overlay shows

`tools/overlay.sh` pairs each rendered page with the filed page that shares the most words, and writes the red (ours), blue (filed) and black (both) overlay. The sample is a portion of the filing: our pages 1 to 7 pair with the filed pages 1 to 7 (the caption, the jurisdiction and parties paragraphs, and the background); pages 8 to 10 (the count, the prayer and the signature block) pair with filed pages 13 to 15. The page map is in `OVERLAY-pilf-ziriax-complaint.txt`. The overlay is a diagnostic, not a score.

File names: `tools/overlay.sh` and `tools/render.sh` write `OVERLAY-<id>.pdf`/`.txt` and `OUTPUT-<id>.pdf`, the convention the other courts use, not the `<id>-overlay.pdf` form the brief mentions.

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The search (CourtListener RECAP, `okwd`, complaints filed in 2026) found complaint entries with no stored PDF; the one stored complaint found is this one. The second search route (Justia, Clearinghouse) returned 403 to the fetch tool. Tier 2 is therefore **not** judged against two filers yet. A PI motion in the same district (Polston, 5:26-cv-02265-G) was downloaded and checked but is a motion, not a complaint, and was not saved.
2. **The "okd" folder.** CourtListener lists `okd` as not in use. The live Oklahoma federal courts are `okwd`, `oknd` and `oked`. The templates follow the Western District's local rules (the rules set the folder is built from), and the exemplar is from the Western District. If the folder should be a different district, the rules, the exemplar and the `court:` line change; the template does not. This is a question for David.
3. **Font.** LCvR7.1(d) sets a 13-point minimum and margins; it names no face (checked against the rules PDF, 2026-10-15). Under `docs/FONTS.md` rule 6 a court that names no face gets the house standard, so the template sets Times New Roman 13 pt (Liberation Serif fallback), the exemplar's face too; it was EB Garamond. The 13-point minimum is met.
4. **Signature block.** It sits with the prayer on page 10 in the final render. If a filer's prayer runs over a page, the signature can stand alone on the next page; the template does not keep the last prayer item with it.
5. **Paragraph numbers differ.** The sample numbers its allegations from 1 (the template numbers them). The filed numbers are not transcribed for paragraphs 31 to 55, which are not in the sample.
6. **Portion transcribed.** Pages 8 to 12 of the filing (paragraphs 31 to 55, and the heading of the second count) are not transcribed. The sample goes from filed paragraph 30 straight to filed paragraphs 56 to 59 (sample numbers 31 to 34), so its numbering and the filing's diverge after paragraph 30.
7. **Caption party names.** Party names are written in capitals and broken into rows by the sample (a row must fit the 3.6 in column; the build asserts it). This is a sample choice, not a rule.
8. **The "107. S. West Street" line** is transcribed as filed (the exemplar carries that typo).
9. **Left-aligned body.** Body text is left-aligned, not justified. The exemplar's justification could not be read from the text layer; not asserted.
10. **Counsel block.** W.D. Okla. filings in the exemplars do not put counsel in the upper left; the signature block carries the counsel. The template does not produce a top-left counsel block.

## Review of the rendered pages (final render, 10 pages)

- Page 1: court name, caption with ")" column and `Case No.`, title, lead-in, Jurisdiction and Venue paragraphs 1 to 3, the start of Parties. Pass.
- Page 2: Parties paragraphs 4 to 6. Pass.
- Page 3: Background, Oklahoma Law (7 to 10). Block quotation (the statute) indented and single-spaced. Pass.
- Page 4: paragraphs 11 to 16; The NVRA's Public Disclosure Provision heading. Pass.
- Page 5: paragraphs 17 to 20; the Defendant Is Denying heading kept with its paragraph. Pass.
- Page 6: paragraphs 21 to 25 and the block quotation from the Board's letter. Pass.
- Page 7: Count I heading, paragraphs 26 to 29. Pass.
- Page 8: paragraphs 30 to 32. Pass.
- Page 9: paragraphs 33 to 34, PRAYER FOR RELIEF heading (unnumbered WHEREFORE), prayer items 1 to 3. Pass.
- Page 10: prayer items 4 to 7; `Dated:` and the signature block with the footnote line. Pass.

Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder). Layout defects found in earlier renders and fixed: paragraphs overlapping each other and the headings (the paragraph was a fixed-height grid block with no trailing leading); the court name line set in italics; the lead-in overlapping the first heading; the signature standing alone on a page (fixed by moving the prayer; see gap 4).

## Engines

### docx (`docx/reference.docx`, `docx/okd-complaint.lua`, 2026-10-15)

- Matches the typst form: Letter, 1 in margins; Times New Roman 13 pt throughout (the typst face); double spacing as one exact 27.5 pt pitch with one blank pitch after each paragraph; 0.5 in first-line indent; centered bold capitals for level-1 headings, bold for level 2, bold italic for level 3; court name lines; caption as a borderless table with the ")" column; allegations numbered by the filter (Rule 10(b)), not by Word's list numbering; prayer items with the number at the margin and the text at 0.5 in; signature block with "Dated:" at left and the signer at 3.8 in; centered page number in the footer at 13 pt.
- Differs: the cover and signature are tables and the caption rows are single-spaced exact lines, so line positions can sit a few points off the typst grid (typst rounds each block to whole pitches; Word does not). The numbered paragraph gap is a tab stop at 1.0 in, not typst's 0.3 in after the number. The font is named (Times New Roman) but not embedded: Word substitutes a face if it is not installed.
- BLOCKED (not done):
  - `docx.pdf` (LibreOffice conversion, Gates 0 and 1): `soffice` is not installed on this box and cannot be installed here (no conda-forge package, no root).
  - Visual review of the docx pages: pages_reviewed=0 (needs the LibreOffice PDF).
  - Zip integrity step of `tools/render-docx.sh`: `unzip` is not installed, so the command exits 1 after writing `usage/OUTPUT-complaint.docx` (`unzip: not found`, then `... is not a valid zip`). The parts were checked instead with `ziptool` (17 parts) and `xmllint --noout`: all well formed.
  - Opening the .docx in Word or LibreOffice without a repair prompt: not done.
  - `tools/check.sh --engine docx`: not run (needs the `.docx.pdf`).
