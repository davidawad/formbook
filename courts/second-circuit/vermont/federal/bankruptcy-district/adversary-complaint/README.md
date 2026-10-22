# vtb: adversary complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the District of Vermont (`vtb`), a complaint that starts an adversary proceeding under Fed. R. Bankr. P. 7001.
Folder: `courts/second-circuit/vermont/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md` (the filed complaint, transcribed in full except the statutory block quotes in ¶¶ 57–76, which are transcribed in full too; see gap 4) |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf`, 15 pages, vendored Times New Roman (metric twin) only, no warnings, on the shared cross-engine layout model (`lib/typst/xengine.typ`; fb-595.68.26) |
| overlay | ok: `usage/OVERLAY-fouracre-adversary-complaint.pdf` and `OVERLAY-fouracre-adversary-complaint.txt` (page map written by `tools/overlay.sh`, see gap 9) |
| pages reviewed | 15 of 15 on typst and docx (every page rendered at 40 dpi and viewed side by side after the last template change, 2026-10-22) |

## Governing rules

Primary sources, fetched 2026-10-14. The local rules are the Local Bankruptcy Rules of the District of Vermont as published on the court's site, edition dated 11.30.21 (see gap 1).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010, fetched 2026-10-14) | Fed. R. Civ. P. 10 applies in an adversary proceeding; the caption must substantially conform to the appropriate Official Form 416 (here the complaint caption, 416A, as the rule text shows). | `caption()`: court name, debtor block, plaintiff and defendant block, adversary number, title. |
| Fed. R. Bankr. P. 9004(a), (b) (https://www.law.cornell.edu/rules/frbp/rule_9004, fetched 2026-10-14; amended effective 2024-12-01) | (a) legible; (b) caption with the court's name, the case title, the case number and any adversary number, and a brief designation of the document. | `caption()` and the `title` frontmatter field. |
| Fed. R. Civ. P. 10(b) (via FRBP 7010) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `render-blocks()`: each body paragraph is numbered from 1; headings and quotations are not. |
| Vt. LBR 5005-1(a)(1) | 8½ × 11 inch page. | `paper: "us-letter"`. |
| Vt. LBR 5005-1(a)(2) (2021 edition) | Plainly legible. | Vendored Times New Roman (metric twin), 12 pt, no system fonts. |
| D. Vt. LBR 10(a)(4) (format of filings; the 2024 edition's Vt. LBR 5005-1(a) cross-refers to it; read 2026-10-15, see gap 1) | No less than 12 point font. No typeface named. | 12 pt body (`type-size`). |
| Typeface | Vt. LBR 1007-3(c)(1) names Arial, CG Times, Courier and Times New Roman, for master mailing lists only. No rule names a face for filings. | Times New Roman, the house standard and the exemplar's face (fb-595.68.26; was EB Garamond). See gap 3. |
| Vt. LBR 5005-1(a)(3) | Margins no less than ¾ inch, exclusive of page numbers. | `page-margin = 1in`. |
| Vt. LBR 5005-1(a)(4) | Consecutively paginated, page numbers centered at the bottom. | The page footer: the number centered in a single line box. |
| Vt. LBR 5005-1(a)(5) | 1.5 or 2.0 line spacing for text; 1.0 or 1.15 for quoted material and footnotes. | `pitch-double = 27.6pt`, Word's double spacing at 12 pt (2.0; the exemplar measures 27.8 pt). Quotations, caption, title and signature: `pitch-single = 13.8pt` (1.15). |
| Vt. LBR 5005-1(a)(6) | Footnotes used sparingly. | No footnotes in this filing. |
| Vt. LBR 5005-1(c)(1) to (4) | Caption of the case (debtor's full name, chapter, not the SSN); case number; a title; the party on whose behalf it is filed. | `debtor` (name, chapter, case number), `title`, the `Plaintiff` line. The caption must match the petition caption (Vt. LBR 1005-1). |
| Vt. LBR 5005-1(b) | Attorney name, office address, email, telephone and the party represented, below the signature line. | `signature.lines` (printed as given; see gap 5). |
| Vt. LBR 7008-1(a), (b) | Core or non-core statement for the complaint and for each cause of action; consent to final orders for non-core claims. | Content, not template: the sample states the core basis as the filing does ("This is a core proceeding under 28 U.S.C. § 157 (b)(2)(A), (E) and (O)"). The template does not check it (gap 6). |
| Vt. LBR 7005-1, 9013-6 | A certificate of service is filed with the paper it covers. | Not produced: the filing has a separate certificate of service (gap 7). |

Not produced by this template (separate papers, filed with the complaint): the adversary proceeding cover sheet, the summons, and the Rule 7.1 disclosure statement where required.

## Layout

- Caption: court name centered in bold, single-spaced; a single line below it the debtor box (`In re` and `Debtor.`, `Chapter` and `Case No.` beside it) and the parties box (a blank line, the plaintiffs, `Plaintiff,`, `v.`, the defendants, `Defendants.`; `Adv. Proc. No.` beside its second line), each a table of one row per single line, ruled at its right and closed by a bottom rule 6 pt below its last line. The parties box may run over a page (the motion-brief sample has over a hundred defendants).
- Title centered in bold, single-spaced, a single line below the caption and above the body.
- Body (27.6 pt lines): a `#` line is a centered bold heading (level 1); `##` centered bold (level 2); `###` bold italic at the left (level 3); headings at the body pitch, kept with the next block. A paragraph is numbered from 1. A list is lettered (a), (b), ... . A `>` block is a single-spaced quotation, half an inch in on both sides, a single line above and below. The last block is kept with the signature.
- Signature, never split: `signature.dated` a single line below the body, then a double line below it `signature.lines` 3 in. from the left margin.
- Typst 0.15.0 with the vendored `cmarker` package (see `typst/vtb-adversary-complaint.typ`).

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `court` (list of lines), `debtor` (`name`, `chapter`, `case_no`), `caption` (`plaintiffs` list, `defendants` list), `adv_no`, `title`, `signature` (`dated`, `lines` list).
- Body: blank-line-separated blocks. `#`, `##`, `###` are headings; `> ` is a single-spaced quotation (one quoted paragraph per block); `1. ` or `- ` starts a list (one item per line); any other block is a numbered paragraph.
- Do not put paragraph numbers in the text: the template numbers them.

