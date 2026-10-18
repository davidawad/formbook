# Second Circuit, answering (appellee's) brief

Court: United States Court of Appeals for the Second Circuit (`ca2`). Doc type: `answering-brief`.
Folder layout: one self-contained folder per doc type, so this folder holds its own `typst/`, `usage/`, `usage/`.

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-answering-brief-2.pdf` | A real filed brief for appellee (Second Circuit No. 25-2247), text layer present. |
| `usage/SOURCE.md` | Where it came from, who filed it, dates, and what it shows. |
| `typst/ca2-answering-brief.typ` | The template: `ca2-answering-brief(meta, md)`. Content-agnostic; every number is a named parameter at the top or traces to a rule. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`. |
| `usage/INPUT-answering-brief.md` | Transcription of the exemplar: cover, counterstatement, summary, standard of review, part of Argument I.A, conclusion, signature, certificates. A portion, not the whole brief. |
| `usage/OUTPUT-answering-brief.typst.pdf` | Render of the sample (12 pages). |
| `usage/OVERLAY-finkelman-answering-brief.pdf`, `-overlay.txt` | Red/blue overlay against the exemplar (`tools/overlay.sh`). |

Build (from the repo root, with the toolchain on `PATH`):

```sh
sh tools/render.sh courts/second-circuit/court-of-appeals/answering-brief usage/INPUT-answering-brief.md
sh tools/overlay.sh courts/second-circuit/court-of-appeals/answering-brief finkelman-answering-brief
```

Typst is run by `tools/render.sh` with `--ignore-system-fonts`, the vendored `fonts/`, and `vendor/typst-packages` (cmarker). Any typst warning fails the build.

## Markdown contract

Same as the Ninth Circuit template (`courts/ninth-circuit/court-of-appeals/README.extra.md`), with these differences:

- Frontmatter: `case_number`, `caption` (two sides, `names` and `designation`), `proceeding`, `brief_title`, `counsel`, `phone`, `signature` are required. `district_court_case` and `judge` print as `Case No. X (JUDGE)`. `date` and `city` print under the signature block. `service: {certificate: true, method: "ACMS"}` adds the certificate of service. `authorities` is the table-of-authorities registry, as in ca9.
- Body: `# Heading` (level 1) is a section. The sections of an appellee's brief are, in order: Jurisdictional Statement (optional, FRAP 28(b)(1)), Counterstatement of Issues Presented for Review (optional, 28(b)(2)), Counterstatement of the Case (optional, 28(b)(3)), Summary of the Argument (required, 28(a)(7) via 28(b)), Argument (required, 28(a)(8) via 28(b)), Conclusion (required, 28(a)(9) via 28(b)). The template does not refuse a brief that omits the optional sections; it does not check the required ones either. That check is a gap (see below).
- Under `# Argument`, level 2 is a centered point heading (I., II.), level 3 is A., level 4 is 1., level 5 is a. Elsewhere level 2 is A., level 3 is 1.
- Footnotes, block quotes, italics for case names, and `toa:KEY` links work as in ca9.
- Word limit: the template refuses a body over 14,000 words (Local Rule 32.1(a)(4)(A); see "Rules").

## Rules

All text below was fetched from the court's site on 2026-10-14 unless marked otherwise.

