# okwd: motion-brief

Doc type: **motion to dismiss with brief in support** (Fed. R. Civ. P. 12(b)(6)) in the United States District Court for the Western District of Oklahoma (`okwd`). The motion and brief are one document, titled as one (LCvR7.1(k)).
Folder: `courts/tenth-circuit/oklahoma/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-trupia-5-26-cv-02422-motion-brief.pdf` (one filer, a defendant's municipal counsel; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-trupia-motion-brief.md`: the whole motion and brief, caption, signature and certificate of mailing |
| render | ok: `samples/OUTPUT-trupia-motion-brief.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh`) |
| overlay | ok: `samples/OVERLAY-trupia-motion-brief.pdf` and `OVERLAY-trupia-motion-brief.txt` (`sh tools/overlay.sh`) |
| pages reviewed | 8 of 8, every page rasterized at 60 dpi and viewed after the last template change (pages 2 to 4 re-checked after the indent fix) |

File names follow the house convention that `tools/render.sh` and `tools/overlay.sh` read and write: the brief's `samples/<id>.md` is `samples/INPUT-<id>.md`, its `<id>.pdf` is `OUTPUT-<id>.pdf`, and its `<id>-overlay.pdf` / `.txt` are `OVERLAY-<id>.pdf` / `.txt`.

## Governing rules

