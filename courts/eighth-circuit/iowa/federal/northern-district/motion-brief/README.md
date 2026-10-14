# iand: motion-brief

Doc type: **motion-brief**, the memorandum in support of a Rule 12(b) motion to dismiss, in the United States District Court for the Northern District of Iowa (`iand`).
Folder: `courts/eighth-circuit/iowa/federal/northern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-gharavi-schwab-6-25-cv-02074-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-gharavi-motion-brief.md`: the complete memorandum (caption, table of contents, Introduction, Relevant Allegations, Legal Standard, Argument a to e, Conclusion, signature, proof of service) |
| render | ok: `samples/OUTPUT-gharavi-motion-brief.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`) |
| typeface | no face required by the court's rules (LR 10 names none; checked 2026-10-14). EB Garamond 12 pt stays; no vendored substitute applies. See the Governing rules table. |
| overlay | ok: `samples/OVERLAY-gharavi-motion-brief.pdf` and `.txt` (`tools/overlay.sh`, exemplar passed explicitly). The exemplar PDF is not committed in this snapshot; the overlay used the RECAP copy at the URL in `exemplars/SOURCE.md` (17 pages). |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi and viewed in the typeface pass, 2026-10-14) |

## Governing rules

Primary sources, fetched 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| N.D. Iowa LR 7(b)(3) | A brief is filed as an electronic attachment to the motion, under the same docket entry. | Not a layout rule; the sample is the attachment's text (`ECF 13-1` in the exemplar). |
| N.D. Iowa LR 7(d) | The moving party's brief states the grounds for the motion and cites the authorities. | Content; the template does not check it. |
| N.D. Iowa LR 7(h) | Brief length: 20 pages, not counting the table of contents, table of authorities and signature block. | Not enforced; the sample body is about 10 pages in this render. A longer brief needs leave under LR 7(h). |
| N.D. Iowa LR 10(a) | 8 1/2 x 11 inch paper. Source: https://www.iand.uscourts.gov/sites/iand/files/Local%20Rules%208.1.2020%20edits.%20clean.pdf (Local Rules, "Revised August 1, 2020", effective December 1, 2020; the posted copy is the version checked). | `page-w`, `page-h`. |
| N.D. Iowa LR 10 (typeface, point size) | Names no typeface and no point size. Checked against the full text of the same Local Rules copy (2026-10-14): no provision mentions a font, typeface or type size. | `font-family = "EB Garamond"`, `type-size = 12pt`: the "No face named" row of `docs/FONTS.md`. |
| N.D. Iowa LR 10(b)(1) | Double spaced. | `pitch = 24pt`, `body-leading = 1.35em`; paragraphs and headings are rounded to whole 24 pt lines (`on-grid`). |
| N.D. Iowa LR 10(b)(2) | One side of the page. | Single-sided PDF. |
| N.D. Iowa LR 10(b)(3) | Top margin of at least 1 inch. | `margin = 1in` on all sides. |
| N.D. Iowa LR 10(b)(4) | A brief of more than 10 pages has a subject matter table of contents on its first page. | `toc: true` puts the outline (level 1 and 2 headings, with pages) on page 1 under the caption. |
| N.D. Iowa LR 10(b) (last paragraph) | Documents of more than one page are numbered at the bottom of each page. | `footer` (centered page number). |
| N.D. Iowa LR 10(d) | Caption: district and division, case number, names of the litigants per FRCP 10(a), designation of the content, and the party filing. | `court-title`, `caption` (parties, `Case No.`, judges, title). |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, file number and Rule 7(a) designation. | As LR 10(d). |
| Fed. R. Civ. P. 12(b)(6) | The motion's ground: failure to state a claim. | Content; not checked by the template. |

## Layout

- Court title (3 lines), caption with a `)` column, `Case No.`, judges, and the title of the paper in bold on the right.
- Page 1: the table of contents follows the caption; body starts on page 2.
- Body: double spaced; first-line indent 0.5 in; paragraphs are not numbered except the Relevant Allegations (`NUMBERED:` chunks, 1 to 10).
- Headings: level 1 centered caps (I. INTRODUCTION ...); level 2 bold, flush left (a. ...); level 3 bold italic (i. ...). A heading is kept with the paragraph after it; a heading that wraps is double spaced like the body.
- Block quotations (`> ...`) are single spaced and indented 0.5 in on both sides.
- Signature block after the conclusion (`SIGNATURE`): party, firm, `/s/` signer, counsel lines.
- Proof of service: a level-1 heading; the service list is single spaced (`SINGLE:` chunks).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Blank-line-separated chunks: `#`/`##`/`###` headings; `NUMBERED: ...` paragraphs; `> ...` block quotes; `SINGLE: ...` single-spaced lines (one per source line); a list (numbered 1., 2., ...); the word `SIGNATURE`; or a plain paragraph.
- Frontmatter: `case_number`, `case_label` (default "No."), `judge`, `magistrate_judge`, `division`, `toc` (true for briefs over 10 pages), `caption.parties` (list of `{names, designation}`), `brief_title`, `date` (optional), `signature` (`party` lines, `firm` lines, `signer`, `lines`).
- Not supported: tables, footnotes, raw typst.

