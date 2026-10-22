# First Circuit (ca1): reply brief (appellant's reply)

- Court: `ca1`, Court of Appeals for the First Circuit (`courts/first-circuit/court-of-appeals/`)
- Doc type: `reply-brief`. Reply Brief of Appellant (FRAP 28(c)); one self-contained folder, no shared files.
- Exemplar: `usage/FILED-EXAMPLE-reply-brief.pdf` (*Warner v. DeJoy*, No. 24-1414, filed 2024-10-09; provenance in `usage/SOURCE.md`).
- Sample: `usage/INPUT-reply-brief.md` (excerpt of the filed brief; see Known gaps).
- Status: template built; render and page review re-done 2026-10-14 (pages below). Overlay PDF not regenerated this run (see Overlay). Not reviewed by a human; `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `ca1-brief`. |
| `typst/ca1-reply-brief.typ` | Template; the same code as the opening-brief template with its parameter block set for a reply: `word-limit = 6500`, `required-sections = ()` (FRAP 28(c)), `needs-standard-of-review = false`, `addendum = "optional"`. A "Reply Argument" heading gets the same roman-numeral point scheme as "Argument". |
| `usage/INPUT-reply-brief.md` | Markdown contract sample (frontmatter + body). |
| `usage/OUTPUT-reply-brief.typst.pdf` | `sh tools/render.sh courts/first-circuit/court-of-appeals/reply-brief usage/INPUT-reply-brief.md` (10 pages). |
| `usage/OVERLAY-warner-reply-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/first-circuit/court-of-appeals/reply-brief warner-reply-brief`. |
| `usage/` | The filed exemplar and `SOURCE.md`. |

## Governing rules

Primary source: the First Circuit Rulebook, "effective with amendments through June 1, 2026", <https://www.ca1.uscourts.gov/sites/ca1/files/rulebook.pdf> (read on 2026-10-13; page numbers are the rulebook's printed pages). FRAP text cross-checked against <https://www.law.cornell.edu/rules/frap/rule_32> on 2026-10-13.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| FRAP 28(c) | A reply brief must contain a table of contents with page references and a table of authorities with the pages where cited. No other section is required (p. 57) | TOC; TOA; `required-sections = ()` |
| FRAP 32(a)(2)(A)-(F) | Cover contents (rulebook pp. 67-68) | `cover-body` |
| FRAP 32(a)(4)-(6) | 8½ × 11; double-spaced, quotations single-spaced; margins at least 1 inch; 14-point or larger proportional serif; plain roman, case names italic (p. 68) | page, text, quotation, and footnote styles |
| FRAP 32(a)(5) (typeface) | Rule names no face: a proportionally spaced serif face, 14 pt or larger. No 1st Cir. local rule names a face (rulebook text read 2026-10-14). Court-named face: none | `font-family = ("Times New Roman", "Liberation Serif")` (the house standard, `docs/FONTS.md` rule 6; EB Garamond in the earlier template); no substitute needed |
| FRAP 32(a)(7)(B)(ii) | A reply brief is acceptable if it has no more than half the type volume of a principal brief (p. 69), so 6,500 words | `word-limit = 6500` |
| FRAP 32(f) | Excluded from the count: cover, disclosure, TOC, TOA, oral-argument statement, addendum with statutes, certificate, signature block (pp. 69-70) | `strip-oral-argument`; markdown body only |
| FRAP 32(g)(1)-(2); Form 6 | Certificate of compliance, Form 6 wording (rulebook p. 113) | `certificate-of-compliance` |
| 1st Cir. R. 28.0 | The addendum rule is for the appellant's brief (p. 58). Not required for a reply; `optional` here | `addendum = "optional"` |
| 1st Cir. Notice to Litigants ¶¶ 2, 7; 1st Cir. R. 25.0(e) | Form per FRAP 32; certificate of service only where FRAP 25(d) requires one | `certificate-of-service`, optional |
| FRAP 32(a)(2) (cover color) | Reply: gray (paper copies only) | not produced; see Known gaps |
| Checklist for Briefs, ca1 (rev. 3/22; secondary) | Footnotes the same size as the body text; disk rule (1st Cir. R. 32.0) only for paper | footnotes at 14 pt; no disk rule |

## Overlay

This run (2026-10-14): `tools/overlay.sh` could not write the PDF, because `usage/FILED-EXAMPLE-reply-brief.pdf` is not in this checkout (`usage/` holds only `SOURCE.md`). The `.txt` page map is unchanged from the earlier run, and the pairings below are from that run.

`usage/OVERLAY-warner-reply-brief.pdf` puts our render (red) over the best-matching filed page (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only. Pairings from the last run:

- p.1 ↔ filed p.1 (80%), p.2 ↔ p.2 (55%), p.3 ↔ p.3 (20%): cover, TOC, and TOA (the sample's TOA has two cases; the filed TOA lists many).
- p.4 ↔ p.5 (85%), p.5 ↔ p.6 (85%): introduction and reply argument; point I.
- p.6 ↔ p.8 (52%), p.7 ↔ p.8 (37%): point I (end) and point II.
- p.8 ↔ p.19 (60%): conclusion and signature block.
- p.9 ↔ p.20 (23%), p.10 ↔ p.21 (48%): compliance certificate and service certificate.

## Page review (Gate 2)

Every page of `OUTPUT-reply-brief.typst.pdf` was rendered at 60 dpi and viewed (10 of 10). Typst printed no warnings. Fonts embedded: Times New Roman (vendored) only.

| Page | Content | Result |
|---|---|---|
| 1 | Cover (reply title, two counsel groups, telephone) | OK. Fits one page. |
| 2 | Table of contents (roman "I." and "II." point headings with hanging indent) | OK. |
| 3 | Table of authorities (two cases, page 3) | OK. |
| 4 | Introduction; reply argument | OK. |
| 5 | Point I heading (centered, bold); text; bullet list | OK. |
| 6 | Point I (continued): bullets; the *Taite* and *Ahmed* citations | OK. |
| 7 | Point II heading; paragraph; "CONCLUSION" heading and its lead-in | OPEN (minor): the lead-in "should:" falls at the foot of page 7 and the bullets start on page 8. Nothing forces them together. |
| 8 | Conclusion bullets; signature block | OK. |
| 9 | Certificate of compliance (Form 6 wording). Word count from the markdown (901). | OK. |
| 10 | Certificate of service (comma fixed on re-render) | OK. |

Tier-2 findings (OPEN or ACCEPTED; recorded on the earlier EB Garamond template): the page-7 lead-in finding above (OPEN); the typeface is EB Garamond where the filed brief uses Times New Roman (ACCEPTED: the rule names no face, so EB Garamond stays; see `docs/FONTS.md`).

## Known gaps

1. Cover color (gray for a reply) is not produced. FRAP 32(a)(2) applies to paper copies; the PDF is white.
2. The sample is an excerpt: it transcribes the cover, TOC, TOA (for the two cited cases), the introduction, reply argument I and the start of II, the conclusion, and the certificates. The filed brief is 21 pages.
3. The table of authorities is built only from `toa:` links. Every citation the filer wants listed must be linked; a link inside a heading is refused.
4. The word count is computed from the markdown body (`count-words`). It has not been cross-checked against the PDF text in this box. The 6,500 limit is the half of 13,000 that FRAP 32(a)(7)(B)(ii) allows; the template does not check a reply's page count (FRAP 32(a)(7)(A) page limit of 15 pages is not enforced).
5. The page-7 lead-in finding (OPEN) is not fixed: keeping a colon-introduced list with its first item would need a rule the template does not have.
6. Typeface: Times New Roman, the house standard (`docs/FONTS.md` rule 6), because the rulebook names no face; the filed brief's face too. (EB Garamond in the earlier template.)

## Engines

The typst template is the reference; the latex and docx engines render the same sample, each into `usage/`. All three
set Times New Roman 14 pt (latex: newtx, its metric twin), the face the typst template names; the notes above that call
the face EB Garamond are superseded (the docx engine set EB Garamond until fb-595.54.2 and failed `DEF-FONT-002`).

| Engine | Folder | Output | Status |
|---|---|---|---|
| typst (primary) | `typst/` | `usage/OUTPUT-reply-brief.typst.pdf` (10 pages) | tier 1 green |
| latex | `latex/` (`template.tex` + `ca1.lua`, pdflatex) | `usage/OUTPUT-reply-brief.latex.pdf` (10 pages) | tier 1 green; XENG-001..003 PASS |
| docx | `docx/` (`reference.xml` + `ca1.lua`, `fb render`: pandoc, LibreOffice) | `usage/OUTPUT-reply-brief.docx`, `.docx.pdf` (10 pages) | tier 1 green; XENG-001..003 PASS |

Build: `sh tools/check.sh <doc-dir> --engine typst|latex|docx`; `fb render --engine docx` builds the reference document from `docx/reference.xml` (`base="xengine"`, the typst face as `{font}`). (Until fb-595.68, `sh docx/make-reference.sh` built a committed `reference.docx`.)
The docx contents and authorities carry page numbers from a first LibreOffice pass (`fb render`, docxpass.rs: the
needles `ca1.lua` writes).

### Cross-engine (fb-595.54.2)

The three engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/latex/xengine.sty` and
`xengine.lua`, `lib/docx/xengine.lua` and fb render's `base="xengine"` reference, `tools/fb/src/docxxengine.rs`; docs/EVAL-LOOP.md, "Cross-engine gate"), and
`eval.yaml` sets `params.cross_engine: gate`.

