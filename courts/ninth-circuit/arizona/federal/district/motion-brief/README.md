# D. Ariz. (azd): motion with memorandum

Doc type: **motion** (a motion to dismiss, or in the alternative to stay, with its memorandum of points and authorities, one filed document) in the United States District Court for the District of Arizona. Folder: `courts/ninth-circuit/arizona/federal/district/motion-brief/`. The court-root `typst/` and `usage/` of `district/` are not touched.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the whole motion, caption to certificate of service (17 pages, as the exemplar) |
| typeface | face required: **none** (LRCiv 7.1(b)(1) names a size and a pitch, not a face; see Governing rules) → **Times New Roman** (vendored), the house standard (`docs/FONTS.md` rule 6) and the exemplar's face; the docx uses the same face. |
| render | ok (re-rendered 2026-10-15): `usage/OUTPUT-motion-brief.typst.pdf`, 17 pages, typst 0.15.0, `tools/render.sh`, vendored EB Garamond only (`pdffonts`: EBGaramond-Regular, -Bold, -BoldItalic embedded), no warnings, exit 0 (the earlier EB Garamond render, before fb-595.68.21; the committed render is 20 pages in Times New Roman) |
| overlay | **fail** (2026-10-15): `tools/overlay.sh` needs `usage/FILED-EXAMPLE-motion-brief.pdf`, which is not in this snapshot (not in git, not on disk). No `OVERLAY-evancho-mtd.pdf` was produced. `OVERLAY-evancho-mtd.txt` is the earlier page map, not regenerated. |
| pages reviewed | 17 of 17 (re-viewed 2026-10-15 at 60 dpi, every page; no layout change from the render before; on the earlier EB Garamond render) |

File names follow the repo's tools: the sample is `INPUT-<id>.md`, the render `OUTPUT-<id>.pdf`, the overlay `OVERLAY-<id>.pdf/.txt`, because `tools/render.sh` and `tools/overlay.sh` read and write those names by default.

## Governing rules

