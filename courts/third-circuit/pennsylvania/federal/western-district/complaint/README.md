# W.D. Pa. (pawd): complaint

Doc type **complaint** in the United States District Court for the Western District of Pennsylvania (`pawd`, Third Circuit).
Folder: `courts/third-circuit/pennsylvania/federal/western-district/complaint/`. Built by the wave-3 unit fb-595.31.16 (Haiku); the court root `typst/` and `usage/` were not touched.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (primary, transcribed) and `usage/FILED-EXAMPLE-complaint-2.pdf` (second filer, saved for comparison, not transcribed). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-complaint.md` (the whole filing: caption, 46 numbered paragraphs, four counts, prayers, jury demands, signature) |
| typeface | LCvR 5.1.B names no face and asks at least 12 point. Font: **Times New Roman** 12 pt (vendored, docs/FONTS.md), the exemplar's face and the house standard, in the typst PDF, the docx and its LibreOffice PDF (`fb lint fonts` does not report the folder) |
| render | ok (2026-10-22): `usage/OUTPUT-complaint.typst.pdf`, 11 pages, and `usage/OUTPUT-complaint.docx` with its LibreOffice PDF, 11 pages; `fb render`, vendored fonts only, no warnings |
| overlay | `just overlay` writes `.overlay/<doc path>/OVERLAY-complaint.pdf` (not committed); a diagnostic, not a score |
| pages reviewed | 11 of 11, both engines, side by side at 50 dpi (2026-10-22, the renders of fb-595.68.35) |

## Governing rules

Checked 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCvR 5.1.A (W.D. Pa. Local Rules, manual at https://www.pawd.uscourts.gov/sites/pawd/files/lrmanual20181101.pdf, the text headed "November 1, 2016") | 8½ × 11 inch white paper. | `paper: "us-letter"`. |
| LCvR 5.1.B (same) | Lettering not smaller than 12 point; text double-spaced; quotations over two lines may be indented and single-spaced; headings and footnotes may be single-spaced; margins at least one inch on all four sides; page numbers may be in the margins, no text in them. | `type-size = 12pt`; `pitch-body = 24pt` (double spacing: every body line a 24 pt box); single lines (court title, caption, signature) 13.8 pt; `margin = 1in`; the page number centred in the bottom margin. |
| LCvR 5.1.C, 5.1.D | One side of a page; securely fastened. | Not a template property (print). |
| LCvR 5.1.E | Exhibits accompany but are not bound to the filing; separator pages; top-right identification. | Not produced (no exhibits in the sample). |
| LCvR 5.2.B | Under the signature line: name, address, telephone, fax, email (if applicable), and Pennsylvania bar number, with the state's postal abbreviation as prefix ("PA 12345"). | `signature` block: `lines` in the sample include "PA ID No." for each attorney; the template prints the lines as given. Fax is not in the Cragle filing, so none is printed. |
| LCvR 5.2.D | Redaction of personal identifiers (SSN last four, minors' initials, year of birth, financial account last four). | Not a template property; the sample has no identifiers to redact (the filing has the plaintiff's age, which is not an identifier under the rule). |
| Fed. R. Civ. P. 10(a) (text fetched from https://www.law.cornell.edu/rules/frcp/rule_10, "as amended Apr. 30, 2007, eff. Dec. 1, 2007") | Every pleading has a caption with the court's name, a title, a file number, and a Rule 7(a) designation. | `caption()`: court title (two lines, `block`s), the parties column, "Civil Action No." in the right column, and the title. |
| Fed. R. Civ. P. 10(b) (same source) | A party states its claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `body-content()` numbers each body paragraph (the count headings, the prayer and the jury lines are not numbered). The paragraph numbers match the filing: 39, 43 and 46 in both the render and the exemplar (checked with `pdftotext`). |
| Fed. R. Civ. P. 8(a)(1)-(3) (https://www.law.cornell.edu/rules/frcp/rule_8, "amended Dec. 1, 2010") | Short and plain statement of jurisdiction, of the claim, and a demand for relief. | Content: the sample's "JURISDICTION AND VENUE" and the WHEREFORE prayers. The template does not check the wording. |
| Fed. R. Civ. P. 38(b) (https://www.law.cornell.edu/rules/frcp/rule_38, "amended Dec. 1, 2009") | A jury demand may be included in a pleading, served within 14 days after the last pleading directed to the issue. | `jury_demand: true` prints "JURY TRIAL DEMANDED" under the right-hand caption; the demand lines are in the body. |
| LCvR 7.1 / Appendix LCvR 7.1.A | Disclosure statement (Fed. R. Civ. P. 7.1) is a separate filing. | Not produced (separate document). |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44), the Rule 7.1 disclosure statement, the summons, and any exhibits (LCvR 5.1.E).

## Layout

- The cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line a box of its pitch, 24 pt for the body and the headings, 13.8 pt for single lines; the spaces between blocks explicit. Times New Roman 12 pt.
- Court title: two centred bold single lines; 24 pt below, the caption: the parties in the left column (single lines), a ")" per line, and on the right "Civil Action No.", then (when the sample asks) "JURY TRIAL DEMANDED" in bold and "Electronically Filed.", a blank single line apart.
- The title centred in bold capitals 24 pt below the caption; the lead-in paragraph 24 pt below it, indented.
- Headings at the type size on the body pitch with no space of their own, kept with the next block: section headings (`#`) centred bold capitals; count headings (`##`) centred bold, each source line of the heading its own line; `###` bold at the margin.
- Numbered paragraphs: the number at the half-inch indent in a 0.5 in box (the text starts 1 in from the margin; a tab in the docx). Lettered items (a., b., ...): the letter half an inch in, the text hanging at 1 in.
- WHEREFORE paragraphs and the "JURY TRIAL DEMANDED" lines (centred bold) are unnumbered.
- Signature block, kept with the last block: "Dated:" at the margin, then from 3.0 in "Respectfully submitted,", the firm, the signer's "s/" line and the attorney lines, single-spaced, 24 pt between the groups.
- Footer: the page number centred in a single line ending 0.5 in above the page edge.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `case_number`, `caption` (a list of `{names, designation}`, with "v." inserted between), `title`, `jury_demand` (bool), `electronically_filed` (bool), `lead_in` (the unnumbered opening paragraph), `date`, `signature` (`lead`, optional `firm` list, `signer`, `lines`).
- Body: blank-line-separated chunks. `#` = section heading, `##` = count heading (several source lines allowed), `### ` = left-aligned sub-heading; a paragraph starting "WHEREFORE" or "JURY TRIAL DEMANDED" is unnumbered; a run of lines starting "- " is a lettered list (a., b., ...); any other paragraph is numbered.
- Numbering is done by the template: the sample must not contain paragraph numbers.
- Not supported: tables, footnotes (not used in this doc type), raw typst.

