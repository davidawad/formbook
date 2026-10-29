# okwd: motion-brief

Doc type: **motion to dismiss with brief in support** (Fed. R. Civ. P. 12(b)(6)) in the United States District Court for the Western District of Oklahoma (`okwd`). The motion and brief are one document, titled as one (LCvR7.1(k)).
Folder: `courts/tenth-circuit/oklahoma/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer, a defendant's municipal counsel; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the whole motion and brief, caption, signature and certificate of mailing |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 10 pages (the docx render too), typst 0.15.0, Times New Roman only, no warnings (`sh tools/render.sh`) |
| overlay | ok: `usage/OVERLAY-trupia-motion-brief.pdf` and `OVERLAY-trupia-motion-brief.txt` (`sh tools/overlay.sh`) |
| pages reviewed | 10 of 10, typst and docx (every page rendered at 40 to 50 dpi and viewed after the last template change; fb-595.68.33) |

File names follow the house convention that `tools/render.sh` and `tools/overlay.sh` read and write: the brief's `usage/<id>.md` is `usage/INPUT-<id>.md`, its `<id>.pdf` is `OUTPUT-<id>.pdf`, and its `<id>-overlay.pdf` / `.txt` are `OVERLAY-<id>.pdf` / `.txt`.

## Governing rules

Primary sources. Local rules: the W.D. Okla. Local Civil Rules as posted at
https://okwd.uscourts.gov/local-rules (current edition `LocalRules2026.pdf`, effective April 2026, read by text extraction on 2026-10-14; the court posts a red-lined set of 2026 proposed amendments with no effective date, not reflected here). Federal rules: Fed. R. Civ. P. 5, 7, 8, 10, 11 and 12 from https://www.law.cornell.edu/rules/frcp/ , fetched 2026-10-14 (the wording quoted in this README was read in those texts: Rules 5(b)(2)(C), 7(b)(1), 8(a), 10(a), 11(a), 12(b)).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCvR7.1(b) | Each motion and brief clearly titled to identify on whose behalf it is presented. | `brief_title` (in the sample: "DEFENDANT CITY OF OKLAHOMA CITY'S MOTION TO DISMISS AND BRIEF IN SUPPORT"). |
| LCvR7.1(c) | Each motion a separate document (a combined motion and brief is allowed by (k)). | Not a template matter; the sample is one motion. |
| LCvR7.1(d) | Print style, footnotes included, not less than **13-point**; margins at least one inch top, bottom and sides. | `type-size = 13pt`; `margin = 1in`. The footer page number is 13 pt. |
| LCvR7.1(e) | Opening brief not over 25 pages (30 for summary judgment); cover, table of contents, table of authorities, signature block, certificate of service and exhibits not counted; a brief over 15 pages needs an indexed table of contents and table of authorities. | Page limit is a content matter, the sample is 10 pages; `eval.yaml` sets `page_limit: 25` (DEF-LEN-001, counted over every page, so stricter than the rule). **The template does not generate a table of contents or table of authorities** (see known gaps). |
| LCvR7.1(k) | A motion and brief in support may be one document if so identified in the title. | `brief_title` names both. |
| LCvR5.2(a) | Papers double-spaced if typewritten; 8 1/2 by 11 inch paper; one side. | `pitch-body = 29.9pt`, exact line boxes of two single lines of Times New Roman at 13 pt (the exemplar measures the same 29.9 pt); checked as OKWD-FORM-002 in `eval.yaml` (every pair of body lines at least 26 pt apart); headings, the caption and the signature single-spaced (LCvR7.1(e) allows it for headings); `page-w`, `page-h`. |
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
- Body double spaced in exact 29.9 pt line boxes (`pitch-body`; single lines 14.95 pt) on the shared cross-engine layout model (`lib/typst/xengine.typ`), with no extra space between paragraphs (as the exemplar; was 26 pt with a 17.5 pt gap after every paragraph); first-line indent 0.5 inch. Paragraphs are not auto-numbered: where the filed brief numbers its statement of the case, the sample types the number in the text (escaped as `1\.`), so the numbers are exactly those filed.
- Headings at 13 pt, single-spaced, with a blank single line above (were typst's larger heading sizes on the double pitch): level 1 bold centered capitals (STATEMENT OF THE CASE, ARGUMENT AND AUTHORITY, CONCLUSION); level 2 bold at the margin, its label ("II.") in a 0.5 in box and its lines hanging after it (as the exemplar); level 3 bold italic, the same after the 0.5 in indent. A heading is kept with the paragraph after it. List items (`1.` lettered A., B., ...; `-` bulleted) have the label in a 0.5 in box after the indent, the text hanging at 1 in.
- Signature block from 3.4 in (the date, when given, at the margin beside it): "Respectfully submitted," then the optional `firm` list (a `""` entry is a blank line), the "/s/" line and the signer's contact lines; single-spaced at the right half, kept together.
- Certificate block: centered bold capitals title, the statement as a double-spaced paragraph, a blank line, the recipients and the signer from 3.4 in; kept together. The last chunk of the body is kept with the signature block (on the sample the whole conclusion moves to page 9, leaving the foot of page 8 empty: accepted, a signature never stands alone).
- Footer: centered page number on every page. The clerk's ECF header is applied by the court, not by the filer, and is not produced.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1, unnumbered), `##` (level 2, numbered I., II. by the template), `###` (level 3, lettered A., B. by the template; do not type the labels), a markdown list, or a paragraph (indented, not numbered).
- Frontmatter fields: `case_number`, `caption.parties` (list of `{names, designation}`; `names` a list of lines), `brief_title` (must contain "brief", LCvR7.1(k)), `jury_demand`, `date` (optional), `signature` (`firm` list of lines, a `""` entry a blank line, optional; `sign`; `lines`), `certificate` (optional: `title`, `text`, `recipients` lines, `sign`, `lines`; set after the signature, so it is not in the body).
- Body paragraphs that the filing numbers are written `1\.`, `2\.` and so on (escaped so markdown does not read them as a list).
- Not supported: raw typst, forced line breaks in the body. Footnotes and pipe tables are set by the shared model (none in the sample).

