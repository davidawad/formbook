# Supreme Court of Georgia: motion or response to a motion (`motion-brief`)

Governing rules for a motion, or a response to a motion, filed in the Supreme Court of Georgia. Verified 2026-10-15 against the official rules PDF below. `petition-for-review` had the same layout (typography, certification and certificate of service) plus a questions-presented page; this folder moved to the shared document model (fb-595.54.36) and that one did not yet (docs/open-items/fb-595.54.36.md).

## Primary source

- Rules: Supreme Court of Georgia, *Rules of the Supreme Court of the State of Georgia*, effective July 2, 2026, <https://www.gasupreme.us/wp-content/uploads/2026/07/SupremeCourtRules_eff-July-2-2026.pdf> (linked from <https://www.gasupreme.us/rules/>). Read from the PDF text. The third-party mirrors (state-rules.com, courtrules.net) returned HTTP 403 and were not used.
- The brief named "Ga. Sup. Ct. R. 20 et seq." for typeface. The typeface rule is **Rule 16 (Typography)**; Rule 20 is the word and page limit.
- Motions: **Rule 26(1)**: "Motions should comply with Rules 15, 16, 17, and 20. Responses to motions may be filed at any time." Rule 26(3) applies Rules 15–18 to emergency motions, with Rule 9 added for supersedeas.

