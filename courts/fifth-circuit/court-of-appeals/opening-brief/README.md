# Fifth Circuit: opening brief (principal brief of appellant)

Template for the principal brief of an appellant in the U.S. Court of Appeals for the Fifth Circuit. Content-agnostic: every number is a named parameter at the top of `typst/ca5-opening-brief.typ` and traces to a rule or a style choice. The court-root `typst/` and `samples/` (the older ca5 material) are not part of this folder and were not touched.

## Layout

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-candel-25-20366-opening-brief.pdf` | Filed exemplar: Brief of Appellant, *Candel & Partners SAS v. ExxonMobil Corp.*, No. 25-20366 (5th Cir.), filed 2025-11-03, 59 pages, text layer present. |
| `exemplars/SOURCE.md` | Where the exemplar came from, the docket number, the filer, the date filed and the date fetched. |
| `samples/INPUT-candel-opening-brief.md` | Markdown transcription of the exemplar: front matter, the sections of the brief, footnotes, the conclusion and both certificates. Follows the markdown contract of the ninth-circuit sample (frontmatter, `# Heading` sections, `toa:` citation links, `[^n]` footnotes). |
| `samples/OUTPUT-candel-opening-brief.pdf` | Render of the sample (14 pages). |
| `samples/OVERLAY-candel-opening-brief.pdf`, `-overlay.txt` | Red/blue overlay against the exemplar, and the page map from `tools/overlay.sh`. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`, splits frontmatter from body, calls the template. |
| `typst/ca5-opening-brief.typ` | The template: `ca5-opening-brief(meta, md)`. |

Build (from the repo root, with typst 0.15.0 on PATH):

```sh
sh tools/render.sh courts/fifth-circuit/court-of-appeals/opening-brief samples/INPUT-candel-opening-brief.md
sh tools/overlay.sh courts/fifth-circuit/court-of-appeals/opening-brief candel-opening-brief exemplars/FILED-EXAMPLE-candel-25-20366-opening-brief.pdf
```

Typst runs with the vendored fonts only (`--ignore-system-fonts`); any typst warning fails the render. The font is EB Garamond (`fonts/eb-garamond/`), and cmarker 0.1.10 is vendored under `vendor/typst-packages/`.

## Typeface (fonts pass, 2026-10-14)

| Court requirement | Face the rules name | Substitute | Fit |
|---|---|---|---|
| CA5-FORM-005: proportionally spaced serif, 14 pt text, 12 pt footnotes (FRAP 32(a)(5)-(6); Checklist 2(a), 2(d)) | None. FRAP 32(a)(5)(A)-(B) allows any proportionally spaced face with serifs; Form 6 asks only for the program and font used. The local rule (5th Cir. R. 32.3) text was not fetched. | None needed: EB Garamond (`fonts/eb-garamond/`) kept | n/a (no court-named face; `docs/FONTS.md` "No face named") |

The rules name no face, so the template keeps EB Garamond in typst, latex and docx. The filed exemplar is set in Century Schoolbook; the rules allow it but do not require it, so the difference is a tier-2 visual choice, not a rule failure. Checked on the typst render: `pdffonts` lists only `EBGaramond` (Regular, Bold, Italic) and nothing else is embedded.

## Governing rules

| ID | Requirement | Source | Verified |
|---|---|---|---|
| CA5-FORM-005 | Proportionally spaced serif type, 14 point or larger for text; 12 point or larger for footnotes. Roman style, italics for case names; no sans serif in text. | Fifth Circuit, *Checklist for Preparation of Briefs, Record Excerpts, Motions and Other Papers*, item 2(a) and 2(d); FRAP 32(a)(5)-(6). Checklist: https://www.ca5.uscourts.gov/docs/default-source/forms-and-documents---clerks-office/rules/brchecklist.pdf (PDF metadata: September 2024). | Read from the checklist, 2026-10-14. |
| CA5-FORM-004 | Double spaced. Quotations over two lines and footnotes may be single spaced. | Checklist 2(b); FRAP 32(a)(4). | Checklist, 2026-10-14. |
| CA5-FORM-003 | 1 inch margins on all sides. | Checklist 2(c); FRAP 32(a)(4). | Checklist, 2026-10-14. |
| CA5-FORM-001 | 8½ × 11 inch paper. | Checklist 2(a). | Checklist, 2026-10-14. |
| CA5-LEN-001 | Principal brief: 30 pages, or 13,000 words under the word-count option (the template uses the word count). Certificates, tables and the oral argument statement do not count. | Checklist 2(a) and 2(g); FRAP 32(a)(7)(B)(i) and 32(f). | Checklist, 2026-10-14. |
| CA5-CONT-001 | Certificate of interested persons, placed before the table of contents. | 5th Cir. R. 28.2.1 (cited by the checklist, item 1(a)). | Cited by the checklist. The rule text itself was not fetched. |
| CA5-CONT-002 | Statement regarding oral argument. | 5th Cir. R. 28.2.3; FRAP 34(a)(1). Checklist 1(b). | Cited by the checklist. The rule text itself was not fetched. |
| CA5-CONT-004 | Table of contents with page references; table of authorities. | FRAP 28(a)(2)-(3). Checklist 1(c)-(d). | Checklist, 2026-10-14. |
| CA5-CONT-005 | Jurisdictional statement, statement of issues, statement of the case, summary, argument with standards of review, conclusion. | FRAP 28(a)(4)-(9). Checklist 1(e)-(j). | Checklist, 2026-10-14. |
| CA5-CONT-006 | Signature of counsel; certificate of service in the form of FRAP 25. | FRAP 32(d); FRAP 25. Checklist 1(k)-(l). | Checklist, 2026-10-14. |
| CA5-CONT-007 | Certificate of compliance with the type-volume limit and the typeface requirements. | FRAP 32(g); 5th Cir. R. 32.3. Checklist 1(m). | Cited by the checklist. The rule text itself was not fetched. |
| CA5-CONT-003 | Front cover: case number at top; court name; title of the case; nature of the proceeding and the court below; brief title identifying the party; counsel's name, office address and telephone. | FRAP 32(a)(2); checklist 3(a). | Checklist, 2026-10-14. |
| CA5-CONT-008 | Cover colour: blue for the brief of appellant. Paper copies only, so not produced. | Checklist 3(c); FRAP 32(a)(2). | Checklist, 2026-10-14. |
| CA5-CONT-009 | Record citations in the form `ROA.123` (single-record) or `ROA.<docket>.123`. | 5th Cir. R. 28.2.2; checklist 2(h). | Checklist, 2026-10-14. |
| CA5-CONT-010 | Heading numbering: Argument point headings I., II.; sub-headings A., 1., a.; elsewhere A., 1., a., (1). Numbers are typed by the template, not the author. | Convention (exemplar), not a rule. | Exemplar. |

Rules were checked against the court's checklist (dated September 2024) on 2026-10-14. The rule text of 5th Cir. R. 28.2.1, 28.2.2, 28.2.3, 32.3, and FRAP 25, 28, 32 and 34 was **not** fetched in full, so those IDs are verified only as the checklist cites them. Re-check against the current local rules before the template is relied on for filing.

## Exemplar settles only what the rules leave open

- The exemplar sets the certificate of interested persons single-spaced. The checklist is silent on it, so the template follows the exemplar for that certificate only.
- The exemplar is set in Century Schoolbook. The rules allow any proportional serif face at 14 point, and the vendored EB Garamond is used instead. The overlay will show the typeface difference; that is expected.
- The exemplar puts the certificate of service and the certificate of compliance on their own pages. The template does the same.

## What the overlay shows

`samples/OVERLAY-candel-opening-brief.txt` maps each of the 14 sample pages to the exemplar page sharing the most words:

| Sample page | Content | Best exemplar page | Word overlap |
|---|---|---|---|
| 1 | Cover | 1 | 90.3% |
| 2 | Certificate of interested persons | 3 | 50.0% |
| 3 | Statement regarding oral argument | 4 | 87.0% |
| 4 | Table of contents | 6 | 28.3% |
| 5 | Table of authorities | 8 | 20.6% |
| 6 | Jurisdiction, issues | 12 | 54.1% |
| 7 | Statement of the case | 14 | 71.9% |
| 8 | Procedural history, summary of the argument | 27 | 41.7% |
| 9 | Summary (end); Argument point I | 28 | 40.5% |
| 10 | Argument (point I.A) | 31 | 54.2% |
| 11 | Argument (point I.A end, I.B) | 33 | 53.5% |
| 12 | Conclusion, signature | 57 | 29.8% |
| 13 | Certificate of service | 58 | 54.7% |
| 14 | Certificate of compliance | 59 | 33.3% |

The overlay is a diagnostic, not a score. The low overlap on the table of contents and table of authorities is expected, since the exemplar's tables run on different page numbers and carry long dot leaders. The page-to-page matches are by word, so a sample page can pair with the wrong exemplar page when the same citation recurs.

## Review (Gate 2): all 14 pages rendered and looked at

- Page 1 (cover): fits on one page. The date and both counsel blocks are on the page.
- Page 2 (certificate of interested persons): single spaced, signature block on the same page.
- Page 3 (oral argument statement): double spaced, centred heading.
- Page 4 (table of contents): page numbers match the body pages, the point headings hang.
- Page 5 (table of authorities): page references match the body pages. (Before 2026-10-16 a wrapped entry pushed its page list onto a line of its own; fixed, see the verification pass.)
- Pages 6–12 (body): double spaced, footnotes at 12 point, headings numbered by the template, point headings hang.
- Page 13 (certificate of service) and page 14 (certificate of compliance): the word count on page 14 is computed from the markdown (1,577 words, excluding the front matter, the tables, the oral argument statement and the certificates). A rough awk count of the same markdown gives 1,592. The difference is markup tokens such as `§`.

Defects found and fixed during the review:
- The cover spilled onto a second page (paragraph spacing used the double-spacing value). Fixed by setting paragraph spacing to the single value in every single-spaced block.
- Argument point headings were numbered twice ("I. I."). The sample now leaves the numbers out, as the contract says.
- Typst steps the heading counter only when numbering is set, so "B. Procedural History" and the second Argument sub-point printed "A.". Fixed by setting heading numbering in the template.
- Level-1 headings were left-aligned because the block shrank to its first line. Fixed by making them full width.
- The double-spacing value was too small (pitch 22 pt, about 1.6 × the type size). Now 30.8 pt, about 2.2 × the type size, which matches the ninth-circuit tuning.

## Known gaps

- **Standard of review**: the checklist requires the argument to include the standards of review (item 1(i)). The sample has no standard-of-review paragraph, and the template does not check for one.
- **Sample is an excerpt**: the exemplar runs 59 pages; the sample carries the front matter, most of the statement of the case, the summary, points I and I.A/I.B of the argument, the conclusion and both certificates. Point II of the argument and the remaining argument pages are not transcribed.
- **Table of authorities**: a citation is listed on the page where its link starts. A citation that begins at the end of a page and continues onto the next is listed on the first page. Verified only on this sample.
- **Word limit**: the template refuses to build a brief over 13,000 words (CA5-LEN-001, FRAP 32(a)(7)(B)(i)); the 30-page option is not checked.
- **Passim** threshold (7 pages) is in the template but no authority in the sample reaches it.
- **Cover colour, spiral binding and paper-copy count** (checklist 3(b)-(c), 4) are paper-copy requirements and are not produced.
- **Record references** are typed by the author (`ROA.1399`); the template does not validate them.
- **Word count**: the certificate of compliance uses the word count computed from the markdown, not the PDF. Counsel must check it against the word processor before filing.
- **Certificate typeface statement** names the typeface and point size as the template sets them (EB Garamond 14 point, footnotes 12 point). If a different face is used in filing, the statement must change.
- Not run: `tools/check.sh` and `tools/check-selftest.sh` (no check contract exists for this doc type yet).

## Verification pass 2026-10-16 (fb-595.26.5)

- Rendered: `sh tools/render.sh` (typst, exit 0, no warnings), 14 pages, same count as the committed PDF. Overlay rerun (`tools/overlay.sh`, exit 0); map above updated (pages 7 to 12 moved by a few lines after the heading-spacing fix).
- Viewed: all 14 pages at 60 dpi before the fixes and all 14 again after them (page 12 and the TOC/TOA pages at full size, the rest also in a contact sheet); the 14 overlay pages at 40 dpi; exemplar page 1 against our cover.
- Fixed in `typst/ca5-opening-brief.typ`: (1) TOC and TOA titles were small, bold, left-aligned; now centred bold capitals like the other section titles. (2) TOA and TOC rows: a wrapped entry left its page number alone on the next line ("... 1, 5, / 6") and the leader could shrink to ". ."; each row is now a grid, the entry hangs and the page reference sits at the right on the entry's last line. (3) Sub-headings (I., A.) sat closer to the text above than the double-spaced lines did; space above is now `heading-gap` (2em). Headings no longer use typst's built-in sizes (section titles 1.15em, sub-headings body size). (4) No word-limit check; the template now stops above 13,000 words. (5) The closing signature could stand alone on a page; the last body paragraph (not a footnote definition or heading) is kept with it. (6) Certificate paragraphs are set flush left.
- Fixed in the sample: the two case names in the statement regarding oral argument were not italic (transcription error).
- latex engine re-rendered (`--engine latex`, exit 0, 14 pages); its pages were not reviewed in this pass.
- Gaps that remain: standard-of-review paragraph not transcribed or checked; the sample is an excerpt; typeface differs from the exemplar (EB Garamond vs Century Schoolbook, tier 2 choice); the cover is plain centred text without the exemplar's rules (tier 3); docx not rendered (no soffice).

## Status

- exemplar: yes (`exemplars/FILED-EXAMPLE-candel-25-20366-opening-brief.pdf`)
- render: ok (`samples/OUTPUT-candel-opening-brief.pdf`, 14 pages, no typst warnings)
- overlay: ok (`samples/OVERLAY-candel-opening-brief.pdf`, page map in `-overlay.txt`)
- pages reviewed: 14 of 14

## Engines

- **latex** (`latex/template.tex`, `latex/ca5-brief.lua`; `sh tools/render.sh --engine latex`): matches the typst form for the mandated items: EB Garamond from `fonts/` (`fontdir`), 14 pt text, 12 pt footnotes, 30.8 pt double pitch, 17 pt single pitch for headings, quotations and certificates, 1 in margins, letter paper, roman front pages and arabic body from 1, certificates on their own pages, TOC and TOA built from the headings and `toa:` citations (two tectonic passes). Differs: the TOA page list is read from the previous pass, so it settles on the second run; the word count is computed from the markdown body and may differ from typst by a few words. Open tier-1 findings: see the PR description and the Gate 2 review rows.
- **docx** (`docx/reference.docx`, built by `docx/make-reference.sh`; `docx/ca5-docx.lua`): styles only (font, sizes, spacing, margins, heading styles). BLOCKED: `<id>.docx.pdf` (no LibreOffice on this box: `soffice` not found, and conda-forge has no package), so Gates 0 and 1 cannot run on the docx. Not in the docx yet: the cover and caption layout, the front statements from frontmatter, the TOC and TOA (TOA citations are plain text), heading numbering labels, the page-number footer, and the generated certificates of service and compliance from frontmatter (the body certificates are in).
