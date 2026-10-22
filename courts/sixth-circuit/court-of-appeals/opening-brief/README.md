# Sixth Circuit (ca6) — opening brief (appellant's principal brief)

Doc type `opening-brief` of `courts/sixth-circuit/court-of-appeals`. Self-contained: the court-root `typst/` and `usage/` (ca9 layout) are not touched.

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-opening-brief.pdf` | Real filed Sixth Circuit appellant's brief (text-based PDF, 90 pp.). |
| `usage/SOURCE.md` | URL fetched, case, docket, filer, date filed, date fetched. |
| `usage/INPUT-opening-brief.md` | Markdown transcription (excerpt) of the exemplar: frontmatter (cover, disclosure, oral-argument statement, designation, authorities) and body. |
| `usage/OUTPUT-opening-brief.typst.pdf` | `sh tools/render.sh courts/sixth-circuit/court-of-appeals/opening-brief usage/INPUT-opening-brief.md` |
| `usage/OVERLAY-netchoice-opening-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/sixth-circuit/court-of-appeals/opening-brief netchoice-opening-brief` |
| `typst/main.typ` | Entry point; reads `--input sample=...`. |
| `typst/ca6-opening-brief.typ` | Template `ca6-brief(meta, md)`. Content-agnostic; the numbers are named parameters traced to the rules. |

Typeface: Times New Roman (Liberation Serif, its metric twin, as the fallback), since fb-595.54.3. FRAP 32(a)(5)(A) and (a)(6) require a proportionally spaced serif at 14 pt and name no face; the Sixth Circuit Briefs Checklist ("Typefaces") gives "such as Times New Roman" as its example, and Times New Roman is the one face all three engines set with the same metrics (LaTeX: newtx; Word: Times New Roman), which the cross-engine gate needs (`docs/FONTS.md`, `docs/EVAL-LOOP.md`). The exemplar's Palatino is a visual comparison only.

Build (from the repo root, with the toolchain on PATH): the render uses only the pinned Times New Roman and the vendored fonts (`--ignore-system-fonts`), and any typst warning fails the build.

## Governing rules

Verified 2026-10-14 against the Sixth Circuit's combined rules PDF, `https://www.ca6.uscourts.gov/sites/ca6/files/documents/rules_procedures/Full%20Rules%20w%20FRAP_0.pdf` (the PDF lists FRAP "last amended December 1, 2025", Sixth Circuit Rules "last amended July 13, 2026", IOP "last amended October 1, 2025").

