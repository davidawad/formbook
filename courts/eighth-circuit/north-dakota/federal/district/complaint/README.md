# D.N.D. (ndd): complaint

Doc type: **complaint** in the United States District Court for the District of North Dakota (`ndd`). Folder: `courts/eighth-circuit/north-dakota/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-ndd-complaint-bitcanary325cv00181.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-ndd-complaint-bitcanary.md`: the whole complaint (all 96 numbered paragraphs, counts I to VII, prayers, jury demand, signature) |
| render | ok: `usage/OUTPUT-ndd-complaint-bitcanary.typst.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh` exit 0) |
| overlay | ok: `usage/OVERLAY-bitcanary-complaint.pdf` and `OVERLAY-bitcanary-complaint.txt` |
| pages reviewed | 9 of 9 (fonts pass 2026-10-14: every page rendered at 50 dpi and viewed again after the font check) |
| depth | 9 rendered pages against a 10-page exemplar |

File names follow `tools/render.sh` and `tools/overlay.sh` defaults (`INPUT-`, `OUTPUT-`, `OVERLAY-`), not the `<id>.pdf` / `<id>-overlay.pdf` form in the brief, because `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf`.

## Governing rules

Primary source: D.N.D. Civil Rules (local rules), "Effective October 6, 2025", https://www.ndd.uscourts.gov/lci/local_rules.pdf (92 pages; read and the relevant rules quoted 2026-10-14). The court's own Civil Rule text governs the form. Federal rules: https://www.law.cornell.edu/rules/frcp/rule_10 (Rule 10(a), 10(b)), fetched 2026-10-14; the fetch returned a summary, so the wording is checked against the official text before a tier-1 claim is closed.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D.N.D. Civ. R. 5.1(B)(1) | Standard size (8½ × 11) paper; page numbers at the bottom of each page. | `page` (us-letter, numbering in the footer, centred). |
| D.N.D. Civ. R. 5.1(B)(2) | One side of the page; minimum one-inch margin; **12-point font or larger**; **double-spaced**, except the title of the case and quoted material may be single-spaced. | `margin = 1in`, `type-size = 12pt`, `body-leading = 1.35em` (24.0 pt baseline pitch, measured), `single-leading` for the caption and signature block. |
| D.N.D. Civ. R. 3.1(A) | A civil case is assigned to the division where the action arose or the defendant resides; "The plaintiff must designate the appropriate division in the caption of the complaint." | `division` frontmatter line; the template fails the build if it is missing (`assert`). The sample: "EASTERN DIVISION". |
| D.N.D. Civ. R. 5.1(B)(3) | Papers after the initial pleading (exhibits excepted) are in pleading format, each with the venue, case title and file number. | Not applied to the complaint (it is the initial pleading); the caption carries venue, title and case number. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `court-title`, `caption` ("Case No." and the title). |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers each body paragraph (1, 2, ...). Headings, the lead-in and WHEREFORE paragraphs are not numbered. |

Not produced by this template (separate filings, not part of the complaint, and not in the sample): the civil cover sheet (JS-44); the Corporate Disclosure Statement or certificate of non-applicability (D.N.D. Civ. R. 7.1.1, due within 14 days of the first filing); the summons. Any of these may be required with the first filing.

## Layout

- Court title (three centred bold lines: court, district, division), then the caption: party names with a column of ")" marks, and on the right the case number and the title in bold; "JURY DEMAND" under the title when the complaint demands a jury.
- Body text double-spaced, 12-point, one-inch margins on all sides, first-line indent 0.5 in, paragraphs numbered 1, 2, ... by the template.
- Caption, title and signature block single-spaced (the rule allows this for the case title).
- Headings: `#` centred bold caps (PARTIES, JURISDICTION AND VENUE, BACKGROUND, COUNT I); `##` centred bold sub-heading (the cause of action). Headings are sticky, so a heading never ends a page.
- Prayers (paragraphs starting WHEREFORE) are unnumbered, as in the exemplar.
- Signature block: frontmatter `signature.firm`, then `signature.lines`, indented to the right half of the page. A `date` line prints only when given (the exemplar has none).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `court`, `district`, `division`, `caption.parties` (list of `{names: [lines], designation}`; "v." is inserted between parties), `case_number` (blank prints a blank line), `title`, `jury_demand`, `lead_in` (unnumbered), `signature` (`firm`, `lines`), `date` (optional), optional `closing`.
- Body: blank-line-separated chunks. `#` / `##` / `###` headings; a `1.` list (lettered (a), (b), ...); a paragraph starting WHEREFORE (unnumbered); any other chunk is a numbered allegation. The sample does not type the numbers; the template numbers the allegations.
- Not supported: tables, footnotes, raw typst.

## Spacing (measured)

`pdftotext -bbox` on page 2 of the render: lines inside a paragraph are 24.0 pt apart (the baseline pitch), and paragraphs are 24.0 pt apart (each paragraph block carries `below: body-leading`; without it the gap between paragraphs was 7.8 pt). The caption and signature block are single-spaced at about 13.8 pt.

