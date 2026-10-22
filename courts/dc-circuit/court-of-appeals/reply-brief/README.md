# D.C. Circuit (cadc): appellant's reply brief

- Court: `cadc`, United States Court of Appeals for the District of Columbia Circuit (`courts/dc-circuit/court-of-appeals/`)
- Doc type: `reply-brief`. Reply brief of the appellant (FRAP 28(c)). One self-contained folder; no shared files touched.
- Exemplar: `usage/FILED-EXAMPLE-reply-brief.pdf` (*Rosen-Kellogg v. Mayorkas*, No. 24-5158, filed 2025-02-28; provenance in `usage/SOURCE.md`).
- Sample: `usage/INPUT-reply-brief.md`, a full transcription of the filed 16-page brief (see Known gaps for what differs).
- Status: template built; render, overlay, and a page-by-page review done (below). Not reviewed by a human. `court.json` and the court-root `typst/` and `usage/` are untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `cadc-brief`. |
| `typst/cadc-reply-brief.typ` | Template. Helpers copied from the ca9 template (cmarker body, TOC and TOA built from introspection, cover-fit loop, `toa:` links); rule parameters and certificates rewritten for the D.C. Circuit. On the shared cross-engine layout model (`lib/typst/xengine.typ`). |
| `latex/template.tex`, `latex/cadc.lua` | LaTeX engine: layout (`lib/latex/xengine.sty`) and the filter that writes the cover, tables, signature and certificates. |
| `docx/cadc.lua`, `docx/make-reference.sh`, `docx/reference.docx` | DOCX engine: the filter (`lib/docx/xengine.lua`) and the reference document built by `make-reference.sh` (`lib/docx/xengine-reference.sh`). |
| `eval.yaml` | `params.cross_engine: gate` (Gate 4). |
| `usage/INPUT-reply-brief.md` | Markdown contract sample: frontmatter plus the brief body. |
| `usage/OUTPUT-reply-brief.typst.pdf`, `.latex.pdf`, `.docx`, `.docx.pdf` | `sh tools/render.sh [--engine latex\|docx] courts/dc-circuit/court-of-appeals/reply-brief usage/INPUT-reply-brief.md` (16 pages each). |
| `usage/` | The filed exemplars and `SOURCE.md`. Overlays (`just overlay`) go to the gitignored `.overlay/`. |

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
| Cir. R. 28(a)(8) | A brief in a case scheduled for argument (or argued, or submitted without argument) says so in capital letters at the top of the front cover, with the argument date. | `cover-body`, from `oral_argument` (optional field). | Rules PDF as amended through 2025-12-04, fetched 2026-10-16: https://www.cadc.uscourts.gov/sites/cadc/files/rules-RulesFRAP20251204.pdf |
| Cir. R. 28(a)(2) | The table of authorities lists each page on which an authority is cited; "passim" or similar terms may not be used. | `toa-section`: every page, no passim path. | Same PDF, fetched 2026-10-16. |
| FRAP 32(a)(2) | Cover contents: court, case number, title, parties, counsel with address and telephone. | `cover-body`. | Cited from memory of the rule's structure; not re-fetched on 2026-10-14. Verify before relying on it. |
| FRAP 25(d) | Proof of service. | `certificate-of-service`, only when `service.certificate: true`. | Wording is template-authored; FRAP 25(d) text not re-fetched. See Known gaps. |

**Not generated, on purpose.** The exemplar has no statement of related cases, no disclosure statement, no glossary, no addendum, and no required-section order (FRAP 28(c) requires none beyond TOC and TOA). The template enforces none of them. The reply's own argument headings are free.

## What the overlay shows

