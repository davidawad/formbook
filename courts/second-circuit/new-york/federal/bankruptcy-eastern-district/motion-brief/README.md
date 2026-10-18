# nyeb: motion-brief

Doc type: **motion with memorandum of law** (the memorandum in support of a motion in an adversary proceeding) in the United States Bankruptcy Court, Eastern District of New York (`nyeb`).
Folder: `courts/second-circuit/new-york/federal/bankruptcy-eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-nyeb-motion-brief-empirestategrandcouncil2601072.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-nyeb-motion-brief-bmtmemorandummotiontodismiss.md` (the whole memorandum: counsel block, caption, headings, bulleted list, block quotations, signature) |
| render | ok: `usage/OUTPUT-nyeb-motion-brief-bmtmemorandummotiontodismiss.typst.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-bmt-memorandum-motion-to-dismiss.pdf` and `usage/OVERLAY-bmt-memorandum-motion-to-dismiss.txt` |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed in its final state) |

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

- Letter paper, 1 inch margins, 12 pt EB Garamond (vendored in `fonts/`), double-spaced body (24 pt pitch), single-spaced counsel block, caption, block quotations and signature block.
- Page 1: counsel block at the top left (single-spaced); court title centred in bold caps (two lines); bordered caption: the `In re` debtor block with `Case No.` and `Chapter` at the right; the adversary parties with `v.` between them and the adversary number at the right; the title centred bold.
- Body: unnumbered paragraphs, first line indented 0.5 in, double-spaced. `#` headings centred bold caps; `##` bold left (for lettered argument headings); `###` bold italic left; `- ` bullets with a hanging indent; `> ` block quotations single-spaced and indented 1 in on both sides.
- Footer: matter number at the left (when given in the frontmatter, as the exemplar's "22376.3"); page number centred.
- Signature: "Dated:" and place at the left; signer's block at the right, single-spaced. The conclusion and the signature are kept together in one unbreakable block; a heading is kept with the paragraph after it.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `title`, `counsel` (list of lines), `caption.debtor` (`names`, `designation`), `caption.parties` (list of `{names, designation}`; `v.` is inserted between parties), `case_number` (with judge code), `chapter`, `adversary_number` (with judge code), `matter_number` (optional, footer), `signature` (`dated` lines, `lines`).
- Body is blank-line separated. `#` heading, `##` heading (bold left), `###` heading (bold italic left), `- ` bullets, `> ` block quotations (one `>` chunk per quoted paragraph; a `>` line alone keeps a quoted block together), any other paragraph (unnumbered, first-line indent).

## What the overlay shows

`usage/OVERLAY-bmt-memorandum-motion-to-dismiss.pdf`: red is our render, blue is the filed exemplar, black is where they agree. The page map (`.txt`) pairs our 9 pages with exemplar pages by shared words: 1 to 1 (53.1%), 2 to 4 (59.4%), 3 to 5 (79.8%), 4 to 6 (79.5%), 5 to 8 (57.2%), 6 to 9 (75.2%), 7 to 10 (92.4%), 8 to 11 (90.8%), 9 to 13 (68.9%). The exemplar is 13 pages, and the pairs are not one-to-one because the page breaks differ. The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **Only the memorandum.** The notice of motion, the affirmation (if any), the proposed order (LBR 9013-1(c)), the notice list (LBR 9013-1(d)) and the proof of service (LBR 9013-1(e)) are not produced. The template is for the memorandum only.
2. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for two or three filers; the brief asks for one per doc type. Tier 2 is not judged against two filers yet.
3. **Page count.** Our render is 9 pages against the exemplar's 13. The cause has not been determined (font metrics and the exemplar's line breaks are the likely candidates).
4. **Font.** No E.D.N.Y. rule read names a font or size. 12 pt EB Garamond is used because it is the only font vendored in `fonts/`. The exemplar is set in a Times-family font.
5. **Transcription keeps the filing's own errors.** The sample reproduces the filed text from its text layer, including "Idbal" (for Iqbal), "clams", "Judgement Statute", "apply" for "applies", "with prejudiced", "Ashcroft v. Idbal" and the duplicated "Fed. R. Civ. P.(b)". The template does not correct text. Case names are roman (the text layer has no italics).
6. **Table of contents and table of authorities.** None in the exemplar; none is produced. Whether the court requires either for a memorandum of this length was not checked.
7. **Footer matter number.** "22376.3" is the exemplar's matter number; it is in the sample's frontmatter, not the template.
8. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court-root shape and are not run for this doc-type folder. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type. No stamp is written.
9. **Rules not fetched.** FRBP 7009 and 7012 are cited from the exemplar, not from their text. Fed. R. Civ. P. 12(b)(6) and 9(b) are cited in the sample only.

