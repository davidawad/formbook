# nvd: complaint

Doc type: **complaint** in the United States District Court for the District of Nevada (`nvd`).
Folder: `courts/ninth-circuit/nevada/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer, see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (the whole 14-page complaint, transcribed) |
| typeface | face required: **none** (LR IA 10-1(a)(3) sets size only: "Text must be size 12 font or larger"). Template face: **Times New Roman** 12 pt, the house face (docs/FONTS.md) and the filed exemplar's face and size; was 13 pt for EB Garamond. Embedded: Times New Roman Regular, Bold, Italic, BoldItalic (`pdffonts`), the same faces in the typst and docx PDFs. |
| render | ok: `usage/OUTPUT-complaint.typst.pdf` and `usage/OUTPUT-complaint.docx.pdf`, 14 pages each, typst 0.15.0 and LibreOffice, vendored fonts only, no warnings (re-rendered 2026-10-22) |
| overlay | ok: `usage/OVERLAY-williams-complaint.pdf` and `.txt` (pairing by word overlap; see below; re-run 2026-10-15) |
| pages reviewed | 14 of 14 on each engine (rasterized at 60 dpi and viewed on 2026-10-22; see Visual review) |
| BLOCKED | none. Tier-2 coverage is short of the eval loop's "two or three filers" (see Known gaps 1). |

## Governing rules

Primary source for the local rules: **D. Nev. Local Rules of Practice** (amended 2020; PDF modified 2025-07-30), https://www.nvd.uscourts.gov/wp-content/uploads/2020/04/Local-Rules-of-Practice-Amended-2020.pdf, fetched and read 2026-10-14. The courtrules.net mirror was not used: its text was out of date for LR 7-3 (it gives 30 pages; the court's PDF gives 24 for motions other than summary judgment).

Federal rules: Fed. R. Civ. P. 10(a), (b), (c) from https://www.law.cornell.edu/rules/frcp/rule_10 (LII text; no "current through" date on the page, amendment note "eff. Dec. 1, 2007"), fetched 2026-10-14.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| NVD-FORM-001 | LR IA 10-1(a)(1) | Double-spaced lines of text; lines numbered consecutively from 1 on the left margin of each page, no more than 28 per page. The caption, the court title, the case name and quotations are exempt from double spacing. | `lines-per-page = 28`, `pitch`, `line-numbers()` |
| NVD-FORM-002 | LR IA 10-1(a)(2) | Legible, one side of each page. | PDF output is one-sided |
| NVD-FORM-003 | LR IA 10-1(a)(3) | Text 12 point or larger. | `type-size = 12pt`; footer 12 pt |
| NVD-FORM-004 | LR IA 10-1(a)(4) | Quotations over 50 words indented and single spaced. | `allegations()`: a `>` chunk is single spaced and indented 0.5 in on both sides |
| NVD-FORM-005 | LR IA 10-1(a)(5) | All pages numbered consecutively. | `footer-block()`, "-N-" |
| NVD-FORM-006 | LR IA 10-1(a)(6) | Margins at least one inch on all four sides. | `top-margin = 1in`, `bottom-margin = 1in`; `pitch` is set so the 28 lines fit between them (Known gaps 3) |
| NVD-FORM-007 | LR IA 10-1(c) | 8½ × 11 inch paper (manual filing). | `page-w`, `page-h`, `paper: "us-letter"` |
| NVD-FIRST-001 | LR IA 10-2 | First page: attorney's name beginning at least one inch below the top; name, Nevada bar number, address, phone, email, party represented. | `counsel` frontmatter, lines 1 to 10 at the top margin |
| NVD-FIRST-002 | LR IA 10-2 | Court title "UNITED STATES DISTRICT COURT / DISTRICT OF NEVADA"; caption with parties on the left, case number and document title on the right. | `court-title()`, `caption()` |
| NVD-FIRST-003 | LR 38-1 | "JURY DEMAND" typed or printed in capital letters on the first page immediately below the title of the pleading. | `jury_demand: true` puts the words directly under the title |
| NVD-FILE-001 | LR 7.1-1 | Disclosure statement (certificate of interested parties) with the first appearance, pleading or motion. | Not generated: a separate filing (see Not produced). |
| NVD-FILE-002 | LR 3-1 | Civil cover sheet with every new civil action. | Not generated: a separate filing. |
| FRCP 10(a) | caption with court name, title, file number, Rule 7(a) designation | | `court-title()`, `case_number`, `brief_title` |
| FRCP 10(b) | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." | Each body paragraph is numbered by the template; headings, lists, quotations, parentheticals and unnumbered sections (`unnumbered_sections`) are not. | `allegations()` |

Not produced by this template (separate filings or content the author writes): the civil cover sheet (LR 3-1); the disclosure statement (LR 7.1-1); the summons; the Rule 7.1 statement; any certificate of service (FRCP 5(d)(1)(B): "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system"; the sample has none, as in the exemplar).

## Layout

- Numbered lines 1 to 28 down the left margin, one per 23 pt line box from the top margin (28 x 23 pt = 644 pt between the 1 in margins). Double rule at the text's left edge, single rule at its right (the pleading form).
- Counsel block single-spaced from line 1 (13.8 pt lines), filling lines 1 to 7 at least; a blank numbered line; the court title (bold, two lines); a blank line; the caption box: parties at left (rule right and bottom, "v." with a single line clear above and below), "Case No.:", the document title, "JURY DEMAND", then the claims summary (`summary`) as numbered hanging items.
- Body (from page 2): numbered paragraphs, the number in a 0.5 in box after a 0.5 in indent, the text at 1 in; headings: level 1 centered caps, level 2 centered bold, level 3 bold italic; the claim parenthetical is centered and unnumbered. A heading (and a parenthetical) stays on the page of the block after it.
- Prayer and the closing jury demand are unnumbered (`unnumbered_sections`), prayer items are a markdown list (`1.`, ...).
- Signature block: `DATED`, then firm, "By: /s/" signer and the signer's co-counsel lines, at 2.6 in from the left.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body chunks are blank-line separated: a `#` heading (level 1), `##` (level 2), `###` (level 3), a `1.` list (prayer items; numbered as typed), a `>` quotation, a `(...)` parenthetical line (centered), or a paragraph (numbered by the template unless its section is in `unnumbered_sections`).
- Frontmatter: `case_number` (empty for a new complaint: the sample prints "Case No.:"), `counsel` (lines), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `summary` (claims list, optional), `brief_title`, `jury_demand`, `footer_title` (optional), `lead_in` (unnumbered lead-in, optional), `unnumbered_sections`, `date`, `signature` (`firm`, `signer`, `lines`).
- Do not number the paragraphs in the text; the template does it. Do not put line breaks in the text; each paragraph is one chunk.
- Non-breaking spaces (U+00A0) bind "42 U.S.C.", "§ 12112" and "et seq." in headings so the citations do not split across lines.

