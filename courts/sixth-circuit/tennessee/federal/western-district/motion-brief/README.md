# tnwd: motion-brief

Doc type: **motion-brief**, the memorandum of law that supports a motion to dismiss under Fed. R. Civ. P. 12(b)(6) in the United States District Court for the Western District of Tennessee (`tnwd`), as this district's local rules require (LR 7.2(a)(1): a motion is accompanied by a supporting memorandum "so identified").
Folder: `courts/sixth-circuit/tennessee/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| typeface | **Times New Roman** named by the W.D. Tenn. CM/ECF manual, section "Setting up PDF Reader and Converting to PDF": "The court only allows use of the following fonts ... Times New Roman, Arial, and Courier New. Size of font must be (at least) 12 point." LR 7.1(b) itself names no face. Both engines set the vendored Times New Roman (`fonts/`; Liberation Serif, metric-compatible, is only the declared fallback). EB Garamond is not used. |
| sample md | `usage/INPUT-motion-brief.md` (the whole 9-page filing: caption, background, standard, argument I to IV, conclusion, signature block, certificate of service) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` and `usage/OUTPUT-motion-brief.docx` / `.docx.pdf`, 10 pages each, on the shared cross-engine layout model (fb-595.68.31): typst 0.15.0 and LibreOffice, vendored Times New Roman only, no warnings; the docx breaks every line and page as typst (XENG-001..003 gated, `eval.yaml`) |
| overlay | `just overlay` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 10 of 10, typst and docx (every page of the 2026-10-22 renders rasterized at 60 dpi and viewed) |

## Governing rules

Primary sources, fetched and read 2026-10-14:

