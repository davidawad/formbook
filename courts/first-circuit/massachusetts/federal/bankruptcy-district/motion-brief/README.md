# United States Bankruptcy Court, D. Massachusetts (mab): motion with memorandum

- Court: `mab`, United States Bankruptcy Court for the District of Massachusetts (`courts/first-circuit/massachusetts/federal/bankruptcy-district/`)
- Doc type: `motion-brief` (motion under Fed. R. Bankr. P. 9013 with its supporting argument; here, a Rule 12(b)(6) motion to dismiss an adversary complaint)
- Exemplar: `usage/FILED-EXAMPLE-motion-brief.pdf` (*Roy v. The Sisters of Saint Ann d/b/a Anna Maria College*, Adv. Proc. No. 26-04027-EDK, Doc. 6, filed 2026-09-21, 15 pages; provenance in `usage/SOURCE.md`). The argument is inside the motion; there is no separate memorandum in the filing.
- Sample: `usage/INPUT-motion-brief.md` (full transcription of the filed motion, pages 1-15, with footnotes 1-3 and the certificate of service and service list).
- Status: template built, rendered, overlaid and page-reviewed (12 of 12 pages). Not reviewed by a human; `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...`, splits frontmatter, calls `mab-motion-brief`. |
| `typst/mab-motion-brief.typ` | Template. Caption (Rule 9004(b)), numbered paragraphs (MLBR 9013-1(a)), headings, tables, lists, footnotes, signature with the date beside it, certificate of service, service list. |
| `usage/INPUT-motion-brief.md` | Markdown sample: frontmatter (division, debtor, chapter, case numbers, parties, title, date, signature groups) and the body. |
| `usage/OUTPUT-motion-brief.typst.pdf` | `sh tools/render.sh courts/first-circuit/massachusetts/federal/bankruptcy-district/motion-brief usage/INPUT-motion-brief.md` (12 pages). |
| `usage/OVERLAY-saint-ann-motion-to-dismiss.pdf`, `.txt` | `sh tools/overlay.sh courts/first-circuit/massachusetts/federal/bankruptcy-district/motion-brief saint-ann-motion-to-dismiss` (red = ours, blue = filed, black = agree). |
| `usage/` | The filed exemplar and `SOURCE.md`. |

File names follow the repo's role convention: `INPUT-` for the markdown we feed in, `OUTPUT-` for our render, `OVERLAY-` for the comparison.

## Governing rules

Verification date: 2026-10-14.