Primary source: D. Ariz. Local Rules of Civil Procedure, the "Local Rules Master File 2020" PDF at https://www.azd.uscourts.gov/sites/azd/files/local-rules/Local_Rules_Master_File_2020.pdf, read 2026-10-14. **The current text was not verified:** courtrules.net and the court's current rules pages returned HTTP 403, so the 2020 file is the newest copy reachable. Check LRCiv 7.1, 7.2, and 12.1 against the current local rules before the template is treated as final. Quotations below are from the 2020 file.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LRCiv 7.1(a)(1) | Attorney name, address, e-mail, State Bar number, telephone, and the party represented, typed in the space left of center beginning at line 1. | `counsel` frontmatter; `counsel-block()` lines 1 to 5 minimum. |
| LRCiv 7.1(a)(2) | "The title of the Court must begin on or below line six (6) of the first page." | `counsel-lines = 5`; the court title is on line 6 or lower (sample: line 7). |
| LRCiv 7.1(a)(3) | Party names in upper and lower case; right of center: (A) the case number, (B) a brief description of the paper, including "demand for trial by jury if made", (C) mention of any notice of motion or memorandum in support. | `caption()`: `case_number`, `brief_title` (the sample's title says "Motion to Dismiss ... Motion to Stay"; the memorandum is mentioned in the notice paragraph, see gap 4). |
| LRCiv 7.1(b)(1) | Double-spaced body, no more than 28 lines per page; footnotes and indented quotations may be single-spaced. | `pitch = 24pt`, `lines-per-page = 28`; every body chunk is a block with a gap of one `body-leading` below it, so each chunk is a whole number of numbered lines (measured with `pdftotext -bbox-layout`: 24.0 pt between lines on pages 2 and 3, the pages with the most text). |
| LRCiv 7.1(b)(1) | Fixed pitch of 10 or proportional font of at least 13 point, "including any footnotes". | `type-size = 13pt`, `font-family = ("Times New Roman", "Liberation Serif")`. No footnotes in the sample. |
| LRCiv 7.1(b)(1) | Pages numbered; left margin not less than 1 1/2 inches; right margin not less than 1/2 inch. | `page-number-block()` centred in the bottom margin; `left-margin = 1.5in`, `right-margin = 0.75in`. |
| LRCiv 7.1(b)(1) | Letter size, signed under Rule 11. | Letter; `signature-block()` ("DATED:" line, firm, "By: /s/" and signer lines). |
| LRCiv 7.2(b) | The moving party files a memorandum setting out the points and authorities with the motion. | Structure of the sample: the notice paragraph, then `MEMORANDUM OF POINTS AND AUTHORITIES` (level 1 heading) and the memorandum's numbered headings. |
| LRCiv 7.2(e)(1) | "[A] motion including its supporting memorandum ... may not exceed seventeen (17) pages, exclusive of attachments and any required statement of facts." | Not counted by the template (gap 3). The sample is 17 pages with the caption, signature and certificate, which is the exemplar's length. |
| LRCiv 12.1(c) | A Rule 12(b)(6) motion "will [not] be considered or decided unless the moving party includes a certification that, before filing the motion, the movant notified the opposing party of the issues asserted in the motion and the parties were unable to agree that the pleading was curable". | Optional `certification` frontmatter (heading and text), rendered before the signature. The exemplar has none, so the sample has none (gap 5). Tested with a temporary sample; the test file was deleted. |
| Fed. R. Civ. P. 12(b)(6) | "failure to state a claim upon which relief can be granted" is a defense that may be raised by motion. Fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_12. | The motion's title and the Rule 12(b)(6) argument (author content). |

## Layout

- Numbered lines 1 to 28 down the left margin, a double rule at the text's left edge and a single rule at its right (the pleading form; the exemplar and the local rules' Appendix C use it).
- Cover: counsel from line 1; court title on lines 7 and 8 (sample); caption box with the parties on the left, the case number, title and judge on the right.
- Headings: level 1 is centred, bold, capitals, unnumbered (`MEMORANDUM OF POINTS AND AUTHORITIES`). Levels 2 to 5 are numbered by the template (I., A., 1., a.), bold (level 5 bold italic), and hang from the margin. Each heading is one whole number of lines (`on-grid`) and is kept with the text after it.
- Body paragraphs: first-line indent of 0.5 inch (an explicit `h()`, because typst does not indent the first paragraph inside a block).
- Running header from page 2: case number, short title and judge, in 10 pt in the top margin (the exemplar's convention, not a rule requirement; gap 6).

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1 unnumbered centred caps), `##` to `#####` headings (numbered by the template, so do not type the numbers), or a paragraph (unnumbered; first-line indent is added).
- Frontmatter fields: `case_number`, `judge`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `running_header` (lines, pages 2 on), `counsel` (lines, from line 1), `lead_in` (the notice paragraph, unnumbered, optional), `date` (after "DATED:"), `signature` (`firm` lines, `signer`, `lines`), `certificate` (optional: `heading`, `text`, `service` lines, `signer`), `certification` (optional, LRCiv 12.1(c): `heading`, `text`).
- Not supported: tables, footnotes (none in this sample), raw typst. Italics (`*...*`) are supported by the markdown contract but were not transcribed (gap 7).

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/ninth-circuit/arizona/federal/district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/ninth-circuit/arizona/federal/district/motion-brief evancho-mtd
```

The overlay pairs each of our 17 pages with the filed page of the same number (word overlap 46% to 83%). The overlay is a diagnostic, not a score: the exemplar's pleading lines and Times type do not coincide with the render's (EB Garamond), so the two layers show offset text lines on every page. (Recorded on the earlier EB Garamond render, before fb-595.68.21.)

## Visual review (Gate 2 record, all 17 pages, 60 dpi, viewed; on the earlier EB Garamond render, before fb-595.68.21)

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: counsel lines 1 to 6, court title lines 7 and 8, caption box, title and judge on the right, notice paragraph | OK. Caption box closed by right and bottom rules; the title wraps to five lines inside the right column. |
| 2 | Running header; MEMORANDUM heading; I. Introduction (paragraphs 1 and 2) | OK after the paragraph-gap fix (first version: paragraphs overlapped at each break, see below). |
| 3 | Introduction end; II. Relevant Background | OK. |
| 4 | Background end; III. Legal Standard, A. | OK. |
| 5 | III.B and C | OK. Lines 27 and 28 empty: the heading D. moved to page 6 with its paragraph. |
| 6 | III.D; IV. Argument, A.; A.1 | OK after the heading fix (first version: two-line headings overlapped the text below). |
| 7 | A.2 to A.5 | OK. Two-line headings sit on two numbered lines. |
| 8 | A.5 end; B.; B.1; B.2 | OK. |
| 9 | B.2 end; B.3 (ratification) | OK. |
| 10 | B.4; B.5; a. Fourth Amendment | OK. |
| 11 | B.5 b. Procedural Due Process | OK. |
| 12 | B.5 c.; C. (Younger), C.1 | OK. |
| 13 | C.1 (Younger) | OK. |
| 14 | C.1 (bad-faith) | OK. |
| 15 | C.1 end; C.2 (Colorado River) | OK. |
| 16 | C.2 end; D. (TRO) | OK. |
| 17 | V. Conclusion; DATED line; firm block; By /s/ and signer lines; CERTIFICATE OF SERVICE and service list; /s/ SJP | OK. The service list is single-spaced, one entry per block. |

Defects found in review and fixed (all in `typst/azd-motion.typ`): (1) paragraphs in one flow lost their line-gap at each break, so the first line of a paragraph overlapped the last line of the one before (fixed by one block per chunk, each with a gap of one body-leading); (2) two-line headings overlapped the text below, because `measure()` of a single-spaced two-line heading gave 23.4 pt, which rounds to one line (fixed by giving headings the body pitch); (3) the first paragraph in a block lost its first-line indent (fixed by an explicit `h()`); (4) the sample had typed the heading labels (`A.`, `1.`), which doubled the template's labels (fixed in the sample: the template numbers headings).

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP tier 2 asks for 2 or 3 filers from different sources. Not met for this doc type. Searches tried are in `usage/SOURCE.md`.
2. **Font.** LRCiv 7.1(b)(1) names no typeface: "fixed-pitch type size no smaller than ten (10) pitch ... or in a proportional font size no smaller than 13 point" (text read 2026-10-15 from the 2020 master file). So the template sets vendored Times New Roman at 13 pt, the house standard (`docs/FONTS.md` rule 6), which is also the exemplar's face.
3. **Page limit (LRCiv 7.2(e)(1)).** The template does not count the 17 pages. The sample was 17 pages with the caption, signature and certificate on the earlier EB Garamond render, the same as the exemplar; the committed Times New Roman render is 20 pages (not re-checked against the limit here). The brief's target was 8 to 14 pages; this sample is not cut down, because the exemplar is 17 pages and cutting the memorandum would drop the signature and certificate the brief asks for.
4. **Memorandum mention on the first page (LRCiv 7.1(a)(3)(C)).** The rule asks for "mention of any notice of motion or affidavits or memorandum in support" in the caption's right column. The exemplar's title does not say "memorandum"; the template does not add it. An author who wants it can add it to `brief_title`.
5. **LRCiv 12.1(c) certification.** The exemplar (filed 2026-08-18, on a 12(b)(6) motion) has no certification, and the 2020 rule requires one. The template has the optional `certification` slot; the sample does not use it, because the sample is the exemplar, not an edit of it. A filing must include the certification text, which only counsel can write.
6. **Running header (10 pt).** The header is in the top margin in 10 pt; LRCiv 7.1(b)(1)'s 13-point floor is for text, footnotes and quotations, and a header is not text in that sense. A convention choice; the exemplar has one.
7. **Italics.** The text layer carries no italic markup, so case names and signals (*Id.*, *See*) are roman in the sample. The template italicises `*...*` markdown, so a future sample can carry them.
8. **Heading style.** Headings are bold; the exemplar's heading weights could not be read from the text layer. Convention choice.
9. **Certificate of service date.** The exemplar's certificate reads "August ____, 2026" (blank, as filed). The sample keeps the blank; the template prints whatever the sample says.
10. **Current rule text not verified** (see Governing rules). The 2020 master file is the source.
11. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids touching `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.

