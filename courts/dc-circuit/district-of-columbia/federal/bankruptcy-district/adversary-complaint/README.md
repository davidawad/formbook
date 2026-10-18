# dcb: adversary complaint

Doc type: **adversary complaint** (plaintiff's complaint commencing an adversary proceeding, Fed. R. Bankr. P. 7001 and 7003) in the United States Bankruptcy Court for the District of Columbia (`dcb`).
Folder: `courts/dc-circuit/district-of-columbia/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint-2.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md`: the whole 13-page complaint transcribed, plus the consent statement the rules require and the exemplar lacks (gap 3) |
| typeface | face required: none (LBR and FRBP checked, see gap 2). Font: EB Garamond (`docs/FONTS.md`: "no face named" row) |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only (`pdffonts`: EBGaramond Regular, Bold, Italic, all embedded), no warnings; re-rendered 2026-10-15 |
| overlay | ok: `usage/OVERLAY-square-funding.pdf` and `OVERLAY-square-funding.txt` (re-run 2026-10-15 against `usage/FILED-EXAMPLE-adversary-complaint-2.pdf`) |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi to PNG and viewed, 2026-10-15) |
| check gates | not run: `tools/check.sh` expects a court folder with `court.json` and `rules.md`; this is a doc-type folder, and `tools/` is out of scope for this box |

File names: the brief asks for `<id>.md`, `<id>.pdf` and `<id>-overlay.pdf`. `tools/render.sh` and `tools/overlay.sh` write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` by default, and `overlay.sh` reads `OUTPUT-<id>.pdf`, so the tools' names are used. The sample is `INPUT-<id>.md`, following the file-role names in `CLAUDE.md`.

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/dc-circuit/district-of-columbia/federal/bankruptcy-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/dc-circuit/district-of-columbia/federal/bankruptcy-district/adversary-complaint square-funding
```

## Governing rules

Verified 2026-10-14. Local rules: the court's Local Bankruptcy Rules as attached to General Order 2025-01 (signed March 3, 2025; revisions effective April 1, 2025), https://www.dcb.uscourts.gov/sites/dcb/files/2025-03-03%20GO%202025-01%20signed%20w%20LBR.pdf (text read from the PDF's text layer). Federal rules: Cornell LII pages for each rule.

