# idd: motion-brief

Doc type: **motion-brief**, a memorandum in support of a motion to dismiss under FRCP 12(b)(6) (with the FRCP 9(b) argument), in the United States District Court for the District of Idaho (`idd`). Dist. Idaho Loc. Civ. R. 7.1(a)(2) caps a memorandum at twenty pages; 7.1(b)(1) requires it to be a separate brief.
Folder: `courts/ninth-circuit/idaho/federal/district/motion-brief/` (self-contained; the court-root `typst/` and `usage/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: three filings, `usage/FILED-EXAMPLE-motion-brief.pdf` (primary; transcribed and used for the overlay), `…-anderson-2-24-cv-00341-motion-brief.pdf`, `…-robinson-1-24-cv-00306-motion-brief.pdf`. See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md` (the full text of the 14-page memorandum, with its footnotes, headings and signature; the certificate of service is in frontmatter; see Known gaps) |
| typeface | face required: none (LR 5.2(a) sets only a 12-point minimum; LR 7.1(a)(2) names no face; checked on the Court's site 2026-10-15). Substitute: none needed; EB Garamond kept. Fit: n/a. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 11 pages, letter, typst 0.15.0, `pdffonts`: EB Garamond Regular and Bold embedded only, no warnings |
| overlay | fail: `tools/overlay.sh` needs the filed exemplar PDF (`usage/SAMPLE-tarbell-group-…pdf`), which is not in this snapshot (`usage/` holds only `SOURCE.md`). The `.txt` page map is from the earlier run and is stale against this render; regenerate once the exemplar is restored. |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed on the 2026-10-15 re-render; no template change since the last review) |

## Commands

```
sh tools/render.sh courts/ninth-circuit/idaho/federal/district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/ninth-circuit/idaho/federal/district/motion-brief tarbell-motion-brief \
  courts/ninth-circuit/idaho/federal/district/motion-brief/usage/FILED-EXAMPLE-motion-brief.pdf
```

File names follow the tools, not the brief's shorthand: `tools/render.sh` writes `usage/OUTPUT-<id>.pdf` and `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf` and `.txt`. The sample is `INPUT-<id>.md` and the id is `tarbell-motion-brief`. `tools/` is not edited.

## Governing rules

Primary source: the District of Idaho's Local Civil Rules, the print packet from https://idd.uscourts.gov/district/forms_fees_rules/Civil_Rules.cfm?lni=214 (the packet's cover reads "Revised and adopted August 17, 2026"; General Order No. 479, adopted August 17, 2026, amended Rules 9.1, 9.2, 16.4 and 37.1, none of them the form rules below). Fetched 2026-10-14. Rule text quoted from that packet. The civil rules in the packet say nothing about the typeface of a memorandum beyond LR 5.2(a).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Dist. Idaho Loc. Civ. R. 7.1(a)(2) | "No memorandum of points and authorities in support of or in opposition to a motion may exceed twenty (20) pages in length … The use of small fonts and/or minimal spacing to comply with the page limitation is not acceptable." | The template sets 12 pt type and double spacing with no shrink option. The 20-page cap is not enforced by the template (see Known gaps). |
| Dist. Idaho Loc. Civ. R. 7.1(a)(3) | Documents "in support of … other documents must be clearly labeled with the docket number of the motion in the caption." | `motion_docket` frontmatter: the caption shows "[Doc. 26]" under the title. |
| Dist. Idaho Loc. Civ. R. 7.1(b)(1) | "Each motion … must be accompanied by a separate brief … containing all of the reasons and points and authorities relied upon by the moving party." | Output is a stand-alone memorandum with its own caption; the title says "MEMORANDUM IN SUPPORT OF MOTION TO DISMISS". |
| Dist. Idaho Loc. Civ. R. 5.2(a) | 8½ × 11; "double-spaced, except for quoted material and footnotes"; "Each page must be numbered consecutively"; margins "at least one inch"; "the font or typeface for all text, including footnotes, must be at least 12 point." | `page-w`/`page-h`, `margin = 1in`, `type-size = 12pt` (footer and footnotes included), `body-leading` (24 pt pitch), footnotes single-spaced, footer `N - TITLE`. |
| Dist. Idaho Loc. Civ. R. 5.2(b) | Upper-left counsel block; the caption "commencing four inches below the top of the first page, (except where additional space is required for identification)". | `counsel` frontmatter; `cover()` starts the caption at `caption-top = 4in` or directly after a longer counsel block. |
| Dist. Idaho Loc. Civ. R. 5.2(b)(1)–(3), (5) | The court title; the title of the action; the CM/ECF file number; the title of the paper. | `caption.court`, `caption.parties`, `case_number` (`1:25-cv-00144-DCN`), `brief_title`. |

