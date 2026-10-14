# wied: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Wisconsin (`wied`).
Folder: `courts/seventh-circuit/wisconsin/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-taylor-2-26-cv-01900-complaint.pdf` (13 pp., counsel-filed); second filer `FILED-EXAMPLE-testolin-2-26-cv-01895-complaint.pdf` (9 pp., pleading paper). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-taylor-complaint.md` (the whole filing, transcribed from the text layer) |
| render | ok: `samples/OUTPUT-taylor-complaint.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-taylor-complaint.pdf` and `OVERLAY-taylor-complaint.txt` (against the Taylor exemplar) |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

Primary source: Local Rules of the United States District Court for the Eastern District of Wisconsin, "Local Rules 2010-0201, Amended 2026-0729" (71 pp.), fetched 2026-10-14 from https://www.wied.uscourts.gov/sites/wied/files/documents/Local%20Rules%202010-0201-Amended%202026-0729.pdf (linked from https://www.wied.uscourts.gov/local-rules-and-guidance). The court's own page shows no separate revision date beyond the file name.

Federal Rules of Civil Procedure, from the Legal Information Institute (https://www.law.cornell.edu/rules/frcp), fetched 2026-10-14: Rules 8, 10, 12 and 38.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| General L.R. 5(a)(5) | 8½ × 11 inch paper; double-spaced text, quotations over two lines may be single-spaced; headings and footnotes may be single-spaced; margins of at least one inch on all four sides; page numbers may go in the margins. | `page-w`, `page-h`, `margin = 1in`, `body-leading` (24 pt baseline pitch, measured), `single-leading` for caption, headings, signature. Page number centered in the bottom margin. |
| General L.R. 5(a)(6) | A proportionally spaced face must include serifs (sans-serif allowed in headings and captions) and be 12-point or larger. | `font-family = "EB Garamond"` (serif), `type-size = 12pt` everywhere, including the page number. |
| General L.R. 5(a)(7) | Plain roman type; italics or boldface for emphasis; case names italicized or underlined. | Body is roman; `*...*` in markdown renders italic (`inl`, `md`). |
| General L.R. 5(c) | Signature block: `s/ [attorney name]`, attorney name, bar number, attorney for (party), firm, address, telephone, e-mail. | `signature-block()`: "s/ name", name, bar line, role, firm, address lines, "Telephone:", "E-mail:". |
| Civil L.R. 3(a) | A Civil Cover Sheet (JS 44) must accompany each civil action. | Not produced here (separate filing; see gaps). |
| Civil L.R. 7.1 | Disclosure statement (parties, corporate parents, law firms) with the first filing. | Not produced here (separate filing; see gaps). |
| Civil L.R. 8 | A pleading asserting diversity jurisdiction must identify the amount in controversy and each party's citizenship (corporations: state of incorporation and principal place of business; LLCs and partnerships: citizenship of all members). | Not checked by the template; sample content only. |
| Civil L.R. 10(a) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each paragraph is numbered 1, 2, ... from the start of the pleading; headings and lists are not numbered. |
| Fed. R. Civ. P. 8(a) | Short and plain statement of the grounds for jurisdiction, of the claim, and a demand for relief. | Content only; the template does not check it. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number, and a Rule 7(a) designation (the complaint's title names all parties). | `court-title()` (court name, fixed for this court), `caption()` (all parties, "v.", "Case No."), document title. |
| Fed. R. Civ. P. 10(b) | Numbered paragraphs; separate counts for separate claims. | As Civil L.R. 10(a); `## COUNT` headings. |
| Fed. R. Civ. P. 38(b) | A jury demand may be made in a pleading, endorsed on the pleading or in a separate document; the demand is noted in the caption ("JURY TRIAL DEMANDED"). | `jury_demand: true` puts "JURY TRIAL DEMANDED" in the caption; the demand paragraph is body text under the prayer. |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS 44), the Civil L.R. 7.1 disclosure statement, the summons, and the exhibits. The ECF header ("Case 2:26-cv-... Filed ... Page x of y") is added by the court's electronic system at filing, so the template does not add it.

## Layout

- Court title, centered bold caps, on the first page (no counsel block at the top; E.D. Wis. puts counsel only in the signature block at the end).
- Caption: party names left (designation indented under each party, "v." between parties), "Case No." and "JURY TRIAL DEMANDED" right, no ruled box.
- Document title centered bold caps below the caption; the lead-in ("NOW COMES ...") is unnumbered.
- Section headings (`#`): centered bold caps. Count headings (`##`): centered bold, one or two lines. Heading blocks are `sticky` so a heading stays with the text after it.
- Numbered paragraphs: 0.5 in first-line indent, number, then text. Paragraphs are separated by one body pitch (`par(spacing: body-leading)`).
- Lettered list items (`1.` in markdown, rendered as A., B., ...): the prayer for relief. Paragraphs under a level-1 heading starting "PRAYER" or "DEMAND" are not numbered.
- Signature: "Dated this ... day of ..." (sample field `date`), then the firm, role, signature lines and contact block, in the right half of the page.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `case_number` (blank leaves a blank line to fill in), `caption.parties` (list of `{names: [...], designation}`; "v." is inserted between parties), `document_title`, `jury_demand` (true/false), `lead_in` (unnumbered lead-in paragraph, optional), `date` (the words after "Dated this", e.g. `13th day of October, 2026`), `signature` (`firm`, `role`, `signers: [{name, bar, email}]`, `address: [lines]`, `telephone`).
- Body: blank-line-separated chunks. `#` = section heading (level 1, centered bold caps); `##` = count heading (level 2, centered bold); `###` = level 3 (bold italic, left); `1.` items = lettered list (A., B., ...); any other chunk = a numbered paragraph (unless the current section is PRAYER or DEMAND).
- The sample must not put the paragraph numbers in the text: the template numbers the paragraphs.
- Not supported: tables (E.D. Wis. complaints have none in this form), footnotes, raw typst.

