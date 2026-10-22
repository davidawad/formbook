# E.D. Ark. (ared): motion brief (brief in support of a motion to dismiss)

Doc type: **motion-brief**, the brief in support of a Rule 12(b)(6) motion to dismiss, in the United States District Court for the Eastern District of Arkansas (`ared`). Folder: `courts/eighth-circuit/arkansas/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the whole brief: caption, introduction, facts with a table, standard of review, argument A to C with a block quotation, conclusion, signature) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 7 pages (the exemplar is 8), typst 0.15.0, vendored EB Garamond only, no warnings |
| typeface | face required: **none** (E.D. Ark. LR 5.5(a) sets a type-size minimum, "elite", and names no face) → **EB Garamond** kept (no substitute needed; visual-only for any Times expectation) |
| overlay | not regenerated on 2026-10-14: the filed exemplar PDF is absent from this snapshot (only `usage/SOURCE.md` is tracked), so `overlay.sh` exits 1. `usage/OVERLAY-campbell-motion-brief.txt` is from the earlier run. |
| pages reviewed | 7 of 7 (every page rendered at 60 dpi and viewed in its final state) |

## Governing rules

Each rule was read from its primary text on 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| E.D. Ark. Local Rule 7.2(a) | A motion is accompanied by a brief consisting of a concise statement of relevant facts and applicable law; both are filed with the Clerk and served. Fetched from the joint Local Rules PDF (are.uscourts.gov, `redlinc LR7.2.pdf`), 2026-10-14. | Structure of the brief (the sample's sections). The brief is one document; the motion is a separate document (not generated; see gap 6). |
| E.D. Ark. Local Rule 7.2(e) | Motions to dismiss are not taken up unless set forth in a separate pleading accompanied by a separate brief. | This template is the separate brief. The motion itself must be a separate pleading. |
| E.D. Ark. Local Rule 7.2(b) | Response due 14 days after service; a summary-judgment movant has 7 days to reply. Not a layout rule. | Not checked by the template. |
| E.D. Ark. Local Rule 7.2 (no page limit) | The text of Local Rule 7.2 sets no page or word limit for a brief. The assigned judge's practices may (not checked). | No page counter. See gap 5. |
| E.D. Ark. Local Rule 5.5(a) | Papers: type not less than elite, double space, letter size, one side, unfolded, no manuscript covers. | `page-w`/`page-h` (letter), `pitch = 24pt` (double space), `type-size = 12pt`; one-sided pages. Block quotations and the table are single-spaced (gap 3). |
| E.D. Ark. Local Rule 5.5(c)(1) | Signed by at least one attorney of record, with the attorney's address, zip code, telephone number, and Arkansas Supreme Court identification number. | `signature-block`: firm, signer, and the sample's lines (the bar number is in the sample, as filed). |
| E.D. Ark. Local Rule 5.1 | A represented party files electronically (exceptions: case-initiating documents, sealed records, and documents that add a party). | Not a layout rule. The brief is an ECF filing. |
| Fed. R. Civ. P. 7(b)(1) | A request for a court order must be made by motion; the motion must be in writing and state with particularity the grounds. Fetched from https://www.law.cornell.edu/rules/frcp/rule_7, 2026-10-14. | Not a layout rule. The brief states its grounds (sample body). |
| Fed. R. Civ. P. 12(b)(6) | Failure to state a claim is a defense that may be asserted by motion. Fetched from https://www.law.cornell.edu/rules/frcp/rule_12, 2026-10-14. | Not a layout rule. The brief's standard of review and argument (sample body). |
| Fed. R. Civ. P. 11(a) | Signed by at least one attorney of record; the paper states the signer's address, e-mail address, and telephone number. Fetched from https://www.law.cornell.edu/rules/frcp/rule_11, 2026-10-14. | `signature-block`. The sample has the e-mail and phone. |
| Fed. R. Civ. P. 5(d)(1)(B) | A certificate of service is not required when a paper is served by filing it with the court's electronic-filing system. Fetched from https://www.law.cornell.edu/rules/frcp/rule_5, 2026-10-14. | No certificate of service is generated (gap 4). |

## Layout

- Letter size, 1 inch margins on every side. A page number centered in the bottom margin; no other footer text.
- No cover page. The court title (three lines: "IN THE UNITED STATES DISTRICT COURT", "FOR THE EASTERN DISTRICT OF ARKANSAS", the division), the caption (party column closed by a rule at right and bottom; the case number at right), then the centered bold title, then the body on the same page.
- Body double-spaced (24 pt baseline pitch at 12 pt). Paragraphs are not numbered (a brief's paragraphs are not numbered by the rules); each has a 0.5 inch first-line indent.
- Headings: level 1 numbered with roman numerals (I., II., III.), bold capitals, centered; an unnumbered level 1 (INTRODUCTION AND BACKGROUND, CONCLUSION) is centered bold capitals with no number. Level 2 is lettered (A., B., C.), bold, with a hanging indent. Level 3 is numbered (1., 2.), bold italic. A heading is kept with the first line of the text after it, and never ends a page.
- Block quotation: single-spaced, indented 1 inch on each side, justified (gap 3).
- Pipe table: single-spaced, 11 pt, with rules (gap 3).
- Signature block: "Respectfully submitted," the firm, "/s/" and the signer's name, then the lines (bar number, address, telephone, fax, e-mail, "Attorneys for ..."). The last paragraph of the brief stays on the same page as the signature block.

## Markdown contract (for samples)

- YAML frontmatter: `case_number`; `division` (optional); `caption.parties` (list of `{names, designation}`; the template puts "v." between parties); `brief_title`; `date` (optional); `signature` (`firm` lines, `signer`, `lines`).
- Body: blank-line-separated chunks. `#` = level 1 heading (numbered); `# ~ TEXT` = unnumbered level 1; `##` = level 2 (lettered); `###` = level 3 (numbered); a pipe table; a `>` block quotation; a `1.` list (numbered (1), (2), ...); anything else = a body paragraph.
- Heading numbers are not typed by the author. The template numbers I., II., A., B., 1., 2. itself.
- Not supported: footnotes (none in the exemplar), raw typst, and a table of contents or table of authorities (none in the exemplar; none required by the Local Rules text checked).

