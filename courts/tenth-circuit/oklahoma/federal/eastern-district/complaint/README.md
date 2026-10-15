# oked: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Oklahoma (`oked`).
Folder: `courts/tenth-circuit/oklahoma/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-barrick-6-23-cv-00129-complaint.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-barrick-complaint.md`: a transcription of pages 1 to 6, 18 to 19, 21 and 22 to 23 of the 23-page filing, with the omitted paragraphs marked in the sample |
| typeface | no face named by the court's rules (LCvR 5.2(a); checked 2026-10-15). EB Garamond stays, per `docs/FONTS.md` ("No face named"). See gap 2 |
| render | ok: `samples/OUTPUT-barrick-complaint.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings. Re-rendered 2026-10-15; `pdffonts` shows EBGaramond Regular, Bold and Italic embedded |
| overlay | ran 2026-10-15, wrote `samples/OVERLAY-barrick-complaint.pdf` and `.txt`, exit 0. The exemplar PDF is not in the repo, so it was fetched from the URL in `exemplars/SOURCE.md` and passed to `tools/overlay.sh` as its third argument. **The pairing failed**: 9 of 10 sample pages paired at 0.0% word overlap, so the overlay is not a usable comparison for this exemplar (see gap 4) |
| pages reviewed | 10 of 10 (every page re-rendered at 60 dpi and viewed on 2026-10-15) |
| tier 2 | not judged against two filers: one exemplar only (gap 1) |

## Governing rules

Verified 2026-10-14.

| Source | Requirement | Where it is in the template |
|---|---|---|
| LCvR 5.2(a), E.D. Okla. Local Civil Rules, effective July 5, 2016 (as posted at https://www.oked.uscourts.gov/sites/oked/files/Local_Civil_Rules.pdf) | Paper 8½ × 11 in. Print style, footnotes included, not smaller than 12-point. Margins at least 1 in. on the top, bottom and sides. Line spacing no less than 1.5, excluding blocked quotations and footnotes. | `type-size = 12pt`, `page-margin = 1in`, `line-pitch = 24pt` (double) for the body; blocked quotations are single-spaced, as the rule allows. The caption and signature block are single-spaced (gap 3). |
| Typeface, all E.D. Okla. Local Civil Rules (posted PDF, text extracted and searched 2026-10-15) | No typeface is named. LCvR 5.2(a) sets only the print style's minimum size (12-point), the margins and the line spacing. | `font-family = "EB Garamond"` (no face named, so the vendored default is kept; `docs/FONTS.md`) |
| LCvR 3.1 (same document) | Civil cover sheet JS-44 with the complaint. Parties numbered separately in the caption, plaintiffs and defendants consecutively. The face of the complaint says whether the action is related to another case, and identifies it. | Parties are numbered by the template in `caption-rows()`: `(1)` to `(7)` for the exemplar. The related-case statement is author content (gap 6). |
| LCvR 5.3 (same document) | Personal data identifiers (SSN last four, minors' initials, year of birth, account last four) in pleadings. | Author responsibility (A). The sample contains none. |
| Fed. R. Civ. P. 10(a), https://www.law.cornell.edu/rules/frcp/rule_10 (as amended Dec. 1, 2007) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `court`, `case_number`, `caption`, `title` frontmatter. The Rule 7(a) designation is the title "COMPLAINT". |
| Fed. R. Civ. P. 10(b) (same page) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Each paragraph chunk is numbered by the template (`body()`). Paragraphs that the exemplar does not number carry `[unnumbered]` in the sample: the lead-in, continuation paragraphs, the WHEREFORE paragraphs and "For her ... Cause of Action". |

Not checked against a rule: the 8½ × 11 paper size is the typst `us-letter` default and is fixed in the template. Rule 8(a) (a short and plain statement) is author content.

## Layout

- Court name centered, bold, in capitals; the caption is a column of party lines with a column of `)` marks after it, as in the exemplar. Each caption row is a fixed height, so the `)` column has one mark per line.
- Case number and the legends (`JURY TRIAL DEMANDED`, `ATTORNEY LIEN CLAIMED`) sit at the top right of the party column.
- Title "COMPLAINT" centered, bold, after the caption.
- Body: numbered paragraphs with a 0.5 in. first-line indent, number in the first half inch, text from 1 in. Headings: level 1 centered bold capitals; level 2 bold; level 3 bold italic. Headings are `sticky`, so they stay with the paragraph after them.
- Block quotations: single-spaced, indented 1 in. on the left and 0.5 in. on the right, not numbered.
- Prayer items (a markdown list) are lettered `(a)`, `(b)`, ...
- Signature block: "Respectfully submitted," on the right half, one block per firm, joined by "and", then `attorneys_for`.
- Page number centered at the foot, 12 pt.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `court` (list of lines), `case_number`, `caption.plaintiffs` and `caption.defendants` (each a list of `{names: [lines], designation}`; split the names into the lines of the exemplar, one line per row), `legends`, `title`, `signature` (list of `{firm, signer, lines}`), `attorneys_for`.
- Body: blank-line-separated chunks. `#`, `##`, `###` headings; `>` block quotations (each line of a quotation starts with `>`); `- ` list items; `[unnumbered]` before any paragraph that is not numbered; every other chunk is a numbered paragraph. Do not type paragraph numbers in the text: the template numbers them from 1.
- `[unnumbered] [Paragraphs 22 to 87 are not transcribed in this sample.]` marks each omitted run of the exemplar. The template numbers the paragraphs that follow from the next number, so the sample's numbers differ from the filed numbers after an omission (gap 5).

