# nyeb: motion-brief

Doc type: **motion with memorandum of law** (the memorandum in support of a motion in an adversary proceeding) in the United States Bankruptcy Court, Eastern District of New York (`nyeb`).
Folder: `courts/second-circuit/new-york/federal/bankruptcy-eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the whole memorandum: counsel block, caption, headings, bulleted list, block quotations, signature) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 10 pages, typst 0.15.0, vendored Times New Roman only, no warnings; docx `usage/OUTPUT-motion-brief.docx.pdf` 10 pages, the same line and page breaks |
| overlay | ok: `usage/OVERLAY-bmt-memorandum-motion-to-dismiss.pdf` and `usage/OVERLAY-bmt-memorandum-motion-to-dismiss.txt` |
| pages reviewed | 10 of 10, typst and docx side by side (every page rendered at 60 dpi and viewed in its final state) |

File names follow `tools/render.sh` and `tools/overlay.sh` (`OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf/.txt`), not the `<id>.pdf` / `<id>-overlay.pdf` names in the brief (see the adversary-complaint README for the reason).

The exemplar is the memorandum of law itself. The notice of motion, the supporting affirmation, the proposed order and the proof of service that LBR 9013-1 also requires are separate papers and are not produced by this template (see Known gaps).

## Governing rules

Read from primary text on 2026-10-14 unless marked.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 9013(a) | A request for an order must be made by written motion unless an application is authorized or the request is made during a hearing. Source: https://www.law.cornell.edu/rules/frbp/rule_9013 (fetched 2026-10-14). | Cover caption and title; the memorandum is one of the papers in the motion. |
| Fed. R. Bankr. P. 9013(b) | A motion must state its grounds with particularity and set forth the relief requested. Same source. | `# PRELIMINARY STATEMENT` and `# CONCLUSION` state the relief; the sample is the memorandum, so the grounds are in the body. |
| E.D.N.Y. LBR 9013-1(a) | A motion must be in writing and specify the rules and statutory provisions it relies on and the legal authorities that support the relief, either in the motion or in a separate memorandum of law, and the factual grounds. Source: the court's posted "USBC-EDNY-Local-Bankruptcy-Rules.pdf", https://www.nyeb.uscourts.gov/sites/nyeb/files/USBC-EDNY-Local-Bankruptcy-Rules.pdf (text read 2026-10-14; PDF metadata shows modified 2026-09-21). | The memorandum body: `# LEGAL STANDARD` and `# ARGUMENTS AND AUTHORITIES` cite the rules and authorities. |
| E.D.N.Y. LBR 9013-1(c), (d), (e) | (c) a motion is accompanied by a proposed order; (d) notice goes to any entity with an interest; (e) proof of service with the motion. Same PDF. | Not produced by this template (see Known gaps). |
| E.D.N.Y. LBR 9004-1(a) | Plainly typed; no erasures; signed under Rule 9011; on 8 1/2 x 11 paper, not bound at the side. Same PDF. | `page-w` 8.5 in; signature block at the end. |
| E.D.N.Y. LBR 9004-2(a) | Caption: "United States Bankruptcy Court, Eastern District of New York"; title and chapter; case number and judge code; for an adversary proceeding, the full title and the adversary number. Same PDF. | Court title (fixed text); `case_number` with judge code; `chapter`; `adversary_number`; the parties block. |
| Fed. R. Bankr. P. 9004(a), (b) | Legibility; caption content as in the adversary-complaint README. Source: https://www.law.cornell.edu/rules/frbp/rule_9004 (fetched 2026-10-14). | As above. |
| Fed. R. Bankr. P. 7012 | Fed. R. Civ. P. 12 applies in an adversary proceeding. **Not fetched in this pass**; cited because the exemplar relies on it. | Text in the sample only. |
| Fed. R. Bankr. P. 7009 | Fed. R. Civ. P. 9(b) applies (particularity for fraud). **Not fetched in this pass**; cited by the exemplar. | Text in the sample only. |

