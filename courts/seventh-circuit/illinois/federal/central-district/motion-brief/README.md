# ilcd: motion-brief

Doc type: **motion-brief**, a memorandum of law in support of a Rule 12(b) motion to dismiss, in the United States District Court for the Central District of Illinois (`ilcd`).
Folder: `courts/seventh-circuit/illinois/federal/central-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (a portion of the memorandum: cover, introduction, background, legal standard, the opening of Points I to III, conclusion, signature, certificate) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 9 pages (cover, contents i, authorities ii, body 1 to 5, certificate 6), typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-ives-memorandum.pdf` and `OVERLAY-ives-memorandum.txt` |
| pages reviewed | 9 of 9, every page rendered at 60 dpi and viewed. The conclusion was moved onto the signature page after pages 1 to 7 were viewed; those pages are unchanged by the move. Re-rendered and re-viewed 2026-10-15 in the fonts pass (no font change); that pass found gap 10 on page 5, which the earlier review had passed. |

## Governing rules

Primary source: Civil Local Rules of the U.S. District Court for the Central District of Illinois, "September 2026 Version" (adopted by General Order 26-go-1), fetched 2026-10-14 from https://www.ilcd.uscourts.gov/sites/ilcd/files/September%202026%20Version%20.pdf.
Federal rule: Fed. R. Civ. P. 12(b), fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_12.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| CDIL LR 5.1(A) | 8½ × 11 paper, about one-inch margins, pages numbered. | `page-margin`; `numbering` set per part (none on the cover, roman in the front matter, arabic in the body). |
| CDIL LR 5.1(B)(1) | Double-spaced lines. | `body-leading = 1.35em` (24 pt at 12 pt); `spacing: body-leading` on body paragraphs so the pitch across a paragraph break is the same as within one. |
| CDIL LR 5.1(B)(2) | Body text 12- or 14-point, footnotes 10-point or larger, plain roman style. | `type-size = 12pt`; `footnote-size = 10pt`; EB Garamond Regular and Bold; italics only for case names and signals. |
| CDIL LR 5.1(B)(2), typeface | Names no face; requires only a plain, roman style. | Face required: none. Vendored substitute: none, so EB Garamond stays (`docs/FONTS.md`, "No face named"). Metric fit: n/a. |
| CDIL LR 7.1(B)(1) | The memorandum identifies the rule under which the motion is filed. | Not checked by the template. The sample's title names "Rules 12(b)(1) and 12(b)(6)". |
| CDIL LR 7.1(B)(4)(a) | Double-spaced memorandum of no more than 15 pages, unless it complies with the type-volume limit. | Not checked by the template (see gap 4). |
| CDIL LR 7.1(B)(4)(b)(1), (c), (d) | Type-volume limit of 7,000 words (headings, footnotes and quotations count); a certificate of compliance stating the count. | `word-count()` counts the body markdown; `certificate()` prints the count when frontmatter `type_volume: true` (see gap 4). |
| CDIL LR 40.1(E)(1) | Caption identifies the division. | `court-title()` line 3 from frontmatter `division`; the template asserts it is present. |
| CDIL LR 5.11(A)(2) | Signatures as "s/name". | `signature-block()` and `certificate()`: "/s/ Name". |
| CDIL LR 11.1 | Telephone number on the paper; typed name below the signature. | Signature lines carry the telephone number and typed name. |
| Fed. R. Civ. P. 12(b)(1), 12(b)(6) | Defenses by motion. | Content of the filing; cited in the sample text and linked for the table of authorities. |

## Layout