## Known gaps and open choices

1. **Only one exemplar.** Tier 2 asks for 2 or 3 filers. The search (CourtListener RECAP, `court=iand`) found other N.D. Iowa motion-to-dismiss filings (Hane v. Linn County, 1:25-cv-00090; Close v. City of Bellevue, 2:24-cv-01012; Foster v. Sioux City, 5:25-cv-04024), but no brief for them was returned, so none was saved or checked. Tier 2 is therefore **not** judged against two filers yet.
2. **Typeface and size.** The N.D. Iowa Local Rules text names no typeface and no point size (re-checked 2026-10-14 against the full text, not only LR 10), so the template uses EB Garamond 12 pt under the "No face named" row of `docs/FONTS.md`; no substitute was switched in. The exemplar is Segoe UI and Calibri, a Word default, not a court requirement; the size difference is therefore not a rule difference. Whether the court wants a larger apparent size is a question for David.
3. **Images in the sample.** The social-media posts in Relevant Allegations 3, 5 and 6 are images in the exemplar; their text is not in the text layer. The sample marks them as `[Image of the post; not in the text layer.]`. The overlay therefore differs on those lines.
4. **Exhibit citations** (Ct. Dkt. 1 at pages, Exhibit A and B) are the filer's; the sample does not include the complaint's exhibits.
5. **Citation errors in the exemplar.** The filed memorandum contains citation errors (for example, "Hoffman v. Clark, 975 N.W.2d 656 (Iowa 2022)" is cited with no pinpoint, and "Mayfield v. Missouri House of Representatives" (8th Cir.) is introduced as an "Iowa courts" holding). The sample transcribes them as filed; the template does not check citations. Citation checking is for the filing attorney.
6. **Table of authorities.** The exemplar has a table of contents only; the template generates a table of contents from headings and no table of authorities (none is required by LR 10 or 7; LR 7(h) excludes it from the page limit if one is added).
7. **Overlay pairing.** Pages pair by shared words; the page overlap is 46% to 92%. The page map is in `OVERLAY-gharavi-motion-brief.txt`. Pairs skip filed pages, because the filed memorandum is single spaced and the render is double spaced, so the pages do not line up one to one. The overlay is a diagnostic, not a score.
8. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, and this doc-type folder is not that shape. Render and overlay were run; the review below is the Gate 2 equivalent.
9. **Output names.** `tools/render.sh` writes `samples/OUTPUT-<id>.pdf` and `tools/overlay.sh` reads that name, so the sample is `INPUT-<id>.md` and the outputs are `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt` (the file-role naming of CLAUDE.md, not the `<id>.pdf` / `<id>-overlay.pdf` names in the brief).
10. **Version of the local rules.** The copy checked is dated "Revised August 1, 2020". No later revision was found in the search; the current posting should be confirmed before the template is treated as final.

## Review of the rendered pages (samples/OUTPUT-gharavi-motion-brief.pdf)

- Page 1: court title, caption with `)` column, Case No., judges, title; table of contents (I to V, a to e, PROOF OF SERVICE) with pages. Pass.
- Page 2: NOW COMES paragraph; I. INTRODUCTION (two paragraphs); II. RELEVANT ALLEGATIONS 1 to 6 (images marked). Pass.
- Page 3: allegations 7 to 10; III. LEGAL STANDARD; heading a. mid-page with its text. Pass.
- Page 4: legal standard continued; heading b. and i. (italic); no heading at the foot. Pass.
- Page 5: heading ii. and c. False Light; the page ends after the c. paragraph with white space because IV. LEGAL ARGUMENT's heading and first paragraph are kept together. Pass.
- Page 6: IV. LEGAL ARGUMENT; heading a. (three lines, double spaced); the Bauer block quotation, single spaced and indented. Pass.
- Page 7: Drake and Schwab analysis; heading-free paragraphs. Pass.
- Page 8: heading b. (four lines); paragraphs on the 24 pt grid. Pass.
- Page 9: heading c. (two lines) with i. and ii. italic headings. Pass.
- Page 10: heading d. (two lines) with its text; the page ends after d. Pass.
- Page 11: e. paragraph; V. CONCLUSION; WHEREFORE; signature block (party, firm, `/s/ Joseph W. Rust`, AT number); PROOF OF SERVICE heading. Pass.
- Page 12: proof of service paragraph; service list (single spaced). Pass.

Heading size and wrap: the first render had headings at typst's default size (larger than body) and two-line headings that collided with the following text. Both were fixed and every page re-viewed.
