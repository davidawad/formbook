# U.S. Court of Appeals for the Third Circuit: appellant's reply brief (`ca3`, `reply-brief`)

Rule-driven typst form for an appellant's reply brief (FRAP 28(c)). Rule texts were checked on 2026-10-14 where the row says "verified"; the rest are marked "not fetched". One self-contained doc-type folder; the court root's `typst/` and `usage/` are not touched.

| Path | What |
|---|---|
| `typst/ca3-reply-brief.typ` | The template: `ca3-reply-brief(meta, md)`. Content-agnostic; the numbers are named parameters at the top. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`. |
| `usage/INPUT-reply-brief.md` | Transcription of the filed exemplar (cover data, TOA, Introduction, part of Argument I.A.1, Conclusion, signature). A portion of the real brief, not all of it. |
| `usage/OUTPUT-reply-brief.typst.pdf` | `sh tools/render.sh courts/third-circuit/court-of-appeals/reply-brief usage/INPUT-reply-brief.md`. 9 pages. |
| `usage/OVERLAY-afp-reply-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/third-circuit/court-of-appeals/reply-brief afp-reply-brief`. Red = ours, blue = filed, black = both. |
| `usage/FILED-EXAMPLE-reply-brief.pdf`, `usage/SOURCE.md` | The filed reply brief (AFP, 3d Cir. 26-2469, Dkt. 30) and its provenance. |

Build (from the repo root, with the toolchain on `PATH`):

```sh
sh tools/render.sh courts/third-circuit/court-of-appeals/reply-brief usage/INPUT-reply-brief.md
sh tools/overlay.sh courts/third-circuit/court-of-appeals/reply-brief afp-reply-brief
```

Typeface: no face is named by the rule (FRAP 32(a)(5)-(6); L.A.R. 32.1(c), 2011 text, checked 2026-10-15), so the template sets the house standard of `docs/FONTS.md` (rule 6), Times New Roman (Liberation Serif fallback; EB Garamond earlier). Typst is run with no unpinned system font (`--ignore-system-fonts`); any typst warning fails the render.

## Governing rules

Each row: the requirement, the primary source, and where the template implements it. "Verified" means the text was fetched on 2026-10-14. Anything else is marked.

| ID | Requirement | Source (verified) | Template |
|---|---|---|---|
| CA3-LEN-001 | Reply brief: no more than half of the principal-brief type volume, i.e. **6,500 words** (or 650 monospaced lines). Panics above the cap. | FRAP 32(a)(7)(B)(ii) (https://www.law.cornell.edu/rules/frap/rule_32), verified. Third Circuit chart: "Reply & Amicus briefs – 15 pages / 6,500 words / 650 lines" (https://www.ca3.uscourts.gov/sites/ca3/files/chart%20of%20requirements%20for%20briefs.pdf), fetched 2026-10-14 via the saved PDF. | `word-limit`, checked in `ca3-reply-brief` |
| CA3-FORM-004 | Proportionally spaced face with serifs, **14-point or larger**; plain roman, italics for case names. | FRAP 32(a)(5)(A), 32(a)(6), verified. Chart item 5a: "Proportional (14 pt. with serifs)". | `type-size`, `font-family`; the PDF embedded only EBGaramond on the earlier EB Garamond render (now Times New Roman) |
| CA3-FORM-003 | Double spacing for text; single spacing for headings, block quotations, footnotes, TOC and TOA. | FRAP 32(a)(4) (not fetched; the exemplar is double-spaced, and the rule text is the same as FRAP 32(a)(4)). | `body-leading`, `single-leading` |
| CA3-FORM-002 | Margins 1 inch. | FRAP 32(a)(1) (not fetched). | `page-margin` |
| CA3-COVER-001 | Cover: court name, docket number, caption, nature of the proceeding and court below, title of the document, counsel with address and telephone. | Chart item 2 "Content of Front Cover" (fetched 2026-10-14); FRAP 32(a)(2) (not fetched). Exemplar p.1 follows this order. | `cover-body` |
| CA3-COVER-002 | Cover color: **gray** for an appellant's reply (chart item 1d, "Appellant/Petitioner Reply or 4th Step – Gray"). | Chart item 1d (fetched 2026-10-14). | Not rendered; see Known gaps |
| CA3-STRUCT-001 | Tables of contents with page references, and a table of authorities with the reply brief's own page references. | FRAP 28(c), verified (https://www.law.cornell.edu/rules/frap/rule_28). Exemplar pp. i-v. | `toc-section`, `toa-section` |
| CA3-CERT-001 | Certificate of bar membership: "...pursuant to L.A.R. 46.1(e)...member in good standing of the bar of this Court". | Exemplar p.28 (filed text) and chart "Combined certifications 1. Bar membership". The L.A.R. text itself was not retrieved (see Known gaps). | `certificate-of-compliance` |
| CA3-CERT-002 | Certificate of compliance with the word count and typeface: count includes headings, footnotes and quotations, and excludes the parts listed in FRAP 32(f). | FRAP 32(g)(1), verified: "The certificate must state the number of words". Exemplar p.28 and chart "2. Word Count". FRAP 32(f) exclusion list not fetched. | `certificate-of-compliance`, `count-words` |
| CA3-CERT-003 | Identical-copies statement and virus-check statement. | Chart "Combined certifications 4. Identical Compliance of Briefs; 5. Virus check"; exemplar p.28 cites L.A.R. 31.1(c) for the virus check. | `certificate-of-compliance` |
| CA3-CERT-004 | Certificate of service when service is not made automatically through CM/ECF. | FRAP 25(d) (chart item "3. Service if required by F.R.A.P. 25(d)"); exemplar p.29 wording. | `certificate-of-service` (only when `service.certificate: true`) |
| CA3-SIG-001 | Electronic signature "/s/ First Last". | Chart item "3. The brief must contain an electronic signature or s/ first name last name". | `signature-line` |

Authorities: the registry in the frontmatter names each authority once; every citation in the body is a `toa:KEY` link, and the TOA is generated from those links. A key that is not in the registry stops the build.

## What the overlay shows

Pages are paired by shared words, not index (`tools/overlay.sh`). The exemplar is 35 pages and this sample is 9, so the pairs for the body are approximate: sample pp. 4-9 match the filed pages 7-10 (Introduction and Argument I.A.1) and 34-35 (certificates). The cover and TOC/TOA pair with their filed counterparts at 86.8%, 31.2% and 36.5% word overlap. Read the overlay for layout differences (margins, indents, leader dots, heading styles), not for text match.

## Page review (Gate 2, every rendered page viewed at 60 dpi)

| Page | Content | Finding |
|---|---|---|
| 1 | Cover | Fits on one page. Caption, proceeding, district court number and judge, title, counsel with telephone. Matches the filed cover's order. The two counsel groups were stacked in the right half, which squeezed the cover spacing to nothing: fixed 2026-10-16, see below. |
| 2 | TOC | Fixed: the page number of a long entry (A.) wrapped onto its own line. TOC rows are now a two-column grid, so the page number stays on the last line of its entry. Page numbers match the body. |
| 3 | TOA (ii) | Cases grouped and alphabetized, with page lists. Matches the filed TOA format. |
| 4 | Introduction (1) | Fixed: "Id.." had a doubled period (sample markup). Double-spaced, 14-point. |
| 5 | Argument (2) | Point heading I. centered and small caps; A. hangs. |
| 6 | Argument I.A.1 (3) | Level 4 heading (1.) in bold italic, hanging. Block of citations linked. |
| 7 | Argument continued and Conclusion (4) | Conclusion heading; signature block (/s/, name, firm, address, email) follows. |
| 8 | Certificate of compliance (5) | Double-spaced since 2026-10-16 (see below). Bar membership, word count (812, this sample's count, not the filing's 6,479), identical copies and virus check. |
| 9 | Certificate of service (6) | Filed-form wording, /s/ signature, date. |

Pages reviewed: 9 of 9.

## Known gaps

- **Sample is a portion.** The exemplar is 35 pages; the sample is 9 rendered pages (about 800 words of the brief). Argument I.A.2 onward, I.B, I.C, II and III are not transcribed. Tier-2 judgments on argument typography (long block quotations, footnote density, very long sub-headings) need a fuller transcription.
- **Gray cover not rendered.** The chart calls for a gray cover on paper copies of a reply (item 1d). The template draws a plain cover, as the filed exemplar's PDF does (the color is a print property). Hard copies (chart: seven hard copies within five days of electronic filing) are outside a PDF template.
- **Page limit not enforced.** FRAP 32(a)(7)(A) also caps a reply at 15 pages unless it complies with the word limit. The template enforces the word limit (CA3-LEN-001) only. A brief that passes the word limit but runs past 15 pages would render without a warning.
- **L.A.R. text not retrieved.** The Third Circuit local rules page (https://www.ca3.uscourts.gov/rules-procedures/local-appellate-rules) returned 404 on 2026-10-14, and the L.A.R. 31.1(c) and 46.1(e) texts did not turn up in search. Those citations come from the exemplar's filed certificate and from the chart; they are not verified against the rule text.
- **Exemplar count.** One filed exemplar (AFP, a private-firm reply). A second filer (U.S. Attorney's reply, 3d Cir. 26-2028) is identified in `usage/SOURCE.md` but not saved; it is needed for the tier-2 comparison.
- **Monospaced option not implemented.** FRAP 32(a)(5)(B) permits 10½ cpi monospaced type with a 650-line limit. The template does only proportional type.

## Searches (exemplar)

- CourtListener search API (`/api/rest/v4/search/?type=r&court=ca3`, query "reply brief"): several ca3 reply briefs, all public RECAP documents. The detail endpoint requires auth; the docket pages and their storage links were used instead.
- Justia dockets (25-2303, 25-2729): found the docket entries but the fetch returned HTTP 403, so not used.
- Chosen: 26-2469 Dkt. 30 (AFP). Reason: private-firm reply brief, text-based, the same cover and certificate structure as the court's form, 35 pages.

## Engines

- **typst** (`typst/`): primary, unchanged.
- **latex** (`latex/template.tex`, `latex/ca3.lua`; fb render, stock pdflatex until the aux file settles): Times 14 pt (newtx, the metric twin of the typst template's Times New Roman) in the typst line boxes, roman front matter and arabic body; the Argument's point headings centered with roman numerals; the certificates each on their own page. The word limit is 6,500 words (FRAP 32(a)(7)(B)(ii)), checked from the markdown source. 10 pages, every line and page broken where typst breaks them (see "Cross-engine" below).
- **docx** (`docx/reference.xml`, from which `fb render` builds the reference document, replacing `docx/make-reference.sh`; `docx/ca3.lua`; `.docx.pdf` from LibreOffice): Times New Roman 14 pt; sections and footers; the contents and authorities carry their page numbers (fb render's two-pass page map); the earlier gaps (no page numbers, footers, first-line indents or centered point headings) are fixed. Opened in LibreOffice only, not in Word.

## Verification pass 2026-10-16 (fb-595.26.3)

- Rendered: `sh tools/render.sh ... usage/INPUT-reply-brief.md`, exit 0, no typst warnings, 9 pages (the same count as the first pass). Overlay rerun: `usage/OVERLAY-afp-reply-brief.pdf`, 9 pages; pairs and percentages unchanged (cover 86.8%, TOC 31.2%, TOA 36.5%, body 35-84%, certificates 57.4% and 57.6%).
- Viewed: all 9 pages of the OUTPUT at 60 dpi, the 9 overlay pages at 40 dpi (as one contact sheet), the exemplar's page 1 against our cover, and the exemplar's certificate pages 34-35.
- Defect fixed (tier 2), cover: the two counsel groups were stacked in the right half of the page, so the cover fit only with the spacing between its parts at or near zero (the rules touched the text above and below them). Two or more counsel groups now sit side by side, two to a row, across the full width, as on the filed cover; one group still sits in the right half. The cover now fits with clear space around every rule. The template still sets no coordinates; the spacing is the largest that fits.
- Defect fixed (tier 2; FRAP 32(a)(4) exempts only quotations, headings and footnotes from double spacing): the certificate of compliance and the certificate of service were single-spaced with no paragraph indent. The filed certificates (AFP pp. 34-35, and those of the other two ca3 filers, Tresslar and Binder) are double-spaced with a first-line indent. The certificate text now uses the body leading and indent. Page count unchanged (9).
- After both fixes only PDF pages 1, 8 and 9 changed (every other page is pixel-identical to the pre-fix render); those three pages were viewed again.
- latex re-rendered (`--engine latex`): exit 0, 10 pages, as recorded. Its pages were not reviewed in this pass. docx not touched (no `soffice`).
- Gaps unchanged: see Known gaps (portion transcribed, grey cover, 15-page cap not enforced, L.A.R. text not retrieved, one saved exemplar, no monospaced option).

## Cross-engine (fb-595.54.2)

All three engines on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/latex/xengine.sty` and `xengine.lua`, `lib/docx/xengine.lua` and `xengine-reference.sh`; docs/EVAL-LOOP.md, "Adopting the reference breaker"), `params.cross_engine: gate` in `eval.yaml`. The face is the one the typst template sets, Times New Roman (Liberation Serif, its metric twin, vendored; newtx in LaTeX); the "EB Garamond" notes above predate it. The latex and docx filters (`latex/ca3.lua`, `docx/ca3.lua`) are one file for the three Third Circuit briefs; only `TYPE` differs between the copies.

