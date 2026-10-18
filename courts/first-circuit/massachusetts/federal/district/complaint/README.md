# mad: complaint

Doc type: **complaint** in the United States District Court for the District of Massachusetts (`mad`).
Folder: `courts/first-circuit/massachusetts/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: the whole filing (97 numbered paragraphs, Counts I to VI, prayer A to Q, jury demand, signature). Transcribed from the text layer of the exemplar. |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 14 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh courts/first-circuit/massachusetts/federal/district/complaint usage/INPUT-complaint.md`) |
| overlay | ok: `usage/OVERLAY-door-systems-complaint.pdf` and `OVERLAY-door-systems-complaint.txt` (`sh tools/overlay.sh courts/first-circuit/massachusetts/federal/district/complaint door-systems-complaint`) |
| typeface | No face named by the court's rules: EB Garamond kept (`docs/FONTS.md`, "No face named"). Fonts pass 2026-10-14: re-rendered with vendored fonts only, `pdffonts` shows EB Garamond only, no warnings. |
| pages reviewed | 14 of 14 (fonts pass 2026-10-14: every page rendered at 60 dpi and viewed; earlier review at the last template change) |

File names follow the tools, not the brief's wording: `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` reads that name and writes `OVERLAY-<id>.pdf` / `.txt`, so the sample is `usage/<id>.md` with those outputs. The tools are shared and were not edited.

## Governing rules

| Rule | Requirement | Where in the template |
|---|---|---|
| D. Mass. L.R. 5.1(a)(1) | FRCP 10 and 11 apply to the form and signing of papers. The attorney's Board of Bar Overseers registration number is inscribed below the signature. | `signature()`: `(BBO# n)` under each attorney's name (MAD-SIG-001). |
| D. Mass. L.R. 5.1(a)(2) | Filings are 8½ × 11 inch printable format. Documents, except discovery, are double-spaced, except counsel identification, title of the case, footnotes, quotations and exhibits. Non-conforming papers, other than complaints and notices of appeal, are returned by the clerk. | `body-leading = 1.2em` (24 pt baseline pitch at 13 pt, MAD-FORM-001); single spacing for the caption, quotations and signature block. |
| D. Mass. L.R. 3.1 | The initial pleading is accompanied by the civil cover sheet (JS 44) and the local category sheet. | Not generated (separate filing). |
| D. Mass. L.R. 5.1(c) | A request for special action is noted on the first page, right of or beneath the caption, unless it is on the category sheet. | Not generated (the sample asks for no special action). |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `court-title()`, `caption()`: court name, title in the caption, `Civil Action No.` (MAD-CAP-001..003). |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers every paragraph from 1; headings, quotations, the prayer and the jury demand are not numbered. |
| Fed. R. Civ. P. 38(b) | Jury demand. | `jury_demand` frontmatter, rendered after the prayer. |
| Fed. R. Civ. P. 7.1 | Disclosure statement for a nongovernmental corporate party, filed with the first appearance. | Not generated (separate filing). |
| Typeface (none named) | D. Mass. L.R. 5.1 names no typeface or size. Judges' standing orders were not checked. | `font-family = "EB Garamond"` (MAD-FORM-002): the no-face case in `docs/FONTS.md`, not a substitute. |

Rule text: L.R. 3.1, 5.1 and 7.1 from the court's combined local rules PDF, effective November 1, 2019 (https://www.mad.uscourts.gov/general/pdf/LC/Combined%20Local%20Rules%2011-1-19.pdf), read on 2026-10-14. This is the latest consolidated copy the search found; the court's rules page was not reachable in this run (HTTP 404 and 403), so later amendments are not checked. Fed. R. Civ. P. 10(a), 10(b) and 5(d)(1)(B) were read on 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_10 and https://www.law.cornell.edu/rules/frcp/rule_5. Fed. R. Civ. P. 38 and 7.1 are cited from the rule text, not fetched in this run.

The local rules set no typeface, font size or margins for D. Mass. (L.R. 5.1 sets paper size and spacing only), so those are style choices, not rule requirements.

## Layout

- Court title, two bold lines, centered (`court-title()`).
- Caption: a party column with a rule on its right and bottom, and `Civil Action No.` with the title in bold to the right.
- Lead-in (unnumbered, from `lead_in`), then the numbered paragraphs, headings centered bold (level 1 capitals, level 2 bold).
- Quotations (`>`): unnumbered, single-spaced, indented 0.5 in each side.
- Prayer: a paragraph beginning WHEREFORE (unnumbered), then the items lettered A., B., ... with a hanging indent.
- Jury demand (bold, unnumbered), then the signature block at the right (party line, `/s/`, attorneys with BBO numbers and e-mail, firm), then `Dated:`.
- Footer: page number, centered.

## Markdown contract (for samples)

- YAML frontmatter, then the body. `case_number`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `title`, `lead_in` (optional), `jury_demand` (optional), `date`, `signature` (`party` lines, `signer`, `attorneys` as `{name, bbo, email}`, `firm` lines).
- Body: blank-line-separated chunks. `#` (centered caps), `##` (centered bold), `###` (bold, left) headings; a paragraph (numbered by the template); a `>` quotation (unnumbered); a list (lettered A., B., ...); a paragraph beginning WHEREFORE (unnumbered prayer lead).
- Not supported: tables (none needed), footnotes (none used in this filing), raw typst.
- The sample must not put numbers in the text: the template numbers the paragraphs. The numbering of the transcription matches the filed numbering (1 to 97), so the internal cross-references ("paragraphs 1 through 68") read the same as the filing.

