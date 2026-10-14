# flsd: motion-brief

Doc type: **motion to dismiss with incorporated memorandum** (Fed. R. Civ. P. 12(b)(6)) in the United States District Court for the Southern District of Florida (`flsd`).
Folder: `courts/eleventh-circuit/florida/federal/southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-slack-midland-1-26-cv-25201-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-slack-motion-brief.md` (the exemplar's full text: 10 pages of motion and memorandum, the signature block and the certificate of service) |
| render | ok: `samples/OUTPUT-slack-motion-brief.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh ... samples/INPUT-slack-motion-brief.md`) |
| overlay | ok: `samples/OVERLAY-slack-motion-brief.pdf` and `samples/OVERLAY-slack-motion-brief.txt` (`sh tools/overlay.sh ... slack-motion-brief`) |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi and viewed on 2026-10-14, after the fonts-pass re-render; template unchanged) |

File names follow the tools: `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt`.

## Governing rules

Primary source: S.D. Fla. Local Rules, revised effective 1 December 2025, from https://www.flsd.uscourts.gov/sites/flsd/files/25-09-22%202025%20Local%20Rules%20effective%20120125%20-%20FINAL.pdf (fetched and read 2026-10-14).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| L.R. 5.1(a)(3) | Standard 8½ × 11 inch white, opaque paper. | `paper: "us-letter"`. |
| L.R. 5.1(a)(4) | 1 inch margins on top, bottom and each side. | `margin = 1in`. |
| L.R. 5.1(a)(4) | Not less than 1½ spaces between lines (quotations of 50 words or more and footnotes may be single-spaced). | `body-leading = 1.65em`: 27.6 pt pitch at 12 pt (double, following the exemplar). Footnotes are single-spaced (`single-leading`). |
| L.R. 5.1(a)(4) | Fonts no smaller than 12 point, footnotes and quotations included. | `type-size = 12pt`; footnote entries set to `type-size`. |
| L.R. 5.1(a)(4) (typeface) | No typeface is named. The rule text (read 2026-10-14) sets only the 12-point minimum, so no court-named face applies: face required = none. | `font-family = "EB Garamond"`, the "No face named" row of `docs/FONTS.md`. Visual only against the exemplar's Times New Roman; no metric-compatible substitute is needed. |
| L.R. 5.1(a)(4) | Paginated consecutively at the bottom center of each page. | `footer-page-number()`. |
| L.R. 5.1(a)(5)(A)–(D) | Court name, docket line with the judges' last names, the style on the left, the title, all as in the complaint README. | `court-title()`, `caption()`, `style-block()`. The docket line (`case_number`) carries the judges' names: `26-cv-25201-BLOOM/Elfenbein`. |
| L.R. 5.1(a)(6) | Signature block: name, street address, telephone, e-mail and bar number of each counsel. | `signature-block()`. |
| L.R. 5.2 | Certificate of service when service is not through CM/ECF, identifying the persons served, their relationship, address, telephone, e-mail, the date and the method. | `certificate-of-service()`, from `service` in the frontmatter. Used here because the exemplar has one; the CM/ECF wording is the exemplar's. |
| L.R. 7.1(a)(1) | A motion shall incorporate a memorandum of law citing supporting authorities. | The sample is one document: motion, Preliminary Statement, Standard of Review, Argument, Conclusion. |
| L.R. 7.1(a)(3) | A conferral certificate is required before most motions, but not before a motion to dismiss for failure to state a claim. | No conferral certificate is generated, and none is in the exemplar. Consistent with the exemption. A motion that is not a 12(b)(6) motion would need one. |
| L.R. 7.1(c)(2) | A motion and its incorporated memorandum may not exceed 20 pages without leave. The title page, tables, signature pages and certificates of service do not count if no substantive text is on the same page. | Render: 10 pages of motion and memorandum (pages 1 to 10); the signature block (page 11) and the certificate of service (page 12) do not count. Within the limit. |
| Fed. R. Civ. P. 7(b), 12(b)(6) | The motion states the grounds and the relief sought; failure to state a claim. | The motion paragraph and the WHEREFORE paragraph. FRCP text not separately fetched this session. |

## Layout

