# waed: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Washington (`waed`).
Folder: `courts/ninth-circuit/washington/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (primary, 12 pp.) and `usage/FILED-EXAMPLE-complaint-2.pdf` (second filer, 5 pp.); see `usage/SOURCE.md` |
| sample md | `usage/INPUT-complaint.md` (transcription of all 12 pages; footnotes not transcribed, see gaps) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf` and `usage/OUTPUT-complaint.docx` / `.docx.pdf`, 10 pages each, no warnings; the docx breaks every line and page as typst (XENG-001..003 gated, `eval.yaml`) |
| overlay | `just overlay <this folder>` (written to the gitignored `.overlay/`) |
| typeface | face required: none named by LCivR 10(d) (serif or traditional Roman; proportionately spaced, 14 pt or more; or monospaced). Times New Roman (the exemplar's face and the house standard), pinned install; the docx names the same face (`{font}` in `docx/reference.xml`). |
| pages reviewed | 10 of 10 on each engine (`reviews/docx-review.md`) |

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
| LCivR 10(d) | 8½ × 11 with line numbers in the left margin; serif or traditional Roman type; "a proportionately spaced typeface of 14 points or more"; text double spaced; quotations, headings, captions, signature blocks and certifications may be single spaced. | `type-size = 14pt`, `font-family` Times New Roman, numbers 1 to 20 in `line-numbers()`, `pitch = 32pt` (double spacing), `pitch-single = 16pt` for counsel, caption and signature. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | As LCivR 10(a)(1) above. Text from https://www.law.cornell.edu/rules/frcp/rule_10, fetched 2026-10-14. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers each body paragraph; headings and lists are not numbered. |

Local rules source: E.D. Wash. Local Civil Rules, November 2025 version (per the file name), https://www.waed.uscourts.gov/sites/cst/waed/files/local-rules/LocalCivilRules---November-2025.pdf (linked from https://www.waed.uscourts.gov/rules-policies/local-rules), fetched 2026-10-14. The rule text was read from that PDF.

Not produced by this template: the civil cover sheet (JS-44), the corporate disclosure statement (Fed. R. Civ. P. 7.1), the summons, and any filing under LCivR 3 or LCivR 7.1. The local rules marked LCivR 7.1 "Disclosure Statement" as [Reserved], so no E.D. Wash. disclosure rule is applied here.

## Layout

- Numbered lines 1 to 20 down the left margin, a double rule at the text's left edge and a single rule at its right (the pleading form, as in the exemplar).
- The cross-engine layout model (`lib/typst/xengine.typ`): every line a box of its pitch, 32 pt a numbered line (2 × 16 pt; the exemplar measures 32.2 pt), 16 pt a single line, from the top margin (72 pt); the body and the numbers share the grid.
- Counsel single spaced on lines 1 to 4 (more lines push the court title down); the court title, one numbered line each, from line 5; a blank line; the caption row, whole numbered lines tall, so the body after it is on the numbers.
- Paragraphs are numbered 1, 2, … by the template (the number half an inch in, the text 1 in from the margin); headings are one numbered line, bold, kept with the block after them (`sticky`).
- Lists (the relief items) are lettered A., B., …, the letter half an inch in, the text hanging at 0.9 in.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body chunks are separated by blank lines: a `#` heading (level 1, centered caps), a `##` heading (level 2, centered bold), a `###` heading (bold italic), a list (`1.` items, lettered A., B. by the template), or a paragraph (numbered by the template). A heading that wraps takes two numbered lines.
- Frontmatter fields: `case_number`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `footer_title`, `counsel` (lines), `division`, `jury_demand`, `date`, `signature` (`firm` lines, `signer`, `lines`).
- Not supported: tables, footnotes, raw typst. Inline lists inside a paragraph are written as text (see gaps).
- The template numbers the paragraphs; the sample does not put numbers in the text.

## Overlay

Recorded on an earlier render (9 pages, before the cross-engine port; `just overlay` writes a fresh one to `.overlay/`): the overlay showed our render in red, the filed exemplar in blue, and their overlap in black, page by page. Pages are paired by shared words, not by index (`tools/overlay.sh`); the page map is in `OVERLAY-plenty-complaint.txt`:

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

## Review of the rendered pages

Every page of the typst and docx renders, side by side at 60 dpi, after the last template change: `reviews/docx-review.md`.

## Known gaps and open choices

1. **Two filers, two sizes.** The primary exemplar (Plenty) is 14 pt, which matches LCivR 10(d). The second exemplar (Price) measures about 12 pt, so it does not match the rule. The template follows the rule, not the second exemplar. Tier 2 was compared against both filers; the 12-pt filing is not a model for type size.
2. **Typeface.** LCivR 10(d) names no face: it asks for "serif or traditional Roman typefaces" in "a proportionately spaced typeface of 14 points or more" (or a monospaced face, 10.5 cpi). The template sets Times New Roman, the exemplar's face (the pinned install, docs/FONTS.md).
3. **Lines per page.** LCivR 10(d) does not fix a number of lines. The exemplar has 21; the template has 20, so every line stays inside the 1 in bottom margin with the footer below them.
4. **Footer type size.** The footer is 14 pt (LCivR 10(d) names no exception for footers). The exemplar's footer is smaller; the rule governs.
5. **Footnotes and quotations.** The filed complaint has footnotes (citations to consumer forums); they are not transcribed. Block quotations (paragraph 1 and the consumer reviews in paragraph 26) are run into the text and shortened, marked `[...]`.
6. **Call list.** The thirteen call entries in paragraph 19 of the exemplar are run into one paragraph with (i) to (xiii) in the text, because the markdown contract has no roman-numeral list. The filed layout puts them on separate lines.
7. **Paragraph numbers.** The sample's paragraphs number from 1 (the template numbers them); the filed numbers are not transcribed.
8. **Caption.** The party column is closed by a rule (right and bottom), not a column of ")" marks as seen in some E.D. Wash. filings. A layout choice, recorded as ACCEPTED.
9. **Not produced.** The civil cover sheet, the summons and any disclosure statement are separate filings. No rule in the local rules text fixes a disclosure form for complaints (LCivR 7.1 is [Reserved]).

## Engines

`sh tools/check.sh <this folder> --engine typst|docx` runs every gate on each engine (no latex template). The docx is
held to the typst render by Gate 4 (`params.cross_engine: gate` in `eval.yaml`): the same pages, page ends and line
breaks.

### docx (`docx/`)

Declarative inputs only (docs/DOCX.md, "The docx template without shell"): `docx/reference.xml` (the cross-engine
style recipe in the typst face, `{font}`, at 14 pt, with 32 pt and 16 pt exact lines, plus "Numbered Paragraph" and
"List Letter"), `docx/complaint.lua` (the cover, headings, numbered paragraphs, relief items and signature block as
WordprocessingML) and `docx/lib/pleading.lua` (the pleading paper, shared with the motion folder: the footer that
holds the 20 line numbers in a frame at the page's left edge and the title with the page number, written to
`$FORMBOOK_FOOTERS`; the section with the margins and the pleading rules as page borders, `$FORMBOOK_FINAL`; the
counsel block and the caption row sized to whole numbered lines from Times New Roman's advance widths, as typst
measures them). `fb render --engine docx` builds the reference document and the archive.

What differs (not a rule; tier 2 or 3):

- The pleading rules are page borders that run from the text area, not from the page edge (the typst rules run the full page height).
- Word may paginate differently from LibreOffice; the gate is the LibreOffice PDF's.
