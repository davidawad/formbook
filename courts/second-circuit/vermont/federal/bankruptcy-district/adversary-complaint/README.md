# vtb: adversary complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the District of Vermont (`vtb`), a complaint that starts an adversary proceeding under Fed. R. Bankr. P. 7001.
Folder: `courts/second-circuit/vermont/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-fouracre-v-axos-23-01001-adversary-complaint.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-fouracre-adversary-complaint.md` (the filed complaint, transcribed in full except the statutory block quotes in ¶¶ 57–76, which are transcribed in full too; see gap 4) |
| render | ok: `samples/OUTPUT-fouracre-adversary-complaint.pdf`, 15 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-fouracre-adversary-complaint.pdf` and `OVERLAY-fouracre-adversary-complaint.txt` (page map written by `tools/overlay.sh`, see gap 9) |
| pages reviewed | 15 of 15 (each page rendered at 60 dpi and viewed; pages 1 to 15 after the last layout change, see the review below; re-rendered and all 15 pages viewed again 2026-10-15, no font change) |

## Governing rules

Primary sources, fetched 2026-10-14. The local rules are the Local Bankruptcy Rules of the District of Vermont as published on the court's site, edition dated 11.30.21 (see gap 1).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010, fetched 2026-10-14) | Fed. R. Civ. P. 10 applies in an adversary proceeding; the caption must substantially conform to the appropriate Official Form 416 (here the complaint caption, 416A, as the rule text shows). | `caption()`: court name, debtor block, plaintiff and defendant block, adversary number, title. |
| Fed. R. Bankr. P. 9004(a), (b) (https://www.law.cornell.edu/rules/frbp/rule_9004, fetched 2026-10-14; amended effective 2024-12-01) | (a) legible; (b) caption with the court's name, the case title, the case number and any adversary number, and a brief designation of the document. | `caption()` and the `title` frontmatter field. |
| Fed. R. Civ. P. 10(b) (via FRBP 7010) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `render-blocks()`: each body paragraph is numbered from 1; headings and quotations are not. |
| Vt. LBR 5005-1(a)(1) | 8½ × 11 inch page. | `paper: "us-letter"`. |
| Vt. LBR 5005-1(a)(2) (2021 edition) | Plainly legible. | Vendored EB Garamond, 12 pt, no system fonts. |
| D. Vt. LBR 10(a)(4) (format of filings; the 2024 edition's Vt. LBR 5005-1(a) cross-refers to it; read 2026-10-15, see gap 1) | No less than 12 point font. No typeface named. | 12 pt body (`type-size`). |
| Typeface | Vt. LBR 1007-3(c)(1) names Arial, CG Times, Courier and Times New Roman, for master mailing lists only. No rule names a face for filings. | Vendored EB Garamond kept, as `docs/FONTS.md` requires for a court that names no face. See gap 3. |
| Vt. LBR 5005-1(a)(3) | Margins no less than ¾ inch, exclusive of page numbers. | `page-margin = 1in`. |
| Vt. LBR 5005-1(a)(4) | Consecutively paginated, page numbers centered at the bottom. | `numbering: "1"`, `number-align: center`. |
| Vt. LBR 5005-1(a)(5) | 1.5 or 2.0 line spacing for text; 1.0 or 1.15 for quoted material and footnotes. | `body-leading = 1.67em`, measured pitch 27.8 pt at 12 pt (2.0 spacing; the exemplar's measured pitch is 27.8 pt too). Quotations: `single-leading`. |
| Vt. LBR 5005-1(a)(6) | Footnotes used sparingly. | No footnotes in this filing. |
| Vt. LBR 5005-1(c)(1) to (4) | Caption of the case (debtor's full name, chapter, not the SSN); case number; a title; the party on whose behalf it is filed. | `debtor` (name, chapter, case number), `title`, the `Plaintiff` line. The caption must match the petition caption (Vt. LBR 1005-1). |
| Vt. LBR 5005-1(b) | Attorney name, office address, email, telephone and the party represented, below the signature line. | `signature.lines` (printed as given; see gap 5). |
| Vt. LBR 7008-1(a), (b) | Core or non-core statement for the complaint and for each cause of action; consent to final orders for non-core claims. | Content, not template: the sample states the core basis as the filing does ("This is a core proceeding under 28 U.S.C. § 157 (b)(2)(A), (E) and (O)"). The template does not check it (gap 6). |
| Vt. LBR 7005-1, 9013-6 | A certificate of service is filed with the paper it covers. | Not produced: the filing has a separate certificate of service (gap 7). |

Not produced by this template (separate papers, filed with the complaint): the adversary proceeding cover sheet, the summons, and the Rule 7.1 disclosure statement where required.

## Layout

- Caption: court name centered in bold on two lines; a two-column table; left column has the debtor's `In re` block and the parties block, closed by a right and bottom rule; right column has `Chapter` and `Case No.` on the first row and `Adv. Proc. No.` on the second.
- Title centered in bold below the caption.
- Body: a `#` line is a centered bold heading (level 1); `##` centered bold (level 2); `###` bold italic at the left (level 3). A paragraph is numbered from 1. A list is lettered (a), (b), ... . A `>` block is a single-spaced, indented quotation.
- Signature: `signature.dated` on its own line, then `signature.lines` in the right half of the page.
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

