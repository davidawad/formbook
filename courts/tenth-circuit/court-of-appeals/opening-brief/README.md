# Tenth Circuit (ca10): appellant's opening brief

Doc type `opening-brief` for court `ca10`. Self-contained: exemplar, sample, template, and overlay live in this folder. The court-root `typst/` and `samples/` are not used by this doc type.

Status: exemplar **yes**; template renders with the repo's `tools/render.sh` (no warnings); overlay produced; every page of the sample was rendered and reviewed (13 of 13).

## Layout

- `exemplars/FILED-EXAMPLE-lyman-v-henderson-26-4014-opening-brief.pdf`: the real filed brief. Provenance in `exemplars/SOURCE.md`.
- `samples/INPUT-lyman-v-henderson-opening-brief.md`: the markdown sample (frontmatter + body). A **portion** of the brief: cover, TOC, TOA, prior-appeals statement, jurisdictional statement, issues, a portion of the statement of the case, a portion of the summary, standard of review, Argument I, conclusion, oral-argument statement, certificates, attachments index.
- `samples/OUTPUT-lyman-v-henderson-opening-brief.pdf`: `sh tools/render.sh courts/tenth-circuit/court-of-appeals/opening-brief samples/INPUT-lyman-v-henderson-opening-brief.md` (13 pages).
- `samples/OVERLAY-lyman-v-henderson-opening-brief.pdf` and `-overlay.txt`: `sh tools/overlay.sh courts/tenth-circuit/court-of-appeals/opening-brief lyman-v-henderson-opening-brief`.
- `typst/main.typ` (entrypoint) and `typst/ca10-opening-brief.typ` (template). The template is the ca9 engine (cmarker markdown, TOC/TOA by typst introspection) with ca10 cover, statements and certificates.

## Governing rules

Sources were fetched 2026-10-14. "Verified" below means the rule text was read in the fetched source; "per checklist" means the rule number and content come from the court's own checklist/FAQ, and the local rule text itself was not fetched.

