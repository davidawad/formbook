# N.D. Cal. (cand): motion brief

Doc type: **motion** (notice of motion with memorandum of points and authorities, one filed document). Court: United States District Court for the Northern District of California. Folder: `courts/ninth-circuit/california/federal/northern-district/motion-brief/`.

Status: exemplar=yes, render=ok, overlay=ok, pages reviewed 12 of 12. Not a court-level `court.json` status; nothing here sets `status`.

## Governing rules

Source: N.D. Cal. Civil Local Rules, full text (PDF, "Effective October 2, 2026"), https://cand.uscourts.gov/media-library/uploads/local-rule/civil-local-rules (also listed at https://cand.uscourts.gov/rules-forms-fees/local-rules/civil-local-rules). Fetched and read 2026-10-14. The rule text below is quoted or closely paraphrased from that PDF.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| CAND-FORM-001 | Civil L.R. 3-4(c)(1) | 8½ × 11 inch white paper. Numbered lines apply to **manual** filing only (see gaps). | `typst/cand-motion-brief.typ` (paper) |
| CAND-FORM-002 | Civil L.R. 3-4(c)(2)(A)-(B) | Standard proportionally spaced font (e.g. Times New Roman or Century Schoolbook), 12 point or larger, footnotes and quotations included, unless a judge's standing order says otherwise. | `type-size`, `font-family` |
| CAND-FORM-003 | Civil L.R. 3-4(c)(2) | Text on one side, double-spaced, no more than 28 lines per page, except counsel identification, title of the case, footnotes and quotations. | `line-pitch` = 24 pt, `body-leading` |
| CAND-FORM-004 | Civil L.R. 3-4(c)(2)(C) | "Spaced no more than 10 characters per horizontal inch." See open question 1. | not enforced |
| CAND-FORM-005 | Civil L.R. 3-4(c)(3) | Footer on each page with the paper's title, and once a case number is assigned, the case number. | `running-footer` |
| CAND-FIRST-001 | Civil L.R. 3-4(a)(1) | Counsel's name, address, telephone, email and state bar number, upper left, with the party represented and its status. | cover, `counsel` + `counsel_role` |
| CAND-FIRST-002 | Civil L.R. 3-4(a)(3) | Starting on the eighth line (unless counsel identification needs more space): court title, title of the action, case number with the judge's initials, and the title of the paper. | cover (court title, caption, `case_number`) |
| CAND-FIRST-003 | Civil L.R. 7-2(b)(1), 7-4(a)(1) | The noticed hearing date and time on the first page, in the space opposite the caption and below the case number. | caption right column, `hearing` |
| CAND-CONT-001 | Civil L.R. 7-2(b)(2)-(4), 7-4(a)(3)-(5) | Notice of motion in the first paragraph; a concise statement of relief in the second; then the points and authorities: statement of issues, succinct statement of facts, argument citing authorities. | body (author-written, see `samples/`) |
| CAND-CONT-002 | Civil L.R. 7-2(b), 7-4(b) | Motion in one filed document not exceeding 25 pages (text limit for the points and authorities). Not checked by the template: no page counter exists yet. | not enforced |
| CAND-CONT-003 | Civil L.R. 7-4(a)(2) | Table of contents and table of authorities when the brief is more than 10 pages. The template always produces both (generated from headings and `toa:` links). | `toc-section`, `toa-section` |
| CAND-CONT-004 | Civil L.R. 3-4(d) | Citation to authorities: parallel U.S.C. citation for Acts of Congress, C.F.R. title/section and date for regulations, U.S./S. Ct./L. Ed. for Supreme Court cases, F./F. Supp./F.R.D. for other federal courts, official or regional reporter for state courts. Not checked by the template; authorities are written by the author. | not enforced |

Not used, and why: Civil L.R. 7-2(c) (proposed order) and 7-5 (declarations) are separate filings. No certificate of compliance or certificate of service is generated: the N.D. Cal. text above does not call for one, and the exemplar has neither (it is an ECF filing). The "signature block" is a convention, not a rule citation.

## Exemplar

