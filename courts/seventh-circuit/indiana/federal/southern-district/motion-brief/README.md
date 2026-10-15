# insd: motion-brief

Doc type: **brief in support of a Rule 12 motion** (a motion to dismiss with its memorandum, or a partial motion with a Rule 12(e) request) in the United States District Court for the Southern District of Indiana (`insd`).
Folder: `courts/seventh-circuit/indiana/federal/southern-district/motion-brief/` (self-contained; the court-root `typst/` and `samples/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes, 2 filers: `exemplars/FILED-EXAMPLE-uindy-1-26-cv-01669-motion-brief.pdf` (primary, used for the overlay; IU's partial motion and Rule 12(e) brief) and `exemplars/FILED-EXAMPLE-midwest-renewable-1-26-cv-00632-motion-brief.pdf` (second filer, state commissioners' motion to dismiss memorandum). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-uindy-motion-brief.md` (the whole brief: introduction, discussion A to C, conclusion, signature). Footnote 1 is not transcribed. |
| render | ok: `samples/OUTPUT-uindy-motion-brief.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-uindy-motion-brief.pdf` and `OVERLAY-uindy-motion-brief.txt` (run as `sh tools/overlay.sh <this-dir> uindy-motion-brief <exemplar>`) |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed after the last template change) |

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
- Body double spaced (24 pt pitch at 12 pt), first-line indent 0.5 in, paragraphs separated by one line pitch.
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
5. **Font.** As for the complaint: EB Garamond is the only vendored font, and it looks smaller than Times at 12 pt. This is a question for David.
6. **Caption judge initials.** The ECF header of the primary exemplar reads JRO-MKK while its caption reads JPH-MKK. The sample follows the caption (JPH-MKK). The template takes the case number from the sample.
7. **Second exemplar.** The Midwest Renewable memorandum (exemplar 2) is kept for the tier-2 comparison; it is not transcribed. Its caption uses a ")" column and a "No." case-number format, which the template's caption does not change.
8. **Engines.** Typst only.
9. **Gates not run.** As for the complaint: `tools/check.sh` expects a court folder with `court.json` and `rules.md`.
10. **File names.** As for the complaint: `INPUT-`, `OUTPUT-`, `OVERLAY-` names, as the shared tools use.

## Review of the rendered pages (OUTPUT-uindy-motion-brief.pdf)

- Page 1: court title on three lines; caption; title centered; INTRODUCTION heading; the opening paragraphs. Pass.
- Page 2: the third and fourth paragraphs of the introduction; the "Separately" paragraph; the DISCUSSION heading moved to page 3 (no heading at the foot of a page). Pass.
- Page 3: DISCUSSION heading; A. heading; the Eleventh Amendment paragraphs; B. heading at the foot. Pass.
- Page 4: B. continued; C. heading; "1. Legal Standard" heading; the Rule 12(e) paragraphs. Pass.
- Page 5: C.2 heading (two lines, bold, left); the "UINDY Marks" paragraphs. Pass.
- Page 6: the Allison paragraph; C.3 heading; the infringement paragraphs. Pass.
- Page 7: C.4 heading; the common-law paragraphs; CONCLUSION; items (a) and (b). Pass.
- Page 8: items (c) and (d); date line; signature block. Pass.

## Engines

Typst is the primary engine. The DOCX engine (`docx/`: `build-reference.sh`, `reference.docx`, `insd.lua`) is built and validated; it is not visually checked.

- **Matches the typst form (by construction, not by page review):** EB Garamond 12 pt body; exact 24 pt (double) line pitch with one line between paragraphs; 0.5 in first-line indent on every body paragraph (paragraphs are not numbered); 1 in margins on letter paper; centered bold headings (Heading 1) and left bold headings (Heading 3); single-spaced block quotes indented 0.5 in on both sides; single-spaced caption, court lines, title and signature block (signature indented 3.25 in); centered PAGE footer from page 1.
- **Differs or unverified:** footnotes are 10 pt single spaced (L.R. 5-1(b)); the typst template has no footnote handling and the sample has none. The lettered conclusion items "(a)" to "(d)" are plain paragraphs, as in typst. The caption table's cell borders are off (none); the caption lines keep their leading spaces as written in the frontmatter. The signature block is kept together with keep-with-next, which approximates `breakable: false`.
- **Fonts:** EB Garamond is not installed by the build; the machine that opens the file must have it (vendored in `fonts/`).
- **BLOCKED:** `samples/OUTPUT-uindy-motion-brief.docx.pdf` is not produced (LibreOffice `soffice` is not installed on this box, so `tools/render-docx.sh` stops at the conversion step after writing and validating the `.docx`). No page has been rendered or reviewed for the docx engine (0 pages). The cover and caption table borders are not verified against the typst layout. Gate 0 and 1 for docx are not run.
- **Build:** `sh docx/build-reference.sh docx/reference.docx`, then `sh tools/render.sh --engine docx <this-dir> samples/INPUT-uindy-motion-brief.md`.