## Samples and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
D=courts/ninth-circuit/nevada/federal/district/complaint
sh tools/render.sh $D usage/INPUT-complaint.md   # -> usage/OUTPUT-complaint.typst.pdf
sh tools/overlay.sh $D williams-complaint                    # -> usage/OVERLAY-williams-complaint.pdf and .txt
```

Naming: the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt`, with the sample named `INPUT-<id>.md`; these follow `tools/render.sh` and `tools/overlay.sh` defaults, which are not changed here.

- `usage/OVERLAY-williams-complaint.pdf`: red = our render, blue = exemplar, black = both. The page map (`.txt`) pairs pages by word overlap: ours p.1 to 14 with filed p.1 to 13 (the last pairing is coarse; the filed document has 14 pages and ours pairs p.14 with p.13 by word overlap). The overlay is a diagnostic, not a score: the exemplar's line numbers and Times text do not coincide with ours, and the ECF header of the exemplar is not reproduced.

## Visual review (Gate 2 record: every page rendered at 60 dpi and viewed)

Re-done 2026-10-22 for the cross-engine port (fb-595.68.23): all 14 pages of `usage/OUTPUT-complaint.typst.pdf` and all 14 of `usage/OUTPUT-complaint.docx.pdf` rasterized at 60 dpi and viewed side by side.

| Page | What it is | Finding (typst and docx) |
|---|---|---|
| 1 | Counsel (single lines from line 1), court title on lines 11 and 12, caption: parties, "v.", designations; Case No., title, JURY DEMAND, claims (1) to (7) hanging; footer "-1-" and the title | OK on both; the party column's rule runs the full height of the caption row and closes under it. |
| 2 | Lead-in, JURISDICTION AND VENUE, paragraphs 1 to 6, NATURE OF THE ACTION, PARTIES | OK; every double-spaced line on a numbered line. |
| 3 | FACTUAL ALLEGATIONS, paragraphs 7 to 14 | OK. |
| 4 | Paragraphs 14 (end) to 19 | OK. |
| 5 | Paragraph 20, FIRST CLAIM heading, sub-heading and parenthetical, paragraphs 21 to 27 | OK; heading group kept with its first paragraph. |
| 6 | Paragraphs 28 to 34, SECOND CLAIM heading group | OK. |
| 7 | Paragraphs 35 to 42, THIRD CLAIM heading group | OK. |
| 8 | Paragraphs 42 (end) to 48; three numbered lines left blank at the foot (the FOURTH CLAIM group moves on with its first paragraph) | OK. |
| 9 | FOURTH CLAIM heading group, paragraphs 49 to 57 | OK. |
| 10 | Paragraphs 57 (end) to 66, FIFTH CLAIM heading group | OK. |
| 11 | Paragraphs 66 (end) to 73, SIXTH CLAIM heading group | OK. |
| 12 | Paragraphs 73 (end) to 83, SEVENTH CLAIM heading group (two-line sub-heading) | OK. |
| 13 | Paragraphs 84 to 88, PRAYER FOR RELIEF, WHEREFORE, prayer item 1 | OK; prayer items numbered in a half-inch box, text hanging at 1 in. |
| 14 | Prayer items 2 to 6, DEMAND FOR JURY TRIAL, DATED line, signature block at 2.6 in | OK. |

