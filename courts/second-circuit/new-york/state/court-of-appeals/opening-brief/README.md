# New York Court of Appeals: opening brief (appellant's principal brief)

Doc type `opening-brief` of court `ny` (folder: `courts/second-circuit/new-york/state/court-of-appeals/`). One self-contained folder per doc type:

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-people-v-trump-entrepreneur-apl-2016-00115-opening-brief.pdf` | Real filed brief (Respondents-Appellants, APL-2016-00115), text layer present |
| `exemplars/SOURCE.md` | URL fetched, case, docket, filer, date signed, date fetched, why this exemplar, its limits |
| `samples/INPUT-tei-opening-brief.md` | Markdown transcription of the exemplar (a portion; see below) |
| `samples/OUTPUT-tei-opening-brief.pdf` | `sh tools/render.sh … samples/INPUT-tei-opening-brief.md` (14 pages) |
| `samples/OVERLAY-tei-opening-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh … tei-opening-brief` (red = our render, blue = filed exemplar page, black = both) |
| `typst/main.typ` | Entry point (reads the sample named by `--input sample=`) |
| `typst/ny-opening-brief.typ` | The template, `ny-opening-brief(meta, md)`. Structure copied from `courts/ninth-circuit/court-of-appeals/typst/`; numbers and rules are NY's |

Build (from the repo root, toolchain on PATH):

```sh
sh tools/render.sh courts/second-circuit/new-york/state/court-of-appeals/opening-brief samples/INPUT-tei-opening-brief.md
sh tools/overlay.sh courts/second-circuit/new-york/state/court-of-appeals/opening-brief tei-opening-brief
```

Toolchain used: typst 0.15.0, poppler (pdftoppm 26.09.0), ImageMagick 7.1.2, gawk, jq, from conda-forge via micromamba. Renders use only the vendored fonts (`--ignore-system-fonts`); any typst warning is a failure. The render succeeded with no warnings.

## Governing rules

Verified against the copies below on 2026-10-14. Note: the official nycourts.gov and Justia texts were unreachable from this box (Cloudflare 403); the copies used are Cornell LII's (which reproduces the Court of Appeals' 500.1 and 500.13 text, with an amendment note for 500.13 dated eff. 6/22/2016). LII says its state regulations are updated quarterly, so currency against the official text should be re-checked before this is relied on.

| Rule | What it governs | Where it is in the template | Source |
|---|---|---|---|
| 22 NYCRR 500.1(j) | Typeface: serifed, proportionally spaced; body 14-point; footnotes at least 12-point; no bold or all-capital body text (headings exempt) | `font-family`, `type-size`; footnotes at body size; `certificate-of-compliance` (states the typeface, point size, line spacing, as the exemplar's certificate does) | https://www.law.cornell.edu/regulations/new-york/22-NYCRR-500.1 |
| 22 NYCRR 500.1(l) | One-inch margins on all sides; double spacing (quotations over two lines may be single spaced, indented; headings and footnotes may be single spaced); consecutive page numbers centred at the bottom | `page-margin`, `body-leading`, `single-leading`, `quote` show rule, footer | same |
| 22 NYCRR 500.1(f) | Disclosure statement for a business entity, before the table of contents | `disclosure-page` (printed when `disclosure:` is given) | same |
| 22 NYCRR 500.1(e) | Proof of service affixed to the inside of the back cover | `affidavit-of-service` (blanks only) | same |
| 22 NYCRR 500.1(h) | Cited material not otherwise readily available | addendum (`# Addendum`), excluded from the word count | same |
| 22 NYCRR 500.13(a) | Contents: table of contents, table of cases and authorities, questions presented, point headings; statement of related litigation before the contents; original signed and dated; "original" identified on the cover | front matter order; `related-litigation`; `toc-section`, `toa-section`; `signature-block` | https://www.law.cornell.edu/regulations/new-york/22-NYCRR-500.13 |
| 22 NYCRR 500.13(b) | Brief cover: white; caption; counsel's name, address, telephone and facsimile; date completed; upper right corner: argument request (time requested and the presenter) or submission without oral argument; no plastic covers | `cover-body`: argument block in the upper right; counsel grid; `date_completed` | same |
| 22 NYCRR 500.13(c)(1) | Principal brief of appellant: 14,000 words; signatory certifies the count (may rely on the word processor's count) | `word-limit` (panics above it); `count-words` over the body; `certificate-of-compliance` prints the count | same |
| 22 NYCRR 500.13(c)(3) | Word limit excludes the statement of related litigation, disclosure, contents, table of authorities, questions presented, and any addendum | `without-section(body-md, "questions presented")`, and the front matter and addendum are outside `body-md` | same |

The filed exemplar's certificate cites "22 NYCRR PART 500.1(j)" and states Times New Roman, 14 point, double spaced, and a word count of 12,959 words. The template follows that form.

Rules not ruled by the sources above, decided by the template (convention, not rule): the NY statement of issues is "Questions Presented", numbered; point headings are numbered I., A., 1., a. throughout (the exemplar does the same in its Argument and in its Statement of the Case); section headings are centred and bold capitals; the signature block sits with the last paragraph of the text; the cover uses two columns for counsel to keep the cover on one page.

## What the overlay shows

`samples/OVERLAY-tei-opening-brief.txt` pairs each of our 14 pages with the filed page of most shared words:

| Ours | Filed page | Word overlap |
|---|---|---|
| p.1 cover | 1 | 92.0% |
| p.2 disclosure + related statement | 13 | 68.4% |
| p.3 contents | 2 | 63.1% |
| p.4 table of authorities | 9 | 16.6% |
| p.5 Preliminary Statement | 15 | 80.9% |
| p.6 Preliminary Statement (cont.) | 16 | 88.6% |
| p.7 Preliminary Statement (end), Questions Presented 1 and 2 | 17 | 61.1% |
| p.8 Question 3, Statement of Jurisdiction, Statement of the Case | 21 | 68.3% |
| p.9 Statement of the Case (end), Argument, Point I | 31 | 36.7% |
| p.10 Point I.A | 32 | 98.0% |
| p.11 Point I.A (end), footnote 2 | 34 | 45.2% |
| p.12 conclusion and signature | 65 | 95.0% |
| p.13 certificate of compliance | 66 | 78.2% |
| p.14 affidavit of service (blanks) | 106 | 7.6% |

Read it as a diagnostic. The high-overlap pages are the body text the sample transcribes. The low-overlap pages are the parts the exemplar does not have in the same form (the table of authorities, the certificates, the blank affidavit), and the page pairing on those is meaningless. Any blue text that does not sit under red is material the sample leaves out on purpose (the rest of the 156-page brief).

## Render and page review

- Render: ok (exit 0, no typst warnings), 14 pages.
- Overlay: ok (`overlay.sh` wrote the PDF and the map from the final render).
- Pages reviewed: 14 of 14. Each page was rendered at 60 dpi with `pdftoppm -r 60` and looked at. Defects found and fixed in the template along the way:
  1. The cover was taller than the page at any spacing. The counsel blocks now sit side by side and the argument request shares a row with the docket.
  2. Two counsel addresses were on separate lines. Tel. and Fax now share a line.
  3. The related-litigation statement took a page of its own. It now shares the disclosure page.
  4. The conclusion's signature block ran past the bottom margin. Firms now sign side by side.
  5. The certificate of compliance's signature block was orphaned on the next page. The certificate is now one unbreakable block, with names only (no addresses) to keep it on the page.
  6. Blank lines (signature "By:" line, affidavit blanks) did not draw, because `underline(h(…))` draws nothing. They are now drawn lines.
  7. A wrapped table-of-contents entry pushed its page number onto its own line. Each contents entry is now three columns (label, title with leader, page number).
  8. The signer was printed twice (once on the "By:" line and again in the names). The "By:" line now stands alone above the first firm's names.
- Remaining known layout: on the page before the conclusion (PDF p.11, numbered 7) about half of the page is blank (re-checked 2026-10-16). That is the keep-with-signature rule: the last paragraph and the signature block are kept together, and the conclusion does not fit beneath the Point I.A paragraph. A different sample length would move this break.

## Known gaps (not fixed here; for David)

1. **Typeface (kept EB Garamond; not a gap in the rule).** Typeface row: face required = none. 500.1(j) requires "a serifed, proportionally spaced typeface, such as Times Roman": Times is an example, so any serifed proportional face complies. Vendored substitute = none needed; the template keeps **EB Garamond** (`fonts/eb-garamond`, the court-named-face exception in `docs/FONTS.md` does not apply). Fit: n/a. The point size is the rule's 14 pt. EB Garamond has a smaller x-height than Times New Roman, so 14 pt looks smaller than the exemplar's Times 14 pt; the visual match is not the rule's. If David reads the "such as Times Roman" example as the court's face, set `font-family` to `"Liberation Serif"` (vendored, Times-metric, `docs/FONTS.md`) and re-render; the certificate prints the name from `font-family`.
2. **Sample is a portion.** The sample transcribes the cover, disclosure, questions presented, the early preliminary statement, jurisdiction, part of the statement of the case, Point I and its A., the conclusion, and the signature. The exemplar's full 156 pages are not transcribed. The word count on the sample's certificate (1,471) is the sample's count, not the filed brief's.
3. **Statement of related litigation** is not in the exemplar (the copy shows none). The template generates it from `related_litigation:`. The sample's text ("None. (Placeholder: …)") is a placeholder and says so.
4. **Affidavit of service** is not in the exemplar copy. The template prints blank form lines only. The rule puts the proof on the inside of the back cover; a PDF cannot show that placement, so the page is the last page of the render.
5. **Disclosure statement** in the sample shows items 1 and 2 of the exemplar's list; item 3 onward is not transcribed.
6. **Footnotes** are printed at body size (14 pt). The rule allows 12 pt minimum; the exemplar's footnotes are at body size, so the template follows the exemplar.
7. **Table of authorities** uses the NY groups (Cases, Statutes, and the rest). The rule does not set TOA order; the template groups by kind and sorts by name (a convention choice).
8. **Cover colour:** plain white, as 500.13(b) requires. Nothing is coloured.
9. **The exemplar's OCR.** The filed copy is a scan with an OCR text layer. Some passages in later pages are garbled. The sample transcribes only the early pages, so the garbled text is not in the sample.

## Exemplar search (for the record)

Found and ruled out:

- NYCLU-hosted reply brief for the plaintiffs-appellants, Hurrell-Harring (Court of Appeals, 2010, 57 pp., text layer): a reply, not an opening brief. Downloaded and checked; not used.
- People v. Watkins respondent's brief (APL-2023-00099, hosted by statecourtreport.org): a respondent's brief, not an opening.
- Court of Appeals motion papers (NYP Holdings, PBA motion for leave, 2023): motions, not opening briefs.
- Clerk's weekly "new filings" lists at nycourts.gov/CTAPPs/Filings: lists, not briefs.
- A 1973 brief at digitalcommons.nyls.edu: a scan without a text layer (not checked further).
- NY Court of Appeals rules pages at justia.com (403) and courtrules.net (403): not reachable; LII used instead.

Used: the AG-posted Trump Entrepreneur Initiative opening brief (see `exemplars/SOURCE.md`).

## Verification pass 2026-10-16 (fb-595.26.21)

- Render: `sh tools/render.sh … samples/INPUT-tei-opening-brief.md` exit 0, no typst warnings, 14 pages (the same count as the committed PDF; the committed PDF was not stale in page count). `pdffonts`: EB Garamond only.
- Pages viewed: 14 of 14 at 60 dpi (`pdftoppm -r 60`), and page 3 (contents) again after the fix. The 14 overlay pages were viewed at 40 dpi, and the exemplar's page 1 against our cover.
- Overlay: rerun after the fix; the page map is unchanged (table above, page labels corrected to what the pages now hold). Body pages 5, 6, 10 and 12 overlap 81 to 98% with the filed pages; the low pages are the tables, certificates and the blank affidavit, as before.
- Defect fixed: in the table of contents, a wrapped entry printed its page number on the first line while the dot leader ended on the last line, so the leader pointed at nothing (Point I and Point I.A). The page-number column is now bottom-aligned, so the number sits at the end of the leader.
- Checked and found right: cover on one page with the argument request upper right, docket, caption, counsel with telephone and fax, date completed (500.13(b)); disclosure and related-litigation statement before the contents (500.1(f), 500.13(a)); body line pitch 31.4 pt at 14 pt (`pdftotext -bbox`; the exemplar's is 32.2 pt), footnotes single spaced at body size; page numbers centred, front matter roman, body from 1; certificate and affidavit each on one page.
- Remaining gaps: as listed under "Known gaps". Also: the sample's `word_processor: "Microsoft Word"` is transcribed from the exemplar's certificate, so the rendered certificate names Word although this PDF is a typst render; a filer sets the field to what they used. Cover layout differs from the exemplar's (docket upper left, not centred under the argument request; designations not italic or right-aligned): tier 3, not chased.

## Status

- exemplar: yes
- render: ok (14 pages, no warnings)
- overlay: ok
- pages reviewed: 14 of 14
- court.json, `tools/tracker.sh`, STATUS.md, the root README and other courts: not touched.

## Engines

**docx** (`docx/`): `docx/build-reference.sh` builds `docx/reference.docx` from pandoc's default reference (EB Garamond 14 pt, body lines exact 31.4 pt, 0.5 in first-line indent, 14 pt single-spaced footnotes, letter page, 1 in margins, centred PAGE footer, empty cover footer). `docx/ny-opening.lua` builds the cover, disclosure, related litigation, contents, authorities, signature, certificates and affidavit from the same frontmatter as the typst template. Sections: cover (no number), front matter (lower roman), body and certificates (arabic from 1). Point headings are numbered I. / A. / 1. / a. as text by the filter. Render: `sh tools/render.sh --engine docx courts/second-circuit/new-york/state/court-of-appeals/opening-brief samples/INPUT-tei-opening-brief.md` writes `samples/OUTPUT-tei-opening-brief.docx`.

- Matches the typst form: typeface, size, double spacing, margins, cover contents and order, front-matter order, the certificate of compliance text, the affidavit blanks. Word count 1,471 on the sample, the same as the typst render (`count-words` rule reproduced).
- Differs: the table of contents is a TOC field (placeholder text until a field update in Word or LibreOffice); the table of authorities lists the authorities without page numbers; the addendum is numbered 1, 2, ... (typst: Add-1, ...) and has no addendum contents list; the affidavit blanks are typed underscores, not drawn lines; the cover and signature blocks are borderless tables, so their layout is not the typst layout. Pagination is Word's or LibreOffice's, not measured.
- docx gate status: `.docx` written and validated (`unzip -tq` ok; `xmllint --noout` on all 18 XML and rels parts, no errors). The `.docx.pdf` gates (Gates 0 to 3) are **BLOCKED**: LibreOffice (`soffice`) is not installed on the box that built this, so no `.docx.pdf` was rendered and no page was viewed (pages reviewed: 0).
- BLOCKED, for the PR: (1) TOC page numbers: a field update is needed before they appear; (2) TOA page numbers: not generated, LibreOffice does not honour TA/TOA fields; (3) addendum page prefix `Add-` and addendum contents: not reproduced in the docx (one footer per section, no prefix); (4) every `.docx.pdf` gate, until a LibreOffice run.
