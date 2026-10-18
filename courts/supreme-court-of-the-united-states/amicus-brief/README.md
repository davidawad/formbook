# Supreme Court of the United States: amicus curiae brief (merits)

Doc type `amicus-brief` of court `scotus` (folder `courts/supreme-court-of-the-united-states/`).
One doc type only. Self-contained: `usage/`, `usage/`, `typst/`, this README.

## Status

| Item | Result |
|---|---|
| Exemplar | yes: `usage/SAMPLE-scotus-amicus-brief-loperbright22451.pdf` (NSSF, merits-stage amicus for petitioners, No. 22-451, filed 2023-07-24) |
| Sample | `usage/INPUT-scotus-amicus-brief-nssf.md` (excerpt: cover, both tables, Introduction, Summary, Argument I and I.A, I.B to the Guedes discussion, Conclusion, signature, Rule 33.1(h) certificate) |
| Typeface | Rule 33.1(b) names the Century family. Substitute: **TeX Gyre Schola** (`font-family`; `docs/FONTS.md`). Metric-compatible per upstream, not checked against a commercial Century file here. |
| Render | ok: `sh tools/render.sh courts/supreme-court-of-the-united-states/amicus-brief usage/INPUT-scotus-amicus-brief-nssf.md` writes `usage/OUTPUT-scotus-amicus-brief-nssf.typst.pdf` (14 pages, TeX Gyre Schola only, no typst warnings; was 11 pages in EB Garamond) |
| Overlay | ok: `sh tools/overlay.sh courts/supreme-court-of-the-united-states/amicus-brief nssf-amicus-brief` writes `usage/OVERLAY-nssf-amicus-brief.pdf` and `.txt` |
| Pages reviewed | 14 of 14 (final render, rasterized with `pdftoppm -r 80` and viewed) |
| Open | No tier-1 typeface gap. The docx BLOCKED items stay (see Engines). Not BLOCKED: the exemplar exists. |

## Governing rules

Primary sources. The Rules text is the 2019 edition (the only copy that resolved; `https://www.supremecourt.gov/ctrules/2019RulesoftheCourt.pdf`, fetched 2026-10-14). The 2025 and 2026 Rules PDF URLs returned 404 on the same day.

Word limits and cover colors come from the booklet-format specification chart effective March 16, 2026 (`https://www.supremecourt.gov/casehand/BookletFormatSpecificChart2026.pdf`, fetched 2026-10-14). The chart confirms the 2019 limits and colors for merits amicus briefs.

| Requirement | Rule | Template (`typst/scotus-amicus-brief-amicus-brief.typ`) |
|---|---|---|
| Booklet, 6 1/8 x 9 1/4 in | 33.1(a) | `page-w`, `page-h` |
| Text field at most 4 1/8 x 7 1/8 in, footnotes included; margins at least 3/4 in | 33.1(c) | `text-w`, `text-h`; margins derived, and asserted >= 3/4 in |
| Century family (typeface), 12-pt, 2-pt or more leading; footnotes 10-pt | 33.1(b) | `font-family` "TeX Gyre Schola" (the vendored substitute in `docs/FONTS.md`); `type-size` 12pt; `leading` 2pt on a fixed 1em line box (`line-box`), so the baseline pitch is 14pt; `footnote-size` 10pt |
| Quotations over 50 words indented | 33.1(b) | `quote` blocks padded by `para-indent` |
| Word limit: 9,000 (Rule 37.6 government amicus) or 8,000 (other amicus), merits, supporting either side | 33.1(g) (chart 2026) | `word-limits`; the build panics if the body exceeds the limit |
| Cover color: light green (supporting petitioner or neither); dark green (supporting respondent) | 33.1(e), (g) (chart 2026) | Not printed (paper stock). Frontmatter `supports` decides it for the printer. |
| Cover: docket number at top; name of this Court; caption; nature of proceeding and court below; document title; counsel of record with "Counsel of Record" notation; cover type at least 11-pt | 34.1(a)-(g) | `cover()`: 12-pt throughout |
| Brief identifies the party supported | 37.2(a), 37.3(a) | Title line from `brief_title` |
| Table of contents and table of cited authorities (over 1,500 words) | 34.2 | `toc-row()`, `toa-section()`; generated, page numbers from the body's own counter |
| Signature (counsel of record name and address) at the close of the body | 34.3 | `signature-block()` after the Conclusion |
| Amicus parts: interest, summary, argument, conclusion, authorship and funding statement (Rule 37.6) | 37.5, 37.6 | Interest, Summary, Argument, Conclusion are headings in the markdown. The 37.6 statement is a footnote in the sample (the rule does not fix its place). |
| Certificate of word count, separate from the brief | 33.1(h) | Rendered as a page after the brief when `certificate: true`; word count is computed from the body (see Known gaps) |
| Proof of service | 37.5 (with Rule 29) | Not generated (separate document) |

