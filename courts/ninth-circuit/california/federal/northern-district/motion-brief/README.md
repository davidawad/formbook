# N.D. Cal. (cand): motion brief

Doc type: **motion** (notice of motion with memorandum of points and authorities, one filed document). Court: United States District Court for the Northern District of California. Folder: `courts/ninth-circuit/california/federal/northern-district/motion-brief/`.

Status: exemplar=two filed exemplars in `usage/` (different filers; see `usage/SOURCE.md`); render=ok (Times New Roman, pleading paper, 11 pages); overlay=not regenerated; pages reviewed 4 of 11 of the pleading-paper render (cover, contents, a body page and the signature page, rasterized and looked at; the rest of the visual review table below is from the earlier 10-page render and is not re-verified). docx: laid out the same on this machine's LibreOffice but not gated here (see Engines). Not a court-level `court.json` status; nothing here sets `status`.

Typeface: Civil L.R. 3-4(c)(2)(A)-(B) names Times New Roman and Century Schoolbook as examples of a standard proportional font. The template uses vendored **Times New Roman** 12 pt, footnotes too, in typst and docx alike (fb-595.68.22; was Liberation Serif, and EB Garamond at 13 pt before that). The filed exemplar is Times.

## Governing rules

Source: N.D. Cal. Civil Local Rules, full text (PDF, "Effective October 2, 2026"), https://cand.uscourts.gov/media-library/uploads/local-rule/civil-local-rules (also listed at https://cand.uscourts.gov/rules-forms-fees/local-rules/civil-local-rules). Fetched and read 2026-10-14. The rule text below is quoted or closely paraphrased from that PDF.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| CAND-FORM-001 | Civil L.R. 3-4(c)(1) | 8½ × 11 inch white paper with numbered lines (the rule asks them of manually filed papers; the template draws them on every paper, as the filed exemplar has them, and as the complaint template does). | `typst/cand-motion-brief.typ` (`margins`, `line-numbers`, `pleading-rules`) |
| CAND-FORM-002 | Civil L.R. 3-4(c)(2)(A)-(B) | Standard proportionally spaced font (e.g. Times New Roman or Century Schoolbook), 12 point or larger, footnotes and quotations included, unless a judge's standing order says otherwise. | `type-size` = 12 pt, `font-family` = Times New Roman (vendored) (fb-595.68.22) |
| CAND-FORM-003 | Civil L.R. 3-4(c)(2) | Text on one side, double-spaced, no more than 28 lines per page, except counsel identification, title of the case, footnotes and quotations. | `pitch-double` = 24 pt; `pitch-single` = 12 pt for counsel, caption, headings, tables, footnotes and signature, so two single-spaced lines sit on one numbered line; `lines-per-page` = 28, top and bottom margins 60 pt (28 x 24 = 672 of 792 pt) |
| CAND-FORM-004 | Civil L.R. 3-4(c)(2)(C) | "Spaced no more than 10 characters per horizontal inch." See open question 1. | not enforced |
| CAND-FORM-005 | Civil L.R. 3-4(c)(3) | Footer on each page with the paper's title, and once a case number is assigned, the case number. | `running-footer` (10 pt; fits four lines, so a two-line title plus page and case number) |
| CAND-FIRST-001 | Civil L.R. 3-4(a)(1) | Counsel's name, address, telephone, email and state bar number, upper left, with the party represented and its status. | cover, `counsel` + `counsel_role` |
| CAND-FIRST-002 | Civil L.R. 3-4(a)(3) | Starting on the eighth line (unless counsel identification needs more space): court title, title of the action, case number with the judge's initials, and the title of the paper. | cover (court title, caption, `case_number`) |
| CAND-FIRST-003 | Civil L.R. 7-2(b)(1), 7-4(a)(1) | The noticed hearing date and time on the first page, in the space opposite the caption and below the case number. | caption right column, `hearing` |
| CAND-CONT-001 | Civil L.R. 7-2(b)(2)-(4), 7-4(a)(3)-(5) | Notice of motion in the first paragraph; a concise statement of relief in the second; then the points and authorities: statement of issues, succinct statement of facts, argument citing authorities. | body (author-written, see `usage/`) |
| CAND-CONT-002 | Civil L.R. 7-2(b), 7-4(b) | Motion in one filed document not exceeding 25 pages (text limit for the points and authorities). Not checked by the template: no page counter exists yet. | not enforced |
| CAND-CONT-003 | Civil L.R. 7-4(a)(2) | Table of contents and table of authorities when the brief is more than 10 pages. The template always produces both (generated from headings and `toa:` links). | `toc-section`, `toa-section` |
| CAND-CONT-004 | Civil L.R. 3-4(d) | Citation to authorities: parallel U.S.C. citation for Acts of Congress, C.F.R. title/section and date for regulations, U.S./S. Ct./L. Ed. for Supreme Court cases, F./F. Supp./F.R.D. for other federal courts, official or regional reporter for state courts. Not checked by the template; authorities are written by the author. | not enforced |

