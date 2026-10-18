# nyeb: adversary-complaint

Doc type: **adversary complaint** (a complaint that starts an adversary proceeding) in the United States Bankruptcy Court, Eastern District of New York (`nyeb`).
Folder: `courts/second-circuit/new-york/federal/bankruptcy-eastern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md` (the whole complaint: caption, 69 numbered paragraphs, five cause headings, prayer, signature) |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-toyvation-adversary-complaint.pdf` and `usage/OVERLAY-toyvation-adversary-complaint.txt` |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed in its final state) |

File names follow `tools/render.sh` and `tools/overlay.sh` (`OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf/.txt`), not the `<id>.pdf` / `<id>-overlay.pdf` names in the brief, because the tools read and write those names and the brief forbids editing `tools/`.

## Governing rules

Each rule was read from its primary text on 2026-10-14. The local rules are the court's posted PDF (see the last row).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 7001 | A complaint to recover money or property, to determine validity or extent of a lien, and similar matters is an adversary proceeding; the complaint starts it. Source: https://www.law.cornell.edu/rules/frbp/rule_7001 (fetched 2026-10-14). | Scope of the doc type; the caption's "Adv. Pro. No." line. |
| Fed. R. Bankr. P. 7010 | Fed. R. Civ. P. 10 applies to a pleading in an adversary proceeding, except that the caption must substantially conform to Official Form 416A. Source: https://www.law.cornell.edu/rules/frbp/rule_7010 (fetched 2026-10-14). | `caption()`: the court line, the debtor and case block, the adversary parties block, the title. Numbered allegations (Rule 10(b)) are numbered by `render-body()`. |
| Fed. R. Bankr. P. 9004(b) | A paper filed must have a caption stating (1) the court's name, (2) the case's title, (3) the case number and, if appropriate, the adversary-proceeding number, and (4) a brief designation of the document's character. Source: https://www.law.cornell.edu/rules/frbp/rule_9004 (fetched 2026-10-14). | Court title line; `Case No.` and `Chapter` lines; `Adv. Pro. No.` line; the title "COMPLAINT". |
| Fed. R. Bankr. P. 9004(a) | Legibility; common abbreviations acceptable. Same source. | Type size and the vendored font (see Known gaps). |
| E.D.N.Y. LBR 9004-1(a) | (i) plainly typed, printed or copied; no erasures or interlineations that materially deface; signed under Bankruptcy Rule 9011. (ii) on 8 1/2 x 11 inch paper, not stapled or otherwise bound on the side. Source: the court's posted "USBC-EDNY-Local-Bankruptcy-Rules.pdf" (https://www.nyeb.uscourts.gov/sites/nyeb/files/USBC-EDNY-Local-Bankruptcy-Rules.pdf, text read 2026-10-14; the PDF metadata shows modified 2026-09-21). | `page-w` 8.5 in; `page-h` is set by the paper; signature block signed "/s/" under the sample's frontmatter. The template does not check the signature. |
| E.D.N.Y. LBR 9004-2(a) | Caption states "United States Bankruptcy Court, Eastern District of New York", the title and chapter, the case number and the judge code (after the petition), and for an adversary proceeding the full title of the lawsuit and the adversary proceeding case number. Same source. | Court title (the fixed court name); `case_number` (which carries the judge code, e.g. `26-43344-ess`); `chapter`; the parties block; `adversary_number`. |
| Fed. R. Civ. P. 10(b) (incorporated by Rule 7010) | Claims in numbered paragraphs. Text read from the Rule 7010 incorporation only; the Rule 10 text itself was not fetched in this pass. | Numbered paragraphs from 1 on; the lead-in, headings and prayer lead-in are unnumbered. |

Not produced by this template (separate papers, not part of the complaint): the summons (issued by the clerk), the adversary cover sheet and the filing fee; the Rule 7008 statement, if required by the case; any corporate disclosure statement. The template does not check that any of these were filed.

## Layout

- Letter paper, 1 inch margins, 12 pt EB Garamond (vendored in `fonts/`), double-spaced body (24 pt pitch), single-spaced caption and signature block.
- Page 1: court title centred in bold caps (two lines), then a bordered caption block: the debtor's `In re` block with case number and chapter at the right; then the adversary block with the parties, `-against-` between them, and the adversary number and the title at the right. Title bold.
- Body: numbered paragraphs (number at 0.5 in, text at 1 in, wrapped lines return to 1 in); headings bold caps centred (`#`), cause headings bold caps centred over two lines when long; the prayer is a lead-in ("WHEREFORE, plaintiff demands judgment:") followed by lettered items (a), (b), ...
- Footer: page number centred. No header; the ECF header on the exemplar is not reproduced.
- Signature block: "Dated:" at left; signer's block at right, single-spaced.
- The last paragraph or prayer item and the signature block are kept together (unbreakable block); a heading and the paragraph after it are kept together (`sticky`).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `title`, `caption.debtor` (`names`, `designation`), `caption.parties` (list of `{names, designation}`; `-against-` is inserted between parties), `case_number` (with judge code), `chapter`, `adversary_number` (with judge code), `lead_in` (unnumbered lead-in, optional), `signature` (`date`, `lines`).
- Body is blank-line separated. `#` heading (centred bold caps), `##` (centred bold), `###` (bold italic, left), a `1. ` list (lettered by the template: the prayer), a `> ` quotation (single-spaced, indented), `WHEREFORE` paragraph (unnumbered), any other paragraph (numbered by the template).
- Do not number paragraphs in the text; the template numbers them.

