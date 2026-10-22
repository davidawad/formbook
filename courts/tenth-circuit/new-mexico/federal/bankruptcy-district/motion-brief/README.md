# nmb: motion-brief

Doc type: **motion with memorandum** (FRBP 9013 motion, or a memorandum of points and authorities in support of a contested matter) in the United States Bankruptcy Court for the District of New Mexico (`nmb`, Tenth Circuit).
Folder: `courts/tenth-circuit/new-mexico/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | **yes**: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer: Official Committee of Unsecured Creditors; ECF Doc 383, 54 pp., filed 2020-05-29; main case, contested matter). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md`: an excerpt transcribed from the exemplar's text layer: caption, lead-in, introduction, factual paragraphs 1 to 26, conclusion, prayer, signature. Omitted: TOC, TOA, argument sections, service list. The certificate is a placeholder (the filing has none). |
| older sample | `usage/INPUT-motion-brief-2.md`: FICTIONAL, structure test only (adversary caption, placeholder text). Kept as a second check of the adversary caption path. |
| typeface | No face named (FRBP 9004 and NM LBR, 2023 edition, read in full 2026-10-14; neither names a typeface, font size or spacing). Times New Roman (vendored metric twin), the house standard and the exemplar's face, on typst and docx alike (fb-595.68.32; the docx was EB Garamond). |
| render | ok (2026-10-22, `sh tools/check.sh`): `usage/OUTPUT-motion-brief.typst.pdf`, 12 pages, and `usage/OUTPUT-motion-brief-2.typst.pdf` (fictional), 3 pages; letter, Times New Roman only, no typst warnings, on the shared cross-engine layout model (`lib/typst/xengine.typ`; fb-595.68.32) |
| overlay | ok, mechanically (2026-10-15, `sh tools/overlay.sh <dir> roman-catholic-memorandum`): `usage/OVERLAY-roman-catholic-memorandum.pdf` (12 pp.) and `.txt` (page map). The page pairing is by shared words and is poor: the exemplar's TOC and TOA pages (2 to 9) have no counterpart in the sample, so pages drift. The overlay is a diagnostic, not a tier-2 verdict. |
| pages reviewed | 12 of 12 and 3 of 3 on typst and docx (every page rendered at 45 dpi and viewed side by side after the last template change, 2026-10-22). Exemplar pages viewed: 1 and 4 (caption; TOA). |
| check.sh / selftest | `sh tools/check.sh <dir>`: RESULT: 18 checks passed, 0 failed; `--engine docx`: RESULT: 26 checks passed, 0 failed (XENG-001..003 PASS on both INPUTs). No selftest for this doc-type folder. |

## Governing rules