- Court title at the top of the first page; docket line centered; style on the left with "/"; title centered bold capitals.
- Body paragraphs double-spaced, first-line indent 0.5 in, unnumbered (a motion is not a pleading).
- Headings: level 1 centered bold capitals (PRELIMINARY STATEMENT, STANDARD OF REVIEW, ARGUMENT, CONCLUSION); level 2 bold, left (I., II.); level 3 bold, left, indented (a., b.). The numbers are typed in the sample. Headings are sticky, so a heading never ends a page.
- Footnotes: 12 point, single-spaced, numbered by typst. cmarker 0.1.10 does not convert markdown footnotes, so the template collects `[^key]: text` definitions and turns each `[^key]` reference into a typst footnote.
- Signature block single-spaced on the right of the page; certificate of service after it, with the service list.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `case_number` (the docket line as it appears in the caption, with judge initials), `caption.parties`, `division` (optional), `title`, `date` (printed "Dated: ..."), `signature` (`signer`, `lines`), `service` (optional: `date`, `signer`, `list` of lines for the service list).
- Body: `# HEADING` (level 1), `## heading` (level 2), `### heading` (level 3). Paragraphs are unnumbered. Footnotes: `text[^1]` and `[^1]: One paragraph of footnote text.` anywhere in the body.
- Case names are roman in the sample (the exemplar's text layer has no italics). The template italicizes `*...*` if a sample uses it.
- Not supported: tables, raw typst.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one exemplar per doc type. The tier-2 rule (2 or 3 filers from different filers) is not met for this doc type.
2. **Font.** L.R. 5.1(a)(4) names no typeface (checked 2026-10-14), so EB Garamond stays, per `docs/FONTS.md`, at 12 pt. The exemplar's Times New Roman looks larger; a Times-metric face would be a choice for David, not a rule point.
3. **Case names not italic.** The exemplar text layer has no italics, so the sample has roman case names. Bluebook italics would be a tier-2 presentation choice, not a rule requirement.
4. **Page 3 gap.** The ARGUMENT heading, point I and sub-point a are kept with the first paragraph of text, so page 3 ends a third of a page early. This is the "heading never ends a page" rule, not an error; the exemplar breaks differently.
5. **Overlay pairing.** Pages are paired by text: sample page 5 pairs with exemplar page 4, and sample page 12 (the certificate) with exemplar page 11, because the sample's page breaks differ. The overlay is a diagnostic, not a score.
6. **Proposed order.** L.R. 7.1(a)(2) requires a proposed order for the motions listed in 7.1(a)(1) and for emergency relief. A motion to dismiss is not one of them; no proposed order is generated.
7. **Judges' names in the caption.** Present here (`26-cv-25201-BLOOM/Elfenbein`), following the exemplar and L.R. 5.1(a)(5)(B).

## Review of the rendered pages (12 of 12)

Each page was rendered at 60 dpi and viewed on 2026-10-14, after the fonts-pass re-render (no template change).

- Page 1: court title, division, docket line, style with "/", title in bold capitals, the opening paragraph, heading PRELIMINARY STATEMENT. Footer page number. Pass.
- Page 2: the rest of the Preliminary Statement; STANDARD OF REVIEW; footnote 1 at the foot of the page, 12 point. Pass.
- Page 3: the rest of Standard of Review; ARGUMENT, I. and sub-point a. kept together, and the page ends after Standard of Review (the gap is the sticky-heading behavior). Pass with the gap noted.
- Page 4: ARGUMENT, point I and sub-point a. headings, then the text of sub-point a. (Twombly and Iqbal citations, all roman). Pass.
- Page 5: sub-point a. end; sub-point b. heading (two lines), its first paragraph. Pass.
- Page 6: sub-point b. text, with "*Id.*" and the citations as typed. Pass.
- Page 7: the end of sub-point b.; heading II. and sub-point a. Pass.
- Page 8: sub-point a. text, citations, the "demonstrate[]" bracket as in the exemplar. Pass.
- Page 9: sub-point a. text; footnote 2 at the foot of the page, 12 point. Pass.
- Page 10: the last of the argument; CONCLUSION; WHEREFORE (unnumbered, indented). Body ends here (10 pages). Pass.
- Page 11: date line and the signature block (single-spaced, "By: s/ Cory W. Eichhorn", bar numbers, e-mail, firm, address, telephone, fax, "Counsel for Midland Credit Management, Inc."). Pass.
- Page 12: CERTIFICATE OF SERVICE (the CM/ECF wording, date and signer), the service list with the plaintiff's counsel. Pass.

## Validation

- `sh tools/render.sh` exit 0, no typst warnings.
- `sh tools/overlay.sh` wrote the overlay and the page map.
- `sh tools/check.sh` and `tools/check-selftest.sh` were not run for the same reason as the complaint README.
