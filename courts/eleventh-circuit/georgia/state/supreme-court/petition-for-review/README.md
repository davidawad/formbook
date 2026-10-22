# Supreme Court of Georgia: petition for certiorari (`petition-for-review`)

Governing rules for a petition for certiorari to the Supreme Court of Georgia (Ga. Sup. Ct. R. 38–45). Verified 2026-10-15 against the official rules PDF below.

## Primary source

- Rules: Supreme Court of Georgia, *Rules of the Supreme Court of the State of Georgia*, effective July 2, 2026, <https://www.gasupreme.us/wp-content/uploads/2026/07/SupremeCourtRules_eff-July-2-2026.pdf> (linked from <https://www.gasupreme.us/rules/>). Read from the PDF text (85 pages). The third-party mirrors (state-rules.com, courtrules.net) returned HTTP 403 and were not used for the rule text.
- The brief named "Ga. Sup. Ct. R. 20 et seq." for typeface. That is a mis-cite: the typeface rule is **Rule 16 (Typography)**. Rule 20 is the word and page limit. Rule 20 is used here for limits and the certification only.
- Ga. Ct. App. R. 24 (also named in the brief) governs the Court of Appeals, not this court, and is not used.

## Requirements (IDs used in the template)

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| GA-SC-FONT-001 | Rule 16(1) | Proportionally spaced serif body font; monospaced not allowed; Century family given as an example. | `typst/ga-petition-for-review.typ` (`font-family`) |
| GA-SC-FONT-002 | Rule 16(2) | Body and headings no smaller than 13-pt Century Schoolbook; footnotes no smaller than 11-pt. | `type-size`, `note-size` |
| GA-SC-SPACE-001 | Rule 16(4); Rule 17(2) | Line spacing between 1.2x and double; block quotations, headings, captions and footnotes may be single-spaced. Everything else (body, counsel, signature, service list, TOC) must keep at least 1.2x. | `pitch-body` 19.5 pt (1.5x); `pitch-single` 15.9 pt (1.22x) for the cover, headings, quotations, signature, certificate lines and contents title; `pitch-note` 13.5 pt for the 11-pt footnotes |
| GA-SC-MARGIN-001 | Rule 16(5); Rule 17(2) | Margins at least one inch, top, bottom and sides. Letter paper: Rule 17(1). | `page-margin` = 1 in |
| GA-SC-ELEC-001 | Rule 17(3) | E-filed documents carry no hyperlinks to other documents or external sites. | `show link` keeps the text and drops the target |
| GA-SC-PAGE-001 | Rule 21 | Pages counted toward the limit are numbered sequentially in Arabic numerals. The cover is the only unnumbered page. | the page-number footer starts after the cover, `counter(page).update(1)` |
| GA-SC-ORDER-001 | Rule 41(2) | The question or questions presented go under a separate heading at the beginning, before the table of contents and the introduction. | `questions-page` (from frontmatter `questions_presented`) |
| GA-SC-LIMIT-001 | Rule 20(3) | Petitions for certiorari are limited to 7,000 words. | **Not enforced by the template** (see gaps). Sample body: 2,447 words. |
| GA-SC-LIMIT-002 | Rule 20(6) | Cover, table of contents, table of citations, certificate of service, signature block and the word-count statement are not counted. | Template layout |
| GA-SC-LIMIT-003 | Rule 20(7) | "This submission does not exceed the word-count limit imposed by Rule 20." immediately above the signature block. | `signature()` (generated; wording exact) |
| GA-SC-FORM-001 | Rule 41(1) | A petition complies with Rules 14–22. Rule 22(2): Georgia citations include the official reporter. | Content (author) |
| GA-SC-FORM-002 | Rule 41(3) | Argument shows why the question meets the Rule 40 standard, not merely that the decision was error. | Content (author) |
| GA-SC-TIME-001 | Rule 38(2) | The petition is filed within 20 days after entry of judgment, or after the disposition of a motion for reconsideration. | Not a layout rule (noted for the author) |
| GA-SC-SERVE-001 | Rule 14 | Service on the other parties. The certificate of service is generated from frontmatter `service`. | `service-certificate()` |

The Rule 41 petition is judged against Rule 41 and Rules 14–22. Rule 19(1)(a) (table of contents and table of authorities for briefs "of significant length") is written for an appellant's brief, so no table of authorities is generated here. See gaps.

## Typeface and substitute

