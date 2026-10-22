# wied: motion-brief

Doc type: **motion-brief**, the memorandum (brief) in support of a Rule 12(b)(6) motion to dismiss, in the United States District Court for the Eastern District of Wisconsin (`wied`).
Folder: `courts/seventh-circuit/wisconsin/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (14 pp.; the overlay reference). Second filer: `FILED-EXAMPLE-motion-brief-2.pdf` (9 pp.). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md` (the whole brief, transcribed from the text layer) |
| render | ok (re-run 2026-10-22, fb-595.68.28): `usage/OUTPUT-motion-brief.typst.pdf` and `.docx.pdf`, 13 pages each, typst 0.15.0, `pdffonts`: Times New Roman regular, bold, italic, bold italic only (embedded), no warnings |
| overlay | fail (2026-10-15): `tools/overlay.sh` exits 1, `no exemplar pdf in usage/`. The filed PDFs are not in this snapshot (`usage/` holds `SOURCE.md` only). The earlier `OVERLAY-nocams-motion-brief.*` files are from a run with the PDFs present and are not regenerated |
| pages reviewed | 13 of 13, typst and docx (re-rendered 2026-10-22 and each page viewed at 50 dpi in montage) |

## Governing rules

Primary source: Local Rules of the United States District Court for the Eastern District of Wisconsin, "Local Rules 2010-0201, Amended 2026-0729" (71 pp.), fetched 2026-10-14 from https://www.wied.uscourts.gov/sites/wied/files/documents/Local%20Rules%202010-0201-Amended%202026-0729.pdf (linked from https://www.wied.uscourts.gov/local-rules-and-guidance).

