# Appellate Division (all four departments): reply brief

Doc type `reply-brief` of court `nyappdiv` (folder: `courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/`). One self-contained folder per doc type:

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-reply-brief.pdf` | Real filed reply brief, First Department, No. 2022-02719 (NYSCEF Doc. 36), text layer present |
| `usage/SOURCE.md` | URL fetched, case, docket, filer, date filed, date fetched, why this exemplar, its limits |
| `usage/INPUT-reply-brief.md` | Markdown transcription of part of the exemplar (see "Known gaps", item 2) |
| `usage/OUTPUT-reply-brief.typst.pdf` | `sh tools/render.sh … usage/INPUT-reply-brief.md` (13 pages) |
| `usage/OVERLAY-integratenyc-reply.pdf`, `.txt` | `sh tools/overlay.sh … integratenyc-reply` (red = our render, blue = filed exemplar page, black = both) |
| `typst/main.typ` | Entry point (reads the sample named by `--input sample=`) |
| `typst/nyappdiv-reply-brief.typ` | The template, `nyappdiv-reply-brief(meta, md)`. Structure adapted from `courts/second-circuit/new-york/state/court-of-appeals/opening-brief/typst/`; numbers and rules are Part 1250's |

Build (from the repo root, toolchain on PATH):

```sh
sh tools/render.sh courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/reply-brief usage/INPUT-reply-brief.md
sh tools/overlay.sh courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/reply-brief integratenyc-reply
```

Toolchain used: typst 0.15.0, poppler (pdftoppm 26.09.0), ImageMagick 7.1.2, gawk, jq, from conda-forge via micromamba. Renders use only the vendored fonts (`--ignore-system-fonts`); any typst warning is a failure. The render succeeded with no warnings. `pdffonts` shows Times New Roman Regular, Bold and Italic embedded (2026-10-22).

## Governing rules

Part 1250 (Practice Rules of the Appellate Division) applies to all four departments: LII lists it under "Subchapter E – All Departments". Verified against the copy below on 2026-10-14.

| Rule | What it governs | Where it is in the template | Source |
|---|---|---|---|
| 22 NYCRR 1250.8(d) | Reply brief: "shall conform to the requirements of subdivision (b), without repetition"; a cross-appellant's reply answers the cross-appeal | Section structure. The template enforces no section list; the sample follows the exemplar (Preliminary Statement, Argument, Conclusion) | https://www.law.cornell.edu/regulations/new-york/22-NYCRR-1250.8 |
| 22 NYCRR 1250.8(b) | Cover: title; upper right, argued or submitted, time requested and the argument's presenter; lower right, the filing attorney's name, address, telephone, email, and whom they represent. Contents: table of contents (point headings), table of cases and authorities | `cover-body` (upper right: `argument`; lower right: `counsel`); `toc-section`; `toa-section` | same |
| 22 NYCRR 1250.8(f)(1) | Serifed, proportionally spaced typeface; capitals and bold only in headings and quotations; no narrow or condensed face | `font-family` (Times New Roman, vendored); no bold or caps in body text | same |
| 22 NYCRR 1250.8(f)(1)(i) | Body of a proportionally spaced brief in 14-point type; footnotes at least 12 point | `type-size = 14pt`; footnotes set at body size (the exemplar's footnotes are at body size too) | same |
| 22 NYCRR 1250.8(f)(2) | Computer-generated reply briefs: not more than 7,000 words, inclusive of point headings and footnotes, exclusive of signature blocks and of pages with the contents, table of citations, proof of service, certificate of compliance, or addendum | `word-limit = 7000`; `count-words` over the body; the template panics above it | same |
| 22 NYCRR 1250.8(h) | One-inch margins on all sides; text double spaced; quotations over two lines may be indented and single spaced; headings and footnotes may be single spaced; pages numbered consecutively | `page-margin`, `body-leading`, `single-leading`, the `quote` show rule, the footer | same |
| 22 NYCRR 1250.8(j) | Printing specifications statement at the end of the brief: the means of preparation, the typeface name, point size, line spacing, and the word count (the signer's representation covers it) | `printing-statement(words)`: the typeface is the one this file sets (Times New Roman), the word count is the one computed from the sample | same |
| 22 NYCRR 1250.8(g)(2) | Typewritten reply briefs: 25 pages. Not used here: this brief is computer-generated and the (f)(2) word limit applies | none | same |

Not verified in this run: the Appellate Division's own department rules (First Department, 22 NYCRR Part 600; Second, Part 670; Third, Part 800; Fourth, Part 1000). They may add requirements that apply in one department only. Also not verified: the proof-of-service rule (where and how the proof is made). The affidavit page is a blank form (see below).

Source access: nycourts.gov returned HTTP 403 to this box and nyrules.elaws.us returned 503, so the Part 1250 text is the Cornell LII copy (LII notes its state regulations are updated quarterly; the copy reads "Adopted … eff. 9/17/2018"). Check it against the official text before relying on it.

Rules the template decides (convention, not rule): sub-headings are numbered as in the sibling NY folders (I., A., 1., a.); the cover's caption and the counsel are printed in the order the exemplar uses; the printing statement and the proof of service are the last two pages, with the printing statement in the table of contents as the exemplar has it; the signature block sits with the last paragraph of the text.

## What the overlay shows
| Ours (PDF page) | Filed page | Word overlap | What is on our page |
|---|---|---|---|
| p.1 | 1 | 61.2% | cover |
| p.2 | 3 | 69.6% | table of contents |
| p.3 | 4 | 51.8% | table of authorities |
| p.4 | 8 | 97.2% | Preliminary Statement (body p.1) |
| p.5 | 9 | 93.8% | Preliminary Statement (cont.), Argument I (body p.2) |
| p.6 | 10 | 91.8% | Argument I (cont.), I.A begins (body p.3) |
| p.7 | 11 | 87.6% | I.A (body p.4) |
| p.8 | 12 | 63.3% | I.A (end): the CFE and Center points, Klostermann (body p.5) |
| p.9 | 17 | 51.2% | Point II and II.A (body p.6) |
| p.10 | 18 | 56.8% | II.A (body p.7) |
| p.11 | 36 | 52.0% | II.A (end), the Conclusion and the signature block (body p.8) |
| p.12 | 38 | 71.4% | printing specifications statement |
| p.13 | 3 | 6.1% | proof-of-service form (blank) |

Filed page numbers are the exemplar's own PDF pages (its body runs from PDF page 8).

Read it as a diagnostic. The high-overlap pages are the body text the sample transcribes. The low-overlap pages are the generated parts the exemplar does not have in the same form: the table of authorities (its own pages are a different table), and the blank proof of service (no counterpart in the copy). The printing statement pairs with the filed statement on its last page, which is a real match. Any blue text that does not sit under red is material the sample leaves out on purpose.

## Render and page review

- Render: ok (exit 0, no typst warnings), 13 pages.
- Overlay: ok (`overlay.sh` wrote the PDF and the map from the final render).
- Pages reviewed: 13 of 13. Each page was rendered at 60 dpi with `pdftoppm -r 60` and looked at.
- Defects found and fixed along the way:
  1. The cover did not fit one page at any spacing. The body's text edges (`top-edge`/`bottom-edge` at ascender and descender) make each line box taller, and the cover has about 35 lines. The cover now uses glyph bounds for its own line boxes (`cover-body`), and the counsel telephone numbers share a line with their email addresses. The cover fits on one page at the largest spacing in the ladder.
  2. The signature block printed "Dated" and the place in the wrong order (the sibling's order). It now reads "Dated: August 18, 2023" then "New York, New York", as the exemplar does. The "By:" line sits in the Sidley block (the block marked `by: true`), not the first block.
  3. The printing statement names the typeface the PDF uses (Times New Roman since 2026-10-22; was EB Garamond).

## Known gaps (not fixed here; for David)

1. **Typeface.** The rule asks for a serifed, proportionally spaced face "such as Times Roman" at 14 point; the template sets Times New Roman, the house standard and the exemplar's face (2026-10-22, fb-595.68.37; was EB Garamond). Checked 2026-10-15 against the LII copy of 1250.8(f)(1).
2. **Sample is an excerpt.** The exemplar is 38 pages; the body is pages 1 to 30. The sample transcribes: the Preliminary Statement (complete); Argument I's opening and PDE paragraphs; I.A's first part and its Klostermann paragraph; Point II, II.A's first four paragraphs (the cross-appeal and *N.Y. State Inspection* points) and the start of the B & H paragraph; the conclusion; and the signature block. It does not transcribe: I.A's remaining paragraphs; I.B; II.A's last paragraphs; II.B and its subparts; the footnotes (their numerals are dropped from the text, and footnote text is not transcribed); the cover's inside page (counsel continuation, Public Counsel and the other Sidley attorneys, and the PDE intervenor caption). The render therefore jumps from the middle of II.A to the Conclusion. The sample is for layout comparison, not a copy of the brief.
3. **Word count and the printing statement.** The count printed in the sample's printing statement is 1,652: the sample's own count, not the filed brief's (6,915). The template computes the count from the markdown body, as 1250.8(f)(2) and (j) intend for the full brief.
4. **Proof of service.** The exemplar copy has none. The affidavit page is a blank form (STATE OF NEW YORK / COUNTY OF / deposes and says ... ); its placement and content are not verified against Part 1250 and should be checked before use.
5. **Inside cover and continuation of counsel.** The template prints the lower-right counsel on the cover only. The exemplar continues the counsel and caption on its inside cover; the template does not reproduce that page.
6. **No separate statement of questions presented or statement of the case.** The exemplar has none. Under 1250.8(d) a reply conforms to (b) "without repetition", so the template does not require them. Whether a reply should carry a short questions-presented section is a call for David, not verified here.
7. **Layout note.** On body page 5 (PDF page 8), about a quarter of the page is blank: the Point II heading and its first paragraph are kept together and move to the next page. A different sample length would move this break.
8. **Cover typography.** The cover's line box uses glyph bounds (see defect 1). The body uses the sibling's ascender/descender metrics. The two have different line heights; the cover is not body text, so this is deliberate.
9. **Footnotes.** Footnote text is set at body size (14 pt). The rule's minimum is 12 pt; the exemplar's footnotes are at body size, so the template follows the exemplar.

## Exemplar search (for the record)

Searches run on 2026-10-14:

- **CourtListener API** (`api/rest/v4/search`, `court=nyappdiv`, `type=r`): no results. RECAP does not carry Appellate Division briefs.
- **Web searches** for Fourth Department reply briefs (PDF, "reply brief", "Plaintiff-Appellant", "Brief for"): only procedural material and motion decisions posted by the Law Reporting Bureau (e.g. Fourth Department orders on extensions to file reply briefs). No reply brief PDF.
- **Web search for Appellate Division reply briefs** on public-agency and advocacy sites (ag.ny.gov, nyclu.org, courtlistener): found the IntegrateNYC reply brief (First Department, No. 2022-02719) hosted by Public Counsel; downloaded, checked (38 pages, text layer, NYSCEF stamp, Times, 1250.8(j) statement). Used.
- Not checked: the Attorney General's Appeals Bureau pages for other Appellate Division briefs; NYSCEF itself (not reachable from this box); the Fourth Department's own filed-brief pages (nycourts.gov returned 403).

## Status

- exemplar: yes
- render: ok (13 pages, no warnings)
- overlay: ok
- pages reviewed: 13 of 13
- court.json, `tools/tracker.sh`, STATUS.md, the root README and other courts: not touched.

## Verification pass 2026-10-16 (fb-595.26.22)

- Render: `sh tools/render.sh …/reply-brief usage/INPUT-reply-brief.md`, exit 0, no typst warnings, 13 pages (same as the committed PDF), EB Garamond Regular/Bold/Italic only.
- Pages viewed: 13 of 13 at 60 dpi; page 2 (the TOC) viewed again after the fix below. The text of pages 3–13 is identical to the committed render (`pdftotext` diff). Overlay pages viewed as a 40 dpi contact sheet, with page 4 (body) at 100 dpi.
- Overlay: `sh tools/overlay.sh …/reply-brief integratenyc-reply`, exit 0; the page map is unchanged (table above). On body pages our lines run close to the filed ones; the drift over a page is under a line.
- Defect fixed: **TOC page numbers on wrapped entries** sat on the first line of the title while the dot leader ended on the last line (Points I and II, and both A. sub-points). The page-number column is now bottom-aligned (`toc-entry`), so the number ends the leader. Tier 2.
- Still open: the known gaps above (sample is an excerpt, blank proof-of-service form, no inside cover, the quarter-page gap on body page 5).

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"; fb-595.68.37): Times New Roman 14 pt (1250.8(f)(1)), footnotes at the same size, the body in exact 28 pt line boxes (double spacing, 1250.8(h)), single lines (cover, headings, quotations, tables, footnotes, signature, page number) in 16.1 pt boxes, first-fit ragged-right breaking with no kerning, ligatures or hyphenation.

**docx** (`docx/reference.xml`, `docx/nyappdiv-reply-brief.lua`; outputs `usage/OUTPUT-<id>.docx` and `.docx.pdf`, built by `fb render`, no shell).

- The filter writes every paragraph with the typst template's spacing in twips: the cover (docket and argument notice in a two-column row, court, double rules, caption, title, counsel, whom they represent), the contents and authorities with page numbers from `fb render`'s needles (front matter i, ii; body from 1; cover unnumbered), the headings, block quotations, a paragraph pandoc would read as a list ("(1) ...") kept a paragraph as in typst, the last paragraph kept with the signature block, the printing specifications statement with the word count (counted from the markdown rule for rule as typst counts) and the affidavit of service (blanks as underscores). A paragraph that anchors a footnote is left to pandoc (Body Text), which writes the note in Footnote Text.
- Gate 4 CROSS-ENGINE is gated (`eval.yaml`, `params.cross_engine: gate`): the docx breaks every line and page where typst does (XENG-001..003 PASS).
- Word may paginate slightly differently from LibreOffice (docs/DOCX.md); the checked PDF is LibreOffice's.
