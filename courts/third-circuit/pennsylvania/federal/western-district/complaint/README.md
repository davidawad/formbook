# W.D. Pa. (pawd): complaint

Doc type **complaint** in the United States District Court for the Western District of Pennsylvania (`pawd`, Third Circuit).
Folder: `courts/third-circuit/pennsylvania/federal/western-district/complaint/`. Built by the wave-3 unit fb-595.31.16 (Haiku); the court root `typst/` and `usage/` were not touched.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-pawd-complaint-cragle226cv02200.pdf` (primary, transcribed) and `usage/SAMPLE-pawd-complaint-snee222cv00119.pdf` (second filer, saved for comparison, not transcribed). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-pawd-complaint-cragle.md` (the whole filing: caption, 46 numbered paragraphs, four counts, prayers, jury demands, signature) |
| render | ok: `usage/OUTPUT-pawd-complaint-cragle.typst.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no typst warnings (`tools/render.sh` exit 0) |
| overlay | ok: `usage/OVERLAY-cragle-complaint.pdf` and `usage/OVERLAY-cragle-complaint.txt` (`tools/overlay.sh` exit 0) |
| pages reviewed | 12 of 12: every page rendered at 60 dpi (`pdftoppm -r 60`) and viewed after the last template change |

File names: the brief asked for `usage/<id>.md`, `usage/<id>.pdf` and `usage/<id>-overlay.pdf`. `tools/render.sh` and `tools/overlay.sh` (not edited, per the brief) write and read `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, so those names are used. The sample is `INPUT-pawd-complaint-cragle.md`, so its id is `cragle-complaint`.

## Governing rules

