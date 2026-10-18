# C.D. Cal. Bankruptcy Court: adversary complaint

Doc type: **adversary complaint** (FRBP 7001: a proceeding to recover money or property, to determine dischargeability, to obtain an injunction, and so on). Court: United States Bankruptcy Court, Central District of California (cacb), any division. Folder: `courts/ninth-circuit/california/federal/bankruptcy-central-district/adversary-complaint/`.

Status: exemplar=yes, render=ok, overlay=ok, pages reviewed 11 of 11 (after the typeface change, below). Nothing here sets a court-level `court.json` status.

## Governing rules

Sources, read 2026-10-14:

- **Central Guide Supplement to LBR 9004-1, Form and Format of Documents to be Filed or Lodged** (August 2022): https://www.cacb.uscourts.gov/sites/cacb/files/documents/the-central-guide/TCGSupp9004-1_Form-and-Format-of-Documents-to-be-Filed.pdf. Fetched as a PDF and read with `pdftotext`. Sections cited below are its numbering.
- **Local Bankruptcy Rules, effective October 21, 2024**: https://www.cacb.uscourts.gov/sites/cacb/files/documents/local_rules/COMPLETE%20LBRS%2010-2024%20double-sided.pdf (201 pages). Sections cited below are its numbering. The court's site also lists a May 2025 edition; it was **not** fetched, so the LBR text here may be superseded. Check that edition before relying on it.
- FRBP 7001, 7008(a), 7010 are cited from memory of the Federal Rules of Bankruptcy Procedure. **Not fetched, not verified**; see gaps.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| CACB-FORM-001 | Central Guide 9004-1(b)(2)(A)(i) | Pages 8.5 x 11 inches. | page setup, `page-w`, `page-h` |
| CACB-FORM-002 | Central Guide 9004-1(b)(2)(B)(i) | Numbered margins required for a party-generated adversary complaint; at most 28 lines per page, numbered consecutively. | `line-numbers()`, `lines-per-page` = 28, `pitch` = 24 pt |
| CACB-FORM-003 | Central Guide 9004-1(b)(2)(C) | Typeface not smaller than 12 point; the listed typefaces are Arial, Courier, Times New Roman, Helvetica, Geneva, Letter Gothic. Line 1 at least 1 inch below the top edge. | `type-size` = 12 pt; `top-margin` = 72 pt. Typeface: Times New Roman is listed, so the template sets `font-family` = "Liberation Serif" (vendored, metric-compatible substitute, `docs/FONTS.md`). See gaps 1. |
| CACB-FORM-004 | Central Guide 9004-1(b)(2)(F) | Double-spaced, including citations. Footnotes may be single-spaced at 12 point or more. Quotations of 50 words or more may be single-spaced. | `body-leading` (24 pt pitch); `single-leading` for counsel, caption, signature |
| CACB-FORM-005 | Central Guide 9004-1(b)(2)(G) | Every page numbered consecutively at the bottom, including exhibits. | `footer-block()` |
| CACB-FORM-006 | Central Guide 9004-1(b)(2)(E) | One side of the paper only. | output is single-sided PDF |
| CACB-CAP-001 | Central Guide 9004-1(c)(1)(A) | Attorney name, state bar number, firm, address, telephone, fax and email, starting on line 1 at the left margin, single-spaced; then the party represented. | counsel block, `counsel` |
| CACB-CAP-002 | Central Guide 9004-1(c)(1)(B) | Space between lines 1 and 7 to the right of center left blank for the clerk. | counsel block fills lines 1-7 only; right side blank |
| CACB-CAP-003 | Central Guide 9004-1(c)(1)(C) | Court title, including the division, centered on or below line 8. | `court-title()`; the counsel block pushes it down when counsel needs more lines |
| CACB-CAP-004 | Central Guide 9004-1(c)(1)(D)-(G) | Party names left of center; bankruptcy case number to the right of center opposite the names; chapter number under it; adversary number under that. | `caption()`, `bankruptcy_case`, `chapter`, `adversary_number` |
| CACB-CAP-005 | Central Guide 9004-1(c)(1)(H)-(I) | Concise title of the document immediately below the adversary or chapter number or the caption. | `caption()` right column, `brief_title` |
| CACB-CAP-006 | Central Guide 9004-1(c)(1) (hearing) | Time, date and place of the hearing, or a statement that none is required or that one will be scheduled, immediately below the title. | `hearing` (lines), set to "[Status conference to be set by summons]" |
| CACB-CAP-007 | Central Guide 9004-1(c)(2) | Adversary complaint bears a double caption (debtor above, adversary parties below). | `caption()` left column: debtor block, parties |
| CACB-CAP-008 | Central Guide 9004-1(c)(3) | Small business / Subchapter V legend, when the case carries one. | `legend` (optional field) |
| CACB-CORE-001 | LBR 7008-1 | The FRBP 7008 and 7012(b) statements (core or non-core, and consent to final orders if non-core) must be plainly stated in the **first numbered paragraph**. | **Not enforced by the template**: it numbers paragraphs in order; the author must put the statement first. See gaps 4. |
| CACB-SUM-001 | LBR 7004-1(a)(1)(A) | The clerk issues the summons and notice of status conference, so the complaint does not generate one. | not generated |
| CACB-COVER-001 | LBR 7003-1 | Official Form 1040 (Adversary Proceeding Cover Sheet) must accompany a **non-electronically filed** complaint. | not generated: the PDF is the electronic form. See gaps 6. |

