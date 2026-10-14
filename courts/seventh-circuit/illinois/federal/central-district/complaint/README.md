# ilcd: complaint

Doc type: **complaint** (with jury demand) in the United States District Court for the Central District of Illinois (`ilcd`).
Folder: `courts/seventh-circuit/illinois/federal/central-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-thomas-2-26-cv-02194-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-thomas-complaint.md` (the whole complaint, transcribed; slurs and profanity bracketed) |
| render | ok: `samples/OUTPUT-thomas-complaint.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-thomas-complaint.pdf` and `OVERLAY-thomas-complaint.txt` |
| pages reviewed | 12 of 12, every page rendered at 60 dpi and viewed in its final state |

## Governing rules

Primary source: Civil Local Rules of the U.S. District Court for the Central District of Illinois, "September 2026 Version" (adopted by General Order 26-go-1), fetched 2026-10-14 from https://www.ilcd.uscourts.gov/sites/ilcd/files/September%202026%20Version%20.pdf (the Rule 5.1 text carries "Revised 11/2021").
Federal rules: Fed. R. Civ. P. 8(a), 10(a), 10(b), fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_8 and https://www.law.cornell.edu/rules/frcp/rule_10.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| CDIL LR 5.1(A) | 8½ × 11 paper, about one-inch margins, pages numbered. | `page-margin`, `page-footer()` (centered page number on every page). |
| CDIL LR 5.1(B)(1) | Double-spaced lines. | `body-leading = 1.35em`: 0.65em line box + 1.35em = 2.0em = 24 pt at 12 pt (double spacing). Each paragraph block adds one trailing leading so the pitch holds across paragraph boundaries. |
| CDIL LR 5.1(B)(2) | Body text 12- or 14-point; plain roman style. | `type-size = 12pt`, EB Garamond Regular and Bold only (no italics in the body). |
| CDIL LR 40.1(E)(1) | Caption identifies the division. | `court-title()` line 3 from frontmatter `division`; the template asserts it is present. |
| CDIL LR 38.1 | Complaint marks "Equitable relief is sought" if it prays for equitable relief; a jury demand puts "and demand for jury trial" in the title. | Title check: `ilcd-complaint()` asserts the title contains "and demand for jury trial" when `jury_demand: true`. `equitable_relief: true` prints the marking under the title (not set in the sample; see gap 5). |
| CDIL LR 5.11(A)(2) | Signatures as "s/name". | `signature-block()`: "/s/ Name". |
| CDIL LR 11.1 | Telephone number on pleadings; typed name below the signature. | Signature lines carry the phone and the typed name. |
| FRCP 8(a) | Short and plain statement of jurisdiction, claim and relief. | Content of the filing (not checked by the template). |
| FRCP 10(a) | Caption with court, title, file number, Rule 7(a) designation. | `court-title()`, `caption()` (case number at the right), `brief_title`. |
| FRCP 10(b) | Claims in numbered paragraphs. | `paragraphs()`: each markdown paragraph is numbered 1, 2, ...; a chunk marked `[unnumbered]` is not (the WHEREFORE clause and the jury-demand sentence are unnumbered in the filing). |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44), the summons, the disclosure statement under Fed. R. Civ. P. 7.1 and CDIL LR 7.1.1, and exhibits (LR 5.8). Any of these may be needed with the first filing; the rules were not read for their content beyond these headings.

## Layout

