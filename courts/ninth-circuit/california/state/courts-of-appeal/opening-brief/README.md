# California Court of Appeal: appellant's opening brief

Doc type `opening-brief` for the California Courts of Appeal (`court.json` alias `calctapp`). This folder is self-contained. The court-root `typst/` and `samples/` (none of ours) are untouched, and nothing here is a gate stamp: there is no `checks.yaml` for this doc type yet, so no mechanical Gate 0 or Gate 1 has run.

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-kirk-v-city-of-morgan-hill-H048745-opening-brief.pdf` | Filed appellant's opening brief, Sixth District, 40 pages, text layer present. Source and filer in `exemplars/SOURCE.md`. |
| `samples/INPUT-kirk-opening-brief.md` | Transcription of a portion of the exemplar (cover, tables, statements, part of the argument, conclusion, certificates). Frontmatter carries the cover, counsel, signature, service and authorities. |
| `samples/OUTPUT-kirk-opening-brief.pdf` | `sh tools/render.sh courts/ninth-circuit/california/state/courts-of-appeal/opening-brief samples/INPUT-kirk-opening-brief.md`. 14 pages, EB Garamond only. |
| `samples/OVERLAY-kirk-opening-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/ninth-circuit/california/state/courts-of-appeal/opening-brief kirk-opening-brief`. Red = ours, blue = filed, black = both. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`. |
| `typst/calctapp-opening-brief.typ` | The template: `calctapp-opening-brief(meta, md)`. Parameters at the top; each traces to a rule or is a style choice. |

## Governing rules

Verified 2026-10-14 against the courts.ca.gov rule pages. The pages were read through a summarizing fetch with limited quoting, so the wording below is paraphrase of the official text. A person should confirm the quoted values against the official rule before relying on them.

