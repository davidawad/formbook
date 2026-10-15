# ord: motion-brief

Doc type: **motion with memorandum** (a Rule 12 motion to dismiss and the memorandum of points and authorities, one filed document) in the United States District Court for the District of Oregon (`ord`). Folder: `courts/ninth-circuit/oregon/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-columbia-veterinary-zoetis-3-26-cv-01863-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-zoetis-rule-12-motion-to-dismiss.md`: complete transcription of the 11-page exemplar, plus the generated certificate of service: 12 rendered pages |
| render | ok: `samples/OUTPUT-zoetis-rule-12-motion-to-dismiss.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| typeface | face required: none (LR 10-1 text read 2026-10-15 names no typeface; only the 12-pt minimum). Vendored substitute: none needed; **EB Garamond kept** (the rule allows any proportional face). Fit: n/a. Font list unchanged in this pass. |
| overlay | **fail** this pass: `exemplars/FILED-EXAMPLE-*.pdf` is not in this snapshot, so `tools/overlay.sh` could not run. The `samples/OVERLAY-zoetis-rule-12-motion-to-dismiss.txt` on disk is from an earlier run; no `.pdf` is on disk. |
| pages reviewed | 12 of 12 this pass (every page rasterized at 60 dpi and viewed after the re-render) |
| check.sh / check-selftest.sh | not run: they expect a court root with `court.json` and `rules.md`, and this is a doc-type folder; the brief forbids touching `tools/` |

## Governing rules

Sources, fetched and read 2026-10-14:

- **LR 10-1, LR 10-2**: the District of Oregon's LR 10 text (format and caption), https://www.ord.uscourts.gov/index.php/rules-orders-and-notices/local-rules/civil-procedure/1989-lr-10-form-of-pleadings-and-other-documents, with its amendment notes (to September 3, 2024).
- **LR 7-1, LR 7-2**: the District's LR 7 text (motions practice), https://ord.uscourts.gov/index.php/rules-orders-and-notices/local-rules/civil-procedure/1987-lr-07-motions-practice. The LR 7-2 page limit is confirmed by a third-party mirror (https://www.courtrules.net/courts/federal/district-oregon/local-rules/26289); the official page says the same.
- **Caveat**: the court's Local Rules index (https://www.ord.uscourts.gov/index.php/rules-orders-and-notices/local-rules) lists the civil rules by top-level number (LR 7, LR 10) and says changes have an expected effective date of December 1, 2026. The subsection numbers below come from the pages above and have **not** been checked against a codified 2026 text. Confirm before the template is called final.

| Rule | Requirement (as quoted or paraphrased) | Where it lives in the template |
|---|---|---|
| LR 10-1(a) | Typewritten or legibly reproduced, blue or black ink. | Black type on white paper. |
| LR 10-1(b) | Double-spaced, except counsel identification, the case title, footnotes, quotations, and exhibits. | `pitch = 24pt`; body paragraphs at 24 pt; the block quotation is single-spaced (an exempt quotation). |
| LR 10-1(c) | "Typewritten materials, including footnotes and endnotes, must use no smaller than a 12-point font." | `type-size = 13pt` (body); `footer-size = 12pt`. See Known gaps 4 and 5. |
| LR 10-1(d) | One-inch margins on all four sides; no page numbers down the left margin. | `margin = 1in`; no line numbers. |
| LR 10-1(e)(1) | Footer with a brief description of the document and consecutive page numbers at the bottom. | `footer-block`: "Page n - TITLE" (from `footer_title`). |
| LR 10-2(a) | Counsel information in the upper left corner of the first page, starting one inch from the top. | `counsel-block`, from frontmatter `counsel`. |
| LR 10-2(b) | Court title double-spaced, capitalized, centered at least one inch below the counsel information. | `counsel-block` reserves at least 1 in below the counsel lines; `court-title` at pitch, centered, upper case. |
| LR 10-2(d) | Party names single-spaced along the left margin below the court title. | `caption`, left column, single-spaced. |
| LR 10-2(f) | Case number starting at the center of the page, on the same line as the first named plaintiff, with the division code under LR 3-2. | `caption`: right column starts at the page center (`caption-split`); "Case No. …" on the first line. |
| LR 10-2(g) | Document title at least two lines below the case number, single-spaced and capitalized. | `caption`: `v(pitch)`, title in upper case, single-spaced. |
| LR 7-1(a)(1)(A) | "Except for motions for temporary restraining orders, the first paragraph of every motion must certify" the good-faith conferral. | Not enforced: the sample's first paragraph is the certification, transcribed from the exemplar ("LR 7-1 CERTIFICATION"). |
| LR 7-1(c) | Motion and legal memorandum combined in one document; a memorandum "exceeding 20 pages must have a table of contents and a table of cases and authorities with page references." | Combined in one document. **Table of contents and table of authorities are not generated.** The sample is 11 pages of memorandum, under 20, so not required; see Known gaps 2. |
| LR 7-2(b)(1) | Without prior court approval, memoranda "may not exceed 11,000 words, or in the alternative, 35 pages." | Not counted. See Known gaps 3. |
| LR 7-2(b)(2) | If the memorandum exceeds the page limit, a word-count certificate stating the number of words (headings, footnotes and quotations included; caption, tables, signature block, exhibits and certificates excluded). | Not generated (the sample is under the page limit). |
| Fed. R. Civ. P. 12(b)(6) | The motion's ground, cited in the title and motion paragraph (author's text). | Not checked by the template. |

Not produced by this template (separate filings, not part of the motion): the proposed order, any declarations or exhibits, and the notice of hearing if the court requires one.

## Layout

- Top and bottom margins one inch; body text in 24 pt lines; 27 lines per page.
- Cover (page 1): counsel block upper left; court title; caption with the case number at the page center; title two lines below in capitals; the legend (for example "(Oral Argument Requested)") under the title. Page 1 holds the cover only; the body starts on page 2.
- Body: `#` headings centered bold capitals (LR 7-1 certification, the motion, the memorandum, FACTS ALLEGED, LEGAL STANDARD, ARGUMENT, CONCLUSION); `##` headings bold (I., II., …); `###` headings bold, indented. Paragraphs have a 0.5 in first-line indent and are not numbered (motions are not numbered). A markdown block quotation (`>`) is single-spaced and indented 0.5 in on each side.
- Headings stay with the paragraph after them. A paragraph may break across pages.
- The last paragraph of the memorandum stays on one page with the signature block (so the signature is not left alone on a page).
- Signature block: "DATED:" date on the left; firm, "By: /s/" signer, bar numbers and addresses on the right.
- Certificate of service (generated from frontmatter `certificate_of_service`, on its own page): the form wording, the served party, the method, and the signature. The wording "under the laws of the State of Oregon" is the form text for an Oregon certificate, not case-specific text.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Quote any frontmatter value containing a colon or `#` (for example `"Telephone: (503) 222-9981"`); YAML otherwise reads it as a mapping.
- Frontmatter fields: `court` (list of lines), `division`, `counsel` (lines; an empty string gives a blank line), `caption.parties` (list of `{names, designation}`; "vs." is inserted between parties), `case_number`, `brief_title`, `legend` (optional), `footer_title`, `date`, `signature` (`firm` list, `signer`, `lines`), `certificate_of_service` (`date`, `served` list, `method`).
- Body: blank-line-separated chunks. `#` heading, `##` heading, `###` heading; `>` quotation; any other chunk is a paragraph. Do not type paragraph or section numbers the template does not add (the sub-headings carry the author's own "I.", "A." labels).

## Render and overlay

Run from the repo root (`export PATH="$HOME/tb/bin:$PATH"` first):

```sh
sh tools/render.sh courts/ninth-circuit/oregon/federal/district/motion-brief samples/INPUT-zoetis-rule-12-motion-to-dismiss.md
sh tools/overlay.sh courts/ninth-circuit/oregon/federal/district/motion-brief zoetis-rule-12-motion-to-dismiss
```

File names follow the tools' defaults: `render.sh` writes `OUTPUT-<id>.pdf`; `overlay.sh` reads it and writes `OVERLAY-<id>.pdf` and `OVERLAY-<id>.txt`. The `<id>` is `zoetis-rule-12-motion-to-dismiss`.

The overlay is a diagnostic: red = our render only, blue = the filed exemplar only, black = both. The page map (`OVERLAY-zoetis-rule-12-motion-to-dismiss.txt`) pairs each sample page with the exemplar page sharing most words: ours p.1–9 ↔ filed p.1–9, ours p.10 ↔ filed p.9 (word overlap 37%: our p.10 holds the end of Argument III and the page break where the exemplar's p.10 begins), ours p.11 ↔ filed p.10, ours p.12 ↔ filed p.11. The layers do not coincide on text lines because the exemplar's margins, line spacing and footer block differ from the template's (the exemplar's footer carries the firm's address on the right; the template's does not).

## Review of the rendered pages (Gate 2 record, all 12 pages, rendered at 60 dpi and viewed)

| Page | Content | Finding |
|---|---|---|
| 1 | Cover: counsel block (two firms), court title, caption, case number at the page center, title in capitals, legend; footer "Page 1 - …" | OK. |
| 2 | LR 7-1 certification; the motion; the start of the memorandum and its introduction | OK. Headings centered and bold; paragraphs double-spaced with indents. |
| 3 | Introduction (end) and FACTS ALLEGED | OK. |
| 4 | Facts (end); LEGAL STANDARD | OK. Paragraphs no longer overlap (fixed: each paragraph block now adds one leading below, so N lines fill N×24 pt). |
| 5 | ARGUMENT; I. heading; argument text | OK. |
| 6 | Block quotation (single-spaced, indented) with its citation; "Here, neither prong…"; the start of II | OK. |
| 7 | II. text; A. heading | OK. |
| 8 | A. text; B. heading (two lines, bold) | OK. |
| 9 | B. text; C. heading with text | OK. |
| 10 | C. text; III. heading with its paragraph. The CONCLUSION heading and paragraph moved to page 11 with the signature, leaving about a third of the page blank | Accepted: the conclusion and signature stay together. |
| 11 | CONCLUSION; signature block (both firms; "By: /s/" for the lead signer); "Attorneys for Defendant Zoetis, Inc." | OK. The signature was alone on a page before the tail change; fixed. |
| 12 | CERTIFICATE OF SERVICE on its own page: the form wording, the served party, the method ("other (specify): Email (courtesy copy)"), signature | OK. |

## Known gaps and open choices

1. **One exemplar.** The brief asks for one exemplar per doc type; the tier-2 rule in CLAUDE.md asks for two or three filers. A second counsel-filed motion with a combined memorandum is *Beckstrom v. Beckstrom*, 6:26-cv-00920-AA (8 pages, Twin Lakes Church, RECAP `gov.uscourts.ord.193990.25.0_1.pdf`), listed in `exemplars/SOURCE.md`. Not downloaded.
2. **TOC and TOA not generated.** LR 7-1(c) requires them for a memorandum over 20 pages. The sample is under 20, so this is not a failure today. The template does not produce them; if a longer memorandum is rendered, add them before filing.
3. **Page and word limit not counted.** LR 7-2(b)(1) (35 pages or 11,000 words) is not checked. The sample is 11 pages of memorandum.
4. **Font size.** LR 10-1(c) sets 12 pt as the floor. The template uses 13 pt body text because EB Garamond (the only vendored serif) sets smaller than Times New Roman at the same size. A choice, flagged for David.
5. **Footer size.** 12 pt, read as "typewritten material" under LR 10-1(c). The exemplar's footer is smaller.
6. **Footer content.** The exemplar's footer carries the filer's firm block on the right; the template's footer carries the page number and the short title only. LR 10-1(e)(1) asks for a description and a number, so this is a convention choice.
7. **Italics.** The exemplar's text layer has no italic markup; case names are roman in the sample. `*...*` italicizes if a sample uses it.
8. **Certificate of service.** The exemplar shows its service-method checkboxes as text without showing which are ticked; the sample records the one option that appears as text ("other (specify): Email (courtesy copy)"). The certificate wording is the template's form text.
9. **Footnotes.** None in the sample; not exercised. The template does not style them; a sample that uses footnotes needs a check at 12 pt minimum.
10. **Not run.** `tools/check.sh` and `tools/check-selftest.sh` (as in the CAND note). Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.
11. **Page 10 blank space.** The conclusion and signature are kept together, so page 10 ends after the III. paragraph with about a third of the page blank. Accepted for now (the alternative is a signature page with one line of text).

## Engines

**docx** (`docx/`): `sh docx/build-reference.sh docx/reference.docx` builds the reference; `docx/motion.lua` writes the cover (counsel, court title, caption table with the legend), the body, the signature block and the certificate of service; `docx/render.sh` (run by `tools/render-docx.sh`) puts the footer title in the footer. Output: `samples/OUTPUT-zoetis-rule-12-motion-to-dismiss.docx` and `.docx.pdf` (LibreOffice 26.8), 12 pages, all 12 rendered at 60 dpi and viewed (`reviews/docx.md`). The typst output is also 12 pages.

- Matches the typst output: letter; one inch on all four sides; EB Garamond 13 pt (embedded in the PDF); double spacing as an exact 24 pt line and single spacing as an exact 13 pt line; counsel block; court title; caption with the case number at the page center and the legend under the title; headings at typst's default sizes (level 1 18 pt centered, level 2 15.5 pt bold and left, level 3 13 pt bold and indented); block quotations single-spaced and indented; footer "Page n - TITLE" at 12 pt; the last paragraph kept with the signature; certificate of service on its own page.
- Differs from typst: the docx is built from the markdown with Word styles, so line breaks in the signature column and the page breaks follow LibreOffice (Word may move a line); the signature's phone line wraps at the same place as typst. No tables of contents or authorities (as typst).
- Fonts: the PDF is correct only when LibreOffice sees the vendored `fonts/` and no substitute face. This box has no system EB Garamond, so run the render with a `FONTCONFIG_FILE` that lists only the repo's `fonts/` directory.
- Not verified in Word (only LibreOffice here). The `.docx` is a valid zip of well-formed XML (checked by `render-docx.sh`) and converts in LibreOffice without error; no GUI repair prompt was observed (headless).

BLOCKED: check.sh (Gates 0 to 3, docx): `tools/check.sh` reads `<court-dir>/court.json` and `checks.yaml`, and this doc-type folder has neither (it exits 2 before any gate runs), so the gates did not run and `samples/.check-docx.txt` was not written. The Gate 2 record for the docx is `reviews/docx.md`.

[District index](../README.md) | [Formbook index](../../../../../../README.md)