## What the overlay shows

`usage/OVERLAY-toyvation-adversary-complaint.pdf`: red is our render, blue is the filed exemplar, black is where they agree. The page map (`.txt`) pairs each of our 9 pages with the exemplar page sharing most words: 1 to 1 (80.0%), 2 to 2 (59.2%), 3 to 4 (42.9%), 4 to 5 (59.8%), 5 to 6 (82.9%), 6 to 7 (81.5%), 7 to 8 (73.4%), 8 to 9 (61.1%), 9 to 10 (87.7%). The exemplar is 10 pages. Pairing is by shared words, so the page breaks differ and the pairs are not one-to-one; the low score on page 3 has not been traced to a cause. The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **Adversary number is not on the exemplar.** The filed complaint's caption has no "Adv. Pro. No.", but LBR 9004-2(a) requires it for an adversary proceeding. The template follows the rule. The sample adds `26-01152-ess`, taken from the CourtListener docket record (adversary case 1-26-01152), not from the filing. David should confirm the number and whether the court's clerk expects it on the caption.
2. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for two or three filers; the brief asks for one per doc type. Tier 2 is not judged against two filers yet.
3. **Font.** No E.D.N.Y. rule names a font or size (LBR 9004-1 and 9004-2 do not; Rule 9004(a) says only that a paper must be "clearly legible"). The template uses 12 pt EB Garamond, the only font vendored in `fonts/`. The exemplar is set in a Times-family font, so its text looks larger. Whether a Times-metric font should be vendored is a choice for David.
4. **Page count.** Our render is 9 pages against the exemplar's 10. The cause has not been determined (font metrics and the exemplar's line breaks are the likely candidates).
5. **Transcription.** The sample is the filed text from its text layer. Two extraction artifacts are corrected: "Venue isMmm proper" is written "Venue is proper", and the stray "that that" in paragraph 46 is kept as filed. Case names are roman in the transcription (the text layer has no italics). Typographic errors in the filing are kept as filed.
6. **Paragraph numbering.** The template numbers paragraphs; the transcription has 69 numbered paragraphs, the same count as the filed last paragraph (69). Each filed paragraph number was not compared individually.
7. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court-root shape (`court.json`, `rules.md`) and are not run for this doc-type folder; the brief forbids editing `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type. No stamp is written.
8. **Rule 9004-1 signature.** Signature under Rule 9011 is shown as the "/s/" line in the sample; the template does not verify it.

## Review of the rendered pages (final state)

- Page 1: court title; caption with `In re` block, `Case No.`, `Chapter`, plaintiff and defendants, adversary number and title; lead-in; "JURISDICTION AND VENUE"; paragraphs 1 to 4; "FIRST CAUSE OF ACTION" heading (two lines); paragraph 5. Pass.
- Page 2: paragraphs 6 to 17, continuous numbering, no overlap. Pass.
- Page 3: paragraphs 18 to 24, text runs to the foot. Pass.
- Page 4: paragraphs 25 to 32; "SECOND CAUSE OF ACTION" heading kept with paragraph 28. Pass.
- Page 5: paragraphs 33 to 46. Pass.
- Page 6: paragraphs 47 to 55. Pass.
- Page 7: paragraph 56; "THIRD CAUSE" and "FOURTH CAUSE" headings (two lines each), paragraphs 57 to 65. Pass.
- Page 8: paragraphs 66 to 69, "FIFTH CAUSE" heading. Pass.
- Page 9: "WHEREFORE" lead-in, prayer items (a) to (e), "Dated:" and the signature block, kept together. Pass.

Pages reviewed: 9 of 9.

## Build history

- The first render had paragraph-spacing 0 (typst `spacing` is the gap between paragraphs, `leading` the gap between lines), so consecutive paragraphs overlapped. Fixed by setting `spacing` to the double-spacing pitch in the entry point.
- Headings had no gap below them (their block height is one line); fixed with `below: body-leading`.
- The signature block was alone on the last page, and the WHEREFORE lead-in was separated from its items. Fixed by keeping the last chunk with the signature in one unbreakable block and making the WHEREFORE lead-in sticky.

[Court index](../README.md) | [Formbook index](../../../../../../README.md)

## Engines

docx (`docx/`): `sh docx/build-reference.sh docx/reference.docx` builds the reference (pandoc default, styles replaced, footer with a centred page number, letter page with 1 in margins); `docx/nyeb-adversary-complaint.lua` builds the cover, caption, numbered allegations, prayer and signature. `tools/render.sh --engine docx` uses the default path of `tools/render-docx.sh`. Output: `usage/OUTPUT-adversary-complaint.docx` and `.docx.pdf` (LibreOffice, 9 pages). Reviewed: 9 of 9 pages of the `.docx.pdf`, against the typst render (9 pages) at 60 dpi. LibreOffice converts the file with no error; `pdffonts` shows EB Garamond embedded.

- **Matches typst:** letter paper, 1 in margins; EB Garamond 12 pt; body on a 24 pt pitch with a 0.5 in first-line indent; caption with the rules, the `In re` / `Case No.` / `Chapter` block, the adversary block with `Adv. Pro. No.` and the title; numbered allegations (number at 0.5 in, text at 1 in, wrapped lines back at 1 in); unnumbered lead-in; prayer lettered (a) to (e); WHEREFORE kept with the prayer; signature block kept with the last prayer item; centred page number.
- **Differs:** paragraph numbers and prayer letters are typed text followed by a tab, not Word list numbering, so they do not renumber if a paragraph is added in Word. Exact line spacing puts glyphs a few points lower than typst's line box, so lines on a page sit up to about 5 pt lower, and page breaks differ (in the docx, prayer item (d) ends page 8 and (e) moves with the signature to page 9). The title is in the caption only: it is not written to the document properties.
- **docx BLOCKED (not run):** `tools/check.sh <doc-type-dir> --engine docx` (Gates 0 to 3) cannot run for this folder. It reads `court.json` and `checks.yaml` at the court root, and this court has no `checks.yaml` yet. No `usage/.check-docx.txt` stamp is written. The page review above and the font and page-size checks stand in for Gate 2 only; they are not a Gate 1 pass.
- **Not checked in Word:** no Word is available here. The file was opened and converted in LibreOffice.
