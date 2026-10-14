# Eighth Circuit Court of Appeals: reply brief

Doc type `reply-brief` for court `ca8` (folder `courts/eighth-circuit/court-of-appeals/`). One self-contained folder per doc type; the court-root `typst/` and `samples/` (ca8 court folder, not this one) are untouched.

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-delgado-midland-24-1786-reply-brief.pdf` | Real filed reply brief, 8th Cir. No. 24-1786 (19 pp.). Provenance in `exemplars/SOURCE.md`. |
| `samples/INPUT-delgado-midland.md` | Transcription of that brief (frontmatter = cover, counsel, signature, certificates, authorities; body = argument, conclusion, footnotes). |
| `samples/OUTPUT-delgado-midland.pdf` | `sh tools/render.sh courts/eighth-circuit/court-of-appeals/reply-brief samples/INPUT-delgado-midland.md` (18 pages). |
| `samples/OVERLAY-delgado-midland.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/eighth-circuit/court-of-appeals/reply-brief delgado-midland` (red = ours, blue = filed, black = both). |
| `typst/main.typ` | Entry point: reads the sample named by `--input sample=...`. |
| `typst/ca8-reply-brief.typ` | Template `ca8-reply-brief(meta, md)`. Content-agnostic; the numbers are named parameters at the top. |

## Governing rules

Verified 2026-10-14. Primary text where marked; the rest is secondary.

| ID | Requirement | Source (verified) | How the template meets it |
|---|---|---|---|
| CA8-FORM-002 | Margins at least one inch on all four sides | FRAP 32(a)(4), https://www.law.cornell.edu/rules/frap/rule_32 (fetched 2026-10-14) | `page-margin = 1in` |
| CA8-FORM-003 | Text double-spaced; quotations over two lines may be indented and single-spaced; headings and footnotes may be single-spaced | FRAP 32(a)(4) (same) | `body-leading`; quotations, headings, footnotes single-spaced |
| CA8-FORM-004 | Proportionally spaced serif face, 14-point or larger | FRAP 32(a)(5)(A) (same) | EB Garamond (vendored, OFL) at 14 pt everywhere, including footnotes |
| CA8-LIMIT-001 | Reply brief no more than half the principal-brief type volume: 6,500 words | FRAP 32(a)(7)(B)(ii) (same); the principal figure 13,000 (FRAP 32(a)(7)(B)(i)) | `word-limit = 6500`; the build fails above it. The 8th Cir. local principal limit (R. 28A(i)) was not retrieved, so it is not used. |
| CA8-COVER-001 | Cover: case number centered at top; court; case title; nature of the proceeding and court below; brief title identifying the party; counsel name, office address, telephone | FRAP 32(a)(2)(A)-(F) (same) | Cover body; the phone number is part of each counsel block's `lines` |
| CA8-COVER-002 | Reply cover colour gray | FRAP 32(a)(2) (same) | **Not produced**: paper copies only. The electronic PDF has a plain cover. |
| CA8-CERT-001 | Certificate of compliance by the attorney, stating the word count; Form 6 meets the requirement | FRAP 32(g)(1)-(2) (same) | `certificate-of-compliance`: Form 6 wording; word count computed from the markdown |
| CA8-CERT-002 | Electronic-version statement that the brief was scanned for viruses and is virus-free | 8th Cir. R. 28A(h)(2): **secondary** (search excerpt of the rule; courtrules.net and ca8.uscourts.gov returned 403 / were not retrieved). Cited in the exemplar as "Circuit Rule 28A(h)". | Statement in the certificate of compliance |
| CA8-CERT-003 | Certificate of service through CM/ECF | FRAP 25; 8th Cir. R. 25A(a) as cited in the exemplar (**not independently verified**) | `certificate-of-service`, printed when `service.certificate: true` |
| CA8-CONT-001 | Table of contents (headings, page numbers) | Convention; exemplar p. i | Outline with dot leaders; the TOA heading is kept out of the TOC, as in the exemplar |
| CA8-CONT-002 | Table of authorities with the page of each citation; "passim" at 7 or more pages | Convention; exemplar pp. ii-iii | Built from `toa:` links in the body, grouped by kind (cases, statutes, rules, other) |
| CA8-CONT-010 | Heading scheme: section headings centered, bold capitals; then A. / 1. / a. / (1) | Exemplar (the rules leave it open) | `style-heading`, `heading-label` |

Not produced, on purpose: a corporate disclosure statement (FRAP 26.1 is filed separately in the 8th Circuit; the exemplar's signature block carries the 501(c)(3) statement, which the template prints as the signature `note`), an addendum, a statement of related cases (not in the reply-brief form used by this exemplar).

## Markdown contract (frontmatter)

| Field | Required | Feeds |
|---|---|---|
| `case_number` | yes | Cover top line |
| `caption` | yes | list of `{names, designation}` for the two sides; "v." inserted between them |
| `proceeding` | yes | "On Appeal from ..." line (write it in the case's own caps) |
| `brief_title` | yes | Cover title (in capitals), certificate of service description |
| `counsel` | yes | list of `{names, lines}`; `lines` are printed plain; put the telephone number in `lines` |
| `signature` | yes | `signer` (printed "/s/ Name" and then the name), `lines`, optional `also` (further counsel, unsigned), optional `note` (single-spaced paragraph under the block) |
| `date` | no | Under the signature block; the date in the certificate of service |
| `service` | no | `certificate: true` prints the certificate of service |
| `authorities` | yes if the body cites any | map of key to `{kind, name, cite}` (`kind`: `case`, `statute`, `rule`, `other`, `constitution`, `regulation`); `name` is omitted for statutes, rules and other |

Body: `# Heading` is a section (centered); `##` A.; `###` 1.; `####` a.; `#####` (1). Do not type the numbers. Case names and signals in `*italics*`. Citations link to their authority: `[*Heintz v. Jenkins*, 514 U.S. 291, 299 (1995)](toa:heintz)`; a short form links to the same key. A key missing from `authorities:` stops the build. Footnotes `text[^fnN]` with `[^fnN]: text` definitions at the end of the file. Pinpoint asterisks are escaped: `\*3`. Smart punctuation is on. The word count is taken from everything before the certificates.

