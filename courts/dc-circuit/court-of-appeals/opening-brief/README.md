# D.C. Circuit: appellant's opening brief (typst)

Status: exemplar found, template built and rendered, sample reviewed page by page. Typeface switched to the court-named substitute on 2026-10-15 (see Known gaps, item 1). Open items are listed under "Known gaps"; the line pitch needs David's decision.

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-opening-brief.pdf` | Filed appellants' principal brief, No. 25-5181 (June 27, 2025). Provenance in `usage/SOURCE.md`. |
| `usage/INPUT-opening-brief.md` | Transcription of the exemplar: frontmatter with its cover, certificate, glossary, authorities and signature, and a portion of the body (introduction through the start of argument, then conclusion). |
| `usage/OUTPUT-opening-brief.typst.pdf` | Render of the sample. 15 pages. |
| `usage/OVERLAY-centro-opening-brief.pdf`, `-overlay.txt` | Red/blue overlay of the render on the exemplar, and the page map. |
| `typst/cadc-opening-brief.typ` | The template: `dc-brief(meta, body)`. Content-agnostic; every number is a named parameter at the top. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`. |

Build (from the repo root; the vendored fonts only):

```sh
sh tools/render.sh courts/dc-circuit/court-of-appeals/opening-brief usage/INPUT-opening-brief.md
sh tools/overlay.sh courts/dc-circuit/court-of-appeals/opening-brief centro-opening-brief
```

## Governing rules

Verified 2026-10-14 against the D.C. Circuit's own rules PDF, "Circuit Rules Effective January 1, 1994, As Amended Through December 4, 2025" (which also contains the FRAP text): https://www.cadc.uscourts.gov/sites/cadc/files/rules-RulesFRAP20251204.pdf

