# ord: motion-brief

Doc type: **motion with memorandum** (a Rule 12 motion to dismiss and the memorandum of points and authorities, one filed document) in the United States District Court for the District of Oregon (`ord`). Folder: `courts/ninth-circuit/oregon/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: complete transcription of the 11-page exemplar, plus the generated certificate of service: 11 rendered pages |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 11 pages, typst 0.15.0, vendored Times New Roman only, no warnings; docx 11 pages, the same lines and pages (XENG-001..003 gated) |
| typeface | face required: none (LR 10-1 text read 2026-10-15 names no typeface; only the 12-pt minimum). Times New Roman (vendored; the house standard, and the face of both filed exemplars), 12 pt, in both engines (fb-595.68.24; was EB Garamond 13 pt in the docx). |
| overlay | **fail** this pass: `usage/SAMPLE-*.pdf` is not in this snapshot, so `tools/overlay.sh` could not run. The `usage/OVERLAY-zoetis-rule-12-motion-to-dismiss.txt` on disk is from an earlier run; no `.pdf` is on disk. |
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
| LR 10-1(b) | Double-spaced, except counsel identification, the case title, footnotes, quotations, and exhibits. | `pitch-body = 24pt`; the block quotation, counsel, caption and signature at `pitch-single = 13.8pt` (exempt). |
| LR 10-1(c) | "Typewritten materials, including footnotes and endnotes, must use no smaller than a 12-point font." | `type-size = 12pt`, the footer too. See Known gap 5. |
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
- Body: headings at 12 pt on the 24 pt pitch: `#` centered bold capitals (LR 7-1 certification, the motion, the memorandum, FACTS ALLEGED, LEGAL STANDARD, ARGUMENT, CONCLUSION); `##` bold at the margin (I., II., …); `###` bold, indented 0.5 in. Paragraphs have a 0.5 in first-line indent and are not numbered (motions are not numbered). A markdown block quotation (`>`) is single-spaced and indented 0.5 in on each side.
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
sh tools/render.sh courts/ninth-circuit/oregon/federal/district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/ninth-circuit/oregon/federal/district/motion-brief zoetis-rule-12-motion-to-dismiss
```

File names follow the tools' defaults: `render.sh` writes `OUTPUT-<id>.pdf`; `overlay.sh` reads it and writes `OVERLAY-<id>.pdf` and `OVERLAY-<id>.txt`. The `<id>` is `zoetis-rule-12-motion-to-dismiss`.

The overlay is a diagnostic: red = our render only, blue = the filed exemplar only, black = both. The page map (`OVERLAY-zoetis-rule-12-motion-to-dismiss.txt`) pairs each sample page with the exemplar page sharing most words: ours p.1–9 ↔ filed p.1–9, ours p.10 ↔ filed p.9 (word overlap 37%: our p.10 holds the end of Argument III and the page break where the exemplar's p.10 begins), ours p.11 ↔ filed p.10, ours p.12 ↔ filed p.11. The layers do not coincide on text lines because the exemplar's margins, line spacing and footer block differ from the template's (the exemplar's footer carries the firm's address on the right; the template's does not).

## Review of the rendered pages

The Gate 2 record for both engines (every page of the current typst and docx renders, viewed side by side) is
`reviews/docx.md`.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one exemplar per doc type; the tier-2 rule in CLAUDE.md asks for two or three filers. A second counsel-filed motion with a combined memorandum is *Beckstrom v. Beckstrom*, 6:26-cv-00920-AA (8 pages, Twin Lakes Church, RECAP `gov.uscourts.ord.193990.25.0_1.pdf`), listed in `usage/SOURCE.md`. Not downloaded.
2. **TOC and TOA not generated.** LR 7-1(c) requires them for a memorandum over 20 pages. The sample is under 20, so this is not a failure today. The template does not produce them; if a longer memorandum is rendered, add them before filing.
3. **Page and word limit not counted.** LR 7-2(b)(1) (35 pages or 11,000 words) is not checked. The sample is 11 pages of memorandum.
4. **Font size.** 12 pt Times New Roman throughout (LR 10-1(c) floor; the size of both exemplars). The 13 pt body of earlier passes was chosen for EB Garamond and is gone.
5. **Footer size.** 12 pt, read as "typewritten material" under LR 10-1(c). The exemplar's footer is smaller.
6. **Footer content.** The exemplar's footer carries the filer's firm block on the right; the template's footer carries the page number and the short title only. LR 10-1(e)(1) asks for a description and a number, so this is a convention choice.
7. **Italics.** The exemplar's text layer has no italic markup; case names are roman in the sample. `*...*` italicizes if a sample uses it.
8. **Certificate of service.** The exemplar shows its service-method checkboxes as text without showing which are ticked; the sample records the one option that appears as text ("other (specify): Email (courtesy copy)"). The certificate wording is the template's form text.
9. **Footnotes.** None in the sample; not exercised. The template does not style them; a sample that uses footnotes needs a check at 12 pt minimum.
10. **Checks.** `tools/check.sh <dir> --engine typst|docx` run green (fb-595.68.24). `tools/check-selftest.sh` takes a court root (`court.json`), not this doc-type folder, so it was not run here.
11. **Signature page.** The last paragraph is kept with the signature block; at 12 pt the conclusion and the signature fit on page 10 after Argument III.

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`;
docs/EVAL-LOOP.md, "Cross-engine gate"; fb-595.68.24): Times New Roman 12 pt, every line an exact box of its pitch
(24 pt double, 13.8 pt single), the spaces between blocks given explicitly, the same break rules. `eval.yaml` sets
`params.cross_engine: gate`, so the docx must break every line and page where typst does (XENG-001..003).

