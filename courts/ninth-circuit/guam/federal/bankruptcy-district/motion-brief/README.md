# gub: motion with memorandum

Doc type: **motion with a memorandum of points and authorities** (Fed. R. Bankr. P. 9013 and Bankr. L.R. 9013-1: a written motion stating its grounds with particularity, with the memorandum in the same filing) in the United States Bankruptcy Court, District of Guam, Bankruptcy Division (`gub`).
Folder: `courts/ninth-circuit/guam/federal/bankruptcy-district/motion-brief/`. Exemplar: a motion to dismiss an adversary complaint (Rule 12(b)(1) and (6)), with the memorandum in the same document.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-campos-20-00001-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-campos-motion-to-dismiss.md`: the whole filed document (caption, notice of motion, procedural history, legal standard, argument I to III, conclusion, two footnotes, signature) |
| render | ok: `samples/OUTPUT-campos-motion-to-dismiss.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only (`pdffonts`), no warnings |
| typeface | face required: none (GNLR 5.1 and the Bankr. L.R. text, read 2026-10-15, name no face or point size) → vendored substitute: none; **EB Garamond** is the no-face default (`docs/FONTS.md`) → metric-compatible: n/a |
| overlay | ok: `samples/OVERLAY-campos-motion-to-dismiss.pdf` and `.txt` (each sample page paired with the same-numbered filed page, all 11); the filed exemplar was re-fetched from the RECAP URL in `exemplars/SOURCE.md` and matches its SHA-256; the PDF is kept outside the repo, since no court tracks exemplar PDFs in git |
| pages reviewed | 11 of 11 (re-rendered 2026-10-15 and every page rasterised at 60 dpi and viewed; the layout is unchanged from the record below) |

## Governing rules