## What the overlay shows

`samples/OVERLAY-delgado-midland.pdf` puts our render (red) over the filed brief (blue), page by page. Pages are paired by word overlap (`-overlay.txt`), not by index. The pairing scores run 40% to 100% (page 1: 100%, page 2: 90%, page 17: 40%). The differences are layout, not content:

- The filed brief is Word output in Georgia; ours is EB Garamond with typst's line breaking, so lines and page breaks fall differently and the pages do not coincide.
- Pages 1-2 (cover, contents) overlay closely. Our TOA runs 3 pages (ii-iv) against the filed 2; the page numbers in the TOA and TOC therefore differ from the filed ones.
- The body is one page ahead or behind in places; that is the same text on a different page.

## Pages reviewed (Gate 2)

All 18 pages of `samples/OUTPUT-delgado-midland.pdf` were rasterized at 60 dpi (`pdftoppm -r 60`) and viewed. Findings and fixes made:

| Page (PDF) | Finding | Result |
|---|---|---|
| 1 | Cover: case number, court, caption, proceeding, title, counsel and date all on one page | OK |
| 2 | TOC: "Table of Authorities" listed as a contents entry (not in the filed contents) | Fixed: heading excluded from TOC |
| 3-5 | TOA ran to 4 pages with the last holding one entry | Fixed: entry spacing tightened; now 3 pages |
| 6-16 | Body: 11 pages, double-spaced, 14 pt, footnotes 1-3 on their pages, headings in order | OK |
| 17 (before the fix) | The signature block stood alone on a page (footnote definitions at the end of the markdown stopped the keep-with-signature rule) | Fixed: the last paragraph is kept with the signature; the conclusion now starts on the page with the signature |
| 17 | Certificate of compliance: "14-point" broke at the hyphen | Fixed: kept together |
| 18 | Certificate of service | OK |

## Known gaps

- **Word count**: the certificate states 2,557 words; the filed brief's own certificate states 2,741 (Microsoft Word). The template counts whitespace-delimited words from the markdown, which is not Word's method, so the two numbers are not comparable. The printed number is the template's.
- **Length**: 18 pages in total (cover, 1 page of contents, 3 of TOA, 11 of body, 2 of certificates); the filed brief is 19 (body 13). The body was transcribed in full, so the sample is at the exemplar's length, above the 8-14 page target. It was not trimmed to hit the target.
- **Emphasis**: the filed brief's italics on "(emphasis added)" are not reproduced; the markdown has the phrase without the italics.
- **Cover colour** (FRAP 32(a)(2)): not produced; paper copies only.
- **Font**: EB Garamond (the house font for this repo, vendored under `fonts/`), not Georgia. The FRAP requirement is a proportional serif at 14 pt; both meet it.
- **Secondary sources**: 8th Cir. R. 28A(h)(2) and R. 25A(a) are cited from the exemplar and a search excerpt. The court's own rules page was not retrievable from this box (403). Re-verify against the court's rules before relying on the certificate wording.
- **No other doc type** is in this folder. Opening brief, cross-appeal and other ca8 doc types are not covered.

## Engines

- **typst** (primary, `typst/`): the reference for the court's form.
- **latex** (`latex/template.tex`, `latex/ca8.lua`): tectonic (XeTeX) with the vendored EB Garamond; the same page order, 14 pt type, 31.4 pt double spacing, 1 in margins, centered page numbers, TOC and TOA with page numbers (TOA pages collected from a first pass), certificates. Differences: body is shorter in places (page breaks differ from typst by a few lines, so TOC page numbers differ); the LaTeX certificate of compliance uses the source word count (see the PR for the reconciliation with the typst figure); cover and heading spacing are approximate, not measured per page. The filter and template in this folder are the same as the other two briefs apart from the `CFG` block in `ca8.lua` and the cover/signature/certificate macros in `template.tex`.
- **docx** (`docx/reference.docx`, `docx/ca8.lua`, `docx/build-reference.sh`): pandoc on reference.docx (EB Garamond 14 pt, exact 31.4 pt line spacing, 1 in margins, PAGE footer). BLOCKED on this box: LibreOffice (`soffice`) is not installed, so `samples/OUTPUT-<id>.docx.pdf` cannot be produced and the docx checks (Gates 0 to 3) cannot run. Known limits, per docs/DOCX.md: the table of contents is a TOC field (page numbers appear after field update); the table of authorities lists authorities without page numbers (a TOA field needs the same update, and LibreOffice does not honor it); cover and certificates are plain centered paragraphs, not the typst layout.
