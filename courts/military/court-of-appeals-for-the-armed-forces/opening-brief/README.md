# CAAF: brief on behalf of the appellant (`opening-brief`)

Court: United States Court of Appeals for the Armed Forces (`armfor`). Doc type: the appellant's brief on the merits, Rule 24 (also the form that the Rule 25 and granted-case briefs follow). Status: **template built; not a court-level status.** `court.json` is not touched (only David sets `done`).

## Governing rules

Primary source for every requirement: **CAAF Rules of Practice and Procedure, effective October 1, 2024, as amended through September 26, 2025**, https://www.armfor.uscourts.gov/library/Rules/Rules2025SepAmendedThrough26September2025.pdf. Fetched and read on 2026-10-14 (text layer, `pdftotext`); Rule 24 was read in full, and Rules 37, 38 and 39 in the parts cited below. A 2026 Federal Register notice of a proposed redrafting of the rules was seen in search results but not retrieved. Re-check Rule 24 if a redrafted version is adopted.

Kinds: **M** mandated by a court rule; **C** convention (taken from the filed exemplars, the rules leave it open); **A** author responsibility (not generated).

| ID | Requirement | Source | Kind | Where in the template |
|---|---|---|---|---|
| CAAF-BRF-001 | Type-volume limit for a brief of the appellant: 13,000 words. Headings, footnotes and quotations count; index, table of authorities, appendix and certificates do not. | Rule 24(b)(1), (3) | M | `word-limit`; `armfor-opening-brief()` panics over the limit |
| CAAF-BRF-002 | Required order: cover; index; Issue(s) Presented; Statement of Statutory Jurisdiction; Statement of the Case; Statement of Facts; Summary of Argument; Argument; Conclusion; signature. "Relevant Authorities" and "References to the Record" are optional. | Rule 24(a) | M | `required-sections`; `check-structure()` panics if one is missing or out of order |
| CAAF-BRF-003 | Each brief sets out the standard of review for each issue, under its own heading or within the discussion of each issue. | Rule 24(a), Argument | M | `armfor-opening-brief()` checks that a heading names the standard of review (presence only; per-issue coverage is not checked) |
| CAAF-BRF-004 | Issues presented set out in standard bold sentence case. | Rule 24(a) | M | Author writes the issue in bold; not checked |
| CAAF-BRF-005 | Certificate of compliance in the Rule 24(d) form: "This brief complies with the type-volume limitation of Rule 24(b) because: This brief contains N words. This brief complies with the typeface and type style requirements of Rule 37." | Rule 24(c), (d) | M | `certificate-of-compliance()` |
| CAAF-BRF-006 | Typeface: proportional type, 14-point, printed matter including footnotes; margins at least one inch on all four sides; no text in the margin except page numbers. | Rule 37(a) | M | `type-size`, `page-margin`, footnote style |
| CAAF-BRF-007 | Double spacing. Stated for papers "not filed electronically"; the filed briefs are double-spaced. | Rule 37(a); exemplars | C | `body-leading` |
| CAAF-BRF-008 | Index of the matter with page references, and a table of cases, statutes and other authorities, for a pleading of ten or more pages; Bluebook citation form; record references with page numbers; no incorporation by reference. | Rule 37(c)(1)-(4) | M | `index-section()`, `toa-section()` |
| CAAF-BRF-009 | Signature of counsel: name, address, email, telephone, Court Bar number, grade and capacity; electronic filings carry `/s/`. | Rule 38(a), (c) | M | `signature-block()` |
| CAAF-BRF-010 | Certificate of filing and service in the Rule 39(c)(2) form: means of delivery to the Court and to the party, the party's email or mailing address, and the date. | Rule 39(c)(1)-(2) | M | `certificate-of-service()`; the address of the party served is an author input (see Known gaps) |
| CAAF-BRF-011 | Joint appendix filed contemporaneously, as a separate PDF. | Rule 24(e) | A | Not generated; a separate document |

