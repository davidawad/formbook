# tnwd: motion-brief

Doc type: **motion-brief**, the memorandum of law that supports a motion to dismiss under Fed. R. Civ. P. 12(b)(6) in the United States District Court for the Western District of Tennessee (`tnwd`), as this district's local rules require (LR 7.2(a)(1): a motion is accompanied by a supporting memorandum "so identified").
Folder: `courts/sixth-circuit/tennessee/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-gonzalez-carroll-county-1-26-cv-02199-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| typeface | **Times New Roman** named by the W.D. Tenn. CM/ECF manual, section "Setting up PDF Reader and Converting to PDF": "The court only allows use of the following fonts ... Times New Roman, Arial, and Courier New. Size of font must be (at least) 12 point." LR 7.1(b) itself names no face. Substitute: **Liberation Serif** (`docs/FONTS.md`, metric-compatible with Times New Roman). EB Garamond is not used. |
| sample md | `samples/INPUT-gonzalez-memorandum.md` (the whole 9-page filing: caption, background, standard, argument I to IV, conclusion, signature block, certificate of service) |
| render | ok: `samples/OUTPUT-gonzalez-memorandum.pdf`, 9 pages, typst 0.15.0, vendored Liberation Serif only (re-rendered 2026-10-15; `pdffonts`: only LiberationSerif embedded), no warnings |
| overlay | ok: `samples/OVERLAY-gonzalez-memorandum.pdf` and `samples/OVERLAY-gonzalez-memorandum.txt` (page map) |
| pages reviewed | 9 of 9 (every page of the 2026-10-15 render rasterized at 60 dpi and viewed)

File names follow the tools' defaults (`render.sh` writes `samples/OUTPUT-<id>.pdf`; `overlay.sh` reads it and writes `samples/OVERLAY-<id>.pdf`/`.txt`), not the `<id>.pdf` / `<id>-overlay.pdf` names in the brief. `<id>` is `gonzalez-memorandum`.

## Governing rules

Primary sources, fetched and read 2026-10-14:

- **W.D. Tenn. Local Rules** (revised 11.17.2025): the PDF linked from https://www.tnwd.uscourts.gov/local-rules (`https://www.tnwd.uscourts.gov/sites/tnwd/files/Local%20Rules%20%E2%80%93%20Revised%2011.17.%202025%20%28Addition%20of%20LR%2043.1%28h%29%29.pdf`).
- **Fed. R. Civ. P. 5, 7, 8, 10, 12** from https://www.law.cornell.edu/rules/frcp/rule_5, `.../rule_7`, `.../rule_8`, `.../rule_10`, `.../rule_12`.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 7.1(a) | 8½ × 11 inch white paper, one-inch margins on all sides; the paper shows the attorney's name, address, telephone, e-mail and Board of Professional Responsibility number. | `page-w`, `page-h`, `margin`; `signature` (name, `bar_number`, firm, lines). |
| LR 7.1(b) | Double-spaced (quotations, headings and footnotes may be single-spaced); no smaller than 12 point, footnotes included. | `pitch = 27.6pt`, `body-leading`; `type-size = 12pt`; footnote entries set at 12 pt. |
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

- Court title single-spaced, centered; caption with the parties in a left column with a column of `)` marks, `v.` between the sides, designations indented, and `No.` with the case number on the right.
- Title centered, bold, capitals (two lines in the exemplar).
- Body double-spaced, 12 point, left-aligned, first-line indent of ½ inch. **Paragraphs are not numbered** (a brief is not).
- Section headings (`#`): centered bold capitals (BACKGROUND, STANDARD, ARGUMENT, CONCLUSION).
- Point headings (`##`): bold, the roman numeral or letter hung in a ½-inch label column and the text wrapping under it (I., II., III., IV.).
- Block quotations single-spaced, indented ½ inch on both sides.
- Signature block in the right half of the page, after the conclusion, single-spaced: `Respectfully submitted,`, firm name, `s/` name, `Attorney Bar No.`, address, telephone, e-mail, role.
- Certificate of service on its own page (the block is kept together): title, method, the persons served, `DATE:`, firm and `s/` line.
- Page numbers centered at the foot of each page.

## Markdown contract (for samples)

- YAML frontmatter: `case_number` (the docket number, printed after `No.`), `court_division`, `caption` (list of `{names: [...], designation: "..."}`), `title`, `signature` (`signer`, `bar_number`, optional `firm`, `lines`), `date` (optional, printed above `Respectfully submitted`), `certificate` (optional: `document` (defaults to the title), `method`, `served_on` (lines), `date`).
- Body: blank-line-separated chunks. `#` section heading; `##` point heading (`## I. TEXT` gives a hung label `I.`); `###` (set the same as `##`); a `>` quotation; a paragraph (unnumbered). Footnotes: `text[^key]` and `[^key]: text` on its own chunk after the paragraph.
- Italic case names: `*Erie County, Ohio v. Morton Salt, Inc.*`, `*Id.*`, `*See*`.
- Not supported: tables, raw typst.

## Review of the rendered pages (final render, all pages)

Each page was rasterized with `pdftoppm -r 60` after the last template change and viewed.

