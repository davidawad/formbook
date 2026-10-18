# S.D. Miss. (mssd): motion brief (memorandum in support of a Rule 12(b) motion)

Doc type: **memorandum brief in support of a motion to dismiss** in the United States District Court for the Southern District of Mississippi (`mssd`). The doc type is the memorandum, which L.U.Civ.R. 7(b)(2) requires as a separate docket item from the motion.
Folder: `courts/fifth-circuit/mississippi/federal/southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (defendant's counsel; see `usage/SOURCE.md`). A second filer is saved too: `usage/FILED-EXAMPLE-motion-brief-2.pdf` (15 pp., not transcribed). |
| sample md | `usage/INPUT-motion-brief.md`: the whole memorandum transcribed (filed as 8 pages, with the certificate of service). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 7 pages, typst 0.15.0 via `tools/render.sh`, vendored EB Garamond only, no typst warnings. |
| overlay | ok: `usage/OVERLAY-bryant-memorandum.pdf` and `usage/OVERLAY-bryant-memorandum.txt` (`tools/overlay.sh`). |
| pages reviewed | 7 of 7 (every page rendered at 60 dpi and viewed; see the review below). |

The file names follow the tools' conventions (`INPUT-`, `OUTPUT-`, `OVERLAY-`), not the `<id>.pdf` / `<id>-overlay.pdf` names in the brief (see the complaint README).

## Governing rules

Sources, fetched 2026-10-14:

- S.D. Miss. Local Uniform Civil Rules, the "2024 Local Civil Rules MSSD MSND" PDF linked from https://www.mssd.uscourts.gov/court-info/local-rules-and-orders/local-rules (`https://www.mssd.uscourts.gov/sites/mssd/files/2024%20Local%20Civil%20Rules%20MSSD%20MSND%20%28.pdf%29.pdf`). Read: L.U.Civ.R. 7(b)(2), (4), (5); 11(a); 38(a) (text in the PDF, pp. 3 to 7 and 23).
- Fed. R. Civ. P. 5(d)(1)(B): https://www.law.cornell.edu/rules/frcp/rule_5 (checked 2026-10-14).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| L.U.Civ.R. 7(b)(2) | The memorandum brief is filed as a separate docket item from the motion; it is not an exhibit. | Scope: the template produces the memorandum only. The motion is not produced (see gaps). |
| L.U.Civ.R. 7(b)(2)(B) | A motion may not exceed four pages and may not contain legal argument or case citations. | Not produced (separate document; gap 1). |
| L.U.Civ.R. 7(b)(4) | The movant's memorandum brief is filed when the motion is served. | Scope only. |
| L.U.Civ.R. 7(b)(5) | Movant's original and rebuttal memoranda together may not exceed 35 pages. | `context` check at the end of `mssd-motion-brief()`: `assert(pages <= 35)`. Tested: a 38-page mutant fails with "the memorandum is 38 pages; L.U.Civ.R. 7(b)(5) allows 35". |
| L.U.Civ.R. 7(b)(5)(A) | 8 1/2 by 11 inch paper; double spaced (quotations may be indented and single spaced; headings and footnotes may be single spaced); margins at least 1 inch on all four sides; page numbers may be in the margins, but no text there. | `margin: 1in`; double spacing (`body-leading`, 27.6 pt pitch); page number centered in the bottom margin. Headings single spaced. |
| L.U.Civ.R. 7(b)(5)(B) | "Either a proportionally spaced or a monospaced face may be used. A proportionally spaced face must include serifs, but sans-serif type may be used in headings and captions." Text 12-point or larger; footnotes 11-point or larger. Names no face. | EB Garamond (serif), kept: the rule names no face, so `docs/FONTS.md` gives the default. 13 pt text; footnotes 12 pt (see gap 2). |
| L.U.Civ.R. 7(b)(5)(C) | Plain roman type, with italics, highlighting or bold for emphasis; case names must be italicized or underlined. | The template renders `*...*` italic. The sample italicizes case names and signals ("*Id.*", "*See e.g.*", "*supra*"); the template does not check it (gap 4). |
| L.U.Civ.R. 11(a) | Every signed filing shows counsel's name, address, telephone, fax number, e-mail and bar membership number. | `signature-block()` asserts `signer`, `bar_no`, `firm`, `address`, `telephone`, `fax`, `email`; a missing key fails the render. |
| L.U.Civ.R. 38(a) | Not applicable to a memorandum (the demand is in the complaint). | None. |
| Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required when a paper is served through the e-filing system. | `certificate` is optional (frontmatter). The exemplar has one (page 7 of the sample), so the sample has one. |
| Fed. R. Civ. P. 12(b)(6), 8(a)(2) | Content of the motion and the memorandum. | Content of the sample only; the template does not check it. |

