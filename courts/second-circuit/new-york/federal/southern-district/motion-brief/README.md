# S.D.N.Y. (nysd): motion brief (memorandum of law in support of a Rule 12(b) motion)

Doc type: **motion brief** (memorandum of law in support of a motion to dismiss under Fed. R. Civ. P. 12(b)(6)) in the United States District Court for the Southern District of New York (`nysd`).
Folder: `courts/second-circuit/new-york/federal/southern-district/motion-brief/`. Sibling doc type: `../complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (full body transcription, corrected from the exemplar's OCR text; see Sample) |
| typeface | face required: **none** in the court's rules (the joint rules name no face; see NYSD-FORM-002); one judge's practices name Times New Roman 12 pt (see gaps, item 2). The template sets Times New Roman (vendored), the house standard, on typst and docx alike (fb-595.68.26; was EB Garamond). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 16 pages (cover, TOC, TOA of two pages, body of 11 pages, certificate), vendored Times New Roman only, no warnings, on the shared cross-engine layout model (`lib/typst/xengine.typ`; fb-595.68.26) |
| overlay | ok: `usage/OVERLAY-minerva-motion-to-dismiss.pdf` and `.txt` (re-generated 2026-10-15 against `usage/FILED-EXAMPLE-motion-brief.pdf`, the RECAP copy named in `usage/SOURCE.md`) |
| pages reviewed | 16 of 16 on typst and docx (every page rendered at 40 dpi and viewed side by side after the last template change, 2026-10-22) |

Naming note: the brief asked for `usage/<id>.md` and `<id>-overlay.pdf`. The tools and repo convention use `INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`, so those names are used. The id is `minerva-motion-to-dismiss`.

Not set here: `court.json` status, the court-root `typst/` and `usage/` folders (untouched), `STATUS.md`, the tracker.

## Governing rules

Primary sources, read on 2026-10-14:

- **S.D.N.Y. and E.D.N.Y. Joint Local Civil Rules, as amended effective January 2, 2026**, https://www.nysd.uscourts.gov/sites/default/files/local_rules/2026-01-02%20-%20EDNY%20and%20SDNY%20Joint%20Local%20Rules%20As%20Amended.pdf. Local Civil Rule 7.1 (pp. 20 to 21 of the PDF) is quoted from it. Local Civil Rule 11.1 (form of papers) is marked **[Withdrawn]** in these rules; its formatting content moved into 7.1(b).
- **Fed. R. Civ. P. 12(b)**, Cornell LII, https://www.law.cornell.edu/rules/frcp/rule_12: "But a party may assert the following defenses by motion: ... (6) failure to state a claim upon which relief can be granted." Checked 2026-10-14.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| NYSD-FORM-001 | Local Civ. R. 7.1(b)(1) | "all text must be 12-point type or larger, except for text in footnotes which may be 10-point type." | `type-size = 12pt` (footnotes also 12 pt, single-spaced) |
| NYSD-FORM-002 | Local Civ. R. 7.1(b) | The joint rules name **no typeface**. The memo's own certificate cites Judge Caproni's Individual Practice Rule 4(B)(ii) for Times New Roman 12 pt. The template sets Times New Roman, the house standard. See gaps. | `font-family` |
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
- Body: arabic numerals from 1, double-spaced in exact 24 pt lines. Headings at the type size, bold, single-spaced (13.8 pt lines) with a single line above and below: level 1 centered caps; levels 2 to 5 the label in a half-inch box (each level half an inch further in), the title hanging after it. Each heading is sticky. Footnotes at 12 pt, single-spaced, 7 pt apart. The last paragraph is kept with the signature block.
- Block quotations are half an inch in on both sides, single-spaced (NYSD-FORM-003), a single line above and below. Bullets in a half-inch box, the text hanging, double-spaced.
- Signature block: "Dated:" and the place and date at left; "Respectfully submitted," and the firm at right.
- Certificate of compliance: its own page after the signature. Paragraph 1 states the word count (from the frontmatter) under LCivR 7.1(c). Paragraph 2 states the typeface, size, margins and spacing under LCivR 7.1(b), from the template's parameters, so the certificate cannot disagree with the render.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `counsel` (lines, single-spaced at the top of the cover), `court` (list of lines), `case_number`, `file-label` (optional, default `No.`; the exemplar uses `Case No.`), `legends` (optional, above the file number; e.g. `In Admiralty`), `judge` (optional), `caption` (list of `{names, designation}`), `title`, `place` (optional, default New York, New York), `date`, `word_count` (string, for the certificate), `signature` (`firm` lines, `signer`, `lines`), `authorities` (registry: `{kind: case|statute|rule|regulation|other, name, cite}`).
- Body: markdown. Authorities are linked as `[text](toa:KEY)`; every link adds the page to the TOA (a `toa:` link with no registry entry fails the build). Footnotes are `[^label]` with a definition anywhere in the body. Case names are italic (`*...*`).
- The sample types no heading numbers: the template numbers the level 2 to 5 headings.

## Sample

- `usage/INPUT-motion-brief.md` transcribes the whole exemplar body: the preliminary statement, background, legal standard, Argument I (with Singapore veil-piercing and footnote 1), II (with A, B, C, D and footnote 2), III, IV, V and the conclusion. The caption, counsel block, title, signature and certificate are transcribed from the exemplar's first page and last pages.
- Text: the exemplar's text layer is OCR (paper capture), with errors (for example "Complainf s", "Comp!.", "Malrn·een", "MahYveen", "Trombly" for *Twombly*, "Blue TiVhale" for *Blue Whale*). The sample corrects these by reading in context. It was not checked word-for-word against the page image, so a residual transcription error is possible; the citations below are the ones to check first.
- Word count (`word_count: "3,546"` in the frontmatter): counted from the sample body (from "Preliminary Statement" to the end of the conclusion, with headings and footnotes) using `wc -w` after removing link targets and markup. It is not the word processor's count. The exemplar's own certificate states 3,599 words. This README does not explain the difference; the certificate in the render says 3,546, the count of this sample only. A real filing must take its count from the word processor.
- Citations: the sample keeps the citations as the exemplar prints them. Not verified against the reporters: *Archawski v. Hanioti*, "239 F.2d 806 (2d Cir. 1956)" (OCR; the reporter and year look doubtful and should be checked before any use); the pincites of *AlbaniaBEG* (94) and *Koehler* (537–41), which were read from OCR; *Golden Horn* and *Platina* (WL numbers as printed). The Bull article and the Reilly commentary are in the TOA as printed.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/second-circuit/new-york/federal/southern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/second-circuit/new-york/federal/southern-district/motion-brief minerva-motion-to-dismiss
```