## Overlay (red/blue)

`tools/overlay.sh` pairs each rendered page with the exemplar page sharing the most words, so the pairing is by text, not by index. Word-overlap by page (from `OVERLAY-fouracre-adversary-complaint.txt`):

| ours | filed | overlap |
|---|---|---|
| 1 | 1 | 57.3% |
| 2 | 2 | 42.8% |
| 3 | 4 | 47.2% |
| 4 | 5 | 58.9% |
| 5 | 6 | 80.0% |
| 6 | 7 | 79.7% |
| 7 | 8 | 66.0% |
| 8 | 9 | 54.4% |
| 9 | 11 | 49.4% |
| 10 | 12 | 67.1% |
| 11 | 13 | 82.3% |
| 12 | 15 | 47.2% |
| 13 | 16 | 54.2% |
| 14 | 18 | 52.4% |
| 15 | 18 | 19.2% |

The overlay is a diagnostic, not a score. The differences that show on the overlay are: the filed text is Times New Roman 12 pt and our render was EB Garamond 12 pt when this overlay was made (it is Times New Roman now); the filed paragraph numbers are not used (ours count from 1); and the filing runs over more pages because its statutory block quotes are not single-spaced. The page pairing is only approximate because the transcription omits some of the filed page text (gap 4).

## Review of the rendered pages (Gate 2 equivalent; made on the earlier EB Garamond render. The 15 pages of the current typst and docx renders were viewed side by side on 2026-10-22: every line and page alike, no defect found)

Every page of `OUTPUT-adversary-complaint.typst.pdf` was rendered at 60 dpi and viewed. Result per page:

- Page 1: caption, title, heading A and B, paragraphs 1 to 5. Caption closed by rules; the adversary number and chapter line up on the right. Pass.
- Page 2: heading C, paragraphs 6 to 15. Pass.
- Page 3: paragraphs 16 to 22 (no heading at the foot of the page). Pass.
- Page 4: paragraphs 23 to 27, heading D at the foot of the page with its paragraphs. Pass.
- Page 5: heading E, paragraphs 28 to 34, heading F at the foot of the page with its paragraphs. Pass.
- Page 6: paragraphs 35 to 39, heading G. Pass.
- Page 7: paragraphs 40 to 45. Pass.
- Page 8: paragraphs 46 to 55. Pass.
- Page 9: heading H, paragraphs 56 to 60. Pass.
- Page 10: paragraphs 60 to 65 (TILA). Pass.
- Page 11: paragraphs 66 to 68 (TILA and RESPA). Pass.
- Page 12: paragraphs 69 to 72 (RESPA disclosures, HOEPA). Pass.
- Page 13: paragraph 73, heading I (Count 5), paragraphs 74 to 77, and the first quotation. Pass.
- Page 14: quotations (b) and (c), paragraph 78, paragraph 79, heading J, prayer items (a) to (e). Pass.
- Page 15: prayer item (f), the date, and the signature block at the right. Pass. The signature is not separated from the prayer; it sits on the last page with item (f).

Defects found and fixed during the review (all in the template, none in the sample): the body was collapsed to one character per line (a method chain split across lines; fixed by parenthesising the expression); paragraphs overlapped (paragraph spacing was 0; now the block spacing equals the leading); the prayer items and quotations overlapped (same cause); centered headings were left-aligned (blocks were shrink-to-fit; now full width); the spacing was 1.5 instead of 2.0 (the leading was raised to 1.67 em).

## Known gaps and open choices

