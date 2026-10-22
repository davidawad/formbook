# insd: motion-brief

Doc type: **brief in support of a Rule 12 motion** (a motion to dismiss with its memorandum, or a partial motion with a Rule 12(e) request) in the United States District Court for the Southern District of Indiana (`insd`).
Folder: `courts/seventh-circuit/indiana/federal/southern-district/motion-brief/` (self-contained; the court-root `typst/` and `usage/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes, 2 filers: `usage/FILED-EXAMPLE-motion-brief.pdf` (primary, used for the overlay; IU's partial motion and Rule 12(e) brief) and `usage/FILED-EXAMPLE-motion-brief-2.pdf` (second filer, state commissioners' motion to dismiss memorandum). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md` (the whole brief: introduction, discussion A to C, conclusion, signature). Footnote 1 is not transcribed. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 8 pages, typst 0.15.0, vendored Times New Roman only, no warnings (re-rendered 2026-10-22, fb-595.68.28); docx `usage/OUTPUT-motion-brief.docx` and `.docx.pdf`, 8 pages |
| overlay | ok: `usage/OVERLAY-uindy-motion-brief.pdf` and `OVERLAY-uindy-motion-brief.txt` (run as `sh tools/overlay.sh <this-dir> uindy-motion-brief <exemplar>`) |
| pages reviewed | 8 of 8, typst and docx (every page rendered at 50 dpi and viewed on the 2026-10-22 build) |

## Governing rules

| Rule | Requirement | Where in the template |
|---|---|---|
| S.D. Ind. L.R. 5-1(b) | As for the complaint: typewritten; 1-inch margins; 12-point body (10-point footnotes); double spaced except headings, footnotes and quotations; consecutively numbered pages; title on the first page; filer's name, address, telephone and e-mail (where available). | `margin = 1in`, `type-size = 12pt`, `body-leading`, `heading()`, page footer, `cover()`, `signature-block()`. |
| S.D. Ind. L.R. 7-1(a) | Motions are filed separately; a motion may not be contained within a brief. | Not a template issue: this folder produces the brief only. The motion itself is not produced (see gaps). |
| S.D. Ind. L.R. 7-1(b)(1) | A motion under Fed. R. Civ. P. 12 must be accompanied by a supporting brief. | The brief is the product of this folder. |
| S.D. Ind. L.R. 7-1(e)(1) | Supporting and response briefs (excluding tables of contents, tables of authorities, appendices and certificates of service) may not exceed 30 pages; reply briefs 15. Amended July 1, 2024. | Not enforced by the template (see gaps). The sample is 8 pages. |
| S.D. Ind. L.R. 7-1(e)(3) | Only if the court allows a brief over 30 pages: a table of contents with page references, a statement of issues, and a table of authorities. | Not implemented; not needed under the limit. |
| Fed. R. Civ. P. 12(b), 12(e) | Motion grounds; a more definite statement for a pleading that is too vague to respond to. | Content only. |

Rule text: L.R. 5-1 and L.R. 7-1 were fetched 2026-10-14 from the court's PDFs: https://www.insd.uscourts.gov/sites/insd/files/local_rules/Local%20Rule%205-1%20-%20Format%20of%20Documents%20Presented%20for%20Filing_5.pdf and https://www.insd.uscourts.gov/sites/insd/files/local_rules/Local%20Rule%207-1%20-%20Motion%20Practice_2.pdf. The PDFs carry no revision date; the 7-1 PDF says it was amended July 1, 2024. The court's local-rules index page links the rules as separate PDFs and says the complete rules PDF is labeled "Local Rules 7-1-26".

Not verified in this pass: the certificate-of-service requirement for a CM/ECF filing (Fed. R. Civ. P. 5(d)(1)(B)); neither exemplar carries one, and the template has no certificate section.

## Layout

- Court title centered at the top (three lines), then the caption (parties on the left, a ")" column, the case number on the right), single spaced.
- Title of the paper in bold caps centered below the caption.
- Body double spaced: exact 24 pt line boxes at 12 pt on the shared cross-engine model (`lib/typst/xengine.typ`), first-line indent 0.5 in, paragraphs on the same pitch with no space of their own. Headings single-spaced (13.8 pt lines), 12 pt above, none below.
- Headings: `#` centered bold caps (INTRODUCTION, DISCUSSION, CONCLUSION); `###` bold, left (A., B., C.; the numbered sub-headings are escaped `### 1\.`).
- Paragraphs are not numbered (Fed. R. Civ. P. 10 does not apply to briefs). `numbered = false` in `insd-motion-brief.typ`.
- Lettered conclusion items are plain paragraphs starting "(a)" in the sample.
- Signature block: date line, then (indented 3.25 in) "Respectfully submitted," the "/s/" line, the signers, the firm, the address, the e-mail and the telephone.
- Footer: page number, centered, consecutive from page 1.

## Markdown contract (for samples)

As for the complaint (`../complaint/README.md`), with these differences: `numbered` is false; `jury_demand` is not used; the signature has no `counsel` block (the lines are the whole block).

## Known gaps and open choices

1. **Page limit not enforced.** L.R. 7-1(e)(1) caps a supporting brief at 30 pages. The template does not count pages; the sample is 8 pages. A future brief over 30 pages would need the L.R. 7-1(e)(3) contents (TOC, statement of issues, TOA), which the template does not produce.
2. **Footnotes not implemented.** L.R. 5-1(b) allows 10-point footnotes. The exemplar's footnote 1 is not transcribed, so the template's footnote handling is untested.
3. **No certificate of service.** Neither exemplar carries one; the template has no section for it.
4. **Motion not produced.** L.R. 7-1(a) requires the motion to be a separate filing. This folder produces the brief only; a motion template is not in this pass.
5. **Font.** No S.D. Ind. rule names a face (L.R. 5-1(b) sets the 12-point minimum); Times New Roman (vendored), the house standard (`docs/FONTS.md`), in typst and docx alike.
6. **Caption judge initials.** The ECF header of the primary exemplar reads JRO-MKK while its caption reads JPH-MKK. The sample follows the caption (JPH-MKK). The template takes the case number from the sample.
7. **Second exemplar.** The Midwest Renewable memorandum (exemplar 2) is kept for the tier-2 comparison; it is not transcribed. Its caption uses a ")" column and a "No." case-number format, which the template's caption does not change.
8. **Engines.** Typst only.
9. **Gates.** Since fb-595.68.28: `sh tools/check.sh <this folder>` and `--engine docx` both exit 0 (typst 9, docx 13 checks passed, 0 failed).
10. **File names.** As for the complaint: `INPUT-`, `OUTPUT-`, `OVERLAY-` names, as the shared tools use.

## Review of the rendered pages (OUTPUT-motion-brief.typst.pdf and .docx.pdf, 2026-10-22, fb-595.68.28; the docx breaks every line and page as typst does, XENG-001..003)

- Page 1: court title on three lines; caption; title centered; INTRODUCTION heading; the opening paragraphs. Pass.
- Page 2: the "Second" to "Separately" paragraphs of the introduction; the DISCUSSION heading moved to page 3 (no heading at the foot of a page). Pass.
- Page 3: DISCUSSION heading; A. heading; the Eleventh Amendment paragraphs; B. heading kept with its text on page 4. Pass.
- Page 4: B. heading and text; C. heading; "1. Legal Standard" heading; the Rule 12(e) paragraphs. Pass.
- Page 5: the trademark-cases paragraph; C.2 heading (two lines, bold, left); the "UINDY Marks" paragraphs. Pass.
- Page 6: the Allison paragraph; C.3 heading; the infringement paragraphs. Pass.
- Page 7: C.4 heading; the common-law paragraphs (the "§§ 26:1–26:19" citation kept whole on one line). Pass.
- Page 8: CONCLUSION; items (a) to (d); date line; signature block. Pass.

## Engines

Typst is the primary engine. DOCX (`docx/`): `reference.xml` (the Word styles: `base="xengine"` in the typst face `{font}`, Times New Roman, 12 pt, 480-twip body and 276-twip single line boxes, the 12 pt page-number footer 0.5 in above the page edge; `fb render` builds the reference document from it) and `insd.lua` (reads the sample's body chunk by chunk as the typst template does, and the frontmatter as written from `$FORMBOOK_META`, so the caption keeps its leading spaces; writes the court title, the caption with its ")" column, the title, headings, paragraphs, lists, quotations and the signature as WordprocessingML on `lib/docx/xengine.lua`). No script: `fb render` runs pandoc with the filter and packs the archive (fb-595.68.28; were `build-reference.sh` and a committed `reference.docx` naming EB Garamond and Aptos, which failed DEF-FONT-002).

- Cross-engine (fb-595.68.28): typst and docx share the layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`). `check.sh --engine docx`: XENG-001..003 PASS (8 = 8 pages, 221/221 lines break after the same word); `params.cross_engine: gate` in `eval.yaml`. A sign's number is not broken in either engine (typst boxes "§§ 26:1–26:19"; the docx puts a word joiner after the dash).
- Footnotes: the typst template has no footnote handling and the sample has none (L.R. 5-1(b) would ask 10 pt).
- The `.docx` converts in LibreOffice without error (the check's conversion); not opened in Word.
