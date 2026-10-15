# gud (District Court of Guam): complaint

Doc type: **complaint** in the United States District Court of Guam (`gud`).
Folder: `courts/ninth-circuit/guam/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-capfa-25-cv-00020-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-capfa-complaint.md` (full transcription of the 10-page complaint, from the OCR text layer, obvious OCR errors corrected) |
| render | ok: `samples/OUTPUT-capfa-complaint.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh`) |
| overlay | ok: `samples/OVERLAY-capfa-complaint.pdf` and `samples/OVERLAY-capfa-complaint.txt` (`sh tools/overlay.sh`) |
| typeface | face required: none (GNLR 5.1(a), 2022: no typeface or point size). Substitute: n/a; EB Garamond kept, the default when a court names no face (`docs/FONTS.md`). Visual only: EB Garamond is the template's own face, not a court-named one. |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed; page 9 viewed again after the signature-column change; all 9 viewed again on 2026-10-15 for the fonts pass, no change) |

Tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (the names in `tools/`); the brief's `<id>.pdf` and `<id>-overlay.pdf` names are not what the tools write, so the tool names are used.

## Governing rules

Primary source: **General Local Rules of Practice for the District Court of Guam, effective April 19, 2022 ("GNLR")**, https://www.gud.uscourts.gov/sites/gud/files/General%20Local%20Rules%2020220419%20final_0.pdf, fetched and read 2026-10-14. This is the newest version found on the court's site in the search; it is not confirmed as current, and the court's site should be checked before the template is called final.

