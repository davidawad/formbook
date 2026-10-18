# Tenth Circuit (ca10): answering brief

- Court: U.S. Court of Appeals for the Tenth Circuit (`ca10`)
- Doc type: `answering-brief` (appellee's brief, no cross-appeal)
- Status: template and one transcribed sample. Not a finished court. Not in the tracker.
- Layout: self-contained folder. `usage/`, `usage/`, `typst/` and this README all live here.

## Result

- exemplar=yes: `usage/FILED-EXAMPLE-answering-brief.pdf` (filed appellee brief, 63 pages, text layer present; see `usage/SOURCE.md`)
- render=ok: `usage/OUTPUT-answering-brief.typst.pdf` (13 pages since 2026-10-16, no typst warnings, vendored fonts only)
- overlay=ok: `usage/OVERLAY-willey-answering-brief.pdf` and `-overlay.txt`
- pages reviewed: 13 of 13 in the 2026-10-16 pass (`pdftoppm -r 60`, every page viewed)

## Governing rules

Verified 2026-10-14. Each rule's text was fetched from the source listed; where only a secondary summary was available, that is said.

| ID | Rule | What it requires | Source (fetched 2026-10-14) |
|---|---|---|---|
| CA10-FORM-001 | FRAP 32(a)(1) | Single-sided text | https://www.law.cornell.edu/rules/frap/rule_32 (text) |
| CA10-FORM-002 | FRAP 32(a)(4) | Margins at least one inch on all four sides | same (text) |
| CA10-FORM-003 | FRAP 32(a)(4) | Double-spaced, except quotations more than two lines (may be single-spaced), headings and footnotes | same (text) |
| CA10-FORM-004 | FRAP 32(a)(5) | Proportionally spaced face with serifs (sans-serif allowed in headings and captions), 14-point or larger | same (text) |
| CA10-FORM-005 | FRAP 32(a)(6) | Plain roman style; italics or boldface for emphasis; case names italicized or underlined | same (text) |
| CA10-FORM-006 | 10th Cir. R. 32(A) | 13- or 14-point type, 14 preferred. A search summary of a 2022 Clerk memo says the size rule also covers footnotes (not read directly; footnotes are set at 14 pt here) | https://ca10.uscourts.gov/sites/ca10/files/documents/downloads/brief%20and%20appendix%20checklist%202026_0.pdf (checklist, "Updated to Comply with 2025 Rules", 1/2/2026). **Rule text itself not fetched.** |
| CA10-COVER-001 | FRAP 32(a)(2) | Cover: case number centered at top; court; title of case; nature of proceeding and court below; title of brief identifying the party; counsel's name, office address, telephone. Cover colour: appellee red | Cornell FRAP 32 (text). Checklist item 1 also gives red for the appellee's brief. |
| CA10-COVER-002 | 10th Cir. R. 28.2(C)(1)-(2) | Cover also shows the district of origin, the judge or agency below, the district court case number, and a statement whether oral argument is requested | checklist, items 4-5 (cites 28.2(C)(2)). **Rule text not fetched.** |
| CA10-TOC-001 | FRAP 28(a)(2), 10th Cir. R. 28.2(C)(5) | Table of contents with page references; all attachments listed | checklist, items on TOC |
| CA10-TOA-001 | FRAP 28(a)(3) | Table of authorities (cases, statutes, other) | checklist |
| CA10-PRIOR-001 | 10th Cir. R. 28.2(C)(3) | Statement of prior or related appeals, after the TOA; a negative statement if none | checklist |
| CA10-ORAL-001 | 10th Cir. R. 28.2(C)(2); FRAP 34 | Statement of why argument is necessary, if requested; the exemplar gives a statement of counsel that oral argument is not requested | checklist; exemplar |
| CA10-LEN-001 | FRAP 32(a)(7)(A)-(B) | Principal brief: no more than 30 pages, or 13,000 words (or 1,300 lines if monospaced). **The appellee's brief in a case without a cross-appeal is a principal brief; the template does not enforce this** (see Known gaps) | Cornell FRAP 32 (text) |
| CA10-LEN-002 | FRAP 28.1(e)(1)-(2)(B) | Cross-appeal limits only (35 pages, 15,300 words for the appellee's principal and response brief). Not applicable here | Cornell FRAP 28.1 (text, cross-appeal only) |
| CA10-CERT-001 | FRAP 32(g)(1)-(2), Form 6 | Certificate of compliance with the type-volume limit; word count; the typeface statement | Cornell FRAP 32, (g)(1) (text) |
| CA10-CERT-002 | FRAP 32(f); 10th Cir. R. 32(B) | Excluded from the word count: cover, disclosure, TOC, TOA, oral-argument statement, certificates, signature block, proof of service | Cornell FRAP 32(f) (text); 10th Cir. R. 32(B) per the checklist. **Rule text not fetched.** |
| CA10-CERT-003 | 10th Cir. R. 25.5 | Digital submission: privacy redactions; ECF copy is exact; virus scan | the exemplar's certificate wording. **Rule text not fetched.** |
| CA10-SIG-001 | 10th Cir. R. 46.5(A), (C) | Signature with `s/` and the signer's name | checklist, item on signing |
| CA10-SVC-001 | FRAP 25(d); 10th Cir. R. 25.4 | Certificate of service when service is not through ECF | checklist |
| CA10-PAPER-001 | FRAP 32(a)(3); 10th Cir. R. 31.5 | Paper copies (if ordered): exact copy of the ECF brief, bound to lie flat | checklist (not in the template) |

Not generated, on purpose: a corporate disclosure statement (FRAP 26.1), a glossary (10th Cir. R. 28.2(C)(4); the template does not draw one), an addendum, the ECF running header ("Appellate Case: ... Document: ... Page: ..."), which the court stamps on filing. The cover colour is not drawn (see Known gaps).

## Template

- `typst/ca10-answering-brief.typ` is the template: `ca10-brief(meta, md)`. Every number is a named parameter at the top, each traced to a rule. No case-specific text, no coordinates measured off the exemplar, no forced line breaks. Compile only via `tools/render.sh`.
- `typst/main.typ` reads the sample named by `--input sample=...`, splits the frontmatter, and calls the template.
- Calibration: the body baseline pitch is 28.14 pt for 14 pt type (`body-leading = 1.36em`). The exemplar's double-spaced body measures 28.08 pt (page 11 of the exemplar, lines at y=103.79 and 131.87). This is measured, not from a rule.
- Structure, as the rules give it: cover (one page, `i`, unnumbered; FRAP 32(a)(2)), TOC (`ii`), TOA and prior-appeals statement (`iii`), body (`1`-`n`, arabic from 1), signature block after the conclusion, statement of counsel as to oral argument, certificate of compliance, certificate of digital submission, certificate of service.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block, then the body. The template generates the cover, the TOC and TOA, the signature block, the oral-argument page and the certificates.

| Field | Required | Feeds |
|---|---|---|
| `case_number` | yes | Cover: "No. ..." at top; PDF title. |
| `caption` | yes | Cover: list of sides. Each side: `names` (list, one centered line each, inline markdown allowed), `designation`. "v." is inserted between sides. |
| `proceeding` | yes | Cover: "On Appeal from ...". |
| `judge`, `district_court_case` | no | Cover lines under the proceeding. |
| `brief_title` | yes | Cover title (printed in capitals). |
| `oral_argument` | yes | Cover line: "ORAL ARGUMENT IS NOT REQUESTED" (or the requested statement). |
| `counsel` | yes | Cover counsel block: `names` and `lines` per group. |
| `phone` | yes | Cover, last line. |
| `oral_argument_statement` | yes | The statement of counsel as to oral argument (inline markdown). |
| `signature` | yes | `signer` (printed `s/ Name`), `lines` (printed under it). Used after the conclusion and on each certificate. |
| `date` | yes | Date on the compliance certificate; date of service. |
| `prior_related` | yes | Statement of prior or related appeals. |
| `virus_scanner` | yes | The program named in the digital-submission certificate. |
| `service` | no | `certificate: true` adds the certificate of service. `unregistered` is a list of groups; each group is a list of lines. |
| `authorities` | yes if the body cites any | Registry of the TOA. Each entry: `kind` (`case`, `statute`, `rule`, `other`), `name` (printed; italic for cases, typst `emph`), `cite` (optional), and `search` (a **regex**, matched against the text of the body and back matter; escape `.`, `(`, `)` where they must be literal). |

Body markdown: `#` is a section heading (centered, bold); `##` is a point heading (bold, hanging). Headings keep the numerals as typed. Footnotes use `[^1]`. Numerals in the sample body are the exemplar's own.

## Build and check

From the repo root:

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq
sh tools/render.sh courts/tenth-circuit/court-of-appeals/answering-brief usage/INPUT-answering-brief.md
sh tools/overlay.sh courts/tenth-circuit/court-of-appeals/answering-brief willey-answering-brief
pdftoppm -r 60 -png courts/tenth-circuit/court-of-appeals/answering-brief/usage/OUTPUT-answering-brief.typst.pdf <out-dir>/p
```

`tools/check.sh` and `tools/check-selftest.sh` have no `checks.yaml` for this layout, so they were not run.

## Sample

- `usage/INPUT-answering-brief.md`: a transcription of part of the exemplar for visual comparison, not the whole brief. It carries the cover, the TOC/TOA data, the jurisdictional statement, the issues, the statement of the case (I. Factual Background, II. Procedural Background), the conclusion, the statement of counsel as to oral argument, and the certificates. The Argument (Parts I-III) and the Summary of Argument are omitted.
- The certificate of compliance states 1,802 words (1,775 before the conclusion's first sentences were restored on 2026-10-16). That is the sample body's own approximate count, not the 12,524 words of the filed brief.

## Overlay

`usage/OVERLAY-willey-answering-brief.pdf`: red is our render, blue is the exemplar, black is both. Pages are paired by word overlap; the pairing is a diagnostic. Our sample is a portion, so the map pairs each sample page with a different exemplar page (for example, the TOA page with exemplar page 60, the statement of counsel). The overlay shows layout, not a score.

## Known gaps

1. **Cover colour.** FRAP 32(a)(2) requires a red cover for the appellee's paper copies. The PDF is white, as the exemplar's ECF copy is. The template does not draw a coloured cover; a paper copy must be printed on a red cover.
2. **Length is not enforced.** The template does not check the 13,000-word or 30-page limit for the appellee's principal brief. The count it prints (`count-words`) is approximate (whitespace-delimited, markup stripped). A gate for the full brief is needed before filing.
3. **Rule texts not fetched:** 10th Cir. R. 32(A), 32(B), 25.5, 28.2(C), 46.5 and 25.4 were taken from the 2026 checklist and the exemplar, not the rule text. The checklist was fetched as a PDF; the 10th Cir. rules page returned 404. Verify against the court's rules before the template is treated as final.
4. **Table of authorities.** Page references come from `search` regexes over the rendered text. A citation split across lines or across a changed run of text is found only if its regex still matches one text element. The stray space after every matched authority ("Reich , 141", "25.5 ;") was fixed on 2026-10-16.
5. **Not in the template:** corporate disclosure statement (FRAP 26.1), glossary, addendum, the ECF running header, paper-copy counts.
6. **Sample is partial.** The Argument is omitted, so the TOA lists only the authorities in the transcribed portion, and the TOC lists no Argument headings.
7. **Lengths.** The sample is 13 pages (cover 1, TOC 1, TOA and prior statement 1, body 7, certificates 3), within the 8-14 target. The filed exemplar is 63 pages.

## Pages reviewed

(2026-10-14 pass, 14-page layout; superseded by the 2026-10-16 section below.) All 14 pages were rendered at 60 dpi and viewed: cover (1-2), TOC (3), TOA and prior statement (4), body (5-11), certificates (12-14). Defects found and fixed during review: TOA page numbers blank (fixed: show-rule tagging moved into the brief scope), TOC showing physical rather than roman page numbers for front matter (fixed), cover telephone line not centered (fixed), signature in capitals with the name line missing (fixed), compliance certificate wording "font size" (fixed).

## Log

- 2026-10-14: first draft. Exemplar fetched from RECAP (CourtListener doc 32, docket 25-8027). Template, sample, render, overlay, README.

## Typeface (fonts pass, 2026-10-15)

- **Face required by the rules: none named.** FRAP 32(a)(5) requires a proportionally spaced face with serifs, 14-point or larger (or a monospaced face); FRAP 32(a)(6) requires plain roman. The court's own 2026 briefing checklist (item "Is the brief in either 13- or 14-point font (14-point font is preferred)? See 10th Cir. R. 32(A)") and its Quick Reference Guide ("Form and Font Size (14-Point Preferred)") name no face. Source texts were read 2026-10-15: Cornell FRAP 32, `ca10.uscourts.gov` checklist 2026 and QRG (PDF text via pdftotext). The text of 10th Cir. R. 32(A) itself was not retrieved (the court's local-rules page returned 404).
- **Unverified claim, not used.** A secondary Typelaw blog post says the Tenth Circuit requires Century Schoolbook. No court-published text found says so, so the template does not follow it. The filed exemplars use different faces (Oliver reply: Century Schoolbook; Lyman opening: Times New Roman), which is consistent with the rules naming none.
- **Substitute: none; EB Garamond kept** (vendored, `fonts/eb-garamond/`), per the fonts policy: a court whose rules name no face keeps EB Garamond. Set in the template as `font-family`.
- **Compatibility:** not applicable (no named face to match). Pagination is therefore not checked against a Times or Century filing; the length gate uses the word count, not the page count.
- **Renders (2026-10-15):** `tools/render.sh` with vendored fonts only, zero warnings; `pdffonts` shows only EB Garamond (Regular, Bold, Italic). Page counts unchanged. Every page rasterised at 60 dpi and viewed. Overlay regenerated against the filed exemplar (downloaded from the CourtListener URL in `usage/SOURCE.md`; the PDF is not committed to the repo).

## Engines

Typst is the primary engine. The DOCX engine (`docx/build-reference.sh`, `docx/ca10.lua`, `docx/reference.docx`) renders the same sample through pandoc and LibreOffice; the PDF is `usage/OUTPUT-answering-brief.docx.pdf`.

**Matches the typst output** (as of 2026-10-15; the typst cover became one page on 2026-10-16, see below): 14-point EB Garamond throughout; letter paper with 1 in margins; the two-page cover (page i unnumbered, page ii numbered `ii`, centered caption, counsel and phone, oral-argument line as written in the frontmatter); the contents on `iii` and the table of authorities with the prior-appeals statement on `iv`; body numbered from 1; double-spaced body (exact 556 twips, 27.8 pt, against typst's measured 28 pt) with a 0.5 in first-line indent; centered bold body H1 in its own case, bold left H2 with a 0.5 in hanging indent; single-spaced footnotes at 14 pt; the signature block and the "By:" service signature at 3.25 in; the statement of counsel as to oral argument; the compliance, digital-submission and service certificates, each on its own page, in typst's order; the word count (1,775, computed as typst's `count-words` does).

**Differs (tier 2, not chased):** the cover caption and counsel lines are set more loosely than the typst cover; the body H1 and H2 use the same sizes (19.5 pt and 17 pt, typst 19.6 pt and 16.8 pt) but their space above and below is tighter, because LibreOffice keeps the space above a heading at the top of a page; the compliance certificate names the filing program as "a proportionally spaced word processor" (instructed wording, see below); the contents and the table of authorities show no page numbers; the authorities keep dot leaders running to the margin, and the contents have none.

**Page count: docx 15, typst 14 (not matched).** The body overflows by about five lines onto a continuation page: the statement of counsel as to oral argument runs past the signature block, and every later page moves on by one. The body holds the same 23 lines per page as the typst body, so the cause is line breaking (LibreOffice breaks lines greedily; typst breaks paragraphs to minimize raggedness), not line height. Spacing changes were tried (heading space, pitch, footnote and signature gaps) and recovered only part of it; closing the rest would mean departing from the typst line pitch or the rule-driven spacing. Left as BLOCKED.

**BLOCKED items (docx):**
- Contents page numbers (`toc-section`, rows for every heading and certificate): the docx entries have no page numbers. A page-number field needs an update in Word or LibreOffice, and this headless pipeline does not update fields (docs/DOCX.md, "Table of contents"). A first-pass render could supply them; not done here.
- Table of authorities page numbers (`toa-section`, `pages-cited`): same cause, and the TOA field route is not honored by LibreOffice (docs/DOCX.md, "Table of authorities"). The docx lists every authority of the four kinds, as typst does, with dot leaders and no page numbers.
- Page count (tier 1, checked on `usage/OUTPUT-answering-brief.docx.pdf`): 15 pages against the typst 14; cause and the attempts are described above.
- Certificate of compliance, item 2 (program name): the typst template prints "using Typst". The docx prints "using a proportionally spaced word processor", as the rule requires the filer to name the program. The filer must replace it with the program name before filing; the template cannot know it.

**Other notes:** the cover is two sections, page i with no footer and page ii with a roman footer starting at 2, so the footer reads `ii`, `iii`, `iv`, then arabic from 1 in the body. The word limit is 13,000 for a principal brief (FRAP 32(a)(7)(B)(i)); the sample's 1,775 words are within it.

## Verification pass 2026-10-16 (fb-595.26.10)

- Rendered: `tools/render.sh` exit 0, no typst warnings; 14 pages before the fixes, **13 after**. Overlay rerun (`tools/overlay.sh`): cover pairs with filed p. 1 at 61.5%, body pages 49-82%, certificates 60-86%.
- Viewed: all 14 pages of the first re-render, then all 13 pages after the template fixes (pages 9-13 again after the sample fix), at 60 dpi; the 13 overlay pages at 40 dpi; exemplar pages 1-3 against our cover.
- Defects fixed:
  1. **Two-page cover** (tier 1). The brief title, the oral-argument line and counsel sat on page ii, not on the front cover; FRAP 32(a)(2)(D)-(E) put them on the front cover. The exemplar's filer splits the cover over two pages (tier 3, not followed). The cover is now one page, the groups spread with flexible space and the title set between two short rules. Front matter moves up one roman number (TOC `ii`, TOA `iii`).
  2. **Single-spaced lines touching.** `single-leading` was 0.2em, so cover, TOC/TOA, signature and certificate lines crowded (descenders on ascenders). Now 0.65em (typst's normal single spacing).
  3. **Stray space after every TOA-tagged authority** ("Reich , 141", "25.5 ;", "§ 1983 ."): the citation tag was `[#metadata(keys) <ca10-cite>]`, whose space printed. Removed.
  4. **First paragraph after a heading not indented** (the oral-argument statement, the first paragraph of each section). The exemplar indents them (filed pp. 10, 60). The paragraph indent now applies to all paragraphs.
  5. TOC and TOA had no page-column heading and the dot leaders ran into the entry ("Background:."). Added "Page" / "Page(s)" and a small gap before the leader.
  6. Sample: the conclusion began mid-sentence ("Willeys failed ..."): the first sentences on filed p. 57 were dropped at the page break. Restored. Case names in the oral-argument statement set in italics, as filed.
- DOCX outputs not touched (no LibreOffice on this box). The docx engine still makes the two-page cover; `OUTPUT-answering-brief.docx.pdf` (15 pages) is now out of step with the typst render.
- Remaining gaps: Known gaps 1-3, 5, 6 above (cover colour, length not enforced, local rule texts not fetched, no glossary or disclosure, partial sample); no `checks.yaml`.