| Requirement | Source | Verified | Where in the template |
|---|---|---|---|
| Appellee's brief content: conforms to FRAP 28(a)(1)–(8) and (10), except that jurisdictional statement, statement of issues, statement of case and standard of review need not appear unless the appellee is dissatisfied with the appellant's statement. | FRAP 28(b), https://ww3.ca2.uscourts.gov/clerk/case_filing/rules/title7/rule_28.html | 2026-10-14 | section list above; not enforced |
| Cover: case number centered at top; name of court; title of the case; nature of the proceeding and court below; title of the brief identifying the party; counsel's name, office address, telephone. | FRAP 32(a)(2)(A)–(F), https://ww3.ca2.uscourts.gov/clerk/case_filing/rules/title7/rule_32.html | 2026-10-14 | `cover-body` (CA2-COVER-001..) |
| Cover color: appellant blue, appellee red (unrepresented parties exempt). | FRAP 32(a)(2); the court's civil-case brief page, https://www.ca2.uscourts.gov/clerk/case_filing/appealing_a_case/civil_case/brief_and_appendix.html | 2026-10-14 | **not drawn** (see gaps) |
| Caption on covers must match the court's "official caption". | Same court page | 2026-10-14 | caption layout; "– v. –" between sides |
| Paper 8½ × 11; double spacing (quotations over two lines may be single-spaced; headings and footnotes single-spaced); margins at least 1 inch on all four sides. | FRAP 32(a)(4) | 2026-10-14 | `page-margin = 1in`, `body-leading` |
| Proportionally spaced serif face, 14-point or larger (sans only in headings and captions). No face is named: the court's page gives "Times New Roman" only as an example ("Proportionally spaced typeface such as \"Times New Roman\" must be 14-point or larger"). Substitute: none; the template keeps EB Garamond (`docs/FONTS.md`: no face named). | FRAP 32(a)(5)(A); the court's civil-case brief page, verified 2026-10-15 | 2026-10-15 | `type-size = 14pt`, `font-family = "EB Garamond"`; checked by `pdffonts` |
| Plain roman type style; case names italicized or underlined. | FRAP 32(a)(6) | 2026-10-14 | cmarker italics |
| Length: principal brief not over 30 pages, unless it is within the type-volume limit; type-volume: no more than 13,000 words (reply: half). | FRAP 32(a)(7)(A)–(B)(i)–(ii) | 2026-10-14 | superseded by Local Rule 32.1(a)(4)(A) (next row) |
| Local Rule 32.1(a): briefs conform to FRAP 32(a) "except as set forth below"; (a)(1) the cover title names the party, and "the docket number of the case must appear in type at least one inch high"; (a)(4)(A) a principal brief "is acceptable if it contains no more than 14,000 words". | 2d Cir. Local Rule 32.1, https://www.ca2.uscourts.gov/clerk/case_filing/rules/title7/local_rule_32_1.html | 2026-10-16 | `docket-size = 72pt` (cover); `type-volume-limit = 14000`; certificate cites FRAP 32(a)(7)(B) and LR 32.1(a)(4)(A) |
| Excluded from the count: cover, disclosure statement, TOC, TOA, oral-argument statement, addendum, certificates, signature block, proof of service. Headings, footnotes and quotations are counted. | FRAP 32(f) | 2026-10-14 | `count-words` on the body only |
| Certificate of compliance, Form 6 wording (type-volume and typeface). | FRAP 32(g), form in the Appendix of Forms | 2026-10-14 (rule); Form 6 wording taken from the exemplar's certificate | `certificate-of-compliance` |
| Addendum of statutes, rules, regulations: in the brief's addendum at the end. | FRAP 28(f) | 2026-10-14 | `# Addendum` handling (Add-1 pages) |
| Corporate disclosure statement, if required. | FRAP 28(a)(1), 26.1 | 2026-10-14 (28(a)(1) text) | not generated (see gaps) |
| Certificate of service. | FRAP 25(d) | not fetched; standard wording taken from the exemplar | `certificate-of-service` (optional) |

## What the overlay shows

`usage/OVERLAY-finkelman-answering-brief.pdf`: each page of our render (red) on top of the exemplar page it matches best by word overlap (blue). Black is where both agree. The page map is in `-overlay.txt`.

- Cover, Jurisdictional Statement, Counterstatement, Summary, Standard of Review, Argument I, Conclusion: the match is 73–92% word overlap.
- TOC and TOA pages (ours p. i–ii) match the exemplar's TOC/TOA poorly (35% and 18%). That is expected: the sample's TOC and TOA are generated from the sample's headings and links, and it covers different pages of the filed brief. The overlay is a diagnostic, not a score.
- Certificate pages (ours p. 11–12) match the exemplar's certificate pages (filed p. 59–60) at about 45%: the wording differs by design (the sample's count, the template's typeface statement).

## Review (Gate: every page rendered and looked at)

Rendered at `pdftoppm -r 60` and read page by page: 12 of 12 pages reviewed.

| Ours | What was checked | Finding | Fixed |
|---|---|---|---|
| 1 (cover) | caption, court name, proceeding, brief title, counsel block | Counsel block wrapped the firm name at 50% indent. | Yes: indent 35% (cover and signature). |
| 2 (TOC) | entries, leaders, page numbers | The long "A." entry squeezed its dot leader to one dot and wrapped the page number. | Yes: leader gap 0.5em, page box 2em. Now one line with dots. |
| 3 (TOA) | groups, sort order, page list | Fine. | No change. |
| 4–9 (body, pp. 1–6) | headings, footnotes, italics, quotations, double spacing | Fine. Footnotes at 14pt. Point heading centered, small caps. | No change. |
| 10 (conclusion, signature) | signature block, "Dated" line | Firm name no longer wraps. | Yes (with page 1). |
| 11 (certificate of compliance) | Form 6 wording | Fine. The word count is the sample's count (1,428), not the filed brief's. | No change. |
| 12 (certificate of service) | wording, signature | Fine. | No change. |

## Known gaps