## What the overlay shows

`just overlay <this folder>` writes `.overlay/<doc path>/OVERLAY-complaint.pdf` and `.txt` (not committed): each page red (our render) multiplied over blue (the filed exemplar's page with the most shared words), black where both agree, the pages paired by word overlap. The overlay is a diagnostic, not a score; the sample's count breaks fall on other pages than the filing's.

## Known gaps and open choices

1. **Font size and face.** LCvR 5.1.B sets a 12-point minimum, not a face. Times New Roman 12 pt, the exemplar's face and the house standard, in every engine (the template set EB Garamond 13 pt before fb-595.68.35).
2. **Exemplar caption error (Snee).** The second exemplar's printed heading says "DISTRICT OF MASSACHUSETTS" over a W.D. Pa. docket. The template follows the W.D. Pa. caption (Cragle, which is correct). Recorded here, not followed.
3. **Only one exemplar transcribed.** The brief asks for one primary exemplar per doc type; the second filer (Snee) is saved but not compared page by page. Tier-2 comparison against two filers is therefore partial (structure only: numbered paragraphs, counts, prayers, jury demand, signature block).
4. **Count heading.** The Cragle heading for Count III runs over three lines in the filing ("COUNT III: FAMILY AND MEDICAL LEAVE ACT / 29 USCS §§ 2611 et seq. / RETALIATION"); the sample keeps those lines, and the template renders each source line on its own line.
5. **Page gaps.** Some pages end a few lines short: page 1 (paragraph 5 and its items move on whole, typst's widow and orphan rule), page 5 and 7 (a count heading stays with its paragraph), page 10 (the last jury demand stays with the signature). The filing also leaves gaps. Not a rule issue.
6. **Judge practices not checked.** LCvR 7.A makes each judge's practices (posted on the court's chambers pages) apply to motions; the chambers pages were not retrieved, so any judge-specific complaint format is not covered.
7. **Caption box.** The caption closes with a ")" column (as the Cragle exemplar does). No rule text requires a particular caption style; this is a convention choice, recorded as accepted.
8. **No numbered pleading lines.** The W.D. Pa. rules do not require numbered lines, and neither exemplar has them; the template does not draw them.
9. **Overlay pairing.** Pages are paired by word overlap; the lowest pairings (p.9 to 54%, p.12 to 53%) are the count pages, where the sample and the filing break differently. Not a text defect; the rendered text was checked page by page.

## Review of the rendered pages (Gate 2 rows; all 11 pages, typst and docx side by side at 50 dpi, 2026-10-22)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (parties, ")" column, "Civil Action No. 2:26-cv-2200", JURY TRIAL DEMANDED, Electronically Filed.), title, lead-in, JURISDICTION AND VENUE, paragraphs 1 to 4 | OK, both engines alike. Ends short: paragraph 5 and its items move on whole. |
| 2 | Paragraph 5 with items a to c, PARTIES, paragraphs 6 to 8, FACTUAL ALLEGATIONS, 9 and 10 | OK. |
| 3 | Paragraphs 11 to 23 | OK. |
| 4 | Paragraphs 24 to 28, COUNT I, paragraphs 29 to 32 | OK. |
| 5 | Paragraphs 32 (end) and 33, WHEREFORE, items a to g, JURY TRIAL DEMANDED | OK; the item text hangs at 1 in. Ends short: COUNT II stays with paragraph 34. |
| 6 | COUNT II, paragraphs 34 to 38 | OK. |
| 7 | Paragraph 38 (end), WHEREFORE, items a to h, JURY TRIAL DEMANDED | OK. |
| 8 | COUNT III (three centred lines), paragraphs 39 to 42, WHEREFORE, items a to e | OK. |
| 9 | Item e (end) to h, JURY TRIAL DEMANDED, COUNT IV, paragraphs 43 to 46, WHEREFORE | OK. |
| 10 | Items a to h | OK. Ends short: the last JURY TRIAL DEMANDED stays with the signature. |
| 11 | JURY TRIAL DEMANDED, "Dated:", signature block (Respectfully submitted, firm, s/ line, attorneys with PA ID numbers, counsel line, address, telephone) | OK; the signature never stands alone. |

The docx PDF breaks every line and page where the typst PDF does (XENG-001..003: 291/291 lines, 11/11 pages).

Defects of the earlier template (fixed by the cross-engine port, fb-595.68.35): em leadings and `set block(spacing)` instead of line boxes, the number followed by a 0.5 in space (the docx used a tab), the caption's right column centred on the rows, and a docx in EB Garamond 13 pt on a 26 pt pitch.

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): the docx render breaks every line and every page where the typst render does, and `eval.yaml` gates it (`params.cross_engine: gate`, fb-595.68.35).