Not checked by this template (author's responsibility): the complaint must state a claim; the claim statements; the numbering of cross-references (the filing's "Paragraphs 1 through 71" are kept as written, see the sample).

## Exemplar

- `usage/SAMPLE-cacb-adversary-complaint-lpgmarshack826ap01078sc.pdf`: Complaint for avoidance and recovery of preferential, actual and constructive fraudulent, and unauthorized post-petition transfers, and disallowance of claims. 28 pages (26-page complaint, Exhibits 1 and 2). Filed June 30, 2026, Santa Ana Division, by the Chapter 11 trustee (Marshack Hays Wood LLP). Text layer present. Body text is Times New Roman (`TimesNewRomanPS-*`, embedded); exhibits use Arial and Calibri.
- Provenance and searches: `usage/SOURCE.md`.
- **Only one exemplar.** Tier 2 (the eval-loop rule) asks for two or three from different filers. Not done: see gaps 9.

## Sample

- `usage/INPUT-cacb-adversary-complaint-lpgmarshackadversary.md` is a transcription of the exemplar: the double caption and counsel block, the lead-in, the section headings in order (Statement of the Case, Jurisdiction and Venue, Parties, General Allegations A, C, E, F, G, First and Second Claims for Relief, Prayer), the prayer in full, and the signature block. Filing paragraphs 19-31 and 48-52 are not transcribed (the letters in the headings run A, C, E, F, G as filed).
- Paragraph numbers are not transcribed; the template numbers the allegations itself, so the numbers differ from the filing. The filing's cross-references ("Paragraphs 1 through 71") are kept as written and so do not match the template's numbers. This is a transcription artefact, not a template defect.
- Exhibits 1 and 2 (the transfer charts) are not transcribed.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env, see the brief)
sh tools/render.sh courts/ninth-circuit/california/federal/bankruptcy-central-district/adversary-complaint usage/INPUT-cacb-adversary-complaint-lpgmarshackadversary.md
sh tools/overlay.sh courts/ninth-circuit/california/federal/bankruptcy-central-district/adversary-complaint lpg-marshack-adversary
```

- `usage/OUTPUT-cacb-adversary-complaint-lpgmarshackadversary.typst.pdf`: 11 pages, letter (10 with EB Garamond; Times New Roman is wider, so the sample grew by a page). Typst compiled with no warnings (`render.sh` fails on any). Fonts: Liberation Serif only (vendored); `pdffonts` shows `LiberationSerif`, `-Italic`, `-Bold`, `-BoldItalic`, embedded.
- Line pitch measured with `pdftotext -bbox-layout` on page 4 (double-spaced body) and page 1 (single-spaced counsel): 24.00 pt and 12.00 pt. The leading is set per face (`body-leading` 1.345 em, `single-leading` 0.345 em), because Liberation Serif's line box is 0.655 em. Numbered lines run 1 to 28 down the margin.
- `usage/OVERLAY-lpg-marshack-adversary.pdf` and `.txt`: red = our render, blue = exemplar, black = both. Page map: ours 1-3 ↔ filed 1-3 (about 81-85% word overlap); ours 4-11 ↔ filed 5, 9, 11, 13, 13, 20, 21, 21 (27-64%). The map is coarse (word sets, not layout): the exemplar's body is at a different pagination and carries pleading-paper line numbers in the same grid, so the layers align on the cover and drift after it. The overlay is a diagnostic, not a score.
- Naming: the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (the brief's `<id>.pdf` / `<id>-overlay.pdf` names do not match `tools/`; the tools' names are used).

## Visual review (Gate 2 record, all 11 pages, rendered at 80 dpi and looked at, after the typeface change)

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: counsel (lines 1-7), court title (line 8-10), double caption, title, hearing | OK after two fixes. (a) At 13 pt the counsel block ran into the court title; fixed by 12 pt type with a 12 pt single pitch (two single lines per numbered line, as the exemplar does) and a gap rule. (b) The title overflowed to page 2 at 13 pt; fixed by the 12 pt single pitch. The whole cover now fits on page 1. |
| 2 | Statement of the Case, ¶¶ 1-3 | OK. |
| 3 | Jurisdiction and Venue, Parties (¶¶ 4-9) | OK. Heading kept with its paragraph. Italic case names. |
| 4 | Parties (¶¶ 10-12), General Allegations A and C (¶¶ 13-18) | OK. |
| 5 | C (¶¶ 19-20), E heading and ¶¶ 21-22 | OK. The *Id.* and *In re* italics render. |
| 6 | F (¶¶ 23-28), G (¶ 29-30) | OK. Heading "F." kept at the top of the page. |
| 7 | G (¶¶ 31-32), First Claim for Relief (¶¶ 33-39) | OK. Statute line in bold italic, one line, on grid. |
| 8 | Second Claim (¶¶ 40-45), Prayer lead-in (WHEREFORE, unnumbered), first group | OK. Statute line wraps, on grid. |
| 9 | Prayer items 1-8 (First to Fourth Claims) | OK. Group labels are headings, items are one numbered list 1-19 (numbering continues across groups). |
| 10 | Prayer items 9-13 (Fifth and Seventh Claims) | OK. The Fifth group's heading is kept with its first item. |
| 11 | Prayer items 14-19 (All Claims), signature block | OK after a fix. In Liberation Serif the signature block split: its last line went to a page of its own. Now the last prayer group and the signature block are one unbreakable block, so they move together. Signature: "By: /s/ Chad V. Haes" and the printed name in capitals, then the attorney lines. Dated at left. |

Pages 1-8 of the final render are pixel-identical to the pages reviewed before the signature fix.

Reviewed pages: 11 of 11.

Defects found and fixed during review (for the record): the first render had a 13 pt counsel block colliding with the court title and a caption title spilling to page 2 (fixed, above); a nested markdown list collapsed the second claim's prayer items into one bullet (fixed in the sample by flattening; the template's list numbering is now "1.", not "(a)", so a prayer is numbered as filed); the template numbered the WHEREFORE lead-in (now unnumbered, as filed); the printed signer name was not capitalized (now capitalized, as filed); the heading assertion failed on a two-line statute heading (headings now take as many numbered lines as they need); in the typeface pass (Liberation Serif), the signature block split across pages 10 and 11, leaving its last line alone on page 11 (fixed: the signature is unbreakable and joins the last prayer group, see page 11).

## Known gaps and open choices

1. **Typeface (CACB-FORM-003). Resolved in the fonts pass.** The Central Guide lists Arial, Courier, Times New Roman, Helvetica, Geneva and Letter Gothic as the required typefaces. The template uses Liberation Serif, the vendored metric-compatible substitute for Times New Roman (`docs/FONTS.md`), which is the face of the filed exemplar body (embedded `TimesNewRomanPS`). Type size is 12 pt, the floor; the exemplar is 12 pt. No LaTeX or DOCX engine exists for this doc type (`latex/` and `docx/` hold no template), so none needed the change. The sample is a transcription, so its page count is not a check of the filing's pagination; the overlay is the diagnostic.
2. **Numbered lines.** Drawn on every page (CACB-FORM-002). This differs from the N.D. Cal. template, where numbered lines are for manual filing only: under the Central Guide they are required for party-generated documents such as an adversary complaint, whether filed electronically or not.
3. **Single spacing.** Counsel, caption and signature are single-spaced at a 12 pt pitch, so two lines fit each numbered line (the exemplar does the same). Footnotes are not supported by this template (the exemplar's footnote 1 is omitted from the sample); a footnote would need single spacing at 12 pt or more.
4. **Core/non-core statement (CACB-CORE-001).** LBR 7008-1 requires the statement in the first numbered paragraph. **The filed exemplar does not do this**: its core statement is at paragraph 6 (Statement of Jurisdiction and Venue), and paragraph 1 is the statement of the case. The sample keeps it as filed. The template does not enforce the rule. A check on the first numbered paragraph would be needed for a true gate.
5. **Hearing line.** Set from the sample's `hearing` field. The Central Guide's sample reads "(Hearing date to be set by summons)"; the exemplar reads "[STATUS CONFERENCE TO BE SET BY COURT]". The sample uses the former wording with the status-conference line from LBR 7004-1.
6. **Official Form 1040 cover sheet (LBR 7003-1)** is not generated: it is required only for non-electronic filing. A paper filing would need it attached.
7. **Summons and notice of status conference** are issued by the clerk (LBR 7004-1(a)(1)(A)); not generated.
8. **FRBP 7010 and 7008 text not fetched.** The caption and pleading statements are cited from the rule's subject, not checked against its text. Treat those citations as unverified until read from the Rules.
9. **Tier 2 exemplars.** One exemplar. Tier 2 asks for two or three from different filers. Searches for more (CourtListener, Omni case pages, cacb opinions) found only trustee complaints in other cases as text, or docket listings without the complaint. Not done.
10. **Prayer lead-in and group labels.** The WHEREFORE line is unnumbered by a template rule (a chunk starting with "WHEREFORE"). Claim labels in the prayer are headings, not part of the numbered list, so a label that is not a heading (for example a bare line) would be numbered.
11. **Cross-references in the sample** ("Paragraphs 1 through 71") are the filing's own words and do not match the template's paragraph numbers; the author must check cross-references in a real pleading.
12. **Footer.** Page number centered, then the upper-case paper title and the adversary number, at 12 pt (the type floor applies to all typing, Central Guide 9004-1(b)(2)(C)).
13. **Divisions.** The title takes the division from the sample (`division`); the court title block is fixed as "UNITED STATES BANKRUPTCY COURT / CENTRAL DISTRICT OF CALIFORNIA". The Santa Ana, Los Angeles, Riverside and San Fernando Valley divisions are all valid values; the Central Guide's division codes are in its 9004-1(a).
14. **LBR edition.** Read from the October 21, 2024 edition. Check the May 2025 edition (see Governing rules).

## Engines

**docx** (`docx/`: `build-reference.sh` builds `reference.docx`; `cacb-adversary.lua` lays out the cover, caption, numbered allegations, prayer and signature). Built with `sh tools/render.sh --engine docx`; `usage/OUTPUT-cacb-adversary-complaint-lpgmarshackadversary.docx` and `.docx.pdf` are the output. Checked with LibreOffice only (Word is not available here).

- Matches the typst template: letter; left margin 1.5 in, right 0.75 in, top 1 in, bottom 47 pt (28 numbered lines of 24 pt take 672 pt); Liberation Serif 12 pt; 24 pt double and 12 pt single pitch; 28 pleading numbers; two vertical rules; counsel block on lines 1-7 and the court title on line 8; double caption; the cover on page 1 and the body from page 2; allegations numbered in the body; WHEREFORE unnumbered; prayer items numbered 1-19 across the claim groups; the last prayer group kept with the signature block; footer with the page number, the title and the adversary number.
- Differs or is limited: the 28 numbers are a text box in the header, not Word line numbering (line numbering would also number the single-spaced lines). Single-spaced tables (counsel, caption) are not rounded to the 24 pt grid, so an odd number of their lines shifts the grid by 12 pt below them. The bottom margin is 1 pt less than the typst template so that the caption rule fits. The footer title and adversary number are document properties (SUBJECT, COMMENTS) set from the sample's frontmatter; a file whose properties are edited in Word will show the edited values. The font name is Liberation Serif, as in the typst template; the rule text names Times New Roman, and Word substitutes a font where Liberation Serif is not installed (decision for David: rename the font in `build-reference.sh`).
- Not compared with typst page-for-page: no typst `OUTPUT` PDF exists for this sample and none was made. The typst README reports 11 pages for the same sample; this docx renders to 11 pages in LibreOffice.
- Pages rendered and viewed in LibreOffice at 60 dpi: 1-11 (all).
- **BLOCKED: `sh tools/check.sh <doc-dir> --engine docx` does not run.** It needs `checks.yaml` (the Gate 1 rule checks) and `reviews/` at court level, and neither exists for cacb; it exits 2 before any gate runs and writes no stamp. Gates 0-3 are not verified by the tool. Reason: court-level files, out of scope for this task.
