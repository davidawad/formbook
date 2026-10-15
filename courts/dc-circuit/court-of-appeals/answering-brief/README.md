# Court of Appeals for the D.C. Circuit: answering brief (appellee's brief)

Self-contained doc-type folder for `cadc` (D.C. Circuit). Built from one filed exemplar, a partial transcription, and the court's own rules.

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-wilson-25-3041-answering-brief.pdf` | Brief for the United States (appellee), *United States v. Wilson*, No. 25-3041, filed 10/20/2025. Text-based, 32 pages. |
| `exemplars/SOURCE.md` | URL fetched from, case, docket, filer, dates. |
| `samples/INPUT-wilson.md` | Transcription of the exemplar: front matter, a portion of the statement, summary, first half of argument, conclusion, certificates. |
| `samples/OUTPUT-wilson.pdf` | Render of the sample (13 pages). |
| `samples/OVERLAY-wilson.pdf`, `OVERLAY-wilson.txt` | Red/blue overlay against the exemplar (`tools/overlay.sh`), and its page map. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`. |
| `typst/cadc-answering-brief.typ` | The template: `cadc-answering-brief(meta, md)`. Content-agnostic; every number is a named parameter at the top. |

Build (from the repo root):

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (conda-forge)
sh tools/render.sh courts/dc-circuit/court-of-appeals/answering-brief samples/INPUT-wilson.md
sh tools/overlay.sh courts/dc-circuit/court-of-appeals/answering-brief wilson
```

Typst runs with `--root <doc-type-dir> --font-path fonts --ignore-system-fonts --package-cache-path vendor/typst-packages`; any warning fails the build. Fonts and the cmarker package are vendored.

## Governing rules

Verification status is recorded per row. "Fetched" means the text was retrieved in this run (2026-10-14). "Exemplar" means the rule is cited in the filed exemplar only, not re-fetched.

| ID | Requirement | Source | Verified |
|---|---|---|---|
| CADC-FORM-001 | Proportionally spaced serif face, at least 14-point. | FRAP 32(a)(5), quoted in the D.C. Circuit notice below. | Fetched 2026-10-14 (quoted in notice). |
| CADC-FORM-002 | Court encourages Century and Times New Roman; Garamond "can be more difficult to read and the use of this typeface is discouraged." Double-spaced; one side only. | D.C. Circuit Handbook, Part IX.A.6, revised 3/16/2021: https://www.cadc.uscourts.gov/sites/cadc/files/noticeGen-noticePreferredTypefacesForBriefs.pdf | Fetched 2026-10-14. Handbook text is the extract in the notice; the full handbook was not retrievable. Face: Century (the filed exemplar's body face) → `TeX Gyre Schola` (`docs/FONTS.md`); see Known gaps, item 1. |
| CADC-FORM-003 | Margins at least one inch on all sides; double-spaced text, with headings, quotations, footnotes and TOC/TOA single-spaced. | FRAP 32(a)(4) and (a)(5)(B). | Not re-fetched. Template follows the exemplar. |
| CADC-LIMIT-001 | Principal brief (including appellee's): 13,000 words; certificate of compliance. | FRAP 32(a)(7)(B)(i); D.C. Circuit Brief Compliance Checklist (its text reads 13,000 words for a principal brief, citing FRAP 32(a)(2) and (7)). | The checklist URL returned 404 on fetch; the figure comes from a search snippet only. Re-check against the rule text. |
| CADC-LIMIT-002 | Words exempted from the count: FRAP 32(f) and D.C. Circuit Rule 32(e)(1). | FRAP 32(f), D.C. Cir. R. 32(e)(1) as cited by the exemplar. | Exemplar only. |
| CADC-COVER-001 | Cover: case number, court, title of the brief, nature of the proceeding, court below, counsel with address and telephone. | FRAP 32(a)(2), as laid out by the exemplar. | Exemplar only. |
| CADC-CERT-001 | Certificate of parties, rulings under review, and related cases before the table of contents. | D.C. Cir. R. 28(a)(1), cited in the exemplar. | Exemplar only. |
| CADC-CERT-002 | Statutes and regulations statement pointing to an addendum. | D.C. Cir. R. 28(a)(5), cited in the exemplar. | Exemplar only. The sample omits the addendum, so the statement is omitted with it. |
| CADC-CERT-003 | Certificate of compliance, FRAP 32(g) wording with the typeface named. | FRAP 32(g), as worded in the exemplar. | Exemplar only. |
| CADC-CERT-004 | Certificate of service, FRAP 25(d), with the document and the persons served. | FRAP 25(d), as worded in the exemplar. | Exemplar only. |

Not verified in this run: FRAP 28(b) (appellee's brief contents) and the full text of D.C. Cir. R. 28 and 32. The template follows the exemplar for those and is a convention, not a checked rule.

## Layout decisions (convention, tier 2)

- Cover: the template spaces the cover's parts to fit one page (never shrinks type), as ca9 does. Cover text is the sample's frontmatter; none is in the template.
- The exemplar's cover order is kept: oral-argument line, court, number, caption, appeal line with the district case number, brief title, counsel.
- Front matter: the cover is page i (not printed); the certificate of parties is page ii; then the table of contents and the table of authorities (roman numerals).
- The body is numbered from 1; the certificates follow the conclusion; the addendum (if any) is Add-1 onward, per D.C. Cir. R. 28(a)(5).
- Argument: point headings are centered roman numerals (I., II.), sub-headings A., 1., a. The exemplar's single argument heading is unnumbered; the template numbers it I. (convention).
- Non-argument sub-headings are lettered A., B. The exemplar's "Procedural History" is unlettered.
- Issue Presented sits at the start of the body (numbered page 1). The exemplar places it on a roman front page (vi).

## Markdown contract (frontmatter)

| Field | Required | Feeds |
|---|---|---|
| `case_number` | yes | Cover "No.". |
| `oral_argument` | no | Line printed at the top of the cover. |
| `caption` | yes | Cover title of the case: `names` (list) and `designation` per side. "v." between sides. |
| `proceeding` | yes | Cover: the appeal line. Printed as given (caps in the exemplar). |
| `district_court_case` | no | Cover line under the appeal line (e.g. "Cr. No. 23-427 (DLF)"), printed as given. |
| `judge` | no | Cover line with the district case number. |
| `brief_title` | yes | Cover title of the brief (printed in capitals); the certificate of service uses `service.document`. |
| `counsel` | yes | Cover counsel block: `names` and italic `lines` per group. `phone` is appended to the last group. |
| `phone` | yes | Telephone, appended to the last counsel group. |
| `signature` | yes | `signer` (printed as `/s/ Name` and in capitals), `lines` (italic lines under the signature). |
| `certificate_of_parties` | yes | Markdown for the certificate of parties, rulings and related cases. |
| `statutes_and_regulations` | no | Markdown for the statutes-and-regulations statement; printed only when given. |
| `service` | no | `certificate: true` adds the certificate of service: `document`, `served_upon` (text), `date`. |
| `authorities` | yes if the body links any | Table of authorities registry: `kind` (case, constitution, statute, regulation, rule, other), `name` (optional; italic for cases), `cite` (required). |

Body: `# Heading` is a section (bold, capitals, centered). Under `# Argument`, `##` is a point heading. Cite with `[*Case*, cite](toa:key)`; short forms link to the same key. Footnotes are `text[^key]` with `[^key]: text` (14 pt). Write `\*` for a literal asterisk (e.g. WL star pages). `# Addendum` ends the brief (its own roman/Add- numbering). The word count is the body before `# Addendum`.