## Known gaps and open choices

1. **One exemplar.** The brief asks for one per doc type, and EDOK's tier-2 rule asks for two or three filers. Search: CourtListener RECAP through the web search (the court's own CM/ECF search and CourtListener's search page are not reachable from this box: CloudFront returns 403). The one EDOK complaint found in CourtListener RECAP storage is this one (`gov.uscourts.oked.34387.2.0.pdf`). Clearinghouse lists two more EDOK complaints, *United States v. City of Sulphur*, 6:01-cv-00034 (2001), and *United States v. State of Oklahoma*, 6:25-cv-00265 (Aug. 5, 2025, ECF 2); the Clearinghouse page returned 403, so neither was fetched. Tier 2 is therefore **not** judged against two filers.
2. **Font.** No face is named by the court's rules, so EB Garamond stays (`docs/FONTS.md`, "No face named"). Checked 2026-10-15 against the posted Local Civil Rules: LCvR 5.2(a) sets only the 12-point minimum, the margins and the line spacing, and no other LCvR names a typeface. The exemplar is Times New Roman 12 pt, which is the filer's choice and not a rule. EB Garamond at 12 pt has a smaller x-height, so the text looks smaller than the exemplar. The 12-point minimum is met. A Times-metric substitute (`Liberation Serif`, metric-compatible) is vendored and would remove the difference; switching is a decision for David, because the rule does not require it.
3. **Spacing of the caption and signature block (tier-1 reading, open).** LCvR 5.2(a) requires line spacing of at least 1.5 "excluding blocked quotations and footnotes", and it does not list captions or signature blocks as exceptions. The template single-spaces the caption, the signature block and the blocked quotations, as the exemplar does. Read literally, the caption and signature block would need 1.5 spacing. **Question for David:** do captions and signature blocks fall under the 1.5 requirement? The template follows the exemplar until David answers.
4. **Overlay pairing failed.** The exemplar's text layer uses a shifted font encoding (`pdftotext` returns punctuation-shaped gibberish for most of the text), so the overlay's word-matching pairs nearly every page with the wrong exemplar page, at 0.0% overlap. The overlay ran and wrote its files, but it does not show the difference between this template and the filing. The sample text was transcribed from the 60-dpi page images, so small wording errors are possible.
5. **Paragraph numbers.** The template numbers the sample's allegations from 1, so the numbers in the sample do not match the filing. Filed paragraphs 88 to 96 are sample paragraphs 22 to 30, filed 97 to 100 are sample 31 to 34, filed 105 to 113 are sample 35 to 43 (filed 101 to 104 are omitted from the sample). The sample has no paragraph numbers typed in its text.
6. **Civil cover sheet and related-case statement.** The JS-44 cover sheet (LCvR 3.1) and the related-case statement on the face of the complaint are separate filings or author content. They are not produced by this template.
7. **Jury demand.** The caption carries `JURY TRIAL DEMANDED`, as the exemplar does. The demand paragraph itself (Fed. R. Civ. P. 38) is author content and does not appear in the sample.
8. **Caption `)` column.** The exemplar uses a column of `)` marks. Both this template and the motion's caption box are the exemplar's convention for each doc type. Two EDOK filers are needed before either is called a convention for the court (tier 2).
9. **Footer type size.** The page number is 12 pt. LCvR 5.2(a) applies the 12-point minimum to the print style. The page number in the exemplar image looks smaller, so the template is above the exemplar here (observation from the image, not measured).
10. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` at its root. This doc-type folder has neither, and the brief forbids changing `tools/`. Render and overlay were run, and the review below is the Gate 2 equivalent for this doc type.
11. **Tool output names.** `tools/render.sh` writes `samples/OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `samples/OVERLAY-<id>.pdf` and `.txt`. The brief named `<id>.pdf` and `<id>-overlay.pdf`. The tools' names are used, because `overlay.sh` reads `OUTPUT-<id>.pdf`.