Not produced by this template: a table of contents or table of authorities (none of the rules fetched requires one for a memorandum of twenty pages or fewer; the exemplar has none); the proposed order; the certificate of compliance (not in the fetched rules). The memorandum does not carry line numbers (the rules do not require them).

## Layout

- Counsel block single-spaced in the upper left, from the top margin.
- Court title and caption at four inches from the top, or directly after the counsel block when it is longer (the exemplar's two counsel groups are long, so the caption sits at about 4.3 inches; the rule's exception applies).
- Caption: party column closed by a right and bottom rule; the right column carries the file number, the title and the "[Doc. N]" docket line.
- Body double-spaced at a 24 pt baseline pitch. Body paragraphs are unnumbered and indented 0.5 inch on the first line (the indent is inline, because typst does not indent a paragraph that follows a block such as a list or the caption).
- Headings: level 1 centered bold caps (INTRODUCTION, BACKGROUND, ARGUMENT, CONCLUSION); level 2 centered bold; level 3 bold, left (the argument headings "I.", "II.", "III."). Each fills whole double-spaced slots, so the paragraph after it starts on the grid.
- Footnotes: `[^n]` references in paragraphs and bullet items become typst footnotes at 12 pt, single-spaced, with a short rule above them. The definitions are `[^n]: text` chunks in the sample.
- Bulleted lists: a `•` marker, items double-spaced, indented 0.5 inch.
- Section break `\* \* \*` is centered.
- Signature block: "Dated: …" at left, "Respectfully submitted," the firm, "/s/" and the signer, with the lines from the frontmatter.
- Certificate of service: its own page (the exemplar does the same), heading, the certificate text, and the filer's signature block at the right-hand column.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body chunks are separated by blank lines: a `#` heading, a bullet list (`-`), a footnote definition (`[^n]: text`), `\* \* \*`, or a paragraph.
- Frontmatter fields: `case_number`, `motion_docket` (for example `Doc. 26`; shown as `[Doc. 26]`), `counsel` (lines; an empty string is a line-high gap), `caption.court` (lines), `caption.parties` (list of `{names, designation}`), `brief_title`, `footer_title`, `date`, `signature` (`firm`, `signer`, `lines`), `certificate` (`date`, `text`, `signer`, `lines`; omit for no certificate).
- Not supported: tables, numbered paragraphs (memoranda are unnumbered), footnote references inside headings, raw typst.

## What the overlay shows

`usage/OVERLAY-tarbell-motion-brief.pdf`: red is our render, blue is the filed exemplar, black is agreement. The page map (`.txt`) pairs each of our pages with the exemplar page sharing the most words:

```
ours p.1  filed p.1  word-overlap 63.4%
ours p.2  filed p.2  word-overlap 55.4%
ours p.3  filed p.3  word-overlap 41.9%
ours p.4  filed p.5  word-overlap 52.6%
ours p.5  filed p.6  word-overlap 56.4%
ours p.6  filed p.7  word-overlap 79.8%
ours p.7  filed p.8  word-overlap 64.9%
ours p.8  filed p.10  word-overlap 71.1%
ours p.9  filed p.12  word-overlap 50.0%
ours p.10  filed p.13  word-overlap 47.5%
ours p.11  filed p.14  word-overlap 84.3%
```

The pairs are close but not aligned page for page: our render is 11 pages and the exemplar is 14, so the same text falls on different pages. The overlay is a diagnostic, not a score. It was regenerated after the last template change.

## Page review (Gate 2 equivalent)

Every page of `OUTPUT-motion-brief.typst.pdf` was rendered at 60 dpi and viewed after the last template change.