| Requirement | Rule (text read) | Where in the template |
|---|---|---|
| Cover: case number centred at top, court name, case title, nature of proceeding and court below, brief title identifying the party, counsel name/address/phone | FRAP 32(a)(2)(A)–(F) | `cover-body` |
| Cover colour: appellant's cover blue | FRAP 32(a)(2); 6 Cir. R. 28(d) | **not drawn**, see Known gaps |
| Circuit Rule 26.1 disclosure statement | FRAP 26.1, 28(a)(1); 6 Cir. R. 26.1 | `disclosure-page` (roman i) |
| Table of contents with page references; table of authorities (cases alphabetical, statutes, other) | FRAP 28(a)(2)–(3) | `toc-section`, `toa-section` |
| Statement in support of oral argument, one page max; before the jurisdictional statement | 6 Cir. R. 34(a); 6 Cir. R. 28(b)(1)(B) | `oral-argument-page` (length not checked, see Known gaps) |
| Jurisdictional statement; issues; statement of the case; summary; argument; conclusion; signature | FRAP 28(a)(4)–(9) | body headings (author supplies; order is the author's) |
| Standard of review for each issue (may sit in the argument) | FRAP 28(a)(8)(B) | author's responsibility; not checked |
| Typeface: proportionally spaced, serif, 14-point or larger; plain roman, case names italic | FRAP 32(a)(5)(A), 32(a)(6) | `font-family`, `type-size`; all text 14 pt (footnotes too) |
| Paper, double spacing (quotations over two lines may be single-spaced; headings and footnotes single-spaced), margins ≥ 1 in | FRAP 32(a)(4) | `pitch-double` (31.4 pt), `pitch-single` (20 pt), `page-margin` |
| Length: principal brief ≤ 13,000 words (or 1,300 monospaced lines) | FRAP 32(a)(7)(A)–(B)(i); 6 Cir. R. 28(e)(1)–(2)(A)(i) | `word-limit` (the template panics above it) |
| Excluded from length: cover, disclosure, TOC, TOA, oral-argument statement, certificates, signature block, proof of service, designation | FRAP 32(f); 6 Cir. R. 32(b)(1) | the word count runs over the body only (everything before the Table of Authorities' section and the certificates) |
| Certificate of compliance (type-volume and typeface), Form 6 wording, immediately after the signature | FRAP 32(g)(1)–(2); 6 Cir. R. 32(a) | `certificate-of-compliance` |
| Proof of service when served other than through ECF | FRAP 25(d); 6 Cir. R. 25(f)(2) | `certificate-of-service` (always included; CM/ECF wording as in the exemplar) |
| Designation of relevant district-court documents, at the end of the brief as an addendum: entry number, description, Page ID range | 6 Cir. R. 28(b)(1)(A)(i), 30(g)(1)(A)–(C) | `designation-section` |
| Record references use "Page ID #" for district-court appeals | 6 Cir. R. 28(a)(1) | author supplies the citations; not checked |
| Electronic filing: PDF, native rather than scanned, text-searchable | 6 Cir. R. 25(a)(2) (Form of Electronic Filing) | the render is native text (`pdffonts`: embedded Times New Roman, text extracts) |

## Markdown contract

The sample is one `.md` file: a YAML frontmatter block, then the body. Follows the ca9 contract (`courts/ninth-circuit/court-of-appeals/README.extra.md`) with these ca6 fields:

| Field | Feeds |
|---|---|
| `case_number`, `caption`, `proceeding`, `brief_title`, `counsel`, `phone`, `signature`, `date` | Cover, signature block, certificates |
| `counsel_for` (optional) | One line centred under the cover's counsel block (e.g. "Counsel for ...") |
| `disclosure` | Circuit Rule 26.1 page (markdown text) |
| `oral_argument` | Statement in Support of Oral Argument (markdown text) |
| `designation_intro`, `designation` (rows of `date`, `rno`, `description`) | Designation of District Court Record |
| `service.certificate` (default `true`) | Certificate of Service |
| `authorities` | Table of authorities registry; a `toa:KEY` link without an entry stops the build |

Body: `# Heading` sections (Introduction optional; then Statement of Jurisdiction, Statement of Issues, Statement of the Case, Summary of the Argument, Argument, Conclusion). Under `# Argument`, level 2 is a centred roman point heading, level 3 is A., and so on. Elsewhere level 2 is A., level 3 is 1. Footnotes `text[^key]` with `[^key]: text`. Escape a leading `1.` as `1\.`. `# Addendum` ends the brief (its own pages, Add-1, ...).

## Overlay

`usage/OVERLAY-netchoice-opening-brief.pdf` puts our render (red) over the filed page it best matches (blue); black is agreement. Pages are paired by word overlap, not by index. The map (`-overlay.txt`):

- pp. 1–3 (cover, disclosure, TOC) pair with filed pp. 1–3, with word overlap 100%, 90%, 61%. The disclosure text is the same in both; the TOC's differences are the sample's own page numbers.
- pp. 4–5 (TOA) pair with filed TOA pages 10–11 at 26% and 21%. This is expected: the filed TOA runs seven pages (filed pp. 6–12); ours lists only the authorities the excerpt cites.
- pp. 6–13 (oral-argument statement, Introduction, Jurisdiction, Issues, Statement of the Case, Summary, Argument) pair with filed pp. 13–39 at 30–77%. The filed text is the same, but our excerpt skips paragraphs and uses another face than the exemplar's Palatino.
- pp. 14–18 (conclusion, certificates, designation) pair with filed pp. 86–90 at 47–87%.

Font difference: the exemplar is Palatino Linotype; the template is Times New Roman, a serif face that FRAP 32(a)(5)(A) allows. The overlay therefore never matches glyph for glyph.

## Page review (Gate 2)

All 18 pages of `usage/OUTPUT-opening-brief.typst.pdf` were rasterised at `pdftoppm -r 60` and viewed. Findings and their fixes:

| Page (printed) | Finding | Fix |
|---|---|---|
| iii (TOC continuation) | TOC spilled two lines onto a second page | Reduced the vertical gap between TOC rows (`toc-entry`); TOC now one page. |
| Conclusion / signature | The signature block stood alone on a page after the footnote definitions, because the keep-with-signature rule saw the footnote as the last block | The footnote definitions are split out and passed to both renders; the last paragraph is kept with the signature block. |
| 8 (conclusion) | "Counsel of Record …" line wrapped under the half-page signature column | Changed the signature `lines` to "Counsel for Plaintiff-Appellant". |
| 11–12 (designation) | "Page ID" range wrapped in the middle column | Widened the middle column; the table reads as one row per document. |
| 2 | "FSC" italicised in the intro | Set roman, as in the exemplar. |

Every other page was checked for: cover fitting one page (p. 1); disclosure page numbered i; roman numbering run i–v through the front matter; arabic numbering from 1 at the Introduction; TOC page numbers equal to the printed footers (checked for pp. 9, 10, 11 — Certificate of Compliance, Service, Designation); TOA page lists equal to the body pages where each authority is cited (e.g. *Brown* 1, 7 and *Biden* 2, 6); 14-pt type throughout; no widow lines on the body pages.

Pages reviewed: 18 of 18. Final render: 18 pages, zero typst warnings, `pdffonts` showed only embedded EB Garamond (the face then; Times New Roman since fb-595.54.3, see "Cross-engine layout").

2026-10-22 (fb-595.54.3): all 19 pages of the new typst render viewed (`pdftoppm -r 50`), and all 19 of the latex and docx renders. Changed pages against the 18-page render: the TOC and TOA rows are single-spaced 20 pt rows with the page in a 36 pt / 56 pt column; the TOA runs two pages (iii–iv) and the oral-argument statement is page v; the body is one page longer (pp. 1–9, the conclusion and signature on p. 9); certificates pp. 10–11, designation pp. 12–13 (the table breaks between rows, no row split). Checked: the cover fits one page; roman i–v, arabic from 1; TOC numbers equal the printed footers (Introduction 1, Argument 7, Conclusion 9, Certificate of Compliance 10, Designation 12); TOA pages equal the citing pages; no heading ends a page; the last paragraph stands with the signature block. No defect open.

## Known gaps (for review)

1. **Blue cover not drawn.** FRAP 32(a)(2) and 6 Cir. R. 28(d) require the appellant's cover to be blue. The template draws a white cover, because the colour is a property of the paper copies and the PDF is the ECF filing (the exemplar's PDF cover is also not blue). Decision for David: whether to add a blue cover page variant for paper.
2. **Oral-argument statement length not enforced.** 6 Cir. R. 34(a) limits it to one page; the template does not check it. The sample's is one line.
3. **Word count is computed from the markdown**, not from a word processor. The Form 6 certificate says so. The count of the sample (1,472) is for an excerpt; a full brief must be counted on the final text.
4. **Footnotes are split on blank lines.** A footnote with more than one paragraph would be split wrongly; the sample's footnotes are single paragraphs.
5. **Standard of review, Page ID references and jurisdictional-statement content** (FRAP 28(a)(4)(C)–(D), 28(a)(8)(B)) are the author's responsibility; the template does not check them.
6. **Page count above the 8–14 target.** The sample is 18 pages: front matter is 6 (cover, disclosure, TOC, TOA ×2, oral-argument statement), body 8 (an excerpt; the exemplar's full body runs 73 pages), certificates and designation 4. A shorter sample would have to cut the front matter or the body; the body is kept at a length that exercises the argument headings, footnotes and the signature-keeping rule.
7. **Excerpt, not the whole brief.** The sample transcribes the cover, disclosure, TOC/TOA structure, oral-argument statement, part of the Introduction, Jurisdiction, Issues, Statement of the Case, Summary, Argument I.A and II.A, Conclusion, certificates and the full designation. Issue 3 of the Statement of Issues is omitted (its text is garbled in the PDF's text layer).
8. **Designation is the exemplar's list.** The template places it after the certificate of service, as the exemplar does. 6 Cir. R. 30(g)(1)(B) requires only that it be "at the end of the brief as an addendum".

## Log

- 2026-10-14: exemplar found (CourtListener RECAP, ca6, 25-5660, entry 16); rules read; template and sample written; render (18 pp.), overlay, full page review; findings fixed as above.
- 2026-10-16: verification pass (fb-595.26.6), see below.

## Engines

Same rules and numbers as the typst template; the typst output is the reference every engine matches line for line (Gate 4 CROSS-ENGINE, `params.cross_engine: gate` in `eval.yaml`).

**latex** (`latex/template.tex`, `latex/*.lua`; pdflatex). The shared layout package `lib/latex/xengine.sty` (inlined into the generated `.tex` by `fb render`) and the inline rules `lib/latex/xengine.lua`: Times (newtx) 14 bp in 31.4 bp line boxes (body) and 20 bp boxes (headings, footnotes, tables, cover, certificates), the typst spaces as `\addvspace`, contents and authorities rows as `\xe@row` with `\pageref` and `.aux` page lists, the cover's counsel columns as typst's grid. XENG-001..003 pass: every page and every line breaks where typst breaks it.

**docx** (`docx/reference.xml`, `docx/ca6-opening-brief.lua`). fb render builds `reference.docx` from `docx/reference.xml` (pandoc's default reference with these styles, fb-595.63; the old `make-reference.sh`, `reference-src/`, `reference.docx`, `reference-addendum.docx`, `render.sh` and `pages.lua` are gone): the recipe of `lib/docx/xengine-reference.sh`, Times New Roman 14 pt, the typst face, the only font embedded (theme fonts stripped). Every paragraph the filter writes carries the typst line box and spaces (exact line spacing, twips = 20 x pt) and its text as runs with typst's break rules (`lib/docx/xengine.lua`); the contents and authorities rows wrap before their page column (a right indent) with three no-break spaces and a dot leader to the page. TOC and TOA page numbers come from fb render's multi-pass engine (fb-595.63): the filter writes a needle for every heading (its label, title and the text after it, so the body heading is found, not its contents row), citation (from its first word, as typst tags it; kind N in a footnote) and section start to `FORMBOOK_NEEDLES`, reads `FORMBOOK_PAGES`, writes its page-number footers (the number in a 20 pt line; `Add-1`, `Add-2` in an addendum) to `FORMBOOK_FOOTERS` and the last section to `FORMBOOK_FINAL`. The old reference's Word 2013 compatibility mode is not carried over: without it LibreOffice sets the phone number (cover, signature block) 53.65 pt wide, typst 53.66 pt (with it 54.95 pt); nothing else moves. XENG-001..003 pass. The TOC and TOA are text, so they do not update in Word if the text changes (render again); Word itself may paginate slightly differently from the LibreOffice PDF that is checked (`docs/DOCX.md`). BLOCKED: none.

All three engines certify the same word count: each counts the markdown source of the body as typst's `count-words` does, and the certificate names the typeface, not the program.

### Cross-engine layout (fb-595.54.3)

Ported onto the shared model (`lib/typst/xengine.typ`, `lib/latex/xengine.sty`, `lib/docx/xengine.lua`; `docs/EVAL-LOOP.md`, adoption checklist). typst: Times New Roman (was Liberation Serif in typst, newtx in LaTeX, EB Garamond in Word: three faces, docx DEF-FONT-002 failed), pitches instead of leadings, spaces in pt, section headings at 16 pt (whole half points; was 1.15 em), `listing-row` contents and authorities, the page number in a 20 pt line, the right half of the cover and signature at an explicit 3.25 in (typst resolved `pad(left: 50%)` against the padded block, 9 pt short of the half), the certificate naming the typeface only. A space before a closing or separating mark (". . . .") is a no-break space in the LaTeX and Word filters, as Unicode line breaking (typst) treats it. Result: typst 19 pages; latex and docx 19 pages, 100 % of lines alike (before: latex 70.0 %, docx 41.8 %, both 19 pages against 18).

## Verification pass 2026-10-16 (fb-595.26.6)

- Re-rendered `usage/OUTPUT-opening-brief.typst.pdf` with `tools/render.sh` (exit 0, no typst warnings): 18 pages, the same count as the committed render; before the fixes below its text was identical to the committed PDF, so it was not stale. Overlay rerun; map unchanged except the cover (98% to 100%, from the added counsel line).
- All 18 pages viewed at 60 dpi (pages 1, 9, 14, 17, 18 again after the fixes); the 18 overlay pages viewed at 40 dpi, and overlay page 1 (cover against the filed cover) at 150 dpi.
- Fixed:
  - p. 3 (Statement of Jurisdiction): "28 U.S.C. §§ 1651" broke between the two section signs ("§" at the line end, "§ 1651" on the next line). The no-break rule matched only a single sign; it is now `[§¶]+ \S+`, so "§§ 1651" stays whole.
  - pp. 11–12 (designation): straight apostrophes ("NetChoice's") in the table cells, which bypassed the markdown render. The cells now go through `inl`, as the rest of the frontmatter does.
  - Cover: the filed cover's "Counsel for Plaintiff-Appellant NetChoice" line was not transcribed and the template had no place for it. Added the optional `counsel_for` field. With it the single right-half counsel column no longer fit one page, so several counsel groups are now set in two columns across the measure (one group stays in the right half), as on the filed cover.
  - Certificate of compliance: "14-point" is kept on one line (boxed).
  - Signature block and cover: an indented italic line too long for its column now wraps with the same indent.
- Remaining gaps: as in Known gaps above. (Since fb-595.54.3 the latex and docx engines read `counsel_for` too.) The designation table does not repeat its header row on the continuation page (p. 12).
