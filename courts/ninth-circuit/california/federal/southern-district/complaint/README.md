# casd: complaint

Doc type: **complaint** in the United States District Court for the Southern District of California (`casd`).
Folder: `courts/ninth-circuit/california/federal/southern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (a portion of the 35-page filing, see its header comment) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 9 pages, Times New Roman, no warnings (docx: `usage/OUTPUT-complaint.docx`, `.docx.pdf`, the same 9 pages) |
| overlay | ok: `usage/OVERLAY-bachman-complaint.pdf` and `OVERLAY-bachman-complaint.txt` |
| pages reviewed | 9 of 9 on typst and on docx (every page rendered at 50 dpi and viewed after the cross-engine port, fb-595.68.22) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| S.D. Cal. Civil L.R. 5.1 | Papers typed double-spaced on one side, line-numbered in the left margin, not more than 28 lines per page, letter size. | `lines-per-page = 27` (CivLR 5.1 allows 28), `pitch = 24pt`, `page-w = 8.5in`, `line-numbers()`. |
| S.D. Cal. Civil L.R. 5.1 | Proportional font such as Times New Roman at 14-point; no smaller type for text, footnotes or quotations. | `type-size = 14pt` for all body text, headings, caption and counsel. The footer is 10 pt (see gap 4). |
| S.D. Cal. Civil L.R. 5.1 (typeface) | No face is required. "Such as Times New Roman" is an example, not a requirement, so the court-named-face substitution does not apply. | Face required: none. Font: **Times New Roman** (the house standard and the exemplar's face; `font-family` in `casd-complaint.typ`, the docx face through `{font}`). |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `court-title`, `caption` (case number on the right, title below it). |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers each body paragraph; headings, lists and the PRAYER and DEMAND paragraphs are not numbered. |

Rule text: Fed. R. Civ. P. 10 fetched from https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14 (the amended text, eff. 2007-12-01; "Rule 10(a)" and "Rule 10(b)" quoted from it).

S.D. Cal. Civil L.R. 5.1: **not verified against the court's primary text.** The court's own site returned 404 to every fetch made on 2026-10-14 (`www.casd.uscourts.gov`, including `_assets/pdf/rules/Local%20Rules.pdf` and the Local Rules page the search engine listed). The text used here is the search-engine excerpt of CivLR 5.1 on courtrules.net (https://www.courtrules.net/courts/federal/southern-district-california/local-rules/27072; that page returned 403 to the fetch tool), which summarizes the rule as: double space on one side, line numbers in the left margin, no more than 28 lines per page, letter size, and a proportional font such as Times New Roman at 14-point. The exemplar uses 14-point Times New Roman (type height measured from the text layer; see the layout notes below). Before this doc type is marked done, check CivLR 5.1 against the court's current Local Rules PDF.

Not checked: CivLR 7.1 and CivLR 3 (the complaint's first-page requirements, if any beyond Rule 10). No CASD-specific caption or cover rule was confirmed, so the caption follows the exemplar and Rule 10(a). The civil cover sheet (JS-44), the Certification of Interested Entities or Persons, and the summons are separate filings and are not produced here.

## Layout

- Numbered lines 1 to 27 down the left margin (CivLR 5.1: not more than 28), a double rule at the text's left edge and a single rule at its right (the pleading form).
- Top margin 1 inch: line 1 sits on the top margin, so the 27 lines end at 10 inches and the footer is in the 1 inch bottom margin.
- Cross-engine layout model (`lib/typst/xengine.typ`): every body line a 24 pt box with the baseline at 0.8 of it, the line numbers on the same boxes; single lines (counsel, caption, signature) 16 pt boxes, each group starting 6.4 pt below a numbered line's top (`single-drop`), so every third single line stands level with a line number.
- Counsel block on lines 1 to 7; the template grows the block to the next numbered line for longer counsel lists (11 lines in the sample: the court title on line 9).
- Court title (UNITED STATES DISTRICT COURT, SOUTHERN DISTRICT OF CALIFORNIA) on the numbered lines after the counsel block, the caption a numbered line below it.
- Paragraphs are numbered 1, 2, ... by the template, the number in a half-inch box after the half-inch indent; a heading stays with the paragraph after it (sticky). Paragraphs under a heading starting with PRAYER or DEMAND are not numbered (the filed complaint leaves those unnumbered).
- Prayer items (markdown numbered list) are lettered (a), (b), ... as in the filing, half an inch in, the text hanging 0.4 in after the letter.
- The last body block stays with the signature block, which never splits.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1 centered caps; level 2 centered bold; level 3 bold italic left), a numbered list (`1.` items, lettered by the template), or a paragraph (numbered by the template).
- Frontmatter fields: `case_number`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `footer_title`, `counsel` (lines), `lead_in` (unnumbered lead-in paragraph, optional), `jury_demand` (puts "DEMAND FOR JURY TRIAL" in the caption), `legend` (optional, e.g. "Class Action"), `division` (optional), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Not supported: tables, footnotes, raw typst. The sample omits footnote text.
- The sample must not put the numbering in the text: the template numbers the allegations.

## Known gaps and open choices

1. **Only one exemplar.** Tier 2 asks for 2 or 3 filers. The CourtListener API search (`type=r`, `court=casd`, complaints filed 2026-09-08 to 2026-10-11) found other S.D. Cal. complaints (e.g. Novick v. Capricor Therapeutics, 3:26-cv-05568, Pomerantz LLP; Alo, LLC v. Derco, LLC, 3:26-cv-04957, Name Game IP, PC), not downloaded. Tier 2 is therefore **not** judged against two filers yet.
2. **Font.** CivLR 5.1 names Times New Roman as its example; the template sets it (the exemplar's face and the house standard; was EB Garamond until fb-595.68.22).
3. **Footer type size.** The footer is 10 pt (case number and title). The 14-point rule is written for text; footers are logged as an interpretation, the same as in the cand template.
4. **Caption.** The party column is closed by a rule (right and bottom), not the column of ")" marks in the exemplar. ACCEPTED as a tier-2 convention choice.
5. **Overlay names.** `tools/overlay.sh` reads `usage/OUTPUT-<id>.pdf` and writes `usage/OVERLAY-<id>.pdf` and `.txt`; the render is `OUTPUT-<id>.pdf` (the default of `tools/render.sh`). These are the names the tools use, so they are used here in place of `<id>.pdf` and `<id>-overlay.pdf`.
6. **Overlay pairing.** The sample is a portion of the 35-page filing (paragraphs 1 to 28, the prayer, the jury demand and the signature block; the CLRA venue declaration is not transcribed). The overlay pairs each sample page with the exemplar page sharing the most words; pages 6 to 8 pair with exemplar pages 10, 12 and 33 because the sample skips the filing's pages between. The overlay is a diagnostic, not a score.
7. **Paragraph numbers differ.** The sample numbers its allegations from 1; the filed numbers are not transcribed.
8. **Ragged right.** Body text is left-aligned, not justified. The exemplar's justification could not be read from the text layer; not asserted.
9. **Keep-with-next.** A heading is sticky: it moves to the next page with the paragraph after it, which may then break across pages.
10. **Checks.** `sh tools/check.sh <dir> --engine typst|docx` run green (typst 9, docx 13 checks, 0 failed).
11. **Headings.** A heading is one block at the 24 pt pitch; a long heading wraps onto the next numbered line.
12. **Signature block.** One signature block, after the jury demand. The filing repeats the signature under its own jury-demand page; the template does not produce that second signature.

## Review of the rendered pages (current PDF)

- Page 1 (typst and docx alike, 2026-10-22): counsel single-spaced from line 1 (11 lines), court title on lines 9 and 10, caption from line 12: the ruled party column, the case number, the title, CLASS ACTION and DEMAND FOR JURY TRIAL at the right; footer -1-, title and case number. Pass.
- Page 2: ¶¶1 to 5, INTRODUCTION centered bold. Pass.
- Page 3: ¶¶5 to 10. Pass.
- Page 4: ¶¶10 to 13, PARTIES, the Plaintiff and Defendant sub-headings (bold italic). Pass.
- Page 5: ¶¶14 to 18, JURISDICTION AND VENUE, FACTUAL ALLEGATIONS, sub-heading A. Pass.
- Page 6: ¶¶18 to 24. Pass.
- Page 7: ¶¶24 to 28, sub-heading B. Pass.
- Page 8: PRAYER FOR RELIEF, the unnumbered WHEREFORE paragraph, items (a) to (h). Pass.
- Page 9: DEMAND FOR JURY TRIAL, its unnumbered paragraph, a numbered line, the dated signature block. Pass.

Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).

## Engines

### docx

Built by `fb render` from `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`) and `docx/casd.lua` (fb-595.68.22; were `docx/make-reference.sh` and a committed `reference.docx` in EB Garamond). Both engines run on the shared layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): Times New Roman 14 pt, 24 pt exact line boxes on the 27 numbered lines, single lines of 16 pt (counsel, caption, signature) starting 6.4 pt below a numbered line's top, so every third single line stands level with a line number and the others 8 pt off it.

- The line numbers 1 to 27 are a page-anchored frame in the footer (a fixed grid on every page, as typst draws them; Word's `lnNumType` numbered only text lines), the footer carries `-N-`, the paper title and the case number (`$FORMBOOK_FOOTERS`); the page and the pleading rules (page borders: double left, single right) are the last section (`$FORMBOOK_FINAL`).
- The caption is a table: the party column ruled at its right and foot (the rules run to the foot of the row in both engines, as in the exemplar), the case column beside it. The signature block is a row that never splits; the last body block stays with it.
- Allegation numbers in a half-inch box after the half-inch indent (Word: a tab at 1 in); prayer items `(a)`, `(b)`, ... half an inch in, in a 0.4 in box.

`sh tools/check.sh <dir> --engine docx`: 13 passed, 0 failed; XENG-001..003 pass (280/280 lines, 9 pages), `params.cross_engine: gate` in `eval.yaml`.

Differs from typst: the pleading rules are page borders, so they run from the top to the bottom margin, not the full page height.

