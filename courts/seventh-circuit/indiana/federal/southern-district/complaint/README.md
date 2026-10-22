# insd: complaint

Doc type: **complaint** in the United States District Court for the Southern District of Indiana (`insd`).
Folder: `courts/seventh-circuit/indiana/federal/southern-district/complaint/` (self-contained; the court-root `typst/` and `usage/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes, 2 filers: `usage/FILED-EXAMPLE-complaint.pdf` (primary, used for the overlay) and `usage/FILED-EXAMPLE-complaint-2.pdf` (second filer, structure only). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-complaint.md` (caption, parties, jurisdiction, about 49 numbered paragraphs, the coverage section, the prayer and signature; see "Known gaps") |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 9 pages (the docx render too), typst 0.15.0, vendored Times New Roman only, no warnings |
| overlay | ok: `usage/OVERLAY-lightning-rod-complaint.pdf` and `OVERLAY-lightning-rod-complaint.txt` (run as `sh tools/overlay.sh <this-dir> lightning-rod-complaint <exemplar>`) |
| pages reviewed | 9 of 9, typst and docx (every page rendered at 50 dpi and viewed; fb-595.68.28) |

## Governing rules

| Rule | Requirement | Where in the template |
|---|---|---|
| S.D. Ind. L.R. 5-1(b) | Typewritten or printed; at least 1-inch margins; at least 12-point type in the body (10-point in footnotes); double spaced except headings, footnotes and quoted material; consecutively numbered pages; a title on the first page; the filer's name, complete address, telephone and e-mail "where available". | `margin = 1in`, `type-size = 12pt`, `body-leading` (double spacing), `headings` and `chunk()` for quotes, page footer, `cover()` title, `signature-block()`. |
| S.D. Ind. L.R. 5-1(c) | Electronic filings: PDF converted directly from a word processor, each file under 35 MB. | Output of the typst render. |
| Fed. R. Civ. P. 10(a) | Caption with the court name, the title of the action, and the file number. | `court` and `caption` frontmatter. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `numbered = true`; paragraphs are numbered in the template (the sample carries no numbers). |
| Fed. R. Civ. P. 8(a) | Short and plain statement of jurisdiction, claim and demand for relief. | Content only (the sample's jurisdiction paragraphs and "REQUEST FOR RELIEF"). The template does not check it. |

Rule text: L.R. 5-1 was fetched 2026-10-14 from the court's PDF, https://www.insd.uscourts.gov/sites/insd/files/local_rules/Local%20Rule%205-1%20-%20Format%20of%20Documents%20Presented%20for%20Filing_5.pdf (the PDF carries no revision date). The Fed. R. Civ. P. 8 and 10 text was not fetched in this pass; the rule numbers are cited from the rules themselves and should be checked before being relied on.

Not produced by this template: the civil cover sheet, the Rule 7.1 disclosure statement, the summons, and any S.D. Ind. filing that is required with a first filing. None was checked against the local rules in this pass.

## Layout

- Court title centered at the top (three lines), then the caption: parties on the left, a column of ")" marks, the case number on the right. Single spaced.
- Title of the paper in bold caps centered below the caption (L.R. 5-1(b) "title on the first page"); "JURY TRIAL DEMANDED" appears under it when `jury_demand: true`.
- Body double spaced in exact 24 pt line boxes (`pitch-body`; single lines 13.8 pt) on the shared cross-engine layout model (`lib/typst/xengine.typ`); 16.1 pt below every paragraph, list item, heading and quotation.
- Numbered paragraphs 1, 2, ...: the number in a 0.5 in box after the 0.5 in indent, the text from 1 in; paragraphs before the first heading (the lead-in) are not numbered. Paragraphs that begin "WHEREFORE" are not numbered.
- Headings: `#` is centered bold caps; `###` is bold, left. Block quotes are single spaced and indented 0.5 in on both sides.
- Prayer items are a markdown numbered list (rendered "1.", "2.", ... at the 0.5 in indent, the text hanging at 1 in).
- Signature block: date line, then (indented 3.25 in) the firm, the "/s/" line, the signer, and the contact lines; the last chunk of the body is kept with it.
- Footer: page number, centered, consecutive from page 1.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: `#` heading (centered bold caps), `##` (centered bold), `###` (bold, left), a numbered or bulleted list, a `>` block quote, or a paragraph (numbered in the complaint).
- Frontmatter: `court` (list of lines), `caption.left` and `caption.right` (lists of lines; the ")" column is drawn to the longer one), `title`, `jury_demand`, `signature.date`, `signature.lines` (list of lines; "" for a blank line), and `omitted` (free text; ignored by the template, used to record what the sample leaves out).
- Do not put paragraph numbers in the text; the template numbers them. Escape a heading that starts with a number as `### 1\. Title`.
- Not supported: tables, footnotes, raw typst.

## Known gaps and open choices

1. **Sample length.** The exemplar is 17 pages. The sample renders to 9 pages: it carries the caption, paragraphs 1 to 49 (the parties, jurisdiction, facts, the coverage section), the prayer and the signature. Paragraphs 60 to 68 (the exclusions and the remaining definitions) are not transcribed (see `omitted` in the frontmatter). The brief asked for 8 to 14 pages; the shortfall is the untranscribed part of the filing, not the template.
2. **Signature block.** Kept whole and kept with the last chunk of the body (here the last prayer item), so it never stands alone on a page.
3. **E-mail address.** The Lightning Rod signature block has no e-mail address. L.R. 5-1(b) asks for the e-mail "where available", so the template does not require one; the sample follows the exemplar.
4. **Font.** L.R. 5-1(b) sets a 12-point minimum and no typeface. Times New Roman 12 pt (vendored), the house standard (`docs/FONTS.md`), in typst and docx alike; the exemplar is Times New Roman too.
5. **Numbering.** The sample's paragraphs are numbered 1 to 49 by the template. The filed paragraph numbers are not reproduced in full (the exemplar has 68+ paragraphs, and the transcribed paragraphs are numbered in the order they appear).
6. **Overlay pairing.** The overlay pairs each sample page with the filed page that shares the most words. Pages 5 to 7 of the sample pair with exemplar pages 7, 10 and 17 respectively, because the sample skips paragraphs. The overlay is a diagnostic, not a score; its PNG pages were not viewed individually.
7. **Second exemplar.** The Cook complaint (exemplar 2) is kept for structure only: it has the ")" caption, counts and a "DEMAND FOR JURY TRIAL" heading. It is not transcribed, because its content (the death of a minor) is not needed to test the template.
8. **Caption wording.** The Cook exemplar uses "JURY TRIAL DEMAND" in the caption; the Lightning Rod exemplar does not. The template supports both (`jury_demand`).
9. **Engines.** typst and docx (see Engines); no latex engine for this doc type.
10. **Gates.** `sh tools/check.sh <this folder>` and `--engine docx` both exit 0 (typst 9, docx 13 checks passed, 0 failed; fb-595.68.28).
11. **File names.** The brief asked for `usage/<id>.md`, `usage/<id>.pdf` and `<id>-overlay.pdf`. The shared tools (`render.sh`, `overlay.sh`) use `INPUT-<id>.md`, `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, so the files follow the tools' names.

## Review of the rendered pages (OUTPUT-complaint.typst.pdf and OUTPUT-complaint.docx.pdf)

Every page of both renders viewed (fb-595.68.28); the docx breaks every line and page as typst does (XENG-001..003).

- Page 1: court title on three lines; caption with a ")" column and the case number; title centered; the lead-in (unnumbered); THE PARTIES; paragraphs 1 to 3. Pass.
- Page 2: paragraphs 4 to 11; "JURISDICTION AND VENUE" centered bold. Pass.
- Page 3: paragraphs 12 to 19; "FACTUAL BACKGROUND". Pass.
- Page 4: paragraphs 20 to 27. Pass.
- Page 5: paragraphs 28 to 33. Pass.
- Page 6: paragraphs 34 to 39; "THE INSURANCE CONTRACT"; the policy quotation and the first definition, single spaced and indented 0.5 in each side. Pass.
- Page 7: the second definition; paragraphs 40 to 46. Pass.
- Page 8: paragraphs 47 to 49; "REQUEST FOR RELIEF"; the unnumbered WHEREFORE paragraph; prayer items 1 to 3. Pass.
- Page 9: prayer item 4, kept with the date line and signature block. Pass.

## Engines

Typst is the primary engine. The docx engine (`docx/`): `reference.xml` holds the Word styles (`base="xengine"` in the typst face `{font}`, Times New Roman 12 pt, 480-twip body and 276-twip single line boxes, the 12 pt page-number footer 0.5 in above the page edge; `fb render` builds the reference document from it), and `insd.lua` reads the sample's body chunk by chunk as the typst template does and writes every paragraph as WordprocessingML on `lib/docx/xengine.lua` (the frontmatter read as written, `$FORMBOOK_META`, so the caption keeps its leading spaces). No script: `fb render` runs pandoc with the filter and packs the archive (fb-595.68.28; were `build-reference.sh` and a committed `reference.docx` naming EB Garamond, which failed DEF-FONT-002).

- Cross-engine (fb-595.68.28): typst and docx share the layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`). `sh tools/check.sh <this folder> --engine docx`: XENG-001..003 PASS (9 = 9 pages, every line breaks after the same word); `params.cross_engine: gate` in `eval.yaml`. typst 9 and docx 13 checks passed, 0 failed.
- The `.docx` converts in LibreOffice without error (the check's conversion); not opened in Word.