## Engines

| Engine | Status | What matches the typst form | What differs / BLOCKED |
|---|---|---|---|
| typst (primary) | as above | the reference | none |
| docx | `usage/OUTPUT-ndd-complaint-bitcanary.docx` and `.docx.pdf` (9 pages, LibreOffice 26.8.1 PDF, EB Garamond embedded per `pdffonts`) | Letter, 1 in margins, EB Garamond 12 pt, body and headings at 24 pt exact (double), caption as a borderless table with the ")" column, numbered allegations, lettered (a), (b) lists, centred PAGE number, signature block kept whole (one unsplittable table row). Checked by rendering all 9 pages to PNG at 60 dpi against the typst pages. | Paragraph flow is LibreOffice's, so page breaks differ from typst (for example, BACKGROUND starts on page 3 in docx, page 2 in typst). Word is not available here: the `.docx` was not opened in Word, so no Word repair-prompt check was run. No gate stamp: `tools/check.sh --engine docx` was not run, because this doc-type folder has no `checks.yaml` or `rules.md` and the gates cannot run here. |

`docx/reference.docx` is built by `docx/make-reference.sh` (pandoc's package, with styles, Letter page setup and footer replaced). The conversion is `docx/ndd-complaint.lua`, applied by `tools/render-docx.sh` with `SOFFICE` pointing at a LibreOffice that can see the vendored fonts (`FONTCONFIG_FILE` naming `fonts/` only). Commands: `sh tools/render.sh --engine docx <complaint-dir> usage/INPUT-ndd-complaint-bitcanary.md`.

## Known gaps and open choices

1. **One exemplar.** Tier 2 asks for two or three filers. The second filer was not collected: the RECAP search turned up Lipps v. City of Fargo (3:26-cv-00294, 35 pages, RECAP PDF found, not downloaded) and Hoefer v. Teigen (1:25-cv-00207, 244 pages, too long). Tier 2 is therefore **not** judged against two filers.
2. **Division line.** The exemplar's caption reads "EASTERN DISTRICT OF NORTH DAKOTA" with no division line. Civil Rule 3.1(A) requires the division to be designated in the complaint's caption, so the template prints "EASTERN DIVISION" from frontmatter. This departs from the exemplar on purpose (tier 1 over tier 2).
3. **Font.** Typeface check (fonts pass, 2026-10-14): face required = none. D.N.D. Civ. R. 5.1(B)(2) sets a size ("12-point font or larger"), not a typeface, and the rest of the local rules text (`local_rules.pdf`, effective October 6, 2025) names no face. Per `docs/FONTS.md` ("No face named" → EB Garamond), the template keeps EB Garamond at 12 pt; vendored substitute = none needed, font = `EB Garamond`. The filed exemplar is set in Times New Roman, which the rule does not require, and EB Garamond's x-height is smaller at 12 pt, so the text looks smaller than the exemplar. The Times-metric substitute, `Liberation Serif`, is vendored if a court rule ever names Times.
4. **Signature.** The exemplar has no "/s/" or "Respectfully submitted" line in its text layer; the template prints the firm and signer lines the exemplar shows, with no "/s/" and no date.
5. **Lines per page.** No line numbering or 28-line limit: D.N.D. Civ. R. 5.1 does not require pleading paper. This is a reading of the rule, not a choice of style; the exemplar is also unnumbered.
6. **Overlay pairing.** The overlay pairs our pages with the nearest exemplar pages by word overlap: ours p.1 ↔ p.1, p.2 ↔ p.2, p.3 ↔ p.4, p.4 ↔ p.5, p.5 ↔ p.6, p.6 ↔ p.7, p.7 ↔ p.8, p.8 ↔ p.9, p.9 ↔ p.10. The offsets follow the exemplar's own pagination, not an error in the render. The overlay is a diagnostic, not a score.
7. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief does not require them. Render and overlay were run; the page review below is the Gate 2 record for this doc type.

## Review of the rendered pages (9 of 9, 60 dpi, viewed after the last template change)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption with ")" column, case number and title, jury demand, lead-in, PARTIES, paragraphs 1-7, JURISDICTION AND VENUE | OK after two fixes: the three title lines were overlapping (now a stack with single spacing), and headings were larger than 12 pt (now set to the type size). |
| 2 | BACKGROUND, paragraphs 8-20 | OK. |
| 3 | Paragraphs 21-35 | OK. |
| 4 | COUNT I, paragraphs 36-42, WHEREFORE, COUNT II begins (43-45) | OK. Numbers match the filed numbering. |
| 5 | Paragraphs 46-59 | OK. |
| 6 | Paragraphs 60-72, WHEREFORE, COUNT III heading | OK. |
| 7 | Paragraphs 73-81, COUNT IV with the prayer in one paragraph, COUNT V heading | OK. |
| 8 | Paragraphs 82-92, WHEREFORE, COUNT VI | OK. |
| 9 | Paragraphs 93-96, WHEREFORE, COUNT VII, WHEREFORE, firm and signer block | OK. No heading at the foot of a page; signature block not split. |
