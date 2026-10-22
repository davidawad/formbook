# N.D. W. Va. Bankruptcy Court (wvnb): motion with memorandum

Doc type: **motion with memorandum of law** in an adversary proceeding (FRBP 9013; LBR 9013-1(b)). Court: United States Bankruptcy Court for the Northern District of West Virginia. Folder: `courts/fourth-circuit/west-virginia/federal/bankruptcy-northern-district/motion-brief/`.

Status: exemplar=yes (one filer; the exemplar PDF itself is not in this snapshot, see SOURCE.md), render=ok (typst, no warnings, EB Garamond embedded, re-rendered 2026-10-14 for the fonts pass), overlay=fail this pass (`tools/overlay.sh` exits 1: "no exemplar pdf"; the earlier `usage/OVERLAY-sheehan-motion-to-dismiss.txt` is from an earlier pass and was not regenerated), pages reviewed 15 (every page of the three renders, 60 dpi PNG, viewed on 2026-10-14). Nothing here sets `status` in `court.json`.

Tier 2 is **not** closed: one filer is not the 2-3 the eval loop asks for, and the open findings are listed under "Known gaps". Nothing in this folder is marked done.

## Governing rules

Verified this pass against the court's own local rules PDF, `https://www.wvnb.uscourts.gov/sites/wvnb/files/local_rules/Local%20Rules.pdf` (146 pp.; cover reads "Effective Date: November 21.2003"; fetched 2026-10-14). That PDF is the only copy of the N.D. W. Va. local bankruptcy rules this pass could retrieve. It may have been amended since; the court's current text was not found.

FRBP 9013 and the Federal Rules are cited from their public texts (Cornell LII, fetched 2026-10-14, carried over from the earlier pass; not re-fetched this pass).

| ID | Rule | Requirement | Source (URL) | Where it lives in the template |
|---|---|---|---|---|
| WVNB-MOT-001 | FRBP 9013 | A request for an order is made by written motion, stating grounds with particularity and the relief sought. | https://www.law.cornell.edu/rules/frbp/rule_9013 | Title; relief paragraph (sample). The template does not check grounds. |
| WVNB-MOT-002 | LBR 9013-1(b) | Motion and application practice in adversary proceedings is governed principally by FRCP 5 and 7 and by FRBP 7005 and 7007. **Verified** (2003 text). | local rules PDF, LBR 9013-1 (p. 58-59) | Whole template. |
| WVNB-MOT-003 | LBR 9013-1(c)(2)(B) | Negative notice: "...an order may be entered granting the relief sought unless a specific written objection is filed within ____(__) days of the date of the mailing of this notice." **Verified** (2003 text; Appendix G-2). | local rules PDF, LBR 9013-1(c)(2)(B) (p. 59) | Boxed notice, printed only when the sample gives one (`notice`). The filed exemplar has none, so the transcription omits it. |
| WVNB-MOT-004 | LBR 9013-1(c)(2)(C) | A movant must prepare a notice for some motion types, with a fixed negative-notice period (e.g. compromise, sale, free-and-clear sale: 20 days). **Verified** (2003 text). | local rules PDF, LBR 9013-1(c)(2)(C) (pp. 59-60) | **Not generated.** The template prints whatever notice the sample gives. Known gap. |
| WVNB-MOT-005 | LBR 9013-1(c)(1) | A proposed order accompanies the motion "in appropriate circumstances", and should not bear the firm name. **Verified** (2003 text). | local rules PDF, LBR 9013-1(c)(1) (p. 59) | **Not generated.** Known gap. |
| WVNB-MOT-006 | LBR 9013-1(c)(3); LBR 5005-4.10 | Certificate of service; notice rules do not replace service on interested parties. Referenced, not re-read in full this pass. | local rules PDF, LBR 9013-1(c)(3), LBR 5005-4.10 | `certificate-of-service()` on its own page. Parties come from `service.parties` when given; `service.text` prints the certificate sentence as filed. |
| WVNB-MOT-007 | LBR 9004-2(a); FRCP 10(a); FRBP 9004(b), 7010 | Style of an adversary pleading "shall comply with Official Form 16C". **Verified** (2003 text). Form 16C is not in this folder; the caption layout is the complaint's (`../adversary-complaint/`). | local rules PDF, LBR 9004-2(a) (p. 57) | `court-caption()`. |
| WVNB-FMT-001 | LBR 9004-1 (font, spacing, page limit) | **Not in the 2003 text.** The 10-point minimum, the single-to-double spacing range and the 25-page limit came from a third-party search excerpt (courtrules.net, HTTP 403 on fetch). Unverified. | none verified | `type-size = 12pt`; `body-leading = 0.85em`; `page-limit = 25` documented, **not enforced**. Check the court's current LBR text before relying on any of it. |
| WVNB-FMT-002 | LBR 5005-3 (size of papers) | Letter size (8½ × 11 in) for all pages including attachments; no two-sided pages; no stapling or fastening except removable clips; no carbon copies; no tabbed exhibits. **Verified** (2003 text). Margins are not stated. | local rules PDF, LBR 5005-3 (p. 34) | Letter paper. 1 in margins and a page-number footer: convention, not a rule. |