Checked 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCvR 5.1.A (W.D. Pa. Local Rules, manual at https://www.pawd.uscourts.gov/sites/pawd/files/lrmanual20181101.pdf, the text headed "November 1, 2016") | 8½ × 11 inch white paper. | `paper: "us-letter"`. |
| LCvR 5.1.B (same) | Lettering not smaller than 12 point; text double-spaced; quotations over two lines may be indented and single-spaced; headings and footnotes may be single-spaced; margins at least one inch on all four sides; page numbers may be in the margins, no text in them. | `type-size = 13pt` (see Known gaps 1); `leading: 1.35em` with a 0.65 em line gives a 26 pt baseline pitch (measured: 67.36 → 93.36 pt on page 2); `margin: 1in`; page number centered in the footer, in the bottom margin. |
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

- Court title centered in capitals on two lines; the caption is a grid: parties in the left column, a ")" column, and the case number, jury demand and "Electronically Filed" in the right column, which spans the rows.
- The title is centered in bold capitals below the caption; the lead-in paragraph follows, indented.
- Section headings (`#`) are centered bold capitals; count headings (`##`) are centered bold; each source line of a heading is its own line.
- Numbered paragraphs: first-line indent 0.5 in, the number followed by a 0.5 in tab, then the text. Lettered sub-paragraphs (a., b., ...) are indented with a hanging number.
- WHEREFORE paragraphs are unnumbered; the prayer items that follow them are lettered.
- Signature block: "Dated:" line, then "Respectfully submitted," and the firm, the signer's "s/" line and the attorney lines, all single-spaced in the right half of the page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `case_number`, `caption` (a list of `{names, designation}`, with "v." inserted between), `title`, `jury_demand` (bool), `electronically_filed` (bool), `lead_in` (the unnumbered opening paragraph), `date`, `signature` (`lead`, optional `firm` list, `signer`, `lines`).
- Body: blank-line-separated chunks. `#` = section heading, `##` = count heading (several source lines allowed), `### ` = left-aligned sub-heading; a paragraph starting "WHEREFORE" or "JURY TRIAL DEMANDED" is unnumbered; a run of lines starting "- " is a lettered list (a., b., ...); any other paragraph is numbered.
- Numbering is done by the template: the sample must not contain paragraph numbers.
- Not supported: tables, footnotes (not used in this doc type), raw typst.

## What the overlay shows

`usage/OVERLAY-cragle-complaint.pdf`: each page is red (our render) multiplied over blue (the filed exemplar's page with the most shared words). Black is where both agree. The page pairing is by word overlap, not index (`usage/OVERLAY-cragle-complaint.txt` lists the pairs). Final map: ours p.1 to filed p.1 (95%), p.2 to p.2 (83%), p.3 to p.3 (75%), p.4 to p.4 (76%), p.5 to p.5 (74%), p.6 to p.6 (60%), p.7 to p.7 (73%), p.8 to p.9 (74%), p.9 to p.10 (54%), p.10 to p.8 (56%), p.11 to p.9 (68%), p.12 to p.11 (53%). The overlay is a diagnostic, not a score. Pages 8 to 12 pair with a later or earlier filed page because the sample's count breaks fall on different pages from the filing's.

## Known gaps and open choices

1. **Font size and face.** The only vendored font is EB Garamond (`fonts/eb-garamond/`). The rule sets a 12-point minimum, not a face. The template uses 13 pt, because EB Garamond's x-height is smaller than Times 12 pt; the exemplar is Times, so the sample looks slightly smaller in its text than the exemplar at 12 pt. This is within the rule. A Times-metric vendored face would remove the choice (`fonts/` is not touched by this unit).
2. **Exemplar caption error (Snee).** The second exemplar's printed heading says "DISTRICT OF MASSACHUSETTS" over a W.D. Pa. docket. The template follows the W.D. Pa. caption (Cragle, which is correct). Recorded here, not followed.
3. **Only one exemplar transcribed.** The brief asks for one primary exemplar per doc type; the second filer (Snee) is saved but not compared page by page. Tier-2 comparison against two filers is therefore partial (structure only: numbered paragraphs, counts, prayers, jury demand, signature block).
4. **Count heading.** The Cragle heading for Count III runs over three lines in the filing ("COUNT III: FAMILY AND MEDICAL LEAVE ACT / 29 USCS §§ 2611 et seq. / RETALIATION"); the sample keeps those lines, and the template renders each source line on its own line.
5. **Page gaps.** Several pages end with two or three blank lines where the next numbered paragraph or sub-heading moved to the next page (block-level layout, sticky headings). The filing also leaves gaps. Not a rule issue.
6. **Judge practices not checked.** LCvR 7.A makes each judge's practices (posted on the court's chambers pages) apply to motions; the chambers pages were not retrieved, so any judge-specific complaint format is not covered.
7. **Caption box.** The caption closes with a ")" column (as the Cragle exemplar does). No rule text requires a particular caption style; this is a convention choice, recorded as accepted.
8. **No numbered pleading lines.** The W.D. Pa. rules do not require numbered lines, and neither exemplar has them; the template does not draw them.
9. **Overlay pairing.** Pages are paired by word overlap; the lowest pairings (p.9 to 54%, p.12 to 53%) are the count pages, where the sample and the filing break differently. Not a text defect; the rendered text was checked page by page.

## Review of the rendered pages (Gate 2 rows, final PDF, 60 dpi)

Each page was rendered and viewed after the last template change (the count-heading line split and the signature offset).

- p.1: court title, caption (plaintiff and defendant, ")" column, "Civil Action No. 2:26-cv-2200", JURY TRIAL DEMANDED, Electronically Filed), title, lead-in, JURISDICTION AND VENUE, paragraphs 1 to 3 (paragraph 3 ends the page area). PASS.
- p.2: paragraphs 4 to 5 with sub-paragraphs a, b, c; PARTIES; paragraphs 6 to 8. Sub-paragraph and heading spacing correct. PASS.
- p.3: FACTUAL ALLEGATIONS, paragraphs 9 to 18, left-aligned, double-spaced. PASS.
- p.4: paragraphs 19 to 28; COUNT I heading; paragraph 29. PASS.
- p.5: paragraphs 30 to 33; WHEREFORE with items a to c. PASS.
- p.6: items c (cont.) to g; JURY TRIAL DEMANDED; COUNT II heading; paragraphs 34 to 35. PASS.
- p.7: paragraphs 35 (cont.) to 38; WHEREFORE with item a. PASS.
- p.8: items b to h; JURY TRIAL DEMANDED; COUNT III heading (three lines); paragraph 39. PASS.
- p.9: paragraphs 40 to 43; WHEREFORE with items a to d. PASS.
- p.10: items e to h; JURY TRIAL DEMANDED; COUNT IV heading; paragraphs 43 to 45. PASS.
- p.11: paragraph 45 (cont.) and 46; WHEREFORE with items a to f. PASS.
- p.12: items g and h; JURY TRIAL DEMANDED; "Dated: October 7, 2026"; signature block (Respectfully submitted, firm, s/ line, attorneys with PA ID numbers, counsel line, address, telephone). PASS.

Earlier review passes found and fixed: paragraphs running into one another (blocks were inline), headings overlapping text (block spacing equal to text height rather than the 26 pt pitch), caption rows overlapping, and a statute line that had been numbered as paragraph 39. Those are fixed in the current render.

## Engines

- **typst** (primary, `typst/`): the reference for the court's form.
- **docx** (`docx/reference.docx`, `docx/pawd.lua`, `docx/build-reference.sh`; sample `usage/OUTPUT-pawd-complaint-cragle.docx`): built with pandoc 3.6.4 on the reference. Matches the typst template: EB Garamond 13 pt, exact 26 pt (double) line pitch, 1 in margins on US Letter, 0.5 in first-line indent, paragraphs numbered 1 to 46 by the filter (number, tab, text), counts and sections centered in bold, sub-heads flush left, lettered prayer items with a hanging letter, the court heading, the caption (a borderless table: parties, ")" column, case number and jury demand in the right column), the title, the "Dated:" line and the signature block at 3 in, page number centered in the footer.
- Differences from typst: the caption rows are spaced by the table, not the typst grid (a few points per row differ); paragraph numbers and lettered items are typed text, not Word lists; the page number is the PAGE field, which needs no update.
- **BLOCKED** (docx): no `checks.yaml` exists for this court, so no gate check ID can be listed. Every check measured on `usage/OUTPUT-cragle-complaint.docx.pdf` is BLOCKED with the reason "LibreOffice cannot run in the build box, so the .docx.pdf cannot be produced or checked". The `.docx` passes the package checks run here (ziptool reads every entry, xmllint on every XML part, no duplicate style ids); it was not opened in Word or LibreOffice.
