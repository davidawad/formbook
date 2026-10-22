# Court of Appeals for the Third Circuit: opening brief of an appellant

Doc type `opening-brief` for court `ca3`. Self-contained: exemplar, sample, template and rules live here. Court-root `typst/` and `usage/` (none for ca3 yet) are not touched.

Status: exemplar=yes, sample=yes (one), typst render=ok, overlay=ok. typst, latex and docx on the shared cross-engine layout model, `check.sh` green on all three, `params.cross_engine: gate` (see "Cross-engine" at the end).

## Build and check

From the repo root, with typst 0.15.0 on PATH (`render.sh` runs typst with `--ignore-system-fonts`, the vendored fonts only, and treats any warning as failure):

```sh
sh tools/render.sh courts/third-circuit/court-of-appeals/opening-brief usage/INPUT-opening-brief.md   # -> usage/OUTPUT-opening-brief.typst.pdf
sh tools/overlay.sh courts/third-circuit/court-of-appeals/opening-brief tresslar-opening-brief            # -> -overlay.pdf and -overlay.txt
```

Layout: `usage/` (one filed brief and `SOURCE.md`), `usage/` (markdown, rendered PDF, overlay), `typst/main.typ` (entry point, reads `--input sample=`), `typst/ca3-opening-brief.typ` (the template: `ca3-opening-brief(meta, md)`). The template has no case-specific text; every number is a named parameter at the top or traces to a rule.

## Exemplar

`usage/FILED-EXAMPLE-opening-brief.pdf`, Brief of Appellant (Lisa Tresslar, No. 26-1367, 3d Cir., filed 2026-07-27, The Gold Law Firm, P.C.). Source, search, and the second filer consulted (*Gaia Gardens*, No. 26-2749) are in `usage/SOURCE.md`.

Searches: CourtListener RECAP search (`/api/rest/v4/search/`, court=ca3, type=r, "opening brief"), which returned several appellant briefs; two were downloaded and checked for a text layer and a complete brief structure. The Tresslar filing was chosen for its complete section order and the fact that it is one filer, not a combined brief with a long addendum.

## Governing rules