## What the overlay shows

`overlay.sh` pairs each sample page with the exemplar page sharing the most words (Jaccard overlap of word sets), so the pairing is by text, not position. Result for `OVERLAY-wilson.txt`:

Last run (2026-10-15, after the font change):

| Sample page | Filed page | Word overlap | What it is |
|---|---|---|---|
| 1 | 1 | 74% | Cover |
| 2 | 2 | 88% | Certificate of parties |
| 3 | 4 | 49% | TOC |
| 4 | 5 | 50% | TOA |
| 5 | 9 | 45% | Issue presented; statement of the case (A) |
| 6 | 10 | 65% | Statement (proclamation; certificate of pardon) |
| 7 | 11 | 54% | Statement (district court's order, B) |
| 8 | 20 | 79% | Summary of argument; argument point I |
| 9 | 21 | 61% | Argument (relate-to reading; Dubin, Lamar) |
| 10 | 23 | 55% | Argument (deference; Andrews, Rosemond) |
| 11 | 27 | 59% | Conclusion; signature block |
| 12 | 28 | 38% | Certificate of compliance |
| 13 | 28 | 57% | Certificate of service |

Limits, stated plainly: the sample transcribes part of the filed brief (see Known gaps, item 2), so the pairing is by shared text, not by position. The filed pages it pairs with come from the exemplar's argument and later pages. It is a diagnostic, not a score. The red and blue layers are not compared pixel by pixel in this README.

## Gate 2: page review

Re-reviewed 2026-10-15 after the font change to TeX Gyre Schola: all 13 rendered pages were rasterized at 60 dpi and viewed (`pdftoppm -r 60`). Findings:

- p.1 cover: fits on one page; oral-argument line, court, number, caption, appeal line with `Cr. No.`, brief title, counsel. No defect.
- p.2 (ii) certificate of parties: fits one page. No defect.
- p.3 (iii) TOC: lists Issue Presented, the statement and its sub-headings, summary, argument and its point heading, conclusion, with page numbers that match the body (checked against pp. 5-11). No defect.
- p.4 (iv) TOA: cases, statutes, rules, other authorities on one page. Passim threshold not reached. No defect.
- pp.5-7 (body 1-3): double-spaced 14-point TeX Gyre Schola; bold sub-heading A. and B. hang correctly. No defect.
- pp.8-11 (body 4-7): summary, centered point heading I. with small caps, argument text, conclusion, signature block with `/s/` and counsel lines. The signature block stays with the conclusion. No defect.
- p.12 certificate of compliance: wording follows FRAP 32(g); the typeface is named as TeX Gyre Schola (see gap 1). No defect.
- p.13 certificate of service: wording follows FRAP 25(d) as the exemplar. No defect.

Pages reviewed: 13 of 13. Fonts embedded: TeX Gyre Schola (Regular, Bold, Italic) only; no fallback. Typst printed no warnings.

## Known gaps

1. Typeface (resolved 2026-10-15). Face required: Century. The Handbook (IX.A.6) names Century and Times New Roman and discourages Garamond; the filed exemplar's body is set in Century Schoolbook (its PDF also embeds Times New Roman and Arial in part). Substitute: `TeX Gyre Schola` (`docs/FONTS.md`; metric-compatible with the New Century Schoolbook AFMs). The template was EB Garamond before this change; the sample went from 14 to 13 pages. Times New Roman (`Liberation Serif`) is the other face the Handbook names; Century follows the exemplar's body.
2. Sample is partial. The exemplar runs 32 pages (about 4,600 words of text). The sample transcribes the front matter, the first part of the statement (procedural history, the district court's order), the summary, the first half of the argument, the conclusion, and both certificates: about 1,500 words. The remaining statement, the argument's Kelley/Taranto/Martin discussion and Andrews' later parts, and the addendum are not transcribed. The overlay and the 13-page count describe the sample, not the whole brief.
3. The certificate of compliance states 1,505 words: that is the sample's count, not the filed brief's (3,768). The count is computed from the sample markdown, as designed.
4. The addendum (the 90 Fed. Reg. 8331 proclamation) is not transcribed; the exemplar's text layer for it is garbled. The statutes-and-regulations statement is therefore omitted from the sample.
5. Emphasis that is not in the text layer (italics in quoted text, "(emphasis added)") is omitted; the sample drops the "(emphasis added)" tag rather than invent an emphasis.
6. Layout conventions that differ from the exemplar: point heading I. is added; "Procedural History" is lettered A.; Issue Presented is in the body rather than on a roman front page. See Layout decisions above.
7. Rule verification is incomplete: CADC-LIMIT-001 rests on a search snippet; the rest of the rules table is marked as exemplar-only or not re-fetched.
8. The BLOCKED marker is not needed: an exemplar was found (CourtListener RECAP, search `type=r`, `court=cadc`, description "APPELLEE BRIEF").

Searches tried for the exemplar: the FCC library (appellee briefs in D.C. Circuit agency cases; blocked with 403 when fetched), the CourtListener search API (found the RECAP entries), and a general web search. The chosen exemplar is a public RECAP copy.
