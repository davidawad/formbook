# wawd: motion-brief (motion to dismiss with memorandum)

Doc type: **motion-brief**, specifically a Rule 12(b) motion to dismiss with its memorandum, in the United States District Court for the Western District of Washington (`wawd`).
Folder: `courts/ninth-circuit/washington/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`). Tier 2 is not judged against two or three filers; see gaps. |
| sample md | `usage/INPUT-motion-brief.md`: caption, noting data, the introduction through Argument II, the conclusion, the word-count and conferral certificates, signature, and certificate of service. Argument III and IV, and the table of authorities, are not transcribed (see gaps). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf` and `.docx.pdf`, 13 pages each (typst 0.15.0, pdfLaTeX, LibreOffice), Times New Roman (vendored) only, no warnings (2026-10-29, on the shared document model, fb-595.98). |
| overlay | `just overlay <this folder>` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` (not committed). |
| pages reviewed | 13 of 13 on each engine rendered to PNG at 60 dpi (39 images); read by their text layout and line positions (2026-10-29: the image viewer of the agent pod could not open them; see Visual review). |
| typeface | Face required: **none**. LCR 10(e)(1) requires "a proportionally spaced font" and names no face, and the filed motion embeds Times New Roman, so the template sets Times New Roman (`docs/FONTS.md`: a Times exemplar), in every engine. Checked against the rule text, 2026-10-15. Metric fit: n/a. |

## Governing rules

Primary source: W.D. Wash. Local Civil Rules (2026 edition, "WAWD Local Civil Rules (2026) - Clean"), downloaded 2026-10-14 from https://www.wawd.uscourts.gov/sites/wawd/files/WAWD%20Local%20Civil%20Rules%20%282026%29%20-%20Clean.pdf. The court's proposed 2026 amendments (dated 2026-09-22) amend LCR 100 only. LCR rule text was checked against the PDF text layer. Fed. R. Civ. P. 10(a) was fetched from https://www.law.cornell.edu/rules/frcp/rule_10 and checked; Fed. R. Civ. P. 5, 7(b) and 12(b) are cited by number only and were not re-checked against their text in this pass. The court's requirement IDs are in `../rules.md`.

