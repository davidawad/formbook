# First Circuit (ca1): opening brief (appellant's principal brief)

- Court: `ca1`, Court of Appeals for the First Circuit (`courts/first-circuit/court-of-appeals/`)
- Doc type: `opening-brief`. Brief of Appellant (FRAP 28(a)); one self-contained folder, no shared files.
- Exemplar: `usage/FILED-EXAMPLE-opening-brief.pdf` (*United States v. Figueroa*, No. 24-1311, filed 2025-03-17; provenance in `usage/SOURCE.md`).
- Sample: `usage/INPUT-opening-brief.md` (excerpt of the filed brief; see Known gaps).
- Status: template built; render and page review re-done 2026-10-14 (pages below). Overlay PDF not regenerated this run (see Overlay). Not reviewed by a human; `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `ca1-brief`. |
| `typst/ca1-opening-brief.typ` | Template. Parameter block at the top: `doc-kind`, `word-limit` (13,000), `required-sections` (FRAP 28(a)(4)-(9) order), `needs-standard-of-review`, `addendum = "required"`. |
| `usage/INPUT-opening-brief.md` | Markdown contract sample (frontmatter + body). |
| `usage/OUTPUT-opening-brief.typst.pdf` | `sh tools/render.sh courts/first-circuit/court-of-appeals/opening-brief usage/INPUT-opening-brief.md` (14 pages). |
| `usage/OVERLAY-figueroa-opening-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/first-circuit/court-of-appeals/opening-brief figueroa-opening-brief` (red = ours, blue = filed, black = agree). |
| `usage/` | The filed exemplar and `SOURCE.md`. |

## Governing rules

Primary source: the First Circuit Rulebook, "effective with amendments through June 1, 2026", <https://www.ca1.uscourts.gov/sites/ca1/files/rulebook.pdf> (downloaded and read on 2026-10-13; page numbers below are the rulebook's printed pages). FRAP text cross-checked against <https://www.law.cornell.edu/rules/frap/rule_32> on 2026-10-13.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| FRAP 32(a)(2)(A)-(F) | Cover: case number centered at top; name of the court; title of the case; nature of the proceeding and court below; title of the brief; counsel's name, address, telephone (rulebook pp. 67-68) | `cover-body` |
| FRAP 32(a)(4) | 8½ × 11; double-spaced; quotations over two lines may be indented and single-spaced; headings and footnotes may be single-spaced; margins at least 1 inch (p. 68) | `page`, `body-leading`, `page-margin`, quotation and footnote styles |
| FRAP 32(a)(5)(A) | Proportionally spaced serif face, 14-point or larger (p. 68) | `type-size = 14pt` for body, headings, footnotes (`show footnote.entry`) |
| FRAP 32(a)(5) (typeface) | Rule names no face: a proportionally spaced serif face, 14 pt or larger. No 1st Cir. local rule names a face (rulebook text read 2026-10-14). Court-named face: none | `font-family = "EB Garamond"` (kept, per `docs/FONTS.md` "No face named"); no substitute needed |
| FRAP 32(a)(6) | Plain roman; italics or boldface for emphasis; case names italicized (p. 68) | markdown emphasis; the template does not guess case names |
| FRAP 32(a)(7)(A), (B)(i) | Principal brief: 30 pages or 13,000 words (p. 68-69) | `word-limit = 13000`; panic when exceeded |
| FRAP 32(f) | Excluded from the count: cover, disclosure, TOC, TOA, oral-argument statement, addendum with statutes, certificate, signature block, proof of service (pp. 69-70) | `strip-oral-argument` (headings matching "oral argument"); the rest is outside the markdown body |
| FRAP 32(g)(1)-(2); Form 6 | Certificate of compliance, Form 6 wording (rulebook p. 113 for Form 6) | `certificate-of-compliance` |
| FRAP 28(a)(1)-(10) | Contents, in order: disclosure statement (if Rule 26.1 applies), TOC, TOA, jurisdictional statement (a)(4), issues (a)(5), case (a)(6), summary (a)(7), argument with standard of review (a)(8), conclusion (a)(9), certificate (a)(10) (pp. 56-57) | `required-sections`; `needs-standard-of-review` |
| FRAP 26.1; Notice to Litigants ¶ 6 | Nongovernmental corporate party: disclosure statement in the first filing and again in front of the TOC of the principal brief (rulebook, Notice to Litigants) | optional `disclosure` field, rendered before the TOC |
| 1st Cir. R. 28.0(a)(1), (b) | Appellant's addendum: the judgment or order appealed from and any supporting explanation; bound at the rear; begins with its own TOC (p. 58) | `addendum = "required"`; the addendum section and its TOC |
| 1st Cir. Notice to Litigants ¶¶ 2, 7; 1st Cir. R. 25.0(e) | Follow FRAP 32 for form. A certificate of service is needed only where FRAP 25(d) requires one; the Notice of Docket Activity is service on ECF filers | `certificate-of-service`, optional (`service.certificate`) |
| FRAP 32(a)(2) (cover color) | Appellant's brief: blue (paper copies only) | not produced; see Known gaps |
| Checklist for Briefs, ca1 (rev. 3/22; secondary) | Footnotes must be the same size as the body text; 1st Cir. R. 32.0 is a disk rule that applies only to paper filings | footnotes at 14 pt; no disk rule |

## Overlay

This run (2026-10-14): `tools/overlay.sh` could not write the PDF, because `usage/FILED-EXAMPLE-opening-brief.pdf` is not in this checkout (`usage/` holds only `SOURCE.md`). The `.txt` page map is unchanged from the earlier run, and the pairings below are from that run.

`usage/OVERLAY-figueroa-opening-brief.pdf` puts our render (red) over the best-matching exemplar page (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only, not a score. Pairings from the last run (word overlap in parentheses):

- Sample p.1 ↔ filed p.1 (89%), p.2 ↔ p.2 (57%): cover and TOC line up.
- p.3 ↔ p.6 (22%): the TOA is a different layout from the filed TOA page; expected.
- p.4-p.9 ↔ filed pp. 8-11, 23-25 (46-84%): body text lines up with the same passages.
- p.10 ↔ p.44 (43%), p.11 ↔ p.45 (58%): conclusion, signature, compliance certificate.
- p.12 ↔ p.1 (28%): certificate of service.
- p.13-14 ↔ p.8 (9%): addendum placeholder. The filed addendum pages are scanned images, so there is nothing to pair with.

## Page review (Gate 2)

Every page of `OUTPUT-opening-brief.typst.pdf` was rendered at 60 dpi and viewed (14 of 14). Typst printed no warnings. Fonts embedded: Times New Roman (vendored) only.

| Page | Content | Result |
|---|---|---|
| 1 | Cover | OK. Case number, court, caption, proceeding, title, counsel all present; fits one page. |
| 2 | Table of contents | OK. Page column aligned; Add-1 for the addendum. |
| 3 | Table of authorities | OK. Only linked citations listed; "Page(s)" column. |
| 4 | Request for oral argument; Statement of jurisdiction; footnote 1 | OK. |
| 5 | Issues presented; Statement of the case | OK. |
| 6 | Statement of facts (A., 1.); footnote 2 | OK. |
| 7 | Facts (end); Summary of argument | OK. |
| 8 | Argument heading I (centered, bold); A. Background & Legal Standard | OK. |
| 9 | Argument I.A (continued) | ACCEPTED: half the page is blank above the conclusion because the last paragraph is kept with the signature block (by design, see the template). |
| 10 | Conclusion; signature block | OK. |
| 11 | Certificate of compliance (Form 6 wording, drawn check boxes) | OK. Word count is the markdown count of the sample (1,159). |
| 12 | Certificate of service | OK. |
| 13 | Addendum; its table of contents (Add-1) | OK. |
| 14 | Addendum entry (placeholder) | ACCEPTED: sample limit; the filed addendum is scanned, see Known gaps. |

Tier-2 findings (OPEN or ACCEPTED): the Argument starts on a new page after the summary (sticky heading block, p. 8); the statement of facts uses A./1. where the filed brief uses roman numerals (the rules leave the numbering open); the typeface is EB Garamond where the filed brief uses Century Schoolbook (the rule names no face, so EB Garamond stays; see `docs/FONTS.md`).

## Known gaps

1. Cover color (blue for the appellant) is not produced. FRAP 32(a)(2) applies to paper copies; the PDF is white.
2. The sample is an excerpt: it transcribes the cover, TOC, TOA, the request for oral argument, jurisdiction, issues, part of the case and facts, the summary, Argument I.A, the conclusion, and the certificates. The filed brief is 61 pages.
3. The addendum entry is a placeholder. The filed addendum pages are scanned images with no text layer, so their text could not be transcribed.
4. The word count is computed from the markdown body (`count-words`). It has not been cross-checked against the PDF text in this box.
5. The table of authorities is built only from `toa:` links. Every citation the filer wants listed must be linked; the template does not detect citations. A link inside a heading is refused (it would list in the TOC as an authority).
6. The disclosure statement is rendered only when `disclosure` is given. The template does not decide whether FRAP 26.1 applies; a nongovernmental corporate party must include one in front of the TOC.
7. The oral-argument section is excluded from the word count by matching its heading text ("oral argument"). That is a heuristic: a differently titled statement would be counted.
8. The standard-of-review check (FRAP 28(a)(8)(B)) is a heuristic: it passes if the body says "standard of review" or any heading contains "standard".
9. The certificate of service is generic CM/ECF wording; it does not list unregistered recipients unless `service.unregistered` is given.
10. Typeface: EB Garamond is kept because the rulebook names no face. A filer who wants Century Schoolbook would use TeX Gyre Schola (`docs/FONTS.md`); that would be a style choice, not a rule requirement.

## Engines

The typst template is the reference; the latex and docx engines render the same sample, each into `usage/`. All three
set Times New Roman 14 pt (latex: newtx, its metric twin), the face the typst template names; the notes above that call
the face EB Garamond are superseded (the docx engine set EB Garamond until fb-595.54.2 and failed `DEF-FONT-002`).

| Engine | Folder | Output | Status |
|---|---|---|---|
| typst (primary) | `typst/` | `usage/OUTPUT-opening-brief.typst.pdf` (14 pages) | tier 1 green |
| latex | `latex/` (`template.tex` + `ca1.lua`, pdflatex) | `usage/OUTPUT-opening-brief.latex.pdf` (14 pages) | tier 1 green; XENG-001..003 PASS |
| docx | `docx/` (`reference.docx` + `ca1.lua`, pandoc, LibreOffice) | `usage/OUTPUT-opening-brief.docx`, `.docx.pdf` (14 pages) | tier 1 green; XENG-001..003 PASS |

Build: `sh docx/make-reference.sh` once (the output is committed), then `sh tools/check.sh <doc-dir> --engine typst|latex|docx`.
The docx contents and authorities carry page numbers from a first LibreOffice pass (`fb render`, docxpass.rs: the
needles `ca1.lua` writes).

### Cross-engine (fb-595.54.2)

The three engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/latex/xengine.sty` and
`xengine.lua`, `lib/docx/xengine.lua` and `xengine-reference.sh`; docs/EVAL-LOOP.md, "Cross-engine gate"), and
`eval.yaml` sets `params.cross_engine: gate`.