| Rule ID (used in template) | Requirement | Source | Verified |
|---|---|---|---|
| CA10-FORM-001 | Double-spaced text; quotations over two lines single-spaced; headings and footnotes may be single-spaced. FRAP 32(a)(4) | [FRAP 32 (LII)](https://www.law.cornell.edu/rules/frap/rule_32) | verified, 2026-10-14 |
| CA10-FORM-002 | Proportionally spaced serif face, **14-point or larger**; plain roman, italics for case names. FRAP 32(a)(5)(A), 32(a)(6) | FRAP 32 (LII) | verified |
| CA10-FORM-003 | Letter paper; margins at least one inch on all four sides. FRAP 32(a)(4) | FRAP 32 (LII) | verified |
| CA10-FORM-004 | Single-sided, securely bound (paper copies only, not rendered). FRAP 32(a)(1)(A), 32(a)(3) | FRAP 32 (LII) | verified |
| CA10-COVER-001 | Front cover: case number centered at top; court name; case title; nature of proceeding and court below; brief title and party; counsel name, office address, telephone. FRAP 32(a)(2) | FRAP 32 (LII) | verified |
| CA10-COVER-002 | Cover has district of origin, judge, and district court case number. 10th Cir. R. 28.2(C) | [Briefing & Appendix Checklist, updated to 2025 Rules, 1/2/2026](https://ca10.uscourts.gov/sites/ca10/files/documents/downloads/brief%20and%20appendix%20checklist%202026_0.pdf) | per checklist |
| CA10-COVER-003 | Cover states whether oral argument is requested; if requested, a statement of reasons follows the conclusion. 10th Cir. R. 28.2(C)(2) | [Appeal Requirements FAQ 2026](https://www.ca10.uscourts.gov/sites/ca10/files/documents/downloads/Appeal%20Requirements%20FAQ%202026.pdf); checklist | per checklist |
| CA10-COVER-004 | Cover colour: appellant's brief is **blue** (paper hard copies). FRAP 32(a)(2), 28.1(d); checklist item 1 | FRAP 32 (LII); checklist | verified (colour not rendered; see Known gaps) |
| CA10-CONT-001 | Table of contents with page references, listing all attachments. FRAP 28(a)(2); 10th Cir. R. 28.2(C)(5) | checklist | per checklist |
| CA10-CONT-002 | Table of authorities. FRAP 28(a)(3) | checklist | per checklist |
| CA10-CONT-003 | Statement of prior or related appeals, after the table of authorities; negative statement if none. 10th Cir. R. 28.2(C)(3) | FAQ 2026; checklist | per checklist |
| CA10-CONT-004 | Heading numbering: Argument points I., sub-points A., 1., a.; elsewhere A., 1., a. (template convention, not a rule) | template convention | n/a |
| CA10-CONT-005 | Jurisdictional statement, statement of issues, statement of case, summary, standard of review, argument, conclusion. FRAP 28(a)(4)-(9) | checklist | per checklist |
| CA10-CONT-006 | Decision under review and final judgment attached; attachments listed in TOC. 10th Cir. R. 28.2(A), (C)(5) | checklist | per checklist |
| CA10-LEN-001 | Principal brief: **no more than 13,000 words**; type-volume certificate required. FRAP 32(a)(7)(B)(i), 32(g)(1) | FRAP 32 (LII) | verified |
| CA10-LEN-002 | Certificate of compliance required when the brief exceeds 30 pages (template always prints it; FRAP 32(g)(1) requires it for any brief under 32(a)(7)(B)). | FAQ 2026; FRAP 32 (LII) | verified |
| CA10-CERT-001 | Certificate of digital submission: privacy redactions per FRAP 25(a)(5) and 10th Cir. R. 25.5; native PDF; exact copy; virus scan; free of viruses | exemplar wording; checklist cites 25.5 | exemplar + checklist |
| CA10-CERT-002 | Certificate of service for CM/ECF filing, FRAP 25 and 10th Cir. R. 25.4 | exemplar wording; checklist cites 25.4 | exemplar + checklist |
| CA10-SIG-001 | Signature: `s/` plus name (electronic signature). 10th Cir. R. 46.5(A), (C) | checklist | per checklist |

Rule-number conflict, resolved in favour of 14 pt: the checklist says "Is the brief in either 13- or 14-point font (14-point font is preferred)? See 10th Cir. R. 32(A)". FRAP 32(a)(5)(A) requires 14-point or larger for a proportional face. The template uses 14 pt, which satisfies both. The 10th Cir. R. 32(A) text was not fetched and was not read directly.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block, then the markdown body. The template generates the cover, TOC, TOA, prior-appeals statement, signature block, oral-argument statement, certificates, and attachments index.

### Frontmatter

| Field | Required | Feeds |
|---|---|---|
| `case_number` | yes | Cover top line "No. ..." |
| `caption` | yes | Two sides; each `names` (one centered line each) and `designation`. "v." inserted between. |
| `proceeding` | yes | "Appeal from the United States District Court for ..." |
| `judge` | yes | Cover line (e.g., "Honorable ..., District Judge") |
| `district_court_case` | yes | Cover line "Case No. ..." |
| `brief_title` | yes | Cover title (printed in capitals) |
| `oral_argument` | yes | `requested` or `not requested`; cover line; the statement section appears only for `requested` |
| `oral_argument_statement` | yes if requested | "Statement in Support of Oral Argument" |
| `counsel` | yes | List of groups; each has `names` and `lines` (the lines carry each group's own telephone number) |
| `signature` | yes | `signer` (printed as `/s/ Name`) and `lines` (italic lines under the signature block) |
| `date` | yes | Dated line and certificate dates |
| `prior_appeals` | yes | Statement of prior or related appeals (text; a negative statement when there are none) |
| `digital_submission` | yes | `scanner` and `updated` for the digital-submission certificate |
| `attachments` | yes (may be empty) | Index of attachments, in order |
| `authorities` | yes if the body cites any | Registry; `kind` is `case`, `constitution`, `statute`, `regulation`, `rule` or `other`; `name` optional; `cite` required |

### Body

- `# Heading` is a section (bold, capitals, centered). `## Heading` under `# Argument` is a centered point heading (I., II.); deeper levels are A., 1., a., as in the template.
- Cite with a link to `toa:KEY`, full citation as the link text: `[*Bost v. Ill. State Bd. of Elections*, 146 S. Ct. 513, 519 (2026)](toa:bost)`. Every link adds a TOA page. A key missing from `authorities:` stops the build.
- Footnotes: `text[^key]`, and `[^key]: text` definitions. In this sample the definitions sit above the body, not at the end. A footnote definition as the last block of the body stops the signature block from being kept with the preceding paragraph (see review, page 5).
- Word count: the body (from the first heading to the end of the conclusion; headings, text, footnotes and block quotations) is counted and printed in the certificate of compliance, and the build stops above 13,000. The cover, TOC, TOA, prior-appeals statement, oral-argument statement, certificates and attachments index are not counted.

## Page review (13 pages, all rendered at 60 dpi and read)

- p1 cover: fits on one page; caption, originating case line, counsel block, oral-argument line all present. Pass.
- p2 TOC: all sections listed with page numbers, Argument point I. under Argument, attachments index listed. Pass.
- p3 TOA: one page; cases, statutes, grouped; page numbers from links (e.g., *Bost* on 2, 3, 4, 5). Pass.
- p4 Statement of prior or related appeals (roman iii): negative statement. Pass. Alone on its page (the TOA fills p3).
- p5 Jurisdictional statement, issues, start of statement of the case: 14 pt, double spacing, footnote 1 at foot. Pass.
- p6 Rest of statement of the case, summary of argument. Pass.
- p7 Standard of review, Argument I opening (italic case names, TOA links). Pass.
- p8 Argument I, continued. Pass.
- p9 Argument I continued, footnote 2 at foot of page; conclusion moved to next page with its signature block (keep logic). Pass.
- p10 Conclusion, signature block, Statement in Support of Oral Argument. Pass.
- p11 Certificate of compliance: 1,136 words, typeface and type-style statements. Pass.
- p12 Certificate of digital submission and certificate of service (share a page). Pass.
- p13 Index of attachments. Pass.

Defects found and fixed during review:
1. Certificate heading read "32(A)": `upper()` turned the rule's `(a)` into `(A)`. Heading shortened to "Certificate of Compliance"; the rule citation stays in the body text.
2. Conclusion paragraph separated from its signature block (page 5 vs 6). Cause: footnote definitions at the end of the body. Moved above the body.
3. Signature block alone on a page: fixed by the same change.
4. The sample first ran to 17 pages; trimmed to 13 (body cut to Argument I; Argument II removed; TOA "Rules" group made plain text so TOA fits one page; certificates and oral-argument statement share pages). The template now places the oral-argument statement after the signature block, not on its own page.

## Overlay

`samples/OVERLAY-lyman-v-henderson-opening-brief.pdf` pairs each sample page with the filed page sharing the most words (`-overlay.txt`):

| Sample p. | Filed p. | Word overlap |
|---|---|---|
| 1 cover | 1 | 74.6% |
| 2 TOC | 2 | 36.5% |
| 3 TOA | 4 | 50.0% |
| 4 prior appeals | 6 | 18.3% |
| 5 jurisdiction | 7 | 82.2% |
| 6 conclusion/signature | 10 | 71.3% |
| 7 standard/argument | 11 | 57.4% |
| 8 argument | 13 | 52.1% |
| 9 argument, conclusion | 14 | 64.9% |
| 10 oral argument statement | 33 | 55.3% |
| 11 compliance cert | 34 | 64.1% |
| 12 digital + service certs | 35 | 68.6% |
| 13 index of attachments | 37 | 44.4% |

The overlay is a diagnostic. Red is our render, blue is the filed page, black is both. Pairing is by text, so the low-overlay pages (TOC, prior-appeals, index) are short pages with few shared words, not layout failures. The filed brief's cover, TOC and TOA are set in Times New Roman with different leaders, so their overlap is expected to be low. The overlay is not a score.

## Known gaps and accepted deviations

- **Font.** The template uses EB Garamond (vendored, `fonts/eb-garamond/`), not the exemplar's Times New Roman. It is a proportional serif at 14 pt, which meets FRAP 32(a)(5)(A). The certificate of compliance states the face actually used.
- **Cover colour.** Blue (appellant) is required for paper hard copies (CA10-COVER-004) and is not produced; the PDF is white, as in the ca9 template.
- **Word count exclusions.** The count excludes the cover, TOC, TOA, statement of prior/related appeals, oral-argument statement, certificates and attachments index. Whether 10th Cir. R. 32(B) excludes anything else (for example, the prior-appeals statement) was not verified; the checklist only says "excluding the items listed under FRAP 32(f) and 10th Cir. R. 32(B)". The 10th Cir. R. 32(B) text was not fetched.
- **Heading style** is the ca9 point-heading style (small capitals, centered), not the exemplar's. Tier 2 (professional look) is judged as acceptable; it is a template convention.
- **Oral-argument statement** follows the signature block on the same page (the exemplar gives it its own page). Accepted to keep the sample within the 8-14 page target.
- **Certificates.** Compliance, digital submission and service are always printed (CA10-LEN-002). The digital-submission wording comes from the exemplar and the checklist cites 10th Cir. R. 25.5; the local rule text was not fetched.
- **Attachments** are listed on the index only. The decision and judgment are filed as separate PDFs, not produced by the template.
- **Sample is a portion** of the filed brief (roughly 1,100 words of body against about 5,650 in the original). Where the transcription drops text, it is dropped at paragraph boundaries; no sentence is stitched from non-adjacent text. The one paragraph read incompletely in the source (the district court’s "acknowledged" sentence, brief p. 7 / PDF p. 12) was omitted.
- **No `checks.yaml`** for this doc type; no gate script was run against it (out of scope for this box). Verification is the render, the overlay, and the page review above.
- **Court-root folders.** The court-root `typst/` and `samples/` (ca9's opening brief) are untouched; so are `data/`, `tools/`, `lib/`, `fonts/` and `vendor/`.

## Engines

- **typst** (primary): `typst/`, output `samples/OUTPUT-lyman-v-henderson-opening-brief.pdf`.
- **latex** (`latex/template.tex` + `latex/ca10-opening-brief.lua`): output `samples/OUTPUT-lyman-v-henderson-opening-brief.latex.pdf`, 19 pages against typst's 13. Matches the 14-pt EB Garamond type, 31.43-pt double spacing, 1-inch margins, roman front matter and arabic body, cover on one page, TOC and TOA with page references, and the certificates. Known differences: pagination is longer; footnote text on some pages runs wide (not yet fixed); the TOC wrap indent is not hung; the signature block is not kept with the last paragraph.
- **docx**: not built yet (see the court-level PR notes). LibreOffice is not installed on this box; a Debian-package extraction was started but not verified.

## Typeface (fonts pass, 2026-10-15)

- **Face required by the rules: none named.** FRAP 32(a)(5) requires a proportionally spaced face with serifs, 14-point or larger (or a monospaced face); FRAP 32(a)(6) requires plain roman. The court's own 2026 briefing checklist (item "Is the brief in either 13- or 14-point font (14-point font is preferred)? See 10th Cir. R. 32(A)") and its Quick Reference Guide ("Form and Font Size (14-Point Preferred)") name no face. Source texts were read 2026-10-15: Cornell FRAP 32, `ca10.uscourts.gov` checklist 2026 and QRG (PDF text via pdftotext). The text of 10th Cir. R. 32(A) itself was not retrieved (the court's local-rules page returned 404).
- **Unverified claim, not used.** A secondary Typelaw blog post says the Tenth Circuit requires Century Schoolbook. No court-published text found says so, so the template does not follow it. The filed exemplars use different faces (Oliver reply: Century Schoolbook; Lyman opening: Times New Roman), which is consistent with the rules naming none.
- **Substitute: none; EB Garamond kept** (vendored, `fonts/eb-garamond/`), per the fonts policy: a court whose rules name no face keeps EB Garamond. Set in the template as `font-family`.
- **Compatibility:** not applicable (no named face to match). Pagination is therefore not checked against a Times or Century filing; the length gate uses the word count, not the page count.
- **Renders (2026-10-15):** `tools/render.sh` with vendored fonts only, zero warnings; `pdffonts` shows only EB Garamond (Regular, Bold, Italic). Page counts unchanged. Every page rasterised at 60 dpi and viewed. Overlay regenerated against the filed exemplar (downloaded from the CourtListener URL in `exemplars/SOURCE.md`; the PDF is not committed to the repo).

## Engines

DOCX (`docx/`): `build-reference.sh` makes `reference.docx` (EB Garamond 14 pt; exact 31.4 pt double spacing; 0.5 in first-line indent; letter paper, 1 in margins; single-spaced headings, footnotes and front matter; centered page-number footer). `ca10.lua` writes the cover, the sections (cover without number, lower-roman front matter, arabic body), the labelled headings, the signature block, the oral-argument statement and the certificates.

- Matches the typst output: 13 pages (typst: 13); 14 pt type, double spacing, margins; footer numbers i, ii, iii, then 1 to 9; cover on one page; the statement of prior appeals; heading labels (I., A., 1., a.); footnotes; signature block; the certificate of compliance word count (1,136, same as typst); the certificate of digital submission with the scanner and its date; the index of attachments.
- Differs (tier 2, not chased): headings sit lower at the top of a page (Word keeps space before a heading at a section start); the cover spacing is fixed rather than fitted to one page; line breaks differ in places (LibreOffice breaks after a hyphen in "App.113-14", typst does not); the contents and authorities have no dot leaders.
- BLOCKED `TOC` (contents, page column): the page numbers need a field update in Word or LibreOffice; this pipeline does not update fields, and no first-pass page map is written. The contents list every entry in order, without numbers.
- BLOCKED `TOA` (table of authorities, "Page(s)" column): same reason; the authorities are listed, cited on the right pages in the typst output only.
- `sh tools/check.sh <court-dir> --engine docx` fails: the court folder has no `checks.yaml` (Gate 1 cannot run). Nothing was edited to pass it.
