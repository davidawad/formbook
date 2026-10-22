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
| GA-SC-SPACE-001 | Rule 16(4); Rule 17(2) | Line spacing between 1.2x and double; block quotations, headings, captions and footnotes may be single-spaced. Everything else must keep at least 1.2x. | `pitch-body` 19.5 pt (1.5x); `pitch-single` 15.9 pt (1.22x) for the cover, headings, quotations, signature, certificate lines and contents title; `pitch-note` 13.5 pt for the 11-pt footnotes |
| GA-SC-MARGIN-001 | Rule 16(5); Rule 17(2) | Margins at least one inch, top, bottom and sides. Letter paper: Rule 17(1). | `page-margin` = 1 in |
| GA-SC-ELEC-001 | Rule 17(3) | E-filed documents carry no hyperlinks to other documents or external sites. | `show link` keeps the text and drops the target |
| GA-SC-PAGE-001 | Rule 21 | Counted pages numbered sequentially in Arabic numerals. The cover is the only unnumbered page. | the page-number footer starts after the cover, `counter(page).update(1)` |
| GA-SC-LIMIT-001 | Rule 20(3) | Motions, and responses and replies to them, are limited to 7,000 words. | **Not enforced by the template** (see gaps). Sample body: 1,915 words. |
| GA-SC-LIMIT-002 | Rule 20(6) | Cover, table of contents, table of citations, certificate of service, signature block and the word-count statement are not counted. | Template layout |
| GA-SC-LIMIT-003 | Rule 20(7) | "This submission does not exceed the word-count limit imposed by Rule 20." immediately above the signature block. | `signature()` (generated; wording exact) |
| GA-SC-FORM-001 | Rule 22(2) | Georgia citations include the official reporter (case name, volume, page). | Content (author) |
| GA-SC-SERVE-001 | Rule 14 | Service on the other parties. The certificate of service is generated from frontmatter `service`. | `service-certificate()` |
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

All 9 PDF pages of `usage/OUTPUT-motion-brief.typst.pdf` and of `usage/OUTPUT-motion-brief.docx.pdf` were rasterized (50 to 70 dpi) and read, side by side, after the final render (fb-595.68.36: the cross-engine layout model, Times New Roman on both engines). XENG-001..003 pass (219/219 lines, 9 pages alike).

| Page (PDF) | Printed | Result |
|---|---|---|
| 1 | cover | OK. Case number, court, caption (parenthesis and docket centered on the parties), rules around the title, counsel two columns, italics where written. Same in both engines. |
| 2 | 1 | Table of contents. OK. Every entry's page matches the page the heading is on in each engine (typst: the leader stops at the 36 pt page column; Word: the leader runs to the number). |
| 3–7 | 2–6 | Body. OK. Headings single-spaced (level 1 centered bold, level 2 bold, level 3 bold italic) and kept with the text; paragraphs indented after a paragraph, flush after a heading or quotation; the block quotation single-spaced half an inch in on both sides; footnote 1 at 11 pt under a short rule on printed page 2. |
| 8 | 7 | Conclusion, the Rule 20(7) statement, date and signature block on one page. OK (was: the signature block alone on its page; the last paragraph is now kept with it, which moves the Conclusion with it and leaves printed page 6 short). |
| 9 | 8 | Certificate of service on its own page. OK. |

No OPEN rows. ACCEPTED: printed page 6 ends about a third of a page early (the Conclusion heading, its paragraph and the signature block move on together); the caption's designation and "v." sit 2.5 pt and 1.2 pt further right in typst than in Word (cover only, diagnostic).

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

Typst is the reference engine; the docx engine (`docx/`, the same files in `motion-brief/` and `petition-for-review/`) breaks every line and every page where typst does, on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"). `eval.yaml` sets `params.cross_engine: gate`.

- `docx/reference.xml`: the cross-engine recipe (`base="xengine"`) in `{font}` at 13 pt, with the typst pitches in twips (20 x pt): Body Text 390 (19.5 pt) with 156 (7.8 pt) above and below and a half-inch first-line indent; single lines 318 (15.9 pt); Block Text 195 (9.75 pt) around quotations; footnotes 11 pt in 270 (13.5 pt) lines, 120 (6 pt) apart; Body Flush, the Note (no widow control) and Keep variants.
- `docx/ga-motion.lua`: the cover (caption and counsel as fixed-width borderless tables, the rules as paragraph borders), the questions presented (a petition), the table of contents (a dot leader to the page in a 36 pt column, as typst's `listing-row`), the headings, the Rule 20(7) statement and signature block, and the certificate of service; body paragraphs, quotations, lists and footnotes are written by pandoc in the reference styles. Contents page numbers come from `fb render`'s needles (a needle per heading, its text and the words after it); the page-number footer (a 15.9 pt line) and the sections (the cover unnumbered, arabic from 1 after it) are given to `fb render` (FORMBOOK_FOOTERS, FORMBOOK_FINAL).
- The last body paragraph is kept with the signature block in both engines (typst: one unbreakable block; Word: Body Keep and keep-with-next), so the closing never stands alone on a page.

Render with `sh tools/render.sh --engine docx <this folder> usage/INPUT-<id>.md`: `usage/OUTPUT-<id>.docx` and `.docx.pdf` (LibreOffice). The latex engine is not built for this folder.

BLOCKED: none.