- typst: `show: xengine.with(pitch: 31.4pt, list-indent: 0.5in)`; line boxes of 31.4 pt (body, certificates' text) and 20 pt (headings, quotations, footnotes, tables, cover, signatures); section headings 16 pt (were 1.15 em); every space in pt; `listing-row` contents and authorities; point headings bold (no small capitals: Times New Roman has none); the cover's two counsel columns 14 pt apart (were 1 em); the signature at the middle of the text width as a length.
- latex: as the opening brief; the two counsel columns as minipages in a line of natural height (`\xe@natural`).
- docx: `docx/reference.xml` (`base="xengine"`, from which `fb render` builds the reference: Times New Roman, 28 half points, body 628, single 400 twips; it replaced `make-reference.sh`) adds Body Text Noted; the filter as in the opening brief, the counsel columns as a borderless table, the certificate's signature line as two tab columns (typst `form-sig-line`).
- The findings of the opening brief apply here too and are handled by the same shared filters; the third (the lead before a right tab) was found on this brief's contents row "1. An unbounded information interest ... disclosure.", which LibreOffice wrapped one word early with three 14 pt no-break spaces.
- Before (baseline): latex 10 = 10 pages, 42.4 % of lines with typst's break (first difference p1 line 4); docx 10 vs 11 pages, 17.6 %. After: typst 10 pages; latex and docx 10 pages, 166/166 lines, every page starting and ending on typst's words (XENG-001..003 PASS); tier 1: typst 8 passed, latex 11 passed, docx 12 passed, 0 failed. Every page of the typst, latex and docx PDFs viewed.