## Known gaps and open choices

1. **Font.** General L.R. 5(a)(6)(A) requires a serif face of 12 points or larger. The only font vendored in `fonts/` is EB Garamond. The Times-metric serif on this box is a system font (Liberation Serif), which the rules of this formbook do not allow. EB Garamond at 12 pt has a smaller x-height than Times New Roman at 12 pt, so the render looks smaller than the exemplar and runs 11 pages against the exemplar's 13. The 12-point minimum is met. Whether a vendored Times-metric font is wanted is a question for David (`fonts/` is a shared directory, so it is not changed here).
2. **Pleading paper.** The second exemplar (Testolin) uses numbered pleading lines 1 to 28 and a ruled left margin. E.D. Wis. General L.R. 5(a) requires none of that, and the Taylor exemplar and the Schmidt brief do not use it. The template follows Taylor. This is an accepted variant (ACCEPTED, see review below), not a defect.
3. **Second filer, not overlaid.** `tools/overlay.sh` compares against the first exemplar only (Taylor). Testolin was checked by reading its layout and page-1 and last-page text, not by overlay.
4. **Caption layout.** The party block is not in a ruled box. Taylor has no box; Testolin's caption is in two columns with a `Complaint for Damages:` block. Both are accepted; the template does not add a case-type legend (Testolin's "Violation of Fair Credit Reporting Act" block), which the rules do not require.
5. **No separate jury or prayer page.** The jury demand (Fed. R. Civ. P. 38(b)) is a body paragraph under the prayer, as in the Taylor exemplar. The demand is also in the caption.
6. **Heading text and count names.** A two-line count heading (Count III) is valid and renders as two single-spaced lines. There is no check on heading length.
7. **Page 11.** The signature block falls alone on the last page with the closing jury-demand paragraph. The template keeps the block unbreakable (`breakable: false`) so the signature never splits; it does not pull text back from the previous page. Accepted.
8. **Paragraph numbers.** The sample numbers its paragraphs from 1 (as the template does). The filed paragraph numbers match, and so do the cross-references ("paragraphs 1 through 47").
9. **Overlay pairing.** The Taylor exemplar and the render differ in pagination (the exemplar is 13 pages; ours is 11) because of the font, so the overlay pairs pages by word overlap, not index. The overlay is a diagnostic, not a score.
10. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and a `rules.md` in the court directory. This doc-type folder is not that shape, and the brief forbids touching `tools/`. Render and overlay were run; the review below is the Gate 2 equivalent for this doc type.

## Review of the rendered pages (`samples/OUTPUT-taylor-complaint.pdf`, 11 pages)

Rendered at 60 dpi and viewed page by page after the last template change (paragraph spacing).

| Page | Content | Finding |
|---|---|---|
| 1 | Court title, caption (parties; Case No. blank; JURY TRIAL DEMANDED), COMPLAINT, lead-in, NATURE OF ACTION, paragraph 1. | Pass. Caption and title fit on the first page. |
| 2 | PARTIES, paragraphs 2 to 6, JURISDICTION AND VENUE, paragraphs 7 to 10, FACTUAL ALLEGATIONS, paragraph 11. | Pass. Pitch uniform; no heading at page foot. |
| 3 | Paragraphs 12 to 24. | Pass. |
| 4 | Paragraphs 25 to 34. | Pass. |
| 5 | Paragraphs 35 to 42. | Pass. |
| 6 | Paragraphs 43 to 51, LEGAL CLAIMS, COUNT I (heading and sub-heading). | Pass. The COUNT I heading stays with paragraph 48. |
| 7 | Paragraphs 52 to 62, COUNT II and COUNT III headings (COUNT III sub-heading wraps to two lines). | Pass. |
| 8 | Paragraphs 63 to 72. | Pass. |
| 9 | Paragraphs 73 to 80. | Pass. |
| 10 | Paragraphs 81 to 86, PRAYER FOR RELIEF, items A to F (lettered). | Pass. Prayer items are lettered; items are not numbered. |
| 11 | Jury-demand paragraph (unnumbered), "Dated this 13th day of October, 2026.", firm, role, signature, contact block. | Pass. Signature block whole and in the right half of the page. Note 7 above. |

Gate 2 rows, with the overlay: page-level word overlap is 27% (page 11) to 83% (page 5); see `samples/OVERLAY-taylor-complaint.txt`. The lowest pages are the signature page (no body text in the exemplar's matching page) and the mid-pages where the exemplar's pagination differs. Not a score.