The local rules say nothing about a table of contents or a table of authorities for a memorandum, and the template produces neither. The exemplar has neither.

## Layout

- Letter paper, 1 inch margins, page number centered at the bottom.
- Court title: three lines, bold caps, centered (`court`). Caption: parties in a left column with "v." between them; "CIVIL ACTION NO." and the case number on the right.
- Title of the paper: bold, underlined, centered caps (`brief_title`).
- Body: double spaced (27.6 pt line pitch, measured against the exemplar, as in the complaint); body paragraphs with a 0.5 inch first-line indent; footnotes single spaced, with a short rule above them.
- Section headings (INTRODUCTION, ARGUMENT, CONCLUSION): bold, underlined, centered caps. Sub-headings (A., B., C., D.): bold, at the left. Headings stay with the paragraph after them.
- Signature block: "Respectfully submitted, this the <date>" at the left, then the firm, address, telephone, "Facsimile:", "s/ <signer>", the signer's name and bar number in caps, and e-mail, on the right half of the page (the exemplar's ECF convention).
- Certificate of service (optional): bold, underlined, centered caps; one paragraph; "s/" signature.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `case_number`; `court` (lines); `caption.parties` (`{names, designation}`); `brief_title`; `signature` (`date` (optional; prints "Respectfully submitted, this the ..."), `signer`, `bar_no`, `firm`, `address` (list), `telephone`, `fax`, `email`); `certificate` (optional: `date`, `signer`, `bar_no`, `text`).
- Body: `#` = section heading (level 1), `##` = sub-heading (level 2); blank-line-separated paragraphs (first-line indent); lists are supported but unused.
- **Footnotes must use numeric labels** (`[^1]`, `[^2]`) and the definition (`[^1]: ...`) anywhere in the body. The template attaches each definition to the paragraph that cites it: cmarker resolves a footnote only when its reference and definition are in the same render call, so a definition on its own is not rendered and a reference without it shows as literal text. (Found while building this sample: named labels such as `[^arena]` were printed as text.)
- Case names in `*...*` (italic). Escape a literal asterisk as `\*`.

## Known gaps and open choices

1. **The motion is not produced.** The four-page motion (L.U.Civ.R. 7(b)(2)(B)) is a separate filing with no argument or citations; this template produces the memorandum only. Its caption title and signature block are the memorandum's own.
2. **Typeface.** The exemplar is Times New Roman, but the rule names no face: L.U.Civ.R. 7(b)(5)(B) allows any proportionally spaced serif face (or a monospaced one), read in the 2024 Local Civil Rules PDF on 2026-10-14. So the template keeps EB Garamond (`fonts/eb-garamond/`), the default `docs/FONTS.md` gives a court that names no face. It is used at 13 pt for the text and 12 pt for footnotes, chosen by eye against the exemplar, not measured. Text is 13 pt (above the 12-point minimum); footnotes are 12 pt (above the 11-point minimum). EB Garamond is not metric-compatible with Times New Roman, so line breaks and page count differ from the filed Times version. If a judge or David wants Times metrics, the substitute is Liberation Serif (`docs/FONTS.md`), a template change, not a rule change.
3. **Fax number.** L.U.Civ.R. 11(a) requires one. The exemplar's counsel block has none, so the sample says `fax: "None"` (printed as "Facsimile: None").
4. **Italics.** L.U.Civ.R. 7(b)(5)(C) requires case names to be italic or underlined. The filing's text layer, read with `pdftohtml -xml` (italic runs marked `<i>`), italicizes only a few spans: "Federal Rules of Civil Procedure", "Favre v. Sharpe", "Twombly", "Cook v. Mardi Gras Casino", "Prescott", "Cook", "See e.g.", and "Federal Rules of Civil Procedure" in the conclusion. Most case names in the filing are roman. The sample italicizes all case names and the signals, as the rule requires, so the sample differs from the filing in italics. The template does not check italics.
5. **Page limit.** The 35-page check counts every page of the document, including the certificate. It is a hard assert, so the authoring rule is enforced at render time.
6. **Signature convention.** The exemplar signs with "s/" (ECF convention) and has no role line ("Attorney for ..."). The template follows the exemplar; the complaint template signs with "/s/" as the complaint exemplar does.
7. **Table of contents and authorities** are not produced: the local rules do not require them for a memorandum (read above), and the exemplar has none.
8. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, which a doc-type folder does not have, and the brief bars editing `tools/`. The checks in this README were done by hand: render (no warnings), overlay, the page review below, and two mutant tests: the 38-page mutant (fails as it should) and the complaint's fax mutant (see the complaint README).
9. **Second exemplar.** `FILED-EXAMPLE-motion-brief-2.pdf` is saved for a tier-2 comparison; the overlay uses the first exemplar (Bryant).
10. **Local rule text.** The local rules PDF is dated 2024 in its name and was read as posted on 2026-10-14; I did not check whether any amendment changes L.U.Civ.R. 7.

