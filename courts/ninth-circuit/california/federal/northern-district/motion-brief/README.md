# N.D. Cal. (cand): motion brief

Doc type: **motion** (notice of motion with memorandum of points and authorities, one filed document). Court: United States District Court for the Northern District of California. Folder: `courts/ninth-circuit/california/federal/northern-district/motion-brief/`.

Status: exemplar=listed in `usage/SOURCE.md` but the PDF is **not in this snapshot**; render=ok (Liberation Serif, 10 pages); overlay=fail (no exemplar PDF, `tools/overlay.sh` exits 1); pages reviewed 10 of 10 after the font change. Not a court-level `court.json` status; nothing here sets `status`.

Typeface: Civil L.R. 3-4(c)(2)(A)-(B) names Times New Roman and Century Schoolbook as examples of a standard proportional font. The template uses **Liberation Serif** (vendored Times New Roman substitute, metric-compatible, `docs/FONTS.md`) at 12 pt, replacing EB Garamond at 13 pt. The filed exemplar is Times.

## Governing rules

Source: N.D. Cal. Civil Local Rules, full text (PDF, "Effective October 2, 2026"), https://cand.uscourts.gov/media-library/uploads/local-rule/civil-local-rules (also listed at https://cand.uscourts.gov/rules-forms-fees/local-rules/civil-local-rules). Fetched and read 2026-10-14. The rule text below is quoted or closely paraphrased from that PDF.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| CAND-FORM-001 | Civil L.R. 3-4(c)(1) | 8½ × 11 inch white paper. Numbered lines apply to **manual** filing only (see gaps). | `typst/cand-motion-brief.typ` (paper) |
| CAND-FORM-002 | Civil L.R. 3-4(c)(2)(A)-(B) | Standard proportionally spaced font (e.g. Times New Roman or Century Schoolbook), 12 point or larger, footnotes and quotations included, unless a judge's standing order says otherwise. | `type-size` = 12 pt, `font-family` = "Liberation Serif" (Times New Roman substitute) |
| CAND-FORM-003 | Civil L.R. 3-4(c)(2) | Text on one side, double-spaced, no more than 28 lines per page, except counsel identification, title of the case, footnotes and quotations. | `line-pitch` = 24 pt, `body-leading` |
| CAND-FORM-004 | Civil L.R. 3-4(c)(2)(C) | "Spaced no more than 10 characters per horizontal inch." See open question 1. | not enforced |
| CAND-FORM-005 | Civil L.R. 3-4(c)(3) | Footer on each page with the paper's title, and once a case number is assigned, the case number. | `running-footer` |
| CAND-FIRST-001 | Civil L.R. 3-4(a)(1) | Counsel's name, address, telephone, email and state bar number, upper left, with the party represented and its status. | cover, `counsel` + `counsel_role` |
| CAND-FIRST-002 | Civil L.R. 3-4(a)(3) | Starting on the eighth line (unless counsel identification needs more space): court title, title of the action, case number with the judge's initials, and the title of the paper. | cover (court title, caption, `case_number`) |
| CAND-FIRST-003 | Civil L.R. 7-2(b)(1), 7-4(a)(1) | The noticed hearing date and time on the first page, in the space opposite the caption and below the case number. | caption right column, `hearing` |
| CAND-CONT-001 | Civil L.R. 7-2(b)(2)-(4), 7-4(a)(3)-(5) | Notice of motion in the first paragraph; a concise statement of relief in the second; then the points and authorities: statement of issues, succinct statement of facts, argument citing authorities. | body (author-written, see `usage/`) |
| CAND-CONT-002 | Civil L.R. 7-2(b), 7-4(b) | Motion in one filed document not exceeding 25 pages (text limit for the points and authorities). Not checked by the template: no page counter exists yet. | not enforced |
| CAND-CONT-003 | Civil L.R. 7-4(a)(2) | Table of contents and table of authorities when the brief is more than 10 pages. The template always produces both (generated from headings and `toa:` links). | `toc-section`, `toa-section` |
| CAND-CONT-004 | Civil L.R. 3-4(d) | Citation to authorities: parallel U.S.C. citation for Acts of Congress, C.F.R. title/section and date for regulations, U.S./S. Ct./L. Ed. for Supreme Court cases, F./F. Supp./F.R.D. for other federal courts, official or regional reporter for state courts. Not checked by the template; authorities are written by the author. | not enforced |

Not used, and why: Civil L.R. 7-2(c) (proposed order) and 7-5 (declarations) are separate filings. No certificate of compliance or certificate of service is generated: the N.D. Cal. text above does not call for one, and the exemplar has neither (it is an ECF filing). The "signature block" is a convention, not a rule citation.