Rule 37 numbering changed between the 2019 text and the 2026 chart. The 2019 text cites the government-amicus class as Rule 37.4; the chart cites it as Rule 37.6. The template uses the chart's word limits, which are the same either way. Verify the current Rule 37 text before relying on the citation.

## Markdown contract (sample frontmatter)

| Field | Required | Feeds |
|---|---|---|
| `case_number` | yes | Cover top line "No. ..." |
| `caption` | yes | Two sides, each `names` (list, inline markdown) and `designation`; "v." inserted between |
| `proceeding` | yes | Cover: nature of the proceeding and the court below |
| `brief_title` | yes | Cover title (printed in capitals) |
| `supports` | yes | `petitioner`, `respondent`, or `neither`; drives the cover color note in this README and the printer's stock |
| `amicus_class` | yes | `government` (Rule 37.6 class: 9,000 words) or `other` (8,000 words) |
| `counsel` | yes | Groups of `names`, optional `role` (printed under the names; use "Counsel of Record"), and `lines`; phone is appended to the first group |
| `phone` | yes | Telephone of counsel of record |
| `counsel_role` | yes | Line under the counsel block (for example "Counsel for Amicus Curiae") |
| `signature` | yes | `signer` (printed in capitals) and `lines` after the Conclusion and on the certificate |
| `date` | yes | Under the counsel block, after the signature, on the certificate |
| `certificate` | no (default false) | Renders the Rule 33.1(h) certificate as a separate page |
| `authorities` | yes if the body cites any | Registry: `kind` (`case`, `statute`, `regulation`, `other`), `name` (inline markdown), `cite`, `match` (text searched in the body; the body's own citations are labelled and paged) |

The body is markdown: `#` for the section headings (Introduction, Summary, Argument, Conclusion), `##` for point headings (labelled I., II., ...), `###` for sub-points (A., B., ...), `####` for 1., 2., ... Footnotes use the markdown `[^n]` syntax. Headings are not numbered by hand. The authority registry must match cited authorities only; an uncited entry fails the build.

## Exemplar and sample sources

- Exemplar: `usage/SOURCE.md` (URL, docket, filer, dates). Public docket file, text-based PDF (`pdftotext` returns the body).
- Sample: a transcription of the exemplar's cover, both tables, headings, and a representative portion of the body (about 1,865 words by the template count; the full brief is about 5,650 words), the signature block, and the certificate. Part II and the rest of Part I.B are omitted. The sample header says so. The overlay compares the excerpt with the whole filing, so body-page overlap is low by design.

## Overlay

`OVERLAY-nssf-amicus-brief.pdf` (red = our render, blue = filed exemplar, black = both), run against `usage/SAMPLE-scotus-amicus-brief-loperbright22451.pdf` (27 pages). Our cover (p.1) matches the filed cover at 97.8%, our TOC (p.2) at 83.0%. The body pages match at 25.0-100%; the lowest is our p.4 (sub-point A) at 25.0%, which pairs with a filed page holding different text. This is the expected result for an excerpt on a different page size: the filed brief is letter-size, our render is the 6 1/8 x 9 1/4 booklet. The overlay is a diagnostic, not a layout pass.

Names differ from the brief's default: `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `OVERLAY-<id>.pdf/.txt`, which is what the shared tools read. The brief's `usage/<id>.pdf` and `<id>-overlay.*` names were not used.

## Page review (final render, 14 pages, TeX Gyre Schola)

Rasterized at `pdftoppm -r 80`, each page viewed (pages 1-14 of `usage/OUTPUT-scotus-amicus-brief-nssf.typst.pdf`).

1. Cover: one page, counsel block and date on the page with a visible gap above the counsel block (see the cover defect below).
2. TOC (roman i): entries and page numbers match the body (Introduction 1, Summary 2, Argument 3, I.A 4, I.B 6, Conclusion 8).
3. TOA (roman ii): cases, statutes, regulations; "passim" for Chevron.
4. TOA continued (roman iii).
5. Body p.1: Introduction, footnote 1 (Rule 37.6 statement).
6. Body p.2: Summary of Argument.
7. Body p.3: Argument, point I.
8. Body p.4: sub-point A.
9. Body p.5: footnote 2.
10. Body p.6: sub-point B.
11. Body p.7: sub-point B (continued).
12. Body p.8: footnote 3; Conclusion.
13. Body p.9: signature block (Respectfully submitted and counsel), with the date.
14. Certificate (Rule 33.1(h)).

Accepted tier-2 findings: none open on this render. The body is set in a wider face than EB Garamond, so the brief runs 14 pages, not 11; Rule 33.1 sets word limits, not page limits.

Defects found and fixed in review:
- Body leading, after the face change to TeX Gyre Schola. Typst adds `leading` to the face's own line box, which is taller for Schola, so the old 6.2pt value gave about 15.4-pt pitch. The body now sets a fixed 1em line box (`line-box`, the same method as the cert-petition template) with 2pt leading: measured baseline pitch is 14.00pt on body lines in the PDF, so the value no longer depends on the face.
- Cover: with the 1em line box the cover ran out of room and the counsel block sat directly under the brief title. The three fixed 0.35in gaps on the cover were reduced to 0.25in; the cover now fits one page with a visible gap.
- Sub-point labels all read "A.". Typst advances the heading counter only when a numbering is set; a no-print numbering function is now set.
- Statute entries printed "(2018)" with a stray comma. Removed; entries join cite only when present.
- Footnote text was dropped from the word count. Rule 33.1(d) counts footnotes. Fixed.

## Known gaps

1. **Typeface (Rule 33.1(b)): resolved to the substitute.** The rule requires a Century-family face. The template sets `font-family` to TeX Gyre Schola (`docs/FONTS.md`: the Century-family substitute, with an upstream claim of metric compatibility with New Century Schoolbook). The face is not a commercial Century Schoolbook, and the claim was not checked against a commercial file on this box. A filed copy in a commercial Century face will differ slightly in line breaks.
2. **Cover color.** Not printed, because it is paper stock. Light green for `supports: petitioner` or `neither`; dark green for `respondent`.
3. **Certificate word count.** Computed from the body of the sample, so the rendered count (1,865) is for the excerpt, not the full brief. A full brief needs a full transcription. The count approximates a word processor (markup tokens are removed; footnote text is counted). Verify against the word processor before filing.
4. **Rule 33.1(h) certificate placement.** The rule requires the certificate to be separate from the brief. The template renders it as the last page of the same PDF for review; print it separately.
5. **Proof of service** (Rules 37.5, 29) is not generated.
6. **Rules text.** The 2019 Rules PDF is the only copy retrieved. The chart is from 2026. Rule numbering in Rule 37 differs between them (see Governing rules). Verify the current text before relying on it.
7. **Excerpt, not whole brief.** The sample transcribes the parts above. The TOC, TOA, and certificate reflect the excerpt. A full transcription would add pages; the template is built for 8-14 pages with the full body.

[Formbook index](../../../README.md) | [Court README](../README.md)

## Engines

Engine status (this box, after the font change): typst `ok`; latex `ok`: `usage/OUTPUT-scotus-amicus-brief-nssf.latex.pdf`, 14 pages, embedded fonts TeX Gyre Schola only (not page-reviewed; the review above is the typst render). docx: `usage/OUTPUT-scotus-amicus-brief-nssf.docx` regenerated with TeX Gyre Schola; `.docx.pdf` NOT rendered, because `soffice` is not installed on this box (`tools/render-docx.sh` stops at its conversion step). Neither engine has a checks.yaml gate run yet.

- **latex/** (`template.tex`, `brief.lua`): booklet page 6 1/8 by 9 1/4 in., text field 4 1/8 by 7 1/8 in., 12-point type on 14-point baselines, 10/12-point notes, cover, roman TOC and TOA, arabic body, signature, certificate. The TOA page list is generated from `\label`s on each citation (Lua filter), with each page printed once and "passim" at six or more pages. Fonts: TeX Gyre Schola from `fonts/tex-gyre-schola` via `fontdir` (`\setmainfont{texgyreschola}`, the file base name, as the fontspec glob needs).
- **What differs from typst:** the LaTeX render is 14 pages, the same as typst. The docx cover and certificate are plainer than the typst cover.
- **docx/** (`reference.docx`, `brief.lua`): page setup, 12-point type, 14-point exact leading, 0.4-in first-line indent and 10-point footnotes are in `reference.docx`. Its styles name TeX Gyre Schola directly, including the heading styles, which had taken the theme's Aptos Display. The cover, headings, lists, signature and certificate are raw WordprocessingML from `brief.lua`.
- **docx BLOCKED items** (see `docs/DOCX.md`):
  - TOC and TOA: BLOCKED. The lists give headings and authorities without page numbers; there is no TOC/TOA field result, so the page-number checks cannot pass.
  - Footer page numbers: BLOCKED. The reference has no footer with a PAGE field, so the roman and arabic numbering is not built.
  - Typeface: set in `reference.docx`, but not embedded. A reader without TeX Gyre Schola installed gets a substitute font in Word. The PDF from the LibreOffice conversion is the reliable form, and it is still to be rendered where `soffice` exists.
  - Certificate word count: computed from the sample body, not from Word.
  - Word and LibreOffice may paginate differently; the PDF is the LibreOffice conversion.