| Requirement | Source | Value used in the template |
|---|---|---|
| Font style | Rule 8.74(b)(1) (https://courts.ca.gov/cms/rules/index/eight/rule8_74) | Quoted 2026-10-15: "The font style must be a proportionally spaced serif face. Century Schoolbook is preferred." The rule allows any proportional serif, so the face is not named. EB Garamond (`font-family`) stays; the exemplar is Garamond. Visual-only stand-in if Century is wanted: TeX Gyre Schola (not used). |
| Font size | Rule 8.204(b)(4) (https://courts.ca.gov/cms/rules/index/eight/rule8_204); Rule 8.74(b)(1) | 13 pt, including footnotes (`type-size`). |
| Line spacing | Rule 8.74(b)(2) | 1.5 spaced. Measured on the render: body baseline pitch 25.41 pt against 16.97 pt single spacing, which is 1.50 (`body-leading`). |
| Margins | Rule 8.204(b)(6); Rule 8.74(b)(3) | Left and right 1.5 in, top and bottom 1 in (`side-margin`, `top-margin`). |
| Alignment | Rule 8.74(b)(4) | Left-aligned, not justified (`justify: false`). |
| Page size | Rule 8.204(b)(1); Rule 8.74(a)(7) | US Letter. |
| Page numbering | Rule 8.74(a)(2) | Arabic, consecutive from the cover as page 1, so the printed number equals the PDF page. The cover prints no number. |
| Headings and block quotations | Rule 8.204(b) (single spacing allowed for headings, footnotes and block quotations) | Single spaced. |
| Word limit and word-count certificate | Rule 8.204(c)(1) | 14,000 words (`word-limit`). The certificate's count is computed from the markdown; the wording follows the exemplar's certificate. |
| Required brief content | Rule 8.204(a)(2) (statement of appealability, nature of action, relief sought, summary of facts from the record) | Statement of Appealability and Statement of the Facts and Case are required sections in the sample. The required-content list is not enforced by a check yet. |
| Cover content | Rule 8.204(b) (title, case title, trial court and Court of Appeal numbers, trial judge, party each attorney represents) | Court lines, Court of Appeal case number, trial court, superior court number, judge, title, counsel with State Bar numbers and "Counsel for ...". |
| Searchable PDF, fonts embedded, bookmarks, 100 MB | Rule 8.74(a)(1), (a)(3), (a)(5) | Text is searchable and fonts are embedded (`pdffonts`). Bookmarks come from headings. The cover is not bookmarked (see gaps). |
| Cover color | Rule 8.40(a) | Not produced. Green applies to paper filings only, and this template is for electronic filing. |
| Copy to the superior court clerk | Rule 8.212 (as summarized) | Not produced here. The proof of service in the template covers the parties served. |
| Certificate of interested entities (APP-008) | Rule 8.208 (not fetched); the exemplar's first two pages | Not produced. It is a separate Judicial Council form filed with the first document. |
| Proof of service | Exemplar wording; the governing rule was not confirmed in this pass | Included, in the exemplar's form. |

Rule numbers marked "as summarized" or "not fetched" are not confirmed against the official text. The margin pair above is confirmed in two separate rule pages, and they agree.

## Known conflicts and choices

- **The exemplar does not follow the current margin rule.** The 2021 filing measures 1.0 in at the left (text edge at 72 pt) and about 1.1 in at the right. Rule 8.204(b)(6) as fetched today requires 1.5 in left and right, so the template follows the rule. The exemplar settles nothing about margins, because the rule leaves nothing open here. David should confirm the current margin text against the official rule before a PR cites it.
- **Font.** Century Schoolbook is the preferred face under Rule 8.74(b)(1), not a required one; the rule allows any proportional serif. EB Garamond stays. `fonts/tex-gyre-schola/` (the Century Schoolbook substitute in `docs/FONTS.md`) is vendored and could be used if David decides the preference should win; that is a change to this template, not made here. The render is checked for the 13 pt size and the embedded font names (`pdffonts`: EB Garamond only).
- **Heading scheme.** Roman, A, 1, a is used both in the statements and in the argument, matching the exemplar's table of contents. The exemplar's point headings are bold and hang under the label, which the template does too.

## Gate 2: visual review of `samples/OUTPUT-kirk-opening-brief.pdf`

Reviewed 2026-10-14 at 60 dpi, every page, against the exemplar pages the overlay pairs them with. The sha256 of the PDF reviewed is `d080562998b92f3d…` (first 16 hex digits). Later re-renders change the hash only through the embedded creation timestamp: the extracted text is identical across renders (checked with `pdftotext -layout`), so the review stood until 2026-10-16. The 2026-10-16 pass changed the text of pages 2 and 8 and re-reviewed every page (see the section at the end); the committed PDF is `ccd7ae226a3ef893…`.

| Page | Compared with (exemplar PDF page, by overlay pairing) | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 (cover) | Caption, court lines, counsel block, title and the superior court block fit on one page at the largest spacing that fits. | PASS |
| 2 | exemplar p.3 (TOC) | The entry "B. The City’s Theft-reporting Ordinance Contradicts State Law" used to push its page number "12" onto a line of its own. Fixed 2026-10-16: the page number now sits in its own column, level with the last line of the title. | FIXED |
| 3 | exemplar p.5 (TOA) | Cases, constitution and statutes groups; single-line citations with dot leaders and page numbers. | PASS |
| 4 | exemplar p.6 (TOA cont.) | Continuation of the statutes group. | PASS |
| 5 | exemplar p.9 (Introduction) | Heading centered; first-line indent; footnote 1 at 13 pt. | PASS |
| 6 | exemplar p.10 | Statement of the Issue, Appealability, Facts (I.), block quotation. | PASS |
| 7 | exemplar p.12 | Ordinance quotation and the Penal Code section in a block quotation. | PASS |
| 8 | exemplar p.15 (Argument, Standard of Review) | Case names in the body are now italic. The earlier copy had them roman, a sample error, corrected. 2026-10-16: "§§ 1.24.010" no longer splits after the first "§". | FIXED |
| 9 | exemplar p.16 (Argument A) | Case names italic after the fix. Hanging point heading II. | FIXED |
| 10 | exemplar p.16 (Argument A) | Footnote 3 on the page of its reference. Case names italic after the fix. | FIXED |
| 11 | exemplar p.17 (Argument A) | Block quotation followed by the Bivens citation; italic after the fix. | FIXED |
| 12 | exemplar p.18 (Argument B) | Conclusion heading centered; signature block with line breaks, not blank-line paragraphs (the earlier copy had extra space). | FIXED |
| 13 | exemplar p.39 (word count certificate) | Certificate wording follows the exemplar; the count is the template's count of the sample (2,158 words). | FIXED |
| 14 | exemplar p.40 (proof of service) | The service entries had "al.." and the method ran into the name; now one line break between the name and "Served ...". | FIXED |

Pages reviewed: 14 of 14.

## Known gaps

- **TOC wrap (page 2).** Fixed 2026-10-16; see "Verification pass 2026-10-16" below.
- **Cover bookmark.** Rule 8.74(a)(3) asks for bookmarks to each component's first page. The cover is not a heading, so no bookmark points to it. The certificates are bookmarked, but they are not listed in the table of contents, matching the exemplar.
- **Word count.** The certificate says 2,158 words, which the template counts from the markdown. An independent approximate count (markup stripped, headings and footnotes included) gives 2,161. The three-word difference comes from how the two counts treat headings and the signature lines. The sample is a portion, so the number is not a real filing's count.
- **Table of authorities.** Built from `toa:` links in the sample. The sample's authorities are a subset of the exemplar's, and the page numbers are the sample's own pagination, not the exemplar's.
- **One exemplar only.** Tier-2 review needs two or three exemplars from different filers, and this folder has one. Tier 2 cannot be finished until another filer is added.
- **No mechanical gates.** There is no `checks.yaml` and no `check.sh` run for this doc type. Gate 0 and Gate 1 have not been run.

## Exemplar search (for the second exemplar)

- CourtListener and RECAP: returned federal filings, not California Court of Appeal briefs.
- courts.ca.gov self-help: sample forms with blanks and the Fourth District sample Form K. Samples, not filed briefs.
- cap-la.org "FINAL.CS_.AOB_.pdf" and "AB 600 Delgadillo Sample AOB": a Second District sample with placeholder names, marked as a sample. Not a filed brief.
- ADI San Diego "Appellants-Opening-Brief-2024-8-12.docx": not fetched.
- Supreme Court "Oral Argument Document" briefs: filed, but in the California Supreme Court, not the Court of Appeal.
- michellawyers.com (Kirk case page): the Sixth District filing used as the exemplar.

A second Court of Appeal filing from a different filer, PDF with a text layer, would close the tier-2 gap.

## Engines

Docx engine (`docx/`), built 2026-10-15. `docx/make-reference.sh` builds `docx/reference.docx` from pandoc's default reference; `docx/calctapp.lua` writes the cover (from the frontmatter) and the signature block; pandoc writes the body. Set in `styles.xml` and `sectPr`, not rendered: EB Garamond 13 pt everywhere, footnotes included; body lines exact 508 twips (25.4 pt, the typst body pitch measured on `/work/artifacts/calctapp/opening-brief.pdf`); first-line indent 0.5 in; headings single-spaced, bold, black; block quotations single-spaced, indented 0.5 in each side; US Letter; 1.5 in left and right, 1 in top and bottom; centered footer PAGE field, none on the cover (`titlePg`). Not set: line numbers (the typst template sets none).

Differs from typst: no table of contents or table of authorities (no fields, no page numbers); no certificate of word count and no proof of service; the cover is paragraphs, not the caption grid; the signature block is paragraphs, not a grid. The body pitch is the typst pitch, which measures about 1.95 times the 13 pt size; that is double spacing, not the 1.5 this README states for Rule 8.74(b)(2). Flagged for David to check, not changed here.

BLOCKED (docx engine, `samples/OUTPUT-kirk-opening-brief.docx`):
- `docx.pdf` gates 0-3: BLOCKED, reason: `soffice` is not installed on the build box, so `tools/render-docx.sh` stops at the conversion step and no `.docx.pdf` exists. Pages reviewed for docx: 0.
- TOC: not generated (typst builds it with page numbers). Reason: no TOC/TOA filter yet.
- TOA: not generated. Reason: no TOA filter yet; LibreOffice does not honor TA/TOA fields (docs/DOCX.md).
- Certificate of word count and proof of service: not generated by `calctapp.lua`. Reason: not yet written.

## Verification pass 2026-10-16 (fb-595.26.16)

- Rendered with `sh tools/render.sh .../opening-brief samples/INPUT-kirk-opening-brief.md`: exit 0, no typst warnings, 14 pages (the committed PDF was also 14 pages, so it was not stale). `pdffonts`: EB Garamond Regular, Italic and Bold only.
- Viewed all 14 pages at 60 dpi, and the 14 overlay pages at 40 dpi. Our cover was compared with the exemplar's page 1.
- Overlay rerun (`tools/overlay.sh`): pairings unchanged from the table above (cover 86% word overlap, certificate of word count 90%).
- Fixed, in `typst/calctapp-opening-brief.typ`:
  - TOC page numbers (page 2): each entry is now a two-column grid, with the title and its leader in the first column and the page number bottom-aligned in the second (`toc-page-width`). A long title can no longer push its page number onto a line of its own. Entry B now reads "... State / Law ....... 12".
  - "§§" split across lines (page 8, "§ / § 1.24.010"): the no-break rule for a section sign and its number now takes a run of signs (`[§¶]+ \S+`).
- Accepted, not changed (tier 3): the exemplar's cover puts the title above the superior court block, draws a rule beside the caption, and centers the counsel block. Ours puts the superior court block first and the counsel block at the right half. Rule 8.204(b)(10) sets the cover contents, not their order, and all required items are present.
- Remaining gaps: one exemplar (one filer), so tier 2 cannot be finished; no `checks.yaml`, so Gates 0 and 1 have not run; latex not rendered (no `latex/` in this folder); docx not converted (no `soffice`).