Federal Rules of Civil Procedure, from the Legal Information Institute (https://www.law.cornell.edu/rules/frcp), fetched 2026-10-14: Rule 12(b).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| General L.R. 5(a)(5) | 8½ × 11 inch paper; double-spaced text; quotations more than two lines long may be indented and single-spaced; headings and footnotes may be single-spaced; margins of at least one inch on all four sides; page numbers may go in the margins. | `margin = 1in`, `pitch-body` (exact 24 pt line boxes), `pitch-single` (13.8 pt) for the caption, argument and sub-headings, block quotations and signature. Page number centered in the bottom margin. Block quotations (markdown `>`) are single-spaced and indented 0.5 in each side. |
| General L.R. 5(a)(6) | A proportionally spaced face must include serifs (sans-serif allowed in headings and captions) and be 12-point or larger. No face is named. | `font-family = ("Times New Roman", "Liberation Serif")` (serif), `type-size = 12pt` everywhere, headings and the page number included. Typeface: no face named by the rule, so Times New Roman, the house standard (`docs/FONTS.md`), in typst and docx alike. |
| General L.R. 5(a)(7) | Plain roman type; italics or boldface for emphasis; case names italicized or underlined. | Body is roman; `*...*` in markdown renders italic (`inl`, `md`). The sample italicizes case names; see gap 1. |
| General L.R. 5(c) | Signature block: `s/ [attorney name]`, attorney name, bar number, attorney for (party), firm, address, telephone, e-mail. | `signature-block()`, one `s/` line per signer. |
| Civil L.R. 7(a) | A motion must state the rule it is made under and be accompanied by a supporting memorandum (or a certificate that none will be filed). | The brief is the memorandum; the motion itself is a separate document, not produced here. |
| Civil L.R. 7(f) | The principal memorandum in support of a motion must not exceed 30 pages; a reply must not exceed 15 pages; the caption, cover, tables and signature block are excluded from the count. | No check in the template (the count is not enforceable in typst). The Nocams sample is 13 pages including the caption and signature (about 11 pages of text), well under 30. |
| Civil L.R. 7(j) | Unreported decisions may be cited; an unavailable one must be served on the parties (and on pro se parties). | Content only. |
| Civil L.R. 7(k) | Notice of Supplemental Authority is a separate filing without argument. | Not produced here. |
| Fed. R. Civ. P. 12(b)(6) | Motion to dismiss for failure to state a claim. | The brief's standard of review and argument are the sample's content, not the template's. |

Not produced by this template (separate filings, not part of the brief): the motion itself (Civil L.R. 7(a)), any declaration or exhibits, the proposed order (Civil L.R. 7(a)), and any certificate of service. A certificate of service is not required for papers served through ECF (Civil L.R. 5); a paper served on a pro se party needs one. The ECF header is added by the court's electronic system at filing and is not added here.

## Layout

- Court title, centered bold caps, on the first page; caption with party names on the left, "Case No." on the right, no ruled box.
- Document title centered bold caps (for example, "BRIEF IN SUPPORT OF DEFENDANTS' MOTION TO DISMISS").
- Body paragraphs are not numbered. A first-line indent of 0.5 in; double-spaced (24 pt pitch).
- Section headings (`#`, e.g. INTRODUCTION, ARGUMENT, CONCLUSION): centered bold caps at 12 pt on the body pitch, 12 pt above.
- Argument headings (`##`, "I. TEXT"): bold, single-spaced, with the numeral in a 1 in hanging column; wrapped lines align with the text; 12 pt above, 6 pt below.
- Sub-headings (`###`, "a. Text"): bold italic, single-spaced, indented 0.5 in, 6 pt above and below.
- Block quotations (`>`): single-spaced, indented 0.5 in on each side, 12 pt above and below.
- Signature block: "Dated this ... day of ..." (sample field `date`), then firm, role, `s/` line, name, bar number for each signer, address, telephone and e-mail, in the right half of the page.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `case_number`, `caption.parties` (list of `{names: [...], designation}`; "v." is inserted between parties), `document_title`, `jury_demand` (not used by briefs; keep false), `date` (the words after "Dated this", e.g. `7th day of October, 2026`), `signature` (`firm`, `role`, `signers: [{name, bar, email}]`, `address: [lines]`, `telephone`).
- Body: blank-line-separated chunks. `#` = section heading; `##` = argument heading ("I. TEXT"); `###` = sub-heading ("a. Text"); `>` = block quotation; any other chunk = a paragraph.
- Case names and signals (*Id.*, *See*) are italic in the markdown (`*...*`).
- Not supported: tables (none in this doc type's exemplars), footnotes, raw typst, numbered paragraphs (briefs are not numbered).

## Known gaps and open choices

1. **Case-name italics are not from the exemplar.** General L.R. 5(a)(7) requires case names in italics or underline. The Nocams text layer carries no italic information, so the exemplar's roman case names could not be copied as-is. The sample italicizes case names as the rule requires. The template is rule-driven; the italics come from the sample's markdown, not the template.
2. **Font.** Same as the complaint: the rule names no face, so Times New Roman 12 pt, the house standard (`docs/FONTS.md`) and the exemplars' face, in both engines.
3. **Signature block alone on the last page.** The conclusion ends on page 11 and the whole signature block (unbreakable, `breakable: false`) starts page 12. The exemplar puts its signature block after its last paragraph on the same page, but the pagination differs with the font. Accepted; not forced.
4. **No table of contents or table of authorities.** E.D. Wis. Civil L.R. 7 does not require one for a brief under 30 pages (the Nocams and Schmidt briefs have none). The template does not generate one.
5. **Second filer, not overlaid.** `tools/overlay.sh` compares against the first exemplar only (Nocams). Schmidt was checked by reading its layout (caption, roman-numeral headings, conclusion, signature), not by overlay.
6. **Page limit not enforced.** Civil L.R. 7(f) limits the principal brief to 30 pages. The template cannot count pages against the limit; the reviewer must check the rendered page count.
7. **Gate scripts.** Since fb-595.68.28: `sh tools/check.sh <this folder>` and `--engine docx` both exit 0 (typst 9, docx 13 checks passed, 0 failed).

## Review of the rendered pages (`usage/OUTPUT-motion-brief.typst.pdf` and `.docx.pdf`, 13 pages each)

Rendered at 50 dpi and viewed page by page on both engines after the cross-engine port (fb-595.68.28); the docx breaks every line and page as typst does (XENG-001..003).

| Page | Content | Finding |
|---|---|---|
| 1 | Court title, caption (parties; case number right), document title, opening paragraph, INTRODUCTION. | Pass. Caption and title fit on the first page; ARGUMENT and its headings move whole to page 2 (kept with their text). |
| 2 | ARGUMENT, I. STANDARD OF REVIEW, sub-heading a., paragraphs. | Pass. Hanging numeral aligned; sub-heading indented. |
| 3 | Sub-heading b.; II. heading in two lines, aligned after the numeral. | Pass. |
| 4 | Section II; III. heading in two lines. | Pass. |
| 5 | Section III paragraphs (Tuggle, Edwards, Katz citations). | Pass. Italic case names; ". . ." kept with the word before it in both engines. |
| 6 | Section III (Knotts, Tuggle, Carpenter). | Pass. |
| 7 | Section III end, IV. PLAINTIFFS LACK STANDING, sub-heading a. | Pass. |
| 8 | Sub-heading a. paragraphs. | Pass. |
| 9 | Sub-heading b. (associational standing). | Pass. |
| 10 | Associational standing, paragraphs. | Pass. |
| 11 | Sub-heading c. (taxpayer standing). | Pass. |
| 12 | Block quotation (single-spaced, indented 0.5 in both sides), CONCLUSION. | Pass. Block quotation as General L.R. 5(a)(5) allows. |
| 13 | "Dated this 7th day of October, 2026." and the signature block with two signers, address, telephone and e-mail. | Pass. Block whole on the last page (gap 3). |


## Engines

### docx (`docx/`: `reference.xml`, `wied.lua`)

- `docx/reference.xml` holds the Word styles: `base="xengine"` in the typst face (`{font}`, Times New Roman), 12 pt, 480-twip body and 276-twip single line boxes, the 12 pt page-number footer 0.5 in above the page edge; `fb render` builds the reference document from it. `docx/wied.lua` reads the sample's body chunk by chunk, as the typst template does, and writes every paragraph as WordprocessingML on `lib/docx/xengine.lua`: the court title, the borderless caption table (3.25 in party column, 0.3 in gutter), the title, the body paragraphs, section headings, argument headings (the numeral, a tab to the 1 in hanging indent), sub-headings, block quotations and the signature block. No script: `fb render` runs pandoc with the filter and packs the archive (fb-595.68.28; were `build-reference.sh` and a committed `reference.docx` naming EB Garamond).
- Cross-engine (fb-595.68.28): `sh tools/check.sh <this folder> --engine docx`: XENG-001..003 PASS (343/343 typst lines break after the same word, 13 = 13 pages); `params.cross_engine: gate` in `eval.yaml`. typst 9 and docx 13 checks passed, 0 failed. The filter binds the space before a period (". . ."), where typst (Unicode line breaking) never breaks and LibreOffice would.
- The `.docx` converts in LibreOffice without error; not opened in Word. The brief has no TOC or TOA in the typst template, so the docx has none.
