# wied: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Wisconsin (`wied`).
Folder: `courts/seventh-circuit/wisconsin/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (13 pp., counsel-filed); second filer `FILED-EXAMPLE-complaint-2.pdf` (9 pp., pleading paper). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-complaint.md` (the whole filing, transcribed from the text layer) |
| render | ok (re-run 2026-10-22, fb-595.68.28): `usage/OUTPUT-complaint.typst.pdf` and `.docx.pdf`, 12 pages each, typst 0.15.0, `pdffonts`: Times New Roman regular and bold only (embedded), no warnings |
| overlay | fail (2026-10-15): `tools/overlay.sh` exits 1, `no exemplar pdf in usage/`. The filed PDFs are not in this snapshot (`usage/` holds `SOURCE.md` only). The earlier `OVERLAY-taylor-complaint.*` files are from a run with the PDFs present and are not regenerated |
| pages reviewed | 12 of 12, typst and docx (re-rendered 2026-10-22 and each page viewed at 50 dpi in montage) |

## Governing rules

Primary source: Local Rules of the United States District Court for the Eastern District of Wisconsin, "Local Rules 2010-0201, Amended 2026-0729" (71 pp.), fetched 2026-10-14 from https://www.wied.uscourts.gov/sites/wied/files/documents/Local%20Rules%202010-0201-Amended%202026-0729.pdf (linked from https://www.wied.uscourts.gov/local-rules-and-guidance). The court's own page shows no separate revision date beyond the file name.

Federal Rules of Civil Procedure, from the Legal Information Institute (https://www.law.cornell.edu/rules/frcp), fetched 2026-10-14: Rules 8, 10, 12 and 38.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| General L.R. 5(a)(5) | 8½ × 11 inch paper; double-spaced text, quotations over two lines may be single-spaced; headings and footnotes may be single-spaced; margins of at least one inch on all four sides; page numbers may go in the margins. | `page-w`, `page-h`, `margin = 1in`, `pitch-body` (exact 24 pt line boxes), `pitch-single` (13.8 pt) for the court title, caption and signature. Page number centered in the bottom margin. |
| General L.R. 5(a)(6) | A proportionally spaced face must include serifs (sans-serif allowed in headings and captions) and be 12-point or larger. No face is named. | `font-family = ("Times New Roman", "Liberation Serif")` (serif), `type-size = 12pt` everywhere, headings and the page number included. Typeface: no face named by the rule, so Times New Roman, the house standard (`docs/FONTS.md`), in typst and docx alike. |
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
- Numbered paragraphs: the number at the 0.5 in first-line indent, in a 0.5 in box, the text from 1 in; no extra space between paragraphs (exact 24 pt line boxes on the shared cross-engine model, `lib/typst/xengine.typ`). Headings at 12 pt on the body pitch, a section heading with 12 pt above it.
- Lettered list items (`1.` in markdown, rendered as A., B., ...): the prayer for relief; the letter at 0.5 in, the lines hanging at 0.9 in. Paragraphs under a level-1 heading starting "PRAYER" or "DEMAND" are not numbered.
- Signature: "Dated this ... day of ..." (sample field `date`), then the firm, role, signature lines and contact block, in the right half of the page.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `case_number` (blank leaves a blank line to fill in), `caption.parties` (list of `{names: [...], designation}`; "v." is inserted between parties), `document_title`, `jury_demand` (true/false), `lead_in` (unnumbered lead-in paragraph, optional), `date` (the words after "Dated this", e.g. `13th day of October, 2026`), `signature` (`firm`, `role`, `signers: [{name, bar, email}]`, `address: [lines]`, `telephone`).
- Body: blank-line-separated chunks. `#` = section heading (level 1, centered bold caps); `##` = count heading (level 2, centered bold); `###` = level 3 (bold italic, left); `1.` items = lettered list (A., B., ...); any other chunk = a numbered paragraph (unless the current section is PRAYER or DEMAND).
- The sample must not put the paragraph numbers in the text: the template numbers the paragraphs.
- Not supported: tables (E.D. Wis. complaints have none in this form), footnotes, raw typst.

## Known gaps and open choices

1. **Font.** General L.R. 5(a)(6) requires a proportional serif face of 12 points or larger and names no face. Times New Roman 12 pt, the house standard (`docs/FONTS.md`), is used in typst and docx. The render runs 12 pages against the exemplar's 13.
2. **Pleading paper.** The second exemplar (Testolin) uses numbered pleading lines 1 to 28 and a ruled left margin. E.D. Wis. General L.R. 5(a) requires none of that, and the Taylor exemplar and the Schmidt brief do not use it. The template follows Taylor. This is an accepted variant (ACCEPTED, see review below), not a defect.
3. **Second filer, not overlaid.** `tools/overlay.sh` compares against the first exemplar only (Taylor). Testolin was checked by reading its layout and page-1 and last-page text, not by overlay.
4. **Caption layout.** The party block is not in a ruled box. Taylor has no box; Testolin's caption is in two columns with a `Complaint for Damages:` block. Both are accepted; the template does not add a case-type legend (Testolin's "Violation of Fair Credit Reporting Act" block), which the rules do not require.
5. **No separate jury or prayer page.** The jury demand (Fed. R. Civ. P. 38(b)) is a body paragraph under the prayer, as in the Taylor exemplar. The demand is also in the caption.
6. **Heading text and count names.** A two-line count heading (Count III) is valid and renders as two single-spaced lines. There is no check on heading length.
7. **Page 12.** The signature block falls alone on the last page. The template keeps the block unbreakable (`breakable: false`) so the signature never splits; it does not pull text back from the previous page. Accepted.
8. **Paragraph numbers.** The sample numbers its paragraphs from 1 (as the template does). The filed paragraph numbers match, and so do the cross-references ("paragraphs 1 through 47").
9. **Overlay pairing.** The Taylor exemplar and the render differ in pagination (the exemplar is 13 pages; ours is 12), so the overlay pairs pages by word overlap, not index. The overlay is a diagnostic, not a score.
10. **Gate scripts.** Since fb-595.68.28: `sh tools/check.sh <this folder>` and `--engine docx` both exit 0 (typst 9, docx 13 checks passed, 0 failed).

