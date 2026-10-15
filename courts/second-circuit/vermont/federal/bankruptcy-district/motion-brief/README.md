# vtb: motion with memorandum

Doc type: **motion with memorandum** in the United States Bankruptcy Court for the District of Vermont (`vtb`): a motion under Fed. R. Bankr. P. 9013 in an adversary proceeding, with its argument in the same document.
Folder: `courts/second-circuit/vermont/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-rc-diocese-burlington-26-01005-motion-brief.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-diocese-motion-brief.md` (the filed motion, transcribed in full: caption, all 20 numbered paragraphs, the block quotation, the argument headings, the signature block) |
| render | ok: `samples/OUTPUT-diocese-motion-brief.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-diocese-motion-brief.pdf` and `OVERLAY-diocese-motion-brief.txt` (page map from `tools/overlay.sh`; pages paired one to one) |
| pages reviewed | 9 of 9 (each page rendered at 60 dpi and viewed; see the review below; re-rendered and all 9 pages viewed again 2026-10-15, no font change) |

## Governing rules

Primary sources, fetched 2026-10-14. The local rules are the Local Bankruptcy Rules of the District of Vermont as published on the court's site, edition dated 11.30.21 (see gap 1).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 9013 (https://www.law.cornell.edu/rules/frbp/rule_9013, fetched 2026-10-14; amended effective 2024-12-01) | (a) a request for an order is made by written motion unless the rule says otherwise; (b) a motion states its grounds with particularity and sets out the relief requested. | Content, not template. The sample states the grounds (Rules 12(b)(6), 7012; 28 U.S.C. §§ 157, 1334) and the relief in the first paragraphs. |
| Fed. R. Bankr. P. 9004(a), (b) (https://www.law.cornell.edu/rules/frbp/rule_9004, fetched 2026-10-14) | Legible; caption with the court's name, the case title, the case number and any adversary number, and a brief designation of the document. | `caption()` and the `title` frontmatter field. |
| D. Vt. LBR 10(a)(4) (format of filings; the 2024 edition's Vt. LBR 5005-1(a) cross-refers to it; read 2026-10-15, see gap 1) | No less than 12 point font. No typeface named. | 12 pt body (`type-size`). |
| Typeface | Vt. LBR 1007-3(c)(1) names Arial, CG Times, Courier and Times New Roman, for master mailing lists only. No rule names a face for filings. | Vendored EB Garamond kept, as `docs/FONTS.md` requires for a court that names no face. See gap 2. |
| Vt. LBR 9013-1(a)(1) to (3) (court's local rules, 11.30.21 edition, see gap 1) | Motion states with particularity the law (by title and section) and the procedure (by rule); clearly describes all relief requested; includes a brief summary of the facts. | Content. The sample's paragraphs 3 to 6 and the argument follow the rule's form; the template does not check them. |
| Vt. LBR 9013-1(b) | The motion certifies consultation with opposing counsel before filing (or asks for a waiver). | Not in the template: the exemplar does not have it (finding, see gap 4). |
| Vt. LBR 9013-1(f)(1) | A stipulated motion includes the word "stipulated" in its title and a statement of consent in the body. | `stipulated: true` in the frontmatter makes the template fail unless the title contains "stipulated" (VT-MB-001; mutant tested). |
| Vt. LBR 9013-1(h) | Each motion (except stipulated) includes a proposed order as an attachment. | Not produced: a separate attachment (gap 6). |
| Vt. LBR 9013-5(a) | A motion and its supporting memorandum may be one document only if both are named in the caption and the docket entry. | `memorandum: true` in the frontmatter makes the template fail unless the title contains "memorandum" (VT-MB-002; mutant tested). The sample does not set it: the exemplar's title does not name a memorandum (finding, gap 4). |
| Vt. LBR 9013-5(b) | A memorandum is succinct, does not exceed 15 pages without leave, and states a concise argument with citations. | Not asserted by the template (the page count is not checked). The sample is 9 pages in total, within the limit. |
| Vt. LBR 9013-6(a) to (c) | A notice of motion is filed with or before the motion; a certificate of service is filed with the motion (attached) or separately. | Not produced: the notice and certificate are separate documents (gap 6). |
| Vt. LBR 5005-1(a), (b), (c) | 8½ × 11 inch page; ¾ inch margins; page numbers centered at the bottom; 1.5 or 2.0 line spacing for text, 1.0 or 1.15 for quotations and footnotes; attorney identification below the signature line; caption, case number, title, party. | Same mechanisms as the adversary-complaint template (`paper`, `page-margin`, `numbering`, `body-leading`, `single-leading`, `signature`). |

## Layout

- Same caption as the adversary complaint: court name centered in bold on two lines; a two-column table with the debtor's `In re` block and the parties block (closed by a right and bottom rule) on the left, `Chapter` and `Case No.` on the right, `Adv. Proc. No.` on the second row. The title is centered in bold below the caption.
- Body: a `#` line is a centered bold heading (level 1); `##` centered bold (level 2); `###` bold italic at the left (level 3, the argument headings). A paragraph is numbered from 1, except the first `unnumbered` paragraphs (the introduction, as filed). A `>` block is a single-spaced, indented quotation. A footnote is transcribed as a single-spaced quotation block after its paragraph (gap 3).
- Signature: `signature.dated` on its own line, then `signature.lines` in the right half of the page.
- Typst 0.15.0 with the vendored `cmarker` package (see `typst/vtb-motion-brief.typ`).

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `court`, `debtor` (`name`, `chapter`, `case_no`), `caption` (`plaintiffs`, `defendants`), `adv_no`, `unnumbered` (number of leading paragraphs without a number), `title`, `signature` (`dated`, `lines`); optional `stipulated` and `memorandum` flags, which the template checks against the title.
- Body: as in the adversary-complaint contract.

## Overlay (red/blue)

`tools/overlay.sh` paired every page of the render with the same-numbered page of the filing (word overlap 43.6% to 86.9%). The overlay is a diagnostic, not a score. The visible differences: the filed text is Times New Roman 12 pt and our render is EB Garamond 12 pt; the caption runs onto page 3 in both (the filing's defendant list runs over two pages); the filing's italics and footnote placement are not reproduced.

## Review of the rendered pages (Gate 2 equivalent)

Every page of `OUTPUT-diocese-motion-brief.pdf` was rendered at 60 dpi and viewed. Result per page:

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
2. **Typeface and size.** Same as the adversary complaint (gap 3 there): no rule names a face for filings, so EB Garamond 12 pt (vendored) stays; the exemplar is Times New Roman 12 pt.
3. **Footnotes.** A footnote is printed as a single-spaced indented block after its paragraph, not at the foot of the page. The template has no footnote mechanism; the exemplar's footnote 1 is reproduced in that form.
4. **Findings against the filing (recorded, not corrected in the sample).** (a) No consultation certificate under LBR 9013-1(b) appears in the text layer of the filing. (b) The title names no memorandum, and the filing contains argument in the same document; under LBR 9013-5(a) a combined document must name both in the caption and the docket entry (the docket text reads "Motion to Dismiss Adversary Proceeding"). The sample therefore does not set `memorandum: true`. (c) The caption names 92 defendants, which takes two and a half pages; the rule does not limit caption length, so this is a layout cost, not a defect.
5. **Italics and case names.** The filed text's italics are not visible in the text layer, so case names are roman in the sample.
6. **Companion papers.** Not produced: the proposed order (LBR 9013-1(h)), the notice of motion and the certificate of service (LBR 9013-6). A motion of this kind is filed with them.
7. **Main-case motions.** The template is for motions with the adversary caption. A motion in the main chapter 11 or chapter 13 case uses a different caption (no adversary number), which the template does not yet print. A new sample is needed to add it.
8. **Stipulated motions.** The "stipulated" title rule (LBR 9013-1(f)(1)) is enforced by the template only when `stipulated: true` is set; the consent statement in the body is content.
9. **Tier 2.** One filer in `exemplars/`; the tier-2 check against two or three filers is not done.
10. **No check gates were run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape. This file is the Gate 2 record instead.
11. **Tool naming.** As in the adversary-complaint README: `tools/overlay.sh` writes `OVERLAY-<id>.*`, and render output is `OUTPUT-<id>.pdf`.

## Engines

docx (`docx/`: `build-reference.sh` builds `reference.docx`; `vtb.lua` writes the caption table, the numbering (first 2 paragraphs unnumbered, as the frontmatter says), the quotations, the lettered items and the signature). Render: `samples/OUTPUT-diocese-motion-brief.docx` and `.docx.pdf` (LibreOffice conversion, EB Garamond embedded, 10 pages; all 10 pages viewed beside the typst render, `/work/artifacts/vtb/motion-brief/`). The `.docx` converts in LibreOffice with no error.

- Matches the typst output: letter page, 1 in margins, EB Garamond 12 pt, body at the typst 2.0 pitch (exact 27.84 pt), single-spaced caption, footnote-style quotation and signature, 0.5 in first-line indent, centered bold headings, bold italic left argument headings, centered page number, the caption table with its rules.
- Differs: the docx is 10 pages, the typst render is 9. The caption (defendant list) runs over three pages in both, but line breaks follow LibreOffice's EB Garamond metrics, so the body is about one-third of a page longer and the conclusion and signature block move to page 10. The last body paragraph is kept with the signature block (Word-native keep-with-next); typst does not do this. Heading spacing is approximated from the typst `above`/`below` values.
- The defendants are printed without a trailing `;`, as typst prints them (the typst template's `#dn;` is read as code, so the semicolon is dropped there too; see the adversary-complaint Engines note). Lead to decide whether the typst template should print it.
- docx BLOCKED: `tools/check.sh --engine docx` does not run for this doc-type folder. It exits before any gate: the folder has no `court.json` and no `checks.yaml` (no check IDs exist to fail). Gates 0 to 3 are therefore not run for docx; the page review above is the only docx Gate 2 evidence.