## Review of the rendered pages (final state)

- Page 1: counsel block top left; court title; caption with `In re` debtor block, `Case No. 25-45914-ESS`, `Chapter 7`, plaintiff, `v.`, defendants, `Adv. Pro. No. 26-01072-ESS`; title; PRELIMINARY STATEMENT; body begins. Pass.
- Page 2: body text, FACTUAL BACKGROUND heading. Pass.
- Page 3: body text, LEGAL STANDARD heading, "A. Rule 12(b)(6) Standard" kept with the paragraph after it. Pass.
- Page 4: body text, "B. Rule 9(b) Standard", bullet list begins. Pass.
- Page 5: bullet list ends, citation paragraph, ARGUMENTS AND AUTHORITIES heading, "A." heading (two lines), § 544(b) quotation begins. Pass.
- Page 6: § 544(b) quotation continues, the Murkoff paragraph. Pass.
- Page 7: "B." heading, § 548(a)(1)(A) quotation, "C." heading (three lines), body. Pass.
- Page 8: "D." and "E." headings, five-limb quotation, short paragraphs. Ends with white space: CONCLUSION moved to page 9 with its signature. Pass.
- Page 9: CONCLUSION heading, closing paragraph, "Dated:" and the signature block, kept together. Pass.

Pages reviewed: 9 of 9.

## Build history

- Body paragraphs had no first-line indent until the indent was made inline (`h()` before the paragraph); `set par(first-line-indent:)` inside the block did not reach the cmarker paragraphs.
- The signature block stood alone on a page. Fixed by keeping the last chunk with the signature in one unbreakable block.

[Court index](../README.md) | [Formbook index](../../../../../../README.md)

## Engines

docx (`docx/`): `sh docx/build-reference.sh docx/reference.docx` builds the reference (pandoc default, styles replaced, footer with the matter number at the left and the page number on the centre tab, letter page with 1 in margins); `docx/nyeb-motion-brief.lua` builds the counsel block, caption, title, bullets, quotations and signature. `docx/render.sh` is the court's build (it runs pandoc with `--from markdown+smart-fancy_lists` and puts the frontmatter `matter_number` into the footer). Output: `usage/OUTPUT-nyeb-motion-brief-bmtmemorandummotiontodismiss.docx` and `.docx.pdf` (LibreOffice, 9 pages). Reviewed: 9 of 9 pages of the `.docx.pdf`, against the typst render (9 pages) at 60 dpi. LibreOffice converts the file with no error; `pdffonts` shows EB Garamond embedded.

- **Matches typst:** letter paper, 1 in margins; EB Garamond 12 pt; counsel block single spaced at the top left; court title; caption with the rules, `v.` between the parties and `Adv. Pro. No.` at the right; the title centred and bold; body on a 24 pt pitch with a 0.5 in first-line indent; `#` headings centred bold, `##` bold left, `###` bold italic left; bullets with a hanging indent; block quotations single spaced, indented 1 in on each side; "(a)", "(1)" and "(A)" in quotations stay text (fancy lists are off, as in typst); the conclusion kept with the signature block; footer with the matter number and a centred page number.
- **Differs:** bullets are typed `•` with a tab, not Word list numbering. Exact line spacing puts glyphs a few points lower than typst's line box, so body lines on later pages sit about 11 pt lower than typst (the page count is 9 in both, but the page breaks differ slightly). LibreOffice wraps the first party name in the caption differently in one place: `EMPIRE STATE GRAND COUNCIL ANCIENT AND` breaks before `AND` in the 3.8 in names column, where typst keeps `AND` on the line.
- **docx BLOCKED (not run):** `tools/check.sh <doc-type-dir> --engine docx` (Gates 0 to 3) cannot run for this folder. It reads `court.json` and `checks.yaml` at the court root, and this court has no `checks.yaml` yet. No `usage/.check-docx.txt` stamp is written. The page review above and the font and page-size checks stand in for Gate 2 only; they are not a Gate 1 pass.
- **Not checked in Word:** no Word is available here. The file was opened and converted in LibreOffice.
