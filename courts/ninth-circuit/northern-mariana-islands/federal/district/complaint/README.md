# nmid: complaint

Doc type: **complaint** in the United States District Court for the Northern Mariana Islands (`nmid`).
Folder: `courts/ninth-circuit/northern-mariana-islands/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-nmid-complaint-ewing1600034.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-nmid-complaint-ewingfirstamended.md` (the whole filed complaint, 12 pages filed, 65 paragraphs) |
| typeface | LR 5.2.a requires "12-point type or larger and in a serif font" and names no face. Font: EB Garamond (vendored; no substitute needed). Not metric-compatible with any Times; not needed for LR 5.2.a. |
| render | ok: `usage/OUTPUT-nmid-complaint-ewingfirstamended.typst.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only (`pdffonts`: EBGaramond-Regular, EBGaramond-Bold), no warnings. Re-rendered 2026-10-15. |
| overlay | fail (not re-run): `tools/overlay.sh` needs `usage/SAMPLE-*.pdf`, which is not in this snapshot. `usage/OVERLAY-ewing-first-amended-complaint.txt` is from an earlier run; no `OVERLAY-*.pdf` exists here. |
| pages reviewed | 11 of 11 (re-rendered and every page viewed as PNG at 60 dpi on 2026-10-15) |

File names follow the file roles in `CLAUDE.md` (`INPUT-` the markdown, `OUTPUT-` our render, `OVERLAY-` the comparison) because `tools/render.sh` and `tools/overlay.sh` read and write those names by default. The brief's `<id>.md` / `<id>-overlay.pdf` names are the same files under those names.

## Build

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/ninth-circuit/northern-mariana-islands/federal/district/complaint usage/INPUT-nmid-complaint-ewingfirstamended.md
sh tools/overlay.sh courts/ninth-circuit/northern-mariana-islands/federal/district/complaint ewing-first-amended-complaint
```

## Governing rules

Primary source: **D.N.M.I. Local Rules, 2017 "Final Redline"**, the PDF posted at https://www.nmid.uscourts.gov/sites/nmid/files/LR2017-FinalRedline.pdf. Fetched 2026-10-14 (the box's own HTTP client is refused by the court site; the text was read through the WebFetch tool and extracted from the saved copy). The PDF is a redline: deleted and inserted words both appear in its text layer, so each rule below is quoted from the clean reading (the inserted words), and the redline's wording is checked where the two could differ. **Which version is currently adopted could not be confirmed** (see Known gaps).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 5.2.a | 8.5 x 11 inch white paper; double-spaced numbering running the length of the left margin; all text double-spaced except block quotations, footnotes and headings; 12-point type or larger in a serif font; one-sided, pages numbered consecutively. | `page-w`, `page-h`, `lines-per-page`, `pitch`, `type-size`, `font-family`, `line-numbers()`, `pleading-rules()`, footer |
| LR 5.2.a | Margins: not less than 1.5 in top, 1 in bottom, 0.5 in right, 1 in left. | `top-margin = 1.5in`, `bottom-margin` (derived), `left-margin = 1in`, `right-margin = 0.5in` |
| LR 5.2.a | Upper right-hand corner of page one: three inches left blank for the clerk. | Counsel block is limited to 3.6 in wide at the upper left; nothing is set in the top-right corner (checked on page 1). |
| LR 5.2.c | Counsel's name, bar identification number, mailing address, e-mail and telephone, and the party represented, upper left of page one. | `counsel` frontmatter lines (the template prints them as given; see Known gaps, bar number). |
| LR 5.2.d.1 | "IN THE UNITED STATES DISTRICT COURT / FOR THE NORTHERN MARIANA ISLANDS" on two lines, single-spaced, centered, at least 1.5 in from the top. | `court-title-lines`, `court-title()`; starts on line 8, about 3.8 in from the top. |
| LR 5.2.d.2 | Title of the proceeding below the court title, left of center; in a complaint it must name all parties. | `caption(meta)` left column, from `caption.parties`; "v." between the parties. |
| LR 5.2.d.3 | File number, designation of the proceeding (civil) and the title of the paper, right of the title of the proceeding. | Right column: "CIVIL CASE NO. ..." and `brief_title`. |
| LR 5.2.d.4 | Paper specifically identified. | `brief_title`. |
| LR 5.2.e | Hearing date and time on the first page of motions and oppositions. Not applicable to a complaint. | Not produced (complaint). |
| LR 5.2.f | Privacy redaction (Fed. R. Civ. P. 5.2; App. A.14). | Author's responsibility; the template does not redact. Sample contains no personal identifiers beyond counsel's contact details and the parties' names. |
| LR 5.2.g | Format nonconformity: the clerk may require a conforming document. | Not a template rule; the template follows LR 5.2.a-e. |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, file number and Rule 7(a) designation; the title of the complaint names all parties. Fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_10 (as amended 2007, eff. Dec. 1, 2007). | As above. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Every body paragraph is numbered by `allegations()`; headings and the prayer's lettered items are not. |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (LR 3.1, "Civil Cover Sheet"; the rule's text was not read in full), a Rule 7.1 disclosure statement, the summons. Any of these may be required with the first filing.

