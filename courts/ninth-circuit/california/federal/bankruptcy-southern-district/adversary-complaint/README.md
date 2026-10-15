# casb: adversary complaint

Doc type: **adversary complaint** (FRBP 7001 adversary proceeding) in the United States Bankruptcy Court for the Southern District of California (`casb`).
Folder: `courts/ninth-circuit/california/federal/bankruptcy-southern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-steakhouse-partners-09-90163-adversary-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-steakhouse-partners-complaint.md`: the complaint in full (caption, paragraphs 1 to 38, the claim headings, the prayer and the signature block) |
| render | ok: `samples/OUTPUT-steakhouse-partners-complaint.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-steakhouse-partners-complaint.pdf` and `.txt` (pages paired by word overlap; 61 to 97%) |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed after the last template change; see the review table) |

The exemplar is 13 pages; the sample has the complaint's pages 3 to 13 (pages 1 and 2 are the Form B 104 cover sheet, which is a separate court form and is not transcribed).

## Governing rules

Primary and secondary sources, with how each was checked. The casb local rules are not reachable from this box (casb.uscourts.gov and courtrules.net return 403 to the fetcher), so local-rule text is taken from a secondary source and is marked as such.

| ID | Rule | Requirement | How it was checked | Where it lives |
|---|---|---|---|---|
| CASB-FORM-004 | Fed. R. Bankr. P. 7010 | "Fed. R. Civ. P. 10 applies in an adversary proceeding—except that a pleading's caption must substantially conform to the appropriate version of Form 416." Civil Rule 10 governs the rest of the pleading's form (caption, numbered paragraphs). | Fetched from https://www.law.cornell.edu/rules/frbp/rule_7010 on 2026-10-14 (text quoted in the sentence above). Civil Rule 10 itself was not fetched. | caption (`in_re`, `caption`, `case_number`, `adv_number`, `chapter`, `brief_title`, `judge`); numbered paragraphs (`allegations()`) |
| CASB-FORM-005 | Fed. R. Bankr. P. 9004(a) | "A petition, pleading, schedule, or other document must be clearly legible." | Fetched from https://www.law.cornell.edu/rules/frbp/rule_9004 on 2026-10-14. | all text at 12 pt; no condensed type |
| CASB-FORM-006 | Fed. R. Bankr. P. 9004(b) | Caption contents: court name, title of the case, case number and adversary number, and a brief designation of the paper. | Summary of subdivision (b) on the same Cornell page (fetched 2026-10-14). | caption, footer |
| CASB-FILE-001 | Fed. R. Bankr. P. 7001, LBR 7003-1 | Adversary complaint with the Form B 104 cover sheet. | Form B 104 is on the exemplar (pages 1 and 2). LBR 7003-1 (Form B 1040 and the complaint, plus Local Form CSD 2500A if needed) is from a search-index excerpt of courtrules.net; the primary text was not fetched. | not produced by the template (see Known gaps) |
| CASB-FORM-001 | S.D. Cal. Admin. Proc. 2.4, 2.3(a), 2.5 (via Practical Law note) | Pagination at the bottom of each page; caption detail; quotations single-spaced and indented 5 to 20 spaces. | Practical Law, "Local Bankruptcy Rules: California (S.D. Cal.)" (2021), hosted at https://www.foley.com/wp-content/uploads/imported/0f7995fa1f064f049f1ba48fe094d4d2.pdf, pages 45 to 47. Secondary; primary not fetched. | footer (page number); no quotations in this sample |
| CASB-FORM-002 | S.D. Cal. Admin. Proc. (line spacing, same note) | Double-spaced, except the counsel block, title of the action, category headings, footnotes, quotations, exhibits and real-property descriptions. | Same note. The font size is not stated in the note. | body at 24 pt pitch; counsel and caption single-spaced |
| CASB-FORM-003 | Convention (both exemplars) | Pleading paper: 28 numbered lines down the left margin, double rules, footer under the lines. | Read from the text layers of both casb exemplars (line numbers 1 to 28 on each page extracted: Kennedy pp. 3 to 13, Stika pp. 1 to 5 of the motion). Not a rule text; a tier-2 convention. | `line-numbers()`, `pleading-rules()`, `lines-per-page = 28` |

