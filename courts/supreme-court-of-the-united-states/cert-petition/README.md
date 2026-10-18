# Supreme Court of the United States (SCOTUS): petition for a writ of certiorari (`cert-petition`)

- Court: `scotus`, Supreme Court of the United States (`courts/supreme-court-of-the-united-states/`)
- Doc type: `cert-petition`. Petition for a writ of certiorari in booklet format (Rules 14, 33.1, 34). One self-contained folder, no shared files.
- Exemplar: `usage/SAMPLE-scotus-cert-petition-fisher14981.pdf` (*Fisher v. University of Texas at Austin*, No. 14-981, filed 2015-02-10; provenance in `usage/SOURCE.md`).
- Sample: `usage/INPUT-scotus-cert-petition-fisher.md`, a transcription of the filed petition's cover, front pages, opening, Statement A and Part III, with signature and certificate (see Known gaps, 2).

## Status

| Item | Result |
|---|---|
| Exemplar | yes: `usage/SAMPLE-scotus-cert-petition-fisher14981.pdf` (re-downloaded 2026-10-14 from the URL in `SOURCE.md`; 374 pages, the first 43 are the petition; `SOURCE.md` records no checksum; sha256 of the copy in the folder is `0ea2c1627b3fe6d969d3b104e6f49bdf27e78f847ac034b9198d3b49fd71f24a`, fetched again 2026-10-15) |
| Sample | `usage/INPUT-scotus-cert-petition-fisher.md` (kept from the earlier pass; excerpt, 14 rendered pages) |
| Render | ok (2026-10-15): `sh tools/render.sh courts/supreme-court-of-the-united-states/cert-petition usage/INPUT-scotus-cert-petition-fisher.md` writes `usage/OUTPUT-scotus-cert-petition-fisher.typst.pdf` (14 pages, exit 0, no typst warnings, `--ignore-system-fonts`) |
| Fonts | `pdffonts`: TeXGyreSchola-Regular, -Bold, -Italic embedded (CID Type 0C, subset). No EB Garamond or system face in the output. |
| Overlay | ok (2026-10-15): `sh tools/overlay.sh courts/supreme-court-of-the-united-states/cert-petition fisher-cert-petition` writes `usage/OVERLAY-fisher-cert-petition.pdf` and `.txt` (14 pages) |
| Pages reviewed | 14 of 14 (2026-10-15: every page of the render rasterized with `pdftoppm -r 70` and viewed as PNG) |
| Typeface | Required: Century family, Rule 33.1(b). Substitute: **TeX Gyre Schola** (exact Typst family name, from `docs/FONTS.md`), vendored in `fonts/tex-gyre-schola/`. Class: metric-compatible (the upstream README says its glyph widths follow the Adobe New Century Schoolbook AFMs). The overlay shows 100% word overlap on body pages 6 and 7, but that is not a line-break check. No EB Garamond in this template; the overlay label font (a shared tool) is EB Garamond, which is not part of the court output. |
| Open | Tier-2 items in the Gate 2 table below. `court.json` untouched. latex and docx engines not built. |

## Blockers

