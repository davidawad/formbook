# N.D. Cal. (cand): motion brief

Doc type: **motion** (notice of motion with memorandum of points and authorities, one filed document). Court: United States District Court for the Northern District of California. Folder: `courts/ninth-circuit/california/federal/northern-district/motion-brief/`.

Status: exemplar=two filed exemplars in `usage/` (different filers; see `usage/SOURCE.md`); render=ok (Times New Roman, pleading paper, 11 pages in typst, LaTeX and docx, on the shared document model, fb-595.96); overlay=`just overlay` (not committed); pages reviewed 11 of 11 on each engine, rendered to PNG and read by their text layout (see Visual review).

Typeface: Civil L.R. 3-4(c)(2)(A)-(B) names Times New Roman and Century Schoolbook as examples of a standard proportional font. The template uses vendored **Times New Roman** 12 pt, footnotes too, in typst and docx alike (fb-595.68.22; was Liberation Serif, and EB Garamond at 13 pt before that). The filed exemplar is Times.

## Governing rules

Source: N.D. Cal. Civil Local Rules, full text (PDF, "Effective October 2, 2026"), https://cand.uscourts.gov/media-library/uploads/local-rule/civil-local-rules (also listed at https://cand.uscourts.gov/rules-forms-fees/local-rules/civil-local-rules). Fetched and read 2026-10-14. The rule text below is quoted or closely paraphrased from that PDF.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| CAND-FORM-001 | Civil L.R. 3-4(c)(1) | 8½ × 11 inch white paper with numbered lines (the rule asks them of manually filed papers; the template draws them on every paper, as the filed exemplar has them, and as the complaint template does). | typst/layout.yaml `margin`, `pleading` (the shared model draws the numbers and rules, fb-595.96) |
| CAND-FORM-002 | Civil L.R. 3-4(c)(2)(A)-(B) | Standard proportionally spaced font (e.g. Times New Roman or Century Schoolbook), 12 point or larger, footnotes and quotations included, unless a judge's standing order says otherwise. | the base's `size: 12`, footnotes 12 pt; Times New Roman (typst/cand-motion-brief.typ) |
| CAND-FORM-003 | Civil L.R. 3-4(c)(2) | Text on one side, double-spaced, no more than 28 lines per page, except counsel identification, title of the case, footnotes and quotations. | layout.yaml `pitch: {body: 24, single: 12}`: single lines for counsel, caption, headings, tables, footnotes and signature, so two single-spaced lines sit on one numbered line; `lines-per-page` = 28, top and bottom margins 60 pt (28 x 24 = 672 of 792 pt) |
| CAND-FORM-004 | Civil L.R. 3-4(c)(2)(C) | "Spaced no more than 10 characters per horizontal inch." See open question 1. | not enforced |
| CAND-FORM-005 | Civil L.R. 3-4(c)(3) | Footer on each page with the paper's title, and once a case number is assigned, the case number. | layout.yaml `page_number`: the number, `footer_title` and the case number, 10 pt, anchored 8 pt above the foot (`foot`), a title of two lines wrapping |
| CAND-FIRST-001 | Civil L.R. 3-4(a)(1) | Counsel's name, address, telephone, email and state bar number, upper left, with the party represented and its status. | cover, `counsel` + `counsel_role` |
| CAND-FIRST-002 | Civil L.R. 3-4(a)(3) | Starting on the eighth line (unless counsel identification needs more space): court title, title of the action, case number with the judge's initials, and the title of the paper. | cover (court title, caption, `case_number`) |
| CAND-FIRST-003 | Civil L.R. 7-2(b)(1), 7-4(a)(1) | The noticed hearing date and time on the first page, in the space opposite the caption and below the case number. | caption right column, `hearing` |
| CAND-CONT-001 | Civil L.R. 7-2(b)(2)-(4), 7-4(a)(3)-(5) | Notice of motion in the first paragraph; a concise statement of relief in the second; then the points and authorities: statement of issues, succinct statement of facts, argument citing authorities. | body (author-written, see `usage/`) |
| CAND-CONT-002 | Civil L.R. 7-2(b), 7-4(b) | Motion in one filed document not exceeding 25 pages (text limit for the points and authorities). Not checked by the template: no page counter exists yet. | not enforced |
| CAND-CONT-003 | Civil L.R. 7-4(a)(2) | Table of contents and table of authorities when the brief is more than 10 pages. The template always produces both (generated from headings and `toa:` links). | layout.yaml `contents`, `authorities` (keyed, from the `toa:` links) |
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

