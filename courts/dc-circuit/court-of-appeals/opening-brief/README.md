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
| DC-FRAP-032-A4 | 8½ × 11 paper; double-spaced; quotations over two lines and headings and footnotes may be single-spaced; margins at least one inch on all sides | FRAP 32(a)(4) | `page-margin`, `pitch-body`, `pitch-single` |
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
| 1 | Cover | Fits one page. Oral-argument line, case number, court, caption, proceeding, title, three counsel groups, date. Changed 2026-10-16: three counsel columns broke names ("Michael T. / Kirkpatrick"); groups are now set two to a row, as in the exemplar. Changed 2026-10-22 (fb-595.77, the README hero): the exemplar's short rules between the cover blocks (typst only; a rule never changes the flow), bold case number, oral-argument line and counsel in roman, designations set to the right, cover gaps 12 pt (was 10) on all three engines. |
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
2. **Line pitch.** `pitch-body` is 25 pt at 14 pt (since fb-595.54.2 a line box of its own; it was a 1.07 em leading, 25.09 pt). That is the pitch of the filed exemplar's body text. FRAP 32(a)(4) says "double-spaced" without a number; a pitch of about 2× the nominal 14 pt line (≈28 pt) would be larger and would push the sample well past 15 pages. **Decision for David.**
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

Three engines per doc type (`docs/EVAL-LOOP.md`, "Engines"). The typst template is the reference. All three are on the shared cross-engine layout model since fb-595.54.2 (see "Cross-engine" below): the latex and docx renders break every line and every page where typst does, and `eval.yaml` gates it.

| Engine | Folder | Output | Status |
|---|---|---|---|
| typst (primary) | `typst/` | `usage/OUTPUT-opening-brief.typst.pdf` | 15 pages, reviewed |
| latex | `latex/` (`template.tex`, `cadc.lua`) | `usage/OUTPUT-opening-brief.latex.pdf` | 15 pages, XENG-001..003 PASS |
| docx | `docx/` (`reference.xml`, from which `fb render` builds the reference document; `cadc.lua`) | `usage/OUTPUT-opening-brief.docx`, `.docx.pdf` | 15 pages (LibreOffice PDF), XENG-001..003 PASS |

Build (`fb render` reruns pdflatex until the aux and toc files settle, and renders the docx in passes until the page map of its LibreOffice PDF settles):

```sh
sh tools/render.sh --engine latex courts/dc-circuit/court-of-appeals/opening-brief usage/INPUT-opening-brief.md
sh tools/render.sh --engine docx courts/dc-circuit/court-of-appeals/opening-brief usage/INPUT-opening-brief.md
```