## Exemplar

`usage/FILED-EXAMPLE-motion-brief.pdf`: *Campbell v. Ensurety Ventures, LLC d/b/a Omega Auto Care*, No. 4:26-CV-387-LPR, "Defendant's Brief in Support of its Motion to Dismiss", 8 pages, filed 2026-06-15 by Kutak Rock LLP (Niki T. Cung). Provenance, search trail and the second-filer candidates are in `usage/SOURCE.md`.

The sample transcribes the whole brief from the text layer. The exemplar's footer carries a firm document number, which is omitted. Case names are roman in the sample: the exemplar embeds no italic font (`pdffonts` lists only Times Roman, Times Bold, Segoe UI and Calibri), so the filed copy has no italics to transcribe.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env in $HOME/tb)
D=courts/eighth-circuit/arkansas/federal/eastern-district/motion-brief
sh tools/render.sh $D usage/INPUT-motion-brief.md $D/usage/OUTPUT-campbell-motion-brief.pdf
sh tools/overlay.sh $D campbell-motion-brief $D/usage/SAMPLE-campbell-ensurety-4-26-cv-00387-motion-brief.pdf
```

The tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt`. This doc type's file names follow the brief (`<id>.pdf`, `<id>-overlay.pdf`, `<id>-overlay.txt`), so the outputs were renamed after the overlay ran. `tools/` was not edited.

The overlay is a diagnostic, not a score. Its page map pairs pages by word overlap: ours 1 to 3 with filed 1 to 3 (78%, 75%, 59%); ours 4 with filed 5 (54%); ours 5 with filed 6; ours 6 with filed 7; ours 7 with filed 8 (43%). The exemplar has no pleading line numbers and is Times, so the two layers do not coincide line by line.

## Visual review (every page rendered at 60 dpi and viewed in its final state)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption, title, opening paragraph, INTRODUCTION AND BACKGROUND, start of the introduction | OK. Caption closed by rule; case number at right. |
| 2 | Facts, I. RELEVANT PLED FACTS, the three-column table | OK. Table single-spaced, fits the text width; the heading is kept with its paragraph. |
| 3 | Facts end; II. STANDARD OF REVIEW with two quoted paragraphs; III. LAW AND ARGUMENT and A. (its first paragraph begins at the foot) | OK. Level-1 numerals and bold level-2 letters aligned. |
| 4 | B. with its paragraph; C. heading (two lines) and its first paragraph | OK. Two-line level-2 heading has a hanging indent. |
| 5 | C. body; the next paragraphs; the block quotation begins at the foot | OK. Quotation single-spaced and indented. |
| 6 | Block quotation (continued), the Warciak and Gonzales citations, the final argument paragraph | OK. Quotation ends mid-page; the page has space at its foot. |
| 7 | CONCLUSION, the conclusion paragraph, the signature block | OK after the fix. The signature block no longer stands alone: the conclusion's last paragraph moved with it to page 7. |

Earlier renders had two defects, both fixed in the template and re-viewed: paragraphs overlapped their predecessor (the paragraph gap was 8 pt, not one line), and the signature block split across pages. Neither appears in the final render.

## Engines

**typst** (primary): the section above; `usage/OUTPUT-motion-brief.typst.pdf`, 7 pages.