## Table of contents and table of authorities (not generated)

The 2003 text read does not require either for a bankruptcy motion. The template does not generate either.

## Template changes this pass

The earlier template required a chapter line, a counsel block at top, and a fixed certificate sentence. The filed exemplar has no chapter line, puts counsel only in its signature block, and certifies service in one sentence with no parties list. The changes below keep the fixed layouts and make only those items optional:

- `chapter` is printed only when the sample gives it (`court-caption`).
- `counsel` (top-left block) is printed only when the sample gives it.
- `signature.parties` adds party lines above "s/" (e.g. "DAVID A. LEVINE / INDECO UNION / By Counsel").
- `service.text` prints the certificate sentence as given; otherwise the template builds it from `date` and `method`, as before.
- `service.parties` is optional; the list is printed only when given.
- Level-1 and level-2 headings are set to the body size. The default heading size (1.4 em) leaked through the show rule.

The fictional sample (`usage/INPUT-motion-brief.md`) renders unchanged except for the heading size.

## Fonts and layout

- **Typeface (fonts pass, 2026-10-14):** face required by the court's rules = **none named**. The 2003 local rules text (LBR 5005-3, 9004-2; no LBR 9004-1 in it) names no typeface; a courtrules.net mirror of LBR 9004-1 gives only a 10-point minimum and a single-to-double spacing range, and a search found no other source naming a face. Per `docs/FONTS.md`, no court-named substitute applies, so the template keeps **EB Garamond** (`fonts/eb-garamond/`, vendored; the only font used). The filed exemplar uses Times New Roman; that is convention, not a rule, so the difference stays.
- 12 pt body, 10 pt footnotes and footer. First-line indent 0.5 in. Level-1 headings centered caps; level-2 centered bold; level-3 left bold.
- Caption: two-column table as the complaint. Negative-notice box only when given.
- Signature block, then (for the transcribed sample) the certificate on its own page.

## What the samples show

**`usage/INPUT-motion-brief-2.md`** is a verbatim transcription of the exemplar: the motion (ECF 8) and the memorandum (ECF 8-1), in filing order. It has the caption, the relief paragraph, the memorandum's introduction, factual allegations (with a block quote and a second block quote), argument I-III with subsections A-D, a conclusion, a signature block with party lines, four footnotes and a certificate of service. Its render is 11 pages, with footnotes and italics.

**`usage/INPUT-motion-brief.md`** is **fictional** and was kept from the earlier pass: a transferee's motion to dismiss Counts I and II under FRCP 12(b)(6). It exercises the template's negative-notice box, a counsel block at top and a certificate listing parties; the filed exemplar has none of these. Its render is 4 pages. Its authorities (*Iqbal*, *Twombly*) are real, but their reporter and pin cites were written from memory and not checked.