## Known gaps and open choices

1. **Table of contents and table of authorities.** LCvR7.1(e) requires both for a brief over 15 pages. The template does not generate them; a sample over 15 pages would fail that rule. The sample is 8 pages, so the requirement does not apply to it. Adding a generated TOC/TOA is a larger change (it needs a citation index), not made here.
2. **Fax number.** LCvR5.4 asks for a fax number on every paper. The exemplar's signature block has no fax line, and the sample reproduces the filed block as is. The template prints what the frontmatter gives; whether a missing fax line is a defect is a question for David.
3. **Font.** Face required by the court's rules: **none named**. LCvR7.1(d) (read in `LocalRules2026.pdf`, text extraction on 2026-10-15) requires "print style ... not less than 13-point type" and nothing about a face; LCvR5.2(a) requires double spacing and 8 1/2 by 11 paper. Template font: **Times New Roman** 13 pt, the house standard (`docs/FONTS.md`) and the exemplar's face, in typst and docx alike (fb-595.68.33; the docx had named EB Garamond).
4. **Exemplar count.** One exemplar, one filer (a municipal defendant's counsel, a government party). EVAL-LOOP tier 2 asks for two or three filers, and a second filer would be a private defendant's or a plaintiff's motion. The search found other W.D. Okla. motions to dismiss in RECAP (for example Johnson v. University of Oklahoma, 5:24-cv-00495, a 2024 motion and an amended motion; Bridge v. Oklahoma State Department of Education, 5:22-cv-00787, 2022), but these were not downloaded or checked. Tier 2 is therefore **not** judged against two or three filers.
5. **Case names are roman.** The text layer of the exemplar has no italic markup, so the transcription is roman. The template does italicize `*...*` markdown, so a later sample can carry italics. The exemplar's citations (e.g. *Bell Atlantic Corp. v. Twombly*) are probably italic in the filed PDF; this is not asserted.
6. **Certificate of mailing.** The exemplar's certificate reads "I hereby certify that on the 16th day of September, 2026, I filed ... by US Postal Service ..." and is signed by the filer's counsel. The template renders the frontmatter text as given; the statement is case-specific and belongs in the sample only.
7. **Typos in the filing are kept.** The exemplar has typographical slips (for example "DIMISSED" in a heading, "City , filed", "Rule 12 (B)(6)", "Federal Rules of Civil Procedure Rule 8"); the transcription keeps them as filed, so the overlay compares like with like. They are not corrected here.
8. **Gates.** `sh tools/check.sh <this folder>` and `--engine docx` both exit 0 (typst 12, docx 16 checks passed, 0 failed; fb-595.68.33).
9. **Ragged right.** Body text is left-aligned, not justified. The exemplar's justification could not be read from the text layer; this is a tier 2/3 choice and is not asserted.
10. **Sticky headings leave space.** A heading that does not fit at the foot of a page moves to the next page with its paragraph, which leaves white space at the foot of a page (on the sample since fb-595.68.33: the foot of page 8, the conclusion being kept with the signature block). This is the intended behaviour, not a defect.

## Engines

Typst is the primary engine. The docx engine (`docx/`): `reference.xml` holds the Word styles (`base="xengine"` in the typst face `{font}`, Times New Roman 13 pt, 598-twip body and 299-twip single line boxes, the 13 pt page-number footer 0.5 in above the page edge; `fb render` builds the reference document from it), and `okwd-motion-brief.lua` reads the sample's body chunk by chunk as the typst template does and writes every paragraph as WordprocessingML on `lib/docx/xengine.lua` (the frontmatter read as written, `$FORMBOOK_META`): the caption as a three-column table row, the headings' labels before a tab, the signature block and the certificate each kept together. No script: `fb render` runs pandoc with the filter and packs the archive (fb-595.68.33; were `build-reference.sh` and a committed `reference.docx` naming EB Garamond, which failed DEF-FONT-002).

- Cross-engine (fb-595.68.33): typst and docx share the layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`). `sh tools/check.sh <this folder> --engine docx`: XENG-001..003 PASS (10 = 10 pages, 199/199 lines break after the same word); `params.cross_engine: gate` in `eval.yaml`. typst 12 and docx 16 checks passed, 0 failed (with OKWD-FONT-003, every word at least 13 pt, OKWD-FORM-002, double spacing, and the 25-page limit from `eval.yaml`).
- The `.docx` converts in LibreOffice without error (the check's conversion); not opened in Word.

## On the FRCP base (fb-595.17.20, 2026-10-29)

`typst/layout.yaml` names the generic federal district brief (`base: /lib/layouts/frcp-motion-brief.yaml`, fb-595.17) and overlays only what W.D. Okla. sets itself, each rule cited there; `typst/okwd-motion-brief.typ` names the face, asserts LCvR7.1(k) (the title says "brief") and hands the merged layout to the shared document model (`lib/typst/xdoc.typ`). `latex/` and `docx/` are generated from the merged layout by `fb engines gen` (do not edit them; `fb engines gen --check` fails on a stale one). The per-folder typst code and the docx filter `okwd-motion-brief.lua` are gone. The Layout, Engines and gap 8 above describe the earlier template where they differ from this list.

- Unchanged numbers: Times New Roman 13 pt (LCvR7.1(d)), 29.9 pt double pitch and 14.95 pt single lines (LCvR5.2(a)), the caption's 3.4 in party column, ")" column and case number with JURY TRIAL DEMANDED, the signature column 3.4 in in, the 25-page `page_limit`.
- Headings: the argument headings are numbered I., II. and the sub-headings lettered A., B. by the template (each label in a half-inch box), so the sample no longer types its labels.
- Signature: "Respectfully submitted,", a blank line, the supervising counsel's lines (a `""` line between groups), a blank line, the `/s/` line and the signer's lines; kept whole and with the body's last paragraph (`keep_with_closing`). The sample's trailing `""` lines in `firm` and `recipients` are dropped (the layout sets the blank line).
- Certificate of mailing: kept whole after the signature; the persons served now half an inch in (the exemplar's), no longer in the signature column.
- `eval.yaml`: OKWD-FORM-002 (double spacing) runs on typst and docx; on latex it is SKIP with its reason: pdfTeX sets the pilcrow (the sample's "¶¶") from the TS1 Termes font, whose taller glyph box the line reader takes for a line of its own 3.56 pt above its neighbours. The latex render is set at the same 29.9 pt pitch from the same layout (XENG-003 below). The `fix.anchor`s point into `typst/layout.yaml`.
- Not produced, as before: the table of contents and of authorities of LCvR7.1(e) for a brief over 15 pages (gap 1; the model can set them, `contents`/`authorities`, a later change).

Gate 2 review after the move (every page of the three renders, as text layout `pdftotext -layout` and word boxes `-bbox`; this pod's image viewer could not open a PNG, so no page was looked at as a picture; the latex and docx renders break every line where typst does, XENG-003):

| Page | What is on it | Finding | Status |
|---|---|---|---|
| 1 | Court name, caption with ")" column, case number and JURY TRIAL DEMANDED, the title, the opening paragraph, STATEMENT OF THE CASE, paragraphs 1 to 3 | none | PASS |
| 2-3 | Paragraphs 4 to 8, ARGUMENT AND AUTHORITY, I., II., III. and III.A | labels in their half-inch boxes, sub-headings bold italic half an inch in | PASS |
| 4-7 | III.B, III.C | none | PASS |
| 8 | The end of III.C; the foot of the page empty | the conclusion is kept with the signature (gap 10) | ACCEPTED |
| 9 | CONCLUSION, the signature block | none | PASS |
| 10 | CERTIFICATE OF MAILING, the persons served, the signer | none | PASS |

- typst: `RESULT: 12 checks passed, 0 failed`.
- latex: `RESULT: 14 checks passed, 0 failed` (OKWD-FORM-002 SKIP, above); XENG-001..003 PASS (10 pages, 199/199 typst lines break after the same word).
- docx: `RESULT: 16 checks passed, 0 failed`; XENG-001..003 PASS (10 pages, 199/199).
- `tools/check-selftest.sh` reads a court folder's `court.json`; this doc-type folder has none, so it does not run here.
- BLOCKED: none.