## Review of the rendered pages (`usage/OUTPUT-complaint.typst.pdf` and `.docx.pdf`, 12 pages each)

Rendered at 50 dpi and viewed page by page on both engines after the cross-engine port (fb-595.68.28); the docx breaks every line and page as typst does (XENG-001..003).

| Page | Content | Finding |
|---|---|---|
| 1 | Court title, caption (parties; Case No. blank; JURY TRIAL DEMANDED), COMPLAINT, lead-in, NATURE OF ACTION, paragraph 1. | Pass. Caption and title fit on the first page. |
| 2 | PARTIES, paragraphs 2 to 6, JURISDICTION AND VENUE, paragraphs 7 to 10. | Pass. Pitch uniform; no heading at page foot. |
| 3 | FACTUAL ALLEGATIONS, paragraphs 11 to 23. | Pass. |
| 4 | Paragraphs 24 to 32. | Pass. |
| 5 | Paragraphs 33 to 40. | Pass. |
| 6 | Paragraphs 41 to 48, LEGAL CLAIMS, COUNT I and its title. | Pass. The headings stay with paragraph 48. |
| 7 | Paragraphs 49 to 58, COUNT II and its title. | Pass. |
| 8 | Paragraphs 59 to 68, COUNT III (its title in two lines). | Pass. |
| 9 | Paragraphs 69 to 75. | Pass. |
| 10 | Paragraphs 76 to 83. | Pass. |
| 11 | Paragraphs 83 (end) to 86, PRAYER FOR RELIEF, items A to F, the jury-demand paragraph (unnumbered). | Pass. Prayer items lettered, not numbered. |
| 12 | "Dated this 13th day of October, 2026.", firm, role, signature, contact block. | Pass. Signature block whole, at 3.0 in. Note 7 above. |


## Engines

### docx (`docx/`: `reference.xml`, `wied.lua`)

- `docx/reference.xml` holds the Word styles: `base="xengine"` in the typst face (`{font}`, Times New Roman), 12 pt, 480-twip body and 276-twip single line boxes, headings on the body pitch, the 12 pt page-number footer 0.5 in above the page edge; `fb render` builds the reference document from it. `docx/wied.lua` reads the sample's body chunk by chunk, as the typst template does, and writes every paragraph as WordprocessingML on `lib/docx/xengine.lua`: the court title, the borderless caption table (3.25 in party column, 0.3 in gutter), the title, the lead-in, the numbered paragraphs (unnumbered under PRAYER and DEMAND), the headings, the lettered prayer and the signature block. No script: `fb render` runs pandoc with the filter and packs the archive (fb-595.68.28; were `build-reference.sh` and a committed `reference.docx` naming EB Garamond).
- Cross-engine (fb-595.68.28): `sh tools/check.sh <this folder> --engine docx`: XENG-001..003 PASS (305/305 typst lines break after the same word, 12 = 12 pages); `params.cross_engine: gate` in `eval.yaml`. typst 9 and docx 13 checks passed, 0 failed.
- The numbers are typed by the filter (not Word list numbering), so a paragraph's number does not renumber if text is inserted in Word. The `.docx` converts in LibreOffice without error; not opened in Word.
- **No TOC, TOA or certificate:** the typst template has none, so the docx has none.
