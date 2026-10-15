# txed: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Texas (`txed`).
Folder: `courts/fifth-circuit/texas/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-pacsec3-lumen-2-25-cv-00668-complaint.pdf` (plaintiff's original complaint, Marshall Division, 8 pages, filed 2025-06-30). A second filer, `exemplars/FILED-EXAMPLE-wetro-hacom-2-15-cv-00416-complaint.pdf` (2015, 5 pages), is kept for conventions; see `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-pacsec3-complaint.md`: the whole filing transcribed (caption, 29 numbered paragraphs in 6 headings, prayer, signature block). |
| typeface | Rule names no face: E.D. Tex. CV-10(a)(5) (text read 2026-10-15 from the 2018 copy, the only one retrievable) requires double spacing and "a font no smaller than 12-point type". Vendored substitute: none needed; **EB Garamond kept** (`fonts/eb-garamond/`, the court-agnostic default in `docs/FONTS.md`). Metric compatibility: n/a. The exemplars' Times New Roman is a filer's choice, not a rule. |
| render | ok: `samples/OUTPUT-pacsec3-complaint.pdf`, 8 pages, typst 0.15.0 via `tools/render.sh`, vendored EB Garamond only, no typst warnings; re-rendered 2026-10-15, `pdffonts` shows EB Garamond Regular and Bold embedded. |
| overlay | **fail**: `tools/overlay.sh` exits 1 with "no exemplar pdf" because `exemplars/` holds only `SOURCE.md` in this snapshot (the `FILED-EXAMPLE-*.pdf` files are not tracked). No `OVERLAY-pacsec3-complaint.pdf` is produced. The `.txt` on disk is from an earlier run and was not rewritten. |
| pages reviewed | 8 of 8 of `OUTPUT-pacsec3-complaint.pdf` rasterized at 60 dpi and viewed on 2026-10-15 after the typeface check. |

The file names follow the tools' defaults (`OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf/.txt`), not the `<id>.pdf` / `<id>-overlay.pdf` names in the brief, because `tools/render.sh` and `tools/overlay.sh` write and read those names.

## Governing rules

Primary sources. Verified 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| E.D. Tex. Local Rule CV-10(a)(1) | Every document is endorsed with the style and number of the action. | `court`, `case_number`. |
| CV-10(a)(2) | A caption with the name and party designation of the filer, and a statement of the document's character (example: "Defendant John Doe's Motion to Dismiss under Rule 12(b)(6)"). | `caption` (designations), `brief_title`. |
| CV-10(a)(3) | Signed by the lead attorney, or with his or her permission. | `signature` block. |
| CV-10(a)(4) | Plainly written, typed or printed, double-spaced, on 8 1/2 by 11 inch white paper (the paper rule is for paper filings; the template follows it for the PDF). | `page-w`, `page-h`. |
| CV-10(a)(5) | Double spaced and in a font no smaller than 12-point type. | `body-leading` (1.47 em, a 27.6 pt baseline pitch at 13 pt); `type-size = 13pt`. |
| CV-10(c) | No "blue backs" or covers with paper filings. | Not produced. |
| CV-7(a) | Each pleading or motion is a separate document; the proposed order is a separate searchable PDF; no security settings that block copying. | Not produced by this template (the complaint is one document; the proposed order is a separate file). |
| CV-4(b) | Attorneys file the complaint electronically upon opening the case. | Not a template matter. |
| CV-4(c) | All party names in the caption typed with accurate capitalization and spacing. | `caption` is taken from the sample's frontmatter as given. |
| Fed. R. Civ. P. 10(a) | Caption: court name, title, file number, and the Rule 7(a) designation; the title of the complaint names all the parties. Fetched from https://www.law.cornell.edu/rules/frcp/rule_10 (text carries "As amended Apr. 30, 2007, eff. Dec. 1, 2007"). | `court`, `case_number`, `caption` (all parties named), `brief_title`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Every markdown list item at the top level is one numbered paragraph; the template numbers them continuously across the whole pleading (`counter("para")`). |
| Fed. R. Civ. P. 12(b)(6) and 12(a)(1)(A)(i) | Failure to state a claim may be raised by motion (relevant to the motion-brief doc type, not this one); the answer or motion is due 21 days after service. Fetched from https://www.law.cornell.edu/rules/frcp/rule_12 (text carries "Apr. 2, 2024, eff. Dec. 1, 2024"). | Not used by the complaint template. Cited for the motion-brief folder. |

**Version caveat.** The E.D. Tex. Local Rules copy used is the PDF at https://www.txed.uscourts.gov/sites/default/files/LocalRules.pdf, which is headed "LOCAL RULES AND APPENDICES as of [December 1, 2018]". It was the only copy the box could read (fetched 2026-10-14). Courtrules.net copies of CV-7 and CV-10 agree with it on the substance cited here (12-point, double-spaced, 30-page dispositive limit). A later revision may exist that this box could not retrieve; a reviewer should check the current court-posted text before relying on the rule numbers.

Not verified and not used: the judge-specific standing orders on page limits (one judge's standing order converts page limits to a word count; it is a single judge's rule, not the district's).

Not produced by this template (separate filings, not part of the complaint): civil cover sheet (JS 44, CV-4(a)); AO 120 or 121 for patent or copyright cases (CV-4(a)); summons (CV-4(a)); the Rule 7.1 disclosure statement; the certificate of interested persons if the court requires one.

## Layout

- Letter size, 1 inch margins on all sides, page numbers centered in the footer (11 pt).
- Court title, bold and centered, single spaced, lines 1 onward (no pleading-paper line numbers: the rules do not require them).
- Caption as a two-column grid: parties on the left, with "v." between the parties and each designation indented; case number and the jury demand on the right.
- Title of the paper, bold and centered, in capitals.
- Body double spaced: every block sits on one 27.6 pt grid, measured from the PDF (`pdftotext -bbox`): 27.56 pt between baselines on page 2 of the render, and 27.6 pt in the exemplar.
- Section headings are level-1 markdown headings: centered, bold, capitals, numbered `I.`, `II.`, ... by the template.
- Numbered paragraphs: a number at the half-inch indent, then the text. Paragraphs run on through the page; numbers are the template's, not the markdown's.
- Prayer items are a markdown bullet list, lettered `a.`, `b.`, ... by the template (a hanging indent).
- Signature block, single spaced, at the right half of the page, not split across pages (`breakable: false`).

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `court` (list of lines, each set in bold capitals and centered); `caption` (a list of `{names, designation}`; "v." is inserted between the parties); `case_number`; `jury_demand` (optional); `brief_title`; `signature` (`firm` lines, `signer`, `lines`, `role`); `footer_title` (accepted, not printed).
- Body: `#` headings for sections; markdown `1.` items are numbered paragraphs (the number written in the markdown is ignored); `-` items are lettered prayer items; other paragraphs are unnumbered (the opening paragraph, the WHEREFORE line).
- Non-breaking spaces after section signs (`§` + U+00A0) keep "§ 1" on one line; the sample has them.
- Not supported: tables (the caption is generated), footnotes, raw typst, nested lists.

## Decisions and deviations

1. **Type: 13 pt EB Garamond.** The rule sets a 12-point floor. EB Garamond's x-height is small, so 12 pt reads smaller than the exemplar's Times at 12 pt. 13 pt meets the floor and reads closer to the exemplar. This is a judgment, recorded as a choice.
2. **Pitch measured, not guessed.** `body-leading` was set from the measured exemplar pitch (27.6 pt). EB Garamond's line box is 0.65 em (measured), so the leading is 1.47 em.
3. **Caption.** The exemplar has no ")" column and no rules; the template follows that (ACCEPTED tier-2 choice; Wetro's 2015 caption is similar).
4. **Page count.** 8 pages, matching the exemplar's 8. (An earlier 6-page render came from 12-point EB Garamond's narrower lines; the 13 pt choice made the count match.)
5. **No measured coordinates.** Every size and spacing value is a rule value or a grid measured from the exemplar's line pitch; no coordinates were copied from the PDF.

## Known gaps

1. **Only one filer is fully checked.** The tier-2 comparison uses the PacSec3 filing; Wetro (2015) was used only for conventions (caption, numbering, prayer, signature). A second 2025-2026 filer was not found.
2. **Font.** EB Garamond is the only font vendored in `fonts/`. The exemplar is Times New Roman (Word default). The template cannot use Times; the look differs, though the size is set to match the apparent size.
3. **Local-rule version.** See the version caveat above. The rule numbers and quoted limits are from the December 2018 copy.
4. **Pleading format.** Not required by CV-10 and not used (the CAND template's pleading paper is not carried over).
5. **No proposed order.** CV-7(a) requires a separate proposed order; it is not part of this template.
6. **Overlay pairing is by words.** The overlay pairs each render page with the filed page sharing the most words; a page with a different break pairs with a neighbor. It is a diagnostic, not a score.

## Review record

- Pages 1-8 of `samples/OUTPUT-pacsec3-complaint.pdf` were rendered at 60 dpi and viewed after the last template change. Page 1: caption and title clean; no overlap after the block-height fix. Pages 2-6: body grid even, numbering 1-29 continuous, headings I-VI in order. Page 7: prayer items lettered a-f, WHEREFORE line clear of item (a). Page 8: signature block complete.
- Defects found and fixed during review: (a) court-title and caption lines overlapped (single-spaced lines had no leading; fixed with fixed-height single-spaced lines); (b) section headings took the surrounding size (now set explicitly to the body size); (c) the first numbered paragraph after each heading overlapped the heading (block gap moved above each block); (d) the WHEREFORE line overlapped prayer item (a) (same cause as c); (e) "§ 1" split across a line (NBSP in the sample).

## Engines

The docx engine is `docx/`: `reference.docx` (built by `docx/make-reference.sh` from pandoc's default, the same styles as the typst form) and `docx/txed-complaint.lua` (the cover, caption table, numbered paragraphs, prayer letters, signature block). Run: `sh tools/render.sh --engine docx <this folder> samples/INPUT-pacsec3-complaint.md`.

- **Matches the typst form:** EB Garamond 13 pt (the font must be installed on the machine that opens the file, or Word substitutes silently); double spacing at an exact 27.6 pt pitch; half-inch first-line indent; letter page, 1-inch margins; headings `I.`, `II.` ...; paragraphs numbered 1 to 29 continuously across the pleading; prayer lettered `a.` to `f.` with a hanging indent; signature block at the right half, kept together; 11 pt page number centered in the footer; caption as a borderless two-column table with the case number and jury demand at the foot of the right column.
- **Differs:** a table cell cannot be bottom-aligned, so the case number is placed at the foot of the caption by padding the right column with empty lines (correct while the party names do not wrap); footnotes and paragraph breaks are Word's, so line breaks and the page count are not the typst render's (8 pages); no PDF bookmarks.
- **Checked:** the markdown body is all in the `.docx`, in order, with footnotes present (character-order check run outside the gates); the `.docx` reads back in pandoc.
- **BLOCKED (docx.pdf):** Gates 0 to 3 on `samples/OUTPUT-pacsec3-complaint.docx.pdf` cannot run: LibreOffice (`soffice`) is not installable in this environment (not on conda-forge; no root for apt). The `.docx` is delivered; no page of it has been rendered or reviewed, and `samples/.check-docx.txt` is not written. Re-run `sh tools/render.sh --engine docx` and `sh tools/check.sh <folder> --engine docx` where LibreOffice is installed, then review every page (`## sample pacsec3-complaint docx` in `reviews/`).
