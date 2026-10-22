# oked: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Oklahoma (`oked`).
Folder: `courts/tenth-circuit/oklahoma/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: a transcription of pages 1 to 6, 18 to 19, 21 and 22 to 23 of the 23-page filing, with the omitted paragraphs marked in the sample |
| typeface | no face named by the court's rules (LCvR 5.2(a); checked 2026-10-15). Times New Roman (vendored), the house standard of `docs/FONTS.md`, on both engines. See gap 2 |
| render | ok (2026-10-22, fb-595.68.33): `usage/OUTPUT-complaint.typst.pdf` and `usage/OUTPUT-complaint.docx.pdf`, 10 pages each, Times New Roman only, no warnings |
| overlay | ran 2026-10-15, wrote `usage/OVERLAY-barrick-complaint.pdf` and `.txt`, exit 0. The exemplar PDF is not in the repo, so it was fetched from the URL in `usage/SOURCE.md` and passed to `tools/overlay.sh` as its third argument. **The pairing failed**: 9 of 10 sample pages paired at 0.0% word overlap, so the overlay is not a usable comparison for this exemplar (see gap 4) |
| pages reviewed | 10 of 10 typst and 10 of 10 docx (every page rendered at 50 dpi and viewed on 2026-10-22, after the last template change) |
| tier 2 | not judged against two filers: one exemplar only (gap 1) |

## Governing rules

Verified 2026-10-14.

| Source | Requirement | Where it is in the template |
|---|---|---|
| LCvR 5.2(a), E.D. Okla. Local Civil Rules, effective July 5, 2016 (as posted at https://www.oked.uscourts.gov/sites/oked/files/Local_Civil_Rules.pdf) | Paper 8½ × 11 in. Print style, footnotes included, not smaller than 12-point. Margins at least 1 in. on the top, bottom and sides. Line spacing no less than 1.5, excluding blocked quotations and footnotes. | `type-size = 12pt`, `page-margin = 1in`, `pitch-body = 24pt` (double) for the body; blocked quotations are single-spaced (`pitch-single = 13.8pt`), as the rule allows. The caption and signature block are single-spaced (gap 3). |
| Typeface, all E.D. Okla. Local Civil Rules (posted PDF, text extracted and searched 2026-10-15) | No typeface is named. LCvR 5.2(a) sets only the print style's minimum size (12-point), the margins and the line spacing. | `font-family = ("Times New Roman", "Liberation Serif")` (no face named; the house standard of `docs/FONTS.md`, vendored) |
| LCvR 3.1 (same document) | Civil cover sheet JS-44 with the complaint. Parties numbered separately in the caption, plaintiffs and defendants consecutively. The face of the complaint says whether the action is related to another case, and identifies it. | Parties are numbered by the template in `caption-rows()`: `(1)` to `(7)` for the exemplar. The related-case statement is author content (gap 6). |
| LCvR 5.3 (same document) | Personal data identifiers (SSN last four, minors' initials, year of birth, account last four) in pleadings. | Author responsibility (A). The sample contains none. |
| Fed. R. Civ. P. 10(a), https://www.law.cornell.edu/rules/frcp/rule_10 (as amended Dec. 1, 2007) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `court`, `case_number`, `caption`, `title` frontmatter. The Rule 7(a) designation is the title "COMPLAINT". |
| Fed. R. Civ. P. 10(b) (same page) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Each paragraph chunk is numbered by the template (`body()`). Paragraphs that the exemplar does not number carry `<!--unnumbered-->` in the sample: the lead-in, continuation paragraphs, the WHEREFORE paragraphs and "For her ... Cause of Action". |

Not checked against a rule: the 8½ × 11 paper size is the typst `us-letter` default and is fixed in the template. Rule 8(a) (a short and plain statement) is author content.

## Layout

- Court name centered, bold, in capitals; the caption is a column of party lines with a column of `)` marks after it, as in the exemplar. Each caption row is a fixed height, so the `)` column has one mark per line.
- Case number and the legends (`JURY TRIAL DEMANDED`, `ATTORNEY LIEN CLAIMED`) sit at the top right of the party column.
- Title "COMPLAINT" centered, bold, after the caption.
- Body: numbered paragraphs with a 0.5 in. first-line indent, number in the first half inch, text from 1 in. Headings: level 1 centered bold capitals; level 2 bold; level 3 bold italic. Headings are `sticky`, so they stay with the paragraph after them.
- Block quotations: single-spaced, indented 1 in. on the left and 0.5 in. on the right, 12 pt above and below, not numbered, not split across pages.
- Prayer items (a markdown list) are lettered `(a)`, `(b)`, ...
- Signature block: from 3.2 in., "Respectfully submitted,", one block per firm (firm in bold, "By: /s/" and the signer's lines), joined by "and", then `attorneys_for`; kept on one page, and the last paragraph is kept with it.
- Page number centered at the foot, 12 pt.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `court` (list of lines), `case_number`, `caption.plaintiffs` and `caption.defendants` (each a list of `{names: [lines], designation}`; split the names into the lines of the exemplar, one line per row), `legends`, `title`, `signature` (list of `{firm, signer, lines}`), `attorneys_for`.
- Body: blank-line-separated chunks. `#`, `##`, `###` headings; `>` block quotations (each line of a quotation starts with `>`); `- ` list items; `<!--unnumbered-->` before any paragraph that is not numbered; every other chunk is a numbered paragraph. Do not type paragraph numbers in the text: the template numbers them from 1.
- `<!--unnumbered--> [Paragraphs 22 to 87 are not transcribed in this sample.]` marks each omitted run of the exemplar. The template numbers the paragraphs that follow from the next number, so the sample's numbers differ from the filed numbers after an omission (gap 5).