1. **Cover color is not drawn.** FRAP 32(a)(2) requires a red cover for an appellee's paper copies. The ECF exemplar is uncolored, and the template prints black on white. A paper copy needs red card stock; the PDF does not carry the color.
2. **No corporate disclosure statement.** FRAP 26.1 disclosure is required for a nongovernmental corporate party. The template does not generate one. The exemplar has none (individual filer).
3. **No statement regarding oral argument.** The exemplar has none. The template does not generate one.
4. **Required sections are not checked.** The template does not refuse a brief missing Summary of the Argument, Argument, or Conclusion. A check belongs in `ca2-answering-brief` before the body is rendered.
5. **Word limit.** Resolved 2026-10-16: Local Rule 32.1(a)(4)(A) (fetched) sets 14,000 words for a principal brief and displaces FRAP 32(a)(7)(B)(i)'s 13,000 ("except as set forth below"). The template enforces 14,000, as the opening brief does.
6. **Typeface.** The exemplar is Times New Roman. Neither FRAP 32 nor Local Rule 32.1 names a face, so the template keeps the vendored EB Garamond (no substitute switch), at 14 pt, which satisfies FRAP 32(a)(5)(A). A filer who reads the court page's "such as \"Times New Roman\"" as a requirement would switch to Liberation Serif (metric-compatible, `docs/FONTS.md`); that is a decision for David. The certificate says "Typst in 14-point EB Garamond" (the program that set the type), not Word.
7. **Sample is a portion.** The sample transcribes the cover, counterstatement, summary, standard of review, part of Argument I.A, the conclusion, and both certificates. It ends mid-sentence on the exemplar's page 22 and says so. It is not the filed brief's full 48 pages.
8. **Local Rule 32.1 fetched 2026-10-16** (court rule page). Only (a), (a)(1) and (a)(4)(A) are used. The docket number is set at 72 pt (one inch type size); the cap-height reading (about 105 pt) is the same open question as in the reply brief's README.
9. **Counsel lines.** The role line ("Counsel for the Defendant-Appellee ...") prints after the email, where the exemplar prints the telephone number before it.

## Engines (latex, docx)

Built by `latex/` (`template.tex` + `ca2.lua`, the same template as the other doc types with `DOC = "answering"`) and `docx/` (`reference.docx` from `make-reference.sh`, + `ca2.lua`).

- **latex** (`usage/OUTPUT-answering-brief.latex.pdf`, 13 pages; typst: 12). Matches: the cover and its counsel block, the heading structure and labels, contents and authorities with computed page numbers, the certificates (type-volume and typeface wording; certificate of service because `service.certificate: true`), certificate word count 1,428 (same as typst). Differs: one page longer than typst, from the heading spacing in the Counterstatement; the cover spreads less.
- **docx** (`usage/OUTPUT-answering-brief.docx`, `.docx.pdf` 13 pages). Matches: the cover, sections and numbering, styles, certificates, word count 1,428. BLOCKED: `DOCX-TOC-PAGES` and `DOCX-TOA-PAGES` (contents and authorities have no page numbers; see the opening brief's README).

## Verification pass 2026-10-16 (fb-595.26.2)

- Re-rendered `INPUT-answering-brief.md` with `tools/render.sh`: exit 0, no warnings, 12 pages (the committed PDF was not stale: same text and page count). Fonts: EB Garamond Regular/Bold/Italic only.
- Viewed all 12 pages at 60 dpi, the exemplar's page 1, and all 12 overlay pages at 40 dpi. The overlay pairing is unchanged (cover 91.8%, body 73-91%, TOC/TOA 35%/18%, certificates 45-49%).
- Fixed (tier 1): the cover printed the docket number at 14 pt; Local Rule 32.1(a)(1) requires type at least one inch high. Now `docket-size = 72pt` (typst) and `\fontsize{72}{80}` (latex `ca2.lua`). The cover still fits one page.
- Fixed (tier 1): the word limit was 13,000 (FRAP); Local Rule 32.1(a)(4)(A), now fetched, sets 14,000 for a principal brief. Limit and certificate wording (FRAP 32(a)(7)(B) and LR 32.1(a)(4)(A)) updated in typst and latex.
- Fixed (tier 2): the table of authorities sorted numbers as text ("10 U.S.C." before "9 U.S.C."); the sort key now compares digit runs by value. No visible change in this sample's order.
- Latex re-rendered (13 pages) and every page viewed. Open latex defects, not fixed: the "Counterstatement of the Case" heading stands alone at the foot of page 2 and the Point I heading at the foot of page 6 (headings not kept with the next paragraph); the counsel block wraps "PLLC" and the role line.
- Still open: gaps 1-4, 6, 7, 9 above; the counsel role line still prints before the telephone (it is in the sample's `lines`).