No E.D.N.Y. rule read in this pass sets a font, size, margin, page limit, or a table of contents or authorities for a memorandum. Those are not asserted by the template (see Known gaps).

## Layout

- Letter paper, 1 inch margins, 12 pt Times New Roman (vendored in `fonts/`), double-spaced body (24 pt line boxes), single-spaced counsel block, court title, caption, title, block quotations and signature block (13.8 pt line boxes); 12 pt above a heading (none at the top of a page) and around each quoted paragraph.
- Page 1: counsel block at the top left (single-spaced); court title centred in bold caps (two lines); bordered caption: the `In re` debtor block with `Case No.` and `Chapter` at the right; the adversary parties with `v.` between them and the adversary number at the right; the title centred bold.
- Body: unnumbered paragraphs, first line indented 0.5 in, double-spaced. `#` headings centred bold, as typed; `##` bold left (for lettered argument headings); `###` bold italic left; `- ` bullets with a hanging indent; `> ` block quotations single-spaced and indented 1 in on both sides.
- Footer: matter number at the left (when given in the frontmatter, as the exemplar's "22376.3"); page number centred.
- Signature: "Dated:" and place at the left; signer's block from 3.25 in, single-spaced, line for line. The last paragraph is kept whole with the signature block, which is never split; a heading is kept with the paragraph after it.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `title`, `counsel` (list of lines), `caption.debtor` (`names`, `designation`), `caption.parties` (list of `{names, designation}`; `v.` is inserted between parties), `case_number` (with judge code), `chapter`, `adversary_number` (with judge code), `matter_number` (optional, footer), `signature` (`dated` lines, `lines`).
- Body is blank-line separated. `#` heading, `##` heading (bold left), `###` heading (bold italic left), `- ` bullets, `> ` block quotations (one `>` chunk per quotation; a `>` line alone separates its paragraphs), any other paragraph (unnumbered, first-line indent).

## What the overlay shows

`usage/OVERLAY-bmt-memorandum-motion-to-dismiss.pdf`: red is our render, blue is the filed exemplar, black is where they agree. The page map (`.txt`) pairs our 9 pages with exemplar pages by shared words: 1 to 1 (53.1%), 2 to 4 (59.4%), 3 to 5 (79.8%), 4 to 6 (79.5%), 5 to 8 (57.2%), 6 to 9 (75.2%), 7 to 10 (92.4%), 8 to 11 (90.8%), 9 to 13 (68.9%). The exemplar is 13 pages, and the pairs are not one-to-one because the page breaks differ. The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **Only the memorandum.** The notice of motion, the affirmation (if any), the proposed order (LBR 9013-1(c)), the notice list (LBR 9013-1(d)) and the proof of service (LBR 9013-1(e)) are not produced. The template is for the memorandum only.
2. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for two or three filers; the brief asks for one per doc type. Tier 2 is not judged against two filers yet.
3. **Page count.** Our render is 10 pages against the exemplar's 13. The exemplar uses a larger line pitch and more space around its quotations; tier 3, not chased.
4. **Font.** No E.D.N.Y. rule read names a font or size. 12 pt Times New Roman (vendored; the house standard, docs/FONTS.md) is used, the face of both filed exemplars (was EB Garamond until fb-595.68.25).
5. **Transcription keeps the filing's own errors.** The sample reproduces the filed text from its text layer, including "Idbal" (for Iqbal), "clams", "Judgement Statute", "apply" for "applies", "with prejudiced", "Ashcroft v. Idbal" and the duplicated "Fed. R. Civ. P.(b)". The template does not correct text. Case names are roman (the text layer has no italics).
6. **Table of contents and table of authorities.** None in the exemplar; none is produced. Whether the court requires either for a memorandum of this length was not checked.
7. **Footer matter number.** "22376.3" is the exemplar's matter number; it is in the sample's frontmatter, not the template.
8. **Checks.** `sh tools/check.sh <this folder> --engine typst` (9 passed, 0 failed) and `--engine docx` (13 passed, 0 failed, XENG-001..003 gated) write the `usage/.check-<engine>.txt` stamps (2026-10-22, fb-595.68.25). `tools/check-selftest.sh` needs a court root (`court.json`) and is not run for this doc-type folder.
9. **Rules not fetched.** FRBP 7009 and 7012 are cited from the exemplar, not from their text. Fed. R. Civ. P. 12(b)(6) and 9(b) are cited in the sample only.

## Review of the rendered pages (final state)

Typst and docx renders of 2026-10-22 (fb-595.68.25), each page viewed side by side at 60 dpi; the two engines break every line and page alike. Footer on every page: "22376.3" at the left (10 pt), the page number centred.

- Page 1: counsel block top left; court title; caption between rules (`In re` debtor block, `Case No.`, `Chapter`; plaintiff, `v.`, defendants; `Adv. Pro. No.` centred on the parties); the title (two lines, centred bold); PRELIMINARY STATEMENT; body begins. Pass.
- Page 2: body text, FACTUAL BACKGROUND heading. Pass.
- Page 3: body text ("¶¶ 51–55" kept whole), LEGAL STANDARD, "A. Rule 12(b)(6) Standard" with the paragraph after it. Pass.
- Page 4: body text. Pass.
- Page 5: "B. Rule 9(b) Standard", the five bullets (hanging), the Musicland paragraphs. Pass.
- Page 6: ARGUMENTS AND AUTHORITIES, "A." heading (two lines), the § 544(b) quotation (single-spaced paragraphs, 12 pt apart). Pass.
- Page 7: the quotation ends; the Murkoff paragraphs; "B." heading; the § 548(a)(1)(A) quotation (two paragraphs). Pass.
- Page 8: citation paragraph, "C." heading (three lines), body. Ends with white space: the two-line "D." heading moves on with its paragraph. Pass.
- Page 9: "D.", the five-limb quotation, "E.". Pass.
- Page 10: CONCLUSION, the closing paragraph, "Dated:" and the signature block, kept together. Pass.

Pages reviewed: 10 of 10.

## Build history

- Body paragraphs had no first-line indent until the indent was made inline (`h()` before the paragraph); `set par(first-line-indent:)` inside the block did not reach the cmarker paragraphs.
- The signature block stood alone on a page. Fixed by keeping the last chunk with the signature in one unbreakable block.

[Court index](../README.md) | [Formbook index](../../../../../../README.md)

## Engines

Both engines run on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"; fb-595.68.25): every line a box of its pitch (24 pt body, 13.8 pt single), explicit spaces between blocks, first-fit ragged-right lines, no kerning, ligatures or hyphenation; a section sign or a doubled one ("¶¶ 51–55") kept with its number.

docx (`docx/`): no shell. `docx/reference.xml` holds the Word styles (`base="xengine"`, the typst face through `{font}`: Times New Roman; the headings, "Body Text Keep", "Bullet"; `pandoc-from="markdown+smart-fancy_lists"`, so "(a)", "(1)" and "(A)" in quotations stay text, as in typst); `fb render` builds the reference document from it. `docx/nyeb-motion-brief.lua` builds the counsel block, caption, title, bullets, quotations and signature, and writes the footer with the frontmatter's `matter_number` (`$FORMBOOK_FOOTERS`) and the last section naming it (`$FORMBOOK_FINAL`; was `docx/render.sh`). Output: `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice, 10 pages). Reviewed: 10 of 10 pages of the `.docx.pdf`, side by side with the typst render at 60 dpi.

- **Matches typst:** every line and page break (Gate 4 XENG-001..003 gated in `eval.yaml`: 10 pages, 272/272 lines alike).
- **Differs:** bullets are typed `•` with a tab, not Word list numbering.
- **Not checked in Word:** no Word is available here. The file was opened and converted in LibreOffice.
