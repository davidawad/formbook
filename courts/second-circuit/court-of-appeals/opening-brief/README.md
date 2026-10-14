# Second Circuit: appellant's opening brief (typst)

Status: template built and rendered; one exemplar; tier 2 provisional (one filer only). Not gated by `checks.yaml` (no checks for this doc type yet).

## Governing rules

| ID | Requirement | Source | Verified |
|---|---|---|---|
| CA2-FORM-001 | Paper: 8½ × 11 in. | FRAP 32(a)(4) (https://www.law.cornell.edu/rules/frap/rule_32) | 2026-10-14 |
| CA2-FORM-002 | Margins: at least 1 in. on all four sides | FRAP 32(a)(4) | 2026-10-14 |
| CA2-FORM-003 | Cover: case number centered at top; name of court; case title; nature of proceeding and court below; brief title naming the party; counsel name, office address, telephone | FRAP 32(a)(2)(A)–(F) | 2026-10-14 |
| CA2-FORM-004 | Proportionally spaced serif face, 14-point or larger, text and footnotes; plain roman with italics or bold for emphasis | FRAP 32(a)(5)(A), 32(a)(6) | 2026-10-14 |
| CA2-LEN-001 | Principal brief: no more than 14,000 words (30 pages) | 2d Cir. Local Rule 32.1(a) (https://www.ca2.uscourts.gov/clerk/case_filing/rules/title7/local_rule_32_1.html); FRAP 32(a)(7) | 2026-10-14 (page last modified 11/16/2015) |
| CA2-ORDER-001 | Contents, in order: disclosure statement (if any), table of contents, table of authorities, jurisdictional statement, statement of issues, statement of the case, summary of argument, argument (with standard of review per issue), conclusion, certificate of compliance | FRAP 28(a)(1)–(10) (https://www.law.cornell.edu/rules/frap/rule_28) | 2026-10-14 |
| CA2-CERT-001 | Certificate of compliance (word count and typeface), Form 6 content | FRAP 32(g)(1)–(2) | 2026-10-14 (Form 6 wording reproduced from the rule's requirements; Form 6 text itself not fetched, see Gaps) |
| CA2-CERT-002 | Certificate of service | FRAP 25(d) (not fetched; see Gaps) | not verified |
| CA2-CONV-001 | Double spacing for text (the rule sets no spacing for full-size briefs) | convention; exemplar | exemplar |
| CA2-CONV-002 | Caption separator "-v-" | exemplar | exemplar |
| CA2-CONV-003 | Cover color: blue for the appellant's cover | 2d Cir. page "Brief and Appendix" (https://www.ca2.uscourts.gov/clerk/case_filing/appealing_a_case/civil_case/brief_and_appendix.html); FRAP 32(a)(2) | not produced; see below |
| CA2-CONV-004 | Point headings: I., II. centered, bold small caps; sub-headings A., 1., a. | exemplar | exemplar |

Note on CA2-CONV-003: FRAP 32(a)(2) puts a color on the cover of paper copies. The ECF PDF (the only output here) has no color, so the template does not produce it. This is the same choice ca9 made (see its README). A paper-copy cover in blue must be printed on blue stock by the filer.

## What is here

| Path | What |
|---|---|
| `typst/ca2-opening-brief.typ` | Template: `ca2-opening-brief(meta, md)`. Adapted from the ca9 template's structure; every number is a named parameter at the top and traces to a rule above. |
| `typst/main.typ` | Entry point; reads the sample named by `--input sample=...`. |
| `samples/INPUT-munafo-opening-brief.md` | Transcribed from the exemplar: cover, tables, jurisdiction, issues, statement of the case, summary, most of Argument I, the start of Argument II, conclusion, certificates. A portion of the brief, not the whole (see Gaps). |
| `samples/OUTPUT-munafo-opening-brief.pdf` | Render (19 pages). |
| `samples/OVERLAY-munafo-opening-brief.pdf`, `-overlay.txt` | Red/blue overlay against the exemplar (`tools/overlay.sh`). |
| `exemplars/` | The filed exemplar and `SOURCE.md`. |

Build (from the repo root, with the toolchain on PATH):

```sh
sh tools/render.sh courts/second-circuit/court-of-appeals/opening-brief samples/INPUT-munafo-opening-brief.md
sh tools/overlay.sh courts/second-circuit/court-of-appeals/opening-brief munafo-opening-brief
```

Render output has no typst warnings; fonts are the vendored EB Garamond only.

## Markdown contract (differences from ca9)

- Frontmatter: `case_number`, `caption` (two sides: `names`, `designation`), `proceeding`, `brief_title`, `counsel`, `phone`, `signature`, `date`, `service` (`date`, `parties` list of `name`/`address`/`method`, optional `signer`), `authorities`; optional `disclosure` (FRAP 26.1 text, printed as its own page before the tables), `district_court_case`, `judge`.
- Not present: related-cases statement and addendum (not in the Second Circuit's FRAP 28 list), word-limit basis and manual image count (ca9 Form 8).
- Body: `# Heading` sections as in ca9; under `# Argument`, `##` is a roman point and `###` a letter. Footnotes: definitions may sit anywhere; the template passes each chunk the definitions it cites.
- Word count: computed from the body markdown, checked against 14,000, printed in the certificate. It excludes the cover, tables, signature and certificates (FRAP 32(f)).

## Overlay (what it shows)

`samples/OVERLAY-munafo-opening-brief.pdf`: red is our render, blue is the filed exemplar, black is agreement. Pages are paired by text (`-overlay.txt`). The word-overlap figures are a diagnostic, not a score. Largest differences are where the transcription is abridged (sample page 5 vs filed page 5 at 13%: the sample's block-quote page against a different filed page) and the tables, whose pagination differs from the filed TOA. These are tier 3 (exemplar pagination and leading), not template defects.

## Page review (Gate 2 equivalent, this doc type)

Final render of `OUTPUT-munafo-opening-brief.pdf`, 19 pages, every page rasterized at 60 dpi and viewed:

| PDF page (label) | Content | Finding |
|---|---|---|
| 1 (cover) | Cover | Fits one page. Proceeding line wraps "New / York". Acceptable (filed exemplar wraps too). |
| 2 (i) | Table of contents | Lists TOA, sections, points, conclusion; numbers match body. |
| 3–5 (ii–iv) | Table of authorities | Cases, statutes, regulations, rules; "passim" not triggered. |
| 6 (1) | Jurisdictional statement, issues | Footnote 1 on its reference page. |
| 7 (2) | Statement of the case | Footnote 2 on its reference page; block quotation on the next page. |
| 8–10 (3–5) | Statement of the case, summary, Argument I.A | Point headings centered, small caps; block quotation indented; headings numbered. |
| 11–12 (6–7) | Argument I.A, I.B | Block list of § 3553(a)(2) items indented. |
| 13–14 (8–9) | Argument I.B, II.A | Point II heading centered; standard of review. |
| 15–16 (10–11) | Argument II.B | Footnote 3 on its reference page. |
| 17 (12) | Conclusion and signature block | Conclusion kept on one page with the signature block. |
| 18 (13) | Certificate of compliance | Word count and typeface paragraphs; signature and date. |
| 19 (14) | Certificate of service | Served party, method, signature and date. |

Fixed during review: (a) the TOA heading was not in the TOC (now `outlined`); (b) "Standard of review" capitalization in the sample; (c) the signature block was orphaned from the Conclusion on its own page, because footnote definitions at the end of the file defeated the keep-with-signature logic (fixed: each chunk now gets the definitions it cites).

Known, not fixed: after a block quotation, the following paragraph is first-line indented (the exemplar does not indent it). Tier 2, low severity.

## Gaps

- Exemplars: one filer only (FPD, N.D.N.Y. appeal). Tier 2 needs two or three filers; the next search should add a private-counsel or U.S. Attorney's Office brief.
- Local Rule 32.1 text was read from the court's own page last modified 11/16/2015; LR 32.1.1 (cited nowhere here) was not found. Re-verify LR 32.1(a) before a filing.
- FRAP 32(a)(7)(B) sets 13,000 words; the template uses 14,000 from LR 32.1(a). The certificate text cites both rules. Verify the interaction.
- Form 6 wording and FRAP 25(d) were not fetched; the certificate text follows the rule's stated requirements and the exemplar's form.
- The sample is a portion of the brief (about 12 body pages; the full exemplar is 28 pages). Its total of 19 pages is above the 8–14 target because the cover, the 4 front-matter pages and 2 certificate pages are fixed. The body alone is within range.
- No `checks.yaml`, no Gate 0/1 checks for this doc type yet (the latex and docx engines are described below).
- No paper-copy cover color (see CA2-CONV-003).

## Engines (latex, docx)

Built by `latex/` (`template.tex` + `ca2.lua`) and `docx/` (`reference.docx` from `make-reference.sh`, + `ca2.lua`), against the same frontmatter and sample as the typst template.

- **latex** (`samples/OUTPUT-munafo-opening-brief.latex.pdf`, 19 pages; typst: 19). Matches: letter, 1-inch margins, EB Garamond 14 pt throughout (vendored, `$fontdir$`), 31.4 pt double spacing, single-spaced footnotes, quotations and headings, the cover's parts, contents and authorities (page numbers computed in two passes, "passim" at seven pages), point and sub-heading labels, signature kept with the last paragraph, both certificates, certificate word count 2,584 (same count as typst). Differs: the cover spreads its parts less than the typst cover (content ends about 1 inch above the bottom margin); body pagination differs by a line or two per page, so some page numbers in the contents differ from typst by one page.
- **docx** (`samples/OUTPUT-munafo-opening-brief.docx`, `.docx.pdf` 19 pages, checked on the LibreOffice PDF). Matches: the cover, the section breaks (cover without number; contents and authorities in lower-case roman; body from 1), 14 pt EB Garamond, double spacing, footnote and quotation styles, centered page number, certificates. BLOCKED: `DOCX-TOC-PAGES` and `DOCX-TOA-PAGES`: the contents and authorities list every entry but the page numbers are empty; the page numbers need a second render pass that reads them from the PDF (not built). Cover spacing differs from typst's (no full-page stretch).
