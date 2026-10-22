# ilcd: complaint

Doc type: **complaint** (with jury demand) in the United States District Court for the Central District of Illinois (`ilcd`).
Folder: `courts/seventh-circuit/illinois/federal/central-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (the whole complaint, transcribed; slurs and profanity bracketed) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 12 pages, typst 0.15.0, vendored Times New Roman only, no warnings; `usage/OUTPUT-complaint.docx` and `.docx.pdf`, 12 pages, every line and page broken as in typst |
| checks | `fb check --engine typst`: 8 passed, 0 failed; `--engine docx`: 12 passed, 0 failed, XENG-001..003 PASS (321/321 lines); `eval.yaml` `params.cross_engine: gate` |
| overlay | `just overlay` writes `.overlay/<doc path>/OVERLAY-complaint.pdf` and `.txt` (not committed) |
| pages reviewed | 12 of 12 typst and 12 of 12 docx, every page rendered at 60 dpi and viewed in its final state (2026-10-22, cross-engine port, fb-595.68.27) |

## Governing rules

Primary source: Civil Local Rules of the U.S. District Court for the Central District of Illinois, "September 2026 Version" (adopted by General Order 26-go-1), fetched 2026-10-14 from https://www.ilcd.uscourts.gov/sites/ilcd/files/September%202026%20Version%20.pdf (the Rule 5.1 text carries "Revised 11/2021").
Federal rules: Fed. R. Civ. P. 8(a), 10(a), 10(b), fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_8 and https://www.law.cornell.edu/rules/frcp/rule_10.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| CDIL LR 5.1(A) | 8½ × 11 paper, about one-inch margins, pages numbered. | `page-margin`, `page-footer()` (centered page number on every page). |
| CDIL LR 5.1(B)(1) | Double-spaced lines. | `pitch-body = 24pt`: every body line a 24 pt box at 12 pt (double spacing), across paragraph ends too; the court title, caption, title, signature lines and page number in 13.8 pt boxes (`pitch-single`, Word's single line). |
| CDIL LR 5.1(B)(2) | Body text 12- or 14-point; plain roman style. | `type-size = 12pt`, Times New Roman Regular and Bold (no italics in the body). |
| CDIL LR 5.1(B)(2), typeface | Names no face; requires only a plain, roman style. | Face required: none. Times New Roman (vendored, with Liberation Serif its metric twin), the face of the filing; typst and docx set the same face. |
| CDIL LR 40.1(E)(1) | Caption identifies the division. | `court-title()` line 3 from frontmatter `division`; the template asserts it is present. |
| CDIL LR 38.1 | Complaint marks "Equitable relief is sought" if it prays for equitable relief; a jury demand puts "and demand for jury trial" in the title. | Title check: `ilcd-complaint()` asserts the title contains "and demand for jury trial" when `jury_demand: true`. `equitable_relief: true` prints the marking under the title (not set in the sample; see gap 5). |
| CDIL LR 5.11(A)(2) | Signatures as "s/name". | `signature-block()`: "/s/ Name". |
| CDIL LR 11.1 | Telephone number on pleadings; typed name below the signature. | Signature lines carry the phone and the typed name. |
| FRCP 8(a) | Short and plain statement of jurisdiction, claim and relief. | Content of the filing (not checked by the template). |
| FRCP 10(a) | Caption with court, title, file number, Rule 7(a) designation. | `court-title()`, `caption()` (case number at the right), `brief_title`. |
| FRCP 10(b) | Claims in numbered paragraphs. | `ilcd-complaint()`: each markdown paragraph is numbered 1, 2, ...; a chunk starting `~ ` is not (the WHEREFORE clause and the jury-demand sentence are unnumbered in the filing). |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44), the summons, the disclosure statement under Fed. R. Civ. P. 7.1 and CDIL LR 7.1.1, and exhibits (LR 5.8). Any of these may be needed with the first filing; the rules were not read for their content beyond these headings.

## Layout

- Cover: three bold court-title lines (court, district, division), 24 pt, the caption (one single-spaced row per line with a ")" mark on every row and a blank row between the entries, as filed; the case number on the row of the first designation, "Jury Trial Demanded" on the row of the last), 24 pt, the title centered bold in capitals, 24 pt.
- Body from the cover page onward (no page break after the cover), double-spaced (24 pt pitch), first-line indent 0.5 in, the paragraph number in a half-inch box after it. Headings at the body pitch, kept with the text after them: level 1 centered bold capitals; level 2 centered bold (count headings); level 3 centered bold (count subtitles).
- Prayer items (markdown list) lettered (a), (b), ...: the label half an inch in, the text hanging an inch in.
- Signature blocks: "Dated:" at the margin, then in the right half (3.25 in) "Respectfully submitted," and each signer as "/s/ Name" with the typed name, bar number, firm, address, telephone and email, single-spaced, 24 pt between the parts; the whole block is kept on one page with the last paragraph.
- Cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): first-fit ragged-right lines, no kerning, ligatures or hyphenation, exact line boxes; the docx breaks every line and page where typst does.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`; `division` (required, LR 40.1(E)(1)); `caption.parties` (list of `{names, designation}`; "v." is inserted between parties; one `names` entry per caption line, so a long name is typed as two entries); `brief_title` (must contain "and demand for jury trial" if `jury_demand`); `jury_demand` (bool); `equitable_relief` (optional bool, LR 38.1); `lead_in` (optional unnumbered opening sentence); `date`; `signature` (list of `{signer, lines}`, one block per signer).
- Body: a `#` heading is a level 1 section; `##` level 2; `###` level 3. Each blank-line-separated chunk that is neither a heading nor a list is a numbered paragraph. A chunk starting with `~ ` is an indented paragraph outside the numbering. A markdown list is lettered (a), (b), ... Section and paragraph numbers are not typed in the text.
- Smart punctuation is on; `*...*` is italic; `[text](url)` prints the text only in black.
- Not supported: tables, footnotes, raw typst.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one exemplar per doc type. CourtListener RECAP (court `ilcd`, complaints filed 2026-01 to 2026-10) also has Beaman v. Bunn Commercial LP (3:26-cv-03240, 27 pages), Nieme v. Bunn Commercial LP (3:26-cv-03241), Pharmaceutical Care Management Association v. Gillespie (3:26-cv-03200, 18 pages) and Karpowski v. Reddit Inc (1:26-cv-01226). They were seen in the search results and not downloaded. Tier 2 (2 or 3 filers) is not yet judged against more than one filer.
2. **Font size and face.** Body text is 12 pt Times New Roman, the filing's face (LR 5.1(B)(2) names none). LR 5.1(B)(2) allows 14 pt; whether David wants 14 pt is a choice this template does not make.
3. **Title of the filing.** The filing's cover title is "COMPLAINT", without the words LR 38.1 requires for a jury demand. The sample uses "COMPLAINT AND DEMAND FOR JURY TRIAL" and says so in its header comment. The filing is a rule deviation, not a template choice.
4. **Signature date line.** The filing says "Dated this 30th day of June, 2026." The template prints "Dated: June 30, 2026." Form choice, not a rule point.
5. **Equitable relief marking (LR 38.1).** The prayer seeks back pay, front pay, compensatory and punitive damages, fees and costs; the filing carries no "Equitable relief is sought" marking. The template supports the marking through `equitable_relief: true`, which the sample does not set. Whether front pay makes the marking necessary is a question for counsel, not the template.
6. **Caption.** The party column is closed by ")" marks, one per row, blank rows included (the filing's style); a name that wraps in its column gets one mark for its row, so a long name is typed as several `names` entries. The right-hand "Jury Trial Demanded" legend is the filing's. Accepted as the convention this filing uses.
7. **Privacy (LR 5.11(A)).** The template does not check for personal identifiers. The sample has none beyond the names and addresses already in the filing.
8. **ECF header.** The filing's stamp ("2:26-cv-02194-CSB-EIL #1 Filed: 06/30/26 Page X of 13") is applied by the court's system at filing and is not reproduced.
9. **Cross-references.** Paragraph numbers are generated. Cross-references in the text ("paragraphs 1-63") are typed by the author and must be kept in step with the numbering.
10. **Selftest.** `fb check` runs the default checks on this doc-type folder (see the checks row above); the folder has no selftest of its own.

## Review of the rendered pages (final state)

typst and docx renders reviewed page by page at 60 dpi (2026-10-22); the two engines set the same lines on every page (XENG-001..003 PASS, 321/321 lines).

| Page | Finding | Verdict |
|---|---|---|
| 1 | Court title (bold, with the division), caption with a ")" on every row, case number on the Plaintiff row and the jury legend on the Defendant row, bold title, lead-in, paragraphs 1 to 4 under NATURE OF PLAINTIFF'S CLAIMS and JURISDICTION AND VENUE. | pass |
| 2 | Paragraphs 5 to 13; ADMINISTRATIVE PREREQUISITES and PARTIES headings. | pass |
| 3 to 5 | Paragraphs 14 to 56 (BACKGROUND FACTS) numbered and aligned, number in a half-inch box, no heading at a page foot. | pass |
| 6 | Paragraphs 57 to 65; COUNT I heading and subtitle centered bold. | pass |
| 7 | Paragraphs 66 to 76; COUNT II heading with its two-line subtitle. | pass |
| 8 | Paragraphs 77 to 86; COUNT III heading with its two-line subtitle. | pass |
| 9 | Paragraphs 87 to 98; COUNT IV and COUNT V headings. | pass |
| 10 | Paragraphs 99 to 108; COUNT VI heading. | pass |
| 11 | Paragraphs 109 to 113, RELIEF REQUESTED: unnumbered WHEREFORE clause, prayer items (a) to (h). The lower third of the page is empty: the DEMAND FOR JURY TRIAL heading, its sentence and the signature blocks travel together. | ACCEPTED: the signature never stands alone; a clerk sees a short page before the signature, which is common. |
| 12 | DEMAND FOR JURY TRIAL with its unnumbered sentence, "Dated:", and both counsel's blocks in the right half ("/s/" names, typed names, bar numbers, firm, address, phone, fax, email). | pass |

The filed exemplar (one filer, `usage/SOURCE.md`) underlines its headings, sets the caption names in bold and the signature in bold italic; those are one filer's style (tier 3) and not followed. The ECF header on the filed pages is the court's stamp and is not reproduced.

## Engines

**docx** (`docx/`): `docx/reference.xml` holds the Word styles (`base="xengine"`: the cross-engine recipe of `tools/fb/src/docxxengine.rs` in the typst face `{font}`, Times New Roman 12 pt, Body Text in exact 480-twip lines with a 720-twip indent, single 276 twips, and a page-number footer in a 13.8 pt line 735 twips above the page foot, as typst's `footer-descent: 30%`). `docx/ilcd-complaint.lua` (on `lib/docx/xengine.lua`) writes every paragraph itself with the typst pitches and spaces in twips: the court title, the caption as a borderless fixed table of 4608/432/4320 twips with a row per caption line, the title, the lead-in, the numbered paragraphs (number, tab at 1 in), the "~ " paragraphs, the headings (kept with the next paragraph), the lettered prayer items, and the signature lines (each kept with the next, the last paragraph kept with them). `fb render --engine docx` builds `reference.docx` from the xml, runs the filter and converts with LibreOffice; no shell, no committed `reference.docx`.

- Matches the typst render line for line and page for page: XENG-001..003 PASS (12 pages, 321/321 lines), `params.cross_engine: gate` in `eval.yaml`.
- The same face as typst (Times New Roman; was EB Garamond in the docx, which failed DEF-FONT-002).
