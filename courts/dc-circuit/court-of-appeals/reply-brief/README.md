# D.C. Circuit (cadc): appellant's reply brief

- Court: `cadc`, United States Court of Appeals for the District of Columbia Circuit (`courts/dc-circuit/court-of-appeals/`)
- Doc type: `reply-brief`. Reply brief of the appellant (FRAP 28(c)). One self-contained folder; no shared files touched.
- Exemplar: `exemplars/FILED-EXAMPLE-rosen-kellogg-24-5158-reply-brief.pdf` (*Rosen-Kellogg v. Mayorkas*, No. 24-5158, filed 2025-02-28; provenance in `exemplars/SOURCE.md`).
- Sample: `samples/INPUT-rosen-kellogg-reply-brief.md`, a full transcription of the filed 16-page brief (see Known gaps for what differs).
- Status: template built; render, overlay, and a page-by-page review done (below). Not reviewed by a human. `court.json` and the court-root `typst/` and `samples/` are untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `cadc-brief`. |
| `typst/cadc-reply-brief.typ` | Template. Helpers copied from the ca9 template (cmarker body, TOC and TOA built from introspection, cover-fit loop, `toa:` links); rule parameters and certificates rewritten for the D.C. Circuit. |
| `samples/INPUT-rosen-kellogg-reply-brief.md` | Markdown contract sample: frontmatter plus the brief body. |
| `samples/OUTPUT-rosen-kellogg-reply-brief.pdf` | `sh tools/render.sh courts/dc-circuit/court-of-appeals/reply-brief samples/INPUT-rosen-kellogg-reply-brief.md` (15 pages). |
| `samples/OVERLAY-rosen-kellogg-reply-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/dc-circuit/court-of-appeals/reply-brief rosen-kellogg-reply-brief`. |
| `exemplars/` | The filed exemplar and `SOURCE.md`. |

## Governing rules

No D.C. Circuit primary text for this doc type was retrieved in full, so the rules below are cited from the sources named, with the status of each stated. Date verified: 2026-10-14.