- **typst** (primary, `typst/pawd-complaint.typ`): the reference for the court's form.
- **docx** (`docx/`): `docx/reference.xml` (`base="xengine"`, the typst face `{font}` = Times New Roman, 12 pt; Body Text in exact 24 pt line boxes with a 0.5 in first-line indent, single lines 13.8 pt; the heading levels at the type size on the body pitch; "Numbered Paragraph" with a tab 1 in from the margin; "Lettered" hanging at 1 in; letter page, 1 in margins, the footer 0.5 in above the edge) and `docx/pawd-complaint.lua` on `lib/docx/xengine.lua`, which cuts the sample's body into chunks as the typst template does (a count heading's further source lines stay heading lines) and writes the court title, the caption table, the title, the lead-in, the numbered paragraphs and lettered items (typed, as typst types them), the signature kept with the last block, the footer (`$FORMBOOK_FOOTERS`) and the last section (`$FORMBOOK_FINAL`). `fb render` builds the reference and runs the passes; no shell script (fb-595.68).
- Checks (2026-10-22): typst 9 passed, 0 failed; docx 13 passed, 0 failed, XENG-001..003 PASS (291/291 lines, 11/11 pages).
- Word: not available here. The file converts in LibreOffice with no error; Word may paginate slightly differently (docs/DOCX.md).
