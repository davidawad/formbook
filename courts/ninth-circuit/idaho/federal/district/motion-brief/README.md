# idd: motion-brief

Doc type: **motion-brief**, a memorandum in support of a motion to dismiss under FRCP 12(b)(6) (with the FRCP 9(b) argument), in the United States District Court for the District of Idaho (`idd`). Dist. Idaho Loc. Civ. R. 7.1(a)(2) caps a memorandum at twenty pages; 7.1(b)(1) requires it to be a separate brief.
Folder: `courts/ninth-circuit/idaho/federal/district/motion-brief/` (self-contained; the court-root `typst/` and `usage/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: three filings of three filers, `usage/FILED-EXAMPLE-motion-brief.pdf` (primary; transcribed and used for the overlay), `FILED-EXAMPLE-motion-brief-2.pdf` (Anderson), `FILED-EXAMPLE-motion-brief-3.pdf` (Robinson). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md` (the full text of the 14-page memorandum, with its footnotes, headings and signature; the certificate of service is in frontmatter; see Known gaps) |
| typeface | face required: none (LR 5.2(a) sets only a 12-point minimum, footnotes and footer included; LR 7.1(a)(2) names no face; checked on the Court's site 2026-10-15). Times New Roman 12 pt, the house standard (`docs/FONTS.md`), as the Robinson and Anderson exemplars (Tarbell is set in Century Schoolbook, one filer's choice); typst names `("Times New Roman", "Liberation Serif")`, the generated engines the same face. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf` and `.docx` / `.docx.pdf`, 14 pages each (13 and the certificate of service), letter, Times New Roman Regular and Bold embedded only, no warnings (fb-595.17.12) |
| overlay | diagnostic only, not committed: `just overlay` writes `.overlay/<doc path>/OVERLAY-<id>.pdf` from `usage/FILED-EXAMPLE-<id>.pdf` |
| pages reviewed | 14 of 14 on every engine (2026-10-29, the FRCP-base render; see "Page review") |

## Commands

```
sh tools/render.sh courts/ninth-circuit/idaho/federal/district/motion-brief usage/INPUT-motion-brief.md
sh tools/render.sh --engine latex|docx courts/ninth-circuit/idaho/federal/district/motion-brief usage/INPUT-motion-brief.md
sh tools/check.sh courts/ninth-circuit/idaho/federal/district/motion-brief [--engine latex|docx]
just overlay courts/ninth-circuit/idaho/federal/district/motion-brief
```

## Governing rules

Primary source: the District of Idaho's Local Civil Rules, the print packet from https://idd.uscourts.gov/district/forms_fees_rules/Civil_Rules.cfm?lni=214 (the packet's cover reads "Revised and adopted August 17, 2026"; General Order No. 479, adopted August 17, 2026, amended Rules 9.1, 9.2, 16.4 and 37.1, none of them the form rules below). Fetched 2026-10-14. Rule text quoted from that packet. The civil rules in the packet say nothing about the typeface of a memorandum beyond LR 5.2(a).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Dist. Idaho Loc. Civ. R. 7.1(a)(2) | "No memorandum of points and authorities in support of or in opposition to a motion may exceed twenty (20) pages in length … The use of small fonts and/or minimal spacing to comply with the page limitation is not acceptable." | The layout sets 12 pt type and double spacing with no shrink option; `eval.yaml` `params.page_limit: 20` checks the render (every page counted, the certificate of service included: the conservative reading). |
| Dist. Idaho Loc. Civ. R. 7.1(a)(3) | Documents "in support of … other documents must be clearly labeled with the docket number of the motion in the caption." | `motion_docket` frontmatter: the caption shows "[Doc. 26]" under the title. |
| Dist. Idaho Loc. Civ. R. 7.1(b)(1) | "Each motion … must be accompanied by a separate brief … containing all of the reasons and points and authorities relied upon by the moving party." | Output is a stand-alone memorandum with its own caption; the title says "MEMORANDUM IN SUPPORT OF MOTION TO DISMISS". |
| Dist. Idaho Loc. Civ. R. 5.2(a) | 8½ × 11; "double-spaced, except for quoted material and footnotes"; "Each page must be numbered consecutively"; margins "at least one inch"; "the font or typeface for all text, including footnotes, must be at least 12 point." | the base (`lib/layouts/frcp-motion-brief.yaml`): letter paper, one-inch margins, 12 pt type and notes, the page number at the bottom centre (the primary exemplar's); `pitch.body: 27.6` (Word double spacing of 12 pt Times New Roman, as the exemplars), footnotes and quotations single-spaced (13.8 pt lines). |
| Dist. Idaho Loc. Civ. R. 5.2(b) | Upper-left counsel block; the caption "commencing four inches below the top of the first page, (except where additional space is required for identification)". | `front` in `typst/layout.yaml`: the counsel column beside an empty column three inches high, so the court's name starts at four inches, or 12 pt below a longer counsel block. |
| Dist. Idaho Loc. Civ. R. 5.2(b)(1)–(3), (5) | The court title; the title of the action; the CM/ECF file number; the title of the paper. | `constants` (the court's name), `caption.parties`, `case_number` (`1:25-cv-00144-DCN`), `brief_title`. |

Not produced by this template: a table of contents or table of authorities (none of the rules fetched requires one for a memorandum of twenty pages or fewer; the exemplar has none); the proposed order; the certificate of compliance (not in the fetched rules). The memorandum does not carry line numbers (the rules do not require them).

## Layout

Set by `typst/layout.yaml` (the generic FRCP brief, `lib/layouts/frcp-motion-brief.yaml`, with this court's overlay; each value cites its rule), on the shared document model (docs/EVAL-LOOP.md, "Generated engines"): every line a box of its pitch, first-fit ragged-right breaking, no kerning, ligatures or hyphenation, so the latex and docx renders break every line and page where typst does.

- Counsel block single-spaced (13.8 pt lines) in the upper left, from the top margin; an empty entry is a blank line between groups.
- Court's name (bold, centered: "UNITED STATES DISTRICT COURT", "DISTRICT OF IDAHO", as the primary exemplar) at four inches from the top, or 12 pt below the counsel block when it is longer (the exemplar's two counsel groups are long, so the caption sits lower; the rule's exception applies).
- Caption a single line below: the party column 3.25 in, ruled at its right and foot; the right column carries the file number, the title in bold and the "[Doc. N]" docket line, a blank single line apart.
- Body double-spaced at a 27.6 pt pitch, no space between paragraphs, first lines indented 0.5 in; unnumbered paragraphs.
- Headings on the body pitch, kept with the text after them: level 1 centered bold caps (INTRODUCTION, BACKGROUND, ARGUMENT, CONCLUSION); level 2 centered bold; level 3 bold with a 0.5 in hanging indent (the argument headings "I.", "II.", "III.").
- Footnotes at 12 pt (LR 5.2(a)), single-spaced, 7 pt apart, under a rule of 30 % of the line; a paragraph or list that calls one keeps its widow and orphan control (`footnote.widows: true`), so a bullet item never leaves its first line alone at a page's foot.
- Bulleted lists: the bullet at the margin in a half-inch box, the text hanging at 0.5 in, double-spaced (the model's lists; the earlier template set the bullet half an inch in).
- Signature block: "Dated: …" at the left beside "Respectfully submitted,", the firm, "/s/" and the signer, with the lines from the frontmatter; one block that never breaks, kept with the last paragraph.
- Certificate of service (`certificate`): its own page (the primary exemplar does the same), its title as a level-1 heading, the certificate text double-spaced, and the filer's "/s/" signature in the signature column.
- Footer: the page number, 12 pt, centered at the bottom of every page (the primary exemplar; the earlier template's "N - TITLE" footer was the Robinson filer's style).

## Markdown contract (for samples)

- YAML frontmatter, then the body: markdown set by the shared document model (`#` to `###` headings, paragraphs, bulleted and numbered lists, block quotations, footnotes `[^n]` with `[^n]: text` definitions, `*italics*`).
- Frontmatter fields: `case_number`, `motion_docket` (for example `Doc. 26`; shown as `[Doc. 26]`; optional), `counsel` (lines; an empty string is a line-high gap), `caption.parties` (list of `{names, designation}`), `brief_title`, `date`, `signature` (`firm`, `signer`, `lines`), `certificate` (`text`, `signer`, `lines`; omit for no certificate). The court's name is the layout's constant (no `caption.court`); there is no `footer_title` (fb-595.17.12).

## What the overlay shows

`just overlay` regenerates it in `.overlay/` (not committed). Our render is 14 pages, as the Tarbell exemplar, but the same text need not fall on the same page (the exemplar is set in Century Schoolbook at a 24 pt pitch). The overlay is a diagnostic, not a score.

## Page review (Gate 2 equivalent)

Every page of `OUTPUT-motion-brief.typst.pdf`, `.latex.pdf` and `.docx.pdf` was read as its text layout and word boxes (`pdftotext -layout`, `-bbox`; the caption rules from `pdftocairo -svg`) after the last layout change (2026-10-29). The three engines break every line and page alike (XENG-001..003 PASS, 326/326 lines), and the typst render breaks every page where the render before the port did.

| Page | Result (typst, latex and docx) |
|---|---|
| 1 | Counsel block (two groups); court's name at the counsel block's foot plus 12 pt; caption ruled at the right and foot, with the file number, "DEFENDANT'S MEMORANDUM IN SUPPORT OF MOTION TO DISMISS" and "[Doc. 26]"; the first paragraph with footnote 1; INTRODUCTION. Footer "1". Pass. |
| 2 | Introduction text; footnote 2 (the list of members). Pass. |
| 3 | Introduction paragraphs (the CARES Act, the amendments, Relator). Pass. |
| 4 | Introduction end; BACKGROUND; bullets ¶¶6–8 to ¶14; footnote 3 from the ¶10 bullet. Pass. |
| 5 | Bullet ¶15 (whole, with its first line; it no longer leaves a line on page 4); two paragraphs; LEGAL STANDARDS. Pass. |
| 6 | Legal standards; ARGUMENT; heading I. Pass. |
| 7 | Section I with its bullets (Doc. 56-1 parts); heading II; footnotes 4 and 5. Pass. |
| 8 | Section II text (the audit prong, the Single Audit Act). Pass. |
| 9 | The Clearinghouse URL (broken where every engine breaks a web address); footnote 6; the audit bullets begin. Pass. |
| 10 | Audit bullets end; the Kootstra paragraph; the original-source definition. Pass. |
| 11 | "First" and "Second" paragraphs; the section break "\* \* \*" (a paragraph of its own); "At bottom". Pass. |
| 12 | Heading III; footnote 7. Pass. |
| 13 | Section III end; CONCLUSION; "Dated: June 9, 2026" beside the signature block. Pass. |
| 14 | CERTIFICATE OF SERVICE on its own page; the certificate text; the right-hand signature block. Pass. |

## Tier-2 findings (against the three filed exemplars, by page)

| Page | Finding | Status |
|---|---|---|
| all | Times New Roman 12 pt, double-spaced at 27.6 pt, as the Robinson and Anderson exemplars (27.4 to 27.6 pt measured on their body pages); Tarbell is set in Century Schoolbook at a 24 pt pitch, one filer's style (tier 3). | ACCEPTED. |
| all | Footer: the page number alone, centered, as the Tarbell exemplar (Anderson centers "-i-"; Robinson prints the title and the number). | ACCEPTED. |
| 1 | The caption's party column is closed by a rule at its right and foot (the Robinson and Anderson filings, checked on page 1, use the same closed box; DEF-COVER-002 passes against Tarbell). | ACCEPTED. |
| 2 | Anderson (18 pages) has a TABLE OF CONTENTS on page 2 with dot leaders. Tarbell (14 pages) has none in its full text. Robinson's page 1 has none; its inner pages were not checked. The template does not produce a contents page. The fetched rules do not require one. | OPEN (whether a contents page is expected for a 20-page memorandum is a question for David; the model can set one: `contents` in `typst/layout.yaml`). |
| 4, 5, 7, 9, 10 | Bullets at the margin, the text half an inch in (the model's lists); Tarbell sets the bullet half an inch in. | ACCEPTED (tier 3). |
| 11 | The section break "\* \* \*" is a body paragraph (indented), not a centered line (the model has no centered break). | ACCEPTED (tier 3). |
| 14 | The certificate of service is on its own page, as in the Tarbell exemplar (page 14). | ACCEPTED. |

## Known gaps and open choices

1. **Block quotation omitted from the transcription.** The Tarbell exemplar quotes the audit's Note N in a block quotation on page 9. The quotation is not in the text layer of the PDF, so the sample carries a bracketed note in its place (`[Block quotation from Note N of the audit is not in the text layer of the filing and is not transcribed.]`). The note is in the sample, not the template.
2. **20-page cap.** LR 7.1(a)(2) caps the memorandum at twenty pages. `eval.yaml` `params.page_limit: 20` checks the render, counting every page (whether the certificate of service counts is not settled by the rule); the sample is 14 pages with the certificate.
3. **Footers** are 12 pt, the same size as the text, to satisfy "all text" in LR 5.2(a).
4. **Caption position.** The caption starts at four inches when the counsel block is short enough; with two long counsel groups it sits lower (the rule's exception).
5. **Second and third exemplars** (Anderson, Robinson) are saved and checked on page 1 and their footers only; their text is not used in the sample.

## Engines

On the generic federal district brief since fb-595.17.12: `typst/layout.yaml` is `base: /lib/layouts/frcp-motion-brief.yaml` plus this court's overlay, each value with its rule; the typst template (`typst/idd-motion-brief.typ`) only names the face; `latex/` (`template.tex`, `xdoc.lua`) and `docx/` (`reference.xml`, `xdoc.lua`) are generated from the merged layout by `fb engines gen` (do not edit them; change the layout and generate again). The old per-folder typst code and Word filter (`docx/idd-motion-brief.lua`) are removed. Word's right margin is one twip wider than typst's (`docx_bias: 0.05`): typst overflows one line of page 2 ("... management and") by 0.02 pt and moves its last word on, and LibreOffice, up to 0.15 pt narrower, fits it otherwise (the earlier filter's 1441-twip margin, now in the layout).

| engine | output | check.sh | XENG-001..003 |
|---|---|---|---|
| typst | `usage/OUTPUT-motion-brief.typst.pdf` (14 pages) | `RESULT: 12 checks passed, 0 failed` | reference |
| latex | `usage/OUTPUT-motion-brief.latex.pdf` (14 pages) | `RESULT: 15 checks passed, 0 failed` | PASS (326/326 lines) |
| docx | `usage/OUTPUT-motion-brief.docx`, `.docx.pdf` (14 pages) | `RESULT: 16 checks passed, 0 failed` | PASS (326/326 lines) |

DEF-COVER-002 passes on every engine. Word may paginate slightly differently from LibreOffice (docs/DOCX.md).