| Rule | Requirement | Where the template uses it | Verification |
|---|---|---|---|
| FRAP 28(c); FRAP 28(a)(2)-(3) | A reply brief must contain a table of contents and a table of authorities, with page references. | TOC, TOA (`toc-section`, `toa-section`). | Read on Cornell LII, `law.cornell.edu/rules/frap/rule_28`, 2026-10-14. |
| FRAP 28.1(e)(2)(A), (C); Cir. R. 32(e)(1) | Appellant's reply brief: no more than half the principal-brief type volume, i.e. 6,500 words (or 650 lines if monospaced). The template enforces 6,500 words. | `word-limit = 6500`; the build stops above it. | FRAP 28.1(e)(2) read on Cornell LII, 2026-10-14. Cir. R. 32(e)(1) read from the court's 2016 amendment order (`cadc.uscourts.gov/sites/cadc/files/rulesamend-Order20161201.pdf`); the current text of Cir. R. 32 was **not** retrieved. The 2016 order's 9,100-word figure is the intervenor limit under Cir. R. 32(e)(2)(B), not the party limit. |
| FRAP 32(a)(4) | 8½ × 11 paper; double-spaced; quotations over two lines may be indented and single-spaced; headings and footnotes may be single-spaced; margins at least 1 inch on all four sides. | `page-margin = 1in`, `body-leading`, `single-leading`, block quotes. | Read on Cornell LII, 2026-10-14. |
| FRAP 32(a)(5) | Proportionally spaced face with serifs (sans-serif allowed only in headings and captions), at least 14-point. | `type-size = 14pt`, footnotes 14 pt, `font-family`. | Read on Cornell LII, 2026-10-14. |
| D.C. Cir. Handbook IX.A.6 (revised 3/16/2021; Clerk's notice of the same date) | Serif, 14-point or larger; Century and Times New Roman encouraged; **Garamond discouraged**; monospaced at most 10½ characters per inch; double-spaced; one side only. | Face: Times New Roman → `Liberation Serif` (`docs/FONTS.md`; metric-compatible). See Known gaps. | Notice PDF read from `cadc.uscourts.gov/sites/cadc/files/noticeGen-noticePreferredTypefacesForBriefs.pdf` (2026-10-14). The current Handbook text was not retrieved; it may have changed since 2021. |
| FRAP 32(a)(6) | Plain roman type; italics or boldface for emphasis; case names italic. | Case names italic in the sample; `emph` in TOA. | Read on Cornell LII, 2026-10-14. |
| FRAP 32(f) | Excluded from the count: cover, disclosure statement, TOC, TOA, oral-argument statement, addendum of statutes, certificate of counsel, signature block, proof of service. | `count-words` counts only the markdown body (everything the author types). Cover, TOC, TOA, certificates and signature are generated, not counted. | Read on Cornell LII, 2026-10-14. |
| FRAP 32(g)(1) | A certificate of compliance stating the word count (or line count), signed by counsel. | `certificate-of-compliance`; the count comes from `count-words`, not typed. | Read on Cornell LII, 2026-10-14. |
| FRAP 32(a)(2) | Cover contents: court, case number, title, parties, counsel with address and telephone. | `cover-body`. | Cited from memory of the rule's structure; not re-fetched on 2026-10-14. Verify before relying on it. |
| FRAP 25(d) | Proof of service. | `certificate-of-service`, only when `service.certificate: true`. | Wording is template-authored; FRAP 25(d) text not re-fetched. See Known gaps. |

**Not generated, on purpose.** The exemplar has no statement of related cases, no disclosure statement, no glossary, no addendum, and no required-section order (FRAP 28(c) requires none beyond TOC and TOA). The template enforces none of them. The reply's own argument headings are free.

## What the overlay shows

`samples/OVERLAY-rosen-kellogg-reply-brief.pdf` puts our render (red) over the best-matching filed page (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only, not a score. Last run:

| Ours | Filed | Overlap | What it is |
|---|---|---|---|
| p.1 | p.1 | 76% | Cover |
| p.2 | p.2 | 90% | TOC |
| p.3 | p.3 | 72% | TOA, first page (cases) |
| p.4 | p.4 | 50% | TOA, second page; the exemplar's TOA is two pages too, so the pairing is by content, not length |
| p.5 | p.5 | 59% | Summary of Argument; point I; sub-point A |
| p.6 | p.7 | 50% | Counsel's bullets (Valentin, Ketab, Monroe) |
| p.7 | p.8 | 71% | Bullets (Orr to Rousset) |
| p.8 | p.9 | 58% | Edwards; sub-point B; B.1; Willoughby, Foman, Richards |
| p.9 | p.11 | 46% | Wisdom; Caribbean block quote; B.2 heading; the District Court quotation |
| p.10 | p.12 | 71% | The District Court's order; sub-point C heading; the futility argument |
| p.11 | p.13 | 79% | Temporal-proximity quotation; complaint quotation (¶ 19) |
| p.12 | p.14 | 68% | Proposed amended complaint; Iqbal and Twombly |
| p.13 | p.15 | 83% | Conclusion; signature block |
| p.14 | p.16 | 43% | Certificate of compliance (filed p.16 is the exemplar's certificate) |
| p.15 | p.1 | 14% | Certificate of service (the exemplar has none; no real match) |

The pairings are close throughout. The typeface is now the metric-compatible substitute for the filing's Times New Roman (Liberation Serif), so the visible differences are the italic case names (FRAP 32(a)(6); the filed brief sets them roman), and the bold-italic level-4 headings (the ca9 convention; the filing uses bold roman).

## Page review (Gate 2)

Every page of `OUTPUT-rosen-kellogg-reply-brief.pdf` was rendered at 60 dpi (`pdftoppm -r 60`) and viewed after the font change (2026-10-15): **15 of 15 pages reviewed**. Typst printed no warnings. Fonts embedded: Liberation Serif (Regular, Bold, Italic, BoldItalic) only.

| PDF page | Printed | Content | Result |
|---|---|---|---|
| 1 | — | Cover: court, caption, D.C. No. and judge, brief title, counsel | OK. Fits one page; the judge line wraps. |
| 2 | i | Table of Contents (point and sub-point hanging indents; page column) | OK. |
| 3 | ii | Table of Authorities, cases (first page) | OK. Case names italic (FRAP 32(a)(6)). |
| 4 | iii | Table of Authorities, cases (second page) | OK. |
| 5 | 1 | Summary of Argument; ARGUMENT; point I; sub-point A | OK. |
| 6 | 2 | Counsel's bullets (Valentin, Ketab, Monroe) | OK. |
| 7 | 3 | Bullets (Orr to Rousset) | OK. Escaped asterisks in "at \*2" render as literal asterisks. |
| 8 | 4 | Rousset, continued; Edwards; sub-point B; B.1; Willoughby, Foman, Richards | OK. Level-4 heading "1." in bold italic (ca9 convention; see Known gaps). |
| 9 | 5 | Wisdom; Caribbean block quote; Rule 15(a) block; point B.2 heading; the District Court quotation | OK. |
| 10 | 6 | JA0221 passage; sub-point C heading; the futility argument | OK. |
| 11 | 7 | The District Court's temporal-proximity quotation; complaint quotation (¶ 19) | OK. |
| 12 | 8 | Proposed amended complaint; Iqbal/Twombly | OK. |
| 13 | 9 | Conclusion heading; Respectfully submitted; signature block; date | OK. The signature block stays with the last paragraph. |
| 14 | 10 | Certificate of Compliance (word count 2,175; typeface sentence "Liberation Serif, 14-point") | OK. Typeface sentence is literal text (see the build note below). |
| 15 | 11 | Certificate of Service | OK. Template-authored wording (see Known gaps). |

**Build issue fixed during review.** An earlier render of the certificate page embedded `DejaVuSansMono`, a fallback font, because the typeface sentence interpolated the length value `type-size` into the content. That line is now literal text ("Liberation Serif, 14-point"), and the rebuilt PDF embeds only Liberation Serif.

**Length.** The body runs 9 printed pages (1-9), plus the certificates (10-11) and the front matter (cover, TOC, TOA: 4 pages), for 15 pages in all. In EB Garamond the body was 10 pages and the total 16. The exemplar is 16 pages in all with the same shape: its body runs 11 pages to the conclusion, and it has no certificate of service. The sample is a full transcription, not an excerpt.

**Word count.** The template's count of the markdown body is 2,175 words; the filed certificate says 2,251. The filing's counting method is not known, so the gap is not explained. Both are under 6,500, and the certificate uses the template's count.

## Known gaps

- **Typeface (resolved 2026-10-15).** Face required: Times New Roman. The D.C. Circuit Handbook (rev. 2021, IX.A.6) names Century and Times New Roman and discourages Garamond; the filed exemplar is Times New Roman 14-point. Substitute: `Liberation Serif` (`docs/FONTS.md`; metric-compatible with Times New Roman). The template was EB Garamond before this change. Page count went from 16 to 15.
- **Current Circuit Rule 32 not retrieved.** The 6,500-word figure comes from FRAP 28.1(e)(2)(C) and Cir. R. 32(e)(1) as the 2016 order states it. The current Circuit Rules PDF on `cadc.uscourts.gov` returned 404 from this box; it should be checked before the template is used for a live filing.
- **Certificate of service.** The exemplar has none. The wording is template-authored from FRAP 25(d) and the CM/ECF practice; it has not been checked against a D.C. Circuit form. It is in the sample only because the brief's structure calls for it (`service.certificate: true`).
- **Case names** are italic in the sample and template (FRAP 32(a)(6) and the Handbook). The filed brief sets them roman; that is a difference from the exemplar, following the rule.
- **Level-4 headings** are bold italic, the ca9 convention. The exemplar uses bold roman. Accepted as a style choice; no rule decides it.
- **Quotation emphasis.** The filed brief says "(emphasis added)" after the *Richards* quotation and "Underling added" after the complaint quotation, but the PDF text layer does not carry the emphasis. The sample keeps the words and the emphasis is lost; no bold or italic was reconstructed.
- **Filing typos kept.** The sample reproduces the filed text as filed, including "Becasue" in the point C heading and "Underling added" after the complaint quotation. It is a transcription, not an edited brief.
- **Not produced.** Cover colour, disk and paper-copy rules, the Cir. R. 26.1 disclosure statement, the related-cases statement, and the addendum (none appear in this reply).

## Engines

The typst template is the reference. The LaTeX and DOCX engines are built from the same markdown.

Build commands, from the repo root:

- LaTeX (tectonic; reruns until the contents and authorities settle):
  `sh courts/dc-circuit/court-of-appeals/reply-brief/latex/render.sh courts/dc-circuit/court-of-appeals/reply-brief samples/INPUT-rosen-kellogg-reply-brief.md courts/dc-circuit/court-of-appeals/reply-brief/samples/OUTPUT-rosen-kellogg-reply-brief.latex.pdf`
- DOCX (run from the court folder):
  `pandoc --from markdown+smart --to docx --reference-doc=docx/reference.docx --lua-filter=docx/cadc.lua samples/INPUT-rosen-kellogg-reply-brief.md -o samples/OUTPUT-rosen-kellogg-reply-brief.docx`

**LaTeX matches the typst output (tier 1):** Liberation Serif 14 pt from `fonts/`, 1 in margins, body line pitch 25.9 pt and single 14.2 pt (measured on the typst render; body lines agree within 1 pt), cover in the same order and positions, roman contents and authorities, arabic body from 1, Certificate of Compliance with the template's count (2,175 words, the same count as typst, computed by `render.sh` from the markdown), Certificate of Service, signature block kept with the last paragraph, I. / A. / 1. / a. heading labels under "Argument", 14 pt footnotes.

**LaTeX differs from typst:**
- The summary paragraph breaks into 13 lines against typst's 14 (one word moves at the end of a line); the rest of the body follows, so the body is 8 pages against typst's 9 and the whole brief is 13 pages against 15 (the table of authorities is one page here against two in typst).
- Table of authorities: each entry flows as "name, citation" in one paragraph; typst puts the citation on the line after the name.
- A heading after a heading is about 2.5 pt closer than typst's collapsed space.
- Contents and authorities page numbers and the Conclusion's page number follow the LaTeX pagination (the build checks that they settle).

**DOCX (BLOCKED):** LibreOffice is not available on this box (`soffice` is not installed; the extracted build fails with a UNO DeploymentException), so no `.docx.pdf` exists. The Gate 0 and Gate 1 checks that run on the `.docx.pdf` are BLOCKED for this reason; the `.docx` itself passes `unzip -tq` and `xmllint --noout` on every XML and rels part. Also BLOCKED or not produced in the `.docx`:
- Cover, table of contents, table of authorities, Certificate of Compliance and Certificate of Service are not generated (pandoc writes the body only). The word count, the typeface statement and the certificates are therefore not checked in the `.docx`.
- The 6,500-word reply limit (FRAP 28.1(e)(2)(C)) is checked by the typst and LaTeX engines only.
- The `.docx` declares Liberation Serif; Word substitutes silently if it is not installed on the machine that opens the file.
- Heading labels (I., A., 1., a.) are written as text by `docx/cadc.lua`, not as Word numbering; the contents field is not generated.

[Formbook index](../../../../README.md) | [Status table](../../../../STATUS.md)