Not used, and why: Civil L.R. 7-2(c) (proposed order) and 7-5 (declarations) are separate filings. No certificate of compliance or certificate of service is generated: the N.D. Cal. text above does not call for one, and the exemplar has neither (it is an ECF filing). The "signature block" is a convention, not a rule citation.

## Exemplar

- `usage/FILED-EXAMPLE-motion-brief.pdf`: Notice of Motion and Motion to Dismiss or Transfer, with Memorandum of Points and Authorities. 17 pages. Filed by the Federal Defendants (U.S. Attorney's Office, N.D. Cal.), April 20, 2017. Text layer present (`pdffonts` shows embedded Times, `pdftotext` reads it).
- Provenance, searches and the caveat about the ECF header are in `usage/SOURCE.md`.
- Only one exemplar. The eval-loop tier 2 rule asks for two or three from different filers; not done (see gaps).

## Sample

- `usage/INPUT-motion-brief.md` is a transcription of the exemplar: caption and counsel block, notice of motion, relief sought, issues, the memorandum's introduction, facts, Argument III.A (venue) and III.B.1 (legal standard), the conclusion, and the signature block. Footnotes 1 and 2 are included.
- It stops after III.B.1. Argument III.B.2-4 (sovereign immunity, agency failure to act, statute of limitations) are not transcribed, to keep the render within the 8-14 page target. The exemplar's pages 9-12 of the memorandum are therefore absent; the overlay shows this.
- Frontmatter follows the ca9 contract in shape (`authorities:` registry, `toa:KEY` links, footnotes, `#` headings) with the N.D. Cal. fields (`court`, `counsel`, `caption`, `hearing`, `footer_title`). Headings are numbered by the template (I., A., 1., a.); the sample types no numbers.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/ninth-circuit/california/federal/northern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/ninth-circuit/california/federal/northern-district/motion-brief tsi-akim-maidu-motion-to-dismiss
```

- `usage/OUTPUT-motion-brief.typst.pdf`: 11 pages of pleading paper (28 numbered lines, double rule at the left, single rule at the right), Times New Roman 12 pt on the shared cross-engine layout model. Typst compiled with no warnings (`render.sh` fails on any warning). Only vendored fonts.
- Overlay: **not generated**. `usage/` has no PDF in this snapshot, so `tools/overlay.sh` exits 1. `usage/OVERLAY-tsi-akim-maidu-motion-to-dismiss.txt` is the stale page map from the EB Garamond render and does not match the current render; it should be regenerated once the exemplar PDF is restored.

## Visual review (all 10 pages of the Liberation Serif render, rendered at 70 dpi and looked at; before fb-595.68.22, not re-verified against the 12-page Times New Roman render)

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
2. **Numbered lines (CAND-FORM-001).** Done. Civil L.R. 3-4(c)(1) asks numbered lines of manually filed papers; the exemplar (an ECF filing) carries them and so does the N.D. Cal. complaint template, so pleading paper is the default for every N.D. Cal. paper here; there is no option to turn it off. 28 lines of 24 pt, a double rule at the text's left edge and a single rule at its right, numbers in the left margin (`line-numbers`, `pleading-rules`; furniture as `complaint/typst/cand-complaint.typ`). Body text sits on the grid; the cover and the signature block are single-spaced at 12 pt, two lines to a numbered line, so they do not always land on a number. The left margin is 1.5 in and the right 1 in, so the text is 6 in wide (was 6.5 in): the page count is 11, not 12.
3. **Font.** Times New Roman 12 pt (vendored), in typst and docx (fb-595.68.22; was Liberation Serif, and EB Garamond at 13 pt before that), the filed exemplar's face. The rule's examples are "e.g.," so other standard proportional faces would also meet its wording.
4. **Lines per page.** 24 pt pitch, 60 pt top and bottom margins (28 x 24 = 672 of 792 pt): 28 double-spaced lines fit per body page, the rule's limit. Footnotes and quotations are exempt from double spacing under 3-4(c)(2). Headings are single-spaced too, but the rule does not exempt headings: that is a convention choice, flagged here. The Civil Local Rules set no minimum margin; `eval.yaml` sets `margin_top_pt` and `margin_bottom_pt` to 60 so DEF-FORM-002 judges against the real margins.
4a. **Court title position (CAND-FIRST-002).** The rule starts the court title on line 8 "except where additional space is required for counsel identification." Here the counsel block runs past seven lines, so the court title follows it with one line of space rather than sitting on line 8 exactly.
5. **Footer size.** 10 pt, as the complaint's footer (was 11 pt before pleading paper), in 11.5 pt boxes ending 8 pt above the page's foot: the 60 pt bottom margin holds four lines (page number, a title of up to two lines, case number). A title that wraps to three lines would run into the last numbered line; shorten `footer_title`. The rule's type-size floor applies to text, footnotes and quotations; the footer is the paper identification.
6. **Judge standing orders** can change the form (3-4(c)(2) says "unless a Judge's standing order ... requires otherwise"). Not reflected.
7. **Page limit (CAND-CONT-002).** The template does not count pages. The sample renders to 11 pages; the 25-page limit is for the author.
8. **Tier 2 exemplars.** One exemplar only. The eval loop asks for two or three from different filers before tier 2 is judged. Not done. Searches tried are in `usage/SOURCE.md`.
9. **Partial sample.** Argument III.B.2-4 not transcribed (see Sample).
10. **Certificates.** None generated (see Governing rules).
11. **Heading numbering.** Numbering is done by the template from heading level (I., A., 1., a.), not typed by the author; the TOC and TOA follow the same numbers.
12. **Argument headings** and sub-headings are sentence case as in the exemplar; the template does not re-case them.

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate") and set Times New Roman 12 pt (CAND-FORM-002), footnotes too: body text in exact 24 pt line boxes (double spaced, CAND-FORM-001), counsel, caption, headings, tables, footnotes and signature in 12 pt boxes, the footer at 10 pt in 11.5 pt boxes. The docx is on the same pleading page as typst: letter, 1.5 in left, 1 in right, 60 pt top and bottom, the numbers 1 to 28 in a page-anchored VML text box and the rules as page-high VML boxes, both in the footers (the cover has a footer of the furniture alone). `eval.yaml`: `params.cross_engine: gate`. Gate status after the pleading-paper change, 2026-10-23, on a macOS machine: typst `RESULT: 9 checks passed, 0 failed` (`sh tools/check.sh <this folder>`). docx **not re-gated**: macOS LibreOffice ignores `FONTCONFIG_FILE` and substitutes the system Times New Roman 5.01 (and Linux Libertine for U+2011), so DEF-FONT-002 and XENG-002/003 fail on this machine for this template as for the unchanged complaint (docs/FONTS.md, rule 1: renders need the pinned 2.82 files, which only the box has). A separate comparison of the two PDFs' text lines (numbers, dot leaders and U+2011 ignored) found all 334 lines and all 11 pages break after the same words. Re-run `sh tools/check.sh <this folder> --engine docx` on the box and write the docx stamp there. Re-gated on the box 2026-10-29 (fb-595.88), both outputs re-rendered from the pleading-paper template (the committed ones predated it, so the 60 pt bottom margin read the old footer as body text): typst `RESULT: 11 checks passed, 0 failed`, docx `RESULT: 15 checks passed, 0 failed`; the pleading line numbers are page furniture for the checks (`params.pleading_lines: 28`), and DEF-COVER-002 accepts the title re-wrapped in the narrower right column (eval.yaml). Open tier 2: both filed exemplars print the footer (title and case number, at the left) on page 1 too; ours starts it after the cover.

Docx engine (fb-595.68.22): `docx/reference.xml` (the cross-engine style recipe, `base="xengine"`, in the typst face) and `docx/cand.lua`, no shell. The filter writes the cover (counsel and role, court title, the caption as a two-column table ruled at the parties' right and bottom, with the case number, the title and the noticed hearing), the table of contents and the table of authorities (page numbers from fb render's needles: the first block of the motion, every heading and every `toa:` link; the cover unnumbered, the tables in roman from i, the motion from 1), the numbered headings, the body (pandoc's paragraphs, so pandoc writes the footnotes), the signature block (one row that does not split), and the footer through `$FORMBOOK_FOOTERS`: the page number, the paper's title in capitals and the case number (CAND-FORM-003). The docx before this port had no tables, no hearing block, no caption rules and a page-number-only footer; all are built now.

Pleading paper is the default (Known gap 2), as for the complaint. The `/s/ Signer` line of the signature block is italic in both engines.
