# insd: complaint

Doc type: **complaint** in the United States District Court for the Southern District of Indiana (`insd`).
Folder: `courts/seventh-circuit/indiana/federal/southern-district/complaint/` (self-contained; the court-root `typst/` and `samples/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes, 2 filers: `exemplars/FILED-EXAMPLE-lightning-rod-1-26-cv-00830-complaint.pdf` (primary, used for the overlay) and `exemplars/FILED-EXAMPLE-cook-1-26-cv-00315-complaint.pdf` (second filer, structure only). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-lightning-rod-complaint.md` (caption, parties, jurisdiction, about 49 numbered paragraphs, the coverage section, the prayer and signature; see "Known gaps") |
| render | ok: `samples/OUTPUT-lightning-rod-complaint.pdf`, 7 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-lightning-rod-complaint.pdf` and `OVERLAY-lightning-rod-complaint.txt` (run as `sh tools/overlay.sh <this-dir> lightning-rod-complaint <exemplar>`) |
| pages reviewed | 7 of 7 (every page rendered at 60 dpi and viewed after the last template change) |

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
- Body double spaced (24 pt pitch at 12 pt, from `body-leading = 1.35em`); paragraphs are separated by one line pitch so the text stays on a grid.
- Numbered paragraphs 1, 2, ... with a 0.5 in indent; paragraphs before the first heading (the lead-in) are not numbered. Paragraphs that begin "WHEREFORE" are not numbered.
- Headings: `#` is centered bold caps; `###` is bold, left. Block quotes are single spaced and indented 0.5 in on both sides.
- Prayer items are a markdown numbered list (rendered "1.", "2.", ...).
- Signature block: date line, then (indented 3.25 in) the firm, the "/s/" line, the signer, and the contact lines.
- Footer: page number, centered, consecutive from page 1.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: `#` heading (centered bold caps), `##` (centered bold), `###` (bold, left), a numbered or bulleted list, a `>` block quote, or a paragraph (numbered in the complaint).
- Frontmatter: `court` (list of lines), `caption.left` and `caption.right` (lists of lines; the ")" column is drawn to the longer one), `title`, `jury_demand`, `signature.date`, `signature.lines` (list of lines; "" for a blank line), and `omitted` (free text; ignored by the template, used to record what the sample leaves out).
- Do not put paragraph numbers in the text; the template numbers them. Escape a heading that starts with a number as `### 1\. Title`.
- Not supported: tables, footnotes, raw typst.

## Known gaps and open choices

1. **Sample length.** The exemplar is 17 pages. The sample renders to 7 pages: it carries the caption, paragraphs 1 to 49 (the parties, jurisdiction, facts, the coverage section), the prayer and the signature. Paragraphs 60 to 68 (the exclusions and the remaining definitions) are not transcribed (see `omitted` in the frontmatter). The brief asked for 8 to 14 pages; the shortfall is the untranscribed part of the filing, not the template.
2. **Orphaned signature block.** On the rendered sample, the signature block sits alone on page 7 after the last prayer item on page 6. A clerk would not object, and the block is kept whole (`breakable: false`). A keep-with-previous rule for the last prayer item is not implemented.
3. **E-mail address.** The Lightning Rod signature block has no e-mail address. L.R. 5-1(b) asks for the e-mail "where available", so the template does not require one; the sample follows the exemplar.
4. **Font.** L.R. 5-1(b) sets a 12-point minimum and no typeface. The only vendored font is EB Garamond (`fonts/`), which has a smaller x-height than Times at 12 pt. The text looks smaller than the exemplar. A vendored Times-metric font would remove the difference; that is a question for David.
5. **Numbering.** The sample's paragraphs are numbered 1 to 49 by the template. The filed paragraph numbers are not reproduced in full (the exemplar has 68+ paragraphs, and the transcribed paragraphs are numbered in the order they appear).
6. **Overlay pairing.** The overlay pairs each sample page with the filed page that shares the most words. Pages 5 to 7 of the sample pair with exemplar pages 7, 10 and 17 respectively, because the sample skips paragraphs. The overlay is a diagnostic, not a score; its PNG pages were not viewed individually.
7. **Second exemplar.** The Cook complaint (exemplar 2) is kept for structure only: it has the ")" caption, counts and a "DEMAND FOR JURY TRIAL" heading. It is not transcribed, because its content (the death of a minor) is not needed to test the template.
8. **Caption wording.** The Cook exemplar uses "JURY TRIAL DEMAND" in the caption; the Lightning Rod exemplar does not. The template supports both (`jury_demand`).
9. **Engines.** Typst only. The latex and docx engines are not built for this doc type.
10. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape. The brief forbids editing `tools/` or the court root, so the gates were not run.
11. **File names.** The brief asked for `samples/<id>.md`, `samples/<id>.pdf` and `<id>-overlay.pdf`. The shared tools (`render.sh`, `overlay.sh`) use `INPUT-<id>.md`, `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, so the files follow the tools' names.

## Review of the rendered pages (OUTPUT-lightning-rod-complaint.pdf)

- Page 1: court title on three lines; caption with a ")" column and the case number; title centered; the lead-in (unnumbered); paragraphs 1 to 6. Pass.
- Page 2: paragraphs 7 to 15, "JURISDICTION AND VENUE" and "FACTUAL BACKGROUND" centered bold; no heading at the foot of the page. Pass.
- Page 3: paragraphs 16 to 27. Pass.
- Page 4: paragraphs 28 to 35. Pass.
- Page 5: paragraphs 36 to 43; "THE INSURANCE CONTRACT" heading; the policy quote is single spaced and indented; paragraph numbers continue after the quote. Pass.
- Page 6: paragraphs 44 to 49; "REQUEST FOR RELIEF"; the unnumbered WHEREFORE paragraph; prayer items 1 to 4. Pass.
- Page 7: the date line and signature block only (see gap 2). Pass with the note.
