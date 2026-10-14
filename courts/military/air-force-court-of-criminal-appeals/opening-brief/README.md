# U.S. Air Force Court of Criminal Appeals (AFCCA): opening brief (brief on behalf of appellant)

- Court: `afcca`, U.S. Air Force Court of Criminal Appeals (`courts/military/air-force-court-of-criminal-appeals/`)
- Doc type: `opening-brief`. Brief on behalf of appellant (AFCCA Appendix A; the assignments-of-error brief). One self-contained folder; no shared files.
- Exemplars: two, from two filer pairs (`exemplars/SOURCE.md`):
  - `FILED-EXAMPLE-douglas-40324-opening-brief.pdf` (*United States v. Douglas*, ACM 40324 (f rev), filed 26 April 2024, Maj Bruha). Full brief and certificate. Primary: the overlay defaults to it.
  - `FILED-EXAMPLE-howard-40478-opening-brief.pdf` (*United States v. Howard*, ACM 40478 (f rev), filed 29 September 2024, Maj Blyth). Front matter (cover, TOC, TOA), assignments of error, start of the statement of facts, certificate. The only one of the two with a TOC and TOA.
- Samples: `samples/INPUT-douglas-opening-brief.md` (full transcription, 13 pages rendered) and `samples/INPUT-howard-opening-brief.md` (excerpt, 7 pages rendered; `excerpt: true`).
- Status: template built; render, overlay and page review done for both samples (below). Not reviewed by a human. `court.json` and the court root are untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `afcca-brief`. |
| `typst/afcca-opening-brief.typ` | Template. Parameter block at the top: `doc-kind`, `required-sections`, `roman-sections`, `index-threshold` (30), `page-limit` (50). The other copy (`answering-brief/typst/afcca-answering-brief.typ`) is identical except `doc-kind`. |
| `samples/INPUT-douglas-opening-brief.md` | Full transcription of the Douglas brief and certificate (markdown contract: frontmatter + body). |
| `samples/INPUT-howard-opening-brief.md` | Excerpt of the Howard brief: cover with counsel, TOC, TOA, assignments of error, statement of the case, start of the statement of facts, certificate. |
| `samples/OUTPUT-<id>.pdf` | `sh tools/render.sh courts/military/air-force-court-of-criminal-appeals/opening-brief samples/<id>.md`. The tools' naming: `OUTPUT-`, not `<id>.pdf`. |
| `samples/OVERLAY-<id>.pdf`, `OVERLAY-<id>.txt` | `sh tools/overlay.sh courts/military/air-force-court-of-criminal-appeals/opening-brief <id> [exemplar.pdf]` (red = ours, blue = filed, black = agree). The tool's naming: `OVERLAY-`, not `<id>-overlay.pdf`. |
| `exemplars/` | The two filed exemplars and `SOURCE.md`. |

The Howard overlay is run against its own exemplar (`exemplars/FILED-EXAMPLE-howard-40478-opening-brief.pdf`) because the tool's default is the first file in the folder.

## Governing rules

