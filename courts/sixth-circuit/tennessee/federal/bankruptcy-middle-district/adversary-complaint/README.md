# tnmb: adversary-complaint

Doc type: **adversary complaint** (FRBP 7001 adversary proceeding) in the United States Bankruptcy Court for the Middle District of Tennessee (`tnmb`).
Folder: `courts/sixth-circuit/tennessee/federal/bankruptcy-middle-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-tnmb-adversary-complaint-lemehnoname325ap90071.pdf` (1 filer, the trustee; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-tnmb-adversary-complaint-lemehnoname.md`: the full 5-page complaint, transcribed from the text layer |
| render | ok: `usage/OUTPUT-tnmb-adversary-complaint-lemehnoname.typst.pdf`, 4 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`) |
| typeface | Rules name no face (LBR 5005-3(a): "clearly legible in 12-point font"). Vendored family: `EB Garamond` (`docs/FONTS.md`, "No face named"). Exemplar is Times New Roman: EB Garamond is visual only against it, not metric-compatible. |
| overlay | ok: `usage/OVERLAY-lemeh-no-name.pdf` and `usage/OVERLAY-lemeh-no-name.txt` (`tools/overlay.sh`) |
| pages reviewed | 4 of 4 (every page rendered at 60 dpi and viewed after the last template change) |

File names follow the tools, not the brief's `<id>.pdf` / `<id>-overlay.pdf`: `tools/render.sh` writes `OUTPUT-<id>.pdf`, `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf` and `.txt`, and the markdown is `INPUT-<id>.md` (the file-role names in CLAUDE.md).

## Governing rules

Primary source: Local Bankruptcy Rules of the United States Bankruptcy Court for the Middle District of Tennessee, "Amended and Restated as of July 28, 2025", https://www.tnmb.uscourts.gov/sites/tnmb/files/tfr/2025_Local%20Bankruptcy%20Rules%20Official_0.pdf. The text was extracted from the official PDF with `pdftotext` on 2026-10-14. Federal rules: Fed. R. Bankr. P. 7010 from https://www.law.cornell.edu/rules/frbp/rule_7010 (current as amended effective 2024-12-01), fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LBR 5005-3(a) | 8 1/2 x 11 inch; "clearly legible in 12-point font"; one-inch margins throughout. | `page-w`, `page-h`, `margin = 1in`, `type-size = 12pt` (all text, footer excepted: see Known gaps 4). |
| LBR 5005-3(b) | All pages sequentially numbered at the bottom, with room for the CM/ECF docket footer. | `numbering: "1"`, centered, `footer-descent: 0.6in`. |
| LBR 9004-2(a)(1) | Caption includes the case number, the chapter and the judge's name; the title describes the document. | `caption()` (Case No., Chapter, Judge) and `title` in the frontmatter. |
| LBR 9004-2(b) | Adversary filings also carry the adversary proceeding number. | `caption()`: "Adv. Proc. No." (blank line before filing). |
| FRBP 7010 | Fed. R. Civ. P. 10 applies in an adversary proceeding, except the caption must substantially conform to Form 416. | Court title and caption layout; numbered allegations (Civil Rule 10(b)) in `allegations()`. |
| LBR 7003-1 | An Adversary Cover Sheet (AO form) must be filed with each complaint filed on paper. | Not produced (separate filing; Known gaps 3). |
| LBR 7001-1(a) | A complaint for turnover of a motor vehicle includes proof of insurance as an exhibit. | Not applicable to this sample (not a turnover complaint); not produced. |
| LBR 5005-4(c) | Electronic filings are PDF and PDF/A. | Not produced by `tools/render.sh` (Known gaps 5). |
| LBR 9010-1 | Notice of appearance, contemporaneously with the first filing. | Not produced (separate filing). |

Not produced by this template: the adversary cover sheet, the summons, the notice of appearance, and any exhibit (all separate filings).

## Layout