| ID | Rule | Requirement | Where it lives in the template | Verified |
|---|---|---|---|---|
| GUB-MOT-001 | Gen. L.R. (D. Guam) 5.1(a) | White 8½ × 11 paper; pages numbered consecutively at the bottom; "All papers shall be double-spaced except for the identification of counsel, title of the case, footnotes, quotations, and exhibits." | `page-w`, `page-h`, `numbering` at bottom centre; `body-leading` (2 em pitch, double spacing); single spacing for counsel, caption, quotations, footnotes, signature. | Text read from the District of Guam General Local Rules, "as of 2021-11-29" PDF (`https://www.gud.uscourts.gov/sites/gud/files/General%20Local%20Rules%20as%20of%2020211129%20final%20%281%29.pdf`), fetched 2026-10-14. The current revision was not checked. |
| GUB-MOT-002 | Gen. L.R. 5.1(b) | Court title centred, "commence not less than three inches from the top of the page." | `counsel-block` fixes the counsel block at 2 in below the 1 in top margin, so the court title starts at 3 in. `court-title()` is the three-line title. | same |
| GUB-MOT-003 | Gen. L.R. 5.1(c)(1) | Counsel's name, address, telephone upper left; space to the right of centre reserved for the clerk's filing stamp. | `counsel-block` is half the text width (left of centre). | same |
| GUB-MOT-004 | Gen. L.R. 5.1(c)(2)–(3)(A)–(C) | Title of the action below and left of the court title; to the right: the file number, "bankruptcy" or "adversary", and a brief description of the document. | `caption` (left column: the lead lines and parties, "vs." between them); `case-info` (case number, chapter, "Adversary Proceeding", adversary number, bold title). | same |
| GUB-MOT-005 | Gen. L.R. 5.1(c)(3)(D) | To the right: "mention of any notice of motion or affidavits or memorandum in support." | `case-info` prints "With Memorandum in Support" when the frontmatter `memorandum: true`. The exemplar's own title does not carry this line (see Known gaps). | same |
| GUB-MOT-006 | Gen. L.R. 5.1(d) | Names typed below signatures. | `signature-block`: "/s/" line, then the typed name and the party line. | same |
| GUB-MOT-007 | Fed. R. Bankr. P. 9013(a), (b) | "A request for an order must be made by written motion"; "A motion must state its grounds with particularity and set forth the relief or order requested." | The sample's opening paragraph states the grounds and the relief; the template does not check the wording. | Cornell LII, `https://www.law.cornell.edu/rules/frbp/rule_9013`, fetched 2026-10-14. |
| GUB-MOT-008 | Fed. R. Bankr. P. 9011(a) | Attorney signs in individual name; the document "must state the signer's address and telephone number." | Counsel block and signature block. | Cornell LII, `https://www.law.cornell.edu/rules/frbp/rule_9011`, fetched 2026-10-14. |
| GUB-MOT-009 | Fed. R. Bankr. P. 9004(b) | Caption: court name, case title, case number and adversary number, "a brief designation of the document's character." | `caption`, `case-info`. | Cornell LII, `https://www.law.cornell.edu/rules/frbp/rule_9004`, fetched 2026-10-14. |
| GUB-MOT-010 | Bankr. L.R. 9013-1(b) (adopted text) | "All motions, unless made in open court, shall include a memorandum setting forth the points and authorities relied upon in support of the motion. Unless otherwise permitted by the court, a motion and the supporting memorandum shall not exceed 15 pages, exclusive of attachments." | Not checked by the template: there is no page counter. The sample is 11 pages. | Read as a search-result excerpt of `https://www.courtrules.net/courts/federal/bankruptcy-district-guam/local-rules/3171`; the direct fetch returned HTTP 403, so the full adopted text was not read. |
| GUB-MOT-011 | Bankr. L.R. 9013-1(c)(1)–(2) (proposed text) | Notice of hearing to be given "not later than 28 days before the hearing", "substantially conform[ing] to the local form (Notice of Hearing)"; responses due 14 days before the hearing, replies 7 days before. | Not generated. The notice of hearing is a separate Guam form, GUB 9073-1 (08/2013), printed on the same proposed-rule PDF. | `https://www.gud.uscourts.gov/sites/gud/files/Bankruptcy%20Local%20Rule%209013%20Amendment%204.pdf`, text read with pdftotext, fetched 2026-10-14. This is the **proposed** text (the court's own notice of amendment says the rule was adopted effective 2023-11-20; the search summary reported that the adopted version differs in some page limits). Confirm against the adopted rule. |
| GUB-MOT-012 | Bankr. L.R. 1001-1(d) and 7001-1 | The General and Civil Local Rules of the District Court apply to the bankruptcy local rules as appropriate. | Basis for applying GUB-MOT-001 to a motion. | Search excerpt only (courtrules.net mirror; direct fetch 403). |

Not generated, on purpose: the notice of hearing (GUB 9073-1), the proposed order, the declaration and request for entry of order (GUB 9021-1), and the certificate of service. The exemplar copy on RECAP has none of these.

## Layout

- Cover: counsel block (upper left, single-spaced), the three-line court title at 3 in, the caption (left: lead lines, parties, "vs."; right: case number, chapter, designation, adversary number, title, memorandum line).
- Body: double-spaced, first-line indent 0.5 in, page number bottom centre. Headings: level 1 centred bold capitals; levels 2 and 3 bold, left, with hanging indent. The author types the section numbers (I., A., 1.), as the exemplar does; the template does not number.
- Block quotations single-spaced and indented 0.5 in on both sides. Footnotes 11 pt, single-spaced.
- Signature: "Respectfully submitted this [date]." then "/s/" and the typed name, the party line, and the firm lines, at right.

## Markdown contract (for samples)

- YAML frontmatter, then the body. `#` is a level-1 heading (centred bold capitals); `##` and `###` are bold left headings; the author types any number.
- Frontmatter: `counsel` (lines), `case_number`, `chapter` (optional), `adversary_number`, `caption` (`lead`: lines before the parties; `parties`: list of `names` and `designation`, with "vs." between), `brief_title`, `memorandum` (true to print the memorandum line), `date` (the "Respectfully submitted" date, e.g. "30th day of May 2020"), `signature` (`signer`, `lines`).
- Footnotes: `text[^1]` and `[^1]: ...` anywhere in the file.
- Quote any YAML value that contains `#` or `: `, since YAML reads `#` after a space as a comment.
- Not supported: tables, raw typst.

## Known gaps and open choices

1. **Local Rule 9013-1 page limit (GUB-MOT-010) is not checked.** There is no page counter; the sample is 11 pages, under the 15-page limit read from the search excerpt. The full adopted text was not read, so the limit is a secondary source.
2. **Notice of hearing (GUB-MOT-011) is not part of the template.** BLR 9013-1 requires a notice substantially conforming to GUB 9073-1, and the proposed text says it must be given 28 days before the hearing. The exemplar is filed without one, so the template produces only the motion. A notice and the hearing date are for the filer.
3. **"With Memorandum in Support" (GUB-MOT-005)** is printed from the frontmatter flag. GNLR 5.1(c)(3)(D) asks for a mention of the memorandum; the exemplar's title does not carry it, so the render differs from the exemplar on that line. The overlay will show it.
4. **Court name.** The exemplar captions the court "UNITED STATES DISTRICT COURT, DISTRICT COURT OF GUAM"; this template uses "DISTRICT COURT OF GUAM / TERRITORY OF GUAM / BANKRUPTCY DIVISION", the form used in the complaint exemplar and on the court's notice form. The court's own name for the bankruptcy division is not settled by the sources read.
5. **Line numbers are not drawn.** GNLR 5.1 does not require them; the exemplar (an ECF filing) does not carry them either.
6. **Font.** EB Garamond (vendored, OFL) at 13 pt. No rule read names a typeface (GNLR 5.1 names no typeface or size; Bankr. L.R. text checked 2026-10-15), so EB Garamond stays, per `docs/FONTS.md`. The exemplar is Times New Roman 12 pt, and EB Garamond sets smaller at the same size, so 13 pt was chosen to match its visual size. This is a choice, not a rule.
7. **Case names and signals are not italic.** The exemplar's text layer has no italic markup (`pdffonts` shows Times Roman and Bold only), so the sample is roman. The template italicises `*...*`, so a future sample can carry italics. The statutory "(emphasis added)" in the exemplar is therefore not reproduced.
8. **Headings are double-spaced** (2 em pitch, like body text). GNLR 5.1(a) exempts only counsel, the title of the case, footnotes, quotations and exhibits from double spacing; headings are not in that list, so double spacing is the reading used here.
9. **Only one exemplar.** Tier 2 is not judged against a second filer; the RECAP search found no other Guam motion in the same docket series.
10. **Certificate of service.** None is in the exemplar copy on RECAP, and none is generated. Whether one is required for this motion must be checked with the filing.
11. **Overlay pairing.** The filed pages 1 to 11 pair with our pages 1 to 11 by word overlap, as the page map shows (word overlap 75% to 95%). The overlay is a diagnostic, not a score.
12. **File names.** The brief names the overlay files `<id>-overlay.pdf` and `.txt`; `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt` and reads `OUTPUT-<id>.pdf`. The repo tools were not edited, so the tool's names are used.

## Visual review (Gate 2 record, all 11 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: counsel block, court title at 3 in, caption, title, memorandum line, opening paragraph | OK. Title bold; "With Memorandum in Support" on its own line. |
| 2 | Procedural history, footnote 1 at foot | OK after the spacing fix (paragraphs and headings no longer overlap; the first version overlapped at each paragraph break). |
| 3 | Procedural history end, footnote 2, Legal Standard A, block quotation | OK. |
| 4 | Legal Standard B, Argument I heading | OK. |
| 5 | Argument I, end of section | OK. Blank space at foot before the II heading (heading kept with its paragraph). |
| 6 | Argument II heading, statute block quotation | OK. The em dash at the end of the quoted line (5) is an orphan from the quotation's own wrap. |
| 7 | II.A to II.C | OK. Hanging indent for the sub-headings. |
| 8 | II.D | OK. |
| 9 | II.D end, II.E, II.F heading | OK. |
| 10 | II.F end, III heading, Senate Report lead-in | OK. |
| 11 | Senate Report block quotation, III conclusion, CONCLUSION, signature | OK. Signature block on the conclusion page (an earlier layout put it alone on page 12; the spacing before it is now one line). |

Pages reviewed: 11 of 11.

## Engines

### docx (build 2026-10-15, LibreOffice not installed)

Files: `docx/make-reference.sh` (builds `docx/reference.docx` from pandoc's default), `docx/gub-motion-brief.lua` (cover, caption, signature). Sample output: `samples/OUTPUT-campos-motion-to-dismiss.docx`. Checked: valid zip, every XML part well-formed (xmllint). Not rendered: no page of the docx was looked at (pages_reviewed = 0).

What the XML sets (in `styles.xml`, `sectPr` and the footer part; set, not rendered):
- EB Garamond 13 pt everywhere; body on an exact 26 pt line pitch (double spacing).
- Level 1 heading centred and bold; levels 2 and 3 bold, left. Headings have half a line above and below.
- Footnote Text 11 pt, single spaced (pandoc's footnotes).
- US Letter with 1 in margins on all four sides; footer distance 0.5 in.
- Footer: a centred PAGE field (GNLR 5.1(a)).
- No line numbers and no pleading rules (the typst form draws none).
- Custom styles: Counsel, Court Title, Caption Block, Signature Block (15 pt exact).

What the filter does (not a style):
- Cover from the frontmatter: counsel lines, the three court-title lines (the form's text), a spacer that puts the title at least 3 in from the top (computed, not measured), the caption as a two-column table with a bottom and right rule (lead lines, then the parties with "vs." between), the case information on the right, with "With Memorandum in Support" when `memorandum` is true.
- Signature block: "Respectfully submitted this <date>.", then "/s/" and the signer's name and lines, at the right.
- The body is pandoc's: the author types paragraph and heading numbers, as in the typst form.

Differs from typst:
- Level 2 and 3 headings have no 0.5 in hanging indent in the docx (typst has one); the typed letter or number leads them.
- Heading spacing is half a line above and below, not the typst leading; the cover lines are exact 15 pt, not the typst single leading.
- The frontmatter `date` is printed through the signature line only; pandoc's own title or date block is suppressed.
- Pagination is not compared with the typst PDF (no docx page was rendered).

BLOCKED (docx):
- docx.pdf Gates 0 to 3: BLOCKED, no LibreOffice on the build box (`soffice` is not installed and conda-forge has no package). The `.docx.pdf` was not written; the `.docx` is the only output.
- The court title at least 3 in from the top (GUB-CMP-002 family, GNLR 5.1(b)): BLOCKED for a measured check; the spacer is computed, not measured.
- Page-count and cross-reference checks: BLOCKED until a PDF of the docx can be made; the typst PDF is the only measured page count (11 pages).