## Overlay

`OVERLAY-door-systems-complaint.pdf`: red is our render, blue is the filed page, black is where they agree. Each sample page is paired with the exemplar page sharing the most words (`.txt`). Pairing: ours p.1 to filed p.1 (79%), p.2 to p.2 (64%), p.3 to p.4 (74%), p.4 to p.5 (60%), p.5 to p.7 (60%), p.6 to p.8 (76%), p.7 to p.9 (89%), p.8 to p.11 (49%), p.9 to p.12 (77%), p.10 to p.13 (88%), p.11 to p.14 (69%), p.12 to p.16 (59%), p.13 to p.17 (75%), p.14 to p.18 (64%). The pairing is by text, and the pages do not line up one to one: the filed exemplar uses about 23 lines per page and a larger apparent type, and this template packs more text per page. The overlay is a diagnostic, not a score.

## Review of the rendered pages (final state)

- Page 1: court title, caption (party column, civil action number, title), lead-in, NATURE OF THE ACTION, ¶¶ 1 to 4, JURISDICTION AND VENUE heading. No spill. Pass.
- Pages 2 to 13: numbered paragraphs at the margin with the number at 0.5 in, headings kept with their first paragraph, quotations after ¶ 35 and ¶ 39 single-spaced and indented, COUNT headings with their parenthetical on the page of their first paragraph. Pass.
- Pages 12 to 14: WHEREFORE, items A to N with the hanging indent (12 and 13), items O to Q on page 14 with no split item. Pass.
- Page 14: jury demand, signature block (party, /s/, two attorneys with BBO numbers and e-mail, firm), `Dated: September 9, 2026`. Pass.

Defects found in review and fixed (all in `mad-complaint.typ`):
- Paragraphs overlapped each other and the headings. Cause: a zero paragraph gap (`spacing: 0pt`) makes typst 0.15 stack EB Garamond paragraphs on top of each other; fixed with `para-gap = 0.65em`, and each numbered paragraph is a block.
- Lines were too tight to be double-spaced. Cause: leading 0.54em; fixed with 1.2em (24 pt pitch).
- The signature block and the firm lines were cramped. Fixed by opening single spacing to 0.45em.

## Known gaps and open choices

1. **Typeface.** The local rules name no face, so EB Garamond stays. The exemplar is in Times New Roman, which is the filer's choice, not a rule. If David wants the exemplar's look, the metric-compatible vendored substitute is Liberation Serif (`docs/FONTS.md`); switching it is a choice for David, not made here.
2. **Paragraph gap.** Paragraphs are separated by 0.65 em on top of the double spacing; the exemplar shows no visible gap. Tier-2 choice, recorded as ACCEPTED: the gap is what keeps the paragraphs apart under typst 0.15 (see the defect above).
3. **Caption.** The party column is closed by a rule (right and bottom) rather than the ")" column of the exemplar. Tier-2 convention choice, ACCEPTED (the CAND templates use the same closure).
4. **Justified text.** Body text is justified; the exemplar's justification could not be read from the text layer.
5. **Exemplars.** One filer saved (the Door Systems complaint). The second D. Mass. complaint checked (Clere v. Delta Air Lines, 1:26-cv-14437-ADB) is recorded in `usage/SOURCE.md`, not saved. Tier 2 is judged against one filer here, not the two or three EVAL-LOOP asks for.
6. **ECF header.** The court's ECF stamp ("Case 1:26-cv-14133-MJJ Document 1 Filed ...") is added by the court's system and is not reproduced.
7. **Exhibits.** The sample refers to Exhibits A and B; the exhibits themselves are not part of the template.
8. **Rules currency.** The local rules are the 2019 consolidated copy (see above); amendments after that date are not checked.
9. **Not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and a `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.
10. **Length.** The sample is the whole 18-page filing; the render is 14 pages, inside the 8 to 14 page target of the brief.

[Formbook index](../../../../../../README.md) | [District Court, D. Mass.](../README.md)

## Engines

docx (`docx/`): `build-reference.sh` builds `reference.docx` (EB Garamond only, 13 pt, 1 in margins, US Letter, page number in the footer). `complaint.lua` builds the caption (a two-cell table with the party rule), the title and the signature block as Word paragraphs in named styles, the prayer letters (A to Q) and the jury demand. `render.sh` runs pandoc and adds the Word numbering for the allegations (pandoc drops numbering it does not write). Checked on the LibreOffice PDF `usage/OUTPUT-complaint.docx.pdf` (every page viewed at 60 dpi, against the typst render). Word was not checked; the `.docx` was opened with LibreOffice only.

Matches the typst form: EB Garamond only (no fallback face); body lines at a 24 pt pitch; headings at the typst sizes (18 pt level 1, 15.5 pt level 2, bold caps); single lines at 14.3 pt; numbered paragraphs at 0.5 in with the text after the number; prayer letters hanging; jury demand and signature block kept together; footer page number centered at 12 pt. Justified text is hyphenated (`autoHyphenation`), as typst hyphenates. Like the typst render, no space is added between paragraphs or around headings.

Differs: LibreOffice sets the body on 15 pages, typst on 14 (the last page holds only the jury demand and the signature block). The line pitch and the lines per full page match; the extra page builds up over the body (line breaks, hyphenation and the caption and prayer spacing are LibreOffice's, not typst's). Not closed: the cause was not isolated.

BLOCKED: page count (tier 1): docx 15 pages (LibreOffice) vs typst 14; the typst form is not reproduced page for page. A Word render may differ again.