## Engines

**docx** (LibreOffice only; Word was not available, so "opens in Word without a repair prompt" is not verified).
`docx/reference.xml` holds the Word styles (the shared cross-engine recipe, `base="xengine"`, in the typst face: Times New Roman 13 pt, exact 24 pt lines); `fb render --engine docx` builds the reference document from it. `docx/azd-motion.lua` builds the cover, caption, hung and numbered headings (I., A., 1., a., as typst), body paragraphs, signature and certificate, and writes the footers (the pleading numbers 1 to 27 in a frame on the page, the page number, and from page 2 the running line from the sample's `running_header` frontmatter, because that text is case-specific and cannot live in the template) and the section (`FORMBOOK_FOOTERS`, `FORMBOOK_FINAL`). `build-reference.sh` and `docx/render.sh` were retired into fb render in fb-595.68.21; no shell script is left in `docx/`. `sh tools/render.sh --engine docx <this folder> usage/INPUT-motion-brief.md` writes `usage/OUTPUT-motion-brief.docx` and `.docx.pdf`: 20 pages, as the typst render; fonts embedded Times New Roman (Regular, Bold, BoldItalic) only.

- Matches typst: Times New Roman 13 pt; 27 numbered lines on a 24 pt grid. Recorded on the earlier EB Garamond build (17 pages, all viewed at 60 dpi): counsel from line 1; court title on line 7; caption ruled right and below; headings hung at the typst indents; running header from page 2 in 10 pt in the top margin (now a 9 pt running line under the page number, in the footer, on both engines); signature and certificate.
- Differs, and why (recorded on the earlier build): (1) the pleading numbers are a floating text box in each header, and the pleading rules are page borders around the text area (top to bottom margin, not the full page height as in typst); (2) the caption row height is estimated from the number of wrapped lines, so the grid below it can differ by a line from typst; (3) headings use the body pitch, so a two-line heading takes two numbered lines in both engines, but Word may break lines differently; (4) no typst PDF is in `usage/` for this doc type (`OUTPUT-motion-brief.typst.pdf` is not in this snapshot), so the docx was compared with the typst template and the review above, not with a rendered typst page.
- BLOCKED: `tools/check.sh <folder> --engine docx` cannot run on a doc-type folder: it reads `court.json` and `checks.yaml` from the folder it is given (exit 2). No stamp is written. The Gate 1 rule checks are not run for docx; the observations above are not a gate result.