**docx**: `docx/make-reference.sh` builds `docx/reference.docx` (EB Garamond 12 pt; 24 pt exact double spacing; 0.5 in first-line indent on body paragraphs; headings on the same 24 pt grid: level 1 centered bold capitals, level 2 bold and level 3 bold italic with a 0.5 in hanging indent; table cells single-spaced at 11 pt with a full rule grid; block quotes single-spaced, indented 1 in each side; 1-inch margins; a centered page-number footer at 11 pt). `docx/brief.lua` adds what pandoc does not: the three-line court title, the caption table (rules at right and bottom of the party column), the centered bold title, the roman, lettered and numbered headings (I., A., 1.; a `# ~ ` heading is unnumbered), lists "(1)", and the signature block. Built with `sh tools/render.sh --engine docx <this folder> usage/INPUT-motion-brief.md`, which writes `usage/OUTPUT-motion-brief.docx`.

| Item | Result |
|---|---|
| The `.docx` opens | Checked as a zip with well-formed XML parts and read back with pandoc (text and heading numbers in order, table, block quote, signature). Not opened in Word or LibreOffice. |
| Built to the typst values | Font face and size, double spacing, margins, heading levels, table rules, caption rules, page number: set in the reference and filter as above. Not compared with the typst pages. |
| Visual review (Gate 2) | Not done. No page of the docx has been rendered or looked at. |
| BLOCKED: `docx.pdf` checks | `soffice` could not be installed in the build box (conda-forge has no `libreoffice` package on 2026-10-15), so `usage/OUTPUT-campbell-motion-brief.docx.pdf` was not produced. Gates 0 and 1 and the Gate 2 page review, which docs/DOCX.md measures on the LibreOffice PDF, cannot run. The docx is delivered without them. |
| Last paragraph with the signature | The typst template keeps the last paragraph on the signature's page. The docx does not set keep-with-next on that paragraph, so the signature can start a page alone. Not fixed: it is a placement rule, and it can only be judged on the LibreOffice PDF, which is BLOCKED. |
| Word substitution | The font is EB Garamond (vendored in `fonts/`). Word substitutes silently when the font is not installed on the machine that opens the file. |

## Known gaps and open choices

1. **Only one exemplar.** The brief asks for one per doc type; EVAL-LOOP's tier-2 rule asks for two or three filers. Tier 2 is therefore **not** judged against two filers. The natural second pick is *Leflar v. HP Inc*, No. 4:22-cv-00690, Doc. 11 (22 pages, HP's memorandum brief), noted in `usage/SOURCE.md`.
2. **Font and length.** EB Garamond (vendored, OFL) at 12 pt, the only font vendored in `fonts/`. The exemplar is Times New Roman, which sets wider than Garamond at the same size, so the render is 7 pages against the exemplar's 8. The brief's target was 8 to 14 pages; 7 is the result of the font, not of omitted text (the whole brief is transcribed). Whether the court wants a Times-metric font is a question for David.
3. **Single-spaced block quotation and table.** LR 5.5(a) says papers are filed "in double space". The exemplar's block quotation and table are single-spaced, so the template follows the exemplar. A strict reading would require double spacing for quotations; this is an open question for David (recorded as ACCEPTED by convention, not as a rule finding). The table is 11 pt, a convention choice.
4. **No certificate of service.** Rule 5(d)(1)(B) excuses it for ECF service, and the exemplar has none. A paper served on a non-ECF party would need one; the template does not generate it.
5. **Page limit.** The text of Local Rule 7.2 sets none; the template has no page counter, and the assigned judge's practices may set one. Not checked.
6. **The motion is a separate document.** Under LR 7.2(e) the motion to dismiss must be a separate pleading. This template generates only the brief. A proposed order, if the judge requires one, is also not generated.
7. **Signature mark.** The exemplar's text layer shows the signer's typed name; the template prints "/s/" before it, the ECF convention. Recorded as an interpretation.
8. **Heading format.** The exemplar's heading centering and numbering cannot be read from the text layer (bold is visible in the embedded font; centering is not). The template's choices (level 1 centered, level 2 hanging) are conventions, not transcribed from the filed copy.
9. **Italics.** Case names are roman because the exemplar has no italic font (see Exemplar). A filer's own italics would need markup in the sample.
10. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, and this doc-type folder is not that shape; `tools/` was not edited. Render and overlay were run; the page review above is the Gate 2 equivalent for this doc type.

## Current shared-model adoption status (2026-10-22)

The DOCX engine uses `docx/reference.xml` and Lua filters with the shared cross-engine layout model. The Word face is resolved from this folder's typst template. The folder has no docx shell builder/render script or binary `reference.docx`; its entry is absent from `.shell-safety-baseline.json`. The current `sh tools/check.sh` runs for typst and docx both report zero failed checks. `DEF-COVER-001` and `DEF-TOC-001` pass; the sample has no contents or authorities table. No LaTeX engine is present in this folder.

The docx check passes XENG-001..003 on every input. Older DOCX notes in this README describe the pre-adoption shell-built engine and are superseded by this status.