- `exemplars/FILED-EXAMPLE-tsi-akim-maidu-16-cv-7189-motion-brief.pdf`: Notice of Motion and Motion to Dismiss or Transfer, with Memorandum of Points and Authorities. 17 pages. Filed by the Federal Defendants (U.S. Attorney's Office, N.D. Cal.), April 20, 2017. Text layer present (`pdffonts` shows embedded Times, `pdftotext` reads it).
- Provenance, searches and the caveat about the ECF header are in `exemplars/SOURCE.md`.
- Only one exemplar. The eval-loop tier 2 rule asks for two or three from different filers; not done (see gaps).

## Sample

- `samples/INPUT-tsi-akim-maidu-motion-to-dismiss.md` is a transcription of the exemplar: caption and counsel block, notice of motion, relief sought, issues, the memorandum's introduction, facts, Argument III.A (venue) and III.B.1 (legal standard), the conclusion, and the signature block. Footnotes 1 and 2 are included.
- It stops after III.B.1. Argument III.B.2-4 (sovereign immunity, agency failure to act, statute of limitations) are not transcribed, to keep the render within the 8-14 page target. The exemplar's pages 9-12 of the memorandum are therefore absent; the overlay shows this.
- Frontmatter follows the ca9 contract in shape (`authorities:` registry, `toa:KEY` links, footnotes, `#` headings) with the N.D. Cal. fields (`court`, `counsel`, `caption`, `hearing`, `footer_title`). Headings are numbered by the template (I., A., 1., a.); the sample types no numbers.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/ninth-circuit/california/federal/northern-district/motion-brief samples/INPUT-tsi-akim-maidu-motion-to-dismiss.md
sh tools/overlay.sh courts/ninth-circuit/california/federal/northern-district/motion-brief tsi-akim-maidu-motion-to-dismiss
```

- `samples/OUTPUT-tsi-akim-maidu-motion-to-dismiss.pdf`: 12 pages. Typst compiled with no warnings (`render.sh` fails on any warning). Only vendored fonts: `pdffonts` shows EBGaramond-Regular, -Italic, -Bold, embedded.
- `samples/OVERLAY-tsi-akim-maidu-motion-to-dismiss.pdf` and `-overlay.txt`: red = our render, blue = exemplar, black = both. The page map pairs pages by word overlap, which is coarse: ours p.1-3 ↔ filed p.1-3, ours p.5-7 ↔ filed p.6-8, ours p.12 ↔ filed p.17 (the signature page, which is the last body page of the exemplar). The overlay is a diagnostic, not a score: the exemplar uses the pleading form (line numbers down the left margin, Times) and the render does not, so the two layers will not coincide on text lines.

## Visual review (Gate 2 record, all 12 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: counsel block, court title, caption, title, hearing | OK. Hearing lines aligned after the fix (a stray leading space before "Hon. Laurel Beeler" was fixed). Caption border drawn as a left-and-bottom rule. |
| 2 | TOC (roman i) | OK after fixing a wrapped entry that pushed its page number onto a new line (page number now sits in its own column). |
| 3 | TOA (ii), cases and statutes | OK. Entries are left-aligned with dot leaders, page numbers right-aligned. |
| 4 | TOA (iii) | OK. Last entry, "Other Authorities", on this page. |
| 5 | Body 1: notice of motion, relief sought (begins) | OK. Double-spaced, footnote 1 at foot of page. The relief paragraph runs over to page 6. |
| 6 | Body 2: relief, issues, memorandum start, introduction | OK. The issues list is numbered with escaped markers (`1\.`). |
| 7 | Body 3: introduction, facts | OK. Italic *Id.* and *See* throughout. |
| 8 | Body 4: facts end; blank space at foot (the Argument heading moves to the next page with its first sub-heading) | Acceptable: heading kept with text. |
| 9 | Body 5: Argument III.A, legal standard, sub-heading 2 | OK. Hanging sub-heading labels correct (III., A., 1., 2.). |
| 10 | Body 6: III.A.2-3, footnote 2 (caed.uscourts.gov) | OK. Footnote 2 at 13 pt. |
| 11 | Body 7: III.B and B.1 | OK. |
| 12 | Body 8: conclusion and signature | OK. Signature block: "Dated" left, "Respectfully submitted" right, "/s/" line. |

Reviewed pages: 12 of 12.

## Known gaps and open choices

1. **Characters per inch (CAND-FORM-004).** Civil L.R. 3-4(c)(2)(C) says "spaced no more than 10 characters per horizontal inch." For a proportional font, 12-point Times New Roman runs at roughly 14-15 characters per inch (my estimate, not measured), so read literally the rule cannot be met by a proportional font at 12 pt. My reading: the cap is for fixed-pitch fonts (Courier at 12 pt is 10 cpi). Not enforced. **Needs David's call** (or the court's answer) before this template is treated as complete.
2. **Numbered lines (CAND-FORM-001).** Civil L.R. 3-4(c)(1) requires numbered lines on paper for manual filing. The exemplar (an ECF filing) carries pleading-paper line numbers; this render does not. Not drawn: the template targets the electronic PDF. A pleading-paper variant would need a 28-line grid and a line-number margin.
3. **Font.** EB Garamond (vendored, OFL) at 13 pt, not Times New Roman. The rule's examples are "e.g.," and EB Garamond is proportionally spaced. 13 pt rather than 12 pt because Garamond sets smaller at the same size. Both are choices; the exemplar is Times.
4. **Lines per page.** 24 pt pitch, 1 inch top and bottom margins: 27 double-spaced lines fit per body page. Checked with `pdftotext -bbox-layout`: pitch 24.0 pt on every body page. Footnotes and quotations are exempt from double spacing under 3-4(c)(2). Headings are single-spaced too, but the rule does not exempt headings: that is a convention choice, flagged here.
4a. **Court title position (CAND-FIRST-002).** The rule starts the court title on line 8 "except where additional space is required for counsel identification." Here the counsel block runs past seven lines, so the court title follows it with one line of space rather than sitting on line 8 exactly.
5. **Footer size.** 11 pt. The rule's type-size floor applies to text, footnotes and quotations; the footer is the paper identification.
6. **Judge standing orders** can change the form (3-4(c)(2) says "unless a Judge's standing order ... requires otherwise"). Not reflected.
7. **Page limit (CAND-CONT-002).** The template does not count pages. The sample is 12 pages; the 25-page limit is for the author.
8. **Tier 2 exemplars.** One exemplar only. The eval loop asks for two or three from different filers before tier 2 is judged. Not done. Searches tried are in `exemplars/SOURCE.md`.
9. **Partial sample.** Argument III.B.2-4 not transcribed (see Sample).
10. **Certificates.** None generated (see Governing rules).
11. **Heading numbering.** Numbering is done by the template from heading level (I., A., 1., a.), not typed by the author; the TOC and TOA follow the same numbers.
12. **Argument headings** and sub-headings are sentence case as in the exemplar; the template does not re-case them.
