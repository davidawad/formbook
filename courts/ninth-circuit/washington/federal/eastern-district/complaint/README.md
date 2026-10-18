# waed: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Washington (`waed`).
Folder: `courts/ninth-circuit/washington/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (primary, 12 pp.) and `usage/FILED-EXAMPLE-complaint-2.pdf` (second filer, 5 pp.); see `usage/SOURCE.md` |
| sample md | `usage/INPUT-complaint.md` (transcription of all 12 pages; footnotes not transcribed, see gaps) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-plenty-complaint.pdf` and `OVERLAY-plenty-complaint.txt` |
| typeface | face required: none named by LCivR 10(d) (serif or traditional Roman; proportionately spaced, 14 pt or more; or monospaced). Vendored substitute: not needed, EB Garamond kept (any proportional serif meets the rule). Fit: n/a. Font list: `EB Garamond`, embedded (`pdffonts`). |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change, and again on the fonts pass) |

File names follow the tools (`INPUT-`, `OUTPUT-`, `OVERLAY-`, which `tools/overlay.sh` reads and writes), not the
`<id>.pdf` / `<id>-overlay.pdf` names in the brief.

## Governing rules

Primary sources, verified 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCivR 10(a)(1)(A) | Counsel's name, firm, address and telephone on the left of the first page, above line five. | `counsel` frontmatter; `counsel-block` holds lines 1 to 4 (grows for longer counsel blocks). |
| LCivR 10(a)(1)(B) | Court title in the center of the first page, on or below line five. | `court-title`: "UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF WASHINGTON", and the `division` line; starts on line 5. |
| LCivR 10(a)(1)(C), (D) | Caption on the left below the court title; case number and title of the pleading on the right. | `caption`: parties on the left (ruled), `Case No.` and `brief_title` on the right. |
| LCivR 10(a)(1)(E), 10(a)(2) | Footer on every page: title (or abbreviated title) followed by the page number; sequential pagination. | `footer-block`: `footer_title` in capitals, then the page counter. |
| LCivR 10(d) | 8½ × 11 with line numbers in the left margin; serif or traditional Roman type; "a proportionately spaced typeface of 14 points or more"; text double spaced; quotations, headings, captions, signature blocks and certifications may be single spaced. | `type-size = 14pt`, `font-family = "EB Garamond"`, numbers 1 to 21 in `line-numbers()`, `pitch = 32pt`, `body-leading`, `single-leading` for counsel, caption, headings and signature. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | As LCivR 10(a)(1) above. Text from https://www.law.cornell.edu/rules/frcp/rule_10, fetched 2026-10-14. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers each body paragraph; headings and lists are not numbered. |

Local rules source: E.D. Wash. Local Civil Rules, November 2025 version (per the file name), https://www.waed.uscourts.gov/sites/cst/waed/files/local-rules/LocalCivilRules---November-2025.pdf (linked from https://www.waed.uscourts.gov/rules-policies/local-rules), fetched 2026-10-14. The rule text was read from that PDF.

Not produced by this template: the civil cover sheet (JS-44), the corporate disclosure statement (Fed. R. Civ. P. 7.1), the summons, and any filing under LCivR 3 or LCivR 7.1. The local rules marked LCivR 7.1 "Disclosure Statement" as [Reserved], so no E.D. Wash. disclosure rule is applied here.

## Layout

- Numbered lines 1 to 21 down the left margin, a double rule at the text's left edge and a single rule at its right (the pleading form, as in the exemplar).
- 21 numbered lines at a 32 pt pitch from the top margin (72 pt): 32 pt is 2 × 1.15 × 14 pt, the double spacing measured on the exemplar (32.2 pt). The body and the numbers share the grid (checked on the render with `pdftotext -bbox`: pitch 32.0 pt).
- Counsel block single spaced on lines 1 to 4; the court title starts on line 5.
- Each body block is a whole number of 32 pt rows (`on-grid`), so headings, paragraphs and the signature block land on the numbered lines.
- Paragraphs are numbered 1, 2, … by the template; a heading stays with the paragraph after it (`heading-line`, `sticky`).
- Lists (the relief items) are lettered A., B., …

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body chunks are separated by blank lines: a `#` heading (level 1, centered caps), a `##` heading (level 2, centered bold; one numbered line, so a long sub-heading must be split over two `##` lines), a `###` heading (bold italic), a list (`1.` items, lettered A., B. by the template), or a paragraph (numbered by the template).
- Frontmatter fields: `case_number`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `footer_title`, `counsel` (lines), `division`, `jury_demand`, `date`, `signature` (`firm` lines, `signer`, `lines`), and optionally `lead_in` and `legend` (not used by the sample).
- Not supported: tables, footnotes, raw typst. Inline lists inside a paragraph are written as text (see gaps).
- The template numbers the paragraphs; the sample does not put numbers in the text.