File names: `tools/render.sh` writes `OUTPUT-<id>.pdf`; `tools/overlay.sh` reads that name and writes `OVERLAY-<id>.pdf` and `.txt`. The transcription's id is `sheehan-motion-to-dismiss`.

Render: `sh tools/render.sh <this-dir> usage/INPUT-motion-brief-2.md` → `OUTPUT-motion-brief-2.typst.pdf`, 11 pages, embedded EB Garamond only, no warnings. The fictional sample rendered to `OUTPUT-motion-brief.typst.pdf`, 4 pages, the same way.

## Overlay

`sh tools/overlay.sh <this-dir> sheehan-motion-to-dismiss` → `usage/OVERLAY-sheehan-motion-to-dismiss.pdf` (11 pages) and `.txt` (page map). Red is our render, blue is the filed exemplar, black is where they agree. Pages are paired by shared words, not index.

Page map (from the `.txt`):

Filed page N (N ≥ 4) is memorandum page N−3; the memorandum starts at filed p. 4.

| Our page | Filed page | Word overlap | What our page holds |
|---|---|---|---|
| 1 | 1 | 50% | Motion caption and relief paragraph; memorandum title, introduction |
| 2 | 6 | 55% | Facts: Employment Agreement, arbitration clause |
| 3 | 7 | 72% | Facts: block quote 2, Zydeco presentation |
| 4 | 8 | 72% | Facts (APL, Indeco, SEC filing); Argument I begins |
| 5 | 10 | 66% | Argument I (arbitration and forum selection) |
| 6 | 11 | 61% | Argument I (end), II. Standing |
| 7 | 13 | 65% | Argument III, A, B (contract; fraud begins) |
| 8 | 14 | 50% | Argument III.B (end), C |
| 9 | 16 | 65% | Argument III.C, D (conspiracy) |
| 10 | 18 | 51% | Conclusion and signature. The overlay pairs this with the filed certificate page, which repeats the signature block; the filed conclusion is on p. 17 |
| 11 | 3 | 94% | Certificate of service. Pairs with the motion's own certificate (filed p. 3); the memorandum's certificate is filed p. 18 |