Federal rules, text from the Legal Information Institute mirror, fetched 2026-10-14: FRCP 5(d)(1)(B) https://www.law.cornell.edu/rules/frcp/rule_5, FRCP 8 https://www.law.cornell.edu/rules/frcp/rule_8, FRCP 10 https://www.law.cornell.edu/rules/frcp/rule_10.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| GNLR 5.1(a) | White opaque paper, 8 1/2 x 11 in.; all papers double-spaced except counsel identification, title of the case, footnotes, quotations and exhibits; all pages numbered consecutively at the bottom. | `page-w`, `page-h`; `body-leading` (24 pt pitch); page number centred in the footer. |
| GNLR 5.1(b) | Court title centred, commencing not less than three inches from the top of the page. | `counsel-block`: a box from the top margin to 3 in.; a longer counsel block pushes the court title down (one half pitch of clearance), never up. |
| GNLR 5.1(c)(1) | Counsel name, address and telephone at the upper left; space right of centre reserved for the clerk's filing stamp. | `counsel-w` = 3.25 in. (the page centre is 4.25 in. from the left edge); caption right column starts at 4.5 in. |
| GNLR 5.1(c)(2) | Title of the action below and to the left of the court title; a complaint names all parties. | `caption-left`: all parties, `between` word ("vs.") from the sample. |
| GNLR 5.1(c)(3) | Right of the title of the action: file number, civil designation, brief description of the document. | `caption-right`: `case_number`, `designation` ("CIVIL"), `brief_title`, optional `brief_subtitle`. |
| GNLR 5.1(c)(4) | Cover sheets accompany documents initiating civil actions. | Not produced (separate form; see Known gaps). |
| FRCP 10(a) | Caption: court name, title, file number, Rule 7(a) designation. | `court_title`, `caption`. |
| FRCP 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: every body paragraph is numbered 1, 2, ... by the template; headings, lists and `<!-- unnumbered -->` paragraphs are not. |
| FRCP 8(a), 8(d)(1) | Short and plain statement of jurisdiction, claim and demand; each allegation simple, concise and direct. | Content (the author's), not checked by the template. |
| FRCP 5(d)(1)(B) | No certificate of service is required for a paper served through the court's e-filing system. | Not generated (the complaint has none; the motion sample does). |

No rule in the 2022 GNLR sets a typeface, a point size, a margin, or a page limit. The typeface, the 1 in. margins and the 12 pt size are conventions from the exemplar and are recorded as such below.

## Layout

- Counsel block in the upper left, single-spaced, left of centre; court title centred and bold at 3 in.; caption as a two-column block (parties left, file number and title right); the body starts on the same page.
- Body double-spaced (24 pt pitch, measured on the PDF: every body line is 24.0 pt from the previous one), first-line indent 0.5 in., numbered paragraphs.
- Headings: level 1 centred bold capitals (roman numerals are typed in the sample); level 2 bold, left. A heading is kept with the paragraph after it.
- Prayer items (a markdown list) are lettered (a), (b), ... and may break across pages.
- Signature: "Respectfully submitted this ... day of ..." then the firm, "/s/" signer and the signer's lines, in a single-spaced block starting 3 in. from the left margin.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number`, `designation`, `court_title` (list of lines), `caption` (`between`, `parties` as `{names: [...], designation}`), `brief_title`, optional `brief_subtitle`, `counsel` (list of single-spaced lines), optional `lead_in` (unnumbered first paragraph, e.g. "COMES NOW..."), `date`, `signature` (`firm`, `signer`, `lines`).
- Body: `# I. HEADING` (level 1), `## A. Heading` (level 2); a blank-line-separated paragraph is one numbered paragraph; a markdown list is lettered; a paragraph starting with `<!-- unnumbered -->` is not numbered (WHEREFORE, the jury demand).
- Not supported: tables, footnotes, raw typst, italics are supported as `*...*`.

## Known gaps and open choices

1. **One exemplar, one filer.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers; this is not met. A second D. Guam complaint with a text layer was found and not saved: *Jane Doe v. Guam Visitors Bureau*, 1:26-cv-00017, Doc. 1 (Razzano Walsh & Torres, 28 pages; RECAP `gov.uscourts.gud.19220.1.0.pdf`). Saving it as `exemplars/FILED-EXAMPLE-doe-26-cv-00017-complaint.pdf` is the next step before tier 2 can be judged. Also seen and not used: *United States v. Jeida Guam*, 1:26-cv-00028, Doc. 1 (USAO, 6 pages, text; a government collection complaint, a different kind of filer) and *Ishizuka v. United States*, 1:26-cv-00033, Doc. 1 (a scan with no text layer; not used).
2. **Typeface.** No court-named face. GNLR 5.1 (2022, text read with `pdftotext` on 2026-10-15) sets no typeface or point size, so the template keeps EB Garamond, the face `docs/FONTS.md` gives a court that names none. The exemplar is set in Times New Roman, and EB Garamond at 12 pt has a smaller x-height, so the text looks smaller than the exemplar. Whether the clerk expects Times is a convention question for David, not a rule; it is the open tier-2 item.
3. **Margins.** 1 in. on every side; the GNLR sets no margin. Convention, not measured off the exemplar.
4. **Pleading-paper line numbers.** The exemplar (CaPFA) uses numbered lines 1 to 28 down the left margin, with rules. GNLR 5.1 does not require them, so this template does not number lines. Recorded as ACCEPTED.
5. **Caption.** No column of ")" marks and no rules; the exemplar has none either. ACCEPTED.
6. **Transcription.** The exemplar's text layer is OCR, with misreadings corrected in the sample (for example "Keimedy", "pajmient", "diversityjurisdiction", "impaid"). Two places in the exemplar could not be read from the OCR: the item "d." in the list under paragraph 20 is missing from the text layer, so the sample has eight items, which the template letters (a) to (h); the filing's letters after "c." are therefore one off. And the filed paragraph numbers restart at 1 in Part II, so the filed numbering after Part II is two lower than the template's (the template numbers continuously: 81 paragraphs; the filing shows 79).
7. **Footer.** Page number only. GNLR 5.1(a) requires numbering; no footer title or case number is required (the CAND template has them). The exemplar's bottom line is the ECF header, not a footer, so it is not a page-number convention to copy. Not asserted.
8. **Justification.** Left-aligned (ragged right); the exemplar's justification could not be read from the text layer.
9. **Cover sheet and other filings.** The civil cover sheet (JS-44), the Rule 7.1 disclosure statement, the summons and any certification required with the first filing are separate documents and are not produced here.
10. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court directory with `court.json` and `rules.md`; this doc-type folder does not have that shape, and the brief forbids editing `tools/`. Render, overlay and the page review below are the checks run here. No check stamp is written.
11. **Line pitch and clearance** are measured on the PDF (`pdftotext -bbox-layout`): counsel lines at 13.8 pt, body at 24.0 pt, court title box at 216 pt (3.00 in.).

## Review of the rendered pages (Gate 2 equivalent)

Rendered at 60 dpi, every page viewed, after the last template change:

- Page 1: counsel top left (lines 1 to 5, single-spaced); court title centred bold at 3 in.; caption with the parties left and "Civil Case No. 25-00020 / CIVIL / COMPLAINT AND DEMAND FOR JURY TRIAL" right of centre; paragraphs 1 to 3 double-spaced; page number at the bottom. **Pass.**
- Page 2: heading III; paragraphs 4 to 15, numbered, no heading at the foot of the page. **Pass.**
- Page 3: paragraphs 16 to 24, the lettered list (a) to (h) on its own lines. **Pass.**
- Page 4: paragraphs 25 to 38. **Pass.**
- Page 5: paragraphs 39 to 49; heading IV and A. kept with their paragraphs. **Pass.**
- Page 6: paragraphs 50 to 62; the two-line B. heading is kept with paragraph 61. **Pass.**
- Page 7: paragraphs 63 to 74. **Pass.**
- Page 8: paragraphs 75 to 81; heading C; heading V; prayer item (a) starts at the foot of the page. **Pass.**
- Page 9: prayer items (b) to (f), heading VI, the unnumbered jury demand, the signature block (firm name on one line after the widening). **Pass.**

Tier 2 is **not** judged (one filer only; see gap 1). OPEN items for tier 2: the second exemplar (gap 1), the typeface (gap 2), the footer (gap 7).

## Engines

### docx (pandoc; `docx/`)

Built by `docx/make-reference.sh` (writes `docx/reference.docx`, run once and committed) and `docx/gud.lua` (cover, caption, numbered paragraphs, lettered items, addresses, signature blocks; body text and headings stay pandoc's). `sh tools/render.sh --engine docx` writes `samples/OUTPUT-capfa-complaint.docx`.

Set in `styles.xml` and `sectPr`, **not rendered** (no LibreOffice on the build box, so no page of the docx has been looked at):

- EB Garamond 12 pt, black, in every style; exact 24 pt line pitch (double); 16.2 pt after each body paragraph (the typst `body-leading` gap).
- Body text: 0.5 in first-line indent. Headings: bold; level 1 centred; 24 pt above; kept with the next paragraph.
- Counsel, caption, addresses and signature: custom style `GudSingle`, exact 13.8 pt. Lettered items: style `GudList`, text at 0.9 in with the label at 0.5 in.
- Footnotes: single spaced, 12 pt.
- US Letter; 1 in margins; centred PAGE field in the footer.
- Court title: 3 in from the top edge, from the counsel line count (one line each).

Differences from typst (judged in the XML only):

- The caption is a borderless three-column table (3.25 in, 0.25 in gutter, 3.0 in), not a grid; the party indents match the typst sample.
- Numbered paragraphs are "N." then a tab (text at 1 in); typst's own numbering layout is not reproduced.
- The court-title position counts counsel paragraphs, not wrapped lines; a counsel line that wraps in Word moves the title lower than 3 in (allowed by GNLR 5.1(b), but not the typst position).
- Pagination, widow control and the footer position are Word's and not checked.

BLOCKED (docx engine):

- `docx.pdf` gates 0 to 3: BLOCKED, `soffice` (LibreOffice) is not installed on the build box, so `tools/render-docx.sh` stops after writing the `.docx` and no `.docx.pdf` exists.
- docx visual review: pages reviewed = 0. The typst output was rendered and viewed as the reference only.
- Word repair prompt: not checked (no Word). The `.docx` is a valid zip and every XML part is well-formed (`unzip -tq`, `xmllint --noout`).
- TOC, TOA, cross-references: none in this doc type. Line numbering: not required by GNLR 5.1.
