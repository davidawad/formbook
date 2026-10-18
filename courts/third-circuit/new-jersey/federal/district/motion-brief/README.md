# njd: motion-brief

Doc type: **motion-brief**, the memorandum of law in support of a motion (here a Rule 12(b)(6) motion to dismiss), in the United States District Court for the District of New Jersey (`njd`).
Folder: `courts/third-circuit/new-jersey/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `usage/SAMPLE-njd-motion-brief-karre226cv06421.pdf` (McGuireWoods LLP, primary, 22 pages) and `usage/SAMPLE-njd-motion-brief-zeines225cv13335.pdf` (Freedman Normand Friedland LLP, 13 pages). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-njd-motion-brief-karremotiontodismiss.md`: the cover, the Introduction, Statement of Facts, Legal Standard, Point I, and the Conclusion with signature, transcribed from the Karre memorandum. Points II to IV are omitted and marked in the text. |
| typeface | Face required: **Times New Roman 14 pt** as the reference proportional face in L.Civ.R. 7.2(d) ("such as Times New Roman 14"; the rule also allows Courier New 12). Substitute: **Liberation Serif** (vendored; metric-compatible with Times New Roman, see `docs/FONTS.md`). Visual match, not pitch-identical: see Known gaps 1. |
| render | ok: `usage/OUTPUT-njd-motion-brief-karremotiontodismiss.typst.pdf`, 11 pages (cover, table of contents `i`, table of authorities `ii`-`iii`, body 1-7), typst 0.15.0, vendored Liberation Serif only (`pdffonts`: LiberationSerif, -Italic, -Bold), no warnings |
| overlay | ok: `usage/OVERLAY-karre-motion-to-dismiss.pdf` and `.txt` (against the Karre exemplar; see below) |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed after the fonts pass; open items are marked OPEN in the Gate 2 table) |

File names follow `tools/render.sh` and `tools/overlay.sh`: the sample is `INPUT-<id>.md`, with `<id>` = `karre-motion-to-dismiss`.

## Governing rules

