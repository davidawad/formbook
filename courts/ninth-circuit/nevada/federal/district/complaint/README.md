# nvd: complaint

Doc type: **complaint** in the United States District Court for the District of Nevada (`nvd`).
Folder: `courts/ninth-circuit/nevada/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer, see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (the whole 14-page complaint, transcribed) |
| typeface | face required: **none** (LR IA 10-1(a)(3) sets size only: "Text must be size 12 font or larger"; read 2026-10-15 from the court's 2020 local rules PDF). Substitute: none needed; **EB Garamond** kept (no-face default, `docs/FONTS.md`). Fit: n/a. Embedded: EBGaramond Regular, Bold, Italic, BoldItalic (`pdffonts`). |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 14 pages, typst 0.15.0, vendored EB Garamond only, no warnings (re-rendered 2026-10-15) |
| overlay | ok: `usage/OVERLAY-williams-complaint.pdf` and `.txt` (pairing by word overlap; see below; re-run 2026-10-15) |
| pages reviewed | 14 of 14 (every page rasterized at 60 dpi and viewed on 2026-10-15; p.9 and p.12 re-checked after the heading-spacing change) |
| BLOCKED | none. Tier-2 coverage is short of the eval loop's "two or three filers" (see Known gaps 1). |

## Governing rules

Primary source for the local rules: **D. Nev. Local Rules of Practice** (amended 2020; PDF modified 2025-07-30), https://www.nvd.uscourts.gov/wp-content/uploads/2020/04/Local-Rules-of-Practice-Amended-2020.pdf, fetched and read 2026-10-14. The courtrules.net mirror was not used: its text was out of date for LR 7-3 (it gives 30 pages; the court's PDF gives 24 for motions other than summary judgment).

Federal rules: Fed. R. Civ. P. 10(a), (b), (c) from https://www.law.cornell.edu/rules/frcp/rule_10 (LII text; no "current through" date on the page, amendment note "eff. Dec. 1, 2007"), fetched 2026-10-14.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| NVD-FORM-001 | LR IA 10-1(a)(1) | Double-spaced lines of text; lines numbered consecutively from 1 on the left margin of each page, no more than 28 per page. The caption, the court title, the case name and quotations are exempt from double spacing. | `lines-per-page = 28`, `pitch`, `line-numbers()` |
| NVD-FORM-002 | LR IA 10-1(a)(2) | Legible, one side of each page. | PDF output is one-sided |
| NVD-FORM-003 | LR IA 10-1(a)(3) | Text 12 point or larger. | `type-size = 13pt` (see Known gaps 2); footer 12 pt |
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

- Numbered lines 1 to 28 down the left margin on a grid of 9 in / 28 = 23.14 pt, starting at the top margin. Double rule at the text's left edge, single rule at its right (the pleading form).
- Counsel block single-spaced from line 1; a blank numbered line; the court title (bold, two lines); a blank line; the caption box: parties at left (rule right and bottom), "Case No.:", the document title, "JURY DEMAND", then the claims summary (`summary`) as numbered hanging items.
- Body: numbered paragraphs at 0.5 in indent; headings: level 1 centered caps, level 2 centered bold, level 3 bold italic; the claim parenthetical is centered and unnumbered. A heading stays with the paragraph after it (a single unbreakable block).
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

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel (lines 1 to 10), court title, caption, title, JURY DEMAND, claims list, footer | OK after two fixes: footer page number was overlapping the footer title (fixed with a single-spaced footer); JURY DEMAND moved directly under the title, claims list after it (LR 38-1). |
| 2 | Lead-in, JURISDICTION AND VENUE, paragraphs 1 to 6 | OK. Text on the numbered lines. |
| 3 | FACTUAL ALLEGATIONS, paragraphs 7 to 14 | OK. |
| 4 | Paragraphs 15 to 19 (punitive, malice, oppression, fraud) | OK. |
| 5 | Paragraph 20, FIRST CLAIM heading with sub-heading and parenthetical, paragraphs 21 to 27 | OK; heading kept with its first paragraph. |
| 6 | Paragraphs 28 to 34, SECOND CLAIM heading | OK. |
| 7 | Paragraphs 35 to 42, THIRD CLAIM heading | OK. |
| 8 | Paragraphs 43 to 48 | OK. |
| 9 | FOURTH CLAIM heading (two-line sub-heading, "et seq." kept together) and paragraphs 49 to 57 | OK after binding "et seq." with a non-breaking space; re-checked. |
| 10 | Paragraphs 58 to 65, FIFTH CLAIM heading | OK. |
| 11 | Paragraphs 66 to 72, SIXTH CLAIM heading | OK. |
| 12 | Paragraphs 73 to 80, SEVENTH CLAIM heading (two-line sub-heading) | OK after the "§" binding; re-checked. |
| 13 | Paragraphs 81 to 88, PRAYER FOR RELIEF heading and WHEREFORE line (kept together) | OK. |
| 14 | Prayer items 1 to 6, DEMAND FOR JURY TRIAL (unnumbered), DATED line, signature block | OK after the `unnumbered_sections` change: the WHEREFORE and jury-demand paragraphs had been numbered 89 and 90. |

## Known gaps and open choices

1. **One filer only.** The eval loop asks for two or three exemplars from different filers before tier 2 is judged. Searches (CourtListener RECAP API, `type=r`, `court=nvd`, complaints filed 2025-06 to 2026-10): Ward v. Tesla (2:26-cv-00800, 17 pp.) and Nguyen v. Wynn (2:26-cv-00176, 19 pp.) were downloaded and checked for a text layer, but they have the same filer (Greenberg Gross); Villanueva v. Tesla (3:25-cv-00678, 26 pp.) and Vanlake v. Breakthru (2:26-cv-00921, 15 pp.) were found but not downloaded. Tier 2 is therefore **not** judged against a second filer yet.
2. **Type size.** The rule requires 12 pt or larger (LR IA 10-1(a)(3)). Body text is 13 pt EB Garamond (the rule names no face, so EB Garamond stays; see the typeface row), chosen so it reads at about the size of the exemplar's 12 pt Times New Roman. EB Garamond at 12 pt would be the minimum-compliant alternative. A reader may prefer 12 pt; it is a choice, not a rule breach.
3. **Line pitch.** The exemplar uses a 24 pt grid, so its 28th line sits at about 10.3 in, which breaches the one-inch bottom margin (LR IA 10-1(a)(6)). This template fits the 28 lines between the one-inch margins (pitch 23.14 pt), which keeps the margins compliant and still gives double-spaced lines at this type size. **This departs from the exemplar's grid; David should confirm the reading.**
4. **JURY DEMAND wording.** LR 38-1 says "JURY DEMAND" directly below the title. The exemplar wrote "DEMAND FOR JURY TRIAL" in the caption. This template follows the rule text. The body still ends with a separate "DEMAND FOR JURY TRIAL" section, as in the exemplar.
5. **Claims summary in the caption.** The exemplar lists its seven claims in the caption's right column. This template reproduces that when the sample supplies `summary`; the rules do not require it.
6. **Paragraph numbers differ.** The filed complaint numbers its allegations from 2 (paragraph 1 is a stray caption artifact); the template numbers from 1. The filed paragraph numbers are not transcribed.
7. **Footer.** Page number "-N-" and the title in 12 pt capitals. Both are in the bottom margin.
8. **Ragged right.** Body text is left-aligned, not justified. The exemplar's text layer does not show its justification; this is a convention choice and is not asserted.
9. **Counsel block.** Counsel is single-spaced, as in the exemplar. LR IA 10-1(a)(1) double-spacing excludes the caption and court title but does not name counsel blocks; reading them as a format item (LR IA 10-2) is the choice made here.
10. **Not produced:** civil cover sheet (LR 3-1), disclosure statement (LR 7.1-1), summons, certificate of service (not required by FRCP 5(d)(1)(B) for ECF service).
11. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this is a doc-type folder under the district court, so the gates were not run and no pass stamp is written. The brief also forbids editing `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.
12. **Content not checked.** The template does not check FRCP 8 pleading content (short and plain statement, jurisdiction, demand for relief); those are author-written.

