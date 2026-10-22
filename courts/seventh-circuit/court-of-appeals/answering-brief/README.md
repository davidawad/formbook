# Court of Appeals for the Seventh Circuit: answering brief (appellee's brief)

Doc type `answering-brief` of court `ca7` (`courts/seventh-circuit/court-of-appeals/`). This folder is self-contained: its own exemplar, sample, template and rules. The court-root `typst/` and `usage/` are not touched.

Status: exemplar = yes; typeface = none named by the rules, EB Garamond kept (fonts pass, 2026-10-15; see the court `README.md` "Typeface"); render = ok (re-run 2026-10-16); overlay = ok (re-run 2026-10-16, the exemplar is in `usage/`); pages reviewed = 14 of 14 in the verification pass of 2026-10-16 (see "Verification pass"). The Seventh Circuit rules were read in the fonts pass (see "Verification status" below).

## Folder

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-answering-brief.pdf` | Filed Brief of Appellees, *Craig v. City of Richmond*, No. 26-1864 (7th Cir.), May 21, 2026. Provenance in `usage/SOURCE.md`. |
| `usage/INPUT-answering-brief.md` | Transcription of that brief (partial, see "Known gaps"). Frontmatter = cover, caption, counsel, signature, service list, authorities. |
| `usage/OUTPUT-answering-brief.typst.pdf` | Render, 14 pages. |
| `usage/OVERLAY-craig-answering-brief.pdf`, `.txt` | Red/blue overlay against the exemplar, and the page map. |
| `typst/ca7-answering-brief.typ` | The template: `ca7-brief(meta, md)`. Content-agnostic. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`. |

## Build

```sh
export PATH="$HOME/tb/bin:$PATH"   # micromamba env: typst 0.15.0, poppler, imagemagick, gawk, jq
sh tools/render.sh courts/seventh-circuit/court-of-appeals/answering-brief usage/INPUT-answering-brief.md
sh tools/overlay.sh courts/seventh-circuit/court-of-appeals/answering-brief craig-answering-brief
```

Fonts are vendored (`fonts/eb-garamond/`); the build runs with `--ignore-system-fonts` and fails on any typst warning. The render embeds only `EBGaramond-Regular/Bold/Italic`.

## Rules the template follows

Requirement IDs are used in comments in `typst/ca7-answering-brief.typ`. "Verified" below means the text was read this session.