- p. 1: court title; caption with `)` column (plaintiff, `v.`, the defendants' list, `Defendants.`) and `No. 1:26-cv-02199-STA-jay`; two-line bold title; opening paragraph; BACKGROUND heading; start of the background. Pass.
- p. 2: background to the end of the STANDARD heading; the standard paragraph with italic citations. Pass.
- p. 3: the standard's end; ARGUMENT heading; point I (hung label, text wraps at the left margin); point II heading on two lines, hung label. Pass.
- p. 4: point II body; point III heading on two lines. Pass.
- p. 5: point III end; point IV heading on two lines; body with signals and parentheticals. Pass.
- p. 6: point IV body; the Monell paragraph. Pass.
- p. 7: point IV continued (the rest of the *Monell* paragraph with its parenthetical quotation, the ratification argument, the state-law claim). Pass.
- p. 8: CONCLUSION heading; the closing paragraph; `Respectfully submitted,`; firm; `s/ Nathan D. Tilly`, `Attorney Bar No. 031318`, address, telephone, facsimile, e-mail. Pass.
- p. 9: CERTIFICATE OF SERVICE on its own page; the method sentence (`Motion to Dismiss` as the document); the served person's address; `DATE:`; firm; `s/ Nathan D. Tilly`. Pass.

## Known gaps and open choices

1. **One exemplar only** (brief's requirement). Tier 2 of EVAL-LOOP asks for two or three filers. The search (CourtListener RECAP, `type=r`, `court=tnwd`, `available_only=on` and plain) turned up other tnwd Rule 12 memoranda, for example the memoranda supporting ECF No. 21 in *Ewel v. University of Memphis*, 2:26-cv-02129, and ECF No. 6 in *Brown v. Navy Federal Credit Union*, 2:26-cv-02414; RECAP did not mark their PDFs as available, so they were not downloaded. *Hannis v. Guardian Life*, 1:25-cv-01297 (doc 8, a 4-page motion, available) was downloaded but is a motion, not a memorandum, and was not used. Tier 2 is therefore **not** judged against two filers.
2. **The exemplar's caption says WESTERN DIVISION** while the case number carries the `1:` prefix (the Eastern (Jackson) office in the docket numbering). The template takes the division from the frontmatter; the sample transcribes the filing as captioned. Not corrected.
3. **Italic citations are inferred.** The filing's text layer has no italic markup. Case names and signals are italic by the citation convention (Bluebook), chosen by the transcriber; the render shows italic where the markdown says so.
4. **Page limit not enforced.** LR 7.2(e) and LR 12.1(a) cap the memorandum at 20 pages, excluding caption, signature and certificates. The sample is 9 pages in all (about 8 with text and signature, the 9th the certificate). A longer memorandum must be checked by the filer; the template does not count pages.
5. **Signature line.** The exemplar prints `By:` above `s/`; LR 11.1(b)'s sample has none, and the template follows the rule's sample. A `By:` line would be a one-line change in `typst/tnwd-motion-brief.typ`.
6. **Certificate of service wording** is the exemplar's (ECF and U.S. Mail), reproduced from the frontmatter. FRCP 5(b)(2)(E) governs the ECF method; the mail method is the filer's choice and is not required.
7. **Font.** Liberation Serif, the Times New Roman substitute, as the CM/ECF manual requires (see the complaint README, gap 3). The 12-point minimum is met.
8. **Caption column count.** The number of `)` marks is computed from the height of the party column (one per line), so a party column that wraps differently from the filing shows a different count. Checked by eye against the filing's caption on page 1; the count was not compared mark for mark.
9. **Overlay.** Pages pair in order (the sample is the whole filing); the overlay is a diagnostic, not a score.
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder has neither, and the brief forbids touching `tools/`. Render and overlay were run; the review above is the visual check for this doc type.

## Engines

DOCX (`docx/`: `build-reference.sh` makes `reference.docx`; `tnwd-motion-brief.lua` sets the caption, point headings with hung labels, block quotations, the signature block and the certificate of service). Rendered with `sh tools/render.sh --engine docx motion-brief samples/INPUT-gonzalez-memorandum.md` to `samples/OUTPUT-gonzalez-memorandum.docx` and `.docx.pdf` (LibreOffice). Reviewed: all 9 pages of the `.docx.pdf` against all 9 pages of the typst output, at 60 dpi.

- Matches typst: Liberation Serif 12 pt; double spacing 27.6 pt and single 13.8 pt; one-inch margins; caption and `No.` line; title; body unnumbered and double spaced with the ½-inch first-line indent; section headings centred; point headings (I., II., ...) with the label at the margin and the text wrapped under it; block quotations single spaced; the signature block on page 8 with the conclusion, and the certificate of service on page 9, as in typst; page numbers centred. Page count is 9 in both.
- Differs (ACCEPTED, tier 2): the caption's `)` column is a cell rule (as in the complaint); a few lines break differently (the caption's party names, the bold title line, point heading II), and some pages hold one line more or fewer than typst (line counts per page are within three lines of typst); the signature block is not forced to a page, so Word may move it.
- BLOCKED: none. `tools/check.sh --engine docx` cannot run: the court folder has no `checks.yaml`, so no check ID was evaluated. See the PR.
