# Supreme Court of Georgia: motion or response to a motion (`motion-brief`)

Governing rules for a motion, or a response to a motion, filed in the Supreme Court of Georgia. Verified 2026-10-15 against the official rules PDF below. The layout is shared with `petition-for-review` (same typography, page numbering, certification and certificate of service); only the questions-presented page is absent, because a motion has none.

## Primary source

- Rules: Supreme Court of Georgia, *Rules of the Supreme Court of the State of Georgia*, effective July 2, 2026, <https://www.gasupreme.us/wp-content/uploads/2026/07/SupremeCourtRules_eff-July-2-2026.pdf> (linked from <https://www.gasupreme.us/rules/>). Read from the PDF text. The third-party mirrors (state-rules.com, courtrules.net) returned HTTP 403 and were not used.
- The brief named "Ga. Sup. Ct. R. 20 et seq." for typeface. The typeface rule is **Rule 16 (Typography)**; Rule 20 is the word and page limit.
- Motions: **Rule 26(1)**: "Motions should comply with Rules 15, 16, 17, and 20. Responses to motions may be filed at any time." Rule 26(3) applies Rules 15–18 to emergency motions, with Rule 9 added for supersedeas.

## Requirements (IDs used in the template)

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| GA-SC-FONT-001 | Rule 16(1) | Proportionally spaced serif body font; monospaced not allowed; Century family given as an example. | `typst/ga-motion-brief.typ` (`font-family`) |
| GA-SC-FONT-002 | Rule 16(2) | Body and headings no smaller than 13-pt Century Schoolbook; footnotes no smaller than 11-pt. | `type-size`, `note-size` |
| GA-SC-SPACE-001 | Rule 16(4); Rule 17(2) | Line spacing between 1.2x and double; block quotations, headings, captions and footnotes may be single-spaced. Everything else must keep at least 1.2x. | `body-leading` = 0.78 em (measured pitch 19.5 pt = 1.5x); `single-leading` = 0.5 em (measured 15.9 pt = 1.22x) |
| GA-SC-MARGIN-001 | Rule 16(5); Rule 17(2) | Margins at least one inch, top, bottom and sides. Letter paper: Rule 17(1). | `page-margin` = 1 in |
| GA-SC-ELEC-001 | Rule 17(3) | E-filed documents carry no hyperlinks to other documents or external sites. | `show link: it => it.body` |
| GA-SC-PAGE-001 | Rule 21 | Counted pages numbered sequentially in Arabic numerals. The cover is the only unnumbered page. | `set page(numbering: "1")` after the cover |
| GA-SC-LIMIT-001 | Rule 20(3) | Motions, and responses and replies to them, are limited to 7,000 words. | **Not enforced by the template** (see gaps). Sample body: 1,915 words. |
| GA-SC-LIMIT-002 | Rule 20(6) | Cover, table of contents, table of citations, certificate of service, signature block and the word-count statement are not counted. | Template layout |
| GA-SC-LIMIT-003 | Rule 20(7) | "This submission does not exceed the word-count limit imposed by Rule 20." immediately above the signature block. | `signature()` (generated; wording exact) |
| GA-SC-FORM-001 | Rule 22(2) | Georgia citations include the official reporter (case name, volume, page). | Content (author) |
| GA-SC-SERVE-001 | Rule 14 | Service on the other parties. The certificate of service is generated from frontmatter `service`. | `service-certificate()` |
| GA-SC-CIP-001 | Rule 26.1(1) | A movant or petitioner files a Certificate of Interested Persons as a separate document at the first filing. | **Not generated** (a separate document; see gaps). Responding parties are not named by Rule 26.1(1). |

## Typeface and substitute

- Rule-named face: Rule 16(1) names the **Century family (e.g., Century Schoolbook)**; Rule 16(2) states the size as 13-point Century Schoolbook. The rule does not mandate a single face.
- Substitute (docs/FONTS.md, "Century family"): **TeX Gyre Schola** (`fonts/tex-gyre-schola/`, GUST Font License). `pdffonts` on the sample shows only `TeXGyreSchola-{Regular,Bold,Italic,BoldItalic}`, all embedded.

## Markdown contract (sample frontmatter)

Same as `petition-for-review/README.md`, except there is no `questions_presented`. Fields: `case_number`, `caption`, `docket`, `title`, `filed_by` (optional), `counsel`, `attorneys_for`, `date`, `signature`, `service`.

## Samples

- `samples/INPUT-dpg-opposition-to-emergency-petition.md`: transcribed from `exemplars/FILED-EXAMPLE-democratic-party-of-georgia-S23M0376-motion-brief.pdf`. Frontmatter from the cover, counsel, signature and certificate. Body is an **excerpt** of about 1,900 words: Introduction (first two paragraphs, plus footnote 1 condensed to its text); the Statement of the Case (two paragraphs); Argument (opening and the first two sub-sections, "Intervenors' improper petition" and "not proven entitlement to a stay", and the merits sub-section through the 2017 amendment); Conclusion. Omitted: the rest of the merits argument, Argument's later sub-sections, and the exhibit list. Footnote URLs (Twitter, perma) are dropped (Rule 17(3)).
- Render: `samples/OUTPUT-dpg-opposition-to-emergency-petition.pdf`, 10 PDF pages: cover (unnumbered), TOC (printed 1), body (2–7), Conclusion (7), signature block alone on printed page 8, certificate of service (9).

## Exemplar