- Cover: three court-title lines (court, district, division), the caption (party names with a column of ")" marks, one per line of each wrapped name; case number and "Jury Trial Demanded" at the right), the title centered in capitals.
- Body from the cover page onward (no page break after the cover), double-spaced, first-line indent 0.5 in. Headings: level 1 centered bold capitals; level 2 centered bold (count headings); level 3 centered bold (count subtitles).
- Prayer items (markdown list) lettered (a), (b), ...
- Signature blocks: "Dated:", "Respectfully submitted," then each signer as "/s/ Name" with the typed name, bar number, firm, address, telephone and email.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`; `division` (required, LR 40.1(E)(1)); `caption.parties` (list of `{names, designation}`; "v." is inserted between parties); `brief_title` (must contain "and demand for jury trial" if `jury_demand`); `jury_demand` (bool); `equitable_relief` (optional bool, LR 38.1); `lead_in` (optional unnumbered opening sentence); `date`; `signature` (list of `{signer, lines}`, one block per signer).
- Body: a `#` heading is a level 1 section; `##` level 2; `###` level 3. Each blank-line-separated chunk that is neither a heading nor a list is a numbered paragraph. A chunk starting with `[unnumbered]` is an indented paragraph outside the numbering. A markdown list is lettered (a), (b), ... Section and paragraph numbers are not typed in the text.
- Smart punctuation is on; `*...*` is italic; `[text](url)` prints the text only in black.
- Not supported: tables, footnotes, raw typst.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one exemplar per doc type. CourtListener RECAP (court `ilcd`, complaints filed 2026-01 to 2026-10) also has Beaman v. Bunn Commercial LP (3:26-cv-03240, 27 pages), Nieme v. Bunn Commercial LP (3:26-cv-03241), Pharmaceutical Care Management Association v. Gillespie (3:26-cv-03200, 18 pages) and Karpowski v. Reddit Inc (1:26-cv-01226). They were seen in the search results and not downloaded. Tier 2 (2 or 3 filers) is not yet judged against more than one filer.
2. **Font size and face.** Body text is 12 pt EB Garamond, the only vendored face. EB Garamond has a smaller x-height than the filing's Times New Roman at 12 pt, so the text looks smaller. LR 5.1(B)(2) allows 14 pt; whether David wants 14 pt is a choice this template does not make.
3. **Title of the filing.** The filing's cover title is "COMPLAINT", without the words LR 38.1 requires for a jury demand. The sample uses "COMPLAINT AND DEMAND FOR JURY TRIAL" and says so in its header comment. The filing is a rule deviation, not a template choice.
4. **Signature date line.** The filing says "Dated this 30th day of June, 2026." The template prints "Dated: June 30, 2026." Form choice, not a rule point.
5. **Equitable relief marking (LR 38.1).** The prayer seeks back pay, front pay, compensatory and punitive damages, fees and costs; the filing carries no "Equitable relief is sought" marking. The template supports the marking through `equitable_relief: true`, which the sample does not set. Whether front pay makes the marking necessary is a question for counsel, not the template.
6. **Caption.** The party column is closed by ")" marks, one per line (the filing's style). The right-hand "Jury Trial Demanded" legend is the filing's. Accepted as the convention this filing uses.
7. **Privacy (LR 5.11(A)).** The template does not check for personal identifiers. The sample has none beyond the names and addresses already in the filing.
8. **ECF header.** The filing's stamp ("2:26-cv-02194-CSB-EIL #1 Filed: 06/30/26 Page X of 13") is applied by the court's system at filing and is not reproduced.
9. **Cross-references.** Paragraph numbers are generated. Cross-references in the text ("paragraphs 1-63") are typed by the author and must be kept in step with the numbering.
10. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, which this doc-type folder is not, and the brief does not ask for them. Render and overlay were run and the review below is the Gate 2 equivalent for this doc type.

## Review of the rendered pages (final state)

| Page | Finding | Verdict |
|---|---|---|
| 1 | Court title, division line, caption with one ")" per name line, case number and jury legend at right, title, lead-in, first numbered paragraphs. | pass |
| 2 | Paragraphs 2 to 17 at double spacing, the PARTIES and BACKGROUND FACTS headings each on their own line. | pass |
| 3 to 5 | Paragraphs 18 to 60 numbered and aligned, no overlap at paragraph breaks, no heading at a page foot. | pass |
| 6 | Paragraphs 61 to 69; COUNT I heading and subtitle centered, subtitle bold. | pass |
| 7 | Paragraphs 70 to 79; COUNT II heading (two-line subtitle centered). | pass |
| 8 | Paragraphs 80 to 92; COUNT III and COUNT IV headings. | pass |
| 9 | Paragraphs 93 to 103; COUNT V heading. | pass |
| 10 | Paragraphs 104 to 113; COUNT VI heading. | pass |
| 11 | RELIEF REQUESTED: unnumbered WHEREFORE clause, prayer items (a) to (h), DEMAND FOR JURY TRIAL with its unnumbered sentence. | pass |
| 12 | Signature blocks for both counsel (Dated line, "/s/" names, typed names, bar numbers, address, phone, email). The block is alone on this page because it did not fit on page 11. | OPEN (minor): a clerk would expect at least the last paragraph to travel with the signature; the page 11 space is about 340 pt against a block of about 345 pt. |

The overlay (`OVERLAY-thomas-complaint.txt`) pairs our pages 1 to 12 with the filed pages 1 to 13 at 43% to 96% word overlap. The filed pages carry the ECF header, which is not in our render, and the filed page 13 is the second signer's address block split across the page; the overlay is a diagnostic, not a score.