| Rule | Requirement | Where the template uses it | Source and how checked |
|---|---|---|---|
| Fed. R. Bankr. P. 9013(a) | A request for an order is made by written motion, unless made in a hearing or the rules authorize an application | Document type | <https://www.law.cornell.edu/rules/frbp/rule_9013>, read 2026-10-14. |
| Fed. R. Bankr. P. 9013(b) | "A motion must state its grounds with particularity and set forth the relief or order requested." | `assert` in `mab-motion-brief`: the body must contain "respectfully requests" (the relief sentence), else the build fails. The phrase is a stand-in, not a legal test. | Same. |
| Fed. R. Bankr. P. 9013 (memorandum) | No memorandum requirement in the rule text. | Not required by the template; the argument may sit in the motion (see MLBR 9013-1(a)). | Same. |
| Fed. R. Bankr. P. 9004(b) | Caption: the court's name, the case title, the case number and a brief designation of the document | `caption()`: court, division, debtor and Chapter 11 / Case No. block, adversary parties and Adv. Proc. No., title | <https://www.law.cornell.edu/rules/frbp/rule_9004>, read 2026-10-14. |
| Fed. R. Bankr. P. 7012(b) | Fed. R. Civ. P. 12(b) applies in adversary proceedings | Cited in the body (the filer's text) | Cited by the exemplar; the rule text itself was not fetched in this box. |
| MLBR 9013-1(a) (D. Mass. Local Bankruptcy Rules, May 1, 2025) | The motion must be in writing, "setting forth each allegation in a numbered paragraph", "state with particularity the grounds", and set out the relief; "arguments and citations to authorities" may be in the motion "unless stated in a separate supporting memorandum filed concurrently with the motion" | `allegations()`: each paragraph is numbered; the argument in the motion is numbered with it, as in the filing | <https://www.mab.uscourts.gov/sites/mab/files/May%201%202025%20Rules.pdf>, downloaded and read with `pdftotext` 2026-10-14, p. 64. |
| MLBR 9013-1(c) | Responses due by the date in the hearing notice, or within 14 days of service, inclusive of the three-day mailing period in Rule 9006(f) | Not produced by the template; the motion's body does not state a deadline | Same PDF, p. 64. |
| MLBR 9013-3(a), (c) | Certificate of service filed with the motion, same manner and parties; it states the date, the manner, and the name and address of each person served | `# CERTIFICATE OF SERVICE` and `# SERVICE LIST` sections are the filer's; the template only keeps them unnumbered and places the signature block before the certificate | Same PDF, p. 67. |
| MLBR 9004-1 and Appendix 8 | Documents conform to Appendix 8: 8.5 x 11 in; double-spaced, except counsel identification, titles, footnotes (and block quotations, certificates, exhibits); margins at least 1 in; consecutive page numbers, first page need not show; 12-point body, 10-point footnotes; plain roman type | `page(margin: 1in)`, `body-leading` (1.35em, a 24 pt pitch at 12 pt: measured in the render), `type-size = 12pt`, `footnote-size = 10pt`, footer numbering from page 2 | Rule 9004-1 in the PDF above, p. 58. Appendix 8 is a separate PDF, <https://www.mab.uscourts.gov/sites/mab/files/APPENDIX%208%20GENERAL%20REQUIREMENTS%20OF%20FORM.pdf>, read with `pdftotext` 2026-10-14; it has subsections (a) to (c). |
| MLBR 9029-2 | Lists the D. Mass. Local Rules that apply in bankruptcy (26.5, 83.5.1, 83.5.4, 83.5.6, 83.6.1-83.6.3) | Not used | Same PDF, p. 73. D. Mass. Local Rule 7.1 is not in the list. No page limit for memoranda was found in the MLBR text (searched for "pages" and "page limit"). |

Typeface (checked 2026-10-14): face required: none. MLBR Appendix 8(c) asks for "a plain, Roman Type" at 12 pt body and 10 pt footnotes, and names no face. The May 1, 2025 MLBR text and Appendix 8 were searched for Times, Helvetica, Arial, Garamond, Century, Georgia, Courier and "font"; none names a face. Standing orders were not checked. Vendored substitute: none needed; the template keeps **EB Garamond** (`fonts/eb-garamond/`), the "No face named" row of `docs/FONTS.md`. Fit: n/a. The filed exemplar's body is Times New Roman, with Liberation Sans and Arial also embedded (`pdffonts`); the template does not reproduce it, since the rules leave the face open. Embedded in our render: EB Garamond Regular, Bold and Italic only.

## Overlay

`usage/OVERLAY-saint-ann-motion-to-dismiss.pdf` puts our render (red) over the best-matching exemplar page (blue). Pages are paired by word overlap. Diagnostic only, not a score. Pairings from the last run:

- ours p.1 ↔ filed p.1 (76%): caption and title.
- ours p.2 ↔ filed p.2 (53%): introduction and Jurisdiction. Our footnote 1 is on this page; in the filing it is on p.3.
- ours p.3 ↔ filed p.3 (48%): Background ¶¶ 5-7 and the bullets of ¶ 7, against the same passages.
- ours p.4 ↔ filed p.4 (46%): ¶¶ 8-11 and the Legal Standard.
- ours p.5 ↔ filed p.6 (69%): the Argument heading and ¶ 12. Paragraph 12 starts on filed p.5, so the best word-overlap page is one page off; the pairing is by text, not by page.
- ours p.6 ↔ filed p.7 (79%), p.7 ↔ filed p.8 (92%), p.8 ↔ filed p.9 (87%), p.9 ↔ filed p.10 (61%), p.10 ↔ filed p.11 (60%): the argument, paragraphs 13-26.
- ours p.11 ↔ filed p.14 (41%): conclusion, dated signature and certificate of service. The filing's certificate is on p. 14; the signature block is on p. 13.
- ours p.12 ↔ filed p.15 (87%): service list.

## Page review (Gate 2)

Every page of `OUTPUT-motion-brief.typst.pdf` was rendered at 60 dpi and viewed (12 of 12). Typst printed no warnings. Fonts embedded: EB Garamond Regular, Bold and Italic only.

| Page | Content | Result |
|---|---|---|
| 1 | Court, division, In re block (debtor, Chapter 11, Case No.), adversary parties, Adv. Proc. No., two-line title, introduction | OK. |
| 2 | Introduction (end), Jurisdiction and Venue 1-3, Relevant Background 4-5, footnote 1 begins | OK. |
| 3 | Background 5 (end) and 6, ¶ 7 with bullets, footnote 1 continues | ACCEPTED: footnote 1 is split across pages 2 and 3 (typst breaks a long footnote across pages; the filing keeps its footnote 1 on one page). |
| 4 | Background 8-9, Legal Standard 10-11 | OK. |
| 5 | Argument heading, Part I and its heading A, ¶ 12 (footnote 2) | OK. Headings are centered (Part I, bold caps) and flush left (A). |
| 6 | ¶¶ 13-16, italic case names and signals | OK. |
| 7 | ¶¶ 17-18, footnote 3 | ACCEPTED: about a fifth of the page is blank at the foot because the Part II heading and ¶ 19 are kept together (a heading never ends a page). |
| 8 | Part II heading and heading A (two lines), ¶¶ 19-20 | OK. |
| 9 | ¶ 20 (end), ¶ 21, heading B (two lines), ¶ 22 | OK. |
| 10 | ¶¶ 23-26 | OK. |
| 11 | CONCLUSION (¶ 27), dated signature block (Dated left, party block right), CERTIFICATE OF SERVICE, /s/ line | OK. |
| 12 | SERVICE LIST, single-spaced, flush left, three groups | OK. The filing sets its service list in two columns; ours is one column (see Gaps). |

Tier-2 findings (OPEN or ACCEPTED): the two ACCEPTED rows above (footnote split on p.2-3; blank foot of p.7); the service list is one column where the filing uses two.

## Known gaps

1. **Exhibits and the proposed order (Exhibit A) are not produced.** The exemplar's Exhibit A is a separate ECF attachment and is not in the file.
2. **Argument numbering is typed by the filer.** The template does not number headings (I., A.); the filing types them, and so does the sample.
3. **No separate memorandum document type.** MLBR 9013-1(a) allows a separate supporting memorandum filed concurrently; the template handles a body with no argument, but a memorandum-only sample was not built or tested.
4. **Service list layout.** The filing sets the service list in two columns; ours is one column, single-spaced, flush left.
5. **ECF header and footer** ("Case 26-04027 Doc 6 Filed ... Desc Main") are system stamps and are not reproduced.
6. **Typeface** is EB Garamond, not the Times New Roman body of the filing. No face is required by the rules. See the note under Governing rules.
7. **The 9013(b) check is a stand-in.** The `assert` looks for the phrase "respectfully requests". A motion that states the relief another way fails the build even though the rule is met. The check should be replaced when a better test exists.
8. **Certificate of service text** is the filer's, not the template's. MLBR 9013-3(c) lists what the certificate must state; the template does not check those elements.
9. **Searches tried (for the record):** CourtListener RECAP search (`type=rd`, `court=mab`, "memorandum of law" "motion", available only), which returned Adv. 26-04027 Doc. 6 (this motion), its Doc. 8 notice of hearing and the Doc. 6 proposed-order attachment, among others. This motion was chosen because it is a full motion with argument in one document, has a text layer, and is in the same court.

## Engines

Typst is the primary engine. The DOCX engine (`docx/`: `reference.docx` from `build-reference.sh`, `mab.lua` for the cover, caption, "Dated" signature table, single-spaced service list and numbering, `render.sh` for the section, footers and numbering part) is checked on the LibreOffice PDF of the `.docx`, as `docs/DOCX.md` describes.

- **Matches the typst output:** 12 pages in both; EB Garamond 12 pt body (embedded in the docx PDF); exact 24 pt line pitch; 0.5 in first-line indent; 1 in margins on Letter; 10 pt footnotes; the caption with the right and bottom rules; numbered paragraphs 1 to 27 with the certificate and service list unnumbered; "Dated" at the left and the signature groups at 3.0 in, kept together; the service list single-spaced, flush left, in one column; page numbers from page 2.
- **Differs (tier 2, not tier 1):** the bullet markers use Word's default symbol font (OpenSymbol, embedded) where typst uses a plain bullet; the tables carry Word's default rules; a footnote's break across pages can fall elsewhere than in typst. Word may paginate differently from LibreOffice.
- **DOCX BLOCKED items:** none for this doc type. Not run in this box: `sh tools/check.sh <dir> --engine docx` (the gates were not executed here), and opening the `.docx` in Microsoft Word (only LibreOffice 26.8.1 was available).