| Page | Result |
|---|---|
| 1 | Counsel block; court title; caption with the file number and "DEFENDANT'S MEMORANDUM IN SUPPORT OF MOTION TO DISMISS [Doc. 26]"; the first paragraph with footnote 1; INTRODUCTION. Footer "1 - …". Pass. |
| 2 | Introduction text; footnote 2 (the list of members). Pass. |
| 3 | Introduction end; BACKGROUND; first bullets; footnote 3. Pass. |
| 4 | Bullets (¶ 13 to ¶ 15); paragraph after the bullets indented (defect found and fixed: the first paragraph after a block lost its indent); LEGAL STANDARDS. Pass. |
| 5 | Legal standards end; ARGUMENT; heading I; footnote 4. Pass. |
| 6 | Bullets (Doc. 56-1 parts); heading II; footnote 5. Pass. |
| 7 | Section II text; footnote 6; the audit bullets' lead-in; the bracketed note on the omitted block quotation (see Known gaps). Pass. |
| 8 | Audit bullets; the original-source paragraphs. Pass. |
| 9 | Original-source paragraph end; the section break; heading III; footnote 7. Pass. |
| 10 | Section III text; CONCLUSION; "Dated: June 9, 2026"; "Respectfully submitted," and the signature block ("/s/ Julian R. Ellis, Jr." then the lines). Pass (defect found and fixed: the signer's name printed twice). |
| 11 | CERTIFICATE OF SERVICE on its own page; the certificate text; the right-hand signature block. Pass (defect found and fixed: the signature block was right-aligned and wrapped). |

## Tier-2 findings (against the three filed exemplars, by page)

| Page | Finding | Status |
|---|---|---|
| 1 | The exemplars are set in Times New Roman (Robinson, Tarazona, Wilcox and, with a Times-style face, Anderson) or Century Schoolbook (Tarbell, which the rule names as an example). EB Garamond reads smaller than either at 12 pt. The 12-point minimum in LR 5.2(a) is met. The only vendored font is EB Garamond (`fonts/`). | OPEN (font choice for David; see Known gaps). |
| 1 | The caption's party column is closed by a rule (the Robinson and Anderson filings, checked on page 1, use the same closed box). | ACCEPTED. |
| 2 | Anderson (18 pages) has a TABLE OF CONTENTS on page 2 with dot leaders. Tarbell (14 pages) has none in its full text. Robinson's page 1 has none; its inner pages were not checked. The template does not produce a contents page. The fetched rules do not require one. | OPEN (whether a contents page is expected for a 20-page memorandum is a question for David; the template would need a contents page built from the headings). |
| 11 | The certificate of service is on its own page, as in the Tarbell exemplar (page 14). | ACCEPTED. |

## Known gaps and open choices

1. **Font (rule-level answer; visual difference remains).** LR 5.2(a) and LR 7.1(a)(2) name no typeface, so the template keeps EB Garamond, per `docs/FONTS.md`. EB Garamond at 12 pt meets the rule's point size, but it looks smaller than the Times and Century exemplars. Those exemplars are a convention, not a requirement; switching to a Times or Century substitute would be a tier-2 choice for David.
2. **Block quotation omitted from the transcription.** The Tarbell exemplar quotes the audit's Note N in a block quotation on page 9. The quotation is not in the text layer of the PDF, so the sample carries a bracketed note in its place (`[Block quotation from Note N of the audit is not in the text layer of the filing and is not transcribed.]`). The template does not produce that quotation; the note is in the sample, not the template.
3. **20-page cap not enforced.** LR 7.1(a)(2) caps the memorandum at twenty pages. The template does not count pages or warn; the sample is 11 pages.
4. **Footnotes.** Footnote references work in paragraphs and bullet items. They do not work inside headings or block quotations (none used). Footnote text supports the same markdown as the body.
5. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, and this doc-type folder does not have that shape. The brief forbids touching `tools/`, so the gates were not run; the render, the overlay and the review above are the checks.
6. **Footers** are 12 pt, the same size as the text, to satisfy "all text" in LR 5.2(a).
7. **Caption position.** The caption starts at four inches when the counsel block is short enough; with two long counsel groups it sits lower (the rule's exception).
8. **Second and third exemplars** (Anderson, Robinson) are saved and checked on page 1 only; their text is not used in the sample.

## Engines

Docx engine (`docx/`): `make-reference.sh` builds `docx/reference.docx` (run once; it unpacks in a temp dir), `idd.lua` writes the cover, the signature block and the certificate of service. Output: `usage/OUTPUT-motion-brief.docx`.

What the docx sets (in styles.xml, sectPr and footer1.xml; set, not rendered: no LibreOffice on the build box):
- Page: US Letter, 1 inch margins, footer 0.4 inch from the bottom edge.
- Font: EB Garamond 12 pt everywhere, footer page number included.
- Body: exact 24 pt line (double), first-line indent 0.5 inch, no space before or after. Headings: exact 24 pt, bold; level 1 centered caps, level 2 centered bold, level 3 bold left; keep with next.
- Cover: counsel single-spaced; court title bold, centered; caption as a borderless table whose left cell is ruled on the right and bottom; case number, title and the "[Doc. 26]" docket line in the right cell.
- Footnotes: native footnotes, 12 pt, single-spaced.
- Signature: "Dated:" and "Respectfully submitted," in a borderless two-column table.
- Certificate of service: starts on a new page (page break), heading in the Heading 1 style, text double-spaced, signature in the right column.

What differs from the typst form:
- Footer: page number only, left-aligned. The typst footer "N - TITLE" needs the case title, which is case-specific, so it is not in the template. Tier 2, OPEN.
- Caption position and caption rule: as for the complaint; the 4-inch caption position is approximate and not measured.
- Body: pandoc's paragraphs; no numbering (the memorandum has none).

BLOCKED (docx.pdf gates 0 to 3): `tools/render-docx.sh` writes the `.docx`, then fails at `soffice` because LibreOffice is not installed on the build box. No docx page was rendered or looked at: pages reviewed for docx = 0. The `.docx` was checked only as a valid zip with well-formed XML parts (xmllint); it was not opened in Word or LibreOffice.