Primary sources fetched 2026-10-14 (unchanged in 2026-10-15 pass).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| NM LBR 9013-1(a) (Bankr. D.N.M. local rules, 2023 PDF, see `../adversary-complaint/README.md` for the URL) | The title of a motion describes the relief sought. | Frontmatter `title` (the exemplar's title is long and describes the relief; the sample uses it verbatim). |
| NM LBR 9013-1(b) | An opposed motion says so; if concurrence was not obtained, the motion recites the attempts made. | Author content. Not a template check. |
| NM LBR 9013-1(d) | For opposed motions and motions requiring notice, the movant files and serves a notice that complies with NM LBR 9004-1; the objection deadline is 21 days from service unless ordered otherwise. | Not in the template. The notice is a separate paper; it is not generated here. |
| NM LBR 9013-1(i) | Briefs or supporting points need not be submitted with a motion, unless the court orders otherwise or NM LBR 7056-1 applies. | The memorandum section is written by the author. Its presence is a choice, not a rule. |
| NM LBR 7007-1 (adversary proceedings) | All motions in adversary proceedings are served; responses are due 21 days after service; optional replies 14 days after the response; briefs are optional unless the court orders otherwise. | Not a template check. |
| NM LBR 7007-2 | Sur-replies need leave of the court. | Not a template item. |
| NM LBR 9013-1(j) | A certificate of service is filed for all motions and notices, within a reasonable time; it may be part of the motion. | `certificate` frontmatter block, printed as "CERTIFICATE OF SERVICE" after the signature. The exemplar has none (see Open items). |
| NM LBR 9011-1(a) | Name, address, telephone and e-mail below the signature line. | `signature()`; the `email` line prints from the frontmatter. |
| NM LBR 9004-2 | Case number format with chapter, judge and location initials. | `case_number` frontmatter (`Case No. 18-13027-t11`) and `chapter`. |
| Fed. R. Bankr. P. 9004(a), (b) (not fetched in this pass; cited from memory) | Legible; caption with the court's name, the title, the case and adversary numbers, and a designation of the paper. | `caption()`: adversary caption (parties box and adversary number) or contested-matter caption (debtor box, chapter and case number). |

Not fetched in this pass (cited from memory; check before use): FRBP 9013 (motions state with particularity the grounds and the relief sought), FRBP 7012 (adversary-proceeding motion practice and consent statement), FRBP 9014. The template contains no assertion that depends on them.

## Layout

Same caption, numbering, quotation, sub-item, footnote, footer and signature layout as `../adversary-complaint/` (its README, Layout: 12 pt Times New Roman in 24 pt line boxes, 15 pt single lines for the court, caption, title, quotations and signature, 10 pt footnotes and footer in 11.5 pt lines, on the shared cross-engine layout model), with these differences:
- Lead-in paragraph and prayer are frontmatter, as in the complaint. Both now accept footnote markers `[^n]` (`with-notes`). Before 2026-10-15 a footnote marker in either was printed literally.
- Headings `#`, `##`, `###` are centered bold; the sample uses `# I. INTRODUCTION`, `### A. The Restructuring`.
- Numbered paragraphs: a typed `1.` is numbered by the template; an untyped paragraph is unnumbered. The filed memorandum numbers only its factual background (1 to 26) and leaves introduction and argument unnumbered; the sample does the same.
- Unnumbered paragraphs take the first-line indent (added 2026-10-15; the filed memorandum indents them).
- Caption, contested matter (no `parties`): debtor in a box on the left; `chapter` (optional) and `case_number` on the right; the title below. Added 2026-10-15, as in the filed exemplar p. 1. The adversary caption is unchanged.
- The `certificate` block is printed after the signature block as a centered "CERTIFICATE OF SERVICE" heading and a paragraph.

## Changes to the template, 2026-10-15

| Change | Why | Source |
|---|---|---|
| `caption()`: contested-matter branch when `parties` is empty | The filed exemplar is a main-case contested matter with a debtor box and no adversary parties box. | Exemplar p. 1; FRBP 9004(b) requires the court name, title, case and designation; it does not fix the box. |
| `caption()`: optional `chapter` line above the case number | The exemplar prints "Chapter 11" with the case number. | Exemplar p. 1; NM LBR 9004-2 (case-number form). |
| Unnumbered paragraphs take the first-line indent | The exemplar indents its unnumbered introduction and argument paragraphs. | Exemplar body text, pp. 9 to 11 (indentation read with `pdftotext -layout`; the exemplar's page images were not checked for this). |
| Lead-in and prayer pass through `with-notes()` | Footnote 1 sits in the lead-in in the exemplar. Before the change, a `[^1]` in the lead-in printed literally. | Found while rendering the sample (2026-10-15). |

Not changed: the paragraph body text and every rule-derived element. The fictional sample still renders to 3 pages with the adversary caption.

## Known gaps and open items

1. **No table of contents or table of authorities.** The filed memorandum has both (front matter, pp. 2 to 8 of the 54-page filing; the body starts on p. 9). The template has no table support and the rules in the table above do not require one. Not added; the sample omits them. Tier 2 gap, open.
2. **Typeface.** The exemplar is Times New Roman (`pdffonts`: TimesNewRomanPS-BoldMT, TimesNewRomanPSMT, non-embedded). The court names no typeface; the template sets Times New Roman (vendored metric twin), the house standard (fb-595.68.32; was EB Garamond in the docx).
3. **Date line.** The exemplar has "Dated: May 29, 2020" on the left of the signature line. The template's `signature()` reads `date_line` from the frontmatter but does not print it. Open: a small template change (left column of the signature block), not made here.
4. **Signature block layout.** The exemplar lists three counsel (names, address, phone, fax, e-mails). The template prints one signer, one firm and one e-mail line. The sample lists the other counsel as plain lines, and the wrapped e-mail line reads awkwardly on page 11. Open.
5. **Certificate of service.** The exemplar has no certificate: its ECF service list follows the signature. The rule (NM LBR 9013-1(j), as cited above) requires a certificate for a motion. The sample carries a bracketed placeholder so the template's certificate block is exercised. Which practice to follow is a choice for the filer; the template follows the rule.
6. **Contested-matter caption, right-aligned "Debtor.".** The exemplar right-aligns "Debtor." inside the box. The template prints the debtor list left-aligned. Open, minor.
7. **Page 4 (sample) gap.** On an earlier render the sticky heading "B. The RE Trust" moved to the next page and left space at the bottom of page 4. On the current render page 11 ends after the conclusion with space below it: the prayer is kept whole with the signature block, which does not fit there (both engines alike). Not changed.
8. **Argument and block quotations not in the sample.** The filed argument sections (the filed TOC lists them through p. 42) are not transcribed. The sample has no block quotation and no argument-level section, so the template's blockquote branch and the Table of Authorities are not exercised by the sample. Open.
9. **Sample is an excerpt.** The sample is 12 rendered pages (inside the 8 to 14 target) from a 54-page filing. The excerpt is the transcription; the omitted pages are listed in the sample's frontmatter comment.
10. **Overlay pairing.** `overlay.sh` pairs pages by shared words; the pairs drift because of the TOC/TOA and the excerpt. The overlay is a diagnostic and was looked at page by page; the pairing is not a measure of tier 2.
11. **Exemplar is one filer.** The tier-2 judgment in EVAL-LOOP calls for 2 or 3 filers. Only one motion-with-memorandum with a text layer was found (see "Searches tried" below). Open: a second filer's memorandum would be needed for a tier-2 verdict.

## Searches tried

### 2026-10-15 (this pass)

- CourtListener REST search (`api/rest/v4/search/?type=rd&court=nmb`, via curl): `"motion to dismiss" memorandum`; `"memorandum in support"`; `"brief in support"`; `"motion to dismiss" "in support"` (200 each). `"motion for summary judgment"` returned 429 (rate limited) and was not retried in this pass.
- Candidates with a PDF and a party filer: Smith v. Wilson (Adv. 12-01330-t, Doc 21, 2013-04-12, 5 pp., brief in support of motion to dismiss): **rejected**, no body text layer. Van Winkle (13-11743-t7, Doc 123, 2020-10-29, 23 pp., withdrawn memorandum in support of summary judgment): **rejected**, no body text layer. Roman Catholic Church of the Archdiocese of Santa Fe (18-13027-t11, Doc 383, 2020-05-29, 54 pp., Committee's memorandum in support of motion for standing): **used** as the exemplar.
- Many other nmb RECAP results were court opinions or orders (`Memorandum Opinion ...`). Those are not party filings and were not used.
- WebSearch (standard and extended, 4 queries): court opinions, local rules, and other courts' papers only.

### 2026-10-14 (earlier passes, kept as history)

Web search (standard and extended):
- "Bankruptcy Court for the District of New Mexico" adversary proceeding complaint pdf
- courtlistener nmb adversary complaint "District of New Mexico" bankruptcy 7001 recap document
- New Mexico bankruptcy adversary proceeding complaint filed pdf "Adv. Pro. No." "Bankr. D.N.M." (extended)
- govinfo USCOURTS-nmb adversary complaint pdf (extended)
- "Bankr. D.N.M." motion to dismiss adversary 2024 pdf memorandum (standard; returned only court opinions)
- "District of New Mexico" bankruptcy adversary "motion to dismiss" memorandum brief Rule 7012 (standard; returned only court opinions from 2004 to 2015 and a 2026 opinion)
- NM bankruptcy local rules PDF with formatting terms (extended; returned the local rules only)

CourtListener REST API (`api/rest/v4/search`, `type=r`, `court=nmb`), read through WebFetch:
- "adversary complaint": returned adversary dockets with complaints; the web page (`/?q=` form) returned HTTP 403.
- "motion to dismiss" memorandum adversary: one filing (Montoya v. Goldstein, Doc 9, brief in support of a motion to dismiss, 2020-07-06). No local PDF.
- "memorandum in support" or "motion for summary judgment" adversary: several motions with no local PDF (Quality Sleep Solutions 18-01035 Docs 20, 29, 36; Johnson v. Marker 24-01003 Doc 16, 2024-04-09; Pidcock v. McCune 21-01013 Docs 168, 185, 190). Only orders and opinions had local PDFs.

Direct storage downloads (`storage.courtlistener.com/recap/gov.uscourts.nmb.<id>/...`):
- Montoya v. Goldstein (168297) Docs 8 and 9: not PDFs (an XML error page).
- Johnson v. Marker (173562) Docs 6 and 16: not PDFs (an XML error page).

Second pass (2026-10-14, brief `fb-595.32.16`):
- WebSearch, standard and extended (about 14 queries): "Bankr. D.N.M." / "Bankruptcy Court for the District of New Mexico" with "memorandum in support", "memorandum brief", "motion to dismiss", "motion for summary judgment", "Adv. Pro. No."; Justia, DocketBird, PacerMonitor, Inforuptcy, Scribd, DocumentCloud, Casetext and Tenth Circuit appendix terms; Vaughan Co. Realtors (Wagner trustee) adversary briefs. Results were court opinions, local rules, or other districts' papers only.
- GovInfo `USCOURTS-nmb-1_*` packages downloaded and read (text layer, `pdftotext`): 04-ap-01159-0 (30 pp, carries a "PACER Cover Sheet for Electronically Filed Documents", but the filed document is the court's Memorandum Opinion, Doc 36), 06-ap-01078-0, 08-ap-01065-0, 09-ap-01093-0, 10-ap-01166-0, 10-ap-01200-1, 11-ap-01227-0, 12-ap-01110-1, 12-bk-12457-1, 13-ap-01069-0, 20-ap-01070-7, 24-bk-10185-0. All are opinions; none includes a party's motion or memorandum.
- CourtListener REST API: HTTP 429, `Retry-After` about 6.3 hours, so this pass could not query it again.
- inforuptcy.com docket page: HTTP 403.

What would settle it: a PACER copy (or a CourtListener RECAP upload by a user with access) of one of the motions above, with a text layer, saved as `usage/SAMPLE-<case>-<docket>-motion-brief.pdf` and recorded in `usage/SOURCE.md`. Then re-run the overlay.

## Engines

The typst template is the reference; the docx breaks every line and page where it does (Gate 4 CROSS-ENGINE, `params.cross_engine: gate` in `eval.yaml`).

**docx** (`docx/`): `reference.xml` (`base="xengine"`: the face is the typst template's through `{font}`, 12 pt, exact 24 pt body lines, 15 pt single lines, 10 pt footnotes in 11.5 pt lines, 1 in margins; Body Text Note, Body Text Keep, Body Text Whole, Sub Item and a Footnote Text that splits) and `nmb-motion-brief.lua` (on `lib/docx/xengine.lua`: reads the sample as the typst template does, the frontmatter strings as written and the body in blank-line-separated chunks as CommonMark, and writes the court lines, the caption as tables (the contested-matter box ruled on all sides, or the debtor's lines and the parties box), the title, the lead-in, the numbered and unnumbered paragraphs, headings, quotations, lettered sub-items, the prayer, the signature, the certificate of service and the footnotes in the typst template's line boxes and spaces; the footer with the short title and "Page X of Y" (PAGE and NUMPAGES fields) and the section through `$FORMBOOK_FOOTERS` and `$FORMBOOK_FINAL`). `fb render` builds the reference document; no shell script and no committed `reference.docx` (fb-595.68.32; were `build-reference.sh`, `reference.docx` and `nmb-filter.lua`, EB Garamond, with no title in the footer; the filter failed on the contested-matter sample). Samples: `usage/OUTPUT-<id>.docx` and `.docx.pdf` (LibreOffice conversion; opened in LibreOffice, not Word).

- `tools/check.sh <dir>`: RESULT: 18 checks passed, 0 failed (DEF-TOC-001, DEF-COVER-001 pass on both INPUTs).
- `tools/check.sh <dir> --engine docx`: RESULT: 26 checks passed, 0 failed; XENG-001..003 PASS (motion-brief: 12 pages, 321/321 lines; motion-brief-2: 3 pages, 63/63 lines).
- No TOC or TOA in these forms, so no field-update caveat applies.
- No latex engine for this folder.
