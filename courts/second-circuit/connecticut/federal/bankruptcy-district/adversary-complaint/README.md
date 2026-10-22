# ctb: adversary complaint

Doc type: **adversary complaint** (commencing an adversary proceeding) in the United States Bankruptcy Court for the District of Connecticut (`ctb`).
Folder: `courts/second-circuit/connecticut/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` and `-2`, `-3` (three filers; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md` (the complaint's text, paragraphs 1 to 34 and the prayer; Schedule A and footnotes omitted) |
| typeface | face required: none by the bankruptcy rules (see "Typeface and size" below). Vendored face: **Times New Roman** (the house face, docs/FONTS.md), the same in the typst and docx engines. The district Arial order is an open question (gap 2). |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf` and `usage/OUTPUT-adversary-complaint.docx.pdf`, 8 pages each, on the cross-engine layout model (fb-595.68.25): every line and page breaks alike (XENG-001..003 PASS, 208/208 lines; `params.cross_engine: gate` in `eval.yaml`) |
| overlay | `just overlay` writes it to the gitignored `.overlay/` (a diagnostic, not committed) |
| pages reviewed | 8 of 8 in both engines (rendered at 50 dpi and viewed on 2026-10-22) |

File names follow the repo's convention (`INPUT-` for the markdown, `OUTPUT-` for our render, `OVERLAY-` for the comparison), because `tools/render.sh` and `tools/overlay.sh` read and write those names. The brief's `<id>.md` / `<id>-overlay.pdf` form is not what the tools produce.

## Governing rules

Each row was read from the cited text on 2026-10-14. The bankruptcy local rules are the 2025 revision on the court's site; the district local rules are the version posted on the district's site (Rule 7 amended January 12, 2024; Rule 10 amended November 7, 2016).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| FRBP 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010) | Fed. R. Civ. P. 10 applies in an adversary proceeding; the caption must substantially conform to Official Form 416 (the adversary form, 416A). | `caption()` in `ctb-adversary-complaint.typ`: court, division, debtor and case, the adversary parties, the adversary number. |
| FRBP 9004(a)-(b) (https://www.law.cornell.edu/rules/frbp/rule_9004) | (a) clearly legible. (b) caption: court name, case title, case number and adversary number, brief designation of the document. | Caption (court, division, debtors, chapter, case number, adversary number and judge, title). |
| FRBP 7008(a) (https://www.law.cornell.edu/rules/frbp/rule_7008) | The jurisdiction allegation names the case, its number and Code chapter, and the district and division; the pleader states whether it does or does not consent to final orders or judgment by the bankruptcy court. | Jurisdiction section of the sample. The consent sentence is in the sample, bracketed (see gap 3). |
| FRCP 10(b) via FRBP 7010 | Claims in numbered paragraphs. | The template numbers every paragraph after the first heading; the lead-in and the prayer are not numbered. |
| Local Bankr. R. 5005-1, effective March 16, 2026 (https://www.ctb.uscourts.gov/local-bankrr5005-1; checked 2026-10-15) | "D. Conn. L. Civ. R. 10 applies to pleadings and documents filed with the Bankruptcy Court." The 2025 PDF cited earlier is superseded. | Items below. |
| D. Conn. L. Civ. R. 10 (https://www.ctd.uscourts.gov/sites/default/files/Current-Revised-Local-Rules-9.4.26.pdf) | Double-spaced; 8½ x 11; left and right margins of at least 1 inch; page numbers in the bottom margin after page 1; name, office address, telephone, fax and email under the signature, with the federal bar number beneath the signature; the complete docket number with the judge's initials on each pleading; the date in the caption. | `main.typ` page setup (1 inch margins, double spacing at 24 pt pitch, header with the adversary number and judge initials from page 2, page number from page 2); `signature()`; the caption's "Dated" line. Fax number is not in the sample (none in the exemplar). |
| Local Bankr. R. 7001-1, 7002-1 | Complaint filed in the division where the case is pending; the Form B1040 cover sheet accompanies it unless filed through CM/ECF. | Not produced: the B1040 cover sheet is a separate form (see gap 5). The division is in the caption. |
| Local Bankr. R. 7007-1 (applies D. Conn. L. Civ. R. 7 and 56 to adversary motions) | Relevant to motions, not to the complaint. | Not applicable to this doc type. |

Typeface and size: no rule that governs this court sets a typeface. Local Bankr. R. 5005-1 (effective March 16, 2026) adopts D. Conn. L. Civ. R. 10 for pleadings; Rule 10 requires conformity with "this Court's Electronic Filing Policies and Procedures" and sets no face. The bankruptcy Appendix A (electronic filing, March 16, 2026) sets no face either. D. Conn. L. Civ. R. 7(a)(5) (applied to adversary practice by Local Bankr. R. 7007-1) requires text of at least 12 point; the template uses 12 point throughout. The template sets Times New Roman, the house face, because no court rule names a face. See gap 2.

## Layout

- Caption: the court (three lines, bold, centred); a two-column box with the debtor block (`In re:`, the debtors, `Debtors.`) and the case number on the right; a second box with the adversary parties (each name, `v.` between them, the designation), the adversary number with the judge's initials, and the date.
- Title: bold, centred, single-spaced below the caption (as in all three exemplars).
- Body: double-spaced 12 point (24 pt line pitch), first-line indent 0.5 inch; a paragraph number at the indent, the text from 1 inch (as in the exemplars). Headings on the body pitch with no extra space: `#` centred bold capitals; `##` bold and left (the lettered sub-sections); `###` centred bold. Paragraphs before the first heading are unnumbered (the lead-in). The "PRAYER FOR RELIEF" heading switches numbering off until the next heading; its list items have the number at the indent and the text hanging at 1 inch.
- Footer from page 2: the page number centred and the docket line (Adv. Pro. No. and the judge's initials, 10 pt) at the right, 0.5 inch above the page edge.
- Signature: "Dated" and the place on the left; the party, the `By: /s/` line with the e-signer, the signers with bar numbers and emails, the firm, the address, telephone and role on the right.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `title`, `court`, `district`, `division`, `chapter`, `main_case`, `jointly_administered`, `debtors`, `judge`, `adv_number`, `caption.parties` (list of `{names, designation}`), `date`, `signature` (`dated_place`, `party`, `esigner`, `signers` (list of `[name, email]`), `firm` (lines), `role`).
- Body: blank-line-separated chunks. `#` / `##` / `###` headings; a list (`1.` items) for the prayer; any other chunk is one numbered paragraph (or the unnumbered lead-in before the first heading).
- Not supported: footnotes, tables, raw typst. The sample does not put the paragraph numbers in the text.

## Known gaps and open choices

1. **Exemplars.** Three filers (`usage/SOURCE.md`): exemplar 1 (Neubert, Pepe & Monteith, the sample's source), 2 (Willcutts & Habib) and 3 (Law Offices of Jeffrey Hellman); tier 2 is judged against all three (see the review below).
2. **Typeface.** The one face-naming text found is the district court's Electronic Filing Order (revised 1/17/2018, https://ctd.uscourts.gov/sites/default/files/Electronic%20Filing%20Order%2C%20revised%201.17.2018.pdf). It says "All documents in this case will be filed electronically ... All documents must be typewritten using Arial bold 12 point font, double spaced. Pleadings must comply with all applicable provisions of D. Conn. L. Civ. R. 10(a)." It is a single district judge's order "in this case", not a rule of the bankruptcy court, and Local Bankr. R. 5005-1 (March 16, 2026) adopts only D. Conn. L. Civ. R. 10, which names no face. The template sets Times New Roman 12 point (the house face; the vendored Arial substitute, Liberation Sans, is in `fonts/liberation-sans/`). The exemplar uses a serif face. **Question for David:** does the bankruptcy court apply the district order's Arial bold to adversary pleadings? If yes, switch `font-family` in `typst/ctb-adversary-complaint.typ` to `"Liberation Sans"` (docs/FONTS.md, Arial row), re-render, and re-check the page count (metric-compatible). Verified text: D. Conn. L. Civ. R. 10 (as amended Nov. 7, 2016) read in the 2020 compilation (https://ctd.uscourts.gov/sites/default/files/Revised-Local-Rules-11-04-2020.pdf); the 2026 compilation linked earlier (`Current-Revised-Local-Rules-9.4.26.pdf`) returned HTTP 404 on 2026-10-15 and was not read.
3. **Statement on final orders (FRBP 7008(a)).** The exemplar has no statement on consent to final orders. The sample's jurisdiction paragraph says "The Trustee [does not consent]" as a bracketed placeholder, not a fact of the filing. The rule requires one of the two choices, so the choice is counsel's. Remove the brackets once the choice is made.
4. **Paragraph numbers.** The template numbers paragraphs from 1 (the exemplar's count is one lower up to the consent paragraph, then the same). The realleging paragraph says "paragraphs 1-34" to match this sample's count; recount if the sample changes.
5. **Cover sheet and schedules.** Not produced: the Form B1040 cover sheet (a separate form; the exemplar's pages 1-2) and Schedule A (the transfer schedule, not in the exemplar's text layer). Schedule A is referenced in paragraph 32 of the sample.
6. **Omitted text.** The sample transcribes paragraphs 1 to 34 and the prayer; footnotes 1 to 3 (debtor identification, the list of other adversary proceedings) are omitted. The sample is 8 pages; the exemplar's complaint runs 11 pages with a different face and spacing. The gap in length is the font metrics, not omitted paragraphs. Tier 2 page count is not a check.
7. **Overlay pairing.** The exemplar's first two pages are the cover sheet, so our page 1 pairs with the exemplar's page 4 (the complaint's second page). The overlay is a diagnostic, not a score.
8. **Caption.** The debtor footnote marker ("1") after "HO WAN KWOK, et al." is not reproduced; the template has no footnote in the caption.
9. **Check scripts.** `sh tools/check.sh <this folder> --engine typst|docx` runs the default checks (Gates 0, 1 and 4); both pass (2026-10-22).

## Review of the rendered pages (typst and docx, 8 pages each)

Every page of `usage/OUTPUT-adversary-complaint.typst.pdf` and `usage/OUTPUT-adversary-complaint.docx.pdf` rendered at 50 dpi and viewed on 2026-10-22, after the port to the cross-engine model (fb-595.68.25). The two renders break every line and page alike (`fb diff --engines`: 208/208 lines, 0 of 8 page ends differ), so each row holds for both.

| Page | Content | Gate 2 |
|---|---|---|
| 1 | court (three lines, bold, centred); the two caption boxes with their right and bottom rules (debtors and chapter, case number, "(Jointly Administered)"; the parties, `v.`, designations, the adversary number with the judge's initials and the date); the title single-spaced, bold, centred; the lead-in; NATURE OF ACTION; paragraphs 1 and 2. No page number. | PASS |
| 2 | paragraphs 3 to 11; JURISDICTION AND VENUE, THE PARTIES, FACTS, "A. Chapter 11 Case"; footer: page number 2 centred, docket line at the right. The consent sentence (paragraph 7) bracketed as gap 3 describes. | PASS |
| 3 | paragraphs 12 to 16; sub-heading B. | PASS |
| 4 | paragraphs 16 to 23; sub-headings C and D; no heading at the foot of the page. | PASS |
| 5 | paragraphs 23 to 27; sub-heading E. | PASS |
| 6 | paragraphs 27 to 34; sub-heading F. | PASS |
| 7 | FIRST CLAIM and its subtitle at the top (kept with the text: page 6 ends a few lines short); paragraphs 35 to 41; PRAYER FOR RELIEF; WHEREFORE; prayer items 1 and 2, the number at the indent, the text hanging at 1 inch. | PASS |
| 8 | prayer item 3; the date and place at left; the signature block (party, `By: /s/`, signers with bar numbers and emails, firm, address, telephone, role). | PASS |

Tier 2 against the exemplars (three filers: Neubert, Pepe & Monteith; Law Offices of Jeffrey Hellman; Willcutts & Habib; `usage/SOURCE.md`): caption boxes, single-spaced bold title, centred bold section headings and numbered paragraphs match the filed convention (the text from 1 inch after the number, as in exemplars 1 and 3; exemplar 2 runs it on after the number). ACCEPTED: the exemplars underline the title or headings in places (one filer's style, tier 3); the docket line repeats in the footer from page 2 (the template's reading of L. Civ. R. 10; the exemplars carry it only in the ECF stamp).

## Engines

**docx** (`docx/reference.xml` and `docx/ctb-adversary-complaint.lua`, built by `fb render`; no shell): output `usage/OUTPUT-adversary-complaint.docx` and its LibreOffice PDF `usage/OUTPUT-adversary-complaint.docx.pdf`.

- The styles are the cross-engine recipe (`base="xengine"`) in the typst face (`{font}`: Times New Roman; was EB Garamond in the old `build-reference.sh`, a tier-1 DEF-FONT-002 failure), 12 pt, exact 24 pt body lines (480 twips) and 13.8 pt single lines (276 twips). The filter writes the caption boxes, the headings, the numbered paragraphs (a tab to 1 inch), the prayer's list items, the signature block, the section (titlePg: no footer on page 1) and the footer (page number and docket line, the docket text from the frontmatter).
- XENG-001..003 PASS (8 pages each; 208/208 lines break after the same word); `eval.yaml` gates them.
- Word itself has not been run here; LibreOffice converts the file and `DEF-DOCX-OPEN` passes.
