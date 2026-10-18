# mdd: motion-brief (memorandum in support of a Rule 12(b) motion)

Doc type: **motion-brief**: the memorandum of law in support of a motion to dismiss under Fed. R. Civ. P. 12(b), filed with the motion and a proposed order (LR 105.1) in the United States District Court for the District of Maryland (`mdd`). Folder: `courts/fourth-circuit/maryland/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (complete: caption, text, conclusion, signature block, certificate of service) |
| typeface | Rule names Times New Roman (LR-102.2.b, "Times New Roman or larger typeface"). Substitute: **Liberation Serif** (vendored; metric-compatible per `docs/FONTS.md`, not checked against a Times New Roman file on this box). Text 12 pt, footnotes 10 pt. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 11 pages, typst 0.15.0, vendored Liberation Serif only (`pdffonts`: `LiberationSerif`, `-Bold`, `-Italic`), no warnings |
| overlay | ok: `usage/OVERLAY-hylton-motion-brief.pdf` and `usage/OVERLAY-hylton-motion-brief.txt`, against the filed exemplar fetched from the RECAP URL in `usage/SOURCE.md` and checked against its SHA-256 (the exemplar PDF is not committed in this snapshot; it is passed to `tools/overlay.sh` as the third argument) |
| pages reviewed | 11 of 11 (every page rendered at 70 dpi and viewed after the last template change) |
| render command | `sh tools/render.sh courts/fourth-circuit/maryland/federal/district/motion-brief usage/INPUT-motion-brief.md` |
| overlay command | `sh tools/overlay.sh courts/fourth-circuit/maryland/federal/district/motion-brief hylton-motion-brief` |

File names: as in the complaint folder, the names follow the repo's tools (`INPUT-`, `OUTPUT-`, `OVERLAY-`), which were not edited.

## Governing rules

Primary sources, fetched 2026-10-14:

- **D. Md. Local Rules, effective December 1, 2025** (the adopted version): https://www.mdd.uscourts.gov/sites/mdd/files/LocalRules.pdf (linked from https://www.mdd.uscourts.gov/local-rules). Quoted text below is from that PDF.
- **Fed. R. Civ. P.** 8(a), 12(b): https://www.law.cornell.edu/rules/frcp/rule_8 and https://www.law.cornell.edu/rules/frcp/rule_12.

| ID | Rule | Requirement (quoted or closely paraphrased) | Where it lives |
|---|---|---|---|
| LR-102.2.a | D. Md. L.R. 102.2.a | "The case caption on all court documents shall contain only a short title, consisting of the names of the first plaintiff and the first defendant only, and the civil action number." | `caption()`: exactly two parties (panics otherwise), then `case_number` |
| LR-102.2.b | D. Md. L.R. 102.2.b | 8½ × 11 inch paper, one-inch margin on all sides; lines double-spaced except quotations and footnotes; "Pages shall be numbered at the bottom of every page after the first page"; at least 12-point text and 10-point footnotes "in Times New Roman or larger typeface." | `margins`, `line-pitch` (27.6 pt), `page-footer` (no number on physical page 1), `font-family` Liberation Serif, `type-size` 12 pt, `footnote-size` 10 pt, `body-leading` set so double-spaced lines are 27.6 pt (Known gaps 1) |
| LR-102.1.b.i | D. Md. L.R. 102.1.b.i | "At the bottom of all court documents, counsel … shall state their name, address, telephone number, email and fax number. Counsel shall also state their bar number." | `signature-block()` (panics if a field is missing; the fax value is printed as given, so "None" is a valid entry) |
| LR-102.1.c | D. Md. L.R. 102.1.c | "all court documents other than the original complaint must bear a signed certificate … If a document is filed electronically, the notice of electronic filing constitutes a certificate of service." | `certificate-block()` (optional; the sample carries one because the exemplar has one) |
| LR-105.1 | D. Md. L.R. 105.1 | "Any motion and opposition to a motion shall be filed with the Clerk and be accompanied by a memorandum setting forth the reasoning and authorities in support of it and a proposed order." | This doc type is the memorandum; the motion, the proposed order and the notice are separate filings (not produced) |
| LR-105.3 | D. Md. L.R. 105.3 | "memoranda in support of a motion … shall not exceed thirty (30) pages … exclusive of … tables of contents and citations" | End check, `max-memo-pages = 30` (with `toc: true` it counts body pages only; without it, every page, which is the stricter count; panics) |
| LR-105.4 | D. Md. L.R. 105.4 | "A table of contents shall be included in any memorandum or brief exceeding fifteen (15) pages in length." | `toc` frontmatter (default off); the end check panics when a memorandum is over 15 pages and has no TOC. Tested: a three-times-longer sample without `toc` fails with the LR-105.4 message; with `toc: true` the TOC page renders with roman numbering and the body restarts at 1. |
| FRCP 8(a) | Fed. R. Civ. P. 8(a) | A pleading must contain "a short and plain statement of the grounds for the court's jurisdiction…". | Not template content (the memorandum does not plead) |
| FRCP 12(b) | Fed. R. Civ. P. 12(b)(6) | Failure to state a claim is a defense that may be raised by motion. | Author content: the title, the introduction and the argument |

Not produced by this template: the motion itself (LR 105.1), the proposed order (LR 105.1), any exhibits (LR 105.5, tabbed when more than five), and the Certificate of Conference where one is required (LR 104.7, discovery motions). Not checked: judge's standing orders.

## Layout

- No separate cover page: the caption, the title and the opening paragraph share page 1, as in the exemplar. The court title (two lines, centered), then the short caption: the first plaintiff and the first defendant on the left with a vertical rule on the right; "Case No. …" on the right.
- The title is centered, bold, in capitals.
- Body: double-spaced; each paragraph has a 0.5 in first-line indent. Headings: level 1 centered bold capitals (INTRODUCTION, LAW, ARGUMENT, CONCLUSION, CERTIFICATE OF SERVICE); level 2 bold with a hanging indent (A., B., …); level 3 bold italic. Footnotes are 10 pt, separated by a rule.
- Numbered lists (`1.`) are numbered 1, 2, … with a hanging indent.
- Signature block after the conclusion: "/s/", the signer's name, the bar number, firm, address, telephone, facsimile, email and the role, all single-spaced in the right half of the page. "Dated:" is printed on the left only when `date` is given.
- Certificate of service after the signature block (when `certificate:` is set), with the same signature style.
- Page numbers: bottom center from physical page 2. With `toc: true`, the cover page is unnumbered, the contents are in roman numerals (i, ii, …), and the body restarts at 1.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `case_number`, `court` (lines), `caption.parties` (exactly two `{names, designation}`), `brief_title`, `toc` (true or false), `signature` (`name`, `bar`, `firm`, `address`, `phone`, `fax`, `email`, `role`), `date` (optional), `certificate` (optional: `text`, `signer`).
- Body: markdown. `#` is level 1 (centered caps), `##` level 2, `###` level 3. Footnotes are `[^n]` with a `[^n]:` definition (cmarker). Citations are written by the author; the template does not check them.
- Not supported: tables, raw typst. Lettered conclusion items (A., B.) are typed in the text: the template does not letter them.