[Parent: nevada/federal/district](../README.md)

## Engines

**docx** (`docx/`): `sh docx/build-reference.sh docx/reference.docx` builds the reference; `docx/complaint.lua` writes the cover and the body; `docx/render.sh` (run by `tools/render-docx.sh`) puts the sample's `footer_title` into the footer. Output: `usage/OUTPUT-complaint.docx` and `.docx.pdf` (LibreOffice 26.8), 14 pages, all 14 rendered at 60 dpi and viewed.

- Matches the typst output: letter; margins 1 in top and bottom, 1.5 in left, 1 in right; EB Garamond 13 pt; 28 numbers on a 462-twip grid, body lines on the numbers (checked on the PDF: body baselines within 0.1 pt of a number); double rule at the left and single at the right (`w:pgBorders`); caption box with the parties, the case number, the title, JURY DEMAND under the title and the claims list; single-spaced counsel and signature block; "-N-" footer with the title; the unnumbered prayer and jury demand.
- Differs from typst: the 28 numbers sit in a header text box, not section line numbering (`w:lnNumType` skips the caption table, so it would not number every line); paragraph numbers are typed by the filter, not Word auto-numbering; the caption box is sized to its text (the body starts on page 2); page breaks follow LibreOffice, Word may move a line.
- Fonts: the PDF is correct only when LibreOffice can see the vendored `fonts/` and no substitute face. This box has no system EB Garamond, so run the check with a `FONTCONFIG_FILE` that lists only the repo's `fonts/` directory; otherwise LibreOffice substitutes silently.
- Not verified in Word (only LibreOffice here). The `.docx` is a valid zip of well-formed XML with every style it uses defined.

BLOCKED: check.sh (Gates 0 to 3, docx): `tools/check.sh` reads `<court-dir>/court.json` and `checks.yaml`, and a doc-type folder has neither (this change may not add them), so the gates did not run and `usage/.check-docx.txt` was not written.