1. **Rules edition.** The Vermont local rules text is the 11.30.21 edition (the court's own PDF, `vtb.uscourts.gov/sites/vtb/files/2021 Local Bankruptcy Rules (11.30.21) - Final - Clean.pdf`). The court's local rules page lists a later edition (2024), and a "Summary of Local Rule Changes" (1.1.24) is on the site. The 2024 edition (`2024 Local Rules Revised 12.1.24.pdf`, read 2026-10-15) differs on the format rule: its Vt. LBR 5005-1(a) says "The District of Vermont Local Rule 10(a) applies to the format of filings and attachments" and drops the (a)(1) to (a)(8) list. The rows above still hold for 8½ × 11, 12 pt, 1 inch margins and double spacing (D. Vt. LBR 10(a)(1), (3), (4), (6)). The D. Vt. LBR 10(a) text was read from the court's `LocalRules.pdf`, which prints a 2018 date; its 4/1/2025 edition was not read. Recheck the 5005-1 and 10(a) text against the current editions before this doc type is released.
2. **Type size.** No Vermont local rule sets a type size for filings (the 12 pt minimum in LBR 1007-3(c) applies to master mailing lists only). 12 pt is used as the usual practice; the exemplar is Times New Roman 12 pt.
3. **Typeface.** No rule names a typeface for filings (see the Typeface row above); the template sets Times New Roman, the house standard (David, 2026-10-17) and the exemplar's face.
3a. **Judge initials.** The filed caption carries judge initials after the adversary number ("23- Hzp" in the text layer, illegible in the stamp). The sample writes `23-01001` without initials; the template prints `adv_no` as given.
4. **Transcription.** The sample transcribes ¶¶ 1–76 and the prayer. The filed paragraph numbers are not used, and the filing's own numbering is irregular (¶ 73 appears twice, and ¶ 66 appears after ¶ 76). The template numbers the sample consecutively, so the sample's numbers do not match the filed numbers. Italics in the filed text are not visible in the text layer and are not transcribed; case names are roman in the sample.
5. **Signature block (LBR 5005-1(b)).** The filed signature block gives "/s/ Todd Taylor, attorney for Diana Fouracre, Plaintiff" and the firm name in the docket, but no office address, email or telephone number. The rule requires those below the signature line. The sample reproduces what the exemplar shows; the template does not assert the rule (it cannot know the address). A filing from this doc type should carry them.
6. **Core and non-core (LBR 7008-1).** The template does not check the core statement or the consent for non-core claims. The sample's core statement follows the exemplar (core under 28 U.S.C. § 157(b)(2)(A), (E), (O)); the non-core consent is not in the exemplar, which is a finding against the filing, not the template.
7. **Companion papers.** Not produced: the adversary proceeding cover sheet, the summons, the certificate of service, the Rule 7.1 disclosure statement and any corporate disclosure statement.
8. **Length.** The render is 15 pages. The exemplar is 18 pages. 15 is one page over the 8-to-14-page target in the brief; the transcription includes the statutory text in full, so the difference is from the layout, not omitted content.
9. **Overlay naming.** `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `OVERLAY-<id>.txt`; the brief's `<id>-overlay.pdf` names are not what the tool writes. The tool was used as written (`tools/` is outside this box's scope). Render output is `OUTPUT-<id>.pdf` (the tool default) rather than `<id>.pdf`.
10. **Check gates.** `tools/check.sh` runs on this folder (typst and docx); the RESULT lines are under Engines.
11. **Tier 2.** Only one filer is in `usage/`. The brief asks for one exemplar per doc type; the tier-2 check against two or three filers is not done.

## Engines

The typst template is the reference; the docx breaks every line and page where it does (Gate 4 CROSS-ENGINE, `params.cross_engine: gate` in `eval.yaml`).

DOCX (`docx/`): `reference.xml` (`base="xengine"`: the face is the typst template's through `{font}`, 12 pt, exact 27.6 pt body lines, 13.8 pt single lines, 1 in margins, the centered page-number footer; the markdown read as CommonMark, as cmarker reads it) and `vtb-adversary-complaint.lua` (on `lib/docx/xengine.lua`: the court lines, the two caption boxes as tables of one row per line, the title, the numbered paragraphs, headings, quotations, lettered items and the signature, each in the typst template's line boxes and spaces). `fb render` builds the reference document; no shell script and no committed `reference.docx` (fb-595.68.26; were `build-reference.sh`, `reference.docx` and `vtb.lua`, EB Garamond). Samples: `usage/OUTPUT-adversary-complaint.docx` and `.docx.pdf` (LibreOffice conversion; opened in LibreOffice, not Word).

- `tools/check.sh <dir>`: RESULT: 9 checks passed, 0 failed (DEF-TOC-001, DEF-COVER-001 pass).
- `tools/check.sh <dir> --engine docx`: RESULT: 13 checks passed, 0 failed; XENG-001..003 PASS (15 pages, 362/362 lines).
- The defendants are printed without a trailing `;` in both engines, as the earlier typst template printed them (it dropped the `;` by accident). Open: whether the caption should end each defendant with `;` as filed (tier 3).
- No latex engine for this folder.
