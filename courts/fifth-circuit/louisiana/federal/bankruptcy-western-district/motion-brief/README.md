# lawb: motion brief (motion with memorandum)

Doc type: **motion with memorandum** (FRBP 9013; LBR 7007-1 to 7007-3 as applied by LBR 9013-1(a)) in the United States Bankruptcy Court for the Western District of Louisiana (`lawb`). Folder: `courts/fifth-circuit/louisiana/federal/bankruptcy-western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-lawb-motion-brief-newcenturyfabricators1450652.pdf` (1 filer; see `usage/SOURCE.md`). A joinder in a receiver's motion, with its memorandum in the same filing. |
| sample md | `usage/INPUT-lawb-motion-brief-newcentury.md` (the whole filed document, 8 pages, transcribed, nine footnotes) |
| render | ok: `usage/OUTPUT-lawb-motion-brief-newcentury.typst.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-new-century-motion-brief.pdf` and `.txt` |
| pages reviewed | 8 of 8 (every page rendered and looked at after the last template change) |

File names: `tools/render.sh` and `tools/overlay.sh` write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (the tools hard-code these names), so the sample PDF and overlay carry those names rather than `<id>.pdf` and `<id>-overlay.pdf`.

## Governing rules

Verified 2026-10-14.

| Rule | Requirement | Where it lives in the template |
|---|---|---|
| Fed. R. Bankr. P. 9004(a) | Papers must be clearly legible; common English abbreviations are acceptable. Source: https://www.law.cornell.edu/rules/frbp/rule_9004 (as amended Apr. 2, 2024, eff. Dec. 1, 2024). | whole template: 12–13 pt, black on white |
| Fed. R. Bankr. P. 9004(b) | A document presented for filing must have a caption: the court's name, the case's title, the case number, the adversary-proceeding number if any, and a brief designation of the document's character. Same source. | `cover`: court name (fixed in the template), `caption.left` (parties), `caption.right` (case number, chapter, judge), `title` (the document's character) |
| Fed. R. Bankr. P. 9013 | A motion must be made in writing, state its grounds with particularity, and set forth the relief requested. Source: https://www.law.cornell.edu/rules/frbp/rule_9013 (as amended Apr. 2, 2024, eff. Dec. 1, 2024). | the body (author text; the template does not check the grounds) |
| LBR 9013-1(a) | LBR 7007-1 through 7007-3 apply to motion practice. Source: W.D. La. Local Bankruptcy Rules, revised as of April 1, 2026, https://www.lawb.uscourts.gov/sites/lawb/files/Local%20Bankruptcy%20Rules%20Revised%20as%20of%201%20April%202026%20with%20Appendices.pdf (fetched and read 2026-10-14). | the rules below |
| LBR 7007-1(d) | A supporting brief or memorandum is optional unless the court orders otherwise. Same source. | the memorandum is part of this filing; no separate brief is produced |
| LBR 7007-1(g) | The motion sets out, in concise plain terms, the specific relief sought, the party against whom it is sought, and the rule or statute relied on. Same source. | the body and prayer (author text) |
| LBR 7007-2(a) | A brief is printed, typewritten, or in some other legible form. Same source. | whole template |
| LBR 7007-2(c)–(d) | A principal brief may not exceed 30 pages or 13,000 words of non-excluded text. A brief of more than 10 pages must have a table of contents and a table of authorities. Same source. | Not enforced: no word or page counter, and no TOC/TOA generated (see gaps). The filing is 8 pages. |
| LBR 9013-1(b) | Notice of a motion conforms substantially to Official Form 420A: hearing date, time and place; how to get a free copy; the relief sought. Same source. | Not produced: this filing has no notice of hearing (see gaps). |
| LBR 9013-1(d) | A certificate of service on registered and non-registered users, stating the manner of service for each party. Same source. | `certificate` frontmatter: rendered when present. The exemplar has none, so no sample exercises it (see gaps). |
| LBR 5005-1(b) | The signature block includes name, state bar number, address, telephone and email (if applicable) of the signing attorney. Same source. | `signature` frontmatter: lead-in, firm, "By:" line, names with bar numbers, address, telephone, fax, email, `counsel_for` |

Font, margins and spacing: neither the LBRs nor FRBP 9004 sets them (`grep` of the full LBR text finds no typeface, margin or line-spacing rule). The layout follows the exemplar: 1-inch margins, double-spaced body, centered bold caps for the main headings, a boxed caption, EB Garamond (the only typeface vendored in `fonts/`).

