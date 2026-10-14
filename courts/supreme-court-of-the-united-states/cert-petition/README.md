# Supreme Court of the United States (SCOTUS): petition for a writ of certiorari (`cert-petition`)

- Court: `scotus`, Supreme Court of the United States (`courts/supreme-court-of-the-united-states/`)
- Doc type: `cert-petition`. Petition for a writ of certiorari in booklet format (Rules 14, 33.1, 34). One self-contained folder, no shared files.
- Exemplar: `exemplars/FILED-EXAMPLE-fisher-14-981-cert-petition.pdf` (*Fisher v. University of Texas at Austin*, No. 14-981, filed 2015-02-10; provenance in `exemplars/SOURCE.md`).
- Sample: `samples/INPUT-fisher-cert-petition.md`, an excerpt of the filed petition (see Known gaps).
- Status: **render = FAIL (blocker: the required typeface is not vendored)**. Template, sample and rules are in place; the layout was checked on a scratch render with a stand-in face. `court.json` untouched.

## Blockers

BLOCKED: the required Century-family typeface is not vendored. Rule 33.1(b) requires the text in a Century family face (Century Expanded, New Century Schoolbook, or Century Schoolbook) at 12 point. `fonts/` holds only EB Garamond, and this doc type may not use it. The template names `New Century Schoolbook` (`typeface` in `typst/scotus-cert-petition-cert-petition.typ`), so `tools/render.sh` fails with `unknown font family` (a typst warning, which the tool treats as failure). That is the intended behaviour: no fallback.

