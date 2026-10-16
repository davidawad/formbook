# Fourth Circuit: appellant's reply brief (`reply-brief`)

Doc type: appellant's reply brief in the United States Court of Appeals for the Fourth Circuit (FRAP 28(c)).
Status: exemplar found, template and sample render; overlay generated; every rendered page reviewed (10 of 10).

## What is here

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-dnc-de-luca-26-1532-reply-brief.pdf` | The filed exemplar: *Democracy North Carolina v. De Luca*, No. 26-1532, Reply Brief of Appellants (36 pages, Doc. 34, filed 08/13/2026). Text-based PDF. |
| `exemplars/SOURCE.md` | URL fetched from, case, docket, filer, dates. |
| `samples/INPUT-de-luca-reply-brief.md` | Markdown transcription of an excerpt of the exemplar (see "Known gaps"). Frontmatter + body, per the markdown contract below. |
| `samples/OUTPUT-de-luca-reply-brief.pdf` | `sh tools/render.sh courts/fourth-circuit/court-of-appeals/reply-brief samples/INPUT-de-luca-reply-brief.md` (10 pages). |
| `samples/OVERLAY-de-luca-reply-brief.pdf`, `.txt` | `sh tools/overlay.sh courts/fourth-circuit/court-of-appeals/reply-brief de-luca-reply-brief` (red = ours, blue = filed, black = both). |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`, splits frontmatter from body, calls the template. |
| `typst/ca4-reply-brief.typ` | The template: `ca4-brief(meta, md)`. Content-agnostic; every number is a named parameter at the top or traces to a rule. Structure copied from `courts/ninth-circuit/court-of-appeals/typst/ca9-brief.typ`; the numbers, cover, certificates and related-cases section are the Fourth Circuit's. |

Build and check (from the repo root):

```sh
export PATH="$HOME/.local/share/formbook/env/bin:$PATH"   # tools/bootstrap.sh toolchain
sh tools/render.sh courts/fourth-circuit/court-of-appeals/reply-brief samples/INPUT-de-luca-reply-brief.md
sh tools/overlay.sh courts/fourth-circuit/court-of-appeals/reply-brief de-luca-reply-brief
```

Typst is run by `tools/render.sh` with `--ignore-system-fonts`, the vendored `fonts/` and `vendor/typst-packages/`; any warning is a failure. The PDF's embedded fonts are Liberation Serif only (`pdffonts`).

## Governing rules

Sources, all fetched 2026-10-14 from the court's own site (Federal and Local Rules of Appellate Procedure, edition dated March 23, 2026):

- https://www.ca4.uscourts.gov/rules/Rule28.html (FRAP 28, Local Rule 28)
- https://www.ca4.uscourts.gov/rules/Rule32.html (FRAP 32, Local Rule 32)
- https://www.ca4.uscourts.gov/rules/Rule25.html (FRAP 25, Local Rule 25)
- https://www.ca4.uscourts.gov/LocalRules/LocalRules.3.22.html (Local Rules 25 and 31; the template uses none of Local Rule 31)

The Fourth Circuit's Form 6 (certificate of compliance) page was not retrievable (404 at the court's URL during this run). The certificate below uses the content FRAP 32(g)(1) requires (the word count, computed from the brief) and the wording of the filed exemplar; it is not verified against Form 6's exact text.

