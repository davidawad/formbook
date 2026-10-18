# USCMCR: brief of the appellee (answering brief)

Status for this doc type: exemplar=yes, render=ok, overlay=ok, pages_reviewed=10 (every page of `usage/OUTPUT-answering-brief.typst.pdf`, viewed after the last render).

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

- **Typeface** (above): Liberation Serif now stands in for Times New Roman. The face comes from the filings, not the rule text, which is unverified.
- **Rules unverified** (above).
- **Word count** is a frontmatter value (13879), not computed from the body.
- **Table of authorities** is not produced; the table of contents is generated.
- **Transcription**: the sample covers the first part of the 49-page brief only (issues, jurisdiction, facts A and B, argument I.A, conclusion). Argument I.B and later, and facts C onward, are not transcribed. Two OCR-garbled items were corrected in transcription: "Al37" → A137 and "Tamak Farm" → Tarnak Farm. The corrected names and cites should be checked against the PDF before any reuse.
- **Number format**: word count without a thousands separator (page 8).
- **Overlay default**: the second exemplar sorts first, so `tools/overlay.sh` without the third argument picks the wrong filing for this doc type.

## Engines

**docx** (`docx/`: `build-reference.sh` builds `reference.docx` from pandoc's default reference, `mc.lua` builds the cover, contents, signature and certificates from the frontmatter). Render: `sh tools/render.sh --engine docx <folder> usage/INPUT-answering-brief.md` writes `usage/OUTPUT-answering-brief.docx` and `.docx.pdf` (LibreOffice). Pages reviewed: 10 of 10 (every page of the `.docx.pdf`, each compared with the typst page; the review PNGs are in `/work/artifacts/mc/answering-brief/`, not committed).

- Matches the typst form: Liberation Serif 12 pt (the Times New Roman substitute, `docs/FONTS.md`; `pdffonts` shows only LiberationSerif), 1 in margins, US Letter; caption with the parenthesis column; counsel block; centered bold level-1 headings (17 pt, the size the typst headings render at) and bold hanging level-2/3 headings; footnotes 11 pt; cover and contents unnumbered; body numbered from 1, centered; certificates on their own pages; the signature block kept together.
- Differs: the word count prints with a thousands separator (13,879), as the filed exemplar does; the typst prints 13879. The issues list "(I)" to "(f)" is a Word numbered list with a hanging indent, not the typst paragraphs. Word may paginate differently from LibreOffice.
- Typst leading: the typst body renders at a 19.25 pt line pitch (measured), which is not the 25 pt a 12 pt double-spaced line gives in Word. The docx keeps the typst pitch. Whether the rules require true double spacing is unverified (see "Rule basis").
- BLOCKED: TOC page numbers (the contents field has cached entries without page numbers; a field update in Word or LibreOffice adds them; no second pass is implemented). No check ID exists yet (no `checks.yaml`).
- BLOCKED: `sh tools/check.sh <folder> --engine docx` exits 2: `Error: open .../checks.yaml: no such file or directory`. Gates 0 to 3 were not run.