**typst** (`typst/`, primary): `ord-motion-brief.typ`, rendered by `tools/render.sh`.

**docx** (`docx/`): declarative inputs only. `docx/reference.xml` holds the Word styles (`base="xengine"` in the
typst face `{font}` and the three heading levels); `docx/motion.lua` writes the cover and caption table, the body,
the signature block and the certificate of service, and hands `fb render` the footer ("Page n - TITLE", from
`footer_title`; `$FORMBOOK_FOOTERS`) and the last section (`$FORMBOOK_FINAL`). `fb render --engine docx` builds the
reference document, runs pandoc and LibreOffice and packs the archive: no shell script, no committed
`reference.docx`. Output: `usage/OUTPUT-motion-brief.docx` and `.docx.pdf`. Not verified in Word (only LibreOffice
here).

## FRCP base port assessment (fb-595.17.13)

Skipped: a shared change is needed. LR 10-1(e)(1) requires a footer on every page with a brief description of the document and the consecutive page number; the template sets "Page n - TITLE", the title from the frontmatter's `footer_title`. The base's footer (`page_number`, lib/typst/xdoc.typ, lib/latex/xdoc.lua, lib/docx/xdoc.lua and tools/fb/src/enginegen) is one line box whose `text` takes only `{page}` and `{pages}`: it cannot print a frontmatter field, and writing the description into `layout.yaml` would be case-specific text. Missing base feature: a running footer with frontmatter fields (`{footer_title}`, and for other districts `{case_name}`, `{case_number}`) beside the page number, in all three engines (the same gap as the District of Alaska's, fb-595.17.11). The rest is expressible as an overlay: one-inch margins and 12-point type (LR 10-1(c), (d)), the counsel block upper left and the court title at least an inch below it (LR 10-2(a), (b)), the caption with the case number from the page's center (LR 10-2(d), (f)), the title two lines below in capitals (LR 10-2(g)), the signature and the certificate of service. This folder does not use pleading paper (LR 10-1(d): no line numbers).

[District index](../README.md) | [Formbook index](../../../../../../README.md)