- **W.D. Tenn. Local Rules** (revised 11.17.2025): the PDF linked from https://www.tnwd.uscourts.gov/local-rules (`https://www.tnwd.uscourts.gov/sites/tnwd/files/Local%20Rules%20%E2%80%93%20Revised%2011.17.%202025%20%28Addition%20of%20LR%2043.1%28h%29%29.pdf`).
- **Fed. R. Civ. P. 5, 7, 8, 10, 12** from https://www.law.cornell.edu/rules/frcp/rule_5, `.../rule_7`, `.../rule_8`, `.../rule_10`, `.../rule_12`.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 7.1(a) | 8½ × 11 inch white paper, one-inch margins on all sides; the paper shows the attorney's name, address, telephone, e-mail and Board of Professional Responsibility number. | `page-w`, `page-h`, `margin`; `signature` (name, `bar_number`, firm, lines). |
| LR 7.1(b) | Double-spaced (quotations, headings and footnotes may be single-spaced); no smaller than 12 point, footnotes included. | `pitch-body = 27.6pt` (Word's double line), `pitch-single = 13.8pt` for the court title, caption, title, headings, signature, certificate lines and footnotes; `type-size = 12pt`; footnote entries set at 12 pt. |
| LR 7.1(d) | Page limits exclude captions, signature lines and certificates. | Applied by the reader (see gap 4). |
| LR 7.2(a)(1) | A motion is accepted only with a supporting memorandum, "so identified". | The title: `MEMORANDUM IN SUPPORT OF ... MOTION TO DISMISS`. |
| LR 7.2(a)(1)(A)-(B) | Proposed order and certificate of consultation: **not required** for motions under Rule 12. | Not produced (the rule exempts Rule 12 motions). |
| LR 7.2(e) | Memoranda in support of motions not over 20 pages unless the court orders otherwise. | Not enforced by the template (gap 4). |
| LR 7.2(h), (i) | Citations to unreported decisions carry Westlaw or Lexis citations; internet materials are attached as PDFs. | Author content (the exemplar's citations carry Lexis cites). |
| LR 11.1(b) | Signature block: "s/" then the filing user's name, attorney bar number, firm name, street address, telephone, primary e-mail. | `signature-block()`. |
| LR 12.1(a)-(c) | Memoranda in support of a Rule 12(b) or (c) motion not over 20 pages without prior approval; a reply by the moving party not over 10 pages. | Gap 4. |
| Fed. R. Civ. P. 5(b)(2)(E) | Service by filing with the court's electronic-filing system is complete upon filing. | `certificate` frontmatter: `served_on` and `method`; the template prints the certificate wording. |
| Fed. R. Civ. P. 7(b)(1) | A motion must be in writing, state with particularity the grounds, and state the relief sought. | The memorandum (the motion itself is a separate filing; see gap 1). |
| Fed. R. Civ. P. 8(a) | Short and plain statement of the claim (the standard the memorandum argues). | Author content. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and the Rule 7(a) designation. | `court-title()`, `caption()` (the file number `No.` is printed opposite the style). |
| Fed. R. Civ. P. 12(b)(6) | Failure to state a claim upon which relief can be granted: a defense that may be raised by motion before pleading. | Author content (STANDARD and ARGUMENT). |

Not produced by this template: the notice of motion itself (Gonzalez's motion is ECF No. 13; this is its memorandum, ECF No. 13-1), any proposed order, a certificate of consultation (not required for Rule 12), the table of contents or authorities (a memorandum this short has none in the exemplar).

## Layout

Both engines set it on the shared cross-engine model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box of its pitch, first-fit ragged-right breaking, no kerning, ligatures or hyphenation.

- Court title single-spaced, centered, a blank double line below; caption: one row per party line (names, the designation 1.25 in in, a blank line, `v.`, a blank line, ...), a column of `)` marks, one per line of text, and `No.` with the case number opposite `v.`.
- Title centered, bold, single-spaced, a blank double line above and below.
- Body double-spaced (27.6 pt), 12 point, ragged right, first-line indent of ½ inch. **Paragraphs are not numbered** (a brief is not).
- Headings single-spaced, a blank single line above and 6.9 pt below, kept with what follows. Section headings (`#`): centered bold. Point headings (`##`, `###`): bold, the typed roman numeral or letter in a ½-inch box and the text hanging after it (I., II., III., IV.).
- Block quotations single-spaced, ½ inch in on both sides, 6.9 pt above and below. Footnotes 12 pt (LR 7.1(b)), single-spaced, 7 pt apart.
- Signature block from the middle of the page (LR 11.1(b) order): `Respectfully submitted,`, `s/` name, `Attorney Bar No.`, firm, address, telephone, e-mail, role; kept on one page with the last paragraph.
- Certificate of service on a page of its own (as filed), kept whole: title, the declaration double-spaced, the persons served, `DATE:`, firm and `s/` line.
- Page numbers centered at the foot of each page, in a 13.8 pt line.

## Markdown contract (for samples)

- YAML frontmatter: `case_number` (the docket number, printed after `No.`), `court_division`, `caption` (list of `{names: [...], designation: "..."}`), `title`, `signature` (`signer`, `bar_number`, optional `firm`, `lines`), `date` (optional, printed above `Respectfully submitted`), `certificate` (optional: `document` (defaults to the title), `method`, `served_on` (lines), `date`).
- Body: blank-line-separated chunks. `#` section heading; `##` point heading (`## I. TEXT` gives a hung label `I.`); `###` (set the same as `##`); a `>` quotation; a paragraph (unnumbered). Footnotes: `text[^key]` and `[^key]: text` on its own chunk after the paragraph.
- Italic case names: `*Erie County, Ohio v. Morton Salt, Inc.*`, `*Id.*`, `*See*`.
- Not supported: tables, raw typst.

## Review of the rendered pages (2026-10-22, typst and docx, all pages)

Each page of both renders was rasterized with `pdftoppm -r 60` after the last change and viewed; the two renders break every line and page alike (XENG-001..003 PASS, 215/215 lines).

- p. 1: court title; caption with the `)` column (one per wrapped line of the long defendant name), `v.` and the file number; the two-line title; the lead-in; BACKGROUND. Pass.
- pp. 2-3: background, STANDARD, ARGUMENT, point I. Pass.
- pp. 4-5: points II. and III. (labels in the half-inch box, text hanging), the start of IV. Pass.
- pp. 6-8: point IV. Page 8 ends about nine lines short: CONCLUSION, its paragraph and the signature block are kept together and open p. 9 (ACCEPTED, tier 2: the signature never stands alone). Pass.
- p. 9: CONCLUSION, the paragraph, the signature block. Pass.
- p. 10: the certificate of service on its own page. Pass.

## Known gaps and open choices

1. **One exemplar only** (brief's requirement). Tier 2 of EVAL-LOOP asks for two or three filers. The search (CourtListener RECAP, `type=r`, `court=tnwd`, `available_only=on` and plain) turned up other tnwd Rule 12 memoranda, for example the memoranda supporting ECF No. 21 in *Ewel v. University of Memphis*, 2:26-cv-02129, and ECF No. 6 in *Brown v. Navy Federal Credit Union*, 2:26-cv-02414; RECAP did not mark their PDFs as available, so they were not downloaded. *Hannis v. Guardian Life*, 1:25-cv-01297 (doc 8, a 4-page motion, available) was downloaded but is a motion, not a memorandum, and was not used. Tier 2 is therefore **not** judged against two filers.
2. **The exemplar's caption says WESTERN DIVISION** while the case number carries the `1:` prefix (the Eastern (Jackson) office in the docket numbering). The template takes the division from the frontmatter; the sample transcribes the filing as captioned. Not corrected.
3. **Italic citations are inferred.** The filing's text layer has no italic markup. Case names and signals are italic by the citation convention (Bluebook), chosen by the transcriber; the render shows italic where the markdown says so.
4. **Page limit not enforced.** LR 7.2(e) and LR 12.1(a) cap the memorandum at 20 pages, excluding caption, signature and certificates. The sample is 9 pages in all (about 8 with text and signature, the 9th the certificate). A longer memorandum must be checked by the filer; the template does not count pages.
5. **Signature line.** The exemplar prints `By:` above `s/`; LR 11.1(b)'s sample has none, and the template follows the rule's sample. A `By:` line would be a change in both `typst/tnwd-motion-brief.typ` and `docx/tnwd-motion-brief.lua`.
6. **Certificate of service wording** is the exemplar's (ECF and U.S. Mail), reproduced from the frontmatter. FRCP 5(b)(2)(E) governs the ECF method; the mail method is the filer's choice and is not required.
7. **Font.** Times New Roman, as the CM/ECF manual allows; both engines set the vendored Times New Roman (`fonts/`), and the docx names it through `{font}`. The 12-point minimum is met.
8. **Caption column count.** One `)` per line of text in the party column (typst measures each row; the docx filter counts the lines first fit on Times New Roman advances, breaking at spaces and after hyphens), so a party column that wraps differently from the filing shows a different count.
9. **Overlay.** Pages pair in order (the sample is the whole filing); the overlay is a diagnostic, not a score.
10. **Selftest.** `tools/check-selftest.sh` needs a court folder with `court.json`; this doc-type folder has none, so it is not run here. `tools/check.sh` runs on both engines.

## Engines

typst (`typst/tnwd-motion-brief.typ`) is the reference; docx (`docx/reference.xml`, base="xengine" in the typst face `{font}`, and `docx/tnwd-motion-brief.lua`, which writes the court title, caption table, title, headings, signature and certificate of service with the typst spaces in twips and leaves body paragraphs, quotations and footnotes to pandoc in the reference styles). `sh tools/check.sh <dir>` and `--engine docx`: 0 failed; XENG-001..003 PASS (215/215 lines, 10 pages), `params.cross_engine: gate` in `eval.yaml`. No latex engine for this folder.

- Differences: none in line or page breaks; widths of identical lines within 0.47 pt; the centered title's first line starts 1.1 pt apart (its width drift, halved by centering).
- BLOCKED: none.
