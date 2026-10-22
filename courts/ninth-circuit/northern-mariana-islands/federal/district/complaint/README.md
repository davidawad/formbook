# nmid: complaint

Doc type: **complaint** in the United States District Court for the Northern Mariana Islands (`nmid`).
Folder: `courts/ninth-circuit/northern-mariana-islands/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (the whole filed complaint, 12 pages filed, 65 paragraphs) |
| typeface | LR 5.2.a requires "12-point type or larger and in a serif font" and names no face. Font: Times New Roman 12 pt (vendored, docs/FONTS.md; the filed exemplar's face too), the same on typst and docx (`{font}` in `docx/reference.xml`). |
| render | ok: `usage/OUTPUT-complaint.typst.pdf` and `usage/OUTPUT-complaint.docx` / `.docx.pdf`, 11 pages each, vendored Times New Roman only, no warnings. Re-rendered 2026-10-22 (fb-595.68.23). |
| overlay | diagnostic only: `just overlay <dir>` writes `.overlay/<doc path>/OVERLAY-complaint.pdf` (not committed). |
| pages reviewed | 11 of 11 on typst and 11 of 11 on docx (every page viewed as PNG at 60 dpi on 2026-10-22, side by side) |

File names follow the file roles in `CLAUDE.md` (`INPUT-` the markdown, `OUTPUT-` our render, `OVERLAY-` the comparison) because `tools/render.sh` and `tools/overlay.sh` read and write those names by default. The brief's `<id>.md` / `<id>-overlay.pdf` names are the same files under those names.

## Build

```sh
sh tools/render.sh courts/ninth-circuit/northern-mariana-islands/federal/district/complaint usage/INPUT-complaint.md
sh tools/render.sh --engine docx courts/ninth-circuit/northern-mariana-islands/federal/district/complaint usage/INPUT-complaint.md
sh tools/check.sh courts/ninth-circuit/northern-mariana-islands/federal/district/complaint
sh tools/check.sh courts/ninth-circuit/northern-mariana-islands/federal/district/complaint --engine docx
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
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Every body paragraph is numbered by `render-body()` (docx: the filter); headings and the prayer's lettered items are not. |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (LR 3.1, "Civil Cover Sheet"; the rule's text was not read in full), a Rule 7.1 disclosure statement, the summons. Any of these may be required with the first filing.

## Layout

