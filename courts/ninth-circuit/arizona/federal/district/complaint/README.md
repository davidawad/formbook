# D. Ariz. (azd): complaint

Doc type: **complaint** (original or amended) in the United States District Court for the District of Arizona. Folder: `courts/ninth-circuit/arizona/federal/district/complaint/`. The court-root `typst/` and `samples/` of `district/` are not touched.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-harod-2-26-cv-05215-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-harod-fac.md`: the whole First Amended Complaint, caption to certificate of service |
| typeface | face required: **none** (LRCiv 7.1(b)(1) names a size and a pitch, not a face; see Governing rules) → **EB Garamond** (vendored, OFL; no substitute). Not metric-compatible with Times, so line count is not the Times line count. |
| render | ok (re-rendered 2026-10-15): `samples/OUTPUT-harod-fac.pdf`, 8 pages, typst 0.15.0, `tools/render.sh`, vendored EB Garamond only (`pdffonts`: EBGaramond-Regular and -Bold embedded), no warnings, exit 0 |
| overlay | **fail** (2026-10-15): `tools/overlay.sh` needs `exemplars/FILED-EXAMPLE-harod-2-26-cv-05215-complaint.pdf`, which is not in this snapshot (not in git, not on disk). No `OVERLAY-harod-fac.pdf` was produced. `OVERLAY-harod-fac.txt` is the earlier page map, not regenerated. |
| pages reviewed | 8 of 8 (re-viewed 2026-10-15 at 60 dpi, every page; no layout change from the render before) |

File names follow the repo's tools: the sample is `INPUT-<id>.md`, the render `OUTPUT-<id>.pdf`, the overlay `OVERLAY-<id>.pdf/.txt`, because `tools/render.sh` and `tools/overlay.sh` read and write those names by default.

## Governing rules

Primary source: D. Ariz. Local Rules of Civil Procedure, the "Local Rules Master File 2020" PDF at https://www.azd.uscourts.gov/sites/azd/files/local-rules/Local_Rules_Master_File_2020.pdf, read 2026-10-14. **The current text was not verified:** courtrules.net and the court's current rules pages returned HTTP 403 to WebFetch and the 2020 file is the newest copy reachable. Before this template is treated as final, check LRCiv 7.1 and 10.1 against the current local rules on azd.uscourts.gov. Quotations below are from the 2020 file.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LRCiv 7.1(a)(1) | Attorney name, address, e-mail, State Bar number, telephone, and the party represented, typed in the space left of center beginning at line 1. | `counsel` frontmatter; `counsel-block()` lines 1 to 5 minimum. |
| LRCiv 7.1(a)(2) | "The title of the Court must begin on or below line six (6) of the first page." | `counsel-lines = 5`: the court title starts on line 6 or lower (Harod: line 7). |
| LRCiv 7.1(a)(3) | Party names in upper and lower case; right of center: (A) the case number, (B) a brief description of the paper including "demand for trial by jury if made", (C) notice/memorandum mention. | `caption()`: `case_number`, `brief_title` (the sample's title includes "AND DEMAND FOR JURY TRIAL"). |
| LRCiv 7.1(a)(3) | Semicolons between parties on an initial or amended complaint. | Not drawn: the sample has one plaintiff and one defendant. Multi-party captions need a template change (gap 6). |
| LRCiv 7.1(b)(1) | "The body of all documents shall be typed double-spaced and shall not exceed 28 lines per page; they shall not be single-spaced except for footnotes and indented quotations." | `pitch = 24pt`, `lines-per-page = 28`, `body-leading = pitch - 0.65 * type-size`; the numbered lines are drawn at the pitch. Measured: 24.0 pt between body lines on page 2 (`pdftotext -bbox-layout`). |
| LRCiv 7.1(b)(1) | "a proportional font size no smaller than 13 point, including any footnotes" (or fixed pitch 10). | `type-size = 13pt`, `font-family = "EB Garamond"`. |
| LRCiv 7.1(b)(1) | Letter size; pages numbered; left margin not less than 1 1/2 inches; right margin not less than 1/2 inch. | `page-w`/`page-h` letter; `page-number-block()` centred in the bottom margin; `left-margin = 1.5in`, `right-margin = 0.75in`. |
| LRCiv 7.1(b)(1) | Signature under Fed. R. Civ. P. 11. | `signature-block()`: "/s/" signature line. |
| LRCiv 7.1 Appendix C | Sample first page: counsel from line 1, court title at line 6, caption box, "DATED this day of ..., 20 ." and the signer's name below the line. | `signature-block()` follows the Appendix C shape ("DATED this ... day of ..."). |
| Fed. R. Civ. P. 8(a) | Jurisdiction grounds, short and plain statement of the claim, demand for relief. | Author content (the sample carries all three); the template does not check the content. |
| Fed. R. Civ. P. 10(a) | Caption: court name, title, file number, Rule 7(a) designation. Fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_10 ("Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation."). | `court-title()`, `caption()`. |
| Fed. R. Civ. P. 10(b) | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." Same source, 2026-10-14. | `allegations()`: each body paragraph is numbered by the template; headings and lists are not. |

Not produced by this template (separate filings or documents the sample does not contain): the civil cover sheet, the Rule 7.1 disclosure statement (and LRCiv 7.1.1 corporate disclosure statement), the summons, and any LRCiv 16.2 filing.

## Layout

- Numbered lines 1 to 28 down the left margin, a double rule at the text's left edge and a single rule at its right (the pleading form, as in the exemplar and Appendix C).
- Top margin 1 inch: line 1 sits on the top margin; the 28 lines end at 10 1/3 inches; the page number is in the bottom margin.
- Counsel block single-spaced from line 1; longer counsel blocks push the court title down, as LRCiv 7.1(a)(2) allows.
- Every block of text is a whole number of 24 pt rows (`on-grid`), so headings, paragraphs and signature blocks land on the numbered lines.
- Paragraphs are numbered 1, 2, ... by the template; a heading stays with the paragraph after it.
- Prayer items (markdown list) are lettered A., B., C., ... (the exemplar's convention, not a rule requirement).
- Certificate of service: optional `certificate` frontmatter (heading, text, signer), unnumbered. The exemplar has one; the local rules do not require one.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1 centred bold caps; level 2 centred bold; level 3 bold italic left), a list (`1.` items, lettered A., B. by the template), or a paragraph (numbered by the template).
- Frontmatter fields: `case_number`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title` (include "AND DEMAND FOR JURY TRIAL" when made), `counsel` (lines, from line 1), `lead_in` (unnumbered lead-in paragraph, optional), `date` (text after "DATED this "), `signature` (`firm` lines, `signer`, `lines`), `certificate` (optional).
- Not supported: tables, footnotes (none in a complaint), raw typst.
- The sample must not put numbering in the text: the template numbers the allegations.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/ninth-circuit/arizona/federal/district/complaint samples/INPUT-harod-fac.md
sh tools/overlay.sh courts/ninth-circuit/arizona/federal/district/complaint harod-fac
```

The overlay page map (ours to filed, by word overlap): p.1→1 (78%), p.2→2, p.3→4, p.4→5, p.5→6, p.6→8, p.7→9, p.8→10. The page pairing is coarse because the sample's paragraph numbers and pagination do not match the filed pages; the exemplar's pleading lines do not coincide with the render's (EB Garamond vs Times). The overlay is a diagnostic, not a score.

## Visual review (Gate 2 record, all 8 pages, 60 dpi, viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel lines 1 to 6, court title lines 7 and 8, caption, title with case number on the right, intro and paragraphs 1 to 4 | OK. Court title below line 6. Caption box closed by right and bottom rules. |
| 2 | Paragraphs 4 to 13, headings PARTIES and JURISDICTION/VENUE | OK. Heading kept with its paragraph. |
| 3 | Paragraphs 13 to 22, FACTUAL ALLEGATIONS | OK. |
| 4 | Paragraphs 23 to 35 | OK. |
| 5 | Paragraphs 35 to 43 | OK. |
| 6 | Paragraphs 43 to 52, COUNT I heading and NEGLIGENCE | OK. Two-line heading centred on the grid. |
| 7 | Paragraphs 52 to 63, COUNT II, JURY TRIAL DEMAND, PRAYER FOR RELIEF heading, WHEREFORE | OK. No heading at the foot of the page. |
| 8 | Prayer items A to D, DATED line, firm block, By /s/ and signer lines, certificate of service | Fixed in this pass: the first version put the date and firm on one line and overlapped the signer lines. Now: date line, firm block right, signer lines below. Re-viewed: OK. |

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP tier 2 asks for 2 or 3 filers from different sources. Not met for this doc type. Searches tried are in `exemplars/SOURCE.md`.
2. **Font.** LRCiv 7.1(b)(1) names no typeface: "fixed-pitch type size no smaller than ten (10) pitch ... or in a proportional font size no smaller than 13 point" (text read 2026-10-15 from the 2020 master file). So the template keeps EB Garamond (vendored, OFL) at 13 pt, per `docs/FONTS.md` ("No face named"), and does not substitute Liberation Serif for the exemplar's Times New Roman. EB Garamond sets smaller than Times at the same size. The vendored fonts are the only ones allowed (no system fonts).
3. **Current rule text not verified** (see Governing rules). The 2020 master file is the source; a 2026 amendment would change the numbers here.
4. **Paragraph numbers differ.** The filed complaint skips paragraphs 46 and 47; the template numbers from 1 to 62 instead of the filed 64. The sample does not carry the filed numbers.
5. **Headings.** The exemplar underlines "INTRODUCTION" and the template does not; the template bolds headings. Convention choice (tier 2/3), not a rule requirement.
6. **Multi-party captions.** LRCiv 7.1(a)(3) requires semicolons between parties on an initial or amended complaint; the template draws "v." and designations only, which is correct for the sample (one plaintiff, one defendant) but not for multi-party cases.
7. **Consolidated actions.** LRCiv 7.1(a)(3) requires the affected case numbers under the lead number for a consolidated complaint. Not drawn.
8. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids touching `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.
9. **Size and format of the exemplar.** The exemplar is an amended complaint, not an original. The form is the same; the template depends only on the form.