## Layout

| Path | What |
|---|---|
| `typst/armfor-opening-brief.typ` | The template: `armfor-opening-brief(meta, md)`. Content-agnostic: no case text, no coordinates, no forced line breaks, the vendored EB Garamond only (`fallback: false`). |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`. |
| `samples/INPUT-pinkerton-opening-brief.md` | The markdown transcription of the Pinkerton brief: frontmatter (caption, four counsel, signature, service, authorities), then the granted issue, jurisdiction, the case, the facts (A to E), the summary, the Argument (point I with its standard of review, and sub-heading B with its first path), the conclusion, and five footnotes. About half of the filed text; the rest of the Argument (point I.B, Paths 2 and beyond, and sub-heading C and D) is omitted. |
| `samples/OUTPUT-pinkerton-opening-brief.pdf` | The render: 15 pages (cover, index, two pages of authorities, nine pages of body, two certificates). |
| `samples/OVERLAY-pinkerton-opening-brief.pdf`, `.txt` | The red/blue comparison and its page map. |
| `exemplars/FILED-EXAMPLE-pinkerton-26-0225-opening-brief.pdf` | Filed exemplar 1 (Army, 2026). |
| `exemplars/FILED-EXAMPLE-muller-19-0230-opening-brief.pdf` | Filed exemplar 2 (Air Force, 2019 Term), for the tier-2 cross-check. |
| `exemplars/SOURCE.md` | URL, case, docket, filer, date filed, date fetched, for both exemplars. |

File names follow the repository's file-role convention (`INPUT-`, `OUTPUT-`, `OVERLAY-`) because `tools/render.sh` and `tools/overlay.sh` read and write those names by default; see the same note in `../petition-supplement/README.md`.

Commands, from the repository root:

```sh
export PATH="$HOME/tb/bin:$PATH"   # toolchain from the box setup (typst 0.15.0, poppler, ImageMagick)
sh tools/render.sh courts/military/court-of-appeals-for-the-armed-forces/opening-brief samples/INPUT-pinkerton-opening-brief.md
sh tools/overlay.sh courts/military/court-of-appeals-for-the-armed-forces/opening-brief pinkerton-opening-brief courts/military/court-of-appeals-for-the-armed-forces/opening-brief/exemplars/FILED-EXAMPLE-pinkerton-26-0225-opening-brief.pdf
```

The overlay takes the Pinkerton exemplar as its third argument because the sample is transcribed from it; by default it would compare against the first exemplar by name (Muller).

## Results

- Render: **ok**. `tools/render.sh` ran and wrote `samples/OUTPUT-pinkerton-opening-brief.pdf` with no typst warnings. Fonts: `EBGaramond-Regular`, `-Bold`, `-Italic`, all embedded.
- Overlay: **ok**. `tools/overlay.sh` ran against the Pinkerton exemplar and wrote `OVERLAY-pinkerton-opening-brief.pdf`. The page map (`OVERLAY-pinkerton-opening-brief.txt`) pairs our cover, index and authorities with the exemplar's first pages, and pairs each body page with the exemplar page it shares the most words with (ours PDF p.5 to p.15 with filed p.5, 8, 9, 10, 12, 7, 13, 15, 23, 25, 26). The overlay is a diagnostic, not a score.
- Pages reviewed: **15 of 15**. Each page of the current PDF was rendered at 60 dpi and looked at. The certificate page (PDF p.14) was re-rendered and re-viewed after its one fix.

## Gate 2: visual review of `samples/OUTPUT-pinkerton-opening-brief.pdf`

"Overlay pairs with" is the Pinkerton exemplar's PDF page that the overlay paired with this page (`OVERLAY-pinkerton-opening-brief.txt`). "body" is the page number printed in the footer.

| PDF p. (printed) | Overlay pairs with | Finding | Status |
|---|---|---|---|
| 1 (cover) | filed p.1 | Caption, party roles, title, both docket numbers, the judges' address line and four counsel in two columns. The first render spilled the second row of counsel onto a second page; the gaps between the cover's parts were reduced from 1.2 em to 0.8 em and the paragraph spacing on the cover from 0.6 em to 0.4 em (the type was not changed), and the cover re-rendered to one page. | FIXED |
| 2 (i) | filed p.2 | Index of Brief with a page column: Granted Issue, the statement sections, the facts sub-headings A to E, the Argument with point I and its sub-headings, and the conclusion. | PASS |
| 3 (ii) | filed p.3 | Table of Cases, Statutes, and Other Authorities, grouped (Supreme Court, CAAF, Service Courts, State and Other Federal, Statutes), page column with dot leaders; "passim" is not needed (no authority reaches seven pages). | PASS |
| 4 (iii) | filed p.4 | The "Rules and Other Authorities" group, two entries, alone on this page. | ACCEPTED (the authorities run onto a second page; the group keeps its heading, and nothing is split) |
| 5 (body 1) | filed p.5 | Granted issue in bold sentence case under its heading; statement of statutory jurisdiction; statement of the case, with footnotes 1 and 2 at 14-point below the text. | PASS |
| 6 (body 2) | filed p.8 | Statement of facts; sub-heading A in bold with its hanging label. | PASS |
| 7 (body 3) | filed p.9 | Continuous text under sub-heading A, with footnotes 3 to 5 at 14-point below it. | PASS |
| 8 (body 4) | filed p.10 | Sub-headings B, C and D with hanging labels; C and D wrap to two lines under their labels. | PASS |
| 9 (body 5) | filed p.12 | Block quotation of the exchange with JP (speakers on separate lines, indented, single-spaced). The paragraph after the block quotation, "(JA 169).", is indented as a new paragraph; the filing has it flush. | ACCEPTED (a paragraph-indent convention after a block quote; tier 2, no rule) |
| 10 (body 6) | filed p.7 | Summary of Argument; footnote 6 at 14-point. | PASS |
| 11 (body 7) | filed p.13 | "Argument" centered; point I centered in bold with its roman numeral; sub-heading A (standard of review) in bold with its hanging label. | PASS |
| 12 (body 8) | filed p.15 | Sub-heading B ("The Two-Path Constitutional Dilemma ...") in bold, three lines; numbered sub-heading 1 ("Path 1 ...") with its hanging label. | PASS |
| 13 (body 9) | filed p.23 | Conclusion; `/s/` signature block with the counsel's lines; the date. | PASS |
| 14 (10) | filed p.25 | Certificate of Compliance in the Rule 24(d) form: word count and typeface statement on one paragraph, then the `/s/` signature. The first render ran the two sentences together ("1833 words.This brief"); fixed in the same paragraph and re-viewed. | FIXED |
| 15 (11) | filed p.26 | Certificate of Filing and Service in the Rule 39(c)(2) form: the means of service, the party served, the date, and the `/s/` signature. | PASS |

Overall visual result: the cover fits one page; the index and the table of authorities agree with the body page numbers; the footnotes are 14-point and stay on the page that carries the mark. No page has an open tier 1 or tier 2 defect.

## Findings about the exemplar (not the template)

- **Pinkerton lists the Summary of Argument before the Statement of Facts.** Rule 24(a) lists the Statement of Facts first. The template follows Rule 24(a); the sample is reordered to match it. The transcription therefore differs from the filed order on purpose.
- **Typeface (CAAF-BRF-006): face=none named, font=EB Garamond.** Rule 37(a) requires "proportional type, e.g., Times New Roman, in fourteen-point type". The "e.g." makes Times New Roman an example, not a requirement, so the rule names no face and any proportional type complies. Per `docs/FONTS.md` ("No face named" row) the template keeps EB Garamond. Pinkerton's certificate says Times New Roman, and the other filings use Century Schoolbook and a Times-style face; font choice is tier 2 and does not change a mandated requirement. Page count is unchanged by this review (no font change; 15 pages rendered).

## Known gaps

- **Certificate of service, address of the party served (CAAF-BRF-010).** Rule 39(c)(2) asks for the party's email or mailing address. The Pinkerton filing names "the Government Appellate Division" and gives no address. The template prints what the frontmatter (`service.served-on`) says. The author must supply the address before filing; the sample carries the exemplar's wording.
- **Word count (CAAF-BRF-001).** The count is computed from the markdown body and approximates a word processor's (Rule 37(d) lets the preparer use the processor's count). The sample's count (1,833 words) is for the transcription only. The author confirms the figure before filing. The certificate prints the computed number.
- **Standard of review (CAAF-BRF-003).** The check is presence only: a heading names the standard of review. Rule 24(a) requires one per issue; a brief with two issues must show two standards. The template does not count issues.
- **Issues in bold (CAAF-BRF-004).** The template does not check bold type; the sample writes the granted issue in bold.
- **Optional sections.** "Relevant Authorities" and "References to the Record" are not generated; a brief that uses them gets no special treatment, and the required-section check is not affected by them.
- **Joint appendix (CAAF-BRF-011).** Rule 24(e) requires a separate joint appendix. It is not part of this template.
- **Sample is an excerpt.** See Layout. The Argument is cut off after point I, sub-heading B, path 1; paths 2 and beyond, point I.C and D, are not transcribed. The sample is a structural and visual reference.
- **No mechanical checks.** This doc type has no `checks.yaml` and no pass stamp; `tools/check.sh` does not run on it. Requirements above are checked by reading the render.
- **Rule currency.** Checked against the September 26, 2025 amended-through rules only.

## Engines

**typst** (`typst/`, primary; the reference for the form) and **docx** (`docx/`). No LaTeX engine.

**docx** (`docx/`): `sh docx/render.sh` (called by `tools/render-docx.sh`) runs pandoc with `docx/armfor.lua` on `docx/reference.docx`. `docx/build-reference.sh` builds the reference (EB Garamond styles, footer page numbers; byte-identical across runs). The index and the table of authorities print body page numbers, so the render runs three passes: a first render to PDF, a search of the body pages for each heading and authority link, a final render, and a second search that must give the same pages.

- Matches the typst form: EB Garamond 14 pt throughout (footnotes 14 pt, single-spaced); body lines exact 31.4 pt (double) with a 0.5 in first-line indent; letter paper, 1 in margins; the cover (caption, title, dockets, counsel block at the foot of the text area); index and table in roman numerals; the body from page 1, with the Argument numbering (I., A., 1., a.) and hanging headings; the signature kept with the last paragraph; certificates of compliance and of filing and service.
- Differs: line and page breaks are LibreOffice's (the PDF that is checked), not typst's, so the page numbers in the index and the table are those of the LibreOffice PDF; Word may paginate differently. The certificate's word count is counted from the docx text (1819); the typst render counts the markdown (1833). The author confirms the figure before filing. The cover's caption spacing is tighter. The first body footnote splits across pages 1 and 2, as in the typst render. The paragraph after the block quotation, "(JA 169).", is indented as a new paragraph in both renders (the filing has it flush; ACCEPTED in the typst Gate 2 table, row 9).
- Pages reviewed: 15 of 15 (docx PDF), each rendered at 60 dpi and looked at, with the typst pages compared.
- BLOCKED (gates cannot run, no check IDs run): `sh tools/check.sh <court-dir> --engine docx` exits 2 with `Error: open .../opening-brief/checks.yaml: no such file or directory` (this snapshot has no `checks.yaml` for this court). The `.docx` has not been opened in Microsoft Word (no Word here); LibreOffice opened it and rendered the PDF.