Not verified against primary text, so not asserted as a rule by this template: the font (EB Garamond is used; the exemplar's font is not part of this check), the 12-point size (the CAND templates use it; no casb rule text was read), and any requirement for a footer title.

## Layout

- Counsel block from line 1 (single-spaced); the court title starts at line 8 or after the counsel block, whichever is lower.
- Caption: a left column with "In re" and the debtor, then the adversary parties with "vs."; a right column with the case number, chapter, adversary number, the title, and the judge. The left column is closed by a rule on the right and bottom.
- The body follows the caption on the same page (no page break after the cover). Every block sits on whole numbered lines (`on-grid`), so headings, paragraphs and the signature land on the grid.
- Paragraphs are numbered 1, 2, ... by the template (Civil Rule 10(b), via 7010). Headings and lists are unnumbered. List items (markdown `1.`) are lettered (a), (b), ...
- The unnumbered lead-in ("... allege as follows:") and the closing prayer come from frontmatter (`lead_in`, `closing`).
- The footer is three centered lines: page number, the paper's title, the case number.

## Markdown contract (for samples)

- YAML frontmatter: `case_number`, `adv_number`, `chapter`, `judge`, `brief_title`, `footer_title`, `counsel` (lines), `in_re` (list of `{names, designation}`), `caption` (list of `{names, designation}`; "vs." is inserted between sides), `lead_in` (optional), `closing` (optional, unnumbered), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Body: blank-line-separated chunks. `#` heading (level 1 centered caps; level 2 centered bold; level 3 bold, at the margin); a markdown list (lettered); or a paragraph (numbered).
- Do not number paragraphs in the text; the template does it.

## Overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, jq, gawk (micromamba env at ~/tb)
sh tools/render.sh courts/ninth-circuit/california/federal/bankruptcy-southern-district/adversary-complaint samples/INPUT-steakhouse-partners-complaint.md
sh tools/overlay.sh courts/ninth-circuit/california/federal/bankruptcy-southern-district/adversary-complaint steakhouse-partners-complaint
```

The overlay pairs our pages with the exemplar's pages by word overlap: ours 1 to 11 with filed 3 to 13. Red is our render, blue is the exemplar; the two will not coincide on text lines (the exemplar uses Times and a different line pitch). It is a diagnostic, not a score.

File names: the render and overlay are written as `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf` and `.txt` (what `tools/render.sh` and `tools/overlay.sh` write by default). The brief's `<id>.pdf` naming was not used, so the tools need no change.

## Review of the rendered pages (Gate 2 record)

Every page rendered at 60 dpi and looked at. Findings from the first render are in the "fixed" column.

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel (lines 1 to 8), court title, caption, lead-in | OK. Footer was wrapping the title onto a second line and then overlapping the case number; fixed by stacking the footer (page number, title, case number). |
| 2 | Introduction, paragraph 1 | OK. |
| 3 | Jurisdiction and venue (2 to 3), The Parties (4 to 5), Factual Allegations (6 to 7) | OK. Headings centered; numbering continuous. |
| 4 | Sub-heading "The Debtors' Prior Bankruptcy Cases" (bold, left) and paragraphs 8 to 12 | OK. Sub-headings sit on their own line with the paragraph after them. |
| 5 | Paragraphs 13 to 19 (19 ends with its lead-in) | OK. |
| 6 | List (a) to (d) under 19; paragraphs 20 and 21 | OK. Lettered items indent correctly; the list does not overlap the next paragraph. |
| 7 | Paragraphs 22 to 26 | OK. |
| 8 | Paragraph 26 (end), "The Estates' Professionals", 27 and 28 | OK. |
| 9 | Paragraphs 29 to 33; "FIRST CLAIM FOR RELIEF" heading at line 25 with 34 and 35 following | OK. Heading kept with its paragraph. |
| 10 | Paragraphs 36 to 38; list (a) to (d) under 37; the WHEREFORE paragraph starts at line 27 | OK. |
| 11 | WHEREFORE (continues), "Dated" line, "Respectfully submitted" and the signature block | OK after the footer fix. The signature block is single-spaced, as in the exemplar. |

Pages 2 to 10 were rendered and looked at before the footer change; the footer change was then checked on pages 1 and 11. The footer is the only element that changed, and it is at the bottom of every page, so the body layout is unchanged.

## Known gaps and open choices

1. **One filer only.** The brief asks for one exemplar per doc type; EVAL-LOOP tier 2 asks for two or three filers. Searched CourtListener (search API, 2026-10-14) for casb adversary complaints: Stika v. Alegria (25-90036, Doc 1) is a 3-page scan with no text layer, so it was not used. Kennedy (this exemplar) is the only text-based casb complaint that the search returned with a PDF.
2. **Local rules not verified.** LBR 7003-1 and the casb administrative procedures are cited through a search excerpt and a 2021 practice note; the primary text was not reachable (403). The template's pleading paper and footer follow the exemplars, not a fetched rule. A reviewer with the current administrative procedures should check the caption wording and the line-spacing exceptions.
3. **Cover sheet not produced.** Form B 104 (the adversary proceeding cover sheet) and the summons (Form B 1040 / CSD 3007) are separate filings and are not generated.
4. **Font.** EB Garamond at 12 pt, vendored in `fonts/`. The exemplar is Times-like, so the text looks slightly smaller on the page. This is a font choice, not a rule.
5. **Paragraph numbers.** The sample numbers its allegations from 1 to 38, matching the filed paragraph numbers; the template numbers them, so any change to the text changes the numbers.
6. **Headings must fit the grid.** Headings are whole numbered lines (multi-line allowed). A heading is kept with the paragraph after it.
7. **Left column of the caption.** The party column is closed by a rule (right and bottom), the convention seen on the exemplar. Recorded as ACCEPTED.
8. **Case names are roman in the sample.** The 2009 exemplar text layer has no italic markup; the template italicizes `*...*` if a sample carries it.
9. **Overlay pairing.** Pages pair coarsely (see Overlay).
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. Render, overlay and page review were run instead.

## Engines

**docx** (`docx/`): `sh tools/render.sh --engine docx courts/ninth-circuit/california/federal/bankruptcy-southern-district/adversary-complaint samples/INPUT-steakhouse-partners-complaint.md` writes `samples/OUTPUT-steakhouse-partners-complaint.docx` and `.docx.pdf` (LibreOffice PDF, 11 pages, EB Garamond embedded). Built by `docx/build-reference.sh` (reference.docx), `docx/render.sh` (sets the footer from the frontmatter) and `docx/casb-adversary-complaint.lua`.

- Matches the typst output in the mandated form: EB Garamond 12 pt, 24 pt line pitch on the body and the numbered lines, 28 line numbers on the grid, double and single pleading rules, the three-line footer (page, title, case number), the counsel block from line 1, the caption, numbered allegations, lettered lists, the signature block.
- Differs: the numbers are a framed header block and the rules are page borders (double rule 14 pt from the text, single 7 pt from it), not the typst background; the footer and rules are placed by Word/LibreOffice layout, not by coordinates. Checked with LibreOffice only (Word is not available here).
- No typst `OUTPUT-steakhouse-partners-complaint.pdf` exists in `samples/` in this snapshot, so there is no typst page to compare against; the pages were judged against the typst template.
- BLOCKED: `tools/check.sh <this folder> --engine docx` exits 2 (`court.json` and `checks.yaml` are missing from this doc-type folder; they are court-level files and were not created). No gate result is claimed. Gate 0 was checked by hand for word presence only (every body word is in the PDF text; only frontmatter keys are absent, as expected).