## Overlay

`usage/OVERLAY-plenty-complaint.pdf` shows our render in red, the filed exemplar in blue, and their overlap in black, page by page. Pages are paired by shared words, not by index (`tools/overlay.sh`); the page map is in `OVERLAY-plenty-complaint.txt`:

| our page | filed page | word overlap |
|---|---|---|
| 1 | 1 | 76.5% |
| 2 | 2 | 80.5% |
| 3 | 4 | 47.1% |
| 4 | 5 | 70.0% |
| 5 | 6 | 63.9% |
| 6 | 9 | 29.5% |
| 7 | 10 | 41.8% |
| 8 | 11 | 52.2% |
| 9 | 12 | 71.2% |

The overlay is a diagnostic, not a score. It shows the filed text runs longer than our transcription (footnotes and the consumer-review quotations are shortened or omitted in the sample), which is why filed pages 9 to 12 pair with our pages 6 to 9. The low overlap on pages 6 and 7 is the consumer-review block that the sample shortens.

## Review of the rendered pages (current PDF, every page at 60 dpi)

- Page 1: counsel on lines 1 to 4, court title on lines 5 to 7, caption on lines 9 to 12, title and jury-demand legend at the right, body from line 13. Pass.
- Page 2: paragraphs 4 to 8, the JURISDICTION AND VENUE heading on line 8. Pass.
- Page 3: paragraphs 9 to 15; PARTIES and FACTUAL ALLEGATIONS headings centered. Pass.
- Page 4: paragraphs 15 to 19; the calls list (i) to (viii) runs inside paragraph 19 as text. Pass for layout; see gaps.
- Page 5: paragraphs 19 to 26; the call list ends on line 4. Pass.
- Page 6: paragraphs 26 to 28 (consumer-review block shortened, marked [...]); LEGAL STANDARD heading on line 14. The next heading moved to page 7 with its paragraph (lines 20 and 21 blank). Pass.
- Page 7: CLASS ACTION ALLEGATIONS heading at the top; paragraphs 29 to 36. Pass.
- Page 8: paragraphs 37 to 42; FIRST CAUSE OF ACTION and its two-line sub-heading on lines 11 to 13. Pass.
- Page 9: paragraph 42 ends; RELIEF REQUESTED; items A to F (F wraps to a second line); JURY DEMAND; DATED line and signature block on lines 14 to 18. No text runs into the footer. Pass.

## Known gaps and open choices