- typst: pitches 31.4 pt (body) and 20 pt (headings, quotations, footnotes, tables, cover, certificates) instead of
  leadings; spaces between blocks in pt; `listing-row` contents (36 pt page column) and authorities (56 pt, or the page
  list); section headings 16 pt (was 1.15 em, 16.1 pt: Word has only half points); point headings bold, not small
  capitals; the check boxes a ruled box around an X; the designations, counsel and signature blocks start at the middle
  of the text (`pad(left: 50%)` inside `align` had put them at their own width).
- latex: `\usepackage{xengine}`, `\xe@lines`, `\addvspace`, `\xe@row`, `\xe@footnotemarks`, `\xe@lists`; the
  contents from `\label`/`\pageref`; an ellipsis (U+2026) one em wide with its own text (T1 has no ellipsis glyph);
  no break before a closing mark after a space (". . .,", UAX #14 LB13/LB15d, as typst).
- docx: `reference.docx` from `xengine-reference.sh` (Times New Roman, exact 31.4/20 pt lines); every paragraph with
  exact spacing; contents and authorities rows with a right indent and a leader tab; page numbers by needles; a word
  joiner between ")(" ("32(a)(7)(B)": LibreOffice would break there, typst does not); the closing-mark rule above.
- Before (fresh render on master, /work/artifacts/baseline): latex 13 pages against typst's 14, 158/216 typst lines with the same break (73.1 %); docx 14 pages, 75/216 lines (34.7 %), tier 1 2 failed (TNR-EMBEDDED, DEF-FONT-002: EB Garamond).
- After: latex and docx 14 pages, 216/216 typst lines break after the same word (100 %), every page starts and ends
  on the same word; tier 1 0 failed on all three engines.
- Pages reviewed (60 dpi, every page of the typst, latex and docx PDFs, 14 each): cover, contents and authorities
  (leaders, page numbers), headings, footnotes, signature block, certificates. No overlapping or clipped text, nothing
  in the margins. Remaining tier-2 differences: the cover's gaps differ between engines (each fits the cover to its
  page); the docx cover's closing rule is one thick line; Word's leaders run up to the page number.