Primary source: *United States Air Force Court of Criminal Appeals Rules of Practice and Procedure*, effective 29 June 2026 (published with the Joint Rules of Appellate Procedure), <https://afcca.law.af.mil/afcca_data/cp/afcca_rules_of_practice_and_procedure_wjrap_29_jun_2026_2888395.pdf>. Downloaded and read on 2026-10-14; page numbers are the rules' printed pages.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| AFCCA R. 17.1(a) (p. 18) | "All appellate filings, excluding attachments, shall appear in proportional 12-point type—e.g., Times New Roman or Century Schoolbook—typed and double-spaced"; one side of 8.5 × 11 white paper; margins at least one inch on all four sides; no embedded images | `type-size = 12pt`, `body-leading` (double spacing), `page-margin = 1in`, letter paper. The typeface is EB Garamond (see Known gaps). |
| AFCCA R. 17.1(a) (p. 18) | Citations conform to the AFCCA Citation Guide and the Bluebook (Bluebook controls) | Not checked; the template does not format citations |
| AFCCA R. 17.1(b)-(f) (p. 18-19) | E-filing: PDF conversion, email subject line, narrative block, file naming, service certification | Outside the document; not generated (see Known gaps) |
| AFCCA R. 17.2(c) (p. 19) | PII and sensitive information: redaction per the JAJM Redaction Guide | Outside the template. The transcriptions are of redacted public filings. |
| AFCCA R. 17.3 (p. 20) | Filings shall not exceed 50 pages, excluding indices, attachments and appendices; headings, footnotes and quotations count | The end-of-brief check: the body from page 1 to the signature block (the certificate and the index excluded) must be at most `page-limit` = 50 pages; a hard failure otherwise. |
| AFCCA R. 18.1 (p. 22) | Briefs over 30 pages (excluding indices, tables, attachments, appendices, certificates) need a subject index and a table of cases and authorities with pages; all briefs comply with R. 17 | `index: true` in the frontmatter draws the TOC and the TOA. The check panics if the body runs over 30 pages without `index: true`. |
| AFCCA R. 18.1; App. A (pp. 22, 46-47) | Assignments of error are filed in compliance with Appendix A | `# Assignments of Error`, roman-numbered (`roman-sections`) |
| App. A (p. 46) | Caption: "IN THE UNITED STATES AIR FORCE COURT OF CRIMINAL APPEALS"; "UNITED STATES / Appellee / v. / [Name] / Appellant", with ")" column; right column: BRIEF ON BEHALF OF APPELLANT, Before Panel No., No. ACM, date | `caption-page`: court line, caption grid with the ")" column, title, panel, number, date |
| App. A (p. 46) | "TO THE HONORABLE, THE JUDGES OF THE UNITED STATES AIR FORCE COURT OF CRIMINAL APPEALS:" | `honorable` line at the start of the body |
| App. A (p. 46) | Sections, in order: Assignment(s) of Error; Statement of the Case; Statement of Facts; Argument (each argument states the standard of review and ends in a prayer for relief); Appendix | `required-sections` (AOE; statement of the case; argument) in order; the standard-of-review check; the WHEREFORE check for opening briefs |
| App. A (p. 47) | Signature block: counsel's signature, name, rank, branch, title, organization, address and phone | `signature` frontmatter, after the body |
| App. A (p. 47) | Certificate of filing and service | `certificate` frontmatter, last page |
| R. 18.2 (p. 22) | Grostefon issues: listed as an assignment of error and argued in a separate Appendix A | Not produced (see Known gaps) |

Two checks are text heuristics: the standard-of-review check is "the body contains 'standard of review'" and the prayer check is "the body contains 'WHEREFORE'". They prove the words are there, not that the content is right.

## Overlay

