# USCMCR: brief of the appellee (answering brief)

Status for this doc type: exemplar=yes, render=ok, overlay=ok, pages_reviewed=11 (every page of `usage/OUTPUT-answering-brief.typst.pdf` and `.docx.pdf`, viewed after the cross-engine port, fb-595.54.7; the "Page review" table below is of the earlier render).

**Tier 1 (the rules' mandated form) is NOT verified.** The governing rules text could not be read (see "Rule basis"), and the typeface the rules call for is not vendored (see "Typeface"). Do not treat this template as passing tier 1.

## What is here

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-answering-brief.pdf` | **Primary exemplar.** The United States' brief (Dec. 19, 2013), 49 pages, text-based. |
| `usage/FILED-EXAMPLE-answering-brief-2.pdf` | Second exemplar, for comparison only: Hicks' "Answer Brief Re Jurisdiction" (Jan. 10, 2014), 26 pages. Not transcribed. |
| `usage/SOURCE.md` | URL, case, filer, date filed, date fetched, for both. |
| `usage/INPUT-answering-brief.md` | Markdown transcription of the primary exemplar: cover data, issues and brief answers, jurisdiction, statement of facts A and B (in part), argument I (in part), conclusion, footnotes, certificate data. |
| `usage/OUTPUT-answering-brief.typst.pdf` | Our render (9 pages). |
| `usage/OVERLAY-hicks-answering-brief.pdf`, `.txt` | Red (ours) over blue (filed) overlay, and its page map. |
| `typst/main.typ` | Entry point. |
| `typst/mc-answering-brief.typ` | The template: `mc-brief(meta, body)`. Same structure and parameters as the opening-brief template; the two files are kept separate, one per doc type. |

Build and check (from the repo root, with the toolchain on `PATH`):

```sh
sh tools/render.sh courts/military/court-of-military-commission-review/answering-brief usage/INPUT-answering-brief.md
sh tools/overlay.sh courts/military/court-of-military-commission-review/answering-brief hicks-answering-brief \
  courts/military/court-of-military-commission-review/answering-brief/usage/FILED-EXAMPLE-answering-brief.pdf
```

The overlay needs the explicit third argument. Without it, `tools/overlay.sh` takes the first exemplar in alphabetical order, and that is the Hicks appellant answer (`answer-appellant` sorts before `answering-brief`), not the government brief the sample was transcribed from.

File-name deviations from the brief: the sample is `INPUT-<id>.md`; the render is `OUTPUT-<id>.pdf`; the overlay is `OVERLAY-<id>.pdf` and `.txt` (the names the tools use by default). `tools/check.sh` and `tools/check-selftest.sh` are not run for this doc type: there is no `checks.yaml` yet.

## Rule basis

Same as the opening brief (`../opening-brief/README.md`, "Rule basis"). Summary:

| Requirement used by the template | Value | Status |
|---|---|---|
| Type-volume (word) limit | Not enforced; the certificate prints the word count from the frontmatter (13879, the government's figure) | Unverified. Rule number: the 2013 government certificate cites Rule 14(i); a 2016 search summary places the 14,000-word limit in Rule 15(g). |
| Typeface and point size | 12 pt; Liberation Serif stands in for Times New Roman (see "Typeface") | Face: rule text unverified. The government certificate says "monospaced typeface with 12 characters per inch, Times New Roman font" (Rule 14(e)). The substitute is metric-compatible (`docs/FONTS.md`). |
| Spacing, margins, paper | Double-spaced; 1 in; US Letter | Unverified. |
| Certificates | Compliance and service, generated | Form taken from the exemplar. |

The primary source (the current CMCR Rules of Practice) is needed. The mc.mil PDF is blocked to this box (HTTP 403 / "Access Denied").

## Exemplars

**Primary:** the government's brief of Dec. 19, 2013, "Brief of the United States on the Court's Lack of Authority to Hear This Case" (CMCR Case No. 13-004). It answers the Court's Dec. 4, 2013 order on its own authority, not an appellant's opening brief on the merits. The sample follows that structure: issues and brief answers, statement of jurisdiction, argument on jurisdiction, facts, conclusion.

**Second (comparison):** Hicks' "Answer Brief Re Jurisdiction" (Jan. 10, 2014), filed by the appellant in answer to the government's brief. It is the nearest other answering-type filing in the case from a different filer. It is not transcribed; `tools/overlay.sh` can compare against it by passing it as the third argument.

Tier 2 calls for two or three exemplars from different filers. Here two exist in the case (government and appellant), but the appellant's is an answer to a government brief, so its format is that of the appellant's side. Treat tier 2 as provisional.

Searches tried for answering briefs beyond these: the same WebSearch results as the opening brief, plus Just Security's Nashiri government notice of appeal (Sept. 19, 2014), which is a notice, not a brief, and was not used.

## Typeface

The filed government brief is set in Times-Roman and Times-Bold in a Word export, and its certificate cites "Rule 14(e)" for Times New Roman and a monospaced 12-cpi option. The template uses `Liberation Serif` at 12 pt, the Times New Roman substitute in `docs/FONTS.md`. The rule text is unverified (see `../opening-brief/README.md`, "Typeface"). Pagination grew from 9 to 10 pages with the switch: Times-metric text is wider than EB Garamond, so the same content takes more lines.

## Overlay (red/blue)

`usage/OVERLAY-hicks-answering-brief.pdf` pairs each of our pages with the filed page sharing the most words, against the government brief (the explicit reference above). Map from `OVERLAY-hicks-answering-brief.txt`:

| Our page | Filed page | Word overlap |
|---|---|---|
| 1 (cover) | 1 | 88.0% |
| 2 (contents) | 2 | 17.0% |
| 3 | 9 | 78.5% |
| 4 | 11 | 67.0% |
| 5 | 12 | 54.3% |
| 6 | 14 | 44.8% |
| 7 | 21 | 41.1% |
| 8 | 44 | 26.8% |
| 9 | 45 | 84.0% |
| 10 | 46 | 93.1% |

The contents page has low overlap because the filed brief's contents are on its own page 1 to 2 and the sample's contents is generated. The sample is an excerpt of the 49-page filed brief, so partial overlap is expected. The filed pages 45 and 46 are the filed certificate and signature pages. Our page 8 (conclusion) pairs with filed page 44 at 26.8%, the lowest overlap in the map; the cause was not investigated. The overlay is a diagnostic, not a score.

## Page review (Gate 2 stand-in)

Every page of `usage/OUTPUT-answering-brief.typst.pdf` was rendered at 60 dpi and viewed after the last change.

| PDF page | Content | Finding |
|---|---|---|
| 1 | Cover, caption, counsel block | Clean. Caption parenthesis column reads correctly. |
| 2 | Table of contents | Clean. Generated from headings. |
| 3 | Body p.1: issues presented and brief answers | Clean. Sub-items (a) to (f) are set as indented paragraphs. |
| 4 | Body p.2: statement of statutory jurisdiction, facts A (begins), footnote 2 | Clean. |
| 5 | Body p.3: facts A (cont.), footnote 3 | Clean. |
| 6 | Body p.4: facts B, footnote 4 | Clean. |
| 7 | Body p.5: argument I and I.A, footnote 5 | Clean. Argument heading and sub-heading styles match the opening brief. |
| 8 | Body p.6: conclusion, signature | Clean. "Dated", "Respectfully submitted", then "//s//" with the signer, kept together. |
| 9 | Body p.7: certificate of compliance | **Open (tier 2):** the word count prints "13879" without a thousands separator; the filing prints "13,879". Fix would be a number format in the template. |
| 10 | Body p.8: certificate of service | Clean. |

Fixes made during this review: the same paragraph-spacing and caption-gutter and signature-block fixes as the opening brief (see that README). The answering template's comment header describes the appellee's brief, not the appellant's.

## Known gaps

- **Typeface**: Times New Roman (vendored; the PDFs embed TimesNewRomanPSMT), as Rule 15(e) names it (`../../rules.md`, MC-FORM-001). The "Typeface" section above describes an earlier Liberation Serif render.
- **Rules unverified** (above).
- **Word count** is a frontmatter value (13879), not computed from the body.
- **Table of authorities** is not produced; the table of contents is generated.
- **Transcription**: the sample covers the first part of the 49-page brief only (issues, jurisdiction, facts A and B, argument I.A, conclusion). Argument I.B and later, and facts C onward, are not transcribed. Two OCR-garbled items were corrected in transcription: "Al37" → A137 and "Tamak Farm" → Tarnak Farm. The corrected names and cites should be checked against the PDF before any reuse.
- **Number format**: fixed; the word count prints with a thousands separator, as the filing does.
- **Overlay default**: the second exemplar sorts first, so `tools/overlay.sh` without the third argument picks the wrong filing for this doc type.

## Engines

**Shared cross-engine layout model (fb-595.54.7).** The typst template (`typst/mc-answering-brief.typ`) imports `lib/typst/xengine.typ`, and the docx filter (`docx/mc.lua`) uses `lib/docx/xengine.lua` on `docx/reference.xml` (`fb render` builds the reference document; `build-reference.sh` and `reference.docx` are retired). Both engines set Times New Roman 12 pt (Rule 15(e); the vendored face, so `TNR-EMBEDDED` and `DEF-FONT-002` pass on both), footnotes included, in exact line boxes: body 27.6 pt (Rule 15(e) double spacing: twice Times New Roman's 13.8 pt single line), single-spaced material (cover, caption, contents, signature, certificates, footnotes) 13.8 pt, section headings 17 pt bold on 19.6 pt, argument headings 14.5 pt bold on 16.7 pt; first-fit breaks, no kerning, ligatures or hyphenation. The contents rows are `listing-row` (page column 36 pt, dot leader) in typst and right-indented leader-tab paragraphs in Word; the Word page numbers come from `fb render`'s multi-pass engine (needles per heading, `FORMBOOK_PAGES`, footers `rIdFtrNone`/`rIdFtrPage`, `FORMBOOK_FINAL`). pandoc reads "(a) ..." / "(1) ..." paragraphs as fancy lists; the filter writes them back as paragraphs, as CommonMark (typst) reads them. Both certificates print the word count with a thousands separator. The docx render breaks every line and page where the typst render does (`fb diff --engines`: XENG-001..003 PASS, 100 % of lines), so `eval.yaml` sets `params.cross_engine: gate`.

Render: `sh tools/render.sh <folder> usage/INPUT-answering-brief.md` (typst) and `sh tools/render.sh --engine docx <folder> usage/INPUT-answering-brief.md` (`usage/OUTPUT-answering-brief.docx` and `.docx.pdf`, LibreOffice). Check: `sh tools/check.sh <folder>` and `sh tools/check.sh <folder> --engine docx` (both 0 failed). Pages reviewed after the port: all 11 pages of the typst and of the docx PDF, at 60 dpi, side by side (no visible difference beyond the footnote rule's weight and the contents' page numbers set flush with the margin in Word).

Changes in the port that move the typst output: body pitch 19.7 pt to 27.6 pt (the template said "double-spaced", Rule 15(e) requires it, the exemplars are at about 27.6 pt), footnotes 11 pt to 12 pt (Rule 15(e): 12 point), headings 16.8/14.4 pt to 17/14.5 pt (whole half points), the certificate word count with a thousands separator, footnote text flush left with a space after the mark. Word may paginate slightly differently from LibreOffice (`docs/DOCX.md`).