Primary sources. Local rules: the W.D. Okla. Local Civil Rules as posted at
https://okwd.uscourts.gov/local-rules (current edition `LocalRules2026.pdf`, effective April 2026, read by text extraction on 2026-10-14; the court posts a red-lined set of 2026 proposed amendments with no effective date, not reflected here). Federal rules: Fed. R. Civ. P. 5, 7, 8, 10, 11 and 12 from https://www.law.cornell.edu/rules/frcp/ , fetched 2026-10-14 (the wording quoted in this README was read in those texts: Rules 5(b)(2)(C), 7(b)(1), 8(a), 10(a), 11(a), 12(b)).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCvR7.1(b) | Each motion and brief clearly titled to identify on whose behalf it is presented. | `brief_title` (in the sample: "DEFENDANT CITY OF OKLAHOMA CITY'S MOTION TO DISMISS AND BRIEF IN SUPPORT"). |
| LCvR7.1(c) | Each motion a separate document (a combined motion and brief is allowed by (k)). | Not a template matter; the sample is one motion. |
| LCvR7.1(d) | Print style, footnotes included, not less than **13-point**; margins at least one inch top, bottom and sides. | `type-size = 13pt`; `margin = 1in`. The footer page number is 13 pt. |
| LCvR7.1(e) | Opening brief not over 25 pages (30 for summary judgment); cover, table of contents, table of authorities, signature block, certificate of service and exhibits not counted; a brief over 15 pages needs an indexed table of contents and table of authorities. | Page limit is a content matter, the sample is 8 pages. **The template does not generate a table of contents or table of authorities** (see known gaps). |
| LCvR7.1(k) | A motion and brief in support may be one document if so identified in the title. | `brief_title` names both. |
| LCvR5.2(a) | Papers double-spaced if typewritten; 8 1/2 by 11 inch paper; one side. | `body-leading = 1.35em` (2.0em pitch, about 26 pt at 13 pt); `page-w`, `page-h`. |
| LCvR5.4 | "All papers shall contain the name, mailing address, daytime telephone number, fax number, and e-mail address" of the attorney. | `signature.lines`. The exemplar's block has e-mail and telephone but no fax line; the sample reproduces it as filed, and the template prints what the frontmatter gives. **Gap:** LCvR5.4 asks for a fax number; this exemplar omits one (see known gaps). |
| LCvR3.1 / caption | Parties numbered in the caption where the filing is an initiating document; the caption carries the case number and any jury demand. | `caption.parties`, `case_number` (for a filed motion, the case number with the judge's suffix, as the exemplar has it), `jury_demand`. |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, file number and Rule 7(a) designation. | Court title lines, `caption`, `case_number`, `brief_title`. |
| Fed. R. Civ. P. 7(b)(1) | A request for a court order must be made by motion, state with particularity the grounds for seeking the order, and state the relief sought. | Content only: the template does not check the wording. |
| Fed. R. Civ. P. 12(b)(6) | Defense of failure to state a claim may be asserted by motion. | Content only (the lead paragraph names the rule). |
| Fed. R. Civ. P. 11(a) | Every paper signed by at least one attorney of record, with the signer's address, e-mail address and telephone. | `signature.sign` ("/s/ name") and `signature.lines`. |
| Fed. R. Civ. P. 5(b)(2)(C) | Service by mail to a person without ECF access is complete on mailing. | `certificate` (title, statement, recipients, signer): the certificate of mailing block at the end. |

## Layout

- Plain double-spaced pages, no pleading line numbers (as in the exemplar; W.D. Okla. does not use numbered pleading paper).
- Court title on two lines, bold; the caption single-spaced: party names, a ")" column, the case number and "JURY TRIAL DEMANDED" at the right. Title of the paper bold, centered, below the caption.
- Body: first-line indent 0.5 inch. Paragraphs are not auto-numbered: where the filed brief numbers its statement of the case, the sample types the number in the text (escaped as `1\.`), so the numbers are exactly those filed.
- Headings: level 1 bold centered capitals (STATEMENT OF THE CASE, ARGUMENT AND AUTHORITY, CONCLUSION); level 2 bold, left, for roman-numeral argument headings; level 3 bold italic, left, for lettered sub-headings. A heading is kept with the paragraph after it.
- Signature block: "Respectfully submitted," then the optional `firm` list (a `""` entry is a blank line), the "/s/" line and the signer's contact lines; single-spaced at the right half, kept together.
- Certificate block: centered bold capitals title, the statement indented, the recipients and the signer; kept together.
- Footer: centered page number on every page. The clerk's ECF header is applied by the court, not by the filer, and is not produced.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1), `##` (level 2), `###` (level 3), a list (`1.` or `-` items, lettered by the template), or a paragraph (indented, not numbered).
- Frontmatter fields: `case_number`, `caption.parties` (list of `{names, designation}`; names are plain text, not markdown), `brief_title`, `jury_demand`, `date` (optional), `signature` (`firm` list, `sign`, `lines`), `certificate` (`title`, `text`, `recipients`, `sign`, `lines`; the template renders the certificate after the signature, so it is not in the body).
- Body paragraphs that the filing numbers are written `1\.`, `2\.` and so on (escaped so markdown does not read them as a list).
- Not supported: tables, footnotes, raw typst, forced line breaks in the body.

## Known gaps and open choices

1. **Table of contents and table of authorities.** LCvR7.1(e) requires both for a brief over 15 pages. The template does not generate them; a sample over 15 pages would fail that rule. The sample is 8 pages, so the requirement does not apply to it. Adding a generated TOC/TOA is a larger change (it needs a citation index), not made here.
2. **Fax number.** LCvR5.4 asks for a fax number on every paper. The exemplar's signature block has no fax line, and the sample reproduces the filed block as is. The template prints what the frontmatter gives; whether a missing fax line is a defect is a question for David.
3. **Font.** Face required by the court's rules: **none named**. LCvR7.1(d) (read in `LocalRules2026.pdf`, text extraction on 2026-10-15) requires "print style ... not less than 13-point type" and nothing about a face; LCvR5.2(a) requires double spacing and 8 1/2 by 11 paper. Template font: **EB Garamond** (`fonts/eb-garamond`), kept per `docs/FONTS.md` ("No face named"). The exemplar is set in Times New Roman (body-text glyph boxes about 17.5 pt by `pdftotext -bbox`, against about 15.6 pt for the 13-point complaint exemplar); the exemplar's face does not change the rule, so it is not substituted. EB Garamond at 13 pt has a smaller x-height, so the text looks smaller than the exemplar; the 13-point minimum is met. Visual difference only; not metric-compatible with the exemplar's face, so line breaks differ.
4. **Exemplar count.** One exemplar, one filer (a municipal defendant's counsel, a government party). EVAL-LOOP tier 2 asks for two or three filers, and a second filer would be a private defendant's or a plaintiff's motion. The search found other W.D. Okla. motions to dismiss in RECAP (for example Johnson v. University of Oklahoma, 5:24-cv-00495, a 2024 motion and an amended motion; Bridge v. Oklahoma State Department of Education, 5:22-cv-00787, 2022), but these were not downloaded or checked. Tier 2 is therefore **not** judged against two or three filers.
5. **Case names are roman.** The text layer of the exemplar has no italic markup, so the transcription is roman. The template does italicize `*...*` markdown, so a later sample can carry italics. The exemplar's citations (e.g. *Bell Atlantic Corp. v. Twombly*) are probably italic in the filed PDF; this is not asserted.
6. **Certificate of mailing.** The exemplar's certificate reads "I hereby certify that on the 16th day of September, 2026, I filed ... by US Postal Service ..." and is signed by the filer's counsel. The template renders the frontmatter text as given; the statement is case-specific and belongs in the sample only.
7. **Typos in the filing are kept.** The exemplar has typographical slips (for example "DIMISSED" in a heading, "City , filed", "Rule 12 (B)(6)", "Federal Rules of Civil Procedure Rule 8"); the transcription keeps them as filed, so the overlay compares like with like. They are not corrected here.
8. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids touching `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.
9. **Ragged right.** Body text is left-aligned, not justified. The exemplar's justification could not be read from the text layer; this is a tier 2/3 choice and is not asserted.
10. **Sticky headings leave space.** A heading that does not fit at the foot of a page moves to the next page with its paragraph, which leaves some white space at the foot of page 3 (sample). This is the intended behaviour, not a defect.
