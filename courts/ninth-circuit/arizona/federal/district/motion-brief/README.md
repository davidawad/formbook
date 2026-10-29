# D. Ariz. (azd): motion with memorandum

Doc type: **motion** (a motion to dismiss, or in the alternative to stay, with its memorandum of points and authorities, one filed document) in the United States District Court for the District of Arizona. Folder: `courts/ninth-circuit/arizona/federal/district/motion-brief/`. The court-root `typst/` and `usage/` of `district/` are not touched.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the whole motion, caption to certificate of service (17 pages, as the exemplar) |
| typeface | face required: **none** (LRCiv 7.1(b)(1) names a size and a pitch, not a face; see Governing rules) → **Times New Roman** (vendored), the house standard (`docs/FONTS.md` rule 6) and the exemplar's face; the docx uses the same face. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf` and `.docx.pdf`, 20 pages each (typst 0.15.0, pdfLaTeX, LibreOffice), vendored fonts only, no warnings (re-rendered 2026-10-29 on the shared document model, fb-595.96) |
| overlay | `just overlay <this folder>` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 20 of 20 on each engine rendered to PNG at 60 dpi (60 images, `.overlay/`); read by their text layout and line geometry (2026-10-29: the image viewer of the agent pod could not open them; see Visual review) |

File names follow the repo's tools: the sample is `INPUT-<id>.md`, the render `OUTPUT-<id>.pdf`, the overlay `OVERLAY-<id>.pdf/.txt`, because `tools/render.sh` and `tools/overlay.sh` read and write those names by default.

## Governing rules