The overlay is a diagnostic, not a score. The differences that show on the overlay are: the filed text is Times New Roman 12 pt and our render is EB Garamond 12 pt (x-height differs, so the lines do not line up letter by letter); the filed paragraph numbers are not used (ours count from 1); and the filing runs over more pages because its statutory block quotes are not single-spaced. The page pairing is only approximate because the transcription omits some of the filed page text (gap 4).

## Review of the rendered pages (Gate 2 equivalent)

Every page of `OUTPUT-fouracre-adversary-complaint.pdf` was rendered at 60 dpi and viewed. Result per page:

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
3. **Typeface.** No rule names a typeface for filings (see the Typeface row above), so the template keeps EB Garamond, as `docs/FONTS.md` requires for a court that names no face. The exemplar's Times New Roman is the filer's choice. EB Garamond at 12 pt has a smaller x-height, so the text looks smaller than the exemplar on the overlay; that is expected, not a defect.
3a. **Judge initials.** The filed caption carries judge initials after the adversary number ("23- Hzp" in the text layer, illegible in the stamp). The sample writes `23-01001` without initials; the template prints `adv_no` as given.
4. **Transcription.** The sample transcribes ¶¶ 1–76 and the prayer. The filed paragraph numbers are not used, and the filing's own numbering is irregular (¶ 73 appears twice, and ¶ 66 appears after ¶ 76). The template numbers the sample consecutively, so the sample's numbers do not match the filed numbers. Italics in the filed text are not visible in the text layer and are not transcribed; case names are roman in the sample.
5. **Signature block (LBR 5005-1(b)).** The filed signature block gives "/s/ Todd Taylor, attorney for Diana Fouracre, Plaintiff" and the firm name in the docket, but no office address, email or telephone number. The rule requires those below the signature line. The sample reproduces what the exemplar shows; the template does not assert the rule (it cannot know the address). A filing from this doc type should carry them.
6. **Core and non-core (LBR 7008-1).** The template does not check the core statement or the consent for non-core claims. The sample's core statement follows the exemplar (core under 28 U.S.C. § 157(b)(2)(A), (E), (O)); the non-core consent is not in the exemplar, which is a finding against the filing, not the template.
7. **Companion papers.** Not produced: the adversary proceeding cover sheet, the summons, the certificate of service, the Rule 7.1 disclosure statement and any corporate disclosure statement.
8. **Length.** The render is 15 pages. The exemplar is 18 pages. 15 is one page over the 8-to-14-page target in the brief; the transcription includes the statutory text in full, so the difference is from the layout, not omitted content.
9. **Overlay naming.** `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `OVERLAY-<id>.txt`; the brief's `<id>-overlay.pdf` names are not what the tool writes. The tool was used as written (`tools/` is outside this box's scope). Render output is `OUTPUT-<id>.pdf` (the tool default) rather than `<id>.pdf`.
10. **No check gates were run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, which this doc-type folder is not. This file is the Gate 2 record instead.
11. **Tier 2.** Only one filer is in `exemplars/`. The brief asks for one exemplar per doc type; the tier-2 check against two or three filers is not done.

## Engines

docx (`docx/`: `build-reference.sh` builds `reference.docx`; `vtb.lua` writes the caption table, the numbering, the quotations, the lettered items and the signature). Render: `samples/OUTPUT-fouracre-adversary-complaint.docx` and `.docx.pdf` (LibreOffice conversion, EB Garamond embedded, 15 pages; all 15 pages viewed beside the typst render, `/work/artifacts/vtb/adversary-complaint/`). The `.docx` converts in LibreOffice with no error.

- Matches the typst output: letter page, 1 in margins, EB Garamond 12 pt, body at the typst 2.0 pitch (exact 27.84 pt), single-spaced caption, quotations and signature (exact 13.2 pt), 0.5 in first-line indent on numbered paragraphs, lettered items, centered bold headings, bold italic left headings, centered page number in the footer, the caption table with the rules, the signature at 3 in.
- Differs: line breaks and page breaks follow LibreOffice's EB Garamond metrics, so a few lines wrap differently and some page breaks move (for example the 77(a) and 78 quotations start one page earlier in docx). Heading spacing is approximated from the typst `above`/`below` values. The last body paragraph is kept with the signature block (Word-native keep-with-next), which typst does not do.
- The defendants are printed without a trailing `;`, as typst prints them. The typst template writes `#for dn in c.defendants [#dn; \ ]`, and typst reads `#dn;` as code, so the semicolon is dropped in the typst PDF too. This is a typst defect (not changed here, `typst/` is out of scope for this task); the docx follows the typst output for tier 1. Lead to decide.
- docx BLOCKED: `tools/check.sh --engine docx` does not run for this doc-type folder. It exits before any gate: the folder has no `court.json` and no `checks.yaml` (no check IDs exist to fail). Gates 0 to 3 are therefore not run for docx; the page review above is the only docx Gate 2 evidence.