- Rule-named face: Rule 16(1) asks for a proportionally spaced serif face and names examples (the **Century family, e.g. Century Schoolbook**, Baskerville, Book Antiqua and others); Rule 16(2) states the size as 13-point Century Schoolbook. The rule does not mandate a single face.
- Face set: **Times New Roman** (vendored, `fonts/`; docs/FONTS.md rule 6, the house standard; the filed exemplars are set in Times New Roman), declared `("Times New Roman", "Liberation Serif")`. The docx names the same face through `{font}` in `docx/reference.xml`. `pdffonts` on both renders shows only `TimesNewRomanPS{MT,-BoldMT,-ItalicMT,-BoldItalicMT}`, all embedded.
- Size: 13 pt body and headings, 11 pt footnotes, the Rule 16(2) minimums in points (DEF-FORM-003 checks 13 pt, `../eval.yaml`). Times New Roman sets narrower than Century Schoolbook at the same size; the rule states sizes, not widths, and the template keeps the 13 pt it had.

## Markdown contract (sample frontmatter)

| Field | Feeds |
|---|---|
| `case_number` | Top line of the cover |
| `caption` (list of `{names, designation}`) | Caption, two sides, "v." between them |
| `docket` (list of strings) | Right column of the caption, e.g. `CASE NO. A230012` |
| `title` | Cover title (set in capitals) |
| `filed_by` (optional) | Line under the title |
| `counsel` (list of `{names, lines}`) | Counsel block, two groups per row; `lines` in italics only where written with `*...*` |
| `attorneys_for` | Line under the counsel block |
| `questions_presented` (list) | Questions presented page, numbered 1, 2, ... (Rule 41(2)) |
| `date`, `signature` (`signer`, `lines`) | Signature block after the body (with the Rule 20(7) statement above it) |
| `service` (`statement`, `served` as `{names, lines}`, optional `note`) | Certificate of service |

The body is markdown: `#` is a section (centered bold), `##` a sub-section (bold), `###` a sub-sub-section (bold italic). The table of contents is generated from the headings. Footnotes use `[^key]` with `[^key]: text` below. Smart punctuation is on.

## Samples

- `usage/INPUT-petition-for-review.md`: transcribed from `usage/FILED-EXAMPLE-petition-for-review.pdf`. Frontmatter from the cover, counsel, certificate and signature. Body is an **excerpt**: Introduction; Jurisdiction; Factual and Procedural Background; Enumeration of Errors; Legal Standard; Argument through the first two sub-sections (a, b); the closing "important issues" paragraph; Conclusion. Omitted: Argument sub-sections c–e and the middle of "Plaintiffs' interpretation". Footnote URLs (perma.cc, twitter) are dropped (Rule 17(3)). Footnotes are condensed to their text.
- The filed petition has no Questions Presented page before the TOC (its "Enumeration of Errors" carries the question). The sample adds `questions_presented` from that same question text to satisfy Rule 41(2), so the template's page is a rule-driven addition, not an exemplar copy.
- Render: `usage/OUTPUT-petition-for-review.typst.pdf` (and `.docx.pdf`), 12 PDF pages: cover (unnumbered), questions presented (printed 1), TOC (2), body (3–9), Conclusion with the Rule 20(7) statement and signature (10), certificate of service (11).

## Exemplar

- `usage/FILED-EXAMPLE-petition-for-review.pdf`: pages 1–34 of the filed package (exhibits cut). Filed by Intervenors (Georgia Republican Party, NRSC, RNC), Court of Appeals docket A230012; certificate of service dated November 22, 2022. This is an **emergency** petition from an interlocutory superior-court order, not a petition from a Court of Appeals decision. Rule 41 applies to both. Provenance: `usage/SOURCE.md`.
- No word-count certificate appears on the filed petition (checked: none of its pages carry Rule 20(7) wording). The template adds it because Rule 20(7) requires it.

## Overlay

`just overlay courts/eleventh-circuit/georgia/state/supreme-court/petition-for-review` writes `.overlay/<this folder>/OVERLAY-petition-for-review.pdf` and `.txt` (not committed). Page map of the typst render (ours → filed, word overlap): 1→1 100%, 2→13 31%, 3→2 69%, 4→7 63%, 5→9 59%, 6→11 64%, 7→12 59%, 8→14 65%, 9→16 42%, 10→18 24%, 11→31 34%, 12→33 59%. Ours p.2 (questions presented) has no counterpart: the filed petition has no questions page before the TOC. Overlap measures transcription coverage (the sample is an excerpt), not layout.

## Gate 2: page review (Gate 2 record)

All 12 PDF pages of `usage/OUTPUT-petition-for-review.typst.pdf` and of `usage/OUTPUT-petition-for-review.docx.pdf` were rasterized (50 to 60 dpi) and read, side by side, after the final render (fb-595.68.36: the cross-engine layout model, Times New Roman on both engines). XENG-001..003 pass (295/295 lines, 12 pages alike).