- Cover (no page number): court title, caption with ")" marks, the title centered in capitals, and the counsel block in the right half of the page.
- Table of contents (page i) and table of authorities (page ii): generated. The contents come from the body's headings (levels 1 to 3, with dot leaders). The authorities come from the links `[text](toa:key)` in the body, grouped Cases, Constitutional Provisions, Statutes, Regulations, Rules, Other Authorities; a key cited on seven or more pages prints "passim".
- Body (arabic numbers from 1): double-spaced; level 1 headings centered bold capitals; level 2 headings bold with a hanging indent (I., II., A., B.); level 3 headings bold and indented; level 4 bold italic. Footnotes 10-point, single-spaced. Block quotations indented and single-spaced.
- Conclusion and signature block: kept on one page (the conclusion is moved with the signature block).
- Certificate of compliance (only when `type_volume: true`), on its own page.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`; `division` (required, LR 40.1(E)(1)); `caption.parties` (as in the complaint); `brief_title`; `counsel` (list of `{names, lines}`, the cover counsel block); `date`; `type_volume` (bool; prints the certificate); `signature` (`firm` lines, `signer`, `lines` under the "/s/" line); `authorities` (registry of `{kind, name, cite}`: kind is `case`, `constitution`, `statute`, `regulation`, `rule` or `other`; a case name is printed italic; a key appears in the table only if the body links to it).
- Body: `#` level 1, `##` level 2, `###` level 3, `####` level 4. Paragraphs are not numbered. Footnotes: `text[^key]` and `[^key]: text` at any point in the file. Citations: `[*Case v. Name*, 1 U.S. 1, 2 (2000)](toa:key)`; short forms link to the same key.
- Heading numbers ("I.", "A.") are typed in the markdown text. The ca9 contract numbers headings automatically; this template does not, because the numbering rule depends on the parent section and the rendered text should equal the markdown. The filer types the numbers.
- Not supported: tables (the contents and authorities are generated), images, raw typst.
- The word count is computed from the body markdown: link targets, footnote labels and markers are removed; everything else in the body counts.

## Known gaps and open choices

1. **One exemplar; the sample is a portion.** The brief asks for one exemplar per doc type. The filing is a memorandum of 21 text pages by the Attorney General's office for a state defendant. The sample transcribes the cover, introduction, background, legal standard, the opening of each argument point, the conclusion, the signature and the certificate. Point II and Point III are not transcribed past their openings, and the footnote 1 text stops at the point marked ". . . ." in the sample.
2. **Table of contents and authorities page numbers are ours.** They are generated from our render, not transcribed from the filing. The filing's own tables carry the filing's page numbers, which will not match a transcription of part of the filing. The authorities table lists only the authorities the sample cites, so it is shorter than the filed table.
3. **Heading hanging indent.** The number is followed by a space, not a tab, so a wrapped level 2 heading (Points II and III) aligns its second line at 0.5 in, slightly right of the first line's text. Open (tier 2, minor); a tab-aligned heading would need a change to the markdown contract.
4. **Word and page limits are not enforced.** The template's word count is an approximation of the word processor's count and is not the filer's certified count: the sample's certificate reads 1,771 words, which is the count of the transcribed portion, not the filed memorandum's 6,810. LR 7.1(B)(4)(c) lets the certificate rely on the word-processing count, so the filer must confirm the number before filing. The 15-page limit (LR 7.1(B)(4)(a)) is not checked: a memorandum over 15 pages needs the certificate; under 15 pages it does not. The template prints the certificate only when `type_volume: true`.
5. **No certificate of service.** The filing has none (CM/ECF generates notice). The template has no service certificate; whether the court wants one is not established here.
6. **Cover layout.** The cover counsel block sits in the right half of the page, as in the filing. The caption uses ")" marks (the same style as the complaint folder), where the filing uses a block caption. Accepted as the convention for this filing.
7. **Font.** EB Garamond at 12 pt. LR 5.1(B)(2) names no face (see the typeface row above), so the face stays; it looks smaller than the filing's Times New Roman at 12 pt. LR 5.1(B)(2) allows 14 pt; not decided here.
8. **The motion itself and the proposed order** are separate filings and are not produced. Rule 7.1(B)(1) requires the memorandum to identify the rule under which the motion is filed; the template does not check that the title does.
9. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, which this doc-type folder is not, and the brief does not ask for them. Render and overlay were run and the review below is the Gate 2 equivalent for this doc type.
10. **Footnote 1 prints as raw text (open, template defect; not a font issue).** The sample's footnote reference (`[^fn1]`, in the introduction's background section) and its definition (`[^fn1]: ...`, after `# CONCLUSION`) fall on opposite sides of the split at `"\n# CONCLUSION\n"` in `typst/ilcd-motion-brief.typ` (the conclusion and signature block are rendered as a second `cmarker.render` call). The reference renders as the literal text `[^fn1]` on body page 2 and the footnote is not printed. Fix: render the footnote definitions with the part that holds the reference, or move them ahead of the split. Not fixed in the fonts pass.

## Review of the rendered pages (final state)

The page column is the PDF page, with the body page number in parentheses where the page is in the body.