## Engines

**docx** (LibreOffice only; Word was not available, so "opens in Word without a repair prompt" is not verified).
`docx/build-reference.sh` builds `docx/reference.docx` (EB Garamond 13 pt, exact 24 pt lines, letter, margins as in the typst template, PAGE field in the footer). `docx/azd-complaint.lua` builds the cover, caption, numbered allegations, lettered relief items, signature and certificate. `sh tools/render.sh --engine docx <this folder> samples/INPUT-harod-fac.md` writes `samples/OUTPUT-harod-fac.docx` and `.docx.pdf`: 8 pages; fonts embedded EBGaramond-Regular and -Bold only.

- Matches typst: body and caption in EB Garamond 13 pt; 28 numbered lines on a 24 pt grid; counsel from line 1; court title on line 7; caption ruled right and below; allegations numbered; pages 1 to 8 viewed at 60 dpi (all 8), and the left pleading rule checked at 150 dpi (double).
- Differs, and why: (1) the pleading numbers 1 to 28 are a floating text box in the header (Word and LibreOffice place it from the page edge, not from the text); (2) the two pleading rules are page borders around the text area, so they run from the top to the bottom margin, not the full page height as in typst; (3) the caption row height is estimated from the number of wrapped lines, so the grid below it can differ by a line from typst; (4) no typst PDF is in `samples/` for this doc type (`OUTPUT-harod-fac.pdf` is not in this snapshot), so the docx was compared with the typst template and the review above, not with a rendered typst page.
- BLOCKED: `tools/check.sh <folder> --engine docx` cannot run on a doc-type folder: it reads `court.json` and `checks.yaml` from the folder it is given (exit 2). No stamp is written. Every Gate 1 rule check in `checks.yaml` is therefore not run for docx; the observations above are not a gate result.