Verified 2026-10-14. Primary sources as fetched: the FRAP text from Cornell LII (`https://www.law.cornell.edu/rules/frap/rule_32` and `.../rule_28`); the Third Circuit Local Appellate Rules as posted by the court (`https://www.ca3.uscourts.gov/sites/ca3/files/local_rules/2011_LAR_Final.pdf`, dated August 1, 2011, linked from the court's rules page as the current full text). The court's site also carries a 2023 amendment to L.A.R. 26 and Misc. 113(c) (`.../LAR%2026%20and%20Misc.%20LAR%20113%28c%29%20Effective%20July%201%202023.pdf`), not applied here because it does not touch the brief's form. courtrules.net returned HTTP 403 and was not used.

| ID | Rule | Source | What the template does |
|---|---|---|---|
| CA3-COVER-1 | Cover: case number centred at top; court name; title of the case; type of proceeding and court below; brief title naming the party; counsel name, address, phone | FRAP 32(a)(2)(A)-(F) (LII, verified) | `cover-body`: number, court (`THE THIRD CIRCUIT`), caption, proceeding, district court case and judge, brief title and appendix line, counsel block with phone |
| CA3-COVER-2 | Cover colour: blue for the appellant's paper cover; unrepresented parties exempt | FRAP 32(a)(2) (LII, verified) | Not produced: paper copies only. Known gap. |
| CA3-FORM-1 | 8½ × 11 paper; double-spaced text; quotations over two lines may be single-spaced; headings and footnotes may be single-spaced | FRAP 32(a)(4) (LII, verified) | `us-letter`; `body-leading`; block quotes and footnotes single-spaced |
| CA3-FORM-2 | Margins at least 1 in on each side; top and bottom at least ¾ in | L.A.R. 32.1(b) (2011 text as posted) | 1 in on all four sides |
| CA3-FORM-3 | Proportionally spaced serif, 14-point or larger | FRAP 32(a)(5)(A) (LII, verified); L.A.R. 32.1(c) | Times New Roman (Liberation Serif fallback; newtx in LaTeX; EB Garamond earlier), 14 pt for text, footnotes, headings |
| CA3-FORM-4 | Plain roman type; italics or boldface for emphasis; case names italic | FRAP 32(a)(6) (LII, verified) | Case names italic as written in markdown (*...*) |
| CA3-FORM-5 | Footnotes printed in the same size type as the text | L.A.R. 32.2(a) (2011 text as posted) | Footnote entries set at 14 pt |
| CA3-FORM-6 | Electronic brief in PDF, one file | L.A.R. 31.1(b)(2) (2011 text as posted) | Output is one PDF |
| CA3-LEN-1 | Principal brief: at most 13,000 words (type-volume) or 30 pages | FRAP 32(a)(7)(A)-(B)(i) (LII, verified) | Word count checked against `word-limit` (13,000) and the count printed in the certificate |
| CA3-CONT-1 | Brief contents, in order: disclosure statement; TOC; TOA; jurisdiction; issues; case; summary; argument; conclusion; certificate of compliance | FRAP 28(a)(1)-(10) (LII, verified, 2013 numbering) | Order of the template: cover, TOC, TOA, body, certificates. Disclosure statement not generated (see gaps) |
| CA3-CONT-2 | Statement of issues: designation of the appendix pages where each issue was raised and ruled upon | L.A.R. 28.1(a)(1) (2011 text as posted) | Author writes the designation in each issue (sample: "(See Appx ...)") |
| CA3-CONT-3 | Statement of related cases after the statement of issues | L.A.R. 28.1(a)(2) (2011 text as posted) | `related-cases` is inserted before `# Statement of the Case`, using the frontmatter text |
| CA3-CONT-4 | Standard or scope of review for each issue under its own heading before the discussion | L.A.R. 28.1(b) (2011 text as posted) | Required: the template refuses to build without a `Standard of Review` heading |
| CA3-CONT-5 | Citations to reported decisions: U.S., F., F. Supp., F.R.D.; court and year | L.A.R. 28.3(a) (2011 text as posted) | Authority registry entries carry the cite; the author types the citation |
| CA3-CONT-6 | Record citations to the appendix | L.A.R. 28.3(c) (2011 text as posted) | Author types the appendix citations in the body (exemplar form) |
| CA3-CERT-1 | Certificate of compliance with the type-volume limit: word count and typeface/type-style | FRAP 32(g)(1) (LII, verified) | `certificate-of-compliance`, with the word count computed by the template |
| CA3-CERT-2 | At least one attorney on the brief is a member of the bar of this court, or has applied under L.A.R. 46.1 | L.A.R. 28.3(d) (2011 text as posted) | `certificate-of-bar` |
| CA3-CERT-3 | Electronic brief: text identical to the paper copies; virus check | Not in the 2011 L.A.R. text. Exemplar practice (the Tresslar filing carries both) | `certificate-of-e-brief`; the virus line prints only when `virus_software` is given. Convention, tier 2 |
| CA3-CERT-4 | Certificate of service | FRAP 25(d). **Not fetched in this run**; the wording follows the exemplar (CM/ECF service) | `certificate-of-service`. Marked here as not verified against the rule text |

The rules are the court's, not the exemplar's. Where the rules leave a choice open (font face, heading style, certificate wording), the exemplar settles it, and that choice is named below.

## Choices the exemplar settles

- **Typeface**: Times New Roman (EB Garamond earlier). Rule names no face: FRAP 32(a)(5)-(6) and L.A.R. 32.1(c) (2011 text, checked 2026-10-15) name none, so the house standard of `docs/FONTS.md` (rule 6) applies. FRAP 32(a)(5) allows any proportional serif at 14 pt. The exemplar is Times New Roman too. Metric compatibility: n/a (no court-named face).
- **Line pitch**: `body-leading = 0.94em` (the same value as the ca9 template, which records it as double spacing). Measured in this render: body line pitch 31.4 pt on 14 pt type (2.24 × type size). This is our render, not a measurement of the exemplar.
- **Heading scheme**: I. / A. / 1. / a. at levels 2 to 5, both inside and outside the Argument. The exemplar numbers its Statement of the Case I., II. and its Argument I., II. the same way. The ca9 centred point headings in the Argument are not used.
- **Section order**: as above, with the related-cases statement after the issues (L.A.R. 28.1(a)(2)); the exemplar follows this, and ca9's placement before the certificates does not apply in this court.
- **Certificates**: each on its own page, after the signature block, in the order compliance, bar membership, e-brief and virus, service.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block followed by the body. The template generates the cover, the TOC and TOA, the related-cases statement, the signature block and the certificates.

| Field | Required | Feeds |
|---|---|---|
| `case_number` | yes | Cover top line; PDF title |
| `caption` | yes | Two sides: `names` (one centred line each) and `designation`; "v." inserted between |
| `proceeding` | yes | Cover: "On Appeal from ..." |
| `district_court_case`, `judge` | no | Cover, in parentheses as written (for example `Civ. No. 24-1435`, `The Honorable ...`) |
| `brief_title` | yes | Cover title in capitals; certificate of service description |
| `appendix` | no | Cover line under the title (for example the joint appendix volume) |
| `counsel` | yes | Cover counsel block (FRAP 32(a)(2)(F)): `names` and `lines` per group |
| `phone` | yes | Cover, after the last counsel group |
| `counsel_for` | no | Cover, italic, below the phone |
| `signature` | yes | `signer` (printed `/s/ Name`), `lines` (printed under it); used after the conclusion and on each certificate |
| `date` | no | Under the signature block and each certificate |
| `related_cases` | yes | The statement of related cases, as written (L.A.R. 28.1(a)(2)) |
| `virus_software` | no | The e-brief certificate's virus line |
| `service.certificate` | no (default true) | Certificate of service on or off |
| `authorities` | yes if the body cites | Registry: `kind` (case, constitution, statute, regulation, rule, other), `name` (case names italic), `cite` |

Body: `# Heading` is a section. Required: `# Statement of the Case`, a heading containing `Standard of Review`, `# Argument`, `# Conclusion`. Sub-headings are numbered automatically: do not type "A." or "I." in a heading (the sample had this error and the TOC showed "A. A."). Citations link to the registry as `[*Flora v. County of Luzerne*, 776 F.3d 169 (3d Cir. 2015)](toa:flora)`. Footnotes use `[^key]`. Block quotations use `>`.

## Overlay (`usage/OVERLAY-tresslar-opening-brief.pdf`)

Red = our render, blue = the filed exemplar, black = both (`tools/overlay.sh`, pages paired by word overlap).

What it shows, and what it does not. Cover and front matter line up well: page 1 (cover) 93.8%, page 2 (TOC) 60.2%, page 5 (Jurisdiction) 93.5%, page 6 (issues) 89.4%, and the certificate pages 59-97%. Body pages pair with low word overlap (30-55%) because the sample is a partial transcription and our pagination does not match the filed pages: our page 7 covers the second half of filed page 8 and the start of filed page 9, so no single filed page is a good pair. The overlay is a diagnostic for the front matter and the certificates, not evidence that the body layout matches the filed pages line for line. The overlay run prints poppler "Syntax Error: Expected the optional content group list" lines for the exemplar (Adobe Acrobat optional-content metadata). They are harmless: the overlay is produced.

## Review (Gate 2 record)

Every page of `usage/OUTPUT-opening-brief.typst.pdf` (18 pages, PDF page numbers below; printed folios are 1-10 for PDF pages 5-14 and i-iv for PDF pages 2-4) was rendered to PNG at 60 dpi and looked at in the first pass. Findings and what was done:

| PDF page | Finding | Action |
|---|---|---|
| 1 (cover) | "THIRD / CIRCUIT" split across a line by natural wrap | Fixed: non-breaking spaces bind "THE THIRD CIRCUIT" (joined words, not a forced break) |
| 2 (TOC) | Page numbers wrapped to their own line where a title ran to the margin | Fixed: page-number box sized to its content (first pass); replaced 2026-10-16 by a two-column grid, see the verification pass below. Re-viewed: every number on its line |
| 2 (TOC) | Sub-headings showed "A. A." and "B. B." | Fixed: the sample typed the letters into the headings; removed (the template numbers them) |
| 3-4 (TOA) | TOA runs onto a second page, with one entry alone on PDF page 4 | Accepted: the exemplar's TOA also runs two pages |
| 5-14 | Body: double spacing, I./A./B./C. headings, the related-cases statement after the issues, footnote 1 at foot of page, signature block after the conclusion | No change |
| 15-18 | Certificates: compliance, bar membership, e-brief and virus, service; each on its own page | No change |
| 12 (Argument II.A) | "A. A." duplicate, as above | Fixed in the sample; re-viewed |

Pages reviewed: 18 of 18 in the first pass. After the fixes, PDF pages 2 and 12 were viewed again; the page count stayed at 18. The other pages were not viewed again. The edits touched only the TOC page-number box and two sample headings.

Word count in the compliance certificate (2,155 in the 2026-10-16 render; 2,157 was recorded earlier) is the count of this sample's body and related-cases text. It is not the count of the filed brief: the sample transcribes part of the argument.

## Known gaps

- **Cover colour** (FRAP 32(a)(2): blue for an appellant's paper cover) is not produced. Paper copies only, like ca9.
- **Corporate disclosure statement** (FRAP 26.1; L.A.R. 26.1 as amended in 2023) is not generated. The Tresslar exemplar has none (an individual filer). Gaia Gardens has one at page i (not saved as an exemplar). Add a `corporate_disclosure` field when a corporate sample is built; not tested.
- **Addendum** (FRAP 28(f)) is not supported: the ca9 `# Addendum` mechanism was not copied. A `# Addendum` heading in the markdown would render as an ordinary section.
- **Argument sections I.A to I.E** of the Tresslar brief are not transcribed. The sample covers the front matter, the statements, Summary, Standard of Review, Argument I's opening, Argument II, the conclusion and the certificates.
- **Certificate of service rule** (FRAP 25(d)) text was not fetched in this run; the wording follows the exemplar.
- **Checker** (`checks.yaml`, `tools/check.sh`) does not yet exist for this court; this doc type is rendered and overlaid only.

## Engines

- **typst** (`typst/`): primary, unchanged.
- **latex** (`latex/template.tex`, `latex/ca3.lua`; fb render, stock pdflatex until the aux file settles): Times 14 pt (newtx, the metric twin of the typst template's Times New Roman) in the typst line boxes, the cover, contents and authorities (page numbers from the previous pass, "passim" at seven pages), the related-cases statement, each certificate on its own page; 19 pages, every line and page broken where typst breaks them (see "Cross-engine" below). Differs only in positions that are not breaks: the cover's gaps.
- **docx** (`docx/reference.xml`, from which `fb render` builds the reference document, replacing `docx/make-reference.sh`; `docx/ca3.lua`; `.docx.pdf` from LibreOffice): Times New Roman 14 pt; sections (cover without number; contents and authorities in lower-case roman; body from 1, footers written by fb render); the contents and authorities carry their page numbers (fb render's two-pass page map: `ca3.lua` writes a needle for every heading and citation). The earlier gaps (no page numbers in the tables, no footers or sections, no first-line indents) and the docx tier-1 failures (`TNR-EMBEDDED`, `DEF-FONT-002`: EB Garamond) are fixed. An addendum is set by the typst engine only (the latex and docx filters stop with an error; no sample has one). Opened in LibreOffice only, not in Word.

## Verification pass 2026-10-16 (fb-595.26.3)

- Rendered: `sh tools/render.sh ... usage/INPUT-opening-brief.md`, exit 0, no typst warnings, 18 pages (the same count as the first pass). Overlay rerun: `usage/OVERLAY-tresslar-opening-brief.pdf`, 18 pages; pairs and percentages unchanged (cover 93.8%, TOC 60.2%, certificates 58.6-97.2%, body 30-55%). TOA page 2 (our p. 4, one entry) pairs at 4.3%.
- Viewed: all 18 pages of the OUTPUT at 60 dpi, the 18 overlay pages at 40 dpi (as one contact sheet), and the exemplar's page 1 against our cover (same order of elements; the exemplar is Times New Roman and puts counsel at the left margin, tier 3).
- Checked: footnote 1 (p. 11) is set at 14 pt (word boxes as tall as the body text); the cover fits page 1; TOC page numbers match the body headings; no heading is left at the foot of a page.
- Defect fixed: the TOC page number was a content-sized box after a `1fr` leader, so a title that ran to the margin would still push the number onto its own line (latent; not visible in this sample). TOC rows are now a two-column grid (title and leader, then the page number), as in the reply-brief template. After the fix only PDF page 2 changed (every other page is pixel-identical to the pre-fix render); page 2 was viewed again.
- Stale statement corrected: the compliance certificate reads 2,155 words, not 2,157.
- latex re-rendered (`--engine latex`): exit 0, 17 pages, as recorded. Its pages were not reviewed in this pass. docx not touched (no `soffice`).
- Gaps unchanged: cover colour, disclosure statement, addendum, partial transcription, FRAP 25(d) text, no `checks.yaml`/`check.sh` for this doc type, one saved exemplar (the second filer is consulted, not saved).

## Cross-engine (fb-595.54.2)

All three engines on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/latex/xengine.sty` and `xengine.lua`, `lib/docx/xengine.lua` and `xengine-reference.sh`; docs/EVAL-LOOP.md, "Adopting the reference breaker"), `params.cross_engine: gate` in `eval.yaml`. The latex and docx filters (`latex/ca3.lua`, `docx/ca3.lua`) are one file for the three Third Circuit briefs; only `TYPE` differs between the copies.

- typst: `show: xengine.with(pitch: 31.4pt, list-indent: 0.5in)`; line boxes of 31.4 pt (body, the related-cases statement and the certificates' text) and 20 pt (headings, quotations, footnotes, tables, cover, signatures); every space in pt (the em values they replace, at 14 pt); `listing-row` contents (36 pt page column) and authorities (56 pt, or the page list's width). Changed from the earlier template: quotation paragraphs 14 pt apart (were 12.6 pt); the signature and counsel blocks at the middle of the text width as a length (3.25 in); the issues list set without a loose list's paragraph breaks; the certificate of compliance names the typeface only ("in font size 14, font style Times New Roman"; it named Typst, `prepared_with` still adds a program when the frontmatter gives one). Kept: Times New Roman 14 pt, 1 in margins, the heading scheme and indents, the cover's design.
- latex: `\usepackage{xengine}`, `\xe@lines` in bp, `\addvspace`, `\xe@row`, `\xe@footnotemarks{14}`, `\xe@lists{0.5in}`; the filter runs `require("latex.xengine")` over the body and every metadata value; an ellipsis is one 1 em unit marked as U+2026; the court name joined with no-break spaces ("THE~THIRD~CIRCUIT") as typst joins it.
- docx: `docx/reference.xml` (`base="xengine"`, from which `fb render` builds the reference: Times New Roman, 28 half points, body 628, single 400 twips; it replaced `make-reference.sh`) adds one style, Body Text Noted; `ca3.lua` writes every paragraph with exact spacing (`require("docx.xengine")`), table rows with the page column as right indent and a leader tab, a word joiner between ")(", the cover's gaps from an estimate of its height (one page).
- Three findings, each a line the gate caught, each handled the same way in all three briefs:
  1. typst moves the line that holds a footnote reference to the next page with its note even when that leaves a widow (the last line of the Argument I paragraph, footnote 1); TeX and Word keep two lines. A paragraph that holds a footnote has no widow penalty in latex (`\widowpenalty=0`: of two equally good breaks TeX takes the later, as typst) and no widow control in Word (style Body Text Noted).
  2. LibreOffice rounds every glyph advance to whole twips, so its lines are 0 to 0.36 pt narrower than typst's, never wider; a line that typst overruns by 0.01 pt (the first issue, "(2)") fitted in Word. The docx right margin is 4 twips (0.2 pt) wider, which centres that drift on typst's margin.
  3. Before a right tab beyond the right indent, LibreOffice wants about a third of an em of the lead's size more than the text and its spaces (measured at the threshold: 1/3 of 14 pt with 14 pt spaces, of 11.5 pt with 11.5 pt spaces; the page number's width does not count). The lead is two no-break spaces at 12.5 pt (10.4 pt in LibreOffice for typst's 0.75 em, 10.5 pt).
- Every engine certifies the same word count (2,155): the latex and docx filters count the markdown source as the typst template does.
- Before (baseline, `data/cross-engine-baseline.json`): latex 17 = 17 pages, 51.1 % of lines with typst's break (first difference p1 line 2); docx 17 vs 19 pages, 27.3 %, and docx tier 1 failing `TNR-EMBEDDED`, `DEF-FONT-002` (EB Garamond). After: typst 19 pages; latex and docx 19 pages, 364/364 lines, every page starting and ending on typst's words (XENG-001..003 PASS); tier 1: typst 8 passed, latex 11 passed, docx 12 passed, 0 failed. Every page of the typst, latex and docx PDFs viewed.