- `usage/OUTPUT-motion-brief.typst.pdf`: 16 pages. typst compiled with no warnings. Vendored fonts only (Times New Roman, embedded).
- `usage/OVERLAY-minerva-motion-to-dismiss.pdf` and `.txt`: red = our render, blue = exemplar, black = both agree. Pages are paired by word overlap. The pairing is coarse and the overlay is a diagnostic, not a score. Ours p.1 to 2 pair with the filed pages 1 to 2 (86% and 89%); ours p.3 to 8 pair with filed p.3 to 8 at 20% to 89% (lowest at p.4, 20%); from our p.9 to p.18 the pairing is one page earlier than the printed page (filed p.8 to 17), which is what word overlap found. I did not investigate the cause of that offset. Read the overlay as pairing pages by text, not as a page-for-page match.

## Visual review (Gate 2 record, made on the earlier 18-page EB Garamond render; the 16 pages of the current typst and docx renders were viewed side by side on 2026-10-22, no defect found)

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
2. **Typeface (resolved).** The joint rules name none. The template sets Times New Roman 12 pt, the house standard (David, 2026-10-17), which is also what the exemplar's judge (Judge Caproni, External Practices in Civil Cases, March 17, 2025, <https://www.nysd.uscourts.gov/sites/default/files/practice_documents/VC%20Caproni%20External%20Practices%20in%20Civil%20Cases%20%282025-03-17%29.pdf>) requires. The certificate names the face from the template's `font-family`.
3. **Judge's individual practices.** Not in the template and not fetched. The exemplar cites a judge-specific rule for word count and typeface. Individual practices vary by judge; check the assigned judge's rules before filing.
4. **Word count.** The template cannot count words; it prints the frontmatter value. The sample's 3,546 is a count of the transcription (see Sample). Production use needs the word processor's count.
5. **Body length.** The body runs 11 pages (the exemplar's body is 12); the whole render is 16 pages against 17 for the exemplar.
6. **Citations read from OCR.** See Sample. Verify against the reporters before any reuse.
7. **Notice of motion, proposed order, declarations, Rule 7.1 disclosure.** Not produced (separate filings).
8. **Automated check.** `tools/check.sh` runs on this folder (typst and docx); the RESULT lines are under Engines.

## Engines

The typst template is the reference; the docx breaks every line and page where it does (Gate 4 CROSS-ENGINE, `params.cross_engine: gate` in `eval.yaml`).

DOCX (`docx/`): `reference.xml` (`base="xengine"`: the face is the typst template's through `{font}`, 12 pt, exact 24 pt body lines, 13.8 pt single lines, footnotes at 12 pt 7 pt apart without keepLines, Block Text half an inch in on both sides, "Body Text Note" and "Body Text Keep"; pandoc reads the sample as CommonMark, as cmarker does) and `motion-brief.lua` (on `lib/docx/xengine.lua`: the cover, the headings with their labels, the table of contents and the table of authorities as listing rows with a page column, the signature table and the certificate, each in the typst template's line boxes and spaces, and four sections: the cover unnumbered, the tables in lower roman from i, the body from 1, the certificate unnumbered). The tables' page numbers come from `fb render`'s needles (``: the table titles, every heading with the words after it, every `toa:` citation, in document order), in place of the deleted `render.sh` and `pages.awk`; `fb render` builds the reference document (no shell script, no committed `reference.docx`; fb-595.68.26). Output: `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice conversion; opened in LibreOffice, not Word). The page numbers hold in Word only if Word paginates the same way (`docs/DOCX.md`).

- `tools/check.sh <dir>`: RESULT: 9 checks passed, 0 failed (DEF-TOC-001, DEF-COVER-001 pass).
- `tools/check.sh <dir> --engine docx`: RESULT: 13 checks passed, 0 failed; XENG-001..003 PASS (16 pages, 379/379 lines).
- No latex engine for this folder.
