# S.D.N.Y. (nysd): motion brief (memorandum of law in support of a Rule 12(b) motion)

Doc type: **motion brief** (memorandum of law in support of a motion to dismiss under Fed. R. Civ. P. 12(b)(6)) in the United States District Court for the Southern District of New York (`nysd`).
Folder: `courts/second-circuit/new-york/federal/southern-district/motion-brief/`. Sibling doc type: `../complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-nysd-motion-brief-minerva26cv06789.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-nysd-motion-brief-minervamotiontodismiss.md` (full body transcription, corrected from the exemplar's OCR text; see Sample) |
| typeface | face required: **none** in the court's rules (the joint rules name no face; see NYSD-FORM-002). One judge's practices name Times New Roman 12 pt (see gaps, item 2). Vendored substitute: **none**, EB Garamond kept per `docs/FONTS.md` ("No face named"). Fit: n/a. `pdffonts`: EBGaramond-Regular, -Italic, -Bold, embedded. |
| render | ok: `usage/OUTPUT-nysd-motion-brief-minervamotiontodismiss.typst.pdf`, 18 pages (cover, TOC, TOA, body of 13 pages, certificate), typst 0.15.0, vendored EB Garamond only, no warnings (re-rendered 2026-10-15) |
| overlay | ok: `usage/OVERLAY-minerva-motion-to-dismiss.pdf` and `.txt` (re-generated 2026-10-15 against `usage/SAMPLE-nysd-motion-brief-minerva26cv06789.pdf`, the RECAP copy named in `usage/SOURCE.md`) |
| pages reviewed | 18 of 18 (every page rendered at 60 dpi and looked at, again on 2026-10-15 after the re-render) |

Naming note: the brief asked for `usage/<id>.md` and `<id>-overlay.pdf`. The tools and repo convention use `INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`, so those names are used. The id is `minerva-motion-to-dismiss`.

Not set here: `court.json` status, the court-root `typst/` and `usage/` folders (untouched), `STATUS.md`, the tracker.

## Governing rules

Primary sources, read on 2026-10-14:

- **S.D.N.Y. and E.D.N.Y. Joint Local Civil Rules, as amended effective January 2, 2026**, https://www.nysd.uscourts.gov/sites/default/files/local_rules/2026-01-02%20-%20EDNY%20and%20SDNY%20Joint%20Local%20Rules%20As%20Amended.pdf. Local Civil Rule 7.1 (pp. 20 to 21 of the PDF) is quoted from it. Local Civil Rule 11.1 (form of papers) is marked **[Withdrawn]** in these rules; its formatting content moved into 7.1(b).
- **Fed. R. Civ. P. 12(b)**, Cornell LII, https://www.law.cornell.edu/rules/frcp/rule_12: "But a party may assert the following defenses by motion: ... (6) failure to state a claim upon which relief can be granted." Checked 2026-10-14.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| NYSD-FORM-001 | Local Civ. R. 7.1(b)(1) | "all text must be 12-point type or larger, except for text in footnotes which may be 10-point type." | `type-size = 12pt` (footnotes also 12 pt, single-spaced) |
| NYSD-FORM-002 | Local Civ. R. 7.1(b) | The joint rules name **no typeface**. The memo's own certificate cites Judge Caproni's Individual Practice Rule 4(B)(ii) for Times New Roman 12 pt. Typeface here is the vendored EB Garamond. See gaps. | `font-family` |
| NYSD-FORM-003 | Local Civ. R. 7.1(b)(3) | "all text must be double-spaced, except for headings, text in footnotes, or block quotations, which may be single-spaced." | `body-leading = 1.35em` (24 pt pitch at 12 pt); headings, block quotations, footnotes, counsel block, caption, TOC/TOA and signature single-spaced |
| NYSD-FORM-004 | Local Civ. R. 7.1(b)(2) | "all documents must have at least one-inch margins on all sides." | `margins = 1in` |
| NYSD-CONT-001 | Local Civ. R. 7.1(a)(2) | A memorandum of law "divided, under appropriate headings, into as many parts as there are issues to be determined." | Headings: level 1 centered caps (PRELIMINARY STATEMENT, BACKGROUND, LEGAL STANDARD, ARGUMENT, CONCLUSION); levels 2 to 5 numbered by the template (I., A., 1., a.) |
| NYSD-CONT-002 | Local Civ. R. 7.1(a)(1) | A notice of motion (or order to show cause) that specifies the rules relied on and the relief sought. | Not produced: a separate filing. |
| NYSD-LEN-001 | Local Civ. R. 7.1(c) | Briefs in support of a motion, if filed by an attorney or computer-prepared, "may not exceed 8,750 words". Excludes caption, index, table of contents, table of authorities, signature blocks and required certificates; includes footnotes. | Not enforced by the template: no counter. The sample is 3,546 words (see word count below). |
| NYSD-LEN-002 | Local Civ. R. 7.1(c) | "If a brief is filed by an attorney or prepared with a computer, it must include a certificate ... that the document complies with the word-count limitations ... The certificate must state the number of words in the document." | `certificate()`: the word count comes from the frontmatter `word_count`; the typeface sentence comes from the template's own parameters |
| NYSD-TOC-001 | Local Civ. R. 7.1(c) (exclusion only) | The rules exclude a table of contents and a table of authorities from the word limit. They do not require either one. | `toc-section()` and `toa-section()` (convention, as in the exemplar; built from the headings and `toa:` links) |
| NYSD-RULE-001 | Fed. R. Civ. P. 12(b)(6) | Failure to state a claim is a defense that may be raised by motion, before the responsive pleading. | Author content (the sample's legal standard; cited by link `toa:rule12b6`) |

Not produced by this template: the notice of motion (LCivR 7.1(a)(1)); the proposed order; the declaration with exhibits (LCivR 7.1(a)(3)); any Rule 7.1 disclosure statement; and the assigned judge's individual practices, which the exemplar cites for word count and typeface (Judge Caproni, Individual Practice Rule 4(B)). The template does not check the individual practices (see gaps).

## Layout

- Cover (page 1, unnumbered): counsel block at upper left (single-spaced), the court name centered bold caps, the caption (parties on the left, closed by a rule at the right and bottom; right column: `In Admiralty`, `Case No.`, the title in bold caps). The exemplar follows the same order; the rules set no cover layout.
- Table of contents and table of authorities: roman numerals (i, ii, iii), dot leaders, page numbers in their own column, built from the headings and the `toa:` links. The TOA groups are Cases, Statutes, Rules, Regulations, Other Authorities (only groups with entries print).
- Body: arabic numerals from 1. Level 1 headings are centered bold caps; level 2 to 5 headings hang with their label. Each heading is sticky. Footnote numbers are set in their own column.
- Block quotations are indented and single-spaced (NYSD-FORM-003).
- Signature block: "Dated:" and the place and date at left; "Respectfully submitted," and the firm at right.
- Certificate of compliance: its own page after the signature. Paragraph 1 states the word count (from the frontmatter) under LCivR 7.1(c). Paragraph 2 states the typeface, size, margins and spacing under LCivR 7.1(b), from the template's parameters, so the certificate cannot disagree with the render.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `counsel` (lines, single-spaced at the top of the cover), `court` (list of lines), `case_number`, `file-label` (optional, default `No.`; the exemplar uses `Case No.`), `legends` (optional, above the file number; e.g. `In Admiralty`), `judge` (optional), `caption` (list of `{names, designation}`), `title`, `place` (optional, default New York, New York), `date`, `word_count` (string, for the certificate), `signature` (`firm` lines, `signer`, `lines`), `authorities` (registry: `{kind: case|statute|rule|regulation|other, name, cite}`).
- Body: markdown. Authorities are linked as `[text](toa:KEY)`; every link adds the page to the TOA (a `toa:` link with no registry entry fails the build). Footnotes are `[^label]` with a definition anywhere in the body. Case names are italic (`*...*`).
- The sample types no heading numbers: the template numbers the level 2 to 5 headings.

## Sample

- `usage/INPUT-nysd-motion-brief-minervamotiontodismiss.md` transcribes the whole exemplar body: the preliminary statement, background, legal standard, Argument I (with Singapore veil-piercing and footnote 1), II (with A, B, C, D and footnote 2), III, IV, V and the conclusion. The caption, counsel block, title, signature and certificate are transcribed from the exemplar's first page and last pages.
- Text: the exemplar's text layer is OCR (paper capture), with errors (for example "Complainf s", "Comp!.", "Malrn·een", "MahYveen", "Trombly" for *Twombly*, "Blue TiVhale" for *Blue Whale*). The sample corrects these by reading in context. It was not checked word-for-word against the page image, so a residual transcription error is possible; the citations below are the ones to check first.
- Word count (`word_count: "3,546"` in the frontmatter): counted from the sample body (from "Preliminary Statement" to the end of the conclusion, with headings and footnotes) using `wc -w` after removing link targets and markup. It is not the word processor's count. The exemplar's own certificate states 3,599 words. This README does not explain the difference; the certificate in the render says 3,546, the count of this sample only. A real filing must take its count from the word processor.
- Citations: the sample keeps the citations as the exemplar prints them. Not verified against the reporters: *Archawski v. Hanioti*, "239 F.2d 806 (2d Cir. 1956)" (OCR; the reporter and year look doubtful and should be checked before any use); the pincites of *AlbaniaBEG* (94) and *Koehler* (537–41), which were read from OCR; *Golden Horn* and *Platina* (WL numbers as printed). The Bull article and the Reilly commentary are in the TOA as printed.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/second-circuit/new-york/federal/southern-district/motion-brief usage/INPUT-nysd-motion-brief-minervamotiontodismiss.md
sh tools/overlay.sh courts/second-circuit/new-york/federal/southern-district/motion-brief minerva-motion-to-dismiss
```

- `usage/OUTPUT-nysd-motion-brief-minervamotiontodismiss.typst.pdf`: 18 pages. typst compiled with no warnings. Vendored fonts only (`pdffonts`: EBGaramond-Regular, -Italic, -Bold, embedded).
- `usage/OVERLAY-minerva-motion-to-dismiss.pdf` and `.txt`: red = our render, blue = exemplar, black = both agree. Pages are paired by word overlap. The pairing is coarse and the overlay is a diagnostic, not a score. Ours p.1 to 2 pair with the filed pages 1 to 2 (86% and 89%); ours p.3 to 8 pair with filed p.3 to 8 at 20% to 89% (lowest at p.4, 20%); from our p.9 to p.18 the pairing is one page earlier than the printed page (filed p.8 to 17), which is what word overlap found. I did not investigate the cause of that offset. Read the overlay as pairing pages by text, not as a page-for-page match.

## Visual review (Gate 2 record, all 18 pages, rendered at 60 dpi and looked at)

Printed page numbers are the body's own (1 to 13); PDF page numbers in brackets.

| Page | What it is | Finding |
|---|---|---|
| cover [1] | Counsel block, court title, caption, title | OK. Counsel block single-spaced at upper left; caption rule at right and bottom; title bold caps. |
| TOC i [2] | Table of contents | OK. Entries, dot leaders and page numbers aligned; wrapped headings hang under their titles; the page column never splits. |
| TOA ii [3] | Cases | OK. Italic case names, cites, page numbers right-aligned; wrapped cites hang. |
| TOA iii [4] | Statutes, Rules, Other Authorities | OK. Only groups with entries print. |
| 1 [5] | Preliminary statement | OK. Double-spaced, first-line indent, heading centered. |
| 2 [6] | Background | OK. *Id.* with paragraph symbols (¶¶) correct. |
| 3 [7] | Legal standard; ARGUMENT; heading I | OK. Heading I numbered and hanging; Legal Standard citations italic. |
| 4 [8] | Argument I continued; block quotation; Bull citation; second block quotation | OK. Block quotations indented and single-spaced. Footnote references none on this page. |
| 5 [9] | Argument I end; heading II; II.A begins; footnote 1 | OK after the footnote fix: note number now set apart from its text (an earlier render ran it into the text). |
| 6 [10] | II.A continued; II.B; first two bullets | OK. Bullets with hanging indent. |
| 7 [11] | Bullets continued; II.C heading | OK. |
| 8 [12] | II.C continued (Archawski, United Overseas); footnote 2 | OK. Footnote 2 sits on this page in full. |
| 9 [13] | II.D heading and text | OK. |
| 10 [14] | II.D continued; heading III; Count II text | OK. Heading III hangs. |
| 11 [15] | Count II continued (Article 53, AlbaniaBEG, Koehler) | OK. |
| 12 [16] | Count II end; heading IV; heading V | OK. Heading IV two lines, sticky. |
| 13 [17] | Leave to amend end; CONCLUSION; signature block | OK. Signature block sits with the conclusion. |
| certificate [18] | Certificate of compliance: word count and typeface | OK after the fix that prints "12-point type" (earlier render printed the raw length value). Paragraphs 1 and 2 separated. |

## Known gaps and open choices

1. **One exemplar.** The brief asks for one per doc type. Tier 2 (two or three filers) is not met. A second SDNY memorandum of the same type, *Better Home & Finance Holding Co. v. Garg*, No. 1:26-cv-07025-CM (30 pp., counsel-filed), was downloaded and checked for text but not saved.
2. **Typeface.** The joint rules name none, so the court-wide template keeps EB Garamond (`docs/FONTS.md`, "No face named"; decided 2026-10-15). The exemplar's certificate cites Judge Caproni's Individual Practice Rule 4(B)(ii) for Times New Roman 12 pt. On 2026-10-15 I checked her published "External Practices in Civil Cases" (March 17, 2025 version, <https://www.nysd.uscourts.gov/sites/default/files/practice_documents/VC%20Caproni%20External%20Practices%20in%20Civil%20Cases%20%282025-03-17%29.pdf>): it requires Times New Roman 12-point and one-inch margins, double spacing, and a word-count certificate. The rule number 4(B)(ii) was not confirmed from the text. That is one judge's rule, not the court's; a template used before other judges cannot follow it. Whether the court template should follow it is a question for David. If so, the substitute is Liberation Serif (metric-compatible), and the change is `font-family` in `typst/nysd-motion-brief.typ` plus the typeface sentence in the certificate. A Times-metric face would also close the length gap. The exemplar's own embedded font is Times-Roman, not embedded.
3. **Judge's individual practices.** Not in the template and not fetched. The exemplar cites a judge-specific rule for word count and typeface. Individual practices vary by judge; check the assigned judge's rules before filing.
4. **Word count.** The template cannot count words; it prints the frontmatter value. The sample's 3,546 is a count of the transcription (see Sample). Production use needs the word processor's count.
5. **Body length.** The body runs 13 pages (the exemplar's body is 12). The brief's 8-to-14 page target is met for the body; the whole render is 18 pages, against 17 for the exemplar, because the cover, TOC, TOA and certificate each take their own page.
6. **Citations read from OCR.** See Sample. Verify against the reporters before any reuse.
7. **Notice of motion, proposed order, declarations, Rule 7.1 disclosure.** Not produced (separate filings).
8. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. The Gate 2 table above is the review record for this doc type.

## Engines

DOCX (`docx/`: `build-reference.sh` makes `reference.docx`; `motion-brief.lua` builds the cover, the tables, the authorities, the signature and the certificate; `render.sh` and `pages.awk` set the page numbers). Output: `usage/OUTPUT-nysd-motion-brief-minervamotiontodismiss.docx` and `.docx.pdf` (LibreOffice PDF, 16 pages). Opened and converted by LibreOffice without error (no Word here).

- Matches the typst output: letter paper, 1 in margins; EB Garamond 12 pt (`pdffonts`: EBGaramond-Regular, -Italic, -Bold); body double spaced at an exact 24 pt pitch with a 0.5 in first-line indent; headings level 2 to 5 hang with their labels (I., A., 1., a.); block quotations and footnotes single spaced; cover with no number, tables in roman numerals, body from 1, certificate with no number; the certificate's word count and typeface text come from the frontmatter and the template.
- Table of contents and table of authorities: the page numbers come from a first LibreOffice pass (`render.sh`): `pages.awk` finds each heading and each `toa:` link text in the body PDF text, in document order, then the docx is written again with those numbers. Spot checks against the rendered pages agree (for example CONCLUSION 11, Archawski 6, Koehler 9, MTBE 10). A link text that does not appear in the body is an error, not a blank. The numbers hold in Word only if Word paginates the same way; that is the known limit in `docs/DOCX.md`.
- Differs: the docx body runs 11 pages against 13 for typst (the cause was not investigated; the spacing and the typst heading size are the likely reasons). The docx headings are 12 pt bold, the typst headings render larger. The signature block travels with the conclusion (keep with next), as typst does. The docx has no typst-style "passim" logic beyond the seven-page rule (implemented, not tested on a page that reaches it).
- Pages reviewed: 16 of 16, each rendered at 60 dpi and looked at. Pages 1 to 9 were checked before the last change, which moved only the conclusion and the signature block (pages 10 and 11), and those were checked after it.
- BLOCKED: `tools/check.sh <doc-dir> --engine docx` cannot run on this doc-type folder: there is no `checks.yaml` and no `court.json` (the script prints the missing-file error for every check and then fails on an arithmetic line). The gates (0 to 3) for docx are not run. Check IDs affected: all (no checks file). Reason: this folder has no court-level check set, as the brief notes in "Known gaps", item 8.