## Known gaps and open choices

1. **One filer only.** The eval loop asks for two or three exemplars from different filers before tier 2 is judged. Searches (CourtListener RECAP API, `type=r`, `court=nvd`, complaints filed 2025-06 to 2026-10): Ward v. Tesla (2:26-cv-00800, 17 pp.) and Nguyen v. Wynn (2:26-cv-00176, 19 pp.) were downloaded and checked for a text layer, but they have the same filer (Greenberg Gross); Villanueva v. Tesla (3:25-cv-00678, 26 pp.) and Vanlake v. Breakthru (2:26-cv-00921, 15 pp.) were found but not downloaded. Tier 2 is therefore **not** judged against a second filer yet.
2. **Type size.** The rule requires 12 pt or larger (LR IA 10-1(a)(3)). Body text is 12 pt Times New Roman, the exemplar's size; the 13 pt of the earlier template was chosen for EB Garamond and was dropped with that face.
3. **Line pitch.** The exemplar uses a 24 pt grid, so its 28th line sits at about 10.3 in, which breaches the one-inch bottom margin (LR IA 10-1(a)(6)). This template fits the 28 lines between the one-inch margins (pitch 23 pt, a whole number of twips so Word sets the same lines), which keeps the margins compliant. **This departs from the exemplar's grid; David should confirm the reading.**
4. **JURY DEMAND wording.** LR 38-1 says "JURY DEMAND" directly below the title. The exemplar wrote "DEMAND FOR JURY TRIAL" in the caption. This template follows the rule text. The body still ends with a separate "DEMAND FOR JURY TRIAL" section, as in the exemplar.
5. **Claims summary in the caption.** The exemplar lists its seven claims in the caption's right column. This template reproduces that when the sample supplies `summary`; the rules do not require it.
6. **Paragraph numbers differ.** The filed complaint numbers its allegations from 2 (paragraph 1 is a stray caption artifact); the template numbers from 1. The filed paragraph numbers are not transcribed.
7. **Footer.** Page number "-N-" and the title in 12 pt capitals. Both are in the bottom margin.
8. **Ragged right.** Body text is left-aligned, not justified. The exemplar's text layer does not show its justification; this is a convention choice and is not asserted.
9. **Counsel block.** Counsel is single-spaced, as in the exemplar. LR IA 10-1(a)(1) double-spacing excludes the caption and court title but does not name counsel blocks; reading them as a format item (LR IA 10-2) is the choice made here.
10. **Not produced:** civil cover sheet (LR 3-1), disclosure statement (LR 7.1-1), summons, certificate of service (not required by FRCP 5(d)(1)(B) for ECF service).
11. **Check scripts.** `tools/check.sh` runs on this folder (typst and docx; the stamps are in `usage/`).
12. **Content not checked.** The template does not check FRCP 8 pleading content (short and plain statement, jurisdiction, demand for relief); those are author-written.

[Parent: nevada/federal/district](../README.md)

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"; fb-595.68.23), and `eval.yaml` gates it (`params.cross_engine: gate`): the docx render breaks every line and every page where the typst render does (XENG-001..003, 445 of 445 lines).

- **Vertical model.** Every line is a box of its pitch with the baseline at 0.8 of it: 23 pt (460 twips) for a numbered line (28 of them fit between the 1 in margins, LR IA 10-1(a)(1), (6)), 13.8 pt (276 twips) for a single line. Every other vertical length is a multiple of 4.6 pt, and a run of single lines has 0.5 pt (10 twips) before and 4.1 pt (82 twips) after it, so each single line's baseline is level with a line number or at least 4.6 pt clear of it: the line numbers are text in both PDFs, and this keeps each number on the same text line in both.
- **typst** (`typst/nvd-complaint.typ`): Times New Roman 12 pt (was 13 pt, chosen for EB Garamond), the line numbers and the pleading rules as page background, the footer in the foreground.
- **docx** (`docx/reference.xml`, `docx/nvd-complaint.lua`): the styles are the cross-engine recipe (`base="xengine"`) in the typst face (`{font}`); the filter writes every paragraph with its own spacing, the caption as a one-row table (the party column's right and bottom rules as cell borders), the footer through `$FORMBOOK_FOOTERS` (the 28 line numbers in a text box anchored to the page, "-N-" as a PAGE field, the paper's title) and the last section through `$FORMBOOK_FINAL` (margins; the pleading rules as page borders). No shell: `docx/render.sh`, `docx/build-reference.sh` and the committed `reference.docx` are gone. pandoc reads without `fancy_lists`, so a "(a)" opening a line stays text, as in typst.
- **Differs from typst** (no text effect): the pleading rules are Word page borders, which run the height of the text area, not of the page.
- Not verified in Word (only LibreOffice here).

`sh tools/check.sh <dir>`: 9 passed, 0 failed (typst); `--engine docx`: 13 passed, 0 failed, XENG-001..003 PASS.