## Requirements (IDs used in the template)

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| GA-SC-FONT-001 | Rule 16(1) | Proportionally spaced serif body font; monospaced not allowed; Century family given as an example. | `typst/ga-motion-brief.typ` (`font-family`) |
| GA-SC-FONT-002 | Rule 16(2) | Body and headings no smaller than 13-pt Century Schoolbook; footnotes no smaller than 11-pt. | `typst/layout.yaml` `size` 13, `footnote.size` 11 |
| GA-SC-SPACE-001 | Rule 16(4); Rule 17(2) | Line spacing between 1.2x and double; block quotations, headings, captions and footnotes may be single-spaced. Everything else must keep at least 1.2x. | `pitch.body` 19.5 pt (1.5x); `pitch.single` 15.9 pt (1.22x) for the cover, headings, quotations, signature and certificate lines; `footnote.pitch` 13.5 pt for the 11-pt footnotes |
| GA-SC-MARGIN-001 | Rule 16(5); Rule 17(2) | Margins at least one inch, top, bottom and sides. Letter paper: Rule 17(1). | `margin` 72 pt on every side |
| GA-SC-ELEC-001 | Rule 17(3) | E-filed documents carry no hyperlinks to other documents or external sites. | **Not enforced by the shared model** (it keeps a markdown link's target; requested for lib/typst/xdoc.typ and lib/pandoc/xdoc.lua in docs/open-items/fb-595.54.36.md): the author writes no markdown links to other documents or sites. The sample has none. |
| GA-SC-PAGE-001 | Rule 21 | Counted pages numbered sequentially in Arabic numerals. The cover is the only unnumbered page. | `page_number.front: lower-roman`: the cover unnumbered, the table of contents (not counted, Rule 20(6)) i, the motion from 1 |
| GA-SC-LIMIT-001 | Rule 20(3) | Motions, and responses and replies to them, are limited to 7,000 words. | **Not enforced by the template** (see gaps). Sample body: 1,915 words. |
| GA-SC-LIMIT-002 | Rule 20(6) | Cover, table of contents, table of citations, certificate of service, signature block and the word-count statement are not counted. | Template layout |
| GA-SC-LIMIT-003 | Rule 20(7) | "This submission does not exceed the word-count limit imposed by Rule 20." immediately above the signature block. | `closing` (a court constant; wording exact) |
| GA-SC-FORM-001 | Rule 22(2) | Georgia citations include the official reporter (case name, volume, page). | Content (author) |
| GA-SC-SERVE-001 | Rule 14 | Service on the other parties. The certificate of service is generated from frontmatter `service`. | `closing` (after a page break) |
| GA-SC-CIP-001 | Rule 26.1(1) | A movant or petitioner files a Certificate of Interested Persons as a separate document at the first filing. | **Not generated** (a separate document; see gaps). Responding parties are not named by Rule 26.1(1). |

## Typeface and substitute

- Rule-named face: Rule 16(1) asks for a proportionally spaced serif face and names examples (the **Century family, e.g. Century Schoolbook**, Baskerville, Book Antiqua and others); Rule 16(2) states the size as 13-point Century Schoolbook. The rule does not mandate a single face.
- Face set: **Times New Roman** (vendored, `fonts/`; docs/FONTS.md rule 6, the house standard; the filed exemplars are set in Times New Roman), declared `("Times New Roman", "Liberation Serif")`. The docx names the same face through `{font}` in `docx/reference.xml`. `pdffonts` on both renders shows only `TimesNewRomanPS{MT,-BoldMT,-ItalicMT,-BoldItalicMT}`, all embedded.
- Size: 13 pt body and headings, 11 pt footnotes, the Rule 16(2) minimums in points (DEF-FORM-003 checks 13 pt, `../eval.yaml`). Times New Roman sets narrower than Century Schoolbook at the same size; the rule states sizes, not widths, and the template keeps the 13 pt it had.

## Markdown contract (sample frontmatter)

Same as `petition-for-review/README.md`, except there is no `questions_presented`. Fields: `case_number`, `caption`, `docket`, `title`, `filed_by` (optional), `counsel`, `attorneys_for`, `date`, `signature`, `service`.

## Samples

- `usage/INPUT-motion-brief.md`: transcribed from `usage/FILED-EXAMPLE-motion-brief.pdf`. Frontmatter from the cover, counsel, signature and certificate. Body is an **excerpt** of about 1,900 words: Introduction (first two paragraphs, plus footnote 1 condensed to its text); the Statement of the Case (two paragraphs); Argument (opening and the first two sub-sections, "Intervenors' improper petition" and "not proven entitlement to a stay", and the merits sub-section through the 2017 amendment); Conclusion. Omitted: the rest of the merits argument, Argument's later sub-sections, and the exhibit list. Footnote URLs (Twitter, perma) are dropped (Rule 17(3)).
- Render: `usage/OUTPUT-motion-brief.typst.pdf` (and `.docx.pdf`), 9 PDF pages: cover (unnumbered), TOC (printed 1), body (2–6), Conclusion with the Rule 20(7) statement and signature block (7), certificate of service (8).

## Exemplar

- `usage/FILED-EXAMPLE-motion-brief.pdf`: the whole filing, 46 pages, filed 2022-11-23 in Case No. S23M0376 (Court of Appeals docket A23E0013) by Respondents (Democratic Party of Georgia, DSCC, Warnock for Georgia). It is an **opposition** to an emergency petition and emergency motion, not a motion itself. It is the closest filed Georgia Supreme Court motion-type document found. Provenance: `usage/SOURCE.md`.
- The filed opposition carries no Rule 20(7) word-count certificate. The template adds it.

## Overlay

`just overlay courts/eleventh-circuit/georgia/state/supreme-court/motion-brief` writes `.overlay/<this folder>/OVERLAY-motion-brief.pdf` and `.txt` (not committed). Page map of the typst render (ours → filed, word overlap): 1→1 84%, 2→2 51%, 3→6 59%, 4→8 39%, 5→13 54%, 6→15 65%, 7→16 55%, 8→31 35%, 9→44 36%. Overlap measures transcription coverage (the sample is an excerpt), not layout; PDF page 8 (conclusion and signature) and 9 (certificate of service) pair with other pages of the filing, mostly names and addresses.

## Gate 2: page review

All 9 PDF pages of `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf` and `.docx.pdf` were rasterized (60 dpi) and read side by side after the final render (fb-595.54.36: the shared document model, `typst/layout.yaml`; latex and docx generated by `fb engines gen`). XENG-001..003 pass on latex and docx (219/219 lines, 9 pages alike).

| Page (PDF) | Printed | Result |
|---|---|---|
| 1 | cover | OK. Case number, court, caption (parenthesis and docket centered on the parties), rules around the title, counsel two columns, italics where written. Same in the three engines. |
| 2 | i | Table of contents. OK. Every entry's page matches the page the heading is on in each engine (typst and LaTeX: the leader stops before the 36 pt page column; Word: the leader runs to the number). |
| 3–7 | 1–5 | Body. OK. Headings single-spaced (level 1 centered bold, level 2 bold, level 3 bold italic) and kept with the text; paragraphs indented; the block quotation single-spaced half an inch in on both sides; footnote 1 at 11 pt under a short rule on printed page 1. |
| 8 | 6 | The conclusion (heading and paragraph), the Rule 20(7) statement, date and signature block. OK: the last paragraph is kept whole with the closing (layout.yaml `keep_with_closing`, fb-595.54.82), as the old template set them in one block; the contents give the conclusion page 6 in the three engines. |
| 9 | 7 | Certificate of service on its own page. OK. |

No OPEN rows. ACCEPTED: body paragraphs touch at the 19.5 pt pitch (the shared model has no space between body paragraphs; the template had 7.8 pt), the first-line indent marks them; the certificate of service is no longer a row of the table of contents (it is set by the closing, not a body heading).

## Gaps

- **Word count not enforced.** Rule 20(3) caps the motion or response at 7,000 words. The template does not count words. The sample body is 1,915 words; a filing needs a count against the rule at filing time.
- **Table of authorities not generated.** Rule 19(1)(a) is written for appellant's briefs. The filed opposition has one; this template does not.
- **Certificate of Interested Persons (Rule 26.1)** is a separate document for a movant or petitioner at its first filing. The template does not produce it.
- **Redaction (Rule 17(4)–(5))** is the filer's job.
- **Excerpt sample.** About 1,900 words of a longer filing (see Samples).

## Commands

```sh
export PATH="$HOME/.local/share/formbook/env/bin:$PATH"   # the toolchain of tools/bootstrap.sh
sh tools/render.sh courts/eleventh-circuit/georgia/state/supreme-court/motion-brief usage/INPUT-motion-brief.md
sh tools/render.sh --engine docx courts/eleventh-circuit/georgia/state/supreme-court/motion-brief usage/INPUT-motion-brief.md
just overlay courts/eleventh-circuit/georgia/state/supreme-court/motion-brief
```

The render fails on any typst warning and on any font outside the vendored set (`--ignore-system-fonts`).

## Engines

The folder is on the shared document model (docs/EVAL-LOOP.md, "Generated engines"; fb-595.54.36): `typst/layout.yaml` holds every number and block of the layout with its rule, `typst/ga-motion-brief.typ` names the face and hands the layout to `lib/typst/xdoc.typ`. `fb engines gen` writes `latex/template.tex`, `latex/xdoc.lua`, `docx/xdoc.lua` and `docx/reference.xml` from it (`fb engines gen --check` fails on a stale one); the latex and docx renders break every line and page where typst does, and `eval.yaml` sets `params.cross_engine: gate`.

Render with `sh tools/render.sh --engine latex|docx <this folder> usage/INPUT-<id>.md`: `usage/OUTPUT-<id>.latex.pdf`, `usage/OUTPUT-<id>.docx` and `.docx.pdf` (LibreOffice).

BLOCKED: none.