The exemplar was filed in 2014 and the rules above are the 2026 text; the sample is a transcription of the 2014 filing, rendered in the 2026-rule template.

## Exemplar

- `usage/SAMPLE-lawb-motion-brief-newcenturyfabricators1450652.pdf`: *In re New Century Fabricators, Inc.*, No. 14-50652 (Chapter 11, Judge Robert Summerhays), "Joinder in Emergency Motion to Dismiss with Memorandum in Support", 8 pages, docket #14, filed 2014-06-03 by FCC, LLC d/b/a First Capital (counsel Gordon, Arata, McCollam, Duplantis & Eagan, LLC). Provenance and searches are in `usage/SOURCE.md`.
- Only one exemplar. EVAL-LOOP's tier-2 rule asks for 2 or 3 filers; see gaps.

## Sample and template

- `usage/INPUT-lawb-motion-brief-newcentury.md`. Its frontmatter carries the caption (`caption.left` as `{t, i}` items, `caption.right` as lines), `title` (lines), and `signature` (`lead`, `firm`, `by`, `lines`, `counsel_for`); the optional `certificate` key is not used by this sample.
- Body: markdown rendered whole. `#` is a level-1 heading (centered bold); `##` is a level-2 heading (bold, underlined, at the left); `1.` lists are lettered (a), (b)…; footnotes are `[^id]` with a definition elsewhere in the body; paragraphs are not numbered (a memorandum, unlike a complaint). Headings are written in caps as filed.
- Transcription: every paragraph, list and footnote of the filing. Not transcribed: the bold-italic defined terms ("First Capital", "Receiver") (plain quotes); case names are italic in the sample by citation convention, because the text layer carries no italics. The "EXHIBIT n" references are bold, as in the filing.
- `typst/lawb-motion-brief.typ` (template) and `typst/main.typ` (entry point). Court name and layout constants are in the template; every case-specific word comes from the frontmatter.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/fifth-circuit/louisiana/federal/bankruptcy-western-district/motion-brief usage/INPUT-lawb-motion-brief-newcentury.md
sh tools/overlay.sh courts/fifth-circuit/louisiana/federal/bankruptcy-western-district/motion-brief new-century-motion-brief
```

- Render: typst compiled with `--ignore-system-fonts` and no warnings. `pdffonts` shows EBGaramond-Regular, -Bold and -Italic only.
- Overlay: red = our render, blue = exemplar, black = both. Pages pair one-to-one by word overlap: ours p.1–8 ↔ filed p.1–8. The overlay is a diagnostic, not a score: the filed copy has a different caption box and a different footer, so text lines will not coincide.

## Visual review (Gate 2 record, 8 of 8 pages, rendered at 50 dpi and looked at)

| Page | Content | Finding |
|---|---|---|
| 1 | Court title, caption box (parties left, case number, chapter, judge right), title, rule, opening paragraph, BACKGROUND, first background paragraphs | OK. |
| 2 | Background: loan agreement, certificates, list (a)–(c); footnotes 1–2 | OK after the spacing fix below. |
| 3 | Background: BlackBriar, CBIZ engagement; CBIZ categories (a)–(e) begin | OK. |
| 4 | CBIZ category (e) ends; findings paragraph; footnotes 3–4 | OK. |
| 5 | "This situation…", "Moreover…", the Receivership Order paragraph, list (a)–(c) begin; footnotes 5–8 | OK. |
| 6 | List (b)–(c); "Copies…"; JOINDER AND SUPPORT heading; the joinder paragraphs; footnote 9 | OK. |
| 7 | The joinder's last paragraphs; PRAYER FOR RELIEF; WHEREFORE paragraph | OK. |
| 8 | Signature block alone (firm, "By:" line, names with bar numbers, address, telephone, fax, email, counsel for First Capital) | Open: the block lands alone on the last page. See gap 2. |

Fixes made during review: paragraphs overprinted each other (typst adds no leading after a paragraph's last line; paragraph spacing now equals the leading); the two headings "JOINDER AND SUPPORT…" and "PRAYER FOR RELIEF" were written as level 2, but the filing centers them, so the sample now marks them level 1; the caption's DEBTOR line indent.

## Engines

Engines for this doc type: typst (primary, `typst/`) and docx (`docx/`). `latex/` is empty.

### docx

- Build: `sh docx/make-reference.sh` writes `docx/reference.docx` (pandoc's default styles, patched to the typst values: EB Garamond 13 pt, body at 26 pt exact, 0.5 in first-line indent, letter page with 1-inch margins, "- n -" page-number footer). `docx/lawb-motion-brief.lua` builds the cover (court name, caption box, title, rule under the title), the signature block and the certificate (when the frontmatter has one), and letters the lists "a.", "b.". Render: `sh tools/render.sh --engine docx courts/fifth-circuit/louisiana/federal/bankruptcy-western-district/motion-brief usage/INPUT-lawb-motion-brief-newcentury.md`, which writes `usage/OUTPUT-lawb-motion-brief-newcentury.docx`.
- Matches the typst template, in the markup: EB Garamond 13 pt throughout; body double-spaced (26 pt lines) with a 0.5 in first-line indent on every body paragraph; caption, signature block and footnotes single-spaced (15 pt); 1-inch margins; letter page; centered bold level-1 headings and bold, underlined level-2 headings at the left, each with a blank double line above and below; the caption box with its rules; the signature block at 2.75 in, kept together; the "- n -" page number centered in the footer.
- Differs, by design or not checked: the list letters are typed text ("a." and a tab), not Word list numbering. The tab stop is fixed at 0.9 in from the margin. The caption box is a Word table with borders, which Word and LibreOffice draw slightly differently. Line and page breaks are the renderer's, so the page count is not known until the PDF is made. The "signature alone on page 8" open item (Known gaps, 2) may or may not reproduce in the docx.
- **BLOCKED: `.docx.pdf` checks (Gates 0 to 3 on the LibreOffice PDF, and the Gate 2 page review).** `soffice` is not installed on the box that built this: conda-forge has no LibreOffice package and there is no root for apt. `tools/render.sh --engine docx` therefore writes the `.docx` and then fails at `soffice`, so `usage/OUTPUT-new-century-motion-brief.docx.pdf` is not produced. Checked so far: the `.docx` is a valid zip, its XML parts are well-formed, and pandoc reads it back with every word of the sample body in order (the typed list letters and the signature block come from the template). Pages reviewed: 0 of the docx's pages, so no visual claim is made for the docx.
- Open for Word: the opening machine needs EB Garamond installed, or Word substitutes a font. The vendored `fonts/` copy is for typst only.

## Known gaps and open choices

1. **One exemplar, and it is a joinder.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers; the brief asks for one per doc type. The filing joins a receiver's motion rather than being a stand-alone motion. Two other W.D. La. memoranda were found: *Global Gaming Legends*, No. 13-01007, doc #116 (a 2013 support brief, 40 pages, only 782 words of text layer) and *Keaty*, No. 05-51007, doc #137 (a 2005 motion with memorandum attached, a scanned image with no text). Neither was used.
2. **Signature block alone on page 8 (open).** The prayer is on page 7; the block needs about 3 inches and page 7 has about 2.8 inches free. Keeping the prayer with its signature is not implemented: it would need a markup for "keep with next" on the prayer paragraph. Open for the reviewer: whether the template should carry that rule, or the sample should be trimmed.
3. **No notice of hearing; no certificate of service.** LBR 9013-1(b) (Official Form 420A) and LBR 9013-1(d) apply to motions. The filing has neither in its 8 pages, so the sample has neither. The template renders a `certificate` block when the frontmatter supplies one; no notice-of-hearing support is built.
4. **No tables of contents or authorities.** LBR 7007-2(d) requires them for a brief of more than 10 pages. This filing is 8 pages. A longer brief would need a generated TOC and TOA; the template does not produce them.
5. **Page and word limits not checked.** LBR 7007-2(c) (30 pages or 13,000 words for a principal brief) is not measured.
6. **Type size.** The filed copy is Times 12 and this render is EB Garamond 13 pt, to match apparent size (the same choice cand's templates make). No LBR or FRBP rule sets a type size; 13 pt is a tier-2 judgment.
7. **Footer and ECF stamp.** The filed copy has a "- n -" page number and an ECF stamp in the footer. The template prints the page number; the ECF stamp is not document text and is not reproduced.
8. **Alignment.** Body text is left-aligned, not justified. The exemplar's justification is not asserted.
9. **Heading styles.** The exemplar's heading styles are read from a text layer that carries no bold or underline markup. The choices here (centered bold caps for the main headings; bold, underlined, left-aligned for sub-headings) are a reading of the page image, not a transcription of markup.
10. **Exemplar vintage.** Filed in 2014; the rules are the 2026 text (see the rules section above). Nothing in the template depends on the 2014 rules.
11. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. The render and overlay commands above are the checks that were run.