## Review of the rendered pages (60 dpi, every page viewed)

- Page 1: court title, caption with the case number on the right, title (bold, underlined), INTRODUCTION heading, paragraphs; footnotes 1 and 2 at the foot of the page, single spaced with a rule above them. Pass.
- Page 2: paragraphs of the introduction; the ARGUMENT heading (centered, bold, underlined); the opening paragraph; sub-heading A ("Standard of Review", bold at the left) with its first paragraph. Pass.
- Page 3: paragraphs under A (Twombly; Bowlby; Lone Star Fund; Favre, Mitchell; Id.) with case names in italic. Pass.
- Page 4: sub-heading B; paragraphs citing Favre, Ferguson, Hustler, Greenbelt, Milkovich. The quotation marks and italics render; "*8-9" with a literal asterisk. Pass.
- Page 5: paragraphs citing Fulton, Perkins, Journal Publishing, S. Health, Garziano. Pass.
- Page 6: paragraphs under B (end) and C (False Light), citing Prescott, Cook, Hays; the page ends with a gap before heading D, which moves to page 7 with its paragraph. Pass.
- Page 7: sub-heading D; paragraphs citing Byrd and Twombly, supra; CONCLUSION; "Respectfully submitted, this the 22nd day of July, 2024"; the signature block on the right half; the CERTIFICATE OF SERVICE heading, its paragraph and the "s/" signature, with no overlap (fixed after the first render, where the heading ran into the signature block). Pass.

Overlay: the overlay pairs each page of our render with the exemplar page that shares the most words. Word overlap runs from 80% (page 7) to 97% (page 3). The overlay is a diagnostic, not a score: the differences are the typeface, the italics (the sample italicizes every case name, the filing only a few), and line wrapping.

## Engines

- **docx** (`docx/reference.docx`, built by `docx/build-reference.sh`; filter `docx/mssd-motion-brief.lua`). Samples: `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (8 pages; typst is 7). Checked by hand: the LibreOffice PDF was viewed page by page (8 of 8) against the typst render (7 of 7). Opened with LibreOffice only: the conversion succeeds and the parts are well-formed XML; Word was not available and was not checked.
- Matches typst: EB Garamond 13 pt text and 12 pt footnotes (embedded in the PDF, no other face), US Letter, 1 in margins, exact 27.6 pt double spacing, 0.5 in first-line indent, single-spaced court title, caption, headings, footnotes and signature block, the caption table, the title in bold underlined caps, section headings centered bold underlined caps, sub-headings bold at the left, native footnotes with a rule above them, the page number centered in the footer, the signature block and the certificate of service.
- Differs, and why: (1) Pagination: LibreOffice puts exact-spacing leading above the text, so a page holds 23 double-spaced lines where typst holds 24; the memorandum runs to 8 pages instead of 7, and the certificate of service starts alone on page 8. Word may differ again. (2) The 35-page limit of L.U.Civ.R. 7(b)(5) is an assert in the typst template only; the docx page count (8) is far below it, and the limit is not checked by a gate for docx. (3) Case-name italics come from the sample's markdown, as in typst.
- BLOCKED: page count (tier 1): docx 8 pages (LibreOffice) vs typst 7. The docx line pitch matches typst; the extra page is not reproduced.
- `tools/check.sh` was not run on this folder: it needs the court's `court.json` and `checks.yaml`, which this doc-type folder does not have.