| Page (PDF) | Printed | Result |
|---|---|---|
| 1 | cover (none) | OK. Case number, court, caption, title in capitals between rules with the filer line, counsel in two columns, party line. Same in both engines. |
| 2 | 1 | Questions presented: the number in a half-inch box, the question hanging, 1.5 spaced. OK. |
| 3 | 2 | Table of contents. OK. Every entry's page matches the page the heading is on in each engine; a two-line entry wraps before the page column. |
| 4–10 | 3–9 | Body. OK. Headings single-spaced and kept with the text; paragraphs indented after a paragraph, flush after a heading; footnotes at 11 pt on printed pages 3, 4, 5 and 6. |
| 11 | 10 | Conclusion, the Rule 20(7) statement, date and signature block on one page. OK. |
| 12 | 11 | Certificate of service: statement, the served in two columns (the third group on a second row), the agreement note, the /s/ signature. OK. |

No OPEN rows. ACCEPTED: the caption's designations and "v." sit 2.5 pt and 1.2 pt further right in typst than in Word (cover only, diagnostic); Word's footnote separator is longer than typst's 30 % rule.

## Gaps (not done here, and why)

- **Word count not enforced.** Rule 20(3) caps the petition at 7,000 words. The template does not count words. The sample body is 2,447 words; the full petition would need a count against the rule (and the Rule 20(6) exclusions) at filing.
- **Table of authorities not generated.** Rule 19(1)(a) is written for appellant's briefs. The filed petition has one; this template does not. Add it if the Court applies Rule 19 to petitions.
- **Certificate of Interested Persons not generated.** Rule 26.1(1) requires it as a separate document at the first filing by a petitioner. It is not part of the petition, so the template does not produce it.
- **Redaction (Rule 17(4)–(5))** is the filer's job: no minors' names, home addresses, or sealed material. Nothing in the template checks this.
- **Excerpt sample.** The body is an excerpt of about 2,450 words, not the whole petition (see the Samples section).
- **Rule 38(2) timing** (20 days) is not a layout requirement and is not checked.

## Commands

```sh
export PATH="$HOME/.local/share/formbook/env/bin:$PATH"   # the toolchain of tools/bootstrap.sh
sh tools/render.sh courts/eleventh-circuit/georgia/state/supreme-court/petition-for-review usage/INPUT-petition-for-review.md
sh tools/render.sh --engine docx courts/eleventh-circuit/georgia/state/supreme-court/petition-for-review usage/INPUT-petition-for-review.md
just overlay courts/eleventh-circuit/georgia/state/supreme-court/petition-for-review
```

The render fails on any typst warning and on any font outside the vendored set (`--ignore-system-fonts`).

## Engines

Typst is the reference engine; the docx engine (`docx/`, the same files in `motion-brief/` and `petition-for-review/`) breaks every line and every page where typst does, on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"). `eval.yaml` sets `params.cross_engine: gate`.

- `docx/reference.xml`: the cross-engine recipe (`base="xengine"`) in `{font}` at 13 pt, with the typst pitches in twips (20 x pt): Body Text 390 (19.5 pt) with 156 (7.8 pt) above and below and a half-inch first-line indent; single lines 318 (15.9 pt); Block Text 195 (9.75 pt) around quotations; footnotes 11 pt in 270 (13.5 pt) lines, 120 (6 pt) apart; Body Flush, the Note (no widow control) and Keep variants.
- `docx/ga-motion.lua`: the cover (caption and counsel as fixed-width borderless tables, the rules as paragraph borders), the questions presented (a petition), the table of contents (a dot leader to the page in a 36 pt column, as typst's `listing-row`), the headings, the Rule 20(7) statement and signature block, and the certificate of service; body paragraphs, quotations, lists and footnotes are written by pandoc in the reference styles. Contents page numbers come from `fb render`'s needles (a needle per heading, its text and the words after it); the page-number footer (a 15.9 pt line) and the sections (the cover unnumbered, arabic from 1 after it) are given to `fb render` (FORMBOOK_FOOTERS, FORMBOOK_FINAL).
- The last body paragraph is kept with the signature block in both engines (typst: one unbreakable block; Word: Body Keep and keep-with-next), so the closing never stands alone on a page.

Render with `sh tools/render.sh --engine docx <this folder> usage/INPUT-<id>.md`: `usage/OUTPUT-<id>.docx` and `.docx.pdf` (LibreOffice). The latex engine is not built for this folder.

BLOCKED: none.