| ID | Requirement | Source | Where in the template |
|---|---|---|---|
| DC-FRAP-032-A2 | Cover: case number centered at top; court name; title of case; nature of proceeding and court below; brief title identifying the party; counsel name, office address and telephone | FRAP 32(a)(2)(A)–(F) | `cover()` |
| DC-CR-028-A8 | The words "ORAL ARGUMENT NOT YET SCHEDULED" (or the argued/submitted statement) in capital letters at the top of the front cover | Circuit Rule 28(a)(8) | `cover()`, from `oral_argument` |
| DC-FRAP-032-A4 | 8½ × 11 paper; double-spaced; quotations over two lines and headings and footnotes may be single-spaced; margins at least one inch on all sides | FRAP 32(a)(4) | `page-margin`, `body-leading`, `single-leading` |
| DC-FRAP-032-A5 | Proportionally spaced serif face, 14-point or larger; sans-serif allowed in headings and captions | FRAP 32(a)(5)(A) | `font-family`, `type-size` |
| DC-HB-IX-A6 | Handbook, Format: encourages Century and Times New Roman; discourages Garamond; 14-point serif | D.C. Circuit Handbook IX.A.6, as revised 16 March 2021 (Clerk's notice "Preferred Typefaces for Briefs"): https://www.cadc.uscourts.gov/sites/cadc/files/noticeGen-noticePreferredTypefacesForBriefs.pdf | Face: Century → `TeX Gyre Schola` (`docs/FONTS.md`). See Known gaps, item 1. |
| DC-FRAP-032-A6 | Plain roman type; case names italicized | FRAP 32(a)(6) | markdown `*...*` |
| DC-FRAP-028.1-E2 / 032-A7 | Appellant's principal brief: no more than 13,000 words (or 1,300 monospaced lines); the template refuses to build over the limit | FRAP 28.1(e)(2)(A)(i), 32(a)(7)(B)(i); Circuit Rule 32(e) | `word-limit`; `dc-brief()` panics |
| DC-CR-028-A1 | Certificate as to Parties, Rulings, and Related Cases, immediately inside the cover and before the table of contents, with paragraphs A (parties and amici), B (rulings under review), C (related cases), and the Rule 26.1 disclosure | Circuit Rule 28(a)(1)(A)–(C); FRAP 26.1; Circuit Rule 26.1 | front matter, from `certificate` |
| DC-FRAP-028-A2 | Table of contents with page references | FRAP 28(a)(2) | `outline()` |
| DC-CR-028-A2 | Table of authorities: every page on which each authority is cited is listed; "passim" or similar may not be used; asterisks optional | Circuit Rule 28(a)(2) | `toa()`; the template has no "passim" path |
| DC-CR-028-A3 | Glossary of every abbreviation, on a page immediately after the table of authorities | Circuit Rule 28(a)(3) | `glossary` (optional, from metadata) |
| DC-FRAP-028-A4 | Jurisdictional statement (district and court of appeals jurisdiction, timeliness dates, finality) | FRAP 28(a)(4)(A)–(D) | author content in the body; not checked by the template |
| DC-FRAP-028-A5–A9 | Issues presented, statement of the case, summary of argument, standard of review, argument, conclusion | FRAP 28(a)(5)–(9); Circuit Rule 28(a)(6) | body headings |
| DC-CR-028-A5 | Statutes and regulations set out in the body or in an addendum; an addendum over 40 pages is bound separately; a colored separation page applies when bound with the brief | Circuit Rule 28(a)(5) | `# Addendum` renders after the certificates; the colored separator is paper-only (Known gaps, item 7) |
| DC-FRAP-032-G1 | Certificate of compliance stating the word count, and the typeface and type-style statement | FRAP 32(g)(1)–(2) (Form 6) | certificate of compliance, word count computed from the body |
| DC-FRAP-025-D | Certificate of service | FRAP 25(d) | certificate of service |
| DC-CR-032-B1 | Electronic filings are PDFs generated from a word-processing file and are text-searchable | Circuit Rule 32(b)(1) | the PDF is text-searchable (`pdftotext` yields the body) |

Notes on the rules: the D.C. Circuit's cover rule is Circuit Rule 28(a)(8), not Circuit Rule 32(b)(1), which governs electronic filing. Circuit Rule 32(e) governs form only by reference to FRAP 28.1 and 32(a).

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block (metadata) followed by the body. The template generates the cover, the certificates, the tables, the signature block and the glossary page.

### Frontmatter

| Field | Required | Type | Feeds |
|---|---|---|---|
| `case_number` | yes | string | Cover "No. ..." and the PDF title |
| `oral_argument` | yes | string | Cover statement, capitals, at the top (Circuit Rule 28(a)(8)) |
| `caption` | yes | list of two sides | Cover. Each side: `names` (one centered line each; inline markdown allowed) and `designation` (e.g. `Plaintiffs-Appellants,`). "v." is inserted between the sides. |
| `proceeding` | yes | string | Cover, "On Appeal from ..." |
| `district_court_case`, `judge` | no | string | Cover lines, shown when given |
| `brief_title` | yes | string | Cover title (printed in capitals) |
| `counsel` | yes | list of groups | Cover counsel block. Each group: `names` and `lines` (phone number included in `lines`). Groups are set side by side. |
| `date` | yes | string | Under the cover counsel; the signature block; the certificate of service |
| `word_processor` | yes | string | Certificate of compliance: "using ..." |
| `certificate` | yes | map | `parties`, `rulings`, `related`, `disclosure`: each markdown text, paragraphs separated by a blank line |
| `signature` | yes | map | `signer` (printed as `/s/ Name`, then the name) and `lines` (italic lines under it) |
| `glossary` | no | list of `{abbr, meaning}` | Glossary page after the table of authorities |
| `authorities` | yes if the body cites any | map | Table of authorities registry: `kind` (`case`, `constitution`, `statute`, `regulation`, `rule`, `other`), `name` (optional; italic for cases), `cite` (required), `sort` (optional) |

### Body

- `# HEADING` (level 1) is a centered bold section. Write the headings in capitals as the brief prints them.
- `## heading` (level 2) and `### heading` (level 3) are bold, left-aligned. Write the labels yourself (`I.`, `A.`, `1.`); the template does not number headings.
- Citations: link to a registry key, with the full citation as the text: `[*Arizona v. United States*, 567 U.S. 387, 407 (2012)](toa:arizona)`. A short form (`*Id.* § 6651`) links to the same key. Every link records the page on which it starts. A key not in `authorities:` stops the build.
- A line that starts with a number and a period is a list to a markdown parser. Escape it: `1\. Individuals ...`.
- `> quoted text` is a block quotation (single-spaced, indented).
- `# Addendum` ends the brief: everything below it renders after the certificate of service and is excluded from the word count.
- Not supported: tables, images, raw typst.

## Overlay

`sh tools/overlay.sh` puts the sample page (red) over the matched exemplar page (blue); black is where both agree. Pages are paired by word overlap, so the sample's pages land on the exemplar's pages they came from. Word overlap by page: 92.5% on the cover (p.1); 26% on the table of authorities (p.5; the sample lists far fewer authorities than the exemplar); 39–77% on the other pages. The overlay is a diagnostic, not a score; it is recorded here so the pages are not reviewed in isolation.

Page map (`usage/OVERLAY-centro-opening-brief.txt`): sample p.1 → exemplar p.1; p.2 → p.2; p.3 → p.4; p.4 → p.5; p.5 → p.8; p.6 → p.15; p.7 → p.16; p.8 → p.18; p.9 → p.19; p.10 → p.20; p.11 → p.41; p.12 → p.45; p.13 → p.70; p.14 → p.71; p.15 → p.72.

## Review record (Gate 2)

Re-reviewed 2026-10-15 after the font change to TeX Gyre Schola: every page of `usage/OUTPUT-opening-brief.typst.pdf` (15 pages) was rendered at 60 dpi and viewed, checked against the exemplar's layout and the rules above. The table is that review. Before the change the render was 14 pages in EB Garamond; the body now runs one page longer.

| Page | Content | Finding |
|---|---|---|
| 1 | Cover | Fits one page. Oral-argument line, case number, court, caption, proceeding, title, three counsel groups, date. Changed 2026-10-16: three counsel columns broke names ("Michael T. / Kirkpatrick"); groups are now set two to a row, as in the exemplar. |
| 2 | Rule 28(a)(1) certificate, parties, rulings (i) | Heading two lines, single-spaced. Paragraphs had no indent and no gap, so consecutive paragraphs read as one; fixed 2026-10-16 (first-line indent). |
| 3 | Certificate cont. (related cases, Rule 26.1) (ii) | OK. |
| 4 | Table of contents (iii) | Page numbers match the layout. OK. |
| 5 | Table of authorities (iv) | Every citation page listed, no "passim". Fixed 2026-10-16: statutes sorted as text ("8 U.S.C." after "28 U.S.C."), and a full-width entry ran into its page number. |
| 6 | Glossary (v) | OK. |
| 7 | Introduction, p. 1 | Double-spaced, first-line indent. OK. |
| 8 | Introduction cont. (the district court's denial) | OK. |
| 9 | Importantly...; Jurisdiction; Question presented; Statutory provisions | OK. |
| 10 | Statement of the case (A); Summary of argument | OK. |
| 11 | Argument I (statutory text); Standard of review | OK. |
| 12 | Argument I (heading and text) | OK. Space at the foot: the conclusion moved to the next page with the signature. |
| 13 | Conclusion and signature block | Fixed 2026-10-16: the signature block was alone on this page; the last paragraph is now kept with it, and headings never end a page. |
| 14 | Certificate of compliance | Word count and typeface sentence present ("14-point TeX Gyre Schola"). OK. |
| 15 | Certificate of service | OK. |

Defects found during review and fixed in the template: the bold lead-ins of the certificate ran into their paragraphs; paragraph spacing overlapped at every paragraph break; single-spaced two-line headings overlapped; the body lost its first-line indent (a `set par` in the certificate section leaked into the body; the body now resets its own paragraph style).

## Known gaps

1. **Typeface (resolved 2026-10-15).** Face required: Century. The Handbook (IX.A.6) names Century and Times New Roman as the preferred faces and discourages Garamond; the filed exemplar is set in Century Schoolbook 14-pt. Substitute: `TeX Gyre Schola` (`docs/FONTS.md`; a Century Schoolbook clone, with glyph widths consistent with the Adobe base-35 New Century Schoolbook AFMs). The template was EB Garamond before this change. Page count went from 14 to 15; the sample reflows and no line is forced. The Handbook names Times New Roman too (`Liberation Serif`); Century is used here because the filed exemplar is set in it.
2. **Line pitch.** `body-leading` is 1.07em, giving a baseline pitch of about 24 pt at 14 pt. That is the pitch of the filed exemplar's body text. FRAP 32(a)(4) says "double-spaced" without a number; a pitch of about 2× the nominal 14 pt line (≈28 pt) would be larger and would push the sample well past 15 pages. **Decision for David.**
3. **Word count.** The certificate's count (1,312) is the template's count of the sample's body, which is a portion of the brief. The exemplar's own certificate states 10,418 words for the whole brief. The 13,000-word limit is enforced at build time for any sample.
4. **Sample is a portion.** It is the exemplar's introduction through the start of the argument, then the conclusion, signature and certificates. The argument body and the statutory addendum are not transcribed. The summary's point I is transcribed only as far as the text read.
5. **Signature alone on a page (resolved 2026-10-16).** The body's last paragraph is now kept with the signature block, as in the reply template.
6. **Cover color.** FRAP 32(a)(2) makes the appellant's cover blue. This applies to paper copies; the PDF is not colored.
7. **Addendum separator.** Circuit Rule 28(a)(5) requires a distinctly colored separation page when the addendum is bound with the brief. Paper only; not produced. The sample has no addendum.
8. **Headings are not numbered by the template.** The labels are typed in the markdown.
9. **Glossary completeness** (Circuit Rule 28(a)(3)) is the author's job; the template renders what is given.
10. **Jurisdictional statement** (FRAP 28(a)(4)(C)–(D): timeliness dates, finality) is author content. The template does not check it.
11. **Signature block** lists one signer. The exemplar lists three counsel in the signature; the template takes one `signer` per block.
12. **Authorities.** The sample's registry has 12 entries; the sample cites no authority it does not list. Short-form citations link to the registry key of the full citation.

## Not verified

- The Clerk's Handbook and "Brief Compliance Checklist" were not read in their current versions. The checklist URL returned 404 when fetched. The typeface rule is taken from the 16 March 2021 notice, which quotes the Handbook section.
- The exemplar's page structure (sections, TOC page numbers) was read from its text layer, not from a rendering. The TOC numbers in the sample are the template's, not the filing's.

## Search record

- CourtListener search for D.C. Circuit appellant briefs: https://www.courtlistener.com/api/rest/v4/search/ (queries "Brief for Appellant", "Oral Argument Not Yet Scheduled"). Returned mostly orders; the usable hits were the Centro (No. 25-5181) and Kelly (No. 26-5070) briefs, both on public sites.
- Web searches for the Circuit Rule 32 text returned other circuits' rules; the D.C. Circuit text came from the rules PDF above.

## Engines

Three engines per doc type (`docs/EVAL-LOOP.md`, "Engines"). The typst template is the reference.

| Engine | Folder | Output | Status |
|---|---|---|---|
| typst (primary) | `typst/` | `usage/OUTPUT-opening-brief.typst.pdf` | rendered, reviewed (Known gaps above) |
| latex | `latex/` (`render.sh`, `template.tex`, `cadc.lua`) | `usage/OUTPUT-opening-brief.latex.pdf` | rendered, 15 pages, same count as typst |
| docx | `docx/` (`reference.docx`, `cadc.lua`, `make-reference.sh`) | `usage/OUTPUT-opening-brief.docx` | `.docx` written and XML-validated; `.docx.pdf` not produced (see below) |

Build:

```sh
sh tools/render.sh --engine latex courts/dc-circuit/court-of-appeals/opening-brief usage/INPUT-opening-brief.md
sh tools/render.sh --engine docx courts/dc-circuit/court-of-appeals/opening-brief usage/INPUT-opening-brief.md
```

`latex/render.sh` runs tectonic until the aux and toc files settle, so the table of contents and table of authorities carry the page numbers of the PDF. `tools/render-latex.sh` alone (single pass) would print placeholder page numbers and must not be used for this engine.

**LaTeX: what matches typst.** Page size and margins (letter, 1 in); TeX Gyre Schola 14 pt (vendored, via `fontdir`); double-spaced body at a 24 pt pitch; single-spaced footnotes, headings, quotations and certificate blocks; arabic body pages from 1, roman front matter from the certificate; cover contents and order; the certificate of parties, rulings, related cases and Rule 26.1 disclosure; contents with dot leaders; table of authorities in the six groups with every citation page (no "passim"); glossary; certificate of compliance (word count from the body, addendum excluded); certificate of service; addendum after the certificates. **What differs:** the compliance count is 1,311 against typst's 1,312 for the same sample (a one-word counting difference between the Lua and typst word counters); heading styling is a plain bold rather than typst's exact heading spacing; the cover's counsel columns wrap at slightly different points; the contents entries are set in regular weight, as in typst. Tier 2 judgement: the layout reads as the typst output at 50 dpi.

**DOCX: BLOCKED items.** The engine could not be checked against a rendered PDF on this box:
- `docx.pdf` (LibreOffice render, Gates 0 and 1): BLOCKED. The docx engine needs `soffice`. conda-forge has no LibreOffice package. The Debian LibreOffice debs were extracted and the binary starts, but it aborts with a UNO `DeploymentException` (its bootstrap paths are hard-coded to `/usr/lib/libreoffice`, and the sandbox denies the bind mount that would fix them). The render log is in `/work/artifacts/docx-render-op.log` on the build box, not in the repo.
- Table of contents page numbers: BLOCKED. The contents list is written without page numbers (Word fields are not updated by pandoc or LibreOffice here). A TOC check fails until a field update step exists (`docs/DOCX.md`, "Fields").
- Table of authorities page numbers: BLOCKED for the same reason; the list is written without pages (`docs/DOCX.md` expects the TOA check to be BLOCKED for LibreOffice).
- Cover and certificate layout: the cover is raw OOXML paragraphs, centered, in the body's 24 pt pitch; the counsel columns are stacked, not side by side (a table is needed; DOCX.md notes table rendering differs). Word and LibreOffice may paginate the cover differently.
- Word check: `.docx` is a valid zip with well-formed XML parts (`unzip -tq`, `xmllint --noout`). Opening it in Word or LibreOffice without a repair prompt was not verified (no LibreOffice here).

`docx/make-reference.sh` regenerates `docx/reference.docx` (TeX Gyre Schola 14 pt, body lines exactly 24 pt, first-line indent 0.5 in, black headings, letter page with 1 in margins, centered PAGE field in the footer).

## Verification pass 2026-10-16 (fb-595.26.12)

- Rendered: `sh tools/render.sh .../opening-brief usage/INPUT-opening-brief.md` exits 0, no typst warnings, 15 pages (the committed PDF had been 14 pages and was stale; the 15-page review above matches the re-render). Overlay rerun: same page map as above; overlaps unchanged except p.12 (71.7%) and p.13 (33.3%), where the conclusion moved to the signature page.
- Viewed: all 15 pages at 60 dpi before the fixes, the changed pages after each fix, and all 15 pages of the final render; all 15 overlay pages at 40 dpi (contact sheet); exemplar pages 1-8 against our cover, certificate, contents and authorities.
- Fixed (tier 2), in `typst/cadc-opening-brief.typ`:
  - Certificate of parties: paragraphs ran together (no indent, no gap). They now take the body's first-line indent, as in the exemplar.
  - Table of authorities: entries sorted with digit runs compared as numbers (8 U.S.C. before 26 U.S.C.); the page list has its own column, so a full-width entry no longer runs into it; long lists wrap in that column.
  - Signature block alone on a page: the body's last paragraph is kept with the signature, and headings are sticky (never last on a page).
  - "§ 6103" and "6103(i)(2)" are never split across lines.
  - Cover: counsel groups are set two to a row (`counsel-columns`); a third column broke names and street lines at 14 pt. The cover spacing shrinks (never the type) to keep the cover on one page; the cover panics if it cannot fit.
- LaTeX re-rendered: 15 pages, builds (latex template unchanged).
- Remaining gaps: Known gaps 2 (line pitch, David's decision), 3-4 (partial sample), 6-12 unchanged.