## Known gaps and open choices

1. **One exemplar.** The brief asks for one per doc type, and EDOK's tier-2 rule asks for two or three filers. Search: CourtListener RECAP through the web search (the court's own CM/ECF search and CourtListener's search page are not reachable from this box: CloudFront returns 403). The one EDOK complaint found in CourtListener RECAP storage is this one (`gov.uscourts.oked.34387.2.0.pdf`). Clearinghouse lists two more EDOK complaints, *United States v. City of Sulphur*, 6:01-cv-00034 (2001), and *United States v. State of Oklahoma*, 6:25-cv-00265 (Aug. 5, 2025, ECF 2); the Clearinghouse page returned 403, so neither was fetched. Tier 2 is therefore **not** judged against two filers.
2. **Font.** No face is named by the court's rules (checked 2026-10-15 against the posted Local Civil Rules: LCvR 5.2(a) sets only the 12-point minimum, the margins and the line spacing, and no other LCvR names a typeface). Times New Roman 12 pt on both engines, the house standard of `docs/FONTS.md` and also the exemplar's face (fb-595.68.33: the docx named EB Garamond before the cross-engine port and failed DEF-FONT-002).
3. **Spacing of the caption and signature block (tier-1 reading, open).** LCvR 5.2(a) requires line spacing of at least 1.5 "excluding blocked quotations and footnotes", and it does not list captions or signature blocks as exceptions. The template single-spaces the caption, the signature block and the blocked quotations, as the exemplar does. Read literally, the caption and signature block would need 1.5 spacing. **Question for David:** do captions and signature blocks fall under the 1.5 requirement? The template follows the exemplar until David answers.
4. **Overlay pairing failed.** The exemplar's text layer uses a shifted font encoding (`pdftotext` returns punctuation-shaped gibberish for most of the text), so the overlay's word-matching pairs nearly every page with the wrong exemplar page, at 0.0% overlap. The overlay ran and wrote its files, but it does not show the difference between this template and the filing. The sample text was transcribed from the 60-dpi page images, so small wording errors are possible.
5. **Paragraph numbers.** The template numbers the sample's allegations from 1, so the numbers in the sample do not match the filing. Filed paragraphs 88 to 96 are sample paragraphs 22 to 30, filed 97 to 100 are sample 31 to 34, filed 105 to 113 are sample 35 to 43 (filed 101 to 104 are omitted from the sample). The sample has no paragraph numbers typed in its text.
6. **Civil cover sheet and related-case statement.** The JS-44 cover sheet (LCvR 3.1) and the related-case statement on the face of the complaint are separate filings or author content. They are not produced by this template.
7. **Jury demand.** The caption carries `JURY TRIAL DEMANDED`, as the exemplar does. The demand paragraph itself (Fed. R. Civ. P. 38) is author content and does not appear in the sample.
8. **Caption `)` column.** The exemplar uses a column of `)` marks. Both this template and the motion's caption box are the exemplar's convention for each doc type. Two EDOK filers are needed before either is called a convention for the court (tier 2).
9. **Footer type size.** The page number is 12 pt. LCvR 5.2(a) applies the 12-point minimum to the print style. The page number in the exemplar image looks smaller, so the template is above the exemplar here (observation from the image, not measured).
10. **Checks.** `sh tools/check.sh <dir> --engine typst|docx` run on this folder: typst 9 and docx 13 checks passed, 0 failed (2026-10-22). `tools/check-selftest.sh` needs a `checks.yaml` (court root); not run.
11. **Tool output names.** `tools/render.sh` writes `usage/OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `usage/OVERLAY-<id>.pdf` and `.txt`. The brief named `<id>.pdf` and `<id>-overlay.pdf`. The tools' names are used, because `overlay.sh` reads `OUTPUT-<id>.pdf`.

## Review of the rendered pages (`OUTPUT-complaint.typst.pdf` and `OUTPUT-complaint.docx.pdf`)

Every page of both engines rendered at 50 dpi and viewed on 2026-10-22, after the last template change; the two engines break every line and page alike (XENG-001..003 PASS), so each row holds for both. Compared with the exemplar pages the sample transcribes.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court name, the numbered party column with its `)` column, the case number and legends at the right, title, lead-in paragraph. The page ends after the lead-in: the two headings are kept with the first two lines of paragraph 1, which do not fit. | PASS |
| 2 | exemplar pp.1-2 | PARTIES heading, Barbara Barrick heading, paragraphs 1 to 6, BOCC heading. | PASS |
| 3 | exemplar p.3 | Paragraphs 7 and 8; the two block quotations (single-spaced, 1 in / 0.5 in), each whole on the page; "In its Motion" continuation unnumbered. | PASS |
| 4 | exemplar p.4 | Continuation paragraphs, unnumbered. | PASS |
| 5 | exemplar p.5 | Clardy heading; paragraphs 9 to 14. | PASS |
| 6 | exemplar p.6 | Paragraphs 15 to 21; the three Gazette quotations; Matthew Kasbaum heading. | PASS |
| 7 | exemplar p.18 | "[Paragraphs 22 to 87 ...]" marker; paragraphs 22 to 30; WHEREFORE (bold lead word, unnumbered). | PASS |
| 8 | exemplar p.19 | SECOND CAUSE heading (three centered lines); lead-in; paragraphs 31 to 36 with the "[Paragraphs 101 to 104 ...]" marker. | PASS |
| 9 | exemplar p.22 | Paragraphs 37 to 42. | PASS |
| 10 | exemplar p.23 | Paragraph 43, WHEREFORE, and the signature block on the same page: "Respectfully submitted,", two firms joined by "and", "Attorneys for Plaintiff Barbara Barrick". | PASS |

## Pass stamp

`usage/.check-typst.txt` and `usage/.check-docx.txt`, written by `tools/check.sh` (typst 9 and docx 13 checks passed, 0 failed, 2026-10-22).

## Engines

Typst is the primary engine; both engines are on the shared cross-engine layout model (fb-595.68.33; docs/EVAL-LOOP.md, "Cross-engine gate"), and `eval.yaml` gates it (`params.cross_engine: gate`).

- typst (`typst/oked-complaint.typ`): `lib/typst/xengine.typ`, every line a box of its pitch (24 pt body; 13.8 pt caption, headings, quotations and signature block), no space between paragraphs (uniform double spacing), explicit spaces between blocks (24 pt court title to caption and caption to title, 12 pt title to body, above a heading and around a quotation, 24 pt above the signature block, 12 pt inside it), the caption as three columns of single lines; the page number 12 pt in a single-pitch line ending 0.5 in above the page edge.
- docx: `docx/reference.xml` (`base="xengine"`, the face as `{font}`, the 12 pt page-number footer) and `docx/oked.lua`, which reads the frontmatter as written (`$FORMBOOK_META`) and the sample chunk by chunk as typst does, numbers the same paragraphs, and writes every paragraph with the typst pitch and spaces (`require("docx.xengine")`); the caption is one table row of three cells. No shell: `docx/build-reference.sh`, `docx/render.sh` and the binary `reference.docx` are gone.
- The baseline docx failed DEF-CONT-001: read with the whole document, pandoc made "[McCurtain County Sheriff Kevin Clardy]" in a quotation a link to the heading of that name and dropped the brackets; each chunk is now read alone, as cmarker reads it. It also failed DEF-FONT-002 (EB Garamond) and numbered every paragraph (it looked for an `[unnumbered]` marker the sample does not use). All pass now; XENG-001..003 PASS (10 = 10 pages, 295/295 lines).