## Exemplar

- `usage/SAMPLE-cand-motion-brief-tsiakimmaidu16cv7189.pdf`: Notice of Motion and Motion to Dismiss or Transfer, with Memorandum of Points and Authorities. 17 pages. Filed by the Federal Defendants (U.S. Attorney's Office, N.D. Cal.), April 20, 2017. Text layer present (`pdffonts` shows embedded Times, `pdftotext` reads it).
- Provenance, searches and the caveat about the ECF header are in `usage/SOURCE.md`.
- Only one exemplar. The eval-loop tier 2 rule asks for two or three from different filers; not done (see gaps).

## Sample

- `usage/INPUT-cand-motion-brief-tsiakimmaidumotiontodismiss.md` is a transcription of the exemplar: caption and counsel block, notice of motion, relief sought, issues, the memorandum's introduction, facts, Argument III.A (venue) and III.B.1 (legal standard), the conclusion, and the signature block. Footnotes 1 and 2 are included.
- It stops after III.B.1. Argument III.B.2-4 (sovereign immunity, agency failure to act, statute of limitations) are not transcribed, to keep the render within the 8-14 page target. The exemplar's pages 9-12 of the memorandum are therefore absent; the overlay shows this.
- Frontmatter follows the ca9 contract in shape (`authorities:` registry, `toa:KEY` links, footnotes, `#` headings) with the N.D. Cal. fields (`court`, `counsel`, `caption`, `hearing`, `footer_title`). Headings are numbered by the template (I., A., 1., a.); the sample types no numbers.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/ninth-circuit/california/federal/northern-district/motion-brief usage/INPUT-cand-motion-brief-tsiakimmaidumotiontodismiss.md
sh tools/overlay.sh courts/ninth-circuit/california/federal/northern-district/motion-brief tsi-akim-maidu-motion-to-dismiss
```

- `usage/OUTPUT-cand-motion-brief-tsiakimmaidumotiontodismiss.typst.pdf`: 10 pages (was 12 in EB Garamond at 13 pt). Typst compiled with no warnings (`render.sh` fails on any warning). Only vendored fonts: `pdffonts` shows LiberationSerif, -Italic, -Bold, embedded. Body line pitch measured at 24.0 pt with `pdftotext -bbox-layout` (`body-leading` retuned from 0.54em to 1.09em for the new face).
- Overlay: **not generated**. `usage/` has no PDF in this snapshot, so `tools/overlay.sh` exits 1. `usage/OVERLAY-tsi-akim-maidu-motion-to-dismiss.txt` is the stale page map from the EB Garamond render and does not match the current render; it should be regenerated once the exemplar PDF is restored.

## Visual review (all 10 pages of the Liberation Serif render, rendered at 70 dpi and looked at)

| PDF page | Printed page | What it is | Finding |
|---|---|---|---|
| 1 | cover | Counsel block, court title, caption, title, hearing | OK. Font change only; no layout change on this page. |
| 2 | i | TOC | OK. Page numbers in their own column. |
| 3 | ii | TOA, cases and statutes | OK. Dot leaders; page numbers right-aligned. |
| 4 | 1 | Notice of motion, relief sought; footnote 1 at foot | OK. Double-spaced at 24 pt pitch. |
| 5 | 2 | Issues to be decided, memorandum, introduction | OPEN (not changed in this font pass): the three numbered issues are set single-spaced (about 17 pt pitch), not double-spaced like the rest. Civil L.R. 3-4(c)(2) exempts only quotations and footnotes. |
| 6 | 3 | Introduction end, factual background | OK. Paragraphs run on without a blank line between them (first-line indent only), as in the exemplar. |
| 7 | 4 | Argument III, III.A, legal standard, sub-heading 2 | OK. Hanging sub-heading labels correct. |
| 8 | 5 | III.A.2-3, footnote 2 (caed.uscourts.gov) | OK. Footnote at foot of page. |
| 9 | 6 | III.A.3, III.B and B.1, legal standard | OK. |
| 10 | 7 | Conclusion and signature | OK. "Dated" left, "Respectfully submitted" right, "/s/" line. |

Reviewed pages: 10 of 10.

## Known gaps and open choices

1. **Characters per inch (CAND-FORM-004).** Civil L.R. 3-4(c)(2)(C) says "spaced no more than 10 characters per horizontal inch." For a proportional font, 12-point Times New Roman runs at roughly 14-15 characters per inch (my estimate, not measured), so read literally the rule cannot be met by a proportional font at 12 pt. My reading: the cap is for fixed-pitch fonts (Courier at 12 pt is 10 cpi). Not enforced. **Needs David's call** (or the court's answer) before this template is treated as complete.
2. **Numbered lines (CAND-FORM-001).** Civil L.R. 3-4(c)(1) requires numbered lines on paper for manual filing. The exemplar (an ECF filing) carries pleading-paper line numbers; this render does not. Not drawn: the template targets the electronic PDF. A pleading-paper variant would need a 28-line grid and a line-number margin.
3. **Font.** Liberation Serif (vendored, OFL) at 12 pt, the Times New Roman substitute named in `docs/FONTS.md`. The rule's examples are "e.g.," so EB Garamond (the previous face, at 13 pt) would also have met the rule's wording; the filed exemplar is Times, so the substitute was chosen. Reading choice: revert `font-family` and `type-size` in `typst/cand-motion-brief.typ` if David prefers EB Garamond.
4. **Lines per page.** 24 pt pitch, 1 inch top and bottom margins: 27 double-spaced lines fit per body page. Checked with `pdftotext -bbox-layout`: pitch 24.0 pt on every body page. Footnotes and quotations are exempt from double spacing under 3-4(c)(2). Headings are single-spaced too, but the rule does not exempt headings: that is a convention choice, flagged here.
4a. **Court title position (CAND-FIRST-002).** The rule starts the court title on line 8 "except where additional space is required for counsel identification." Here the counsel block runs past seven lines, so the court title follows it with one line of space rather than sitting on line 8 exactly.
5. **Footer size.** 11 pt. The rule's type-size floor applies to text, footnotes and quotations; the footer is the paper identification.
6. **Judge standing orders** can change the form (3-4(c)(2) says "unless a Judge's standing order ... requires otherwise"). Not reflected.
7. **Page limit (CAND-CONT-002).** The template does not count pages. The sample renders to 10 pages; the 25-page limit is for the author.
8. **Tier 2 exemplars.** One exemplar only. The eval loop asks for two or three from different filers before tier 2 is judged. Not done. Searches tried are in `usage/SOURCE.md`.
9. **Partial sample.** Argument III.B.2-4 not transcribed (see Sample).
10. **Certificates.** None generated (see Governing rules).
11. **Heading numbering.** Numbering is done by the template from heading level (I., A., 1., a.), not typed by the author; the TOC and TOA follow the same numbers.
12. **Argument headings** and sub-headings are sentence case as in the exemplar; the template does not re-case them.

## Engines

Docx engine: `docx/make-reference.sh` (builds `docx/reference.docx` from pandoc's default), `docx/cand.lua` (cover, caption, case number, title, signature block; the body is pandoc's). Sample build: `usage/OUTPUT-cand-motion-brief-tsiakimmaidumotiontodismiss.docx` (valid zip, every XML part well-formed). Not rendered: no LibreOffice on the build box, so **pages reviewed = 0**. `make-reference.sh` needs `unzip` and `zip`, which the build box lacks; it was run with a stand-in built on libzip's `ziptool` (outside the repo).

What the docx sets (in `styles.xml`, `document.xml` and the footer part; not rendered):
- Liberation Serif 12 pt in the document defaults, black text; footnotes 12 pt, single spaced.
- Exact 24 pt line pitch for body, headings and list items, no space before or after; body first-line indent 0.5 in; headings 1 and 2 centred bold, heading 3 bold italic.
- US Letter with 1 in margins on all four sides; no line numbers (the typst template draws none).
- Footer: centred PAGE field, 11 pt.

What differs from the typst template:
- Table of contents and table of authorities are not generated. The typst template builds them from the headings and the `toa:` links and `authorities` registry; pandoc writes neither, so the docx has no TOC or TOA pages.
- The caption is paragraphs, not a bordered box.
- The footer has the page number only (see BLOCKED).
- Pagination follows Word, not typst; no line-count check is made.

BLOCKED:
- docx.pdf gates 0 to 3 (`tools/check.sh --engine docx`): BLOCKED, no `soffice` on the build box (reason: LibreOffice not installed). No `.docx.pdf` was written.
- Table of contents (`TOC`) and table of authorities (`TOA`) pages: not produced; the docx cannot pass the TOC/TOA checks. A TOC/TOA generator in the filter would be a new piece of work.
- Cover hearing block (date, time, place, judge, from `hearing:`): not produced.
- Footer title and case number on each page: not produced (case text; needs a per-case step).
- Caption rules (typst's box): not reproduced.