## Review of the rendered pages (current PDF, `OUTPUT-barrick-complaint.pdf`)

Every page was rendered at 60 dpi and viewed after the last template change. Compared with exemplar pages where the sample transcribes them.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court name, six-line party column with numbered parties and `)` column, case number and legends at the right, title, intro paragraph. Caption rows line up with the `)` column. | PASS |
| 2 | exemplar p.2 | Heading "Board of County Commissioners..." kept with its paragraph. Paragraphs 2–8 at double spacing; paragraph 8 starts a block quotation at the foot. | PASS |
| 3 | exemplar p.3 | Block quotation after paragraph 8 (unbreakable, so it moved to the page top, leaving the bottom of page 2 short). Continuation paragraphs unnumbered. | PASS |
| 4 | exemplar p.4 | "In addition" and "Here, Plaintiffs'" continuation paragraphs; paragraph 9 starts the McCurtain County Sheriff heading. | PASS |
| 5 | exemplar p.5 | Paragraphs 10–17, the citation-heavy paragraphs 12–14 wrap cleanly; the first block quotation of paragraph 17 begins. | PASS |
| 6 | exemplar p.6 | Continuation of the Gazette quotations; paragraph 18; Matthew Kasbaum heading; paragraphs 19–27. "[Paragraphs 22 to 87 ...]" note sits between 21 and 22. | PASS |
| 7 | exemplar p.18 | Paragraphs 28–30, WHEREFORE (unnumbered, bold), Second Cause heading centered, lead-in unnumbered, paragraphs 31–32. | PASS |
| 8 | exemplar p.19 | Paragraphs 33–40 with the "[Paragraphs 101 to 104 ...]" note before paragraph 35. | PASS |
| 9 | exemplar p.22 | Paragraphs 41–43, WHEREFORE paragraph. Page ends with space left, because the signature block cannot start there (see page 10). | PASS |
| 10 | exemplar p.23 | Signature block alone on the page (the block is unbreakable and does not fit on page 9). "Respectfully submitted," on the right half; two firms, each "By: /s/ name" and the signer's lines; "Attorneys for Plaintiff". | PASS |

## Pass stamp

Not written. `tools/check.sh` cannot run on this folder shape (gap 10).
