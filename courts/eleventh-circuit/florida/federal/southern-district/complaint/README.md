# flsd: complaint

Doc type: **complaint** in the United States District Court for the Southern District of Florida (`flsd`).
Folder: `courts/eleventh-circuit/florida/federal/southern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-castellanos-de-renteria-1-26-cv-27012-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-castellanos-complaint.md` (the full text of the exemplar's 7 text pages; exhibit slip pages 8 to 11 are scans and not transcribed) |
| render | ok: `samples/OUTPUT-castellanos-complaint.pdf`, 7 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh ... samples/INPUT-castellanos-complaint.md`) |
| overlay | ok: `samples/OVERLAY-castellanos-complaint.pdf` and `samples/OVERLAY-castellanos-complaint.txt` (`sh tools/overlay.sh ... castellanos-complaint`) |
| pages reviewed | 7 of 7 (every page rendered at 60 dpi and viewed on 2026-10-14, after the fonts-pass re-render; template unchanged) |

File names follow the tools: `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt`. The brief's `<id>.pdf` and `<id>-overlay.pdf` names are not what the tools produce, so the tools' names are used.

## Governing rules

Primary source: S.D. Fla. Local Rules, revised effective 1 December 2025, from https://www.flsd.uscourts.gov/sites/flsd/files/25-09-22%202025%20Local%20Rules%20effective%20120125%20-%20FINAL.pdf (fetched and read 2026-10-14; the text was read from the PDF, not from a secondary site).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| L.R. 5.1(a)(3) | Standard 8½ × 11 inch white, opaque paper. | `page-w`, `page-h`, `paper: "us-letter"`. |
| L.R. 5.1(a)(4) | 1 inch margins on top, bottom and each side. | `margin = 1in`. |
| L.R. 5.1(a)(4) | Not less than 1½ spaces between lines (quotations of 50 words or more and footnotes may be single-spaced). | `body-leading = 1.65em`: 27.6 pt pitch at 12 pt (double). The rule sets a floor of 1½; the exemplar is double-spaced, which the rule leaves open. Measured: `pdftotext -bbox`, body lines 27.6 pt apart. |
| L.R. 5.1(a)(4) | Fonts no smaller than 12 point, footnotes and quotations included. | `type-size = 12pt`. |
| L.R. 5.1(a)(4) (typeface) | No typeface is named. The rule text (read 2026-10-14) sets only the 12-point minimum, so no court-named face applies: face required = none. | `font-family = "EB Garamond"`, the "No face named" row of `docs/FONTS.md`. Visual only against the exemplar's Times New Roman; no metric-compatible substitute is needed. |
| L.R. 5.1(a)(4) | Paginated consecutively at the bottom center of each page. | `footer-page-number()`, bottom center, numbered from page 1. |
| L.R. 5.1(a)(5)(A) | Name of the court centered across the page. | `court-title()`, centered bold capitals. |
| L.R. 5.1(a)(5)(B) | Docket number, category (civil or criminal), and last names of the assigned District Judge and Magistrate Judge, centered across the page. | `CIVIL CASE NO. ` + `case_number`, centered. The judges' names are not in the sample (see Known gaps). |
| L.R. 5.1(a)(5)(C) | The style fills no more than the left side of the page, leaving room for the Clerk's stamp. | `style-block()`, 3.25 in wide (half the text width). |
| L.R. 5.1(a)(5)(D) | Title of the document, with the party's name and designation, centered. | `caption()`, title centered bold capitals. |
| L.R. 5.1(a)(6) | Signature block: name, street address, telephone, e-mail and Florida Bar number of each counsel. | `signature-block()`, `signature.lines` in the sample. |
| L.R. 3.3 | A civil cover sheet must accompany the complaint. | Not produced (a separate form). |
| Fed. R. Civ. P. 10(a) | Caption with court, title, file number and Rule 7(a) designation. | As L.R. 5.1(a)(5) above. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs. | Each body paragraph is numbered by the template (`body-chunks()`). The lead-in, the WHEREFORE paragraphs and the paragraph under DEMAND FOR JURY TRIAL are unnumbered, as in the exemplar. The numbers 1 to 45 match the cross-references in the filed text ("paragraphs 1 through 26"). |

Not produced by this template (separate papers): the civil cover sheet (L.R. 3.3); the summons; the disclosure statement and certificate of interested persons (no S.D. Fla. local rule for it was found in the rules text read; the judge's initial order may require one; not verified).

## Layout

- Court title (two lines, bold, centered) at the top of the first page, then the docket line, the style on the left, the title centered.
- Single-spaced caption and signature blocks; body text double-spaced; headings centered bold capitals (level 1) or centered bold (level 2, used for COUNT headings); level 3 bold, left.
- Footer: page number only, bottom center.
- No pleading paper: the CAND (`ninth-circuit/california/federal/northern-district`) template uses numbered-line pleading paper, which S.D. Fla. does not require. The S.D. Fla. structure is taken from L.R. 5.1(a).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `case_number` (the docket number as it appears in the caption, with judge initials when assigned), `caption.parties` (list of `{names, designation}`; "v." and the closing "/" are inserted), `title`, optional `division`, optional `lead_in` (an unnumbered paragraph before the first heading), `date`, `signature` (`signer`, `lines`: the bar number, e-mail, firm, address, telephone and "Counsel for ...").
- Body: `# HEADING` (level 1, centered bold capitals), `## heading` (level 2, centered bold), `### heading` (level 3, bold left). Paragraphs are numbered in order. A paragraph that starts with `WHEREFORE` is unnumbered. The paragraph under `# DEMAND FOR JURY TRIAL` is unnumbered.
- Not supported: tables, footnotes, raw typst. Lists are rendered without numbers.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one exemplar per doc type. The tier-2 rule (2 or 3 filers from different filers) is not met for this doc type. A second S.D. Fla. complaint from the same RECAP search is not collected.
2. **Judges' names in the caption (L.R. 5.1(a)(5)(B)).** The exemplar's caption has no judge names (complaints are captioned before a judge is assigned in the first filing). The sample has `CIVIL CASE NO. 1:26-cv-27012` only. A filed complaint that has a judge assigned should carry the judges' last names in `case_number` (as the S.D. Fla. motion exemplar does: `26-cv-25201-BLOOM/Elfenbein`). The template prints `case_number` exactly as given.
3. **Category word.** The rule requires a category (civil or criminal); the template prints `CIVIL CASE NO.`, which is the usual S.D. Fla. form. The exemplar prints `Case No.`; the rule is followed here.
4. **Caption layout.** The exemplar puts the case number in a right-hand column with a `|` column for the style. L.R. 5.1(a)(5)(B) requires the docket line to be centered across the page, so the template centers it. The style is on the left (L.R. 5.1(a)(5)(C)), closed with "/" as in the motion exemplar.
5. **Font.** L.R. 5.1(a)(4) names no typeface; only the 12-point minimum applies (checked against the rule text on 2026-10-14). EB Garamond stays, per `docs/FONTS.md`. EB Garamond at 12 pt has a smaller x-height than the exemplar's Times New Roman, so the text looks smaller. Switching to a Times-metric face (Liberation Serif) would remove the difference, but the rule does not ask for it: a choice for David, not a rule point.
6. **Exhibits.** Pages 8 to 11 of the exemplar are exhibit scans with no text layer. They are not transcribed or rendered.
7. **Paragraph spacing.** Double-spaced (27.6 pt), following the exemplar. The rule's 1½ floor is met.
8. **Overlay pairing.** The overlay pairs pages by text. Page 1 pairs with the exemplar's page 1 at 54% word overlap, because the caption layout differs. The overlay is a diagnostic, not a score.

## Review of the rendered pages (7 of 7)

Each page was rendered at 60 dpi and viewed on 2026-10-14, after the fonts-pass re-render (no template change).

- Page 1: court title, docket line centered, style on the left with "/", title centered, lead-in, heading PARTIES, paragraphs 1 and 2, with the same first-line indent as the rest. Footer page number. Pass.
- Page 2: JURISDICTION AND VENUE, paragraphs 3 and 4, FACTS, the subheading in bold, paragraphs 5 to 9. Pass.
- Page 3: paragraphs 10 to 20 on the grid, no overlaps. Pass.
- Page 4: paragraphs 21 to 26, COUNT I heading centered, paragraphs 27 to 30. Pass.
- Page 5: WHEREFORE (unnumbered, indented), COUNT II, paragraphs 31 to 37, COUNT III heading kept with paragraph 37. Pass.
- Page 6: paragraphs 38 to 45, WHEREFORE, DEMAND FOR JURY TRIAL heading, its unnumbered sentence. Pass.
- Page 7: date and signature block (single-spaced, on the right of the page, "By: /s/" and counsel lines). Pass. The signature block alone on page 7 matches the exemplar.

## Validation

- `sh tools/render.sh` exit 0, no typst warnings (warnings fail the build).
- `sh tools/overlay.sh` wrote the overlay and the page map.
- `sh tools/check.sh` and `tools/check-selftest.sh` were not run: they expect a court folder with `court.json` and `rules.md`, and this doc-type folder is not that shape. The brief forbids editing `tools/`. The pages were reviewed by eye as the Gate 2 equivalent.