## Overlay

`usage/OVERLAY-hylton-motion-brief.pdf`: red = our render, blue = the filed exemplar, black = both. Pages pair one-to-one here (ours p.n with filed p.n, 38-89% word overlap), because the sample is the whole memorandum. The visible differences are the page-1 page number (the exemplar prints "1"; LR-102.2.b does not), the signature block (the exemplar's "/S/" line and its missing fax line),. The page breaks differ from the exemplar, because the template's spacing is set from the rule rather than from the exemplar. The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **Font and size (LR-102.2.b).** Same as the complaint folder: Liberation Serif (the `docs/FONTS.md` substitute for the Times New Roman the rule names) at 12 pt, footnotes 10 pt. The earlier 13 pt EB Garamond is retired. Double-spaced pitch re-measured at 27.6 pt; single 13.9 pt. The render stays at 11 pages.
2. **Fax number (LR-102.1.b.i).** The filed signature block has no fax line. The rule asks for one. The sample states "None" so the template's required field is filled; the exemplar itself does not comply on this point, and the README records it rather than inventing a number.
3. **Page 1 number.** The exemplar prints "1" on page 1. LR-102.2.b says pages are numbered "after the first page"; the template follows the rule and leaves page 1 unnumbered.
4. **Footnote 3.** The exemplar's footnote 3 marker appears in the text layer with no footnote text, so the sample does not transcribe it.
5. **Italics.** The text layer has no italic markup. The sample italicises case names and signals (Bluebook style) as the transcriber's choice; the filed document was not checked for italics.
6. **Certificate of service.** The rule does not require one for an electronically filed paper (the notice of electronic filing is the certificate). The template prints one when `certificate:` is set; the sample carries the exemplar's certificate.
7. **TOC not exercised by a sample.** The memorandum is 11 pages, so `toc` is off in the sample. The TOC path was tested on a temporary copy of the sample (`toc: true`, 13 pages in total, TOC on one page with roman numbering, body restarting at 1); the temporary file was deleted and no TOC sample is kept.
7a. **Table of authorities.** Not required by D. Md. L.R. 105.4 (which asks for a table of contents only); not produced.
8. **One exemplar only.** EVAL-LOOP tier 2 asks for two or three filers. Candidates not saved (Carroll v. Mayor and City Council of Baltimore, 14 pages, and Bland v. Clearone Advantage LLC, 16 pages) are in `usage/SOURCE.md`.
9. **Gates not run.** As in the complaint folder: `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, and the brief forbids editing `tools/`.
10. **Ragged right.** Body text is left-aligned. The exemplar's justification cannot be read from the text layer; a convention, not a rule.
11. **Signature line.** The template prints "/s/" where the exemplar prints "/S/" (case only).
12. **Sample typo (open).** The CONCLUSION in `usage/INPUT-motion-brief.md` (line 124) reads "Educaiton", so the render prints it. It is the sample's transcription, not a template rule, and was left for the transcriber to fix against the filed exemplar.

## Review of the rendered pages (Gate 2 record; all 11 pages at 60 dpi, after the last template change)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, short caption (HYLTON v. SOMERSET COUNTY BOARD OF EDUCATION, ET. AL.), case number, title, opening paragraph | OK. No page number (LR-102.2.b). |
| 2 | INTRODUCTION, A. Procedural Background, B. (start) | OK. Number "2" at the foot. |
| 3 | Introduction, B. (continued) | OK. |
| 4 | LAW heading and paragraphs; ARGUMENT heading; A. (heading wraps with hanging indent) | OK. |
| 5 | Argument A (§ 1983); footnote 1 at foot of page (10 pt) | OK. |
| 6 | Argument A (Maryland boards as state agencies, continued), Count I conclusion | OK. |
| 7 | Argument B (heading wraps, hanging indent); defamation standard | OK. |
| 8 | Lankford statements (numbered list 1-3); footnote 2 at foot | OK. |
| 9 | Opinion discussion (Oliveres, Hughley); Hernandez paragraph; start of the third allegation | OK. |
| 10 | Third allegation (continued); new defendants; end of Argument B | OK. |
| 11 | CONCLUSION (A., B.), signature block (right half), CERTIFICATE OF SERVICE with signature line | OK. Transcription typo in the sample text, not the template: "Educaiton" (see Known gaps 12). |

Reviewed pages: 11 of 11 (rendered at 70 dpi, viewed as 2×2 montages after the last template change; the montages are in `/work/artifacts/review`, outside the repo).

## Engines

**typst** is the reference (`typst/`, `usage/OUTPUT-motion-brief.typst.pdf`, 11 pages). **latex**: not built for this doc type. **docx** (`docx/reference.docx`, `docx/make-reference.sh`, `docx/mdd-motion-brief.lua`): built and rendered with LibreOffice (`usage/OUTPUT-motion-brief.docx`, `usage/OUTPUT-motion-brief.docx.pdf`, 12 pages).

- *Reviewed:* all 12 pages of the docx PDF at 60 dpi (4 per montage, after the last change), and all 11 typst pages paired beside the docx page at 60 dpi. Pages reviewed: 12 of 12 (docx).
- *Matches typst (seen on the pages):* the embedded fonts are Liberation Serif regular, bold and italic, as in typst; double spacing at 27.6 pt; 1-inch margins; the cover (court lines, short caption with the first plaintiff and first defendant and the case number, the centered bold title); no page number on page 1, a centered page number from page 2; headings as the template sets them (level 1 centered bold caps, level 2 bold with a hanging indent); footnotes at 10 pt with the rule above them; numbered lists 1., 2., 3. with hanging indent; the signature block in the right half, kept on one page; the certificate of service heading centered and bold.
- *Differs (tier 2):* pagination. The docx is 12 pages, the typst output 11. The certificate of service sits alone on page 12 because the signature block fills page 11; typst puts the block and the certificate on page 11. Page breaks fall one or two lines apart from typst on most pages (for example, page 7 starts in the middle of Argument B in the docx).
- *Not verified:* the .docx has not been opened in Word. LibreOffice converted it without error. The zip and XML parts were checked.
- *Gates:* `tools/check.sh` does not run on this folder (no `court.json`/`rules.md`); the tier-1 items above were checked by eye on the pages.
- BLOCKED: LR-105.4: the table of contents is not built for docx; `toc: true` makes the build fail with a message. The sample (11 pages in typst) does not need one; a memorandum over fifteen pages cannot be delivered as docx until a TOC is built.
- *Rebuild:* `sh docx/make-reference.sh`, then `sh tools/render.sh --engine docx courts/fourth-circuit/maryland/federal/district/motion-brief usage/INPUT-motion-brief.md`.