| Rule | Requirement | Where it is in `typst/layout.yaml` |
|---|---|---|
| LCR 10(d) | 8 1/2 x 11 inch page. | the base's letter paper. |
| LCR 10(e)(1) | No less than three inches above the court title on the first page; one-inch margins; 12 pt or larger; double spaced or exactly 24 pt; proportionally spaced font. | `cover` (the court title on line 7, three inches from the top); `margin`; the base's `size: 12`; `pitch.body: 24`; the face in `typst/wawd-motion-brief.typ`. |
| LCR 10(e)(2) | "United States District Court, Western District of Washington" on the first page, and a title below the docket number. | `cover`: `{xd.court}`, `{xd.district}`; the case number, then `brief_title`. |
| LCR 10(e)(3) | Bottom notation: left, the abbreviated title and case number with the page number; right, the firm, mailing address and telephone (the filing may omit the firm block). | `page_number.text`: `footer_title`, then "(Case No. ...) – page", on every page; no firm block (see gaps). |
| LCR 10(e)(4) | Dated and signed under Fed. R. Civ. P. 11 and LCR 11. | `closing`. |
| LCR 10(e)(5) | Line numbers in the left margin, at least half an inch to their left. | `pleading`: 27 numbers on the 24 pt lines, right-aligned half an inch left of the text. |
| LCR 7(b)(4) | "ORAL ARGUMENT REQUESTED" in the caption of a motion or responsive memorandum that asks for argument. | `cover`: `caption_notes` (the sample requests argument). |
| LCR 7(d)(4) | Motions to dismiss are noted for consideration no earlier than 28 days after filing. | `caption_notes` carries the noting date given in the filing (NOVEMBER 6, 2026). The template does not check the date. |
| LCR 7(e)(4) | Motions to dismiss and the responses to them: 8,400 words or 24 pages; replies 4,200 words or 12 pages. | Not asserted (length is the author's). The sample is shorter than the limit. |
| LCR 7(e)(6) | When word limits apply, the signature block certifies the word count of the memorandum. Captions, tables and certificates do not count. | `closing`: the sample's `word_certificate`, as filed (the filer's count of the whole memorandum, 8,390). |
| Fed. R. Civ. P. 7(b) (not re-checked this pass) | A request for a court order must be made by motion, stated with particularity. | Author content. |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, file number, and Rule 7(a) designation. | `cover`. |
| Fed. R. Civ. P. 12(b)(6) | Motion to dismiss for failure to state a claim. | Author content (the sample's title and body). |
| Fed. R. Civ. P. 5 | Certificate of service on counsel of record. | `after_tail`: the sample's `certificate_of_service`, on its own page after the signature, as in the filing. |

Not produced by this template: the proposed order (LCR 10(e)(7) "Presented by" language, if a proposed order is filed with the motion), declarations, and the word-count tool output.

## Layout

On the generic federal district brief (`lib/layouts/frcp-motion-brief.yaml`, fb-595.17) with the pleading paper of the shared model (fb-595.96); `typst/layout.yaml` overlays the local rules above, each number with its rule.

- Numbered lines 1 to 27 down the left margin on the 24 pt lines, with a double rule at the text's left edge and a single rule at its right.
- Page 1 (cover): the judge's name on line 1 at the right, lines 2 to 6 blank (three inches from the top), the court title on lines 7 to 9, the caption from line 11: the parties in a 3.1 in column ruled at its right and foot (each designation 2 in in), and at the right the case number, the title of the paper and the noting data in bold.
- Every single-spaced block (caption, contents, signature) starts 9.6 pt into a numbered line, so its lines stand on the numbers or halfway between two.
- Page 2: the table of contents, generated from the headings (to the third level, dot leaders, the pages in a half-inch column, "Page" over them), each level half an inch further in.
- Page numbers: the cover i, the contents ii, the motion from 1 (the filing leaves its cover unnumbered; LCR 10(e)(3) asks for the page number on each page).
- The introduction opens page 3. Headings on the numbered lines: level 1 centered bold capitals; level 2 numbered I., II. by the layout, bold, the label in a half-inch box and the title hanging after it; level 3 A., B. bold italic, half an inch further in.
- Body paragraphs: double spaced, 0.5 in first-line indent.
- After the conclusion: the word-count and conferral certificates, then the signature block (the date at the margin, "Respectfully submitted," and the signers at 3.2 in, the other counsel and the role a numbered line below), never split. The certificate of service is on its own page last.

## Markdown contract (for samples)

- YAML frontmatter, then the body: `#` level-1 headings (sections), `##` argument headings (numbered by the layout: no "I." in the text), `###` sub-headings, paragraphs. The contents are generated: no table of contents in the body.
- Frontmatter fields: `case_number`, `judge`, `location`, `caption.parties` (`names`, `designation`), `brief_title`, `caption_notes` (noting date, oral argument, dates of the action), `footer_title`, `word_certificate` (markdown, optional), `signature` (`date`, `firm` (optional), `signers` (the first with "By: "), `additional`, `role`), `certificate_of_service` (`text`, `signer`).

## Known gaps and open choices

1. **Tier 2 is not judged against two or three filers.** One motion to dismiss with a memorandum was found in the search (CourtListener RECAP, `type=r`, `court=wawd`, filed 2026-08-01 to 2026-10-13); its filer is the only exemplar. A second filer's motion would be needed for the tier-2 rule.
2. **Excerpt.** The sample transcribes the filing's cover, introduction, relevant allegations, legal standards, Argument I and the start of II, the conclusion, the certificates, the signature and the certificate of service. Argument II (its end), III and IV, and the table of authorities are not transcribed, so the generated contents list only the transcribed headings, at our pages.
3. **Footer firm block.** LCR 10(e)(3) puts the preparing firm's name, address and telephone at the right of the bottom notation; this filing omits it, and the template does not set one: the shared model's running footer (`page_number.text`) has one column of lines and a `<tab>` for a piece at the right of one line, not a block of lines at the right (a base feature the model lacks; the old template's `footer_firm` is gone).
4. **The last paragraph is not kept with the signature** (`keep_with_closing: false`): the old template did not keep it either, and with it on, Word's page needle for the last heading (`lib/docx/xdoc.lua` `heading_needle`, called before `xd.last_para` splits the paragraph off) lost the words after "CONCLUSION" and found the word on an earlier page (the contents' CONCLUSION row read 7 in the docx, 10 in typst). A shared docx fix; not made here (court folders only).
5. **Cover page number.** The filing leaves its cover unnumbered and numbers the contents from i; the template prints i on the cover and ii on the contents (`page_number.cover: numbered`), as LCR 10(e)(3) asks for a page number on each page.
6. **Footnotes** are not used in the sample (the filing's are in the untranscribed argument); the model sets them at the base's 12 pt.
7. **Footer type size.** 10 pt in 12 pt lines; see the complaint README, gap 2.
8. **Caption.** Party column closed by a rule (right and bottom), as in the complaint; DEF-COVER-002's four differences from the exemplar's caption and ruled footer are accepted in `eval.yaml` (one filer's style).

## Visual review (Gate 2 record, 2026-10-29)

Every page of the three renders was rendered to PNG at 60 dpi (13 each, 39 images); the pod's image viewer could not open them, so each page was read by its text layout (`pdftotext -layout`) against the numbered lines, and the three engines' pages compared by their ink coverage (equal to 0.002 on every page).

| Page | Finding | Status |
|---|---|---|
| 1 | judge on line 1, court title lines 7 to 9, caption lines 11 to 19, each caption line on a number or halfway; footer "– i" | PASS |
| 2 | contents: title on line 1, "Page" on line 2, rows on the numbers, leaders to the page column; footer "– ii" | PASS |
| 3 to 11 | body double spaced on lines 1 to 27, headings on the lines, kept with their text; footer pages 1 to 9 | PASS |
| 12 | conclusion, certificates, signature block whole on lines 13 to 22 | PASS |
| 13 | certificate of service, the signer on line 5 at 3.2 in | PASS |
| 1 | no second filer to judge the caption's convention against (gap 1) | OPEN |

## Engines

All three engines are generated from one layout (docs/EVAL-LOOP.md, "Generated engines"; fb-595.98): `typst/layout.yaml` over `lib/layouts/frcp-motion-brief.yaml`; `typst/wawd-motion-brief.typ` names the face and hands the layout to `lib/typst/xdoc.typ`; `fb engines gen` writes `latex/template.tex`, `latex/xdoc.lua`, `docx/reference.xml` and `docx/xdoc.lua` (`docx/motion-brief.lua` and the old typst template code are gone; the LaTeX engine is new). `eval.yaml` gates the cross-engine check (`params.cross_engine: gate`) and reads the 27 margin numbers as page furniture (`params.pleading_lines`).

`sh tools/check.sh <dir>`: typst 11 passed, 0 failed; `--engine latex`: 14 passed, 0 failed; `--engine docx`: 15 passed, 0 failed; XENG-001..003 PASS on both. Not verified in Word (LibreOffice only).