## Layout

- Numbered lines 1 to 25 down the left margin, a double rule at the text's left edge and a single rule at its right (pleading form). 25 lines is what 8.5 in holds at 24 pt pitch between a 1.5 in top margin and a 1 in bottom margin; the filed exemplar (2016) has 28 lines, which the 2017 margins do not allow.
- Counsel block single-spaced on lines 1 to 7; the court title follows on lines 8 and 9; the caption on lines 11 to 14; the body begins on the same page (no cover page: the filed exemplar also starts the body on page 1).
- Every block of text is a whole number of 24 pt rows (`on-grid`), so headings, paragraphs and signature blocks land on the numbered lines.
- Paragraphs are numbered 1, 2, ... by the template. A heading stays with the paragraph after it (`heading-line` plus the grouping in `allegations()`). An unnumbered lead-in (the prayer's "WHEREFORE") stays with the list after it.
- Prayer items (a), (b), (c) are lettered by the template; the filed exemplar numbers them 1, 2, 3.
- The signature block stays with the last unit of text (the prayer's last item): `allegations(..., tail: signature-block(meta))`. A signature never stands alone on a page.
- Footer: page number, the paper's title and the case number. This is a convention of the N.D. Cal. template reused here; the 2017 NMI rules do not specify a footer. The exemplar shows a page number at the foot and no title.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1: centered bold caps, e.g. `# INTRODUCTION`), a `##` heading (level 2: centered bold, one line; a cause of action's title and subtitle are two headings), a list (`1.` items, lettered (a) by the template), an unnumbered paragraph (`~ ` prefix; used for the prayer's "WHEREFORE"), or a numbered paragraph (anything else).
- Frontmatter fields: `case_number`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `footer_title`, `counsel` (lines, printed as given), `lead_in` (optional, unnumbered), `jury_demand` (true puts "DEMAND FOR JURY TRIAL" in the caption), `date` (printed after "Dated:"), `signature` (`firm` lines, `signer`, `lines`).
- The sample types no paragraph numbers: the template numbers them.
- Inline sub-items in a paragraph (the filed "(1) ... (2) ..." inside one paragraph) are typed inline, as the filing has them.
- Not supported: tables, footnotes (none needed), raw typst.

## Known gaps and open choices

1. **Which rules version applies.** The text is the 2017 Final Redline, read through WebFetch (the court site refuses the box's HTTP client). The redline mixes deletions and insertions; the quoted text is the inserted wording (for example LR 5.2.a and LR 7.1). The current adopted version (and any general order since 2017) was not confirmed. **Needs David's check of the court's posted local rules before this template is treated as complete.** The 2016 exemplar predates the 2017 rules and was not used to set any value.
2. **Bar identification number (LR 5.2.c).** The rule requires counsel's bar identification number. The exemplar (2016) prints none. The template prints the counsel block as given; a real filing needs the number in the frontmatter `counsel` lines. Not invented.
3. **Lines per page: 25, not 28.** Derived from the 2017 margins (1.5 in top, 1 in bottom); the filed exemplar has 28. The template follows the rule, not the exemplar.
4. **Font.** EB Garamond (SIL OFL, vendored in `fonts/eb-garamond/`) at 12 pt, the minimum size in LR 5.2.a. Checked 2026-10-15 against the 2017 Final Redline text: the only typeface rule is "All text must be in 12-point type or larger and in a serif font", and no face is named, so `docs/FONTS.md` keeps EB Garamond (no court-named substitute). EB Garamond has a smaller x-height than the Times New Roman used in the filed exemplar; that is the filer's choice (tier 3), not a rule, so it is not chased.
5. **Ragged right.** The body is left-aligned; the exemplar's justification is not asserted.
6. **Prayer lettering.** (a), (b), (c) in the template; the filed exemplar uses 1, 2, 3. The template's list convention is shared with the CAND complaint; not asserted against the exemplar.
7. **Tier 2 exemplars.** One filer only. EVAL-LOOP's tier-2 rule asks for two or three from different filers; the search (below) found candidates but did not save them.
8. **Check gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court directory with `court.json` and `rules.md`; this doc-type folder is not that shape and tools/ is off limits in this unit. Render and overlay ran; the review below is the Gate 2 record for this doc type.
9. **Search record.** CourtListener search API (`court=nmid`, `type=r`), complaints filed from 2014: Ewing (chosen); Murphy v. CNMI Government (1:14-cv-00026, amended complaint, 14 pp., not fetched); Kalarikkal v. World Corporation (1:19-cv-00002, RECAP storage link returned NoSuchKey); Garcia v. Poong-In Saipan (1:08-cv-00017, Doc 3, 2008, 7 pp., scanned with OCR text, counsel Woodruff: checked, not saved). The court site (nmid.uscourts.gov) and courtrules.net were not usable from the box.

## Visual review (Gate 2 record: all 11 pages, rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel (lines 1-7), court title (8-9), caption, title, paragraphs 1-4 | OK. Top-right corner clear. Caption and title right of center. |
| 2 | Paragraphs 5-12, FACTS heading | OK. Numbers on the grid. |
| 3 | Paragraphs 12-18 | OK. |
| 4 | Paragraphs 18-26 | OK. |
| 5 | Paragraphs 26-34, FIRST CAUSE OF ACTION heading with its two subtitle lines | OK. Heading kept with its paragraph. |
| 6 | Paragraphs 34-40, SECOND CAUSE heading | OK. Inline (1)-(3) in paragraph 34 wraps cleanly. |
| 7 | Paragraphs 41-46, THIRD CAUSE heading | OK. |
| 8 | Paragraphs 47-54, FOURTH CAUSE heading | OK. |
| 9 | Paragraphs 54-60 | OK. Blank lines 24-25: the FIFTH CAUSE heading and paragraph 61 move to page 10 together. |
| 10 | Paragraphs 61-65, FIFTH CAUSE (two subtitle lines), prayer heading moved to page 11 | OK after the fix. Blank lines at foot: the prayer block moves whole to page 11 (heading kept with its text). |
| 11 | PRAYER FOR RELIEF heading, WHEREFORE, items (a)-(c), date, signature block | OK after the fixes: signature block no longer splits from the firm name; the signer's name prints once under "/s/" (the earlier "By:" line duplicated it). |

Reviewed pages: 11 of 11.

## Engines

**docx** (`docx/`): `reference.docx` (built by `docx/build-reference.sh`), `docx/nmid-complaint.lua` (cover, numbered paragraphs, lettered prayer items, signature block) and `docx/render.sh` (puts the sample's footer title and case number into the footer; the reference keeps placeholders). Output: `usage/OUTPUT-nmid-complaint-ewingfirstamended.docx` and `.docx.pdf` (11 pages, same as typst).

- Matches typst: US Letter; margins 1.5 in top, 1 in bottom (25 lines of 24 pt), 1 in left, 0.5 in right; EB Garamond 12 pt; exact 24 pt double spacing; numbers 1 to 25 in a text box fixed in the left margin (not `w:lnNumType`, which would number the single-spaced cover lines and move with the text); pleading rules as page borders; counsel block, court title, caption table with its right and bottom rule; signature block kept with the last item; footer page number and title.
- Differs: the pleading rules are page borders, so they run the height of the text area, not the full page height (typst draws full height); widow control is off in the reference to match typst's line fill; a heading and its paragraph move together, so a page can end two lines short (page 1 and page 8 of the sample); the caption and signature tables are a fixed minimum height, so the text under them keeps the 24 pt grid only while their content fits.
- Fonts: LibreOffice needs the vendored `fonts/eb-garamond` visible (for example `FONTCONFIG_FILE` pointing at a conf that lists it); without it the PDF silently uses a fallback face.
- Visual review: 11 of 11 pages of `OUTPUT-nmid-complaint-ewingfirstamended.docx.pdf` rendered at 60 dpi and viewed (2026-10-15). Open defects: none. Compared with the typst render: page 1 side by side, the rest against the same form (line count per page, heading and signature placement).
- `tools/check.sh` cannot run on this folder (it reads `court.json` and `checks.yaml`, which exist at court level only, not in `complaint/`). No `.check-docx.txt` stamp is written.

BLOCKED: check.sh (all gates, docx): `tools/check.sh <doc-type dir> --engine docx` exits 2 on a doc-type folder (no `court.json` / `checks.yaml` / `rules.md` there); the docx was checked by the visual review above, not by the gates.