Primary sources, fetched and read 2026-10-14 (D.N.J. Local Civil Rules, complete compilation, https://www.njd.uscourts.gov/sites/njd/files/CompleteLocalRules.pdf; Fed. R. Civ. P. text from https://www.law.cornell.edu/rules/frcp).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| L.Civ.R. 7.2(b) | Any brief includes a table of contents and a table of authorities; the text is limited to 40 ordinary typed pages (15 for a reply), excluding the contents pages. | `toc-section()` and `toa-section()`, built from the headings and from the `toa:` links in the body. The 40-page limit is not enforced by the template; the sample is 7 body pages. |
| L.Civ.R. 7.2(c) | 8.5 x 11 inch paper, black lettering, margins not less than one inch on the sides, top and bottom. | `paper: "us-letter"`; `margins` (1 inch on all sides). |
| L.Civ.R. 7.2(d) | Double-spaced text and/or single-spaced footnotes or inserts; 12 pt non-proportional (Courier New 12) or the equivalent 14 pt proportional font (Times New Roman 14); a 12 pt proportional font reduces the page limits by 25%; footnotes in the same size as the text. | `type-size = 14pt`; `pitch = 28.3pt` (measured in Karre: 28.3 pt); footnotes `set text(size: type-size)`; block quotations single-spaced, which Karre also does (measured: 16.1 pt pitch at 14 pt). |
| L.Civ.R. 7.1(d)(1) | The brief is a separate document, prepared under L.Civ.R. 7.2, filed at least 24 days before the noticed motion day. | Separate file in the court's ECF filing; the template produces one document. Timing is not a template matter. |
| L.Civ.R. 78.1(a) | Regular motion days are the first and third Monday of each month. | `motion_day` on the cover ("Motion Day: August 17, 2026", a third Monday; the Karre exemplar's "Motion Date"). |
| L.Civ.R. 10.1(a) | The first paper states the address of each named party. | Author content: the sample's counsel block gives counsel's address; the template does not check party addresses (see gap 2). |
| L.Civ.R. 10.1(b) | Papers bear the docket number and the name of the assigned judge; the first page endorses the name, office, address and telephone of the attorney of record; black lettering; 8.5 x 11. | `case_number` (Civil Action No.) and `judge` (blank in the sample: see gap 2); counsel block top-left (`counsel`). |
| L.Civ.R. 11.1 and ECF Policies ¶ 12(a) | Signature line with "s/" for an electronically filed document. | `signature-block()`: "/s/ <signer>". |
| Fed. R. Civ. P. 12(b)(6) (Cornell text) | The motion asserts failure to state a claim. | Content only; the sample cites the rule. |

## Layout

- Letter, 1-inch margins; Liberation Serif 14 pt; double spacing at a 28.3 pt pitch (body leading 1.114 em, single-spaced pitch 16.1 pt; both tuned to Liberation Serif's 12.7 pt line height and checked against the Karre exemplar's 28.3 pt and 16.1 pt, measured with `pdftotext -bbox`); first-line indent 0.5 inch; headings: level 1 centered bold caps (INTRODUCTION, ARGUMENT, CONCLUSION), level 2 numbered "I." with a hanging indent and bold text, level 3 "A.", level 4 "1.".
- Cover (no page number): counsel block top-left, single spaced; court title centered bold caps; caption with the party column closed by a right and a bottom rule; the right column carries the `Civil Action No.`, the judge line when set, and `Motion Day:`; the bold caps title centered under the caption.
- Contents pages numbered in roman numerals (`i`, `ii`, ...); the body restarts at 1 (L.Civ.R. 7.2(b) does not prescribe the numbering; this is the usual practice in both exemplars).
- Table of contents: headings with dot leaders and page numbers, produced from the headings. Table of authorities: grouped Cases, Statutes, Rules, Regulations, Other Authorities; case names italic; an authority cited on seven pages or more reads "passim"; page numbers from the `toa:` link locations.
- Signature block: "Dated:" at left; "Respectfully submitted," "/s/" signer, signer, firm and the signer's lines at right.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body: `#` heading (level 1), `##` (level 2, numbered by the template as I., II., ...), `###` (level 3, A., B., ...), paragraphs, block quotations (`>`, single spaced and indented), and inline italics (`*...*`).
- Authority links: `[*Case Name*](toa:key)`, one link per citation occurrence that should appear in the table of authorities; each key must have an entry under `authorities:` in the frontmatter (the template fails the build otherwise). Star pages (`at *6`) and the "E*TRADE" name use an escaped asterisk (`\*`).
- Frontmatter: `counsel` (lines), `court` (lines), `caption.parties` (`{names, designation}`), `case_number`, `judge` (`""` allowed), `motion_day`, `title`, `date`, `signature` (`signer`, `firm` lines, `lines`), `authorities` (`{kind: case|statute|rule|regulation|other, name?, cite}`).
- Not supported: tables, footnotes in the body (none used), raw typst.

## Gate 2: visual review of the render (every page, 60 dpi)

| Page | Review |
|---|---|
| 1 (cover) | Counsel top-left; court title centered bold; caption with party column and rule; `Civil Action No.` and `Motion Day:` on the right; title centered bold below the caption. No page number. Pass. |
| 2 (contents `i`) | TABLE OF CONTENTS; four top-level entries, the Point I entry, and CONCLUSION; page numbers right-aligned with dot leaders. Pass. |
| 3 (authorities `ii`) | TABLE OF AUTHORITIES; Cases list in alphabetical order, italic case names, page numbers. OPEN (TOA-1): the *New Jersey Bank, N.A. v. Bradford Secs. Ops.* entry breaks after its dot leader, so its page number `5` sits alone on the next line. The italic cite nearly fills the line and typst breaks after the leader box; wrapping it in one `box` did not stop the break (tried in the fonts pass, reverted). |
| 4 (authorities `iii`) | Remaining cases; Statutes and Rules groups, each entry with its page numbers. Pass. |
| 5 (body 1) | INTRODUCTION centered; double-spaced text with first-line indent; a paragraph with the em dash; citations and the Rule link. Layout and typeface pass. OPEN (SP-1), shared by pages 5-11: paragraph breaks are tight (see Known gaps 9). |
| 6 (body 2) | Paragraphs on the STATEMENT OF FACTS; "See id." italic signals; paragraph spacing unchanged. Layout and typeface pass. OPEN (SP-1). |
| 7 (body 3) | LEGAL STANDARD heading; quotations and "Id." italic; star pages as `*6`. Layout and typeface pass. OPEN (SP-1). |
| 8 (body 4) | ARGUMENT centered; "I." heading with hanging indent and bold text; Point I opening paragraphs. Layout and typeface pass. OPEN (SP-1). |
| 9 (body 5) | Paragraphs with Third Circuit and state citations; case names italic throughout. Layout and typeface pass. OPEN (SP-1). |
| 10 (body 6) | Block quotation single spaced and indented; citation line flush left after it; the omission marker in italics. Layout and typeface pass. OPEN (SP-1). |
| 11 (body 7) | CONCLUSION centered; signature block: dated line, "Respectfully submitted," "/s/" signer, firm and address. Layout and typeface pass. OPEN (SP-1). |

## Overlay (`tools/overlay.sh`)

- Against the Karre exemplar (the default, `usage/*.pdf | head -1`): our page 1 pairs with filed page 1 (word overlap 84.9%), our pages 2-3 with filed pages 2 and 4 (42.8%, 36.3%), our page 4 (table of authorities `iii`) with filed page 5 (1.4%: a list of statute and rule citations shares few words with the filed text), our 5-10 with filed 7, 8, 10, 11, 12, 13 (84.8%, 65.2%, 45.4%, 66.9%, 78.1%, 83.9%), and our page 11 with filed page 22 (63.6%). The fonts pass re-rendered this map with Liberation Serif; the pairing moved only where the wider face changed the pagination. The map is by word overlap, so the offsets follow the exemplar's own pagination (its text is a 22-page memorandum; ours is a partial transcription of the same passages).
- Against the Zeines exemplar (third argument; run once, then overwritten by the Karre run): overlap 5% to 20%, expected for a different case; diagnostic only.
- Layout comparison with both exemplars was made by eye from the rasterized cover pages: Zeines puts counsel top-left, the bold court title centered, a caption closed by a right and bottom rule, and the bold title under the caption (matches this template). Karre puts counsel under the title on the cover; L.Civ.R. 10.1(b) allows either placement, and the template follows Zeines.

## Known gaps and open choices (for David)

1. **Font face (L.Civ.R. 7.2(d)), resolved in the fonts pass for David to confirm.** The rule allows "12-point non-proportional font (such as Courier New 12) or an equivalent 14-point proportional font (such as Times New Roman 14)". The rule names Times New Roman as its reference face, so the template now sets **Liberation Serif 14 pt**, the metric-compatible substitute in `docs/FONTS.md`, instead of EB Garamond. The reading is that "such as" names the face the rule has in mind, not a mandate; if David reads it as allowing any equivalent proportional face, EB Garamond 14 pt is the alternative (EB Garamond at 14 pt looks smaller than Times New Roman at 14 pt). Page count is unchanged (11 before and after). The 12-pt option with a 25% page-limit cut is not used.
2. **Judge's name (L.Civ.R. 10.1(b)).** The rule says the paper bears "the name of the Judge assigned". Both exemplars print only the judge's initials, inside the case number (`WJM-CF`, `JXN-LDW`); neither prints the name on the cover. The template has a `judge` line for the full name; the sample leaves it blank because the name is not in the exemplar and was not invented. Whether initials suffice in practice, or the name is required, is a question for David.
3. **Party addresses (L.Civ.R. 10.1(a)).** This rule asks for each party's address in the first paragraph of an initial paper. A motion memorandum is not an initial paper, so the template does not require it; noted in case a reader takes the other view.
4. **Partial transcription.** The sample omits Points II to IV, the rest of Point I, and their citations. The bracketed marker in the body says so. The contents and authorities pages list only the entries in the transcription, not those of the filed memorandum.
5. **Block quotations.** Single spaced, as Karre sets them. L.Civ.R. 7.2(d) says "double-spaced text and/or single-spaced footnotes or inserts"; whether a block quotation is an "insert" is a reading question. Karre's practice supports the reading used here.
6. **Footnotes.** The footnote style is set (14 pt, single spaced, same size as the text) but no footnote is in the sample, so it is untested.
7. **Page limit.** The 40-page limit (L.Civ.R. 7.2(b)) is not checked by the template; the sample is far below it.
8. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json`, `rules.md` and `checks.yaml`; this doc-type folder has none of them and the brief forbids editing `tools/`. The gates were not run; the render, the overlay and the review above are the evidence for this doc type.
9. **Paragraph breaks are tight (SP-1, open).** The template sets `spacing: 0pt` between paragraphs, so the line pitch at a paragraph break is the line height (12.7 pt here) rather than the 28.3 pt double-space pitch: the first line of each new paragraph nearly touches the line above. Inside paragraphs the pitch is 28.3 pt. The complaint template has the same setting (its paragraph breaks measure 15.7 pt against a 27.6 pt pitch), so this predates the fonts pass. The fix (`spacing` equal to the body leading, which changes pagination in both templates) is a layout decision, not a font change, and is left for a separate change.
10. **Table-of-authorities wrap (TOA-1, open).** The *New Jersey Bank* entry on page `ii` (PDF page 3) wraps its page number onto its own line. Cause: the italic cite fills the line and typst breaks after the leader box. A single `box` around the leader and the page number did not prevent it. A fix needs a different leader construction or a manual entry layout; not done here.
11. **Overlay exemplar.** `usage/` holds only `SOURCE.md` in this snapshot; the two filed PDFs named there are not committed here, so `tools/overlay.sh` with its default exemplar cannot run. The overlay in this pass was run against the same RECAP files fetched from the URLs in `usage/SOURCE.md` (kept outside the repo). The PDFs should be committed as `usage/SAMPLE-*.pdf` before the overlay can be rerun from the folder.

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **docx** (`docx/reference.docx`, `docx/build-reference.sh`, `docx/njd.lua`): pandoc on a reference.docx restyled to the typst form: Liberation Serif 14 pt (the typst face, metric-compatible with Times New Roman), exact 28.3 pt (double) line spacing, 0.5 in first-line indent, letter page with 1 in margins. Three sections as in typst: the cover with no page number (blank footer), the contents and authorities numbered in roman from `i`, and the body numbered in arabic from 1 (12 pt centered PAGE footer). The filter builds the cover (counsel block, court title, caption table with the party column closed by a right and a bottom rule, `Civil Action No.`, `Motion Day:` line, bold caps title), the contents and the table of authorities (grouped Cases, Statutes, Rules, Regulations, Other Authorities, only the authorities the body cites, case names italic), the body headings (H1 centered bold caps; `I.`, `A.`, `1.`, `a.` labels written as text in a hanging indent, as the typst heading numbering), block quotations single spaced and indented, and the signature table. Known differences: the contents is a TOC field over the headings (Word: update the field for page numbers); the table of authorities is a list without page numbers and without `passim`; the "Page" label is not drawn; labels are typed text, not Word list numbering; the caption table borders differ slightly from typst. Word needs Liberation Serif installed (it is vendored in `fonts/`), or Word substitutes silently.
- **latex**: not built for this court yet (`latex/` is empty).
- Build: `sh docx/build-reference.sh docx/reference.docx`, then from the court folder `pandoc --from markdown+smart --to docx --reference-doc=motion-brief/docx/reference.docx --lua-filter=motion-brief/docx/njd.lua motion-brief/usage/INPUT-karre-motion-to-dismiss.md -o motion-brief/usage/OUTPUT-karre-motion-to-dismiss.docx`. The output passes a zip read of every entry and `xmllint --noout` on every XML part; the three section footers resolve to `footer1.xml` (page number) and `footer2.xml` (blank), as the filter expects.
- **BLOCKED (docx):** the `.docx.pdf` cannot be produced or checked, because LibreOffice cannot run in the build box (`soffice` is not installed; the partial extraction does not run). So no docx gate can be measured, and the docx pages were not rendered or viewed (`pages reviewed: 0`). The court has no `checks.yaml` (none is readable in this folder or the court folder), so no gate check IDs can be listed. Measured on the `.docx.pdf` and therefore BLOCKED: the typst page-number checks (contents and authorities page numbers, the `passim` rule, the body page numbers from 1), the `NJD-FORM-001`, `NJD-FORM-002` and `NJD-FORM-003` requirements (margins, face and size, spacing) as cited by the typst template, and the TOC and TOA entries' page numbers, which pandoc cannot compute (no layout pass). The typst render was checked page by page (11 of 11) as the reference.

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