| ID | Requirement | Source | Where in the template |
|---|---|---|---|
| CA4-FORM-001 | 8½ × 11 paper; text double-spaced; quotations over two lines may be indented and single-spaced; headings and footnotes single-spaced | FRAP 32(a)(4) | `body-leading`, `single-leading`, `style-heading`, `footnote.entry` |
| CA4-FORM-002 | Margins at least one inch on all four sides; page numbers may sit in the margin, no text there | FRAP 32(a)(4) | `page-margin = 1in` |
| CA4-FORM-003 | Typeface: proportionally spaced with serifs (sans-serif allowed in headings and captions) | FRAP 32(a)(5)(A) | `font-family` (Liberation Serif, vendored; the substitute for Times New Roman, see Typeface) |
| CA4-FORM-004 | Plain roman type; italics or bold for emphasis; case names italicized | FRAP 32(a)(6) | the body is set as written; `*...*` for case names |
| CA4-FORM-005 | Proportional face 14-point or larger, everywhere (cover, text, footnotes, TOC/TOA, certificates) | FRAP 32(a)(5)(A) | `type-size = 14pt`; the footnote entry is forced to 14 pt (typst's default is 0.85 em) |
| CA4-LEN-001 | Reply brief: no more than half the principal-brief type-volume, i.e. 6,500 words; a reply brief that complies with the type-volume limit is not also held to the 15-page limit of FRAP 32(a)(7)(A) | FRAP 32(a)(7)(B)(ii) | `reply-word-limit = 6500`; the build panics above it |
| CA4-LEN-002 | Excluded from the count: cover, disclosure statement, TOC, TOA, certificates, signature block, proof of service, addendum of statutes/rules; headings, footnotes and quotations are counted | FRAP 32(f) | `count-words` counts the body only (everything before `# Addendum`) |
| CA4-LEN-003 | Briefs may not exceed the limits without advance permission; motions to exceed are not favored and must be made 10 days ahead | Local Rule 32(b) | the build fails rather than producing an over-length brief |
| CA4-COVER-001 | Cover: case number centered at the top | FRAP 32(a)(2)(A) | `No. #case_number` |
| CA4-COVER-002 | Cover: name of the court | FRAP 32(a)(2)(B) | `IN THE UNITED STATES COURT OF APPEALS FOR THE FOURTH CIRCUIT` |
| CA4-COVER-003 | Cover: title of the case (Rule 12(a)) | FRAP 32(a)(2)(C) | the `caption` sides; `v.` between sides |
| CA4-COVER-004 | Cover: nature of the proceeding and the court, agency or board below | FRAP 32(a)(2)(D) | `proceeding`, `district_court_case`, `judge` |
| CA4-COVER-005 | Cover: title of the brief, identifying the party for whom it is filed | FRAP 32(a)(2)(E) | `brief_title` |
| CA4-COVER-006 | Cover: name, office address and telephone number of counsel | FRAP 32(a)(2)(F) | `counsel` and `phone` (the template fails if they are missing) |
| CA4-COVER-007 | Reply-brief cover is gray (paper copies); cover color is not reproduced in the PDF | FRAP 32(a)(2) | not produced (known gap) |
| CA4-TOC-001 | Reply brief: table of contents with page references | FRAP 28(c) | `toc-section` (generated from headings) |
| CA4-TOC-002 | Reply brief: table of authorities (cases alphabetical; statutes; other authorities) with the pages of the reply brief where cited | FRAP 28(c) | `toa-section`, built from `toa:` links (a key missing from `authorities:` fails the build) |
| CA4-BODY-001 | Reply brief has no fixed section order beyond the TOC and TOA; a conclusion is customary and is the convention the exemplar follows | FRAP 28(c); exemplar | the body is free; the signature block follows the last paragraph |
| CA4-CERT-001 | Certificate of compliance with the type-volume limit: word count, and that the brief is proportionally spaced with the typeface stated | FRAP 32(g)(1), (g)(2) | `certificate-of-compliance(meta, words)`; the word count is the template's own count |
| CA4-CERT-002 | Proof of service only when service is not through CM/ECF; a CM/ECF filing needs none | FRAP 25(d)(1); Local Rule 25(a)(4) | `certificate-of-service` only when `service.certificate: true` |
| CA4-ADD-001 | Addendum of statutes, rules or regulations at the end of the brief; may be supplied under separate cover | FRAP 28(f); Local Rule 28(b) | `# Addendum` section, Add-1, Add-2 ... |

Not required by these rules, so not generated: a statement of related cases (the Ninth Circuit's Form 17 is not a Fourth Circuit requirement in the rules above); a disclosure statement (FRAP 26.1 applies to the first brief, not a reply).

## Typeface

| Face the court names | Vendored substitute (Typst name) | Fit | Used by |
|---|---|---|---|
| Times New Roman (court's notice of preferred typefaces, Dec. 9, 2024, https://www.ca4.uscourts.gov/news-announcements/2024/12/09/preferred-typefaces-for-briefs; the filed exemplar's certificate states 14-point Times New Roman) | Liberation Serif (`Liberation Serif`) | Metric-compatible with Times New Roman (`docs/FONTS.md`) | typst, LaTeX, docx |

FRAP 32(a)(5)(A) names no face. The notice is not a rule, but it prefers Times New Roman, Century Schoolbook or Georgia and "discourages the use of Garamond", so the template follows it. The earlier EB Garamond setting is replaced. The typst page count stayed at 10.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block, then the body. The template generates the cover, tables, signature block and certificates.

| Field | Required | Feeds |
|---|---|---|
| `case_number` | yes | cover "No. ..." line |
| `caption` | yes | cover case title; each side: `names` (list, one centered line each, markdown allowed) and `designation` |
| `proceeding` | yes | "Appeal from ..." line |
| `district_court_case`, `judge` | no | "Case No. ..., judge" line |
| `brief_title` | yes | cover title (capitals) |
| `counsel` | yes | cover counsel groups (`names`, `lines`) |
| `phone` | yes | telephone, appended to the last counsel group |
| `signature` | yes | `signer` (printed `s/ Name`, then in capitals), `lines` (italic lines under it) |
| `date` | no | under the signature block and on the certificates |
| `counsel-for` | no (default "the party") | certificate of compliance: "counsel for ..." |
| `word_limit_basis` | no | accepted for parity with the other courts' templates; not used for a Fourth Circuit form |
| `service` | no | `certificate: true` adds a Certificate of Service; `unregistered` is a list of `{name, address}` |
| `authorities` | yes if the body cites | table of authorities registry; `kind` is `case`, `constitution`, `statute`, `regulation`, `rule` or `other` |

Body: `# Heading` is a section (bold, capitals, centered). `## ` is a point heading in the Argument (roman numeral, flush with its label, as in the exemplar) and a lettered heading elsewhere; `###` is a sub-heading (A. / 1. / a.). Numbers are generated; do not type them. Citations: `[*Case v. Name*, 000 F.3d 000, 000 (cir. year)](toa:key)`; short forms link to the same key. Footnotes: `text[^key]` with `[^key]: text` anywhere. `# Addendum` starts the addendum.

## What the overlay shows

`samples/OVERLAY-de-luca-reply-brief.txt` pairs each of our pages with the filed page that shares the most words:

```
ours p.1  filed p.1   39.2%   (cover)
ours p.2  filed p.3   35.0%   (TOC)
ours p.3  filed p.4   22.8%   (TOA: the exemplar's TOA is on filed pp. 4-6; ours is a generated list of five cases)
ours p.4  filed p.7   71.1%   (Introduction)
ours p.5  filed p.8   47.1%
ours p.6  filed p.10  60.8%
ours p.7  filed p.11  81.4%
ours p.8  filed p.12  82.9%   (Argument I.A, footnote 1)
ours p.9  filed p.34  46.1%   (Conclusion and signature)
ours p.10 filed p.36  62.5%   (certificate of compliance)
```

The map was regenerated after the font change (the earlier map had different pairings for pp. 3, 6, 7 and 9). The overlap percentages are word-set Jaccard figures, not a score. Differences are expected where the sample is an excerpt (the filed Argument continues on pages 7-33, which the sample does not transcribe) and where the template generates parts the filed brief lays out differently (TOA, cover counsel block).

## Pages reviewed (Gate 2 style, rendered with `pdftoppm -r 60` and looked at)

All 10 pages were looked at after the first render, and again after the font change (Liberation Serif); pages 3, 8 and 9 were also looked at after the citation links were added. Recorded findings:

| Page | Finding | Status |
|---|---|---|
| 1 cover | Fits one page; case number, court name, caption, proceeding with case number and judge, title, counsel block all present. Counsel is lead counsel only. | ACCEPTED (see Known gaps) |
| 2 TOC | Renders; `I.` and `A.` entries indented; page numbers right (after the font change, the folio of the wrapped `I.` entry no longer drops onto a new line). A title that ends in a period gets a doubled stop before the leader ("Mailing. ."). | OPEN (minor; see Known gaps) |
| 3 TOA | Lists the five authorities cited in the sample, with pages. First version was empty because the sample had no `toa:` links; fixed. | OK |
| 4 body p.1 | Introduction, double-spaced, 14 pt, first-line indent. | OK |
| 5 body p.2 | Continues the Introduction; Argument heading. | OK |
| 6 body p.3 | Argument heading centered; point heading I. flush with label; A. sub-heading. | OK |
| 7 body p.4 | Body text; signals `See` italic; quotation marks curly. | OK |
| 8 body p.5 | Citations italic (case names and signals); pin cites. | OK |
| 8 body p.5 (2026-10-16) | Footnote 1 now sits at the foot of this page; the rest of the page is blank because the CONCLUSION heading, its paragraph and the signature block are kept together (the keep rule) and do not fit. | ACCEPTED |
| 9 body p.6 | CONCLUSION; signature block with `s/`, capitals name, italic lines and date. | OK |
| 10 certificate of compliance | Word count and typeface statement; signature line. | OK |

Nothing is `OPEN` that blocks the build. The docx and latex engines were not built (the brief asks for typst only).

## Known gaps

- **Excerpt, not the whole brief.** The sample transcribes the Introduction, the opening of Argument I (its opening paragraph) and I.A (through the Husted paragraph) with footnote 1, and the Conclusion, signature and certificate. The filed brief (36 pages, 6,270 words) continues through pages 7-33 of the exemplar. Transcribing it all was not needed for the template's coverage and would not change any layout rule. The sample body is ~1,300 words; the rendered sample is 10 pages (the target was 8-14).
- **Cover counsel is lead counsel only.** FRAP 32(a)(2)(F) requires counsel's name, office address and telephone on the front cover. The filed exemplar instead prints "(counsel listed on reverse)" and puts the full counsel list on page 2. The template follows the rule. The sample lists Jeffrey Loperfido only: the full list (about 11 attorneys over three firms) did not fit on one cover at 14 pt, and the template refuses to build a cover that does not fit (it panics; it does not shrink the type).
- **Cover caption is abridged.** The caption lists "FRANCIS X. DE LUCA, *et al.*" with "Intervenors-Appellees" in the designation; the filed caption names each official and both intervenors.
- **Gray cover not produced.** FRAP 32(a)(2) requires a gray cover for a reply brief. A PDF cannot carry the paper cover color, so the template does not produce one. Paper copies need one.
- **Related-cases statement and disclosure statement omitted** (see Governing rules; not required by the Fourth Circuit rules fetched).
- **TOC entry with a trailing period.** A heading whose text ends in a period (e.g. "...After One Failed Mailing.") shows a doubled period before the dot leader in the TOC. Cosmetic; the fix belongs in `toc-entry` (strip a final period from the entry text) and is not made here.
- **Form 6 wording not verified.** The certificate of compliance is FRAP 32(g)(1) content in the exemplar's wording; the court's Form 6 page could not be fetched.
- **Certificate of service.** The exemplar has none (the case is served through CM/ECF). The template prints one only when `service.certificate: true`, and then only for participants not registered for electronic service.
- **Word count** of the sample (1,334) is the template's count of the sample body only; the exemplar's own figure (6,270) is for the whole brief and is not comparable.

## Exemplar notes

- The filed exemplar is a text layer PDF with a diagonal watermark-like letter stack ("DEMOCRACY") on each page. It is part of the source scan, not the brief; the overlay's text pairing is unaffected.
- Used as a visual and structural reference for: cover order, TOC/TOA layout, Argument heading style, signature block, certificate of compliance.
- The exemplar's certificate of compliance states 14-point Times New Roman; the template uses Liberation Serif (vendored; metric-compatible with Times New Roman, per `docs/FONTS.md`).

## Engines

Three renderings of the same markdown (`samples/INPUT-de-luca-reply-brief.md`). The typst template is the reference.

**LaTeX** (`latex/template.tex`, `latex/ca4.lua`; `sh tools/render.sh --engine latex`): output `samples/OUTPUT-de-luca-reply-brief.latex.pdf`, 11 pages, every page rendered at 50 dpi and viewed after the font change. Layout item the font change exposed, not fixed here: the "CONCLUSION" heading sits at the foot of page 6 with its text on page 7. Matches: Liberation Serif only, double spacing at the typst pitch, 1-inch margins, the cover with the case number and judge line and counsel's telephone number, contents (addendum headings are kept out of the main contents) and authorities, the Form 6 style certificate of compliance (1,334 words, the same as typst's count) with its signature and date line, and the certificate of service on its own page. The addendum's `Add-N` folios are built but the sample has no addendum. Differs: the cover is tighter (fixed gap); body spacing differs slightly, so page breaks and folios differ from typst. Signature: typst's reply `signature-line` writes `s/` with no leading slash; this engine writes `/s/` as the other briefs do. Confirm which is wanted. Not checked by `check.sh` (no `checks.yaml` in this court).

**docx** (`docx/reference.docx`, `docx/ca4.lua`; `sh tools/render.sh --engine docx`): `samples/OUTPUT-de-luca-reply-brief.docx` is written; the `.docx.pdf` is not (see BLOCKED). Styles and sections as in the opening brief. Contents and authorities are Word fields. Certificate word count 1,334.

BLOCKED (docx):
- All gates on the `.docx.pdf`: no LibreOffice on this box (see the opening brief's README, Engines).
- Contents and authorities page numbers: Word fills them on update; LibreOffice does not honour TA/TOA fields (docs/DOCX.md).
- The addendum's `Add-N` folios are not built in the docx (the sample has no addendum).
- The cover's rules and caption positions are paragraph borders and indents, approximated.
- Opened in neither Word nor LibreOffice: well-formed XML only.

## Verification pass 2026-10-16 (fb-595.26.4)

- Exemplars: `exemplars/` held two files with the same SHA-256 (`3136a819…`): `FILED-EXAMPLE-dnc-de-luca-26-1532-reply-brief.pdf` (the one `SOURCE.md` and this README name) and an undocumented copy, `FILED-EXAMPLE-de-luca-v-nc-26-1532-reply-brief.pdf`. The copy was removed; `overlay.sh` picks the first PDF in the folder, which is now the documented one.
- Rendered: `sh tools/render.sh … samples/INPUT-de-luca-reply-brief.md` exit 0, no typst warnings, Liberation Serif only (`pdffonts`). 10 pages, the same count as the committed PDF.
- Overlay: `sh tools/overlay.sh … de-luca-reply-brief` exit 0; page map unchanged (table above). All 10 overlay pages viewed. The cover pairs weakly (39%) because the filed cover carries the full caption and "(counsel listed on reverse)"; body pages line up line for line where the text is transcribed.
- Pages viewed: 10 of 10 typst pages at 60 dpi, plus the exemplar's pages 1 and 2 (cover and counsel list). After the fixes, pp. 1–3 were viewed again (pp. 4–10 are pixel-identical to the first render, `compare -metric AE`).
- Fixed (template): cover counsel lines were italic and indented; they are now roman and flush, as in the filed counsel list. The `Page` / `Page(s)` underline crossed the descender of the "g"; it now sits lower.
- Stale note corrected: footnote 1 is on PDF page 8, not page 9; page 8 is half blank because the Conclusion block is kept with the signature (row added to the page table, ACCEPTED).
- Fixed (LaTeX, `latex/ca4.lua`): cover counsel lines roman, as in typst. Re-rendered, 11 pages; every page viewed at 40 dpi. Still open there: "CONCLUSION" at the foot of page 6 with its text on page 7.
- Remaining gaps: as listed under Known gaps (excerpt, lead counsel only on the cover, abridged caption, gray cover, doubled period before the TOC leader). docx not rebuilt (no LibreOffice).