| Rule | Requirement | Where the template does it |
|---|---|---|
| Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010) | Fed. R. Civ. P. 10 applies to an adversary complaint, except that the caption must substantially conform to Official Form 416. | `caption()`, `cover()` |
| Fed. R. Bankr. P. 9004(a) (https://www.law.cornell.edu/rules/frbp/rule_9004) | The document must be clearly legible. | letter paper, 12 pt type, one-inch margins (`dcb-adversary-complaint.typ`) |
| Fed. R. Bankr. P. 9004(b) | Caption sets out: the court's name; the case's title; the case number and, if appropriate, the adversary-proceeding number; a brief designation of the document. | `court-title()`, `caption()` (debtor case number, chapter, "Adv. Case No."), `title` |
| Fed. R. Bankr. P. 7008(a) (https://www.law.cornell.edu/rules/frbp/rule_7008) | The pleading must include a reference to the name, number and Code chapter of the case, and must state whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court. The core/non-core statement was removed in 2016 (committee note), so it is not required. | `final-orders()`: the statement is generated from `final_orders.consent` and names the debtor, the case number and the chapter from the caption |
| LBR 7012-1 | Each party includes in its initial substantive filing a statement whether it consents to entry of final orders and/or judgments by the bankruptcy judge. | `final-orders()` (same statement as FRBP 7008(a)) |
| LBR 5005-1(c) | On the first page, the represented party's attorney gives name, bar number, office address, email, telephone, and whom the attorney represents (footer or header permitted); a D.C. Bar number is required if the attorney is a D.C. Bar member. | `counsel-block()` (upper left; asserts email and "represents") |
| LBR 7003-1 | Cover sheet (Official Form) required only from a party not represented by an electronic filing user. | not produced (represented filer) |
| LBR 7004-2 | The Clerk issues the summons; if it is not delivered or mailed within 7 days of issuance, the party contacts the Clerk for a new one. | not produced (separate filing) |
| LBR 7007.1-1 | A corporate party files its ownership statement separately through CM/ECF with its initial pleading. | not produced (separate filing) |
| Fed. R. Civ. P. 10(b), as incorporated by FRBP 7010 | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers each body paragraph (not the lead-in or WHEREFORE paragraphs) |

Verified in this pass: FRBP 7010, 9004(a)-(b), 7008(a) (LII pages, quoted). LBR 5005-1(c), 7003-1, 7004-2, 7007.1-1, 7012-1 (the court's attached LBR PDF). Not verified in this pass: the text of Fed. R. Civ. P. 10(b) and Official Forms 416 and 104 (the cover sheet). The template does not depend on the Official Form wording.

Not produced by this template: the adversary cover sheet (Official Form 104), the summons, the corporate ownership statement, and any jury demand (the exemplar has none; the template has no jury-demand option).

## Layout

- Letter paper, one-inch margins on all sides, page number centred at the foot of each page.
- Counsel block single-spaced in the upper left (LBR 5005-1(c)); the court name in bold capitals; the caption as a three-column grid (party names, a column of ")" marks, the case numbers); the title of the paper in bold capitals centred.
- Body double-spaced: a 27.6 pt baseline pitch at 12 pt (measured on the exemplar with `pdftotext -bbox-layout`: body lines on its page 3 are 27.6 pt apart). Each paragraph is rounded to whole lines (`on-grid`), so consecutive paragraphs do not overprint.
- Headings: level 1 is a centred bold line; level 2 (the statute line under a count heading) is a centred line.
- Paragraphs after the first heading are numbered 1, 2, ... by the template; the lead-in and WHEREFORE paragraphs are not.
- The consent statement follows the last count, then the signature block: "Dated", "Respectfully submitted", "By: /s/", the signer's name, bar number, address, phone, facsimile (when given), email and role.
- The template contains no case-specific text. Every name, number, date and paragraph comes from the sample.

## Known gaps and open choices

1. **One exemplar only.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers; this doc type has 1. Searches: CourtListener API (`type=r&court=dcb`, query "complaint adversary", ordered by date; the HTML search page returns 403 to WebFetch, the API works). Of the results with PDFs, Akers (17-10012, entry 1, 2017) and Elliot (26-10013, entry 1, 2026) are scans with no body text and were not used. Webster v. CFG Merchant Solutions (25-10055) is the same filer, the same day, the same counsel, so it is not a second filer. Webster v. Jaycee Development (25-10052) is text-based but a different layout (Calibri), and was not saved. A second filer is needed for tier 2.
2. **Typeface and size.** Checked 2026-10-15 against the court's LBR PDF (text layer, searched for font, typeface, point and format terms): no rule names a typeface or a point size. The only format rule is LBR 5005-1(b), which covers pro se papers (letter size, 1-inch margins, "plainly and legibly" typed) and names no face. A court that names no face keeps EB Garamond (`docs/FONTS.md`), so the template stays on EB Garamond at 12 pt. The exemplar is Times New Roman 12 pt. EB Garamond sets visibly smaller at the same point size. Switching to Liberation Serif (metric-compatible with Times New Roman) would be a choice, not a rule requirement; it is left for David.
3. **Consent statement (assumed value).** The exemplar states no position on final orders, and the rules require one. The sample's `final_orders.consent: consents` is an assumption made to test the template, not a fact from the exemplar. The trustee's actual choice is unknown. The template prints the sentence for either value and refuses any other.
4. **Exemplar as filed.** The transcription keeps what the filer wrote: the blank adversary number ("Adv. Case No. ____________"), two typographical slips ("time he December 2022 Agreement"; the WHEREFORE paragraph of Count II ends without a period), . The "[Signature on Following Page]" line is a layout note and is not transcribed.
5. **Page count.** The render is 12 pages; the filed PDF is 13. Both are double-spaced at the same 27.6 pt pitch (measured on the render, page 4: 27.6 pt between body lines). The page difference is not analysed further; the text is complete (all 71 paragraphs are present, numbered 1 to 71 as filed).
6. **Italics.** The exemplar's case names and "Id." are probably italic, but the text layer carries no italic markup, so the sample is roman. The template italicises `*...*` markup where the sample uses it.
7. **Overlay.** The sample is the whole complaint, so the overlay map pairs most pages one-to-one (page 6 with filed page 8 and page 9 with filed page 10 show the pagination drift). The overlay is a diagnostic, not a score.

## Review of the rendered pages (re-rendered and viewed 2026-10-15, all 12 pages at 60 dpi)

| Page | Content | Finding |
|---|---|---|
| 1 | Counsel block (lines 1 to 8), court name, caption (debtor, plaintiff, defendant, case number, chapter, "Adv. Case No."), COMPLAINT, lead-in | Pass. The court name lines are one stack; no overprint. |
| 2 | Introduction, paragraphs 1 to 6; Parties starts at 7 | Pass. Paragraphs on the grid; no overprint. |
| 3 | Paragraphs 8 to 9 (Parties); Jurisdiction and Venue, 10 to 13 | Pass. |
| 4 | General Allegations, 14 to 19 | Pass. |
| 5 | 20 to 25; Count I heading and statute line; 26 | Pass. The heading stays with paragraph 26. |
| 6 | 27 to 36 | Pass. |
| 7 | WHEREFORE (Count I); Count II heading; 37 to 42 | Pass. |
| 8 | 43 to 48; WHEREFORE (Count II) | Pass. |
| 9 | Count III heading; 49 to 59 | Pass. |
| 10 | WHEREFORE (Count III); Count IV heading; 60 to 64 | Pass. |
| 11 | 65 to 66; WHEREFORE (Count IV); Count V heading; 67 to 71 | Pass. |
| 12 | WHEREFORE (Count V); Statement on Final Orders and Judgments; Dated, Respectfully submitted, signature block | Pass after the fix: the bar number now prints under the signer's name, as in the exemplar. |

Gate 2 rows for these pages are recorded here, not in `reviews/`: this doc type has no `reviews/` folder.

## Engines

Typst is the primary engine (`typst/`). The docx engine (`docx/`) is built here; there is no latex engine for this doc type.

| Engine | Folder | `usage/` output | Status |
|---|---|---|---|
| typst | `typst/` | `OUTPUT-adversary-complaint.typst.pdf` (rendered, not committed) | primary; not changed by the docx work |
| docx | `docx/` | `OUTPUT-adversary-complaint.docx` (committed); `.docx.pdf` is a LibreOffice render, kept out of the tree | built; 12 pages; see below |
| latex | none | none | not built |

**docx.** `docx/reference.docx` is generated by `docx/make-reference.sh` (pandoc's default reference, restyled: EB Garamond 12 pt; body double-spaced at 27.6 pt; single lines at 13.2 pt; 1-inch margins; a centred PAGE field in the footer). `docx/dcb-adversary-complaint.lua` writes the cover (counsel block, court title, the caption as a borderless table, the title), the final-orders statement and the signature block from the frontmatter, and numbers the allegations: paragraphs after the first heading, except WHEREFORE, use the Word custom style "Numbered Paragraph". Render: `sh tools/render.sh --engine docx <this folder> usage/INPUT-adversary-complaint.md <out>.docx.pdf` (the `.docx` is written beside the PDF path).

What matches the typst render (every page of the docx PDF rendered at 60 dpi and viewed beside the typst page, 2026-10-15):

- 12 pages, the same words in the same order (a word-list diff of the two PDFs differs only at line-break hyphens);
- EB Garamond 12 pt, embedded (`pdffonts`); letter paper, 1-inch margins;
- the caption columns (party names, the ")" column, the case numbers), the counsel block, the court title and the bold title;
- allegations numbered 1 to 71, with the lead-in and WHEREFORE paragraphs unnumbered; centred bold level-1 headings; bold level-2 statute lines; the final-orders statement; the signature block.

What differs:

- **Level-1 headings.** Typst renders them larger than 12 pt (the cmarker heading inside `heading-line()`). The docx uses 12 pt bold, the size the template's own comments describe. `typst/` is not changed here.
- **Baselines.** LibreOffice puts double-spaced baselines 2 to 3 pt lower than Typst does. The cover gaps are set from measured baselines (comments in `cover()`); the rest of the page follows the 27.6 pt grid.
- **Number to text.** Typst leaves a 0.3 in gap after the number; the docx uses a tab stop at 1.0 in, so the text of numbered paragraphs starts a few points differently.
- **Word.** Not run. The file was opened in LibreOffice 26.8.1 without a repair prompt. Word may paginate slightly differently (`docs/DOCX.md`).

Not run and BLOCKED: `tools/check.sh --engine docx` (Gates 0 to 3). It needs a court folder with `checks.yaml`, `reviews/` and `rules.md`; this doc-type folder has none, and the change does not create them. No check ID was run. Nothing is stamped (`usage/.check-docx.txt` is not written).

Toolchain used for the LibreOffice render: the official LibreOffice 26.8.1 Linux build (documentfoundation.org), with X11 and pango libraries from conda-forge, and the vendored `fonts/eb-garamond` installed in the user's font directory so that LibreOffice finds it.