| ID | Requirement | Source | Verification |
|---|---|---|---|
| CA7-FORM-002 | 1-inch margins | Convention; the exemplar uses 1 inch | Exemplar layout only |
| CA7-FORM-003 | Double-spaced text; block quotations, footnotes and headings single-spaced | Fed. R. App. P. 32(a)(4) | Not fetched this session; the exemplar follows it |
| CA7-FORM-004 | 12-point text | Circuit Rule 32(b) | **Verified 2026-10-15** against the current rules PDF (p. 89): 12 pt or larger in the body. The Craig certificate cites Cir. R. 32(b) and certifies 12-point Times New Roman. The Carter brief (Nov 2025) is 14 pt. |
| CA7-FORM-005 | 11-point footnotes | Circuit Rule 32(b) | **Verified 2026-10-15** (same text: 11 pt or larger in footnotes) |
| CA7-FORM-006 | Proportional serif face; no condensed type; roman main text | Fed. R. App. P. 32(a)(5)–(6); handbook | **Verified 2026-10-15**: FRAP 32(a)(5)(A) (serif, proportional, sans only in headings and captions) and 32(a)(6) (p. 86) in the rules PDF. Names no typeface. |
| CA7-LEN-001 | Principal brief, 14,000 words, footnotes included, Fed. R. App. P. 32(f) exclusions | Fed. R. App. P. 32(a)(7)(B); Circuit Rule 32(c) | **Verified 2026-10-15** against the rules PDF: Cir. R. 32(c) allows a principal brief of no more than 14,000 words, and a reply of 7,000 (p. 89); FRAP 32(a)(7)(B)(i) (p. 87) says 13,000, which Cir. R. 32(c) replaces. |
| CA7-CONT-001 | Table of contents and table of authorities | Fed. R. App. P. 28(b) (appellee's brief) | Not fetched this session |
| CA7-CONT-002 | Appellee's jurisdictional statement, stating whether appellant's jurisdictional summary is complete and correct | Circuit Rule 28(b) | **Verified in substance.** Seventh Circuit order in *Megna v. Musial*, No. 25-2190, Dkt. 27 (Dec. 1, 2025), quotes the rule and requires it of an appellee. |
| CA7-COVER-001–005 | Cover: case number, court, caption, district court line, title, counsel with office address and telephone, date | Fed. R. App. P. 32(a)(2); the exemplar settles the layout | Exemplar layout only |
| CA7-CERT-001 | Certificate of compliance (word count, typeface, type-style) | Fed. R. App. P. 32(g)(1); Circuit Rule 32(b), 32(c) | Wording taken from the exemplar's certificate, not from a fetched form |
| CA7-CERT-003 | Certificate of service | Fed. R. App. P. 25(d) | Not fetched this session; the exemplar follows it |

Appellee-specific sections (per Fed. R. App. P. 28(b)): the template does not require a statement of issues or a standard of review. The exemplar has neither, and the Craig brief uses a jurisdictional statement, statement of the case, summary, argument and conclusion. Those are the headings the sample uses.

## Choices the rules leave open

- **Typeface: EB Garamond, kept.** Circuit Rule 32(b) and FRAP 32(a)(5)(A) name no face (read 2026-10-15 from the rules PDF; "Verification status" below). The handbook (guidance, not a rule) recommends Century and calls Times and Garamond less legible. TeX Gyre Schola (Century) is vendored now, so a switch is possible; it is not made here, pending David's decision (court `README.md`, "Typeface"). Garamond at 12 pt sets smaller than Times at 12 pt.
- **Front matter in lowercase roman, body in arabic from 1.** The exemplar numbers every page in arabic. Roman front matter is a common convention and was kept.
- **Cover in one piece:** no double rules, no colored cover, and the court line set as ordinary text that wraps on its own. The template has no forced break in literal text. Its `linebreak()` calls only separate lines that come from the frontmatter (address, counsel and signature lines).
- **Certificates:** the compliance certificate and the service certificate use the exemplar's wording. The service certificate lists the counsel served, from frontmatter `service.counsel`, and prints the signature block as one unbreakable unit.

## Verification status

The rules for this doc type were checked as follows:

- Reachable 2026-10-15: `https://www.ca7.uscourts.gov/assets/pdf/rules.pdf` (157 pages, "current as of December 1, 2025"), read with `pdftotext`. This is the source for FRAP 32 and Circuit Rule 32 above. `https://www.ca7.uscourts.gov/rules/rules.pdf` (404) and `courtrules.net` (403) were not used.
- Also reachable: the 2018 typography handbook (guidance, not a rule), the CourtListener API, and RECAP PDFs.
- Not verified here: FRAP 28(b) (CA7-CONT-001, the appellee's contents rule). The fonts pass did not reread it.

**Verified 2026-10-15:** the current Circuit Rule 32(b) (rules PDF, p. 89) says "A brief is acceptable if proportionally spaced type is 12 points or larger in the body of the brief, and 11 points or larger in footnotes." The 12-point body and 11-point footnote choice therefore stands. The same PDF's FRAP 32(a)(5) (p. 86) names no typeface. The rules PDF was fetched from `https://www.ca7.uscourts.gov/assets/pdf/rules.pdf`; this supersedes the 2018 handbook as the source for size.

## Known gaps

1. **Circuit Rule 26.1 disclosure statement is not produced.** A search summary says an appellee's brief includes one in front of the table of contents. Neither exemplar has one, and the rule text was not reachable, so it was not added. Needs a decision: confirm the rule, then add an optional `disclosure` section.
2. **The sample is partial.** About 14 pages of the 34-page filed brief. Omitted: the rest of the Abraham discussion and Argument II, and all of Argument III (its heading is kept, and the sample says so). Footnotes 1–4 are kept.
3. **The certificate word count is the transcription's**, 2,579 words (computed by the template from the markdown). The filed brief certifies 7,497 words. The sample is not a compliant brief.
4. **The table of authorities lists only the authorities cited in the transcribed text.** Every `toa:` key in the body has an entry in the frontmatter; a registry entry with no link does not print.
5. **Exemplar typos are kept as printed**: "26-1854" in footnote 4, "655 F.3d at 774", "Holiday v. Alt. Richfield Co.", "Robertson ... (E.D. La. July 11, 2026)", "Rightsell ... 2026 U.S. Dist. LEXIS 51716 at \*6". They belong to the filing, not to the template. The template does not change citation text.
6. **Short appendix not produced.** Seventh Circuit short appendices are separate filings (Carter's title page shows one combined). No addendum section exists in this template.
7. **One exemplar only.** The tier-2 standard calls for two or three exemplars from different filers. Carter's brief is recorded in `usage/SOURCE.md` for comparison, but not used in the overlay.
8. **Overlay pairing is diagnostic.** Pages are paired by word overlap, not by position. The cover and TOC pair at 100%, and the TOA at 41%. Body pages (PDF 4–10) pair with filed body pages at 45–69%. PDF page 11 (conclusion and signature) pairs at 34%, since the filed brief's signature sits on a different page. PDF pages 12–14 (certificates) pair with filed pages 32–34 at 80%, 85% and 90% (2026-10-16 run). The overlay shows where the sample and the exemplar differ; it is not a score.

## Pages reviewed (Gate 2)

All 14 pages of `usage/OUTPUT-answering-brief.typst.pdf` were rasterized at 60 dpi (`pdftoppm -r 60`) and looked at:

PDF page (printed folio) and what it shows:

| PDF page | Printed folio | Content | Finding |
|---|---|---|---|
| 1 | none | Cover | Fits on one page. Caption, counsel, role and date in order. |
| 2 | i | Table of contents | Entries and page numbers match the body. |
| 3 | ii | Table of authorities | Fits on one page. No `passim` (no authority reaches 7 pages). |
| 4 | 1 | Jurisdictional statement | Headings; footnote 1 at the foot of the page. |
| 5 | 2 | Jurisdictional statement (end), Statement of the case | Plain paragraphs, citations italic. |
| 6 | 3 | Statement of the case | Footnotes 2–4 in order. |
| 7 | 4 | Summary of the argument; Argument I begins | Point heading centered, small caps. |
| 8 | 5 | Argument I (end), Argument II begins | Point II heading wraps to two lines, centered. |
| 9 | 6 | Argument II | Citation-dense paragraphs; pin cites with `*` escaped, rendered. |
| 10 | 7 | Argument II (end) | Single-spaced block quotation, indented. Transcription note. |
| 11 | 8 | Argument III heading, conclusion, signature block | Heading kept with the conclusion; signature block unbroken. |
| 12 | 9 | Certificate of compliance | Word count, typeface line, signature block. |
| 13 | 10 | Certificate of service (counsel list, first four groups) | Fine. |
| 14 | 11 | Certificate of service (last two groups, signature block) | Since 2026-10-16 the last group served is kept with the signature block, so the signature no longer stands alone. |

Every page was rasterized (`pdftoppm -r 60`) and viewed, first after the template's last substantive change and again after the final edits.

Fonts pass, 2026-10-15: the sample was re-rendered (14 pages, `pdffonts`: EB Garamond only, embedded), and all 14 pages were rasterized at `pdftoppm -r 70` and viewed again. No layout change, since the face did not change. Nothing new was found on the pages. The overlay could not be regenerated: `usage/` holds only `SOURCE.md`.

## Verification pass 2026-10-16 (fb-595.26.7)

- Rendered: `sh tools/render.sh ... usage/INPUT-answering-brief.md`, exit 0, no typst warnings, 14 pages (the committed OUTPUT was also 14 pages). Re-rendered after each fix.
- Viewed: all 14 pages at `pdftoppm -r 60`, one PNG at a time; pages 1 and 11–14 again after the fixes (pages 2–10 are text-identical to the first render, checked page by page with `pdftotext -layout`). Exemplar page 1 compared with our cover; exemplar pages 31–34 (signature, certificates) viewed. All 14 overlay pages viewed at `-r 40`.
- Overlay: regenerated (the exemplar is now in `usage/`). Cover and TOC 100%, TOA 41%, body 45–69%, conclusion page 34%, certificates 80–90%. Margins and text block coincide; differences are face and size (EB Garamond vs Times New Roman, both 12 pt) and omitted text.
- Fixed:
  - Template: counsel, signature and service address lines were forced italic; the exemplar sets them roman with only the "Counsel for / Attorneys for" lines italic. Lines are now set as given, and markdown `*...*` in a line is honoured.
  - Template: the certificate of service's signature block stood alone on PDF page 14. The last counsel group served is now kept with the signature block.
  - Sample: the service list was mis-transcribed (Bever and Fecht merged under BBFCS; Gritton and Freel missing). It now has the six groups as filed (exemplar pp. 33–34); the role lines are marked italic in the markdown, as printed.
- Remaining gaps: as in "Known gaps" (Rule 26.1 statement, partial transcription, one exemplar in the overlay). The service certificate's wording and the signature position (left, not right as filed) are the template's, not the filer's (tier 3). The latex engine was re-rendered from the corrected sample (exit 0, 14 pages) but its pages were not viewed in this pass. The docx outputs were not rebuilt (no LibreOffice on this box), so `OUTPUT-answering-brief.docx` and `.docx.pdf` predate the service-list correction.

## Changes made during review

- The first render was 21 pages, with a 15-page body. The brief's target is 8–14 pages, so the transcription was cut to the structural passages above (14 pages).
- The TOA entry spacing was tightened (entries 0.7em to 0.35em, group headings 1.4em to 1em) so the TOA fits on one page.
- The service-certificate signature block was made unbreakable, to stop it splitting from the firm lines.
- *Lafalier* was cited only inside the *Allen* link text, so the TOA would have omitted it. It is now its own `toa:lafalier` link.

[Formbook index](../../../../README.md)

## Engines

- **typst** (`typst/`): primary. Roman address lines and the service-signature keep changed 2026-10-16 (see "Verification pass").
- **latex** (`latex/template.tex`, `latex/ca7-answering-brief.lua`): EB Garamond 12 pt from the vendored `fonts/`, 11 pt footnotes, 26.9 pt double spacing, one-inch margins, no hyphenation. The Argument's point headings are centered small capitals; other headings use A. / 1. / a. / (1). Cover, TOC, TOA, signers block (`/s/` and bar numbers) and both certificates follow the typst frontmatter fields. Output `usage/OUTPUT-answering-brief.latex.pdf`, 14 pages (typst: 14). Differences: the cover is not fitted to the page, so its final date line and rule may sit differently; the TOC shows the short certificate title, not the full typst heading. Gates not run: the court has no `checks.yaml` or `rules.md` yet.
- **docx** (`docx/`): `build-reference.sh` (reference styles, EB Garamond 12 pt, exact 26.9 pt double spacing, 11 pt footnotes), `ca7-answering-brief.lua` (cover, TOC, TOA, signature and certificates as styled paragraphs), `render.sh` (sections with roman front matter and arabic body, PAGE footers, and a two-pass TOC/TOA page map read from the LibreOffice PDF), `pagemap.awk`. Output `usage/OUTPUT-answering-brief.docx` and `.docx.pdf`, 14 pages (typst: 14); the certificate word count is 2,579, the same as typst. Matches typst: the face, sizes, spacing, one-inch margins, cover lines and counsel, roman and arabic folios, the centered Argument point headings, the TOC and TOA entries with page numbers, both certificates. Differences: the cover is spaced by hand (typst fits it to the page); the TOA page list comes from a text search of the PDF, so a short-form cite (`Allen`) also counts unlinked mentions (Allen: 1, 4, 5, 6, 7; typst 1, 4, 5, 6); the TOC and TOA are static text, not fields, and Word may paginate a page number differently; the compliance certificate omits the typst "using Typst" clause (no word processor is named in the frontmatter). Opened in LibreOffice without error; not opened in Word. BLOCKED: `tools/check.sh --engine docx` cannot run: no `checks.yaml` and no `court.json` in this folder or the court (exit 2), so no Gate 1 check ID can be reported; Gate 2 has no `reviews/` file.


## Cross-engine layout (fb-595.54.4, 2026-10-22)

The three engines are on the shared layout model (`lib/typst/xengine.typ`, `lib/latex/xengine.sty`/`.lua`,
`lib/docx/xengine-reference.sh`/`.lua`; docs/EVAL-LOOP.md, "Cross-engine gate") and `eval.yaml` sets
`params.cross_engine: gate`: latex and docx break every line and page where typst does (XENG-001..003 PASS, 377 of
377 lines, 16 pages each). This supersedes the engine and typeface notes above: all three engines set Times New
Roman metrics (typst's Times New Roman/Liberation Serif, newtx, Times New Roman in Word), 12 pt in 27 pt line boxes,
single-spaced parts in 17 pt boxes, footnotes 11 pt in 15.5 pt boxes. Changes to the typst reference: point headings
are bold, not small capitals (Word and LaTeX synthesize small capitals differently); the cover's counsel and the
signature start at mid-page (`right-half`; `pad(left: 50%)` measured half the content's own width); the
certificate's items are text, not a list; footnotes are never split and sit 13.29 pt below the text (the room
LibreOffice keeps above a Word document's notes). The latex word count is taken before the inline rules (it had
dropped 4 words); latex sets an ellipsis as one 1 em glyph; Word gets typst's break opportunities (no break inside
"1332(d)(11)", a break after a slash before a letter).

Gate 2 review of the new renders (`pdftoppm -r 50`, every page of the typst PDF, and the cover, contents,
authorities and signature pages of the latex and docx PDFs): no tier-1 defect. Tier 2, ACCEPTED: the table of
authorities runs onto a third page (two statute rows on iii); the signature block stands alone on body page 9 (the
markdown ends with footnote definitions, so the last paragraph is not kept with it, as before the port); the cover's
gaps differ between engines (typst picks the largest gap that fits, LaTeX stretches, Word sets fixed gaps).