Decision needed (David): vendor a Century-family face into `fonts/` under its licence (for example TeX Gyre Schola under the GUST Font License, or a URW Century Schoolbook clone), then set `typeface` to its family name. `fonts/` is shared, so this folder does not edit it.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...`, calls `scotus-cert-petition`. |
| `typst/scotus-cert-petition-cert-petition.typ` | Template. Parameter block at the top: `word-limit` (9,000), `typeface`, sizes, leading, the 6 1/8 x 9 1/4 inch booklet page and its margins. |
| `samples/INPUT-fisher-cert-petition.md` | Markdown sample: frontmatter (cover, counsel, authorities) plus body. |
| `samples/OUTPUT-fisher-cert-petition.pdf` | Not produced in-tree: the render fails (see Blockers). |
| `samples/OVERLAY-fisher-cert-petition.pdf`, `.txt` | Not produced in-tree (needs the render). A scratch overlay exists in `/work/artifacts/cert-petition/` for diagnosis only. |
| `exemplars/` | The filed exemplar and `SOURCE.md`. |

Build (from the repo root, with `PATH` set to the toolchain):

```sh
sh tools/render.sh courts/supreme-court-of-the-united-states/cert-petition samples/INPUT-fisher-cert-petition.md
sh tools/overlay.sh courts/supreme-court-of-the-united-states/cert-petition fisher-cert-petition
```

Overlay naming: `tools/overlay.sh` reads `samples/OUTPUT-<id>.pdf` and writes `samples/OVERLAY-<id>.pdf` and `.txt`. The brief named `<id>-overlay.pdf`; the tool's naming is used because `tools/` is shared.

## Governing rules

Primary source: *Rules of the Supreme Court of the United States*, effective March 16, 2026, <https://www.supremecourt.gov/filingandrules/2026RulesoftheCourt_WEB.pdf> (downloaded and read on 2026-10-14; page numbers below are the Rules' printed pages). The 2026 revisions notice (adopted February 17, 2026, effective March 16, 2026, <https://www.supremecourt.gov/filingandrules/2026_Rules_Revisions.pdf>) changes Rules 14, 15, 24, 29 and 48. It does not change Rules 33 or 34.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| Rule 33.1(a), (b) | Booklet format, 6 1/8 x 9 1/4 in. Century family 12-point type, 2-point or more leading; footnotes 10-point; quotations over 50 words indented; text on both sides | `page-width`, `page-height`, `typeface` (BLOCKED, see above), `type-size`, `leading-pitch`, `footnote-size`, `quote-indent` |
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

The overlay pairs each page of our render with the best-matching filed page by word overlap. It is diagnostic, not a score. It cannot run in-tree until the typeface is vendored. The scratch overlay (EB Garamond stand-in, so not compliant) paired our cover with the filed cover (85%), our Questions Presented with the filed one (93%), the parties page (100%), the TOC (38%, layout differs), the body (85% on the first body page). The signature block and certificate have no filed counterpart in the excerpt.

## Page review (Gate 2)

Scratch render, 13 pages (`/work/artifacts/cert-petition/scratch-ebgaramond.pdf`): every page rendered at 60 dpi and viewed (13 of 13). Stand-in face: EB Garamond, not the required Century family, so the review checks layout and pagination only, not typeface. Cover re-viewed after the 10-point to 11-point fix (pagination unchanged). Line pitch measured in both files: 14.0 points on the body, the same as the exemplar (12-point type, 2-point leading).

| Page | Content | Result |
|---|---|---|
| 1 | Cover (docket, caption, proceeding, title, counsel) | OK. Fits one page at 11 point; counsel block in two columns, no overlap. |
| 2 | Questions presented alone | OK. |
| 3 | Parties to the proceeding and Rule 29.6 statement | OK. Heading wraps to two lines. |
| 4 | Table of contents | OK. Front-matter page numbers roman, body arabic, both from the document. |
| 5 | Table of authorities | OK. Every page listed; cases, constitutional provisions, statutes in order. |
| 6 | Petition for a Writ of Certiorari, opening paragraphs | OK. |
| 7 | Opinions Below; Jurisdiction; Constitutional Provision Involved (intro line) | OK. |
| 8 | Block quotation (indented); Statement of the Case, A. | OK. The block quotation starts on page 8 while its introductory line is on page 7: ACCEPTED (the layout has no keep-with-next on that line). |
| 9 | Statement, A. (continued); excerpt note; Reasons for Granting the Petition, III. | OK. |
| 10 | Part III (continued) | OK. |
| 11 | Part III (continued); Conclusion | OK. |
| 12 | Signature block alone on a page | ACCEPTED: the block (about 4 in.) does not fit under the conclusion, so it is kept together on the next page. |
| 13 | Certificate of compliance | OK. Word count 1,616 is the count of this excerpt, not of a complete petition. |

Tier-2 findings: the signature block sits alone on page 12 (ACCEPTED, above); the block quotation's introductory line is separated from it on page 7 (ACCEPTED, above). Cover proceeding line wraps to three lines; a long proceeding line may wrap (ACCEPTED).

Re-check after the last edit (proceeding line size, 10 to 11 point): only page 1 changed; the page openings of pages 2-13 were compared and are unchanged in pagination.

## Known gaps

1. **Typeface (BLOCKED).** See Blockers. Nothing else can make the render pass.
2. **Excerpt.** The sample transcribes the cover, the questions presented, the parties, the opening, Opinions Below, Jurisdiction, the constitutional provision, Statement A, and Part III with the conclusion. Pages 5 through 30 are omitted and marked in the sample. The certificate count (1,616) is the excerpt's count.
3. **Appendix.** Rule 14.1(i) appendix and Rule 34.4 appendix TOC are not generated.
4. **Stock ticker symbols.** Rule 14.1(b)(i) (2026) requires them where a party has one. The template does not check for them.
5. **Footnotes.** The template styles footnotes at 10 point with 2-point leading, but the excerpt has none, so that path has not been rendered or reviewed.
6. **Cover colour and paper copies.** Rule 33.1(e) cover colour (white for a petition) and paper-copy binding are not produced; the PDF is plain white. Forty paper copies (Rule 33.1(f)) are not produced.
7. **Word count.** `count-words` is a markdown token count, not a word-processor count; it has not been cross-checked against the PDF text.
8. **Exemplar provenance.** The exemplar is a copy from a law-firm site; the docket number is confirmed on supremecourt.gov, but the Court's own DocketPDF copy was not found (see `exemplars/SOURCE.md`).
9. **Exemplar age.** The exemplar is from 2015, before the 2019 booklet and word-limit changes that the template follows. The current rules were read directly from the 2026 PDF; the exemplar only settles layout details the rules leave open.

## Engines

Engine status (this box): typst `fail` (unchanged: the Century-family typeface is not vendored). latex: not built; docx: not built. Both are blocked on the same decision, below.

- Not built: `latex/` and `docx/`. Building either against EB Garamond would repeat the stand-in this doc type may not use (see Blockers). Once David vendors a Century-family face and names it, the typst `typeface` and the latex and docx font names change together, and both engines are built from the same parameters.
- docx BLOCKED: typeface (Rule 33.1(b)), listed as the blocker above; the cover and TOC/TOA BLOCKED items are the same as the amicus and merits docx.