## Render and checks

```sh
D=courts/ninth-circuit/california/federal/northern-district/motion-brief
for e in typst latex docx; do sh tools/render.sh --engine $e $D usage/INPUT-motion-brief.md; done
for e in typst latex docx; do sh tools/check.sh $D --engine $e; done
just overlay $D   # -> .overlay/<doc path>/OVERLAY-motion-brief.pdf and .txt (not committed)
```

- `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx.pdf`: 11 pages each of pleading paper (28 numbered lines, a double rule at the left and a single rule at the right), Times New Roman 12 pt, no warnings.

## Visual review (Gate 2 record)

2026-10-29, after the move onto the shared model (fb-595.96): every page of the three renders (11 typst, 11 latex, 11 docx: 33 pages) rasterized at 60 dpi with pdftoppm into `.overlay/`. The agent's image viewer could not open the PNGs in its pod, so each page was read by its text layout (`pdftotext -layout`) and its line geometry (`fb measure`); a look at the images themselves is left to the reviewer (PR). The three engines break every line and page alike (XENG-001..003 PASS).

| PDF page | Printed page | What it is | Finding (all three engines) | Status |
|---|---|---|---|---|
| 1 | cover | Counsel and role (lines 1-6), court title from line 8, caption ruled at the parties' right and foot, case number, title in bold capitals, hearing | OK. The title wraps in six lines in the 1.5 in page's right column; the exemplar's in four, past its own right margin (accepted in eval.yaml for DEF-COVER-002). | ACCEPTED (tier 3) |
| 2 | i | Table of contents | OK: "Page" over the page column, labels in their boxes. | OK |
| 3 | ii | Table of authorities: cases (italic name, comma, citation), statutes, rules, regulations, other | OK: "Page(s)" over the first group, leaders, wrapped entries hang. | OK |
| 4 | 1 | Notice of motion, relief sought; footnote 1 | OK. | OK |
| 5 | 2 | Issues to be decided (double-spaced now), memorandum, introduction | OK (the old template's single-spaced issues, an open finding, are gone). | OK |
| 6-10 | 3-7 | Facts, argument III.A and III.B with numbered sub-headings, footnote 2 | OK. | OK |
| 11 | 8 | Conclusion and signature: "Dated" left, "Respectfully submitted," at 3.2 in, the preamble, "/s/" in italics, signer | OK. | OK |
| all | | Footer: page number, the title in capitals (two lines), "No." and the case number, 10 pt, the last line 8 pt above the foot | OK. | OK |

Reviewed pages: 11 of 11 on each engine (33).

## Known gaps and open choices

1. **Characters per inch (CAND-FORM-004).** Civil L.R. 3-4(c)(2)(C) says "spaced no more than 10 characters per horizontal inch." For a proportional font, 12-point Times New Roman runs at roughly 14-15 characters per inch (my estimate, not measured), so read literally the rule cannot be met by a proportional font at 12 pt. My reading: the cap is for fixed-pitch fonts (Courier at 12 pt is 10 cpi). Not enforced. **Needs David's call** (or the court's answer) before this template is treated as complete.
2. **Numbered lines (CAND-FORM-001).** Done. Civil L.R. 3-4(c)(1) asks numbered lines of manually filed papers; the exemplar (an ECF filing) carries them and so does the N.D. Cal. complaint template, so pleading paper is the default for every N.D. Cal. paper here; there is no option to turn it off. 28 lines of 24 pt, a double rule at the text's left edge and a single rule at its right, numbers in the left margin (`line-numbers`, `pleading-rules`; furniture as `complaint/typst/cand-complaint.typ`). Body text sits on the grid; the cover and the signature block are single-spaced at 12 pt, two lines to a numbered line, so they do not always land on a number. The left margin is 1.5 in and the right 1 in, so the text is 6 in wide (was 6.5 in): the page count is 11, not 12.
3. **Font.** Times New Roman 12 pt (vendored), in typst and docx (fb-595.68.22; was Liberation Serif, and EB Garamond at 13 pt before that), the filed exemplar's face. The rule's examples are "e.g.," so other standard proportional faces would also meet its wording.
4. **Lines per page.** 24 pt pitch, 60 pt top and bottom margins (28 x 24 = 672 of 792 pt): 28 double-spaced lines fit per body page, the rule's limit. Footnotes and quotations are exempt from double spacing under 3-4(c)(2). Headings are single-spaced too, but the rule does not exempt headings: that is a convention choice, flagged here. The Civil Local Rules set no minimum margin; `eval.yaml` sets `margin_top_pt` and `margin_bottom_pt` to 60 so DEF-FORM-002 judges against the real margins.
4a. **Court title position (CAND-FIRST-002).** The rule starts the court title on line 8 "except where additional space is required for counsel identification." The counsel block stands in a box at least six numbered lines high (`min_height: 144`) and the court title a numbered line below it, so it starts on line 8 at the earliest; the sample's counsel fills the six lines and the title starts on line 8.
5. **Footer size.** 10 pt in 11.5 pt line boxes, the last ending 8 pt above the page's foot (`page_number.foot`): the 60 pt bottom margin holds four lines (page number, a title of up to two lines, case number). The sample's `footer_title` is in capitals, as both exemplars print it (the model sets the field as written).
6. **Judge standing orders** can change the form (3-4(c)(2) says "unless a Judge's standing order ... requires otherwise"). Not reflected.
7. **Page limit (CAND-CONT-002).** Not checked: the 25 pages are the memorandum's text, which the page count of the whole paper (cover and tables included) does not measure. The sample renders to 11 pages.
8. **Tier 2 exemplars.** One exemplar only. The eval loop asks for two or three from different filers before tier 2 is judged. Not done. Searches tried are in `usage/SOURCE.md`.
9. **Partial sample.** Argument III.B.2-4 not transcribed (see Sample).
10. **Certificates.** None generated (see Governing rules).
11. **Heading numbering.** Numbering is done by the layout from heading level (I., A., 1., a.), not typed by the author; the contents follow the same numbers. In the contents each level steps half an inch (`contents.step`), so II. stands half an inch in from the level-1 rows; the old template set levels 1 and 2 at the margin (tier 3).
12. **Argument headings** and sub-headings are sentence case as in the exemplar; the template does not re-case them.