The overlap is modest (50-72%) for a transcription, and the page layouts differ (font, leading, the filer's ECF header and footer). The pairing is a diagnostic, not a score. The page-11 match is the strongest, because the certificate's wording and parties line up.

## Page review (Gate 2 record, 70 dpi PNG, every page viewed)

Sheehan transcription (11 pages):

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption, relief paragraph, memorandum title, introduction | OK after the heading fix. The memorandum title and "INTRODUCTION" are at body size. The caption box reads "In re: GEOSTELLAR, INC., Debtor." (the template's form; the filing's caption has no "Debtor." line). |
| 2 | Factual allegations, block quote 1, footnote 1 | OK after the heading fix. |
| 3 | Block quote 1 (end), second contract, block quote 2 | OK. |
| 4 | Facts (APL, Indeco, SEC document) | OK. |
| 5 | Argument heading, I, footnote 2 | OK after the heading fix. |
| 6 | Argument I (end), II. Standing, footnote 3 | OK after the heading fix. |
| 7 | III. Failure to State a Claim, A, B | OK after the heading fix. |
| 8 | B (continued), footnote 4 | OK. |
| 9 | C, D, footnote 5 | OK. |
| 10 | Conclusion, dated line, signature block with party lines | OK after the heading fix. |
| 11 | Certificate of service and its signature | OK. |

Pages 3, 4, 8, 9 and 11 were viewed on the render before the heading fix. The fix touched only level-1 and level-2 headings; those five pages have no level-1 or level-2 heading (page 9 has only level-3 headings, which the fix does not change). Pages 1, 2, 5, 6, 7 and 10 were viewed again after the fix.

Fictional sample (4 pages), all viewed after the template changes: page 1 counsel block, caption, notice box, relief paragraph; page 2 relief, background, standard of review, argument headings; page 3 argument end, conclusion, signature; page 4 certificate listing three parties.

## Known gaps (tier-2 findings, OPEN)

Ordered by page. None blocks render or overlay; all are for the eval loop's tier-2 pass.

- **Pages 1-10, line spacing and length.** The filed memorandum is set in Times New Roman at roughly double spacing (about 28 text lines a page; estimated from the text layout, not measured; 19 pp. in total). Our render is 11 pp. at `body-leading = 0.85em`. The local-rules text read has no spacing rule, so this is a convention choice, not a rule. Whether the court's current text sets a range is not verified (see WVNB-FMT-001).
- **Page 1, font.** EB Garamond (vendored) against the filed Times New Roman. Vendored fonts only; left as is.
- **Page 1, caption labels.** The template prints "Case No." and "Adv. Pro. No."; the filed caption prints "BK. NO." and "Civil No.". The template's labels are generic and were not changed.
- **Page 1, debtor line.** The template adds "Debtor." under the debtor name; the filed caption does not.
- **Page 1, combined document.** The filing is two documents (motion, memorandum), each with its own caption. The transcription keeps one caption and runs the memorandum after the motion. The filed memorandum's own caption page is not reproduced.
- **Page 10, signature.** The party lines ("DAVID A. LEVINE / INDECO UNION / By Counsel") come from the sample's `signature.parties`, not from a rule. The template's "Respectfully submitted" and the firm lines match the filing.
- **Page 11, certificate.** The filed sentence is printed from `service.text`, so the template's generated certificate sentence and the parties list are not exercised by this sample; the fictional sample exercises them.
- **Negative notice and proposed order.** The filing has neither. The template does not generate the movant-prepared notices for fixed-period motion types (LBR 9013-1(c)(2)(C)) or the proposed order (LBR 9013-1(c)(1)). Known gaps.
- **Page limit.** The 25-page limit (WVNB-FMT-001) is documented but not counted, and its source is unverified.
- **Filer's text.** The transcription keeps the filer's own typos and any irregular citations ("failed to alleged", "MARTING"). The authorities in both samples were not checked. The exemplar's cites are the filer's, not ours.
- **Tier-2 exemplars.** Only one filer (Sheehan v. Levine, 2019). The eval loop wants two or three filers. Candidates are listed in `usage/SOURCE.md`; the best is the 2026 Storj Labs memorandum (ECF 131), which is a standalone memorandum and would need its own transcription.
- **Currency.** The local rules text is the 2003 edition. The court's current text was not found.

## Engines

**docx** (`docx/`): declarative `reference.xml` uses the shared xengine styles and inherits `{font}` from Typst. `wvnb-motion-brief.lua` builds the counsel block, caption, negative notice, signature block and certificate of service. `fb render --engine docx` creates the DOCX and LibreOffice PDF; tier-1 and cross-engine checks pass.

- Matches the typst form: EB Garamond 12 pt (the only face in the PDF, checked with `pdffonts`), exact 18 pt body line pitch (the typst pitch, measured from the typst PDF), 0.5 in first-line indent, letter, 1 in margins, 10 pt centered page-number footer, level 1 centered capitals, level 2 centered bold, level 3 left bold, native footnotes at 10 pt, block quotes indented 1 em on each side, the caption box with its right and bottom rules, the boxed negative notice, the signature in the 3.2 in column, and the certificate of service on its own page.
- Differs: the single-spaced blocks use exact 11.4 pt; the footnote separator is pandoc's default rule, not the 30% rule of the typst form; the level-1 capitals are typed into the file by the filter; the Sheehan sample runs 12 pages in the docx against 11 in typst (the same pitch, with different line breaks and one heading held to the next page).
- Reviewed: every page of `OUTPUT-motion-brief-2.docx.pdf` (12) and `OUTPUT-motion-brief.docx.pdf` (4), each against the typst page at 60 dpi.
- BLOCKED: `tools/check.sh --engine docx` cannot run: this snapshot has no `checks.yaml` for this court (exit 2, `Error: open .../checks.yaml: no such file or directory`). No check IDs were authored. Word is not available here, so the `.docx` is verified only by LibreOffice (converts without error; the XML parts are well-formed); no Word repair check was run.
