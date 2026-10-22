# vtb: motion with memorandum

Doc type: **motion with memorandum** in the United States Bankruptcy Court for the District of Vermont (`vtb`): a motion under Fed. R. Bankr. P. 9013 in an adversary proceeding, with its argument in the same document.
Folder: `courts/second-circuit/vermont/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief-2.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the filed motion, transcribed in full: caption, all 20 numbered paragraphs, the block quotation, the argument headings, the signature block) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 10 pages, vendored Times New Roman (metric twin) only, no warnings, on the shared cross-engine layout model (`lib/typst/xengine.typ`; fb-595.68.26) |
| overlay | ok: `usage/OVERLAY-diocese-motion-brief.pdf` and `OVERLAY-diocese-motion-brief.txt` (page map from `tools/overlay.sh`; pages paired one to one) |
| pages reviewed | 10 of 10 on typst and docx (every page rendered at 40 dpi and viewed side by side after the last template change, 2026-10-22) |

## Governing rules

Primary sources, fetched 2026-10-14. The local rules are the Local Bankruptcy Rules of the District of Vermont as published on the court's site, edition dated 11.30.21 (see gap 1).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 9013 (https://www.law.cornell.edu/rules/frbp/rule_9013, fetched 2026-10-14; amended effective 2024-12-01) | (a) a request for an order is made by written motion unless the rule says otherwise; (b) a motion states its grounds with particularity and sets out the relief requested. | Content, not template. The sample states the grounds (Rules 12(b)(6), 7012; 28 U.S.C. §§ 157, 1334) and the relief in the first paragraphs. |
| Fed. R. Bankr. P. 9004(a), (b) (https://www.law.cornell.edu/rules/frbp/rule_9004, fetched 2026-10-14) | Legible; caption with the court's name, the case title, the case number and any adversary number, and a brief designation of the document. | `caption()` and the `title` frontmatter field. |
| D. Vt. LBR 10(a)(4) (format of filings; the 2024 edition's Vt. LBR 5005-1(a) cross-refers to it; read 2026-10-15, see gap 1) | No less than 12 point font. No typeface named. | 12 pt body (`type-size`). |
| Typeface | Vt. LBR 1007-3(c)(1) names Arial, CG Times, Courier and Times New Roman, for master mailing lists only. No rule names a face for filings. | Times New Roman, the house standard and the exemplar's face (fb-595.68.26; was EB Garamond). See gap 2. |
| Vt. LBR 9013-1(a)(1) to (3) (court's local rules, 11.30.21 edition, see gap 1) | Motion states with particularity the law (by title and section) and the procedure (by rule); clearly describes all relief requested; includes a brief summary of the facts. | Content. The sample's paragraphs 3 to 6 and the argument follow the rule's form; the template does not check them. |
| Vt. LBR 9013-1(b) | The motion certifies consultation with opposing counsel before filing (or asks for a waiver). | Not in the template: the exemplar does not have it (finding, see gap 4). |
| Vt. LBR 9013-1(f)(1) | A stipulated motion includes the word "stipulated" in its title and a statement of consent in the body. | `stipulated: true` in the frontmatter makes the template fail unless the title contains "stipulated" (VT-MB-001; mutant tested). |
| Vt. LBR 9013-1(h) | Each motion (except stipulated) includes a proposed order as an attachment. | Not produced: a separate attachment (gap 6). |
| Vt. LBR 9013-5(a) | A motion and its supporting memorandum may be one document only if both are named in the caption and the docket entry. | `memorandum: true` in the frontmatter makes the template fail unless the title contains "memorandum" (VT-MB-002; mutant tested). The sample does not set it: the exemplar's title does not name a memorandum (finding, gap 4). |
| Vt. LBR 9013-5(b) | A memorandum is succinct, does not exceed 15 pages without leave, and states a concise argument with citations. | Not asserted by the template (the page count is not checked). The sample is 10 pages in total, within the limit. |
| Vt. LBR 9013-6(a) to (c) | A notice of motion is filed with or before the motion; a certificate of service is filed with the motion (attached) or separately. | Not produced: the notice and certificate are separate documents (gap 6). |
| Vt. LBR 5005-1(a), (b), (c) | 8½ × 11 inch page; ¾ inch margins; page numbers centered at the bottom; 1.5 or 2.0 line spacing for text, 1.0 or 1.15 for quotations and footnotes; attorney identification below the signature line; caption, case number, title, party. | Same mechanisms as the adversary-complaint template (`paper`, `page-margin`, the page footer, `pitch-double` 27.6 pt and `pitch-single` 13.8 pt, `signature`). |

## Layout

- Same caption as the adversary complaint: court name centered in bold; the debtor box and the parties box, each a table of one row per single line ruled at its right and closed by a bottom rule, `Chapter` and `Case No.` beside the first, `Adv. Proc. No.` beside the second. The parties box runs over two pages here (the sample has over a hundred defendants); no rule is drawn across it at a page break. The title is centered in bold, a single line below the caption and above the body.
- Body: a `#` line is a centered bold heading (level 1); `##` centered bold (level 2); `###` bold italic at the left (level 3, the argument headings). A paragraph is numbered from 1, except the first `unnumbered` paragraphs (the introduction, as filed). A `>` block is a single-spaced, indented quotation. A footnote is transcribed as a single-spaced quotation block after its paragraph (gap 3).
- Signature: `signature.dated` on its own line, then `signature.lines` in the right half of the page.
- Typst 0.15.0 with the vendored `cmarker` package (see `typst/vtb-motion-brief.typ`).

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `court`, `debtor` (`name`, `chapter`, `case_no`), `caption` (`plaintiffs`, `defendants`), `adv_no`, `unnumbered` (number of leading paragraphs without a number), `title`, `signature` (`dated`, `lines`); optional `stipulated` and `memorandum` flags, which the template checks against the title.
- Body: as in the adversary-complaint contract.