- Court title (three centered bold lines: UNITED STATES BANKRUPTCY COURT / FOR THE MIDDLE DISTRICT OF TENNESSEE / division), then the caption: the debtor and the parties on the left, a ")" column, and on the right the case number, chapter, judge and adversary number.
- Body double-spaced (24 pt baseline pitch at 12 pt); numbered allegations with a 0.5 inch first-line indent; block quotations single-spaced and indented 0.5 inch from both margins; headings centered and bold; a lettered prayer (A., B., ...); a signature block at the right half.
- Each block of text ends with one line of space, so the double-spacing pitch holds between paragraphs without a visible blank line (`below: body-leading`).
- Headings are sticky: a heading stays with the paragraph after it.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `chapter` (string), `case_number`, `judge`, `adv_proc_no` (blank before filing), `division`, `caption` (`debtor` names; `parties`: list of `{names, designation}`; "v." is inserted between parties), `title` (list of lines), `signature` (list of lines; the first is the `/s/` line).
- Body: blank-line-separated chunks. `#` (level 1, centered bold caps), `##` (level 2, centered bold), a numbered list (`1.` items, lettered A., B., ... by the template), a block quotation (`>`), or a paragraph.
- A paragraph is numbered by the template. A paragraph that is not numbered in the filed pleading starts with `§ ` (the marker is dropped): the lead-in, the statutory-predicate paragraph, the WHEREFORE paragraph, and a citation line after a quotation.
- Footnotes: `[^n]` in text, and `[^n]: text` as a separate chunk (supported; not used in this sample).
- Not supported: tables, raw typst.

## Overlay

`usage/OVERLAY-lemeh-no-name.pdf`: red is our render, blue is the filed exemplar, black is where they agree. `OVERLAY-lemeh-no-name.txt` maps each of our pages to its best-matching filed page by shared words: ours 1 to filed 1 (82.7%), ours 2 to filed 2 (70.7%), ours 3 to filed 3 (60.8%), ours 4 to filed 4 (51.1%). The overlay is a diagnostic, not a score. The differences are the font (Known gaps 1), the single caption row layout, and the bold headings.

## Known gaps and open choices

