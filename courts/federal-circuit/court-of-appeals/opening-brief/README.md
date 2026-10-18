# Federal Circuit (cafc): opening brief (appellant's principal brief)

- Court: `cafc`, United States Court of Appeals for the Federal Circuit (`courts/federal-circuit/court-of-appeals/`)
- Doc type: `opening-brief`. Brief of Appellant (FRAP 28(a); Fed. Cir. R. 28(a)); one self-contained folder, no shared files.
- Exemplar: `usage/SAMPLE-cafc-opening-brief-delfasco241363.pdf` (*Delfasco LLC v. Secretary of the Army*, No. 24-1363, filed 2024-03-26; provenance in `usage/SOURCE.md`).
- Sample: `usage/INPUT-cafc-opening-brief-delfasco.md` (transcription of the filed brief, excerpted; see Known gaps).
- Status: template built; render, overlay and page review done (below). Not reviewed by a human; `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `cafc-brief`. |
| `typst/cafc-opening-brief.typ` | Template. Parameter block at the top: `doc-kind`, `word-limit` (14,000), `required-sections` (Fed. Cir. R. 28(a)(5)-(10) order), `needs-standard-of-review`, `addendum = "required"`. |
| `usage/INPUT-cafc-opening-brief-delfasco.md` | Markdown contract sample (frontmatter + body). |
| `usage/OUTPUT-cafc-opening-brief-delfasco.typst.pdf` | `sh tools/render.sh courts/federal-circuit/court-of-appeals/opening-brief usage/INPUT-cafc-opening-brief-delfasco.md` (21 pages). |
| `usage/OVERLAY-delfasco-opening-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/federal-circuit/court-of-appeals/opening-brief delfasco-opening-brief` (red = ours, blue = filed, black = agree). |
| `usage/` | The filed exemplar and `SOURCE.md`. |

Typst is run by `tools/render.sh` with vendored fonts only (`--ignore-system-fonts`); the sample's embedded fonts are EB Garamond Regular, Italic, Bold, BoldItalic, and nothing else. The build emitted no warnings.

## Governing rules

Primary sources, both fetched 2026-10-14:

- **Federal Circuit Rules of Practice, dated October 6, 2026** (the court's current compilation, 239 pp.), <https://www.cafc.uscourts.gov/wp-content/uploads/RulesProceduresAndForms/FederalCircuitRules/FederalCircuitRulesofPractice.pdf>. Rule page numbers below are the compilation's printed pages.
- **Federal Circuit Forms 9, 19, 30** (Certificate of Interest, March 2023; Certificate of Compliance with Type-Volume Limitations, July 2020; Certificate of Service, July 2020), from <https://www.cafc.uscourts.gov/home/rules-procedures-forms/court-forms/>.

FRAP text is taken from the same compilation (its Federal Rules of Appellate Procedure section).

| Rule | Requirement | Where the template uses it |
|---|---|---|
| Fed. Cir. R. 32(a)(1); FRAP 32(a)(2)(A)-(F) | Cover: case number centered at top; court name; the clerk's official caption; nature of the proceeding and the tribunal below; brief title; counsel name, office address, telephone | `cover-body` |
| FRAP 32(a)(2) (cover color) | Appellant's brief blue, paper copies only; electronic copies need not follow it (footnote) | not produced (see Known gaps) |
| FRAP 32(a)(4); Fed. Cir. R. 32(e) | 8½ × 11; double-spaced; quotations over two lines indented and single-spaced; headings and footnotes may be single-spaced; margins ≥ 1 in; page numbers centered at bottom | `page`, `body-leading`, `page-margin`, `quote` and footnote styles, `number-align: center` |
| FRAP 32(a)(5)(A); Fed. Cir. R. 32 Practice Notes (Footnotes) | Proportionally spaced serif face, 14-point or larger; applies to footnotes | `type-size = 14pt` everywhere, footnotes included |
| FRAP 32(a)(6) | Plain roman; italics or boldface for emphasis; case names italic | markdown emphasis; the template does not guess case names |
| Fed. Cir. R. 32(b)(1); FRAP 32(a)(7)(B)(i) (as enlarged) | Principal brief: 14,000 words (or 1,300 monospaced lines) | `word-limit = 14000`; the build stops when the count is higher |
| Fed. Cir. R. 32(b)(2); FRAP 32(f) | Not counted: certificate of interest, statement of related cases, addendum, cover, disclosure, TOC, TOA, oral-argument statement, certificates, signature block, proof of service | `strip-oral-argument`; front matter, addendum and certificates are outside the markdown body |
| Fed. Cir. R. 28(a)(1)-(12) | Order: certificate of interest (1); TOC (2); TOA (3); statement of related cases (4); jurisdictional statement (5); issues (6); case (7); summary (8); argument, with standard of review under its own heading (9); conclusion and relief sought (10); addenda (11); certificate of compliance (12) | `required-sections`; `needs-standard-of-review`; the order of the front and back matter |
| Fed. Cir. R. 47.4(a)-(b); Form 9 | Certificate of interest, items (1)-(6), negative answers stated; in each principal brief | `certificate-of-interest` (item text as Form 9 and 47.4(a)) |
| Fed. Cir. R. 47.5(a)-(b); Fed. Cir. R. 28(a)(4) | Statement of related cases: prior appeals (title, number, date, panel, reporter cite) and pending cases | `related-cases-page`, from the frontmatter |
| Fed. Cir. R. 28(c)(1)(A), 28(a)(11) | Addendum with all judgments, orders, agency actions or decisions appealed from and their supporting opinions or findings, bound with the brief | `addendum = "required"`; the addendum follows the body and precedes the certificates, with its own contents list and `Add-` pagination |
| Fed. Cir. R. 32(b)(3); FRAP 32(g); Form 19 | Certificate of compliance: required for a brief over the page limit; Form 19 (or FRAP Form 6) satisfies it (Practice Notes to Rule 32) | `certificate-of-compliance`: Form 19 wording, word count from the markdown |
| FRAP 25(d); Fed. Cir. R. 25(e); Form 30 | Proof of service only when service is outside the electronic filing system (Form 30 note) | `certificate-of-service`, only with `service.certificate: true` |
| FRAP 32(d); Fed. Cir. R. 32(g) | Signature by the party or an attorney of record | `signature-block`, after the conclusion |

## Overlay

`usage/OVERLAY-delfasco-opening-brief.pdf` puts our render (red) over the best-matching exemplar page (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only, not a score. Pairings from the last run (word overlap in parentheses):

- p.1 ↔ filed p.27 (64%): the filed addendum cover repeats the caption and proceeding lines.
- p.2 ↔ p.2 (91%), p.3 ↔ p.3 (61%), p.4 ↔ p.4 (46%): certificate of interest, contents, authorities.
- p.5 ↔ p.4 (14%): the second TOA page; the filed brief's TOA is one page.
- p.6 ↔ p.5 (81%), p.7-p.9 ↔ pp.6-8 (58-85%): statement of related cases and the body. The body text lines up with the same passages.
- p.10-p.15 ↔ pp.10-15 (47-76%): the same passages in the same order.
- p.16 ↔ p.18 (56%), p.17 ↔ p.26 (32%): argument end and conclusion, with the signature block.
- p.18-p.19 ↔ p.36 (20%): addendum contents and the addendum's decision text (the sample has only a placeholder for it).
- p.20 ↔ p.37 (19%), p.21 ↔ p.38 (59%): certificate of compliance and certificate of service.

## Page review (Gate 2)

Every page of `OUTPUT-cafc-opening-brief-delfasco.typst.pdf` was rendered at 60 dpi (`pdftoppm -r 60`) and viewed (21 of 21). Pages 2 and 20 were fixed after the first review (duplicate periods in the certificate of interest; missing paragraph break in the Form 19 certificate) and viewed again.

| Page | Content | Result |
|---|---|---|
| 1 | Cover | OK. Case number, court, caption, proceeding, title, counsel; fits one page. |
| 2 | Certificate of interest (i) | OK after fix. Items 1-5 with Form 9 wording; signature. |
| 3 | Table of contents (ii) | OK. Front matter and body headings with page columns; Add-1 for the addendum. |
| 4 | Table of authorities (iii) | OK. Cases, sorted; "Page(s)" column. |
| 5 | Table of authorities, continued (iv); Statutes | OK. |
| 6 | Statement of related cases (v) | OK. Fed. Cir. R. 47.5 wording for "none". |
| 7 | Jurisdictional statement; statement of the issue; statement of the case begins | OK. |
| 8 | Statement of the case (continued) | OK. |
| 9 | Statement of the case (continued), footnote 1 | OK. |
| 10 | Statement of the case (continued), footnotes 2 and 3 | OK. |
| 11 | Summary of the argument | OK. |
| 12 | Summary of the argument (continued) | OK. |
| 13 | Argument: point I (standard of review), block quotation | OK. |
| 14 | Argument: block quotation continued; point II begins | OK. |
| 15 | Argument: point II | OK. |
| 16 | Argument: point II, block quotation, footnote 4 | OK. |
| 17 | Conclusion and relief sought; signature block | OK. |
| 18 | Addendum (Add-1): contents | OK. |
| 19 | Addendum (Add-2): decision placeholder | OK. Placeholder text is labelled as a sample note. |
| 20 | Certificate of compliance with type-volume limitations (12) | OK after fix. Form 19 layout; 2,484 words checked; box drawn. |
| 21 | Certificate of service (13) | OK. |

## Known gaps and decisions

- **Sample is an excerpt.** Argument II stops after the agency-website passage and Argument III is not transcribed. The filed addendum (the ASBCA decision) is a placeholder. The sample covers cover, certificate of interest, contents, authorities, related cases, jurisdiction through Argument II, conclusion, signature, and both certificates. Case names, citations and APPX references are transcribed as printed; OCR errors in the exemplar's text layer were corrected from context (e.g. "M117-76" printed as "Ml(-76" is set as "MK-76"; "Contel" for "Conte!"; "Arkansas Natural Gas Corp." for the OCR "Arkansas Gas Cmp.").
- **Length above the target.** The render is 21 pages: front matter 6 (cover, certificate of interest, contents, two pages of authorities, related cases), body 11, addendum 2 (the sample's placeholder), certificates 2. The brief's own 8-14 target is exceeded by the front matter and the certificates, which the rules require or the exemplar carries. The body alone is 11 pages.
- **Cover color.** FRAP 32(a)(2): blue for the appellant's paper copies only; not produced here.
- **Certificate of compliance included although not required.** Fed. Cir. R. 32(b)(3) requires it only for a brief over the page limit. The template generates it to match the exemplar; the Form 19 wording is reproduced, the word count is computed from the markdown, and the other two Form 19 options are left blank for the filer.
- **Certificate of service.** Fed. Cir. R. 25(e) requires proof of service only for service outside CM/ECF (Form 30). The template prints ECF-service wording (as the exemplar does) when `service.certificate: true`. For paper or other service, the `unregistered` list prints U.S. Mail wording; Form 30's full layout is not reproduced.
- **Addendum placement.** Fed. Cir. R. 28(a)(11)-(12) puts the addendum before the certificate of compliance. The exemplar does the same. The certificates continue the body's arabic pagination.
- **Typeface.** The exemplar is set in Times; the template uses EB Garamond at 14 pt, a proportionally spaced serif face (FRAP 32(a)(5)(A)). This is a choice of face, not a rule difference.
- **Oral argument statement.** Not in the sample. If a brief includes one, the template removes it from the word count (FRAP 32(f)).
- **Not verified.** The cover's exact placement of counsel block and phone for the Federal Circuit is taken from the exemplar and FRAP 32(a)(2)(F); the Federal Circuit's own cover form is not in the compilation.

## Engines

The typst template is the reference. The LaTeX and docx engines are built from the same markdown contract (`docs/EVAL-LOOP.md`, "Engines").

| Engine | Files | Output (`usage/`) | Pages |
|---|---|---|---|
| typst (reference) | `typst/` | `OUTPUT-cafc-opening-brief-delfasco.typst.pdf` | 21 |
| latex | `latex/template.tex`, `latex/cafc.lua`, `latex/render.sh` (tectonic, EB Garamond from `fonts/eb-garamond`) | `OUTPUT-cafc-opening-brief-delfasco.latex.pdf` | 21 |
| docx | `docx/reference.docx` (made by `docx/make-reference.sh` from `docx/styles.xml.in`), `docx/cafc-docx.lua`, `docx/render.sh`, `docx/pages.sh` | `OUTPUT-cafc-opening-brief-delfasco.docx` and `.docx.pdf` (LibreOffice 26.8, vendored fonts only) | 21 |

**Matches the typst layout (latex and docx):** 14 pt EB Garamond throughout, footnotes included; double spacing at the typst baseline pitch (31.43 pt); 1 in margins; the clerk's caption, certificate of interest, contents and authorities with page numbers; Argument labels (I. / A. / 1. / a.); the addendum with its own contents and `Add-` pages; the certificate of compliance (Form 19 wording, box checked) and the certificate of service; page numbers in the footer (roman, arabic, `Add-`).

**Differs from the typst layout:**

- Pagination. The LaTeX file has point II of the Argument on page 9 (typst: 8); its other headings are within a line or two of typst's pages. The contents and authorities give the numbers of their own render, so they follow it.
- docx contents and authorities are static text with page numbers from a LibreOffice render (the file is rendered, the numbers read from the PDF, and the file is written again until they stop changing). LibreOffice does not honor TA fields (`docs/DOCX.md`), and Word may paginate differently, so the numbers can be off by a page in Word.
- docx table of authorities finds a citation by the text the brief writes for it. A bare `Id.` or a pinpoint-only short cite is not located, so such pages are not listed.
- docx word count is pandoc's tokenization: 2,481 for the certificate, against 2,484 from typst.

**docx items not verified:** the file was converted by LibreOffice and not opened in Word. Font substitution was checked from the PDF (`pdffonts`: EB Garamond, plus DejaVu Sans for the checkbox glyph).

**Status:** latex render ok; docx render ok. No `checks.yaml` or `check.sh` exists for this court in this snapshot, so no gate was run on either engine; the page review below is visual only.

**Pages viewed:** all 21 pages of the latex and docx renders, at 30 to 40 dpi, in the final state.

## Verification pass 2026-10-16 (fb-595.26.13)

- Rendered: `sh tools/render.sh courts/federal-circuit/court-of-appeals/opening-brief usage/INPUT-cafc-opening-brief-delfasco.md`, exit 0, no typst warnings, 21 pages (same as the committed PDF; the earlier page count was not stale). Overlay rerun: `sh tools/overlay.sh ... delfasco-opening-brief`, exit 0; pairings as listed under Overlay (cover ↔ filed addendum cover 64%, certificate of interest 91%, body pages 47–85%).
- Viewed: all 21 pages at 60 dpi, then pages 2, 6, 15 and 21 again after the fixes; the overlay pages at 40 dpi; the exemplar's page 1 against our cover (same parts in the same order; the filed cover also prints the Board judges and the date, not reproduced, tier 3).
- Fixed:
  - Certificate of interest, statement of related cases and certificate of service signed "Is/ John J. O'Brien": the template hard-coded an OCR misreading of "/s/". Now "/s/" (typst and latex).
  - Numbered certificate items (pp. 2, 6): continuation lines hung 0.5 in, deeper than the item text. The number now sits in a fixed 0.3 in box and wrapped lines align with the text.
  - Sample, Argument II (p. 15): nested quotations `"'When … provisions.'"` and `"'the … provisions,'"` were curled wrongly by smart punctuation (closing quote printed as opening and vice versa). Set with explicit curly quotes in the markdown.
- Added: optional `patent_claims` (list of markdown paragraphs) and `patent_claims_heading` frontmatter. When present, the claims print on unnumbered page(s) right after the cover, single-spaced (Fed. Cir. R. 32(a)(3), Federal Circuit Rules of Practice, Oct. 6, 2026 compilation, p. 145, fetched 2026-10-16). Not in this sample (contract appeal); checked with a throwaway sample (22 pages, claims on page 2, then the certificate of interest), not committed.
- LaTeX re-rendered (21 pages, `/s/` in all certificates). docx not re-rendered (no LibreOffice on this box): `docx/cafc-docx.lua` still prints "Is/" and the committed `.docx`/`.docx.pdf` carry it; the docx has no claims page and the old certificate-item indent.
- Remaining gaps: as under Known gaps (excerpted sample, addendum placeholder, Form 30 layout not reproduced).

[Formbook index](../../../../README.md)