Primary source: D. Ariz. Local Rules of Civil Procedure, the "Local Rules Master File 2020" PDF at https://www.azd.uscourts.gov/sites/azd/files/local-rules/Local_Rules_Master_File_2020.pdf, read 2026-10-14. **The current text was not verified:** courtrules.net and the court's current rules pages returned HTTP 403, so the 2020 file is the newest copy reachable. Check LRCiv 7.1, 7.2, and 12.1 against the current local rules before the template is treated as final. Quotations below are from the 2020 file.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LRCiv 7.1(a)(1) | Attorney name, address, e-mail, State Bar number, telephone, and the party represented, typed in the space left of center beginning at line 1. | layout.yaml `front`: `{counsel}` in a box at least four numbered lines high (`min_height: 96`). |
| LRCiv 7.1(a)(2) | "The title of the Court must begin on or below line six (6) of the first page." | the counsel box (`min_height: 96`) and a numbered line above the title: line 6 at the earliest (sample: line 8). |
| LRCiv 7.1(a)(3) | Party names in upper and lower case; right of center: (A) the case number, (B) a brief description of the paper, including "demand for trial by jury if made", (C) mention of any notice of motion or memorandum in support. | layout.yaml `front` caption columns: `case_number`, `brief_title` (the sample's title says "Motion to Dismiss ... Motion to Stay"; the memorandum is mentioned in the notice paragraph, see gap 4). |
| LRCiv 7.1(b)(1) | Double-spaced body, no more than 28 lines per page; footnotes and indented quotations may be single-spaced. | layout.yaml `pitch.body: 24`, `pleading.lines: 27` (27 numbered lines between the one-inch margins). |
| LRCiv 7.1(b)(1) | Fixed pitch of 10 or proportional font of at least 13 point, "including any footnotes". | layout.yaml `size: 13`, `footnote.size: 13`; Times New Roman (typst/azd-motion.typ). No footnotes in the sample. |
| LRCiv 7.1(b)(1) | Pages numbered; left margin not less than 1 1/2 inches; right margin not less than 1/2 inch. | layout.yaml `page_number` centered under the text; `margin.left: 108` (1.5 in), `margin.right: 72`. |
| LRCiv 7.1(b)(1) | Letter size, signed under Rule 11. | Letter; layout.yaml `closing` ("DATED:" line, firm, "By: /s/" and signer lines). |
| LRCiv 7.2(b) | The moving party files a memorandum setting out the points and authorities with the motion. | Structure of the sample: the notice paragraph, then `MEMORANDUM OF POINTS AND AUTHORITIES` (level 1 heading) and the memorandum's numbered headings. |
| LRCiv 7.2(e)(1) | "[A] motion including its supporting memorandum ... may not exceed seventeen (17) pages, exclusive of attachments and any required statement of facts." | Not counted by the template (gap 3). The sample renders at 20 pages with the caption, signature and certificate (13 pt on 27 numbered lines; the exemplar files the same text on 17 pages of 28 lines). |
| LRCiv 12.1(c) | A Rule 12(b)(6) motion "will [not] be considered or decided unless the moving party includes a certification that, before filing the motion, the movant notified the opposing party of the issues asserted in the motion and the parties were unable to agree that the pleading was curable". | Optional `certification` frontmatter (heading and text), set before the signature (layout.yaml `closing`). The exemplar has none, so the sample has none (gap 5). Tested with a temporary sample; the test file was deleted. |
| Fed. R. Civ. P. 12(b)(6) | "failure to state a claim upon which relief can be granted" is a defense that may be raised by motion. Fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_12. | The motion's title and the Rule 12(b)(6) argument (author content). |

## Layout

The folder is on the generic federal district brief (`lib/layouts/frcp-motion-brief.yaml`) with D. Ariz.'s rules overlaid in `typst/layout.yaml`, set by the shared document model (`lib/typst/xdoc.typ`; `latex/` and `docx/` generated by `fb engines gen`, fb-595.96).

- Pleading paper (layout.yaml `pleading`): the numbers 1 to 27 down the left margin, right-aligned on 1 in, one per 24 pt numbered line from the top margin; a double rule at 1.3 in and 1.34 in from the page's left edge and a single rule at 7.6 in. Page furniture: `eval.yaml` params.pleading_lines: 27 drops the numbers from the text the checks read.
- First page (`front`): counsel single-spaced (16 pt lines) from the top margin in a box at least four numbered lines high; the court title (bold, centered, a numbered line each) a numbered line below it, so on line 6 at the earliest (LRCiv 7.1(a)(2); line 8 in the sample); a numbered line below, the caption: the parties at left, ruled at their right and foot, "v." between them; the case number, the bold title and the judge at right; then the notice paragraph (`lead_in`).
- Headings on the numbered lines, kept with what follows: level 1 centred, bold, capitals; levels 2 to 5 numbered by the layout (I., A., 1., a.), bold (level 5 bold italic), each half an inch further in, the label in a half-inch box and the title hanging after it.
- Body paragraphs double-spaced with a 0.5 in first-line indent; footnotes at 13 pt.
- Footer: the page number centred under the text and the running line (case number, short title, judge) under it, both 9 pt (gap 6).
- Signature, kept with the last paragraph: "DATED:" on a numbered line, then at 2.6 in the firm, "By: /s/" and the signer's lines; the certificate of service after it (its heading, the paragraph, the service list single-spaced, "/s/" and the signer at 2.6 in).

## Markdown contract (for samples)

- Frontmatter fields: `case_number`, `judge`, `caption.parties` (list of `{names, designation}`; "v." between parties), `brief_title`, `running_header` (three lines: case number, short title, judge; the footer's running line), `counsel` (lines), `lead_in` (the notice paragraph, optional), `date` (after "DATED:"), `signature` (`firm` lines, `signer`, `lines`), `certificate` (optional: `heading`, `text`, `service` lines, `signer`), `certification` (optional, LRCiv 12.1(c): `heading`, `text`).
- Body: `#` the memorandum's title, `##` to `#####` its headings (the layout numbers them: do not type the labels), paragraphs.

## Render and checks

```sh
D=courts/ninth-circuit/arizona/federal/district/motion-brief
for e in typst latex docx; do sh tools/render.sh --engine $e $D usage/INPUT-motion-brief.md; done
for e in typst latex docx; do sh tools/check.sh $D --engine $e; done
just overlay $D   # -> .overlay/<doc path>/OVERLAY-motion-brief.pdf and .txt (not committed)
```

## Visual review (Gate 2 record)

2026-10-29, after the move onto the shared model (fb-595.96): every page of the three renders (20 typst, 20 latex, 20 docx: 60 pages) rasterized at 60 dpi with pdftoppm into `.overlay/`. The agent's image viewer could not open the PNGs in its pod, so each page was read by its text layout (`pdftotext -layout`) and its line geometry (`fb measure`); a look at the images themselves is left to the reviewer (PR). The three engines break every line and page alike (XENG-001..003 PASS).

| Page | What it is | Finding (all three engines) | Status |
|---|---|---|---|
| 1 | Counsel (lines 1 to 6), court title on lines 8 and 9, caption (13 party lines, "v."), case number, bold title and judge at right; the notice paragraph | Structure as the rules ask. The notice paragraph's lines stand between the line numbers: the caption's single lines are not a whole number of numbered lines, and the model does not snap a block to the numbered grid (the old template padded it). | OPEN (tier 2) |
| 2 | The notice's end; MEMORANDUM OF POINTS AND AUTHORITIES; I. Introduction | OK; every line on a numbered line. | OK |
| 3-19 | II. Relevant Background, III. Legal Standard, IV. Argument (A.-D. with their numbered and lettered sub-headings) | OK: labels in their boxes, titles hanging, headings kept with their text. | OK |
| 19-20 | V. Conclusion; "DATED:" and the signature at 2.6 in (page 19); the certificate of service (page 20) | OK. | OK |
| all | Footer: the page number and the running line under it, 9 pt | The exemplar's running header stands in its top margin from page 2; ours in the footer on every page (gap 6). | ACCEPTED (tier 3) |

Reviewed pages: 20 of 20 on each engine (60).

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP tier 2 asks for 2 or 3 filers from different sources. Not met for this doc type. Searches tried are in `usage/SOURCE.md`.
2. **Font.** LRCiv 7.1(b)(1) names no typeface: "fixed-pitch type size no smaller than ten (10) pitch ... or in a proportional font size no smaller than 13 point" (text read 2026-10-15 from the 2020 master file). So the template sets vendored Times New Roman at 13 pt, the house standard (`docs/FONTS.md` rule 6), which is also the exemplar's face.
3. **Page limit (LRCiv 7.2(e)(1)).** The template does not count the 17 pages. The sample was 17 pages with the caption, signature and certificate on the earlier EB Garamond render, the same as the exemplar; the committed Times New Roman render is 20 pages (not re-checked against the limit here). The brief's target was 8 to 14 pages; this sample is not cut down, because the exemplar is 17 pages and cutting the memorandum would drop the signature and certificate the brief asks for.
4. **Memorandum mention on the first page (LRCiv 7.1(a)(3)(C)).** The rule asks for "mention of any notice of motion or affidavits or memorandum in support" in the caption's right column. The exemplar's title does not say "memorandum"; the template does not add it. An author who wants it can add it to `brief_title`.
5. **LRCiv 12.1(c) certification.** The exemplar (filed 2026-08-18, on a 12(b)(6) motion) has no certification, and the 2020 rule requires one. The template has the optional `certification` slot; the sample does not use it, because the sample is the exemplar, not an edit of it. A filing must include the certification text, which only counsel can write.
6. **Running line (9 pt).** The exemplar sets a running header (case number, short title, judge) in the top margin from page 2; no rule asks for it. The model has no page header, so the line stands in the footer under the page number on every page, both at 9 pt (layout.yaml `page_number.size`); LRCiv 7.1(b)(1)'s 13-point floor is for text and footnotes, and the footer is not text in that sense. One filer's convention (tier 3).
7. **Italics.** The text layer carries no italic markup, so case names and signals (*Id.*, *See*) are roman in the sample. The template italicises `*...*` markdown, so a future sample can carry them.
8. **Heading style.** Headings are bold; the exemplar's heading weights could not be read from the text layer. Convention choice.
9. **Certificate of service date.** The exemplar's certificate reads "August ____, 2026" (blank, as filed). The sample keeps the blank; the template prints whatever the sample says.
10. **Current rule text not verified** (see Governing rules). The 2020 master file is the source.
11. **Checks.** `tools/check.sh` runs on this folder on all three engines (the stamps are in `usage/`); DEF-COVER-002 is reported, not counted (eval.yaml `cover_structure: report`: the exemplar's letterhead columns, one filer's layout).

## Engines

All three engines are generated from one layout (docs/EVAL-LOOP.md, "Generated engines"; fb-595.96): `typst/layout.yaml` over `lib/layouts/frcp-motion-brief.yaml`; `typst/azd-motion.typ` names the face (Times New Roman 13 pt) and hands the layout to `lib/typst/xdoc.typ`; `fb engines gen` writes `latex/template.tex`, `latex/xdoc.lua`, `docx/reference.xml` and `docx/xdoc.lua` (the folder's own docx filter is gone). The pleading paper is the model's `pleading` key; the footer's 9 pt its `page_number.size`; the counsel block's least height a box's `min_height` (all fb-595.96). `eval.yaml` gates the cross-engine check (`params.cross_engine: gate`).

`sh tools/check.sh <dir>`: typst 10 passed, 0 failed; `--engine latex`: 13 passed, 0 failed; `--engine docx`: 14 passed, 0 failed; XENG-001..003 PASS on both. Not verified in Word (LibreOffice only).

## FRCP base port

Moved onto the base with pleading paper (fb-595.96), replacing the folder's own typst template and docx filter (fb-595.17.11 had skipped it for want of pleading paper in the model).

[Parent: arizona/federal/district](../README.md)