1. **Font.** The rules name no font family. The exemplar is Times New Roman. The only serif font vendored in `fonts/` is EB Garamond, the same choice as the CAND complaint template. EB Garamond at 12 pt has a smaller x-height than Times at 12 pt, so the text looks smaller than the exemplar. The 12-point minimum is met. Liberation Serif (the Times New Roman substitute, metric-compatible, `docs/FONTS.md`) is vendored, but the rules name no face, so the template keeps EB Garamond. Switching to Liberation Serif would be a tier-2 choice to match the exemplar, and is left open.
2. **One exemplar, one filer.** The brief asks for one exemplar per doc type, so tier 2 (2 or 3 filers) is not met. A second filer exists: *McLemore v. Capital One Auto Finance*, Adv. Proc. 3:24-ap-90091, Doc. 1 (6 pages, text-based, counsel Justin Campbell; https://storage.courtlistener.com/recap/gov.uscourts.tnmb.394442/gov.uscourts.tnmb.394442.1.0.pdf). It was checked for a text layer and not saved.
3. **Separate filings not produced.** The adversary cover sheet (LBR 7003-1), the summons, and the notice of appearance (LBR 9010-1) are not in this template. The exemplar's cover sheet is attachment 1 on the docket and is not in the exemplar PDF.
4. **Footer size.** The page number is in the body size (12 pt). The CM/ECF footer is added by the court at filing and is not drawn here; the template leaves room for it (`footer-descent: 0.6in`).
5. **PDF/A.** LBR 5005-4(c) requires PDF/A. `tools/render.sh` does not pass a PDF standard to typst, so the output is not PDF/A-conformant. This is a tool-level question (for David), not something this template can set.
6. **Caption rows.** The caption pairs one row per line, so each party name must fit one line in the 3.7 inch party column. A name that wraps throws the ")" column out of step. Both exemplar parties fit one line in this sample.
7. **Heading style.** The exemplar underlines its centered headings; the template uses bold. Tier-2 choice; not asserted.
8. **Alignment.** Body text is left-aligned (ragged right). The exemplar's justification could not be read from its text layer; not asserted.
9. **Scanned exemplar rejected.** *Williams v. Statebridge Company, LLC*, Adv. Proc. 3:23-ap-90104, Doc. 1 (8 pages): the PDF has no text layer beyond the PACER header, so it cannot be transcribed by `pdftotext`. Not saved.
10. **Depth.** The exemplar is 5 pages; the sample transcribes all of it and renders 4 pages. The brief's 8 to 14 page target applies only when the exemplar is that long.
11. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` (not this doc-type folder shape), and `tools/` is out of scope for this box. The renders and the overlay were run; the review below is the Gate 2 equivalent.

## Searches for the exemplar

- CourtListener REST search API (`/api/rest/v4/search/`, `type=r`, `court=tnmb`, query `"adversary proceeding" complaint`), filtered for complaints with a RECAP PDF. The web fetch tool is blocked by CourtListener (HTTP 403), so the API was called with `curl`.
- WebSearch: "Middle District of Tennessee bankruptcy adversary proceeding complaint pdf"; "courtlistener tnmb adversary complaint". No filing PDFs in the results.
- tnmb.uscourts.gov docket calendar (`/docket`): no case-specific entries.
- Candidates downloaded and checked for a text layer: *Lemeh v. No Name Group* Doc. 1 (used), *Williams v. Statebridge* Doc. 1 (scanned, rejected), *McLemore v. Capital One* Doc. 1 (text, not saved), *Lemeh v. Go Live Productions* Doc. 1 (4 pages, same filer as the used complaint, not saved).

## Review of the rendered pages (current PDF)

- Page 1: court title on three lines, caption with the debtor and both parties and the ")" column, case number, chapter, judge and adversary number on the right; "COMPLAINT"; the lead-in and paragraphs 1 to 5. Pass.
- Page 2: "The statutory predicate" paragraph (unnumbered), BACKGROUND heading, paragraphs 6 to 10, FIRST CLAIM FOR RELIEF heading with its sub-heading kept with paragraph 11. Pass.
- Page 3: paragraphs 12 to 17; the block quotation of the *RXAR* test, single-spaced and indented, with its citation line; no heading at the foot of a page. Pass.
- Page 4: paragraphs 18 and 19; WHEREFORE; prayer items A. to D. lettered; the signature block at the right half, with "/s/" and the counsel block. Pass.

## Engines

**docx** (`docx/build-reference.sh` makes `docx/reference.docx`; `docx/tnmb.lua` builds the cover, caption table, signature and numbering; `tools/render.sh --engine docx`, the PDF is the LibreOffice conversion).

- Matches the typst output: 4 pages in both; EB Garamond 12 pt throughout; 8 1/2 x 11 with one-inch margins; double spacing as an exact 24 pt line pitch; 0.5 in first-line indent; numbered allegations (number, tab, text); the caption as a borderless three-column table with the ")" column; the court title and the title lines bold and centered; headings bold and centered at the typst sizes (16.8 pt and 14.4 pt, as the typst render has them); the signature block at 3.25 in; the page number centered at the foot. Reviewed page by page at 60 dpi (4 of 4 pages, docx and typst): every line within about 3 pt of its typst position.
- Differs (tier 2 or renderer): a few lines break one word differently (for example WHEREFORE item A.); the lettered prayer items are typed as "A." with a tab, not Word list numbering; the first line of each page sits about 3 pt lower than in typst (exact line spacing).
- Not produced (as in typst): the adversary cover sheet, the summons, the notice of appearance, exhibits.
- BLOCKED: none for the render. `sh tools/check.sh <court-dir> --engine docx` cannot run in this folder: the court folder has no `checks.yaml` and no `rules.md`, so the gates have nothing to read (not changed here). The docx gates are therefore not run.
