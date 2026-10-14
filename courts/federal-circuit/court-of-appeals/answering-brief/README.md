# Federal Circuit: answering brief (brief for the appellee)

Doc type: `answering-brief`. Court: `cafc` (Court of Appeals for the Federal Circuit).
Status: full-depth template built from one filed exemplar; the sample renders to 13 pages.
Not a court-level `court.json` status change: this folder does not set `status` (only David does).

## Layout

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-in-re-ablynx-26-1333-answering-brief.pdf` | Brief for Appellee, Director of the USPTO, *In re Ablynx N.V., Sanofi*, No. 26-1333, filed 2026-08-14 (38 pp.). Provenance in `exemplars/SOURCE.md`. |
| `samples/INPUT-ablynx-answering-brief.md` | Markdown transcription (front matter + a portion of the body, Statement of the Issue through Conclusion, with the signature and both certificates). |
| `samples/OUTPUT-ablynx-answering-brief.pdf` | `sh tools/render.sh courts/federal-circuit/court-of-appeals/answering-brief samples/INPUT-ablynx-answering-brief.md` (13 pages). |
| `samples/OVERLAY-ablynx-answering-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/federal-circuit/court-of-appeals/answering-brief ablynx-answering-brief` (red = our render, blue = exemplar). |
| `typst/main.typ` | Entry point; reads `--input sample=...`, splits the frontmatter, calls the template. |
| `typst/cafc-answering-brief.typ` | Template `cafc-brief(meta, md)`. Structure copied from `courts/ninth-circuit/court-of-appeals/typst/ca9-brief.typ`; numbers and forms are the Federal Circuit's. |

## Governing rules

Each entry: the rule, the primary text I could read, and what is and is not verified.

| Rule | What it requires here | Source read | Verified |
|---|---|---|---|
| FRAP 32(a)(5)(A) | Proportionally spaced serif face, 14-point or larger. Template: EB Garamond 14 pt everywhere. | Cornell LII, `law.cornell.edu/rules/frap/rule_32`, fetched 2026-10-14 | Text yes; not checked against the current official FRAP PDF |
| FRAP 32(a)(6) | Plain roman style; case names italicized. | same | same |
| FRAP 32(a)(4) | Margins of at least one inch (template: 1 in). Double spacing for text, single for headings, quotations, footnotes. | same (the LII text of (a)(4) was not captured; the margin and spacing are from the exemplar and standard practice) | Partial: spacing matched to exemplar, margin from exemplar |
| Fed. Cir. R. 32(b) | Principal brief type-volume limit: 14,000 words (30-page safe harbor). Template: `word-limit = 14000`. The certificate of compliance cites "Fed. Cir. R. 32(b)". | The exemplar's own certificate cites Fed. Cir. R. 32(b). The 14,000 figure comes from a third-party mirror (courtrules.net, Rule 32). | Citation: yes (exemplar). Number: **not verified** at cafc.uscourts.gov, which returned HTTP 404 and a bot challenge to my requests. |
| Fed. Cir. R. 47.4 / Form 9 (Certificate of Interest) | Filed separately with entry of appearance; not generated in the brief. | Not read | **Not verified**; omitted by design, not in the sample |
| Fed. Cir. R. 47.5 (Statement of Related Cases) | Text is supplied by the sample, not generated; the exemplar has the statement on the page before the body. | Exemplar | Exemplar only |
| Pagination (exemplar) | Front matter in lower-case roman (i, ii, iii); body in Arabic from 1; cover unnumbered. | Exemplar | Exemplar only |

Not verified: whether any Federal Circuit rule amendments after the mirror's text changed the word limit or the cover contents. Re-check against the official rules before relying on the 14,000 figure.

## What the overlay shows

The overlay pairs each sample page with the exemplar page sharing the most words. The sample is a portion of a 38-page brief, so most pages overlap only partly (word-overlap 33–92%, see `OVERLAY-ablynx-answering-brief.txt`). The cover (92%) and the Statement of the Issue (89%) line up closely. Red-only text is the sample's transcription beyond the exemplar's words; blue-only text is exemplar content the sample does not reproduce (the omitted Statement of the Case, Argument B.2–B.3, the chart and figures).

Measured line pitch on a body page: exemplar 32.2 pt, sample 32.1 pt (body leading `0.99em` with 14 pt type). The first render used `0.94em` and gave 31.4 pt; I changed it to match the exemplar. Page count stayed at 13.

## Pages reviewed (Gate 2 record)

All 13 rendered pages were rendered at 60 dpi and looked at, in their final state.

| Page | Content | Result |
|---|---|---|
| 1 | Cover (case number, caption, proceeding, title, counsel, date) | Fits one page; no defects. The court line wraps naturally ("UNITED STATES COURT OF APPEALS FOR THE FEDERAL CIRCUIT" on one line at 14 pt bold; no forced break). |
| 2 | Table of Contents (i) | Entries, dot leaders, page numbers match the body (checked against pages 1, 2, 3, 4, 6, 7). |
| 3 | Table of Authorities (ii) | Cases, Statutes groups. Fallaux shows "2, 4, 6". |
| 4 | Statement of Related Cases (iii) | Heading and paragraphs; no defects. |
| 5–11 | Body pp. 1–7 | Numbered headings (I.–V., A., B., 1.), footnotes at 14 pt, block of bullets, signature block kept with the Conclusion. |
| 12 | Certificate of Compliance (body p. 8) | Word count (1,330, computed from the markdown) and the FRAP 32(a)(5)–(6) sentence. |
| 13 | Certificate of Service (body p. 9) | Generic CM/ECF wording (see gaps). |

Pages 6 and 7 were the ones that moved when the leading changed; they were re-checked after the change.

## Known gaps (not defects of this template; recorded so they are not missed)

- **Portion, not the whole brief.** The sample transcribes the Statement of the Issue, the Statement of the Case (sections A and B, first paragraphs), the Summary, Argument standard of review and B.1 (with its bullets), and the Conclusion. The Argument after B.1, the Statement of the Case's chart, and the figures are omitted. The sample is 13 pages; the exemplar is 38.
- **No figures.** cmarker does not render images or charts; the exemplar's timeline figures and filed chart are not reproduced.
- **No addendum.** The Federal Circuit's addendum (if any) is not generated; the ca9 addendum scaffold was dropped.
- **No CM/ECF header.** The "Case: 26-1333 Document: 23 Page: N Filed: date" line at the top of each filed page is generated by the e-filing system and is not reproduced.
- **Certificate of service wording** is a convention: the exemplar has no certificate of service, and the sample includes one with generic CM/ECF language. Its rule citation is not verified.
- **Certificate of Interest (Form 9)** is not generated (see the table above).
- **Signature.** The certificate reuses the sample's signature lines; the exemplar's certificate lists only the signer's title and office. The template prints `certificate_lines` separately so the two can differ.
- **Statement of Related Cases** is text supplied by the sample; the template does not generate it from a form.
- **Word count** is computed from the markdown body (headings, text, footnotes, quotations; not list markers or footnote marks), not from a word processor; the certificate names the word processor the sample supplies (`word_counter`).
- **Exemplar text layer** is from a paper-capture producer; pdftotext extracts it, but the transcription was checked by eye against the page images, not against an OCR-free source.
- **Second exemplar** is not included; the brief asked for one exemplar per doc type and the ca9 two-filer rule is a court-level check, not this folder's.
- The template's `word-limit` and certificate wording depend on the unverified Fed. Cir. R. 32(b) figure above.

## Rendering

Typst 0.15.0, EB Garamond (vendored in `fonts/eb-garamond/`), cmarker 0.1.10 (vendored in `vendor/typst-packages/`). `tools/render.sh` runs with `--ignore-system-fonts`; the build emitted no warnings.