- Numbered lines 1 to 25 down the left margin, a double rule at the text's left edge and a single rule at its right (pleading form). 25 lines is what 8.5 in holds at 24 pt pitch between a 1.5 in top margin and a 1 in bottom margin; the filed exemplar (2016) has 28 lines, which the 2017 margins do not allow.
- The cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line a box of its pitch with the baseline at 0.8 of it, first-fit ragged-right breaking, no kerning, ligatures or hyphenation. Double-spaced text on the 24 pt pitch of the numbered lines; single-spaced blocks (counsel, court title, caption, signature) on a 12 pt pitch, starting 9.6 pt into a numbered line, so every second single line stands on a numbered line's baseline.
- Counsel block single-spaced on lines 1 to 7 (at least seven numbered lines); the court title's two single lines on line 8; the caption from line 10, at least its party lines plus one, rounded up to whole numbered lines; a blank numbered line; the body on the same page (no cover page: the filed exemplar also starts the body on page 1).
- Headings, paragraphs and list items are whole numbered lines, so the text stays on the numbered lines (unless a caption name wraps more than one line).
- Paragraphs are numbered 1, 2, ... by the template, the number in a 0.5 in box after the 0.5 in indent (the text 1 in from the margin). A heading stays with the text after it (typst sticky, Word keep with next). An unnumbered lead-in (the prayer's "WHEREFORE") stays with the list after it.
- Prayer items (a), (b), (c) are lettered by the template (the label in a 0.5 in box after the indent, the text hanging at 1 in); the filed exemplar numbers them 1, 2, 3.
- The signature block, one blank numbered line below the text, stays with the last unit of text (the prayer's items): one unbreakable block in typst, keep-with-next paragraphs and a row that never splits in Word. A signature never stands alone on a page.
- Footer (10 pt, 48 pt below the last numbered line): page number, the paper's title in capitals and the case number. This is a convention of the N.D. Cal. template reused here; the 2017 NMI rules do not specify a footer. The exemplar shows a page number at the foot and no title.

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
4. **Font.** Times New Roman 12 pt, the house standard (docs/FONTS.md) and the filed exemplar's face. LR 5.2.a asks only "12-point type or larger and in a serif font"; no face is named.
5. **Ragged right.** The body is left-aligned; the exemplar's justification is not asserted.
6. **Prayer lettering.** (a), (b), (c) in the template; the filed exemplar uses 1, 2, 3. The template's list convention is shared with the CAND complaint; not asserted against the exemplar.
7. **Tier 2 exemplars.** One filer only. EVAL-LOOP's tier-2 rule asks for two or three from different filers; the search (below) found candidates but did not save them.
8. **Check gates.** `tools/check.sh` runs on this folder (typst and docx); the court-level `rules.md` supplies the rows. Gate 4 (cross-engine) is `gate` in `eval.yaml`.
9. **Search record.** CourtListener search API (`court=nmid`, `type=r`), complaints filed from 2014: Ewing (chosen); Murphy v. CNMI Government (1:14-cv-00026, amended complaint, 14 pp., not fetched); Kalarikkal v. World Corporation (1:19-cv-00002, RECAP storage link returned NoSuchKey); Garcia v. Poong-In Saipan (1:08-cv-00017, Doc 3, 2008, 7 pp., scanned with OCR text, counsel Woodruff: checked, not saved). The court site (nmid.uscourts.gov) and courtrules.net were not usable from the box.

## Visual review (Gate 2 record: all 11 pages of both engines, rendered at 60 dpi and viewed side by side, 2026-10-22)

| Page | What it is | Finding (typst and docx alike) |
|---|---|---|
| 1 | Counsel (lines 1-5), court title (line 8), caption (lines 10-13), INTRODUCTION, JURISDICTION, VENUE, paragraphs 1-3 | OK. Top-right corner clear. Caption and title right of center, the party column ruled right and below. Lines 24-25 blank: the PARTIES heading moves on with its paragraph. |
| 2 | PARTIES, paragraphs 4-10, FACTS | OK. Numbers on the text's baselines. |
| 3 | Paragraphs 11-17 | OK. |
| 4 | Paragraphs 17-24 | OK. Line 25 blank: paragraph 25 does not split 1+3 (widow and orphan control). |
| 5 | Paragraphs 25-31 | OK. Lines 24-25 blank: the FIRST CAUSE heading block moves on with its paragraph. |
| 6 | FIRST CAUSE OF ACTION (three heading lines), paragraphs 32-37 | OK. Inline (1)-(3) in paragraph 34 wraps cleanly. |
| 7 | Paragraphs 37-42, SECOND CAUSE heading | OK. |
| 8 | Paragraphs 43-48, THIRD CAUSE heading | OK. |
| 9 | Paragraphs 49-55, FOURTH CAUSE heading | OK. |
| 10 | Paragraphs 56-62, FIFTH CAUSE heading | OK. |
| 11 | Paragraphs 63-65, PRAYER FOR RELIEF, WHEREFORE, items (a)-(c), date and signature block | OK. The signature block on the same page as the last item. |

Reviewed pages: 11 of 11 (typst), 11 of 11 (docx). Open tier-2 findings: none.

## Engines

**docx** (`docx/`): `docx/reference.xml` (the cross-engine style recipe, `base="xengine"`, in the typst face through `{font}`; fb render builds the reference document from it) and `docx/nmid-complaint.lua` (cover, numbered paragraphs, lettered prayer items, signature block; the last section and the footer through `FORMBOOK_FINAL` and `FORMBOOK_FOOTERS`: the numbered lines 1 to 25 in a frame fixed to the page, the pleading rules as page-height lines, the page number, the paper's title and the case number from the frontmatter). No shell script, no committed `reference.docx` (fb-595.68.23; were `build-reference.sh`, `render.sh`, `pagemap.awk` and an EB Garamond `reference.docx`). Output: `usage/OUTPUT-complaint.docx` and `.docx.pdf`.

- Cross-engine gate: XENG-001..003 pass (11 pages, 306/306 lines break after the same word as typst; every baseline within 0.01 pt), `params.cross_engine: gate`.
- The caption's bottom rule: LibreOffice sets it below the row (typst strokes take no room), so the row's minimum height is 0.75 pt less in the docx.
- Word may paginate slightly differently from the LibreOffice PDF (docs/DOCX.md).