1. **Two filers, two sizes.** The primary exemplar (Plenty) is 14 pt, which matches LCivR 10(d). The second exemplar (Price) measures about 12 pt, so it does not match the rule. The template follows the rule, not the second exemplar. Tier 2 was compared against both filers; the 12-pt filing is not a model for type size.
2. **Typeface.** LCivR 10(d) names no face: it asks for "serif or traditional Roman typefaces" in "a proportionately spaced typeface of 14 points or more" (or a monospaced face, 10.5 cpi). EB Garamond meets that, so it stays; no `docs/FONTS.md` substitute applies. EB Garamond at 14 pt has a smaller x-height than the filed exemplar's Times New Roman at 14 pt, so the page looks smaller than the exemplar. The rule's size is met. A Times-metric face (`Liberation Serif`, vendored) would remove the difference, but the rule does not require it, so the template is not switched.
3. **Lines per page.** LCivR 10(d) does not fix a number of lines. The template uses 21 because the primary exemplar does. A different number would move the grid but not break any rule.
4. **Footer type size.** The footer is 14 pt (LCivR 10(d) names no exception for footers). The exemplar's footer is smaller; the rule governs.
5. **Footnotes and quotations.** The filed complaint has footnotes (citations to consumer forums); they are not transcribed. Block quotations (paragraph 1 and the consumer reviews in paragraph 26) are run into the text and shortened, marked `[...]`.
6. **Call list.** The thirteen call entries in paragraph 19 of the exemplar are run into one paragraph with (i) to (xiii) in the text, because the markdown contract has no roman-numeral list. The filed layout puts them on separate lines.
7. **Paragraph numbers.** The sample's paragraphs number from 1 (the template numbers them); the filed numbers are not transcribed.
8. **Caption.** The party column is closed by a rule (right and bottom), not a column of ")" marks as seen in some E.D. Wash. filings. A layout choice, recorded as ACCEPTED.
9. **Not produced.** The civil cover sheet, the summons and any disclosure statement are separate filings. No rule in the local rules text fixes a disclosure form for complaints (LCivR 7.1 is [Reserved]).
10. **Check scripts not run.** `tools/check.sh` expects a court folder with `court.json` and `rules.md`, and this doc-type folder is not that shape. The brief forbids touching `tools/`, so the gates were not run. Render, overlay and the page review above are the checks for this doc type.
11. **Heading length.** A heading must fit on one numbered line (`heading-line` asserts it); the cause sub-heading is split over two `##` lines in the sample for that reason.

## Engines

### docx (`docx/`)

Build and render: `sh docx/build-reference.sh docx/reference.docx` (the reference is generated, so it can be rebuilt), then `sh tools/render.sh --engine docx <this folder> usage/INPUT-complaint.md`, which writes `usage/OUTPUT-complaint.docx` and `usage/OUTPUT-complaint.docx.pdf` (LibreOffice 26.8 conversion; EB Garamond embedded, `pdffonts`). `docx/complaint.lua` lays out the cover, caption and signature block (`docx/pleading.lua`, shared helpers) and numbers the paragraphs; `docx/render.sh` fills the footer title from `footer_title`.

What matches the typst output (checked on the LibreOffice PDF, 9 pages, the same page count and the same first line on every page):

- Letter; 1.1 in left and 1 in right margin; 72 pt top margin; 14 pt EB Garamond (LCivR 10(d)).
- 21 numbers down the left margin in a header text box, on the same 32 pt grid as the body (every body line is an exact 32 pt line; the first counsel line and the first caption line sit on the numbers' baselines).
- Double rule at the left of the text and single rule at the right (page borders); footer `TITLE - n`, one line, left aligned.
- Counsel on lines 1 to 4, court title from line 5, one blank line, caption on lines 9 to 12 with the right rule and bottom rule under the parties (cell borders), case number and title at right.
- Numbered paragraphs (number, tab to 1 in), headings centered (level 1 caps, level 2 bold), lettered relief list (A. to F.), signature block (DATED, "Respectfully submitted," firm, "/s/" and signer lines) on the grid.
- Widow and orphan control off, as in the typst output, so the page breaks fall where typst puts them.

What differs (not a rule; tier 2 or 3):

- Word numbers the lines of this document with a header text box, not with Word's line numbering (`w:lnNumType`), because the typst template numbers the page and the numbers must stay on the grid even on lines that are not body text.
- The pleading rules are page borders that run from the text area, not from the page edge (the typst rules run the full page height).
- The caption rules are cell borders, so they end at the bottom of the parties (as the typst box does), but a Word table may differ by a fraction of a point.
- Word may paginate differently from LibreOffice (line breaking and font metrics); the page map above is the LibreOffice PDF's.
- Tables are not justified; the typst output is not justified either.

Checks: `tools/check.sh` cannot run on a doc-type folder: it reads `<court>/court.json` and `<court>/checks.yaml`, and this folder has neither. The docx PDF was checked by hand instead: every word of the sample is in the PDF (the two exceptions are em-dash joins that `pdftotext` splits), the 9 pages were viewed as PNG (`reviews/docx-review.md`).

BLOCKED: tools/check.sh (all gates, `--engine docx`): the script needs `<court>/court.json` and `<court>/checks.yaml` (`Error: open .../checks.yaml: no such file or directory`), which only exist at court level; no gate ran on this folder, so `usage/.check-docx.txt` is not written.