None for typst. The typeface blocker recorded in the earlier pass was wrong: `fonts/tex-gyre-schola/` is vendored (`texgyreschola-regular.otf` and bold/italic). TeX Gyre Schola is based on the URW Century Schoolbook L, so it is the Century family that Rule 33.1(b) names. The template now sets `typeface = "TeX Gyre Schola"`; no fallback is used (the render uses `--ignore-system-fonts`).

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...`, calls `scotus-cert-petition`. |
| `typst/scotus-cert-petition-cert-petition.typ` | Template. Parameter block at the top: `word-limit` (9,000), `typeface`, sizes, leading, the 6 1/8 x 9 1/4 inch booklet page and its margins. |
| `usage/INPUT-scotus-cert-petition-fisher.md` | Markdown sample: frontmatter (cover, counsel, authorities) plus body. |
| `usage/OUTPUT-scotus-cert-petition-fisher.typst.pdf` | Our render (14 pages). |
| `usage/OVERLAY-fisher-cert-petition.pdf`, `.txt` | Red/blue comparison against the filed exemplar and the page map. |
| `usage/` | The filed exemplar and `SOURCE.md`. |

Build (from the repo root, with the toolchain on `PATH`):

```sh
sh tools/render.sh courts/supreme-court-of-the-united-states/cert-petition usage/INPUT-scotus-cert-petition-fisher.md
sh tools/overlay.sh courts/supreme-court-of-the-united-states/cert-petition fisher-cert-petition
```

Overlay naming: `tools/overlay.sh` reads `usage/OUTPUT-<id>.pdf` and writes `usage/OVERLAY-<id>.pdf` and `.txt`. The brief named `<id>-overlay.pdf`; the tool's naming is used because `tools/` is shared.

## Governing rules

Primary source: *Rules of the Supreme Court of the United States*, effective March 16, 2026, <https://www.supremecourt.gov/filingandrules/2026RulesoftheCourt_WEB.pdf> (downloaded and read on 2026-10-14; page numbers below are the Rules' printed pages). The 2026 revisions notice (adopted February 17, 2026, effective March 16, 2026, <https://www.supremecourt.gov/filingandrules/2026_Rules_Revisions.pdf>) changes Rules 14, 15, 24, 29 and 48. It does not change Rules 33 or 34.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| Rule 33.1(a), (b) | Booklet format, 6 1/8 x 9 1/4 in. Century family 12-point type, 2-point or more leading; footnotes 10-point; quotations over 50 words indented; text on both sides | `page-width`, `page-height`, `typeface` (TeX Gyre Schola), `type-size`, `leading-pitch`, `footnote-size`, `quote-indent` |
| Rule 33.1(c) | Opaque paper; margins at least 3/4 in.; text field (including footnotes) no larger than 4 1/8 x 7 1/8 in. | `margin-x = 1in`, `margin-y = 1.0625in`: text field exactly 4.125 x 7.125 in |
| Rule 33.1(d) | Word limits exclude questions presented, parties and disclosure statement, TOC, TOA, counsel listing, appendix; footnotes counted | `count-words` on the body only (the front pages and the signature block are not in the body) |
| Rule 33.1(g)(i) | Petition for a writ of certiorari: 9,000 words | `word-limit = 9000`; the build panics above it |
| Rule 33.1(h) | Certificate of word count, stating the number of words, separate from the document | `certificate-of-compliance`, on its own page after the body |
| Rule 34.1(a)-(f) | Cover, from the top: docket number; "Supreme Court of the United States"; caption; nature of the proceeding and the court below; title; counsel of record with the notation "Counsel of Record", address, email and telephone | `cover` (docket line, caption, proceeding, title, counsel columns) |
| Rule 34.1(g) | Cover type not smaller than 11-point, except identification of counsel | `cover-size = 11pt`; counsel block at `counsel-size = 10pt` |
| Rule 34.2 | TOC and TOA (every page listed; no "passim"; ranges only when cited on every page) | `outline` (TOC, depth 2); `toa-section` (every page listed, passim never used) |
| Rule 34.3 | Counsel names at the close of the body | `signature-block` |
| Rule 14.1(a) | Questions presented on the first page after the cover, with no other information | front page `qp` (own page) |
| Rule 14.1(b)(i), (ii) | Parties with stock ticker symbols, if any (2026 text); corporate disclosure statement (Rule 29.6) | `parties` front page. The template does not enforce ticker symbols; the sample has none (an individual petitioner). |
| Rule 14(c) | TOC and TOA for a petition over 1,500 words | always rendered |
| Rule 14.1(e)-(i) | Jurisdiction, provisions involved, case statement, argument, appendix | content of the body; the appendix is not generated (Known gaps) |
| Rule 34.4 | Appendix TOC | not generated (Known gaps) |

## Overlay

`usage/OVERLAY-fisher-cert-petition.pdf` pairs each page of our render with the best-matching filed page by word overlap (`usage/OVERLAY-fisher-cert-petition.txt` is the page map). It is diagnostic, not a score. Pairing (ours to filed): cover 1 to 1 (84%), Questions Presented 2 to 2 (93%), parties 3 to 3 (100%), TOC 4 to 4 (38%: our TOC is a generated list, the filed page is laid out differently), TOA 5 to 8 (30%: low overlap, not a check), the body 6 to 11, 7 to 12, 8 to 13, 9 to 14 (100%, 100%, 97%, 82%), the Part III pages 10 to 41, 11 to 42, 12 to 43 (68%, 70%, 44%: the best matches fall in the filed petition's last pages, so the pairing is approximate), the signature page 13 to filed 1 (65%: the filed cover shares the counsel names), and the certificate 14 to filed 4 (21%: low overlap, no certificate match).

## Page review (Gate 2)

Render with TeX Gyre Schola, 14 pages (`usage/OUTPUT-scotus-cert-petition-fisher.typst.pdf`). Each page rasterized with `pdftoppm -r 70` and viewed.

| Page | Content | Result |
|---|---|---|
| 1 (cover) | Cover (docket, caption, proceeding, title, counsel) | OK. Fits one page; counsel block in two columns, no overlap. |
| 2 (label i) | Questions presented alone | OK. |
| 3 (label ii) | Parties to the proceeding and Rule 29.6 statement | OPEN (cosmetic): the centred two-line heading is set with wide word spacing. Not fixed. |
| 4 (label iii) | Table of contents | OK. Front-matter page numbers roman, body arabic, both from the document. |
| 5 (label iv) | Table of authorities | OK. Every page listed; cases, constitutional provisions, statutes in order. |
| 6 (label 1) | Petition for a Writ of Certiorari, opening paragraphs | OK. |
| 7 (label 2) | Opinions Below | OK. |
| 8 (label 3) | Jurisdiction; Constitutional Provision Involved (block quotation); Statement A | OK. Quotation on the same page as its introductory line. |
| 9 (label 4) | Statement A (continued); excerpt note | OK. |
| 10 (label 5) | Reasons for Granting the Petition, III. | OK. |
| 11 (label 6) | Part III (continued) | OK. |
| 12 (label 7) | Part III (continued); Conclusion | OK. |
| 13 (label 8) | Signature block alone on a page | ACCEPTED: the block (about 4 in.) does not fit under the conclusion, so it is kept together on the next page. |
| 14 (unnumbered) | Certificate of compliance | OK. Word count 1,616 is the count of this excerpt, not of a complete petition. |

Tier-2 findings: the signature block sits alone on page 12 (ACCEPTED, above); the parties heading word spacing on page 3 (OPEN, cosmetic). The block quotation now sits on the same page as its introductory line (render page 8; the earlier scratch render split them).

Page numbers: the table numbers the 14 PDF pages in order. The cover (PDF page 1) is unnumbered; front matter is labelled i-iv; the body is labelled 1-7 with the signature block on the page labelled 8; the certificate is unnumbered.

## Known gaps

1. **Excerpt.** The sample transcribes the cover, the questions presented, the parties, the opening, Opinions Below, Jurisdiction, the constitutional provision, Statement A, and Part III with the conclusion. Pages 5 through 30 of the filed petition are omitted and marked in the sample. The certificate count (1,616) is the excerpt's count, not a complete petition's count.
2. **Appendix.** Rule 14.1(i) appendix and Rule 34.4 appendix TOC are not generated.
3. **Stock ticker symbols.** Rule 14.1(b)(i) (2026) requires them where a party has one. The template does not check for them.
4. **Footnotes.** The template styles footnotes at 10 point with 2-point leading, but the excerpt has none, so that path has not been rendered or reviewed.
5. **Cover colour and paper copies.** Rule 33.1(e) cover colour (white for a petition) and paper-copy binding are not produced; the PDF is plain white. Forty paper copies (Rule 33.1(f)) are not produced.
6. **Word count.** `count-words` is a markdown token count, not a word-processor count; it has not been cross-checked against the PDF text.
7. **Exemplar provenance.** The exemplar is a copy from a law-firm site; the docket number is confirmed on supremecourt.gov, but the Court's own DocketPDF copy was not found (see `usage/SOURCE.md`).
8. **Exemplar age.** The exemplar is from 2015, before the 2019 booklet and word-limit changes that the template follows. The current rules were read directly from the 2026 PDF; the exemplar only settles layout details the rules leave open.
9. **Engines.** `latex/` and `docx/` are not built for this doc type. Only typst is in scope for this pass.

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **docx** (`docx/reference.docx` from `docx/build-reference.sh`, `docx/scotus.lua`, `docx/render.sh`): built and rendered with `sh tools/render.sh --engine docx`. Two passes: LibreOffice's PDF of pass 1 gives the page of every heading and every cited authority, and pass 2 writes them into the tables of contents and authorities. Matches the typst output: 6 1/8 x 9 1/4 in page, TeX Gyre Schola 12 pt on 14 pt lines, 1 in side and 1.0625 in top and bottom margins, 0.5 in first-line indents, 0.9 em between paragraphs, block quotation indented 0.5 in, cover, Questions Presented and Parties on their own pages, roman front matter (i to iv), arabic body (1 to 8), no number on the cover or certificate, the same 14 pages and the same TOC and TOA entries and page labels, and the same certificate count (1,616, from the same markdown rules). Differences (tier 2, not chased): no hyphenation (typst hyphenates, so line breaks differ); the TOA page numbers sit at the right margin without a leader (typst sets them beside each entry); the cover's counsel block is placed with a fixed gap (2,500 twips) rather than typst's fill, which fits the sample; level-1 headings are 16.5 pt (typst 16.8 pt, half-point steps) and one level-2 heading wraps on a different line; the Parties heading is not justified. The TOC and TOA page labels are cached text, not fields, so nothing needs updating in Word; Word may paginate a line or two differently from LibreOffice, which would move a label. Not opened in Word (not available here); checked as well-formed XML and by the LibreOffice conversion.
- **docx BLOCKED items:** none in the output. `sh tools/check.sh <this dir> --engine docx` cannot run: this doc-type folder has no `checks.yaml` and `court.json` is at the court root (exit 2), so the docx gates were not run.
- **latex**: not built for this doc type.