Pages are paired by word overlap, not by index (the tool's map is in `samples/OVERLAY-<id>.txt`). Pairings are only as good as that measure: a TOC repeats the words of the assignments of error, so it pairs with an AOE page.

`samples/OVERLAY-douglas-opening-brief.pdf` (13 pages, against the Douglas exemplar, which is the default): every page pairs with the filed page of the same number.

- p.1-4 ↔ filed p.1-4 (97-100%): caption, assignments of error, the additional statement of the case.
- p.5-8 ↔ filed p.5-8 (72-93%): the argument; differences are line breaks and where footnotes fall.
- p.9-11 ↔ filed p.9-11 (89-100%): point II and the footnotes.
- p.12 ↔ filed p.12 (68%): the WHEREFORE and the signature block.
- p.13 ↔ filed p.13 (94%): the certificate page of the filing, which is `FILED-EXAMPLE` p.13 of the exemplar.

`samples/OVERLAY-howard-opening-brief.pdf` (7 pages, against the Howard exemplar, passed explicitly): p.1 ↔ filed p.1 (cover, 100%); p.2 (our TOC) ↔ filed p.8 (the filed AOE page, 71%: the TOC repeats the AOE words); p.3 (our TOA) ↔ filed p.4 (17%: our TOA lists only the authorities the excerpt cites, the filed TOA is a long list in a different layout); p.4 ↔ filed p.8 (75%: the AOE page); p.5-6 ↔ filed p.9-10 (65%: the statement of the case and facts); p.7 ↔ filed p.12 (97%: the certificate).

Diagnostic only, not a score. Reading the Howard exemplar makes poppler print "xref" warnings (the source has broken cross-reference entries); the renders and the pairings are unaffected.

## Page review (Gate 2)

Every page of both `OUTPUT-*.pdf` files was rendered at 60 dpi and viewed. Typst printed no warnings. Fonts embedded: EB Garamond only (Regular, Italic, Bold, Bold Italic).

**`douglas-opening-brief`, 13 of 13 pages:**

| Page | Content | Result |
|---|---|---|
| 1 | Caption; TO THE HONORABLE; assignments of error I–II; start of the additional statement of the case | OK. Numerals and caption grid aligned. |
| 2 | Previous assignments of error; facts 1 | OK |
| 3 | Block quotation; facts 2–3 | OK |
| 4 | Facts 3–4; the Argument heading starts on the next page | ACCEPTED: half the page is blank because the Argument heading, the point heading and the standard of review are kept together (sticky) |
| 5 | Additional Arguments, point I; standard of review; law and analysis; sub-heading 1 | OK |
| 6 | Sub-heading 1 (continued); sub-heading 2; footnote 1 | OK |
| 7 | Sub-heading 2 (continued); sub-heading 3 | OK |
| 8 | Sub-heading 3 (continued); sub-heading 4 (Conclusion); WHEREFORE | OK. Numbering runs 1–4 under point I. |
| 9 | Point II heading; additional facts; standard of review; law and analysis | OK |
| 10 | Sub-headings 1 and 2 (point II); footnote 2 | OK |
| 11 | Argument continued; footnotes 3 and 4 | OK |
| 12 | WHEREFORE; "Respectfully submitted"; signature block | ACCEPTED: the signature stands on its own page with the WHEREFORE (by design; the last paragraph is kept with the signature) |
| 13 | Certificate of filing and service and signature | OK |

**`howard-opening-brief`, 7 of 7 pages:**

| Page | Content | Result |
|---|---|---|
| 1 | Caption with the counsel block (cover) | OK. Counsel block centered; the caption grid aligned. |
| 2 | Table of contents (page ii) | OK. Entries and page numbers match the body. |
| 3 | Table of authorities (page iii) | OK. Cases and statutes listed with pages. |
| 4 | TO THE HONORABLE; assignments of error I–VII | OK. Point headings with the numeral on its own line. |
| 5 | Statement of the case; footnote 1 (punitive articles); statement of facts (Background) | OK |
| 6 | Statement of facts (continued); the excerpt ends | ACCEPTED: sample limit (`excerpt: true`); the filed brief continues |
| 7 | Certificate of filing and service | OK |

Tier-2 findings (OPEN or ACCEPTED): typeface (EB Garamond at 12 pt, see Known gaps); the sub-headings in the Douglas sample ("Previous Assignments of Error", "Additional Facts") are unnumbered bold text, as the filing has them; the sample's Appendix A "Appendix" section is not generated.

## Known gaps

1. **Typeface.** R. 17.1(a) names Times New Roman and Century Schoolbook as examples of proportional type and requires 12 pt. Neither is vendored (`fonts/` holds only EB Garamond, and `fonts/` is shared, not edited here). The template sets EB Garamond at 12 pt. EB Garamond has a smaller x-height than the two example faces, so the text looks smaller on the page than the filing. A human should decide whether to add a Times-metric face to `fonts/`.
2. **Grostefon issues (R. 18.2).** The template does not produce the Appendix A for Grostefon issues. A brief with Grostefon issues must file that appendix separately.
3. **E-filing wrapper (R. 17.1(b)-(d)).** The email subject line, the narrative block and the PDF naming are not generated. They are outside the document.
4. **Index is authored, not computed.** The template draws the TOC and the TOA only when `index: true`. The page-limit check panics when a body runs over 30 pages without it, so a brief cannot silently miss the index. A brief over 30 pages whose body is under 30 pages cannot be detected.
5. **TOA is built from links, not detected.** Every citation the filer wants listed must be a link to `toa:KEY`, with the key in `authorities:`. The template does not find citations.
6. **Standard of review and prayer are heuristics** (see Governing rules).
7. **Excerpt samples.** `excerpt: true` skips the required-section, standard-of-review and prayer checks. It is set only on the Howard sample, which is a partial transcription. A complete filing must not set it.
8. **Certificate wording.** The certificate follows the Appendix A form ("I certify that the original and copies of the foregoing were [method] to the Court and served on [recipient] on [date]"). The Douglas filing's certificate has "Respectfully submitted," above the signature; the template omits it on the certificate.
9. **Sub-heading numbering.** Outside the Argument and the assignments of error, sub-headings are not numbered; a filer who numbers facts types the numbers in the heading text.
10. **Counsel block.** The `counsel` frontmatter prints a cover-page counsel block under the caption. Appendix A does not call for one; the Howard filing has one on its cover.
