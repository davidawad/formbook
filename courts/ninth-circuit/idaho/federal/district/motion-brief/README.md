# idd: motion-brief

Doc type: **motion-brief**, a memorandum in support of a motion to dismiss under FRCP 12(b)(6) (with the FRCP 9(b) argument), in the United States District Court for the District of Idaho (`idd`). Dist. Idaho Loc. Civ. R. 7.1(a)(2) caps a memorandum at twenty pages; 7.1(b)(1) requires it to be a separate brief.
Folder: `courts/ninth-circuit/idaho/federal/district/motion-brief/` (self-contained; the court-root `typst/` and `usage/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: three filings, `usage/FILED-EXAMPLE-motion-brief.pdf` (primary; transcribed and used for the overlay), `…-anderson-2-24-cv-00341-motion-brief.pdf`, `…-robinson-1-24-cv-00306-motion-brief.pdf`. See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md` (the full text of the 14-page memorandum, with its footnotes, headings and signature; the certificate of service is in frontmatter; see Known gaps) |
| typeface | face required: none (LR 5.2(a) sets only a 12-point minimum, footnotes and footer included; LR 7.1(a)(2) names no face; checked on the Court's site 2026-10-15). Times New Roman 12 pt, the house standard (`docs/FONTS.md`), as the Robinson and Anderson exemplars (Tarbell is set in Century Schoolbook, one filer's choice); typst names `("Times New Roman", "Liberation Serif")`, the docx the same face through `{font}`. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` and `usage/OUTPUT-motion-brief.docx` / `.docx.pdf`, 14 pages each (13 and the certificate of service), letter, Times New Roman Regular and Bold embedded only, no warnings |
| overlay | diagnostic only, not committed: `just overlay` writes `.overlay/<doc path>/OVERLAY-<id>.pdf` from `usage/FILED-EXAMPLE-<id>.pdf` (not re-run for the cross-engine port) |
| pages reviewed | 14 of 14 on both engines (typst and docx.pdf, every page at 60 dpi, side by side, 2026-10-22, after the cross-engine port) |

## Commands

```
sh tools/render.sh courts/ninth-circuit/idaho/federal/district/motion-brief usage/INPUT-motion-brief.md
sh tools/render.sh --engine docx courts/ninth-circuit/idaho/federal/district/motion-brief usage/INPUT-motion-brief.md
sh tools/check.sh courts/ninth-circuit/idaho/federal/district/motion-brief [--engine docx]
just overlay courts/ninth-circuit/idaho/federal/district/motion-brief
```

## Governing rules

Primary source: the District of Idaho's Local Civil Rules, the print packet from https://idd.uscourts.gov/district/forms_fees_rules/Civil_Rules.cfm?lni=214 (the packet's cover reads "Revised and adopted August 17, 2026"; General Order No. 479, adopted August 17, 2026, amended Rules 9.1, 9.2, 16.4 and 37.1, none of them the form rules below). Fetched 2026-10-14. Rule text quoted from that packet. The civil rules in the packet say nothing about the typeface of a memorandum beyond LR 5.2(a).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Dist. Idaho Loc. Civ. R. 7.1(a)(2) | "No memorandum of points and authorities in support of or in opposition to a motion may exceed twenty (20) pages in length … The use of small fonts and/or minimal spacing to comply with the page limitation is not acceptable." | The template sets 12 pt type and double spacing with no shrink option. The 20-page cap is not enforced by the template (see Known gaps). |
| Dist. Idaho Loc. Civ. R. 7.1(a)(3) | Documents "in support of … other documents must be clearly labeled with the docket number of the motion in the caption." | `motion_docket` frontmatter: the caption shows "[Doc. 26]" under the title. |
| Dist. Idaho Loc. Civ. R. 7.1(b)(1) | "Each motion … must be accompanied by a separate brief … containing all of the reasons and points and authorities relied upon by the moving party." | Output is a stand-alone memorandum with its own caption; the title says "MEMORANDUM IN SUPPORT OF MOTION TO DISMISS". |
| Dist. Idaho Loc. Civ. R. 5.2(a) | 8½ × 11; "double-spaced, except for quoted material and footnotes"; "Each page must be numbered consecutively"; margins "at least one inch"; "the font or typeface for all text, including footnotes, must be at least 12 point." | `margin = 1in`, `type-size = 12pt` (footer and footnotes included), `pitch-double` (27.6 pt, Word double spacing of 12 pt Times New Roman, as the exemplars), footnotes single-spaced (13.8 pt lines), footer `N - TITLE`. |
| Dist. Idaho Loc. Civ. R. 5.2(b) | Upper-left counsel block; the caption "commencing four inches below the top of the first page, (except where additional space is required for identification)". | `counsel` frontmatter; `cover()` starts the caption at `caption-top = 4in` or directly after a longer counsel block. |
| Dist. Idaho Loc. Civ. R. 5.2(b)(1)–(3), (5) | The court title; the title of the action; the CM/ECF file number; the title of the paper. | `caption.court`, `caption.parties`, `case_number` (`1:25-cv-00144-DCN`), `brief_title`. |

Not produced by this template: a table of contents or table of authorities (none of the rules fetched requires one for a memorandum of twenty pages or fewer; the exemplar has none); the proposed order; the certificate of compliance (not in the fetched rules). The memorandum does not carry line numbers (the rules do not require them).

## Layout

All of it on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box of its pitch, first-fit ragged-right breaking, no kerning, ligatures or hyphenation, so the docx breaks every line and page where typst does.

- Counsel block single-spaced (13.8 pt lines) in the upper left, from the top margin.
- Court title (bold, centered) and caption at four inches from the top, or 12 pt below the counsel block when it is longer (the exemplar's two counsel groups are long, so the caption sits lower; the rule's exception applies). The docx holds the counsel block in a table row at least 3 in high, with 12 pt after its last line.
- Caption: party column 3.25 in, closed by a right and bottom rule; the right column carries the file number, the title and the "[Doc. N]" docket line, a blank single line apart.
- Body double-spaced at a 27.6 pt pitch, no space between paragraphs. Body paragraphs are unnumbered and indented 0.5 in on the first line, after a heading or a list too.
- Headings on the body pitch, kept with the text after them: level 1 centered bold caps (INTRODUCTION, BACKGROUND, ARGUMENT, CONCLUSION); level 2 centered bold; level 3 bold with a 0.5 in hanging indent (the argument headings "I.", "II.", "III.").
- Footnotes: `[^n]` references in paragraphs and bullet items become footnotes at 12 pt (LR 5.2(a)), single-spaced (13.8 pt lines), 7 pt apart, under a 2 in rule; the mark stands against the word before it.
- Bulleted lists: a `•` at 0.5 in in a 0.5 in box, the text hanging at 1 in, double-spaced.
- Section break `\* \* \*` is centered on its own line.
- Signature block: "Dated: …" at left, "Respectfully submitted," the firm, "/s/" and the signer, with the lines from the frontmatter; one block that never breaks.
- Certificate of service: its own page (the exemplar does the same), heading, the certificate text, and the filer's signature block at the right-hand column.
- Footer: "N - TITLE" (the page number and `footer_title` in capitals), 12 pt, flush left, on every page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body chunks are separated by blank lines: a `#` heading, a bullet list (`-`), a footnote definition (`[^n]: text`), `\* \* \*`, or a paragraph.
- Frontmatter fields: `case_number`, `motion_docket` (for example `Doc. 26`; shown as `[Doc. 26]`), `counsel` (lines; an empty string is a line-high gap), `caption.court` (lines), `caption.parties` (list of `{names, designation}`), `brief_title`, `footer_title`, `date`, `signature` (`firm`, `signer`, `lines`), `certificate` (`date`, `text`, `signer`, `lines`; omit for no certificate).
- Not supported: tables, numbered paragraphs (memoranda are unnumbered), footnote references inside headings, raw typst.

## What the overlay shows

The page map that stood here was from the earlier 11-page render (EB Garamond, 24 pt pitch), before the cross-engine port; `just overlay` regenerates it in `.overlay/` (not committed). Our render is 14 pages, as the Tarbell exemplar, but the same text need not fall on the same page. The overlay is a diagnostic, not a score.

## Page review (Gate 2 equivalent)

Every page of `OUTPUT-motion-brief.typst.pdf` and `OUTPUT-motion-brief.docx.pdf` was rendered at 60 dpi and viewed side by side after the last template change (2026-10-22). The two engines break every line and page alike (XENG-001..003 PASS, 328/328 lines).

| Page | Result (typst and docx) |
|---|---|
| 1 | Counsel block (two groups); court title; caption with the file number, "DEFENDANT'S MEMORANDUM IN SUPPORT OF MOTION TO DISMISS" and "[Doc. 26]"; the first paragraph with footnote 1; INTRODUCTION. Footer "1 - …". Pass. |
| 2 | Introduction text; footnote 2 (the list of members). Pass. |
| 3 | Introduction paragraphs (the CARES Act, the amendments, Relator). Pass. |
| 4 | Introduction end; BACKGROUND; bullets ¶¶6–8 to ¶14; footnote 3 from the ¶10 bullet. Pass. |
| 5 | Bullet ¶15; two paragraphs; LEGAL STANDARDS. Pass. |
| 6 | Legal standards; ARGUMENT; heading I. Pass. |
| 7 | Section I with its bullets (Doc. 56-1 parts); heading II; footnotes 4 and 5. Pass. |
| 8 | Section II text (the audit prong, the Single Audit Act). Pass. |
| 9 | The Clearinghouse URL (broken where typst breaks a web address); footnote 6; the audit bullets begin. Pass. |
| 10 | Audit bullets end; the Kootstra paragraph; the original-source definition. Pass. |
| 11 | "First" and "Second" paragraphs; the centered section break; "At bottom". Pass. |
| 12 | Heading III; footnote 7. Pass. |
| 13 | Section III end; CONCLUSION; "Dated: June 9, 2026" beside the signature block. Pass. |
| 14 | CERTIFICATE OF SERVICE on its own page; the certificate text; the right-hand signature block. Pass. |

## Tier-2 findings (against the three filed exemplars, by page)

| Page | Finding | Status |
|---|---|---|
| all | Times New Roman 12 pt, double-spaced at 27.6 pt, as the Robinson and Anderson exemplars (27.4 to 27.6 pt measured on their body pages); Tarbell is set in Century Schoolbook at a 24 pt pitch, one filer's style (tier 3). | ACCEPTED. |
| 1 | The caption's party column is closed by a rule (the Robinson and Anderson filings, checked on page 1, use the same closed box). | ACCEPTED. |
| 2 | Anderson (18 pages) has a TABLE OF CONTENTS on page 2 with dot leaders. Tarbell (14 pages) has none in its full text. Robinson's page 1 has none; its inner pages were not checked. The template does not produce a contents page. The fetched rules do not require one. | OPEN (whether a contents page is expected for a 20-page memorandum is a question for David; the template would need a contents page built from the headings). |
| 14 | The certificate of service is on its own page, as in the Tarbell exemplar (page 14). | ACCEPTED. |

## Known gaps and open choices

1. **Block quotation omitted from the transcription.** The Tarbell exemplar quotes the audit's Note N in a block quotation on page 9. The quotation is not in the text layer of the PDF, so the sample carries a bracketed note in its place (`[Block quotation from Note N of the audit is not in the text layer of the filing and is not transcribed.]`). The template does not produce that quotation; the note is in the sample, not the template.
2. **20-page cap not enforced.** LR 7.1(a)(2) caps the memorandum at twenty pages. The template does not count pages or warn (whether the certificate of service counts is not settled by the rule); the sample is 14 pages with the certificate.
3. **Footnotes.** Footnote references work in paragraphs and bullet items. They do not work inside headings or block quotations (none used). Footnote text supports the same markdown as the body.
4. **Footers** are 12 pt, the same size as the text, to satisfy "all text" in LR 5.2(a).
5. **Caption position.** The caption starts at four inches when the counsel block is short enough; with two long counsel groups it sits lower (the rule's exception).
6. **Second and third exemplars** (Anderson, Robinson) are saved and checked on page 1 only; their text is not used in the sample.

## Engines

typst (`typst/idd-motion-brief.typ`, the reference) and docx (`docx/reference.xml`, `docx/idd-motion-brief.lua`); no latex. Both pass `tools/check.sh` with 0 failed; the docx passes XENG-001..003 and `eval.yaml` sets `params.cross_engine: gate`.

The docx (fb-595.68.23): `docx/reference.xml` is the cross-engine style recipe (`base="xengine"`) in the typst face (`{font}`), 12 pt, 27.6 pt body and heading lines, 13.8 pt single and footnote lines, with "Body Text Note" and "List Item Indented" for the paragraphs that carry a footnote (pandoc writes those, so that it writes the note); `docx/idd-motion-brief.lua` writes every other paragraph with its own exact spacing, the caption as a table (the party text 0.75 pt nearer the rule than in typst, since LibreOffice takes the rule's width from the cell), the counsel block as a table row at least 3 in high, a web address with a zero-width space wherever typst breaks one, and the footer "N - TITLE" with the last section through `fb render` (`$FORMBOOK_FOOTERS`, `$FORMBOOK_FINAL`). Its right margin is 1 twip wider than typst's (1441 twips): LibreOffice sets a line of Times New Roman up to about 0.15 pt narrower than typst, and one body line (p2, "... management and") that typst overflows by 0.02 pt otherwise fits in LibreOffice; 1441 breaks every line of the sample as typst does (1440 and 1443 do not). No shell and no binary reference document. Word may paginate slightly differently from LibreOffice (docs/DOCX.md).