## Engines

All three engines are generated from one layout (docs/EVAL-LOOP.md, "Generated engines"; fb-595.96): `typst/layout.yaml` over `lib/layouts/frcp-motion-brief.yaml`; `typst/cand-motion-brief.typ` names the face and hands the layout to `lib/typst/xdoc.typ`; `fb engines gen` writes `latex/template.tex`, `latex/xdoc.lua`, `docx/reference.xml` and `docx/xdoc.lua` (`docx/cand.lua` is gone; the LaTeX engine is new). The model keys this folder brought in (fb-595.96): `pleading` (the numbered lines and rules), `page_number.size`, `.pitch` and `.foot` (the 10 pt footer anchored at its foot, a title wrapping), a box's `min_height` (the counsel block), an authorities group's `separator` (the comma after an italic case name). `eval.yaml` gates the cross-engine check (`params.cross_engine: gate`).

`sh tools/check.sh <dir>`: typst 11 passed, 0 failed; `--engine latex`: 14 passed, 0 failed; `--engine docx`: 15 passed, 0 failed; XENG-001..003 PASS on both. Not verified in Word (LibreOffice only).

## FRCP base port

Moved onto the base with pleading paper (fb-595.96), replacing the folder's own typst template and docx filter (fb-595.17.11 had skipped it for want of pleading paper in the model).

[Parent: california/federal/northern-district](../README.md)