## Overlay (red/blue)

`tools/overlay.sh` paired every page of the render with the same-numbered page of the filing (word overlap 43.6% to 86.9%). The overlay is a diagnostic, not a score. The visible differences: the filed text is Times New Roman 12 pt and our render was EB Garamond 12 pt when this overlay was made (it is Times New Roman now); the caption runs onto page 3 in both (the filing's defendant list runs over two pages); the filing's italics and footnote placement are not reproduced.

## Review of the rendered pages (Gate 2 equivalent; made on the earlier 9-page EB Garamond render. The 10 pages of the current typst and docx renders were viewed side by side on 2026-10-22: every line and page alike, the caption on pages 1 to 3, the body on 3 to 10, the signature block on 10; no defect found)

Every page of `OUTPUT-motion-brief.typst.pdf` was rendered at 60 dpi and viewed. Result per page:

- Page 1: caption (court, debtor block, plaintiff and first defendants), the defendant list continues. Pass.
- Page 2: defendant list continues to the rule. Pass.
- Page 3: defendant list ends with "Defendants."; the title "DIOCESE’S MOTION TO DISMISS COMPLAINT"; the start of the introduction (two unnumbered paragraphs, as filed). Pass.
- Page 4: the end of the introduction, footnote 1 (single-spaced, indented), heading JURISDICTION, VENUE, AND STATUTORY BASIS FOR RELIEF, paragraphs 1 to 3, heading UNDISPUTED FACTS, paragraph 4. Pass.
- Page 5: paragraph 5 (the six claims), heading LEGAL STANDARD, paragraph 6. Pass.
- Page 6: paragraphs 7 and 8, heading I (bold italic at the left, two lines), paragraphs 9 to 11, with the block quotation after paragraph 9. Pass.
- Page 7: paragraphs 12 to 14 (the case citations). Pass.
- Page 8: paragraph 15 (end of argument I), heading II (bold italic, two lines), paragraphs 16 to 19. Pass.
- Page 9: paragraph 19 continues, paragraph 20, heading CONCLUSION (centered), the date and the signature block at the right. Pass.

Defects found and fixed during the review: the introduction was numbered (two paragraphs too many; now the `unnumbered: 2` frontmatter count); the rule checks used a method that typst does not have (`.lower()`; fixed to the `lower()` function, and the two mutants now fail with the rule message).

## Known gaps and open choices

1. **Rules edition.** The 9013 text above is the 11.30.21 edition and has not been checked against the 2024 edition. The 2024 edition's Vt. LBR 5005-1(a) defers format to D. Vt. LBR 10(a) (read 2026-10-15, from a copy with a 2018 print date; the 4/1/2025 edition was not read). See gap 1 in the adversary-complaint README. Recheck before release.
2. **Typeface and size.** No rule names a face for filings; the template sets Times New Roman 12 pt, the house standard (David, 2026-10-17) and the exemplar's face.
3. **Footnotes.** A footnote is printed as a single-spaced indented block after its paragraph, not at the foot of the page. The template has no footnote mechanism; the exemplar's footnote 1 is reproduced in that form.
4. **Findings against the filing (recorded, not corrected in the sample).** (a) No consultation certificate under LBR 9013-1(b) appears in the text layer of the filing. (b) The title names no memorandum, and the filing contains argument in the same document; under LBR 9013-5(a) a combined document must name both in the caption and the docket entry (the docket text reads "Motion to Dismiss Adversary Proceeding"). The sample therefore does not set `memorandum: true`. (c) The caption names 92 defendants, which takes two and a half pages; the rule does not limit caption length, so this is a layout cost, not a defect.
5. **Italics and case names.** The filed text's italics are not visible in the text layer, so case names are roman in the sample.
6. **Companion papers.** Not produced: the proposed order (LBR 9013-1(h)), the notice of motion and the certificate of service (LBR 9013-6). A motion of this kind is filed with them.
7. **Main-case motions.** The template is for motions with the adversary caption. A motion in the main chapter 11 or chapter 13 case uses a different caption (no adversary number), which the template does not yet print. A new sample is needed to add it.
8. **Stipulated motions.** The "stipulated" title rule (LBR 9013-1(f)(1)) is enforced by the template only when `stipulated: true` is set; the consent statement in the body is content.
9. **Tier 2.** One filer in `usage/`; the tier-2 check against two or three filers is not done.
10. **Check gates.** `tools/check.sh` runs on this folder (typst and docx); the RESULT lines are under Engines.
11. **Tool naming.** As in the adversary-complaint README: `tools/overlay.sh` writes `OVERLAY-<id>.*`, and render output is `OUTPUT-<id>.pdf`.

## Engines

The typst template is the reference; the docx breaks every line and page where it does (Gate 4 CROSS-ENGINE, `params.cross_engine: gate` in `eval.yaml`).

DOCX (`docx/`): `reference.xml` (`base="xengine"`: the face is the typst template's through `{font}`, 12 pt, exact 27.6 pt body lines, 13.8 pt single lines, 1 in margins, the centered page-number footer; the markdown read as CommonMark, as cmarker reads it) and `vtb-motion-brief.lua` (on `lib/docx/xengine.lua`: the court lines, the two caption boxes as tables of one row per line with their foot rows as tables of their own, the title, the unnumbered introduction (`unnumbered` in the frontmatter) and the numbered paragraphs, headings, quotations, lettered items and the signature, each in the typst template's line boxes and spaces). `fb render` builds the reference document; no shell script and no committed `reference.docx` (fb-595.68.26; were `build-reference.sh`, `reference.docx` and `vtb.lua`, EB Garamond). Samples: `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice conversion; opened in LibreOffice, not Word).

- `tools/check.sh <dir>`: RESULT: 9 checks passed, 0 failed (DEF-TOC-001, DEF-COVER-001 pass).
- `tools/check.sh <dir> --engine docx`: RESULT: 13 checks passed, 0 failed; XENG-001..003 PASS (10 pages, 297/297 lines).
- The defendants are printed without a trailing `;` in both engines, as the earlier typst template printed them. Open: whether to end each with `;` as filed (tier 3).
- No latex engine for this folder.