`usage/OVERLAY-rosen-kellogg-reply-brief.pdf` puts our render (red) over the best-matching filed page (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only, not a score. Last run:

| Ours | Filed | Overlap | What it is |
|---|---|---|---|
| p.1 | p.1 | 85% | Cover (76% before the oral-argument line was added on 2026-10-16) |
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

Every page of `OUTPUT-reply-brief.typst.pdf` was rendered at 50 dpi (`pdftoppm -r 50`) and viewed after the port onto the cross-engine layout model (fb-595.54.2, 2026-10-22), and every page of the latex and docx renders beside it: **16 of 16 pages reviewed** in each engine. Typst printed no warnings. Fonts embedded: Times New Roman (Regular, Bold, Italic, BoldItalic) in typst and docx, TeX Gyre Termes X (its metric twin) in latex.

| PDF page | Printed | Content | Result |
|---|---|---|---|
| 1 | — | Cover: oral-argument line, number, double rule, court, caption with designations from the middle, D.C. No. and judge, brief title, counsel and telephone, double rule | OK. One page; the judge line wraps after "United States" in all three engines. |
| 2 | i | Table of Contents ("Page" underlined; point and sub-point hanging indents; page column) | OK. No page number alone on a line. |
| 3 | ii | Table of Authorities, cases *Ashcroft* to *Orr* ("Page(s)" underlined) | OK. Case names italic (FRAP 32(a)(6)); every page listed, no passim (Cir. R. 28(a)(2)). |
| 4 | iii | Table of Authorities, *Richards* to *Wisdom* | OK. |
| 5 | 1 | Summary of Argument | OK. The Argument heading chain (ARGUMENT, I., A. and two lines of text) does not fit below it and opens page 2. |
| 6 | 2 | ARGUMENT; point I; sub-point A; bullets (*Valentin*) | OK. Bullets at the margin, text half an inch in. |
| 7 | 3 | Bullets *Ketab* to *Surface Art* | OK. |
| 8 | 4 | "And compare:"; bullets *McDaniel* to *Edwards* | OK. |
| 9 | 5 | Sub-point B; B.1 (bold italic); *Willoughby*, *Foman*, *Richards*, *Precythe* | OK. |
| 10 | 6 | *Wisdom*; the *Caribbean* quotation; B.2 heading; the District Court quotation begins | OK. Quotations single-spaced, half an inch in on both sides. |
| 11 | 7 | Quotation ends; JA0221; the argument to "already have." | OK. |
| 12 | 8 | Sub-point C; the futility argument; the temporal-proximity quotation begins | OK. |
| 13 | 9 | Quotation ends; the complaint quotation with its numbered paragraph 19; JA0013; the proposed amendment | OK. Item 19 has its number in a half-inch box inside the quotation. |
| 14 | 10 | *Iqbal*/*Twombly*; CONCLUSION; signature block; date | OK. The signature block stays with the last paragraph. |
| 15 | 11 | Certificate of Compliance (2,175 words; "Times New Roman, 14-point") | OK. |
| 16 | 12 | Certificate of Service | OK. Template-authored wording (see Known gaps). |

**Length.** The body runs 10 printed pages (1-10), plus the certificates (11-12) and the front matter (cover, TOC, TOA: 4 pages), for 16 pages in all (15 before the cross-engine port, at a 25.9 pt pitch). The exemplar is 16 pages in all with the same shape: its body runs 11 pages to the conclusion, and it has no certificate of service. The sample is a full transcription, not an excerpt.

**Word count.** The template's count of the markdown body is 2,175 words; the filed certificate says 2,251. The filing's counting method is not known, so the gap is not explained. Both are under 6,500, and the certificate uses the template's count.

## Known gaps

- **Typeface (resolved 2026-10-15).** Face required: Times New Roman. The D.C. Circuit Handbook (rev. 2021, IX.A.6) names Century and Times New Roman and discourages Garamond; the filed exemplar is Times New Roman 14-point. Substitute: `Liberation Serif` (`docs/FONTS.md`; metric-compatible with Times New Roman). The template was EB Garamond before this change. Page count went from 16 to 15. Since the pinned Times New Roman files were added (`docs/FONTS.md`), typst renders Times New Roman itself, Liberation Serif being the fallback; the docx names Times New Roman and latex sets newtx, its metric twin.
- **Current Circuit Rule 32 not retrieved.** The 6,500-word figure comes from FRAP 28.1(e)(2)(C) and Cir. R. 32(e)(1) as the 2016 order states it. The current Circuit Rules PDF on `cadc.uscourts.gov` returned 404 from this box; it should be checked before the template is used for a live filing.
- **Certificate of service.** The exemplar has none. The wording is template-authored from FRAP 25(d) and the CM/ECF practice; it has not been checked against a D.C. Circuit form. It is in the sample only because the brief's structure calls for it (`service.certificate: true`).
- **Case names** are italic in the sample and template (FRAP 32(a)(6) and the Handbook). The filed brief sets them roman; that is a difference from the exemplar, following the rule.
- **Level-4 headings** are bold italic, the ca9 convention. The exemplar uses bold roman. Accepted as a style choice; no rule decides it.
- **Quotation emphasis.** The filed brief says "(emphasis added)" after the *Richards* quotation and "Underling added" after the complaint quotation, but the PDF text layer does not carry the emphasis. The sample keeps the words and the emphasis is lost; no bold or italic was reconstructed.
- **Filing typos kept.** The sample reproduces the filed text as filed, including "Becasue" in the point C heading and "Underling added" after the complaint quotation. It is a transcription, not an edited brief.
- **Not produced.** Cover colour, disk and paper-copy rules, the Cir. R. 26.1 disclosure statement, the related-cases statement, and the addendum (none appear in this reply).

## Engines

The typst template is the reference. The LaTeX and DOCX engines are built from the same markdown by `fb render`:
`sh tools/render.sh --engine latex|docx courts/dc-circuit/court-of-appeals/reply-brief usage/INPUT-reply-brief.md`.

- **latex** (`usage/OUTPUT-reply-brief.latex.pdf`, 16 pages; pdflatex, Times from newtx). `latex/cadc.lua` writes the cover, the contents and authorities (two-pass page numbers), the headings with their labels, the signature block and the certificates; `latex/template.tex` holds the layout. Word count 2,175, the typst template's count of the markdown source. Every line and page breaks where typst breaks it (see "Cross-engine").
- **docx** (`usage/OUTPUT-reply-brief.docx`, `.docx.pdf` 16 pages; LibreOffice). `docx/cadc.lua` writes the cover (rules as paragraph borders), the contents and authorities with their page numbers (fb render's two-pass page map: needles for every heading and citation), the quotations, the signature block and the certificates; Times New Roman. Word count 2,175. The earlier gaps (no cover, tables or certificates in the `.docx`, no `.docx.pdf`) are closed. Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (`docs/DOCX.md`).

## Cross-engine (fb-595.54.2)

All three engines on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/latex/xengine.sty` and `xengine.lua`, `lib/docx/xengine.lua` and `xengine-reference.sh`; docs/EVAL-LOOP.md, "Adopting the reference breaker"); `params.cross_engine: gate` in `eval.yaml`.

- typst: `show: xengine.with(pitch: 29.4pt, list-indent: 0.5in)`; line boxes of 29.4 pt (body) and 17 pt (headings, quotations, footnotes, tables, cover, signature, certificates); every space in pt (the em values it had, at 14 pt); `listing-row` contents and authorities (36 pt page column; 56 pt or the list's own width); the signature block and the cover's designations and counsel at the middle of the text width (3.25 in); the page number in a 17 pt box. The pitches changed: the template's line box (ascender to descender plus a leading) gave a 25.9 pt body pitch, 1.85 times the type size, which is under double spacing (FRAP 32(a)(4)), and a 14.2 pt single pitch, under the face's own height, which Word's exact line spacing would clip; the ca9 reference's 29.4 pt (2.1 x) and 17 pt are used. The certificate names Times New Roman, the face all three engines set (it named Liberation Serif, which no engine embeds).
- latex: `\usepackage{xengine}`, `\xe@lines`, `\addvspace`, `\xe@row`, `\xe@footnotemarks`, `\xe@lists`; filter on `require("latex.xengine")`; the ellipsis as one 1 em unit with ActualText U+2026; a quotation sets `\@totalleftmargin` and `\linewidth` so a list inside it is measured from the quotation; a citation mark leaves vertical mode first (a citation that opens a list item at the top of a page was listed a page early); headings are not split.
- docx: `reference.docx` from `make-reference.sh` (`lib/docx/xengine-reference.sh`, Times New Roman 14 pt, 588 and 340 twips); `cadc.lua` on `docx.xengine` with exact spacing, leader-tab rows, sections and footers, a word joiner in ")(" tokens.
- Before (fresh baseline, 2026-10-21): latex 13 pages against typst's 15, 52.9 % of lines with typst's break; docx 9 pages (no cover, tables or certificates), 43.5 %. After: typst 16 pages; latex and docx 16 pages, 334/334 lines, every page starting and ending on typst's words (XENG-001..003 PASS); tier 1: typst 8 passed, latex 11 passed, docx 12 passed, 0 failed. Positions (diagnostic): widths within 0.09 pt (latex) and 0.37 pt (docx); every line within 1.4 pt of typst's baseline and left edge (latex 1.4 pt and docx 0.2 pt at most on the baseline; the largest differences are on the cover).

[Formbook index](../../../../README.md) | [Status table](../../../../STATUS.md)

## Verification pass 2026-10-16 (fb-595.26.12)

- Rendered: `sh tools/render.sh .../reply-brief usage/INPUT-reply-brief.md` exits 0, no typst warnings, 15 pages (the committed PDF had been 16 pages and was stale). Overlay rerun (`tools/overlay.sh ... rosen-kellogg-reply-brief`): same page map as the table above; the cover now overlaps 85%.
- Viewed: all 15 pages at 60 dpi before the fixes, pp. 1-3 again after each fix, and all 15 pages (contact sheet) of the final render; all 15 overlay pages at 40 dpi; the exemplar's page 1 against our cover.
- Rules checked in the D.C. Circuit rules PDF (as amended through 2025-12-04; it downloaded on 2026-10-16, so the "returned 404" note under Known gaps is out of date): Circuit Rule 28(a)(8) and 28(a)(2) (rows added to the rules table).
- Fixed (tier 1): the cover had no oral-argument statement. The exemplar says "ORAL ARGUMENT SCHEDULED FOR APRIL 10, 2025" and Circuit Rule 28(a)(8) requires it. The template now prints the optional `oral_argument` field in capitals at the top of the cover (typst and latex), and the sample's frontmatter carries it.
- Fixed (tier 1): the table of authorities had a "passim" path from seven pages, which Circuit Rule 28(a)(2) forbids. It is removed (typst and latex); every page is listed, and a long list wraps inside its own column.
- Fixed (tier 2): in the table of contents, the page numbers of I.A, I.B.2 and I.C wrapped onto lines of their own. Page numbers now have their own column. The latex table of authorities printed "4,5" without a space; it now prints "4, 5".
- LaTeX re-rendered: 13 pages, builds; the cover shows the oral-argument line.
- Remaining gaps: as listed under Known gaps (the certificate of service wording is template-authored; case names are italic, unlike the filing).