| PDF page | Finding | Verdict |
|---|---|---|
| 1 (cover) | Court title, division, caption with one ")" per line of each wrapped name, case number at right, title in two lines, counsel block at the right half. | pass (gap 6 accepted) |
| 2 (contents, i) | Level 1 to 3 entries with dot leaders and page numbers; wrapped level 2 entries align under the text. | pass |
| 3 (authorities, ii) | Cases (italic names), Constitutional Provisions, Statutes; page references come from the body's links ("2, 4" for the statute cited on body pages 2 and 4). | pass |
| 4 (body 1) | INTRODUCTION and the start of BACKGROUND A; double-spaced paragraphs, no overlap at paragraph breaks. | pass |
| 5 (body 2) | Rest of A. Legal Background; the footnote 1 reference prints as raw `[^fn1]` and no footnote text is printed (gap 10); B. Procedural History. | OPEN (gap 10) |
| 6 (body 3) | LEGAL STANDARD; ARGUMENT and the start of Point I. | pass |
| 7 (body 4) | Rest of Point I; Point II heading with hanging indent and its opening paragraph. | OPEN (minor, gap 3) |
| 8 (body 5) | Point III heading with hanging indent (gap 3); CONCLUSION; "Dated" line, "Respectfully submitted," firm, "/s/" name and typed block, on one page. | pass (gap 3 applies) |
| 9 (body 6) | CERTIFICATE OF COMPLIANCE; the count statement (gap 4: the transcribed portion's count); "/s/" name and typed name. | pass (gap 4 applies) |

The overlay (`OVERLAY-ives-memorandum.txt`) pairs our pages 1 to 9 with the filed pages 1, 2, 4, 7, 8, 11, 16, 27, 28 at 35% to 90% word overlap. The filed pages are not the same portion of the memorandum as our pages, and the table of authorities and contents pages are generated, so the overlay is a diagnostic, not a score.

## Engines

**docx** (`docx/`): `docx/build-reference.sh` builds `docx/reference.docx` from pandoc's default reference; `docx/ilcd.lua` lays out the cover, caption, contents and authorities, the body, the signature block and the certificate of compliance, in three sections (cover without a page number; contents and authorities in roman numerals; body and certificate in arabic from 1). Built by `sh tools/render.sh --engine docx <this folder> usage/INPUT-motion-brief.md`, which writes `usage/OUTPUT-motion-brief.docx`.

- Matches the typst form: EB Garamond 12 pt body; exact 24 pt (double) line pitch; 0.5 in first-line indent; letter paper, 1 in margins; the three numbering sections; level 1 to 4 heading styles (centered caps; bold hanging indents for levels 2 and 3; bold italic for level 4); single-spaced, indented block quotations; footnotes 10 pt single; the counsel block at 3.25 in; "Dated" and "Respectfully submitted," on one line; the conclusion kept with the signature block (keep-with-next). The certificate's word count is the typst count of the body markdown (1771 for this sample, the same figure as the typst render).
- Differs or unverified: the footer's section references use the relationship id `rId9` that pandoc 3.6.4 gives the footer part in this reference (checked on the output; a different pandoc may renumber it, which would break the section footers, so re-check after a pandoc change). The caption's ")" marks are one per caption line as written, not one per wrapped line (BLOCKED, see below). The keep-with-next chain for the conclusion is set but not verified by a render. Footnote 1 prints its text in this engine (the typst gap 10 does not apply here). EB Garamond must be installed on the machine that opens the file.
- BLOCKED, table of contents: `TOC \o "1-4" \h` is a field with placeholder text. Its page numbers appear only after a field update in Word or LibreOffice, and the body page numbers are not computed by the filter. The contents page is not checked against the typst page numbers.
- BLOCKED, table of authorities: the authorities the body cites are listed by group, without page numbers (no TA/TOA fields; LibreOffice does not honor them the way Word does). A page-reference table needs a second pass or a field update.
- BLOCKED, caption: one ")" per caption line as written. The party names here wrap onto several lines in the typst grid, and the docx shows one ")" for the long name (the docx cannot count wrapped lines).
- BLOCKED, docx.pdf not produced (`soffice` is not installed on this box; Gates 0 and 1 measure the LibreOffice PDF). No page was rendered or reviewed (pages reviewed: 0). The `.docx` was validated only as a zip with well-formed XML parts; it has not been opened in Word or LibreOffice.
