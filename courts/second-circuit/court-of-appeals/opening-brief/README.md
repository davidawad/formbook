# Second Circuit: appellant's opening brief (typst)

Status: template built and rendered; one exemplar; tier 2 provisional (one filer only). Not gated by `checks.yaml` (no checks for this doc type yet).

## Governing rules

| ID | Requirement | Source | Verified |
|---|---|---|---|
| CA2-FORM-001 | Paper: 8½ × 11 in. | FRAP 32(a)(4) (https://www.law.cornell.edu/rules/frap/rule_32) | 2026-10-14 |
| CA2-FORM-002 | Margins: at least 1 in. on all four sides | FRAP 32(a)(4) | 2026-10-14 |
| CA2-FORM-003 | Cover: case number centered at top; name of court; case title; nature of proceeding and court below; brief title naming the party; counsel name, office address, telephone | FRAP 32(a)(2)(A)–(F) | 2026-10-14 |
| CA2-FORM-004 | Proportionally spaced serif face, 14-point or larger, text and footnotes; plain roman with italics or bold for emphasis | FRAP 32(a)(5)(A), 32(a)(6) | 2026-10-14 |
| CA2-FACE-001 | **No face named.** FRAP 32(a)(5)(A) names no face (any proportionally spaced serif face, 14 pt or larger). Local Rule 32.1(a)(2) names none (its 12-pt figure is for pamphlet briefs only). The court's brief page gives "Times New Roman" only as an example ("such as"). Substitute: none. The template sets **Times New Roman** (vendored; Liberation Serif, its metric twin, as fallback; the house face, `docs/FONTS.md` rule 6). Latex (newtx Times) and docx match. | FRAP 32(a)(5)(A); 2d Cir. LR 32.1(a)(2); https://www.ca2.uscourts.gov/clerk/case_filing/appealing_a_case/civil_case/brief_and_appendix.html | 2026-10-15 |
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
| `usage/INPUT-opening-brief.md` | Transcribed from the exemplar: cover, tables, jurisdiction, issues, statement of the case, summary, most of Argument I, the start of Argument II, conclusion, certificates. A portion of the brief, not the whole (see Gaps). |
| `usage/OUTPUT-opening-brief.typst.pdf` | Render (20 pages). |
| `usage/OVERLAY-munafo-opening-brief.pdf`, `-overlay.txt` | Red/blue overlay against the exemplar (`tools/overlay.sh`). |
| `usage/` | The filed exemplar and `SOURCE.md`. |

Build (from the repo root, with the toolchain on PATH):

```sh
sh tools/render.sh courts/second-circuit/court-of-appeals/opening-brief usage/INPUT-opening-brief.md
sh tools/overlay.sh courts/second-circuit/court-of-appeals/opening-brief munafo-opening-brief
```

Render output has no typst warnings; fonts are the vendored Times New Roman only (Regular, Bold, Italic, embedded).

## Markdown contract (differences from ca9)

- Frontmatter: `case_number`, `caption` (two sides: `names`, `designation`), `proceeding`, `brief_title`, `counsel`, `phone`, `signature`, `date`, `service` (`date`, `parties` list of `name`/`address`/`method`, optional `signer`), `authorities`; optional `disclosure` (FRAP 26.1 text, printed as its own page before the tables), `district_court_case`, `judge`.
- Not present: related-cases statement and addendum (not in the Second Circuit's FRAP 28 list), word-limit basis and manual image count (ca9 Form 8).
- Body: `# Heading` sections as in ca9; under `# Argument`, `##` is a roman point and `###` a letter. Footnotes: definitions may sit anywhere; the template passes each chunk the definitions it cites.
- Word count: computed from the body markdown, checked against 14,000, printed in the certificate. It excludes the cover, tables, signature and certificates (FRAP 32(f)).

## Overlay (what it shows)

`usage/OVERLAY-munafo-opening-brief.pdf`: red is our render, blue is the filed exemplar, black is agreement. Pages are paired by text (`-overlay.txt`). The word-overlap figures are a diagnostic, not a score. Largest differences are where the transcription is abridged (sample page 5 vs filed page 5 at 13%: the sample's block-quote page against a different filed page) and the tables, whose pagination differs from the filed TOA. These are tier 3 (exemplar pagination and leading), not template defects.

## Page review (Gate 2 equivalent, this doc type)

Render of `OUTPUT-opening-brief.typst.pdf`, 19 pages (the earlier EB Garamond render, before the cross-engine port; the review after it is under "Cross-engine"), every page rasterized at 60 dpi and viewed:

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
- The sample is a portion of the brief (about 12 body pages; the full exemplar is 28 pages). Its total of 20 pages is above the 8–14 target because the cover, the 4 front-matter pages and 2 certificate pages are fixed. The body alone is within range.
- No `checks.yaml`, no Gate 0/1 checks for this doc type yet (the latex and docx engines are described below).
- No paper-copy cover color (see CA2-CONV-003).

## Engines (latex, docx)

Built by `latex/` (`template.tex` + `ca2.lua`) and `docx/` (`reference.xml`, from which `fb render` builds `reference.docx`, + `ca2.lua`), against the same frontmatter and sample as the typst template. All three engines are on the shared cross-engine layout model since fb-595.54.2 (see "Cross-engine" below): the latex and docx renders break every line and every page where typst does, and `eval.yaml` gates it.

- **latex** (`usage/OUTPUT-opening-brief.latex.pdf`, 20 pages; typst: 20). Times 14 pt (newtx, stock TeX Live) in the typst line boxes, the cover, contents and authorities (page numbers computed in two passes, "passim" at seven pages), labels, signature kept with the last paragraph, both certificates; certificate word count 2,584 (counted from the markdown as typst counts it). Differs only in positions that are not breaks: the cover's gaps, the docket line's box.
- **docx** (`usage/OUTPUT-opening-brief.docx`, `.docx.pdf` 20 pages, checked on the LibreOffice PDF). Times New Roman 14 pt; sections (cover without number; contents and authorities in lower-case roman; body from 1, footers written by fb render); the contents and authorities carry their page numbers (fb render's two-pass page map, `tools/fb/src/docxpass.rs`: `ca2.lua` writes a needle for every heading and citation). The earlier BLOCKED items (`DOCX-TOC-PAGES`, `DOCX-TOA-PAGES`: empty page numbers) and the tier-1 failures (`TNR-EMBEDDED`, `DEF-FONT-002`: EB Garamond; `DEF-TOC-001`; `DEF-CONT-001`) are fixed. Opened in LibreOffice only, not in Word.

## Verification pass 2026-10-16 (fb-595.26.2)

- Re-rendered `INPUT-opening-brief.md` with `tools/render.sh`: exit 0, no warnings, 19 pages (the committed PDF was not stale: same text and page count). Fonts: EB Garamond Regular/Bold/Italic only (the face the template then set; Times New Roman since).
- Viewed all 19 pages at 60 dpi, exemplar pages 1-2, and all 19 overlay pages at 40 dpi. The overlay pairing is unchanged (cover 89.1%, body 45-88%, page 5 at 13% as described above).
- Fixed (tier 1): the cover printed "No. 25-3142-cr" at 14 pt; Local Rule 32.1(a)(1) (fetched 2026-10-16) requires the docket number "in type at least one inch high". Now `docket-size = 72pt`, bold, without "No." (as in the exemplar). Latex `ca2.lua` changed the same way. The cover still fits one page.
- Fixed (tier 2): the table of authorities sorted statutes as text ("18 U.S.C. § 875(c)" after "§ 3742"); the sort key now compares digit runs by value, so § 875(c) comes first.
- Latex re-rendered (19 pages) and every page viewed. Open latex defects, not fixed: statutes still sort as text; the cover's parts are spread unevenly.
- Still open: the gaps listed above (one filer; Form 6 and FRAP 25(d) not fetched; paragraph indent after block quotations; no paper cover color). The docket size uses the 72 pt reading of "one inch high" (see the reply brief's README for the cap-height question).

## Cross-engine (fb-595.54.2)

All three engines on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/latex/xengine.sty` and `xengine.lua`, `lib/docx/xengine.lua` and `xengine-reference.sh`; docs/EVAL-LOOP.md, "Adopting the reference breaker"), `params.cross_engine: gate` in `eval.yaml`.

- typst: `show: xengine.with(pitch: 31.4pt, list-indent: 0.5in)`; line boxes of 31.4 pt (body), 20 pt (headings, quotations, footnotes, tables, cover, certificates) and 80 pt (the one-inch docket number); every space in pt; `listing-row` contents (36 pt page column) and authorities (56 pt, or the page list's width). Changed from the earlier template: section headings 16 pt (were 16.1 pt, 1.15 em: Word has only half points); point headings bold, not bold small capitals (CA2-CONV-004: Times New Roman has no small capitals and each engine would synthesize them differently); quotation paragraphs 14 pt apart (were 12.6 pt); the signature block starts at the middle of the text width (3.25 in; the relative pad resolved to 201 pt inside its unbreakable block). Kept: Times New Roman 14 pt, 31.4 pt double spacing, 1 in margins, indents, the cover's design.
- latex: `\usepackage{xengine}`, `\xe@lines`, `\addvspace`, `\xe@row`, `\xe@footnotemarks{14}`, `\xe@lists{0.5in}`; the filter runs `require("latex.xengine")` over the body and every metadata value; an ellipsis character is one 1 em unit marked as U+2026 (ActualText), as typst and Word set the glyph; a list right after a heading does not open with a break (`\@nobreak`).
- docx: `make-reference.sh` then called `lib/docx/xengine-reference.sh` (Times New Roman, 28 half points, body 628, single 400 twips; `reference.docx` committed); `make-reference.sh` and the committed `reference.docx` since retired into fb render, which builds the reference document from `docx/reference.xml` (`base="xengine"`, the same numbers); `ca2.lua` writes every paragraph with exact spacing (`require("docx.xengine")`), the table rows with the page column as right indent and a leader tab, and a word joiner between ")(" so LibreOffice does not break "32(a)(7)(B)" (typst boxes the token, TeX has no break there).
- Every engine certifies the same word count: the latex and docx filters count the markdown source as the typst template does (2,584).
- Before (baseline, fresh render before the port): latex 20 pages against typst's 18, 151/363 lines with typst's break (41.6 %); docx 19 pages, 103/363 (28.4 %), and docx tier 1 failing `TNR-EMBEDDED`, `DEF-FONT-002`, `DEF-TOC-001`, `DEF-CONT-001` (blocks 9, 10, 42, 43). After: typst 20 pages; latex and docx 20 pages, 367/367 lines, every page starting and ending on typst's words (XENG-001..003 PASS); tier 1: typst 8 passed, latex 11 passed, docx 12 passed, 0 failed.
- Pages reviewed after the port (`pdftoppm -r 50`, every page viewed in typst, latex and docx): 1-20 of each. Cover, contents (leaders, page column), authorities (two-line case entries, page lists), headings, the block quotations, footnotes 1-3 at the foot of their pages, signature block kept with the Conclusion, both certificates; no overlapping or clipped text, nothing in the margins.