- `exemplars/FILED-EXAMPLE-democratic-party-of-georgia-S23M0376-motion-brief.pdf`: the whole filing, 46 pages, filed 2022-11-23 in Case No. S23M0376 (Court of Appeals docket A23E0013) by Respondents (Democratic Party of Georgia, DSCC, Warnock for Georgia). It is an **opposition** to an emergency petition and emergency motion, not a motion itself. It is the closest filed Georgia Supreme Court motion-type document found. Provenance: `exemplars/SOURCE.md`.
- The filed opposition carries no Rule 20(7) word-count certificate. The template adds it.

## Overlay

`samples/OVERLAY-dpg-opposition-to-emergency-petition.pdf` and `.txt`. Page map (ours → filed, word overlap): 1→1 84%, 2→2 51%, 3→6 68%, 4→8 55%, 5→12 60%, 6→14 74%, 7→15 86%, 8→16 43%, 9→31 20%, 10→44 36%. Overlap measures transcription coverage, not layout. PDF page 9 (the stranded signature page) pairs at 20% because the filed page it matches is a different page of the filing; PDF page 10 (certificate of service) pairs with the filed certificate at 36%, a list of names and addresses.

## Gate 2: page review

All 10 PDF pages of `samples/OUTPUT-dpg-opposition-to-emergency-petition.pdf` were rasterized at 60 dpi and read (after the final render).

| Page (PDF) | Printed | Result |
|---|---|---|
| 1 | cover | OK. Counsel lines italic, no literal asterisks. The `* Application…` line is escaped in the sample (YAML single quotes), so it is not a bullet. |
| 2 | 1 | TOC. OK. Entries match the printed pages. |
| 3–8 | 2–7 | Body. OK. The level-1 heading "Argument" is kept with its sub-heading (`block(sticky: true)`). Headings single-spaced, paragraphs indented, paragraph gaps present. Block quotation single-spaced and indented. |
| 9 | 8 | **Open (tier 2).** The Rule 20(7) statement, date and signature block stand alone on this page: the Conclusion ends at the foot of printed page 7. The statement is immediately above the signature block, as the rule requires. A signature page with no body text is a convention clerks may flag. Fix in the content (tighten the body by a few lines), or add a keep-with-next rule that is not in the template yet. |
| 10 | 9 | Certificate of service. OK. |

Defects found and fixed during the review (not present in the final render):
1. Level-1 heading stranded at the foot of a page (fixed: sticky).
2. Signature block address wrapped to narrow lines (widened to 4.2 in).
3. Single-spaced text below the 1.2x floor (raised; see the petition README, item 6).
4. The `*` in the counsel line parsed as a bullet (escaped).

## Gaps

- **Word count not enforced.** Rule 20(3) caps the motion or response at 7,000 words. The template does not count words. The sample body is 1,915 words; a filing needs a count against the rule at filing time.
- **Signature page alone** (Gate 2, printed page 8). Open, see the table above.
- **Table of authorities not generated.** Rule 19(1)(a) is written for appellant's briefs. The filed opposition has one; this template does not.
- **Certificate of Interested Persons (Rule 26.1)** is a separate document for a movant or petitioner at its first filing. The template does not produce it.
- **Redaction (Rule 17(4)–(5))** is the filer's job.
- **Excerpt sample.** About 1,900 words of a longer filing (see Samples).

## Commands

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (conda-forge)
sh tools/render.sh courts/eleventh-circuit/georgia/state/supreme-court/motion-brief samples/INPUT-dpg-opposition-to-emergency-petition.md
sh tools/overlay.sh courts/eleventh-circuit/georgia/state/supreme-court/motion-brief dpg-opposition-to-emergency-petition
```

The render fails on any typst warning and on any font outside the vendored set (`--ignore-system-fonts`).

## Engines

Typst is the primary engine (above). The DOCX engine is `docx/`: `build-reference.sh` writes `reference.docx` (the 1.5-spaced measurements of the typst motion: 19.5 pt lines, 7.8 pt after each paragraph, 13-pt headings, 11-pt footnotes, the page number in the footer); `ga-motion.lua` builds the cover, questions presented (petition only), TOC, closing and certificate; `render.sh` makes two renders so the TOC numbers come from the docx's own layout. Render with `sh tools/render.sh --engine docx <this folder> samples/INPUT-dpg-opposition-to-emergency-petition.md`: `samples/OUTPUT-dpg-opposition-to-emergency-petition.docx` and `.docx.pdf` (LibreOffice 26.8.1).

| | docx | typst |
|---|---|---|
| Pages | 10 | 10 |
| Font | TeX Gyre Schola only | TeX Gyre Schola only |
| Line pitch | 19.5 pt; 7.8 pt after paragraphs | same |
| Headings | 13 pt; the space above a heading depends on what precedes it (see below) | same |
| Cover | same layout; rules as paragraph borders | same |
| TOC | every number equals the typst output | same |
| Closing | the word-count sentence, date and signature kept on one page | same |
| Certificate | same; recipients in two columns, wrapping | same |

Checked: every page of `OUTPUT-dpg-opposition-to-emergency-petition.docx.pdf` was rendered (60 dpi) and set beside the typst page; line positions were measured with `pdftotext -bbox`.

Measured against typst, the spacing of the transitions that occur in this sample agrees to 1.6 pt or less: level 1 to level 2, body to level 2, level 2 to level 3, and level 2 to body. The space above a heading differs by case (typst adds block spacing that LibreOffice does not), so each case has its own heading style in `reference.docx` (`Heading<n>Body` after body text, the level-1 heading at the top of the body).

What differs:

- **Caption.** The close-parenthesis column and the docket are top-aligned in the table; typst centres them on the caption.
- **Line breaks.** A few line breaks at the margin differ (LibreOffice and typst break the same lines a word apart in places).
- Word not run (see answering-brief).

BLOCKED: none.