- **latex**: TeX Gyre Schola 14 pt (`tgschola`, stock TeX Live) in the typst line boxes; the cover, the certificate as to parties, contents and authorities (page numbers in two passes, every page, no "passim"), glossary, signature kept with the last paragraph, both certificates; the certificate's word count (1,312) counted from the markdown as typst counts it. Differs only in positions that are not breaks: a centered line sits up to 2.2 pt further left than typst's.
- **docx**: TeX Gyre Schola 14 pt; sections (cover without number; certificate, contents, authorities and glossary in lower-case roman; body and certificates from 1, footers written by fb render); the contents and authorities carry their page numbers (fb render's page map, `tools/fb/src/docxpass.rs`: `cadc.lua` writes a needle for every heading and citation); the cover's counsel in a two-column borderless table. The earlier BLOCKED items (no `.docx.pdf`; contents and authorities without page numbers; counsel stacked) and the tier-1 failure `DEF-FORM-002` are fixed. Opened in LibreOffice only, not in Word.

## Cross-engine (fb-595.54.2)

All three engines on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/latex/xengine.sty` and `xengine.lua`, `lib/docx/xengine.lua` and `xengine-reference.sh`, whose recipe fb render has since taken over from `docx/reference.xml`; docs/EVAL-LOOP.md, "Adopting the reference breaker"), `params.cross_engine: gate` in `eval.yaml`.

- typst: `show: xengine.with(pitch: 25pt, list-indent: 0.5in)`; line boxes of 25 pt (body), 21 pt (quotations, footnotes, tables, signature and certificate blocks, level-3 headings), 29 pt (level-1 headings, 19.5 pt bold) and 25 pt (level-2, 17 pt bold), 16.4 pt (the cover); every space in pt; `listing-row` contents and authorities (36 pt page column, or the page list's width); the glossary's abbreviations in a 1 in column. Changed from the earlier template: the body pitch is 25 pt (was 1.07 em leading, 25.09 pt); single spacing is 21 pt (was 16.4 pt; see the LibreOffice finding below); headings 19.5 / 17 pt (were 1.4 / 1.2 em, 19.6 / 16.8 pt: Word has only half points); the cover's spacing is fixed (was the largest of six that fits; the sample used 0.45 of the old gaps, which are now the gaps) and the date follows the counsel (was pushed to the foot of the page: Word has no fill); the signature's right column is a length (241 pt); each citation's page is taken after its first word (a citation that opens a line was filed under the line before). Kept: TeX Gyre Schola 14 pt, 1 in margins, the half-inch indents, the parts and their order.
- latex: `\usepackage{xengine}`, `\xe@lines`, `\addvspace`, `\xe@row`, `\xe@footnotemarks{14}`, `\xe@lists{0.5in}`; `cadc.lua` writes the whole brief, through `require("latex.xengine")` over the body and every metadata value.
- docx: `docx/reference.xml` (`base="xengine"`: fb render builds the reference document on the shared recipe; TeX Gyre Schola, 28 half points, body 500, single 420 twips; until fb-595.68 `make-reference.sh` built a committed `reference.docx` with `lib/docx/xengine-reference.sh`); `cadc.lua` (rewritten on `require("docx.xengine")`) writes every paragraph with exact spacing, the table rows with the page column as right indent and a leader tab, and a word joiner between ")(" so LibreOffice does not break "6103(i)(2)".
- Every engine certifies the same word count: the latex and docx filters count the markdown source as the typst template does (1,312).

What the first TeX Gyre Schola adoption found (each a line or a tier-1 check the gate caught):
- **The vendored Schola is not TeX Live's.** `fonts/tex-gyre-schola` (2.609) has wider ( ) [ ] { } * + / < = > \ | and ellipsis than the Type 1 `tgschola` of TeX Live (the New Century Schoolbook AFM widths: parentheses 483 against 333 thousandths of an em), and a bold interword space of 0.278 em against 0.287 em. `cadc.lua` writes each of those glyphs as `\dcg{<regular>}{<bold>}{<glyph>}`, scaled across to the OpenType advance (a box with a gap of its own split "6103(i)(2)" into two words in the PDF's text), and the template sets the bold space. Without it latex broke 8 lines differently.
- **LibreOffice sets the ligatures of an OpenType face** (fi, fl, ff, ffi, ffl), which typst, LaTeX and Word by default do not; it reads no `w14:ligatures`, and a character style that alternates at the join does not stop it (it shapes across runs). A word joiner between the letters does, and is not in the PDF's text.
- **LibreOffice places a line of exact spacing by the font's descent** (0.711 em in this face, 1.635 em high) when the face is taller than the box, where typst puts the baseline at 0.8 of the box: at 16.4 pt a line that opened a page reached 5 pt into the top margin (`DEF-FORM-002`). The single pitch is therefore 21 pt and the heading pitches 29 / 25 pt, so every line stays inside the margins wherever it falls; a line that opens a page by a hard break is moved down into typst's place (`DROP` in `cadc.lua`), taken from the space below it. Elsewhere LibreOffice's baselines sit 6 to 7 pt above typst's (reported by `fb diff --engines`, not gated: the breaks are).

Before (baseline, `data/cross-engine-baseline.json`): latex 15 = 15 pages, 59.6 % of lines with typst's break, first difference p1 line 10; docx 14 pages against 15, 17.2 %, and tier 1 failing `DEF-FORM-002`. After: typst 15 pages; latex and docx 15 pages, 302/302 lines, every page starting and ending on typst's words (XENG-001..003 PASS); tier 1: typst 7 passed, latex 10 passed, docx 11 passed, 0 failed.

Review (Gate 2) of the new renders, 2026-10-22: every page of the typst PDF viewed at 40 and 60 dpi, and the docx and latex PDFs page by page beside it (cover, certificate, contents, authorities, signature and certificate pages at 60 dpi side by side).

| Page | Content | Finding |
|---|---|---|
| 1 | Cover | One page; parts closer than before (the old fit chose 0.45 of its gaps), date under the counsel. OK. |
| 2-3 (i-ii) | Certificate as to parties | Heading three lines; parts A-C and Rule 26.1 with the body's indent. OK. |
| 4 (iii) | Contents | Rows 25 pt apart, level 2 half an inch in, wrapped title hangs. OK. The docx leader runs to the number (Word's right tab), typst's stops at the page column: accepted, the model's design. |
| 5 (iv) | Authorities | Two groups, every page listed. OK. |
| 6 (v) | Glossary | 1 in abbreviation column. OK. |
| 7-13 (1-7) | Body | Double spaced, headings kept with their text; conclusion kept with the signature on p. 13. OK. |
| 14-15 (8-9) | Certificates | Word count 1,312, the typeface sentence; signer 45 % in. OK. |

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