- typst: pitches 31.4 pt (body) and 20 pt (headings, quotations, footnotes, tables, cover, certificates) instead of
  leadings; spaces between blocks in pt; `listing-row` contents (36 pt page column) and authorities (56 pt, or the page
  list); section headings 16 pt (was 1.15 em, 16.1 pt: Word has only half points); point headings bold, not small
  capitals; the check boxes a ruled box around an X; the designations, counsel and signature blocks start at the middle
  of the text (`pad(left: 50%)` inside `align` had put them at their own width).
- latex: `\usepackage{xengine}`, `\xe@lines`, `\addvspace`, `\xe@row`, `\xe@footnotemarks`, `\xe@lists`; the
  contents from `\label`/`\pageref`; an ellipsis (U+2026) one em wide with its own text (T1 has no ellipsis glyph);
  no break before a closing mark after a space (". . .,", UAX #14 LB13/LB15d, as typst).
- docx: the `base="xengine"` reference from `docx/reference.xml` (Times New Roman, exact 31.4/20 pt lines; a committed `reference.docx` from `xengine-reference.sh` until fb-595.68); every paragraph with
  exact spacing; contents and authorities rows with a right indent and a leader tab; page numbers by needles; a word
  joiner between ")(" ("32(a)(7)(B)": LibreOffice would break there, typst does not); the closing-mark rule above.
- Before (fresh render on master, /work/artifacts/baseline): latex 10 pages, 124/159 typst lines with the same break (78.0 %); docx 9 pages against typst's 10, 56/159 lines (35.2 %), tier 1 2 failed (TNR-EMBEDDED, DEF-FONT-002: EB Garamond).
- After: latex and docx 10 pages, 160/160 typst lines break after the same word (100 %), every page starts and ends
  on the same word; tier 1 0 failed on all three engines.
- Pages reviewed (60 dpi, every page of the typst, latex and docx PDFs, 10 each): cover, contents and authorities
  (leaders, page numbers), headings, footnotes, signature block, certificates. No overlapping or clipped text, nothing
  in the margins. Remaining tier-2 differences: the cover's gaps differ between engines (each fits the cover to its
  page); the docx cover's closing rule is one thick line; Word's leaders run up to the page number.
