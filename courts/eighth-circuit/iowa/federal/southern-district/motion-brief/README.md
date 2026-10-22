# iasd: motion brief

Doc type: **motion brief** (brief in support of a motion, with table of contents and table of authorities) in the United States District Court for the Southern District of Iowa (`iasd`), Central Division. The sample is a Rule 12(b) motion to dismiss's supporting brief, as the exemplar is.
Folder: `courts/eighth-circuit/iowa/federal/southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: a transcription of the cover, the introduction, the factual background (with the privacy-policy block quotation and footnotes 1 to 3), the start of Argument I, the conclusion, and the signature block. Argument I's first paragraphs and Arguments II to IV are not transcribed. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 8 pages (9 on the earlier EB Garamond render: cover, TOC, TOA, body pages 1 to 6), typst 0.15.0, Times New Roman (pinned; vendored Liberation Serif fallback; embedded), no system fonts, no warnings |
| overlay | ok: `usage/OVERLAY-hanfling-brief.pdf` and `OVERLAY-hanfling-brief.txt` (page map) |
| typeface | face required by the court: **none** (LR 10(b) has no typeface or point-size rule; checked 2026-10-14 in the PDF text, see Governing rules). Font: **Times New Roman** 12 pt, the house standard (`docs/FONTS.md`, rule 6) and the exemplar's face; EB Garamond until then. Metric compatibility: n/a. See Known gaps 4. |
| pages reviewed | 9 of 9, on the then-final EB Garamond PDF (sha256 `bdd908b4...`, see the review table below) |
| `tools/check.sh` | not run: a doc-type folder is not a court folder (see Known gaps) |

## Governing rules

Primary source: **Local Rules of the United States District Courts for the Northern and Southern Districts of Iowa, effective December 7, 2020** (N.D. Administrative Order 20-AO000-13-P; S.D. Administrative Order 20-AO-23-P). Full PDF: https://www.iasd.uscourts.gov/sites/iasd/files/Local%20Rules%20-%20Final%2012142020.pdf (linked from https://www.iasd.uscourts.gov/local-rules). Read and quoted on 2026-10-14 from a text extract of that PDF (see the complaint README for how the copy was obtained). A 2026 proposed red-line is on the court's site and is not used (see the complaint README).

Fed. R. Civ. P. text is cited by number and was **not fetched in this pass**.

| ID | Rule | Kind | Requirement | Where it lives |
|---|---|---|---|---|
| IASD-FORM-001 | LR 10(a) | M | 8½ × 11 inch paper. | `page` setup (`us-letter`) |
| IASD-FORM-002 | LR 10(b)(1) | M | Double spaced. | `body-leading` (24 pt baseline pitch at 12 pt) |
| IASD-FORM-003 | LR 10(b)(2) | M | One side of the page. | Single-sided PDF. |
| IASD-FORM-004 | LR 10(b)(3) | M | Top margin of at least 1 inch on each page. | `margin-top = 1in` |
| IASD-FORM-005 | LR 10(b) (last sentence) | M | Documents of more than one page numbered at the bottom. | Front matter `i`, `ii`, … ; body `1`, `2`, … at the bottom centre. |
| IASD-TOC-001 | LR 10(b)(4) | M | A brief of more than 10 pages includes, **on the first page**, a subject-matter table of contents. | `toc-section()` on page ii (after the cover). See Known gaps 1: the rule's "first page" is ambiguous and this follows the exemplar. |
| IASD-CAP-001 | LR 10(d) | M | Caption: district and division, case number, party names as Fed. R. Civ. P. 10(a) requires, designation of the content, and the party filing. | `court-title()`, `caption()`; frontmatter `division`, `case_number`, `caption`, `brief_title` |
| IASD-MOT-001 | LR 7(c) | M | Oral argument requested is noted separately in the caption (and in the conclusion of the brief). | `caption()` prints `ORAL ARGUMENT REQUESTED` when `oral_argument: true`. The conclusion's wording is author content (see Known gaps 2). |
| IASD-MOT-002 | LR 7(d) | M | The brief states the grounds for the motion and cites the authorities relied on. | Author content; the TOA is built from the `toa:` links, so every authority the brief cites is listed. |
| IASD-MOT-003 | LR 7(b)(3) | M | The brief is filed as an electronic attachment under the same docket entry as the motion. | Filing practice; not in the template. |
| IASD-MOT-004 | LR 7(h) | M | A brief may not exceed 20 pages, not counting the TOC, TOA and signature block, unless a different limit is set by the Local Rules or leave is granted. | Not checked by the template (no page counter). The exemplar's body runs 32 pages; see Known gaps 3. |
| IASD-SIG-001 | LR 11 | M | Under the signature: name, law firm, mailing address, telephone, email; lead counsel identified if more than one lawyer. | `signature-block()`; frontmatter `signature.lines` |
| IASD-TIER2-001 | none in the Local Rules (LR 10(b) checked 2026-10-14) | C | Typeface and size: none given. The exemplar is Times New Roman 12 pt. | `font-family = ("Times New Roman", "Liberation Serif")`, `type-size = 12pt`, `footnote-size = 12pt` (Known gaps 4). |
| IASD-TIER2-002 | none | C | Headings: level 1 centered bold capitals; level 2 and below numbered (I., A., 1., a.) with a hanging indent; block quotations single spaced and indented 0.5 inch on both sides. | `heading-num()`, `show heading`, `show quote` |
| IASD-TIER2-003 | none | C | Front matter numbered in lower-case roman; table of authorities groups (Cases, Statutes, Rules, Other Authorities) with `passim` for an authority on five or more pages. | `toa-section()`, `toa-groups`, `passim-threshold` |

Not produced by this template (separate papers): the motion itself, any proposed order, the certificate of service (LR 5(a), see Known gaps 5), and any declarations (LR 5A(g)(7): documents prepared under penalty of perjury). The motion itself must cite the statutes and rules under which it is made (LR 7(b)(2)).

## Layout

- Cover (page i): court title (three centered bold lines), the caption (party column with a right and bottom rule; case number, title and `ORAL ARGUMENT REQUESTED` at right).
- Table of contents (page ii): one row per heading, with dot leaders and the page in its own column; a wrapped heading hangs under its title.
- Table of authorities (page iii on): built from the `toa:` links in the body; each authority lists the distinct pages where it is cited, `passim` at five or more; page numbers in their own column.
- Body (page 1 on): double spaced; first-line indent 0.5 inch; headings as above; footnotes single spaced at text size; block quotations single spaced; the signature block after the conclusion, with the date on the left and the signature block indented to the caption's party column.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `division`, `caption` (`versus`, `parties`: list of `{names, designation}`), `case_number`, `brief_title`, `oral_argument` (true or false), `authorities` (a registry: key → `{kind, name?, cite}`; `kind` is `case`, `statute`, `rule` or `other`; `name` is italicised for a case), `signature` (`date`; `lines` with `""` for a blank line).
- Body: `#` = level 1 heading (unnumbered; centered bold capitals); `##` = level 2 (roman numeral); `###` = level 3 (capital letter); `####` = level 4 (arabic). The template numbers the headings; the sample types no numbers.
- Authority links: `[*Case Name*, cite, at pin](toa:key)` records the link under the key. A key not in the registry fails the build. Footnotes: `[^id]` and `[^id]: text`.
- Block quotation: `> ` lines. Section and paragraph signs keep their number on the same line.
- Not supported: tables; raw typst.

## The overlay

`usage/OVERLAY-hanfling-brief.pdf`: red = our render, blue = the filed exemplar, black = both agree. The filed PDF is not stored in `usage/` in this snapshot (only `SOURCE.md`), so the overlay was built against a copy fetched from the URL in `usage/SOURCE.md` on 2026-10-14 (40 pages, sha256 `a4e6ad619db6cc47f523b3fd86638097c9832a5386c91fa486b623a66586264a`). Pages are paired by word overlap (`OVERLAY-hanfling-brief.txt`):

| ours | filed | overlap |
|---|---|---|
| 1 (cover) | 1 (cover) | 90.3% |
| 2 (TOC) | 2 (TOC) | 22.4% |
| 3 (TOA) | 14 | 20.5% |
| 4 (body 1) | 8 | 89.4% |
| 5 (body 2) | 9 | 69.3% |
| 6 (body 3) | 9 | 30.5% |
| 7 (body 4) | 15 | 52.3% |
| 8 (body 5) | 16 | 53.2% |
| 9 (body 6, signature) | 40 | 89.3% |

Expected differences: the exemplar's pleading page has an ECF header (`Case 4:26-cv-00213-RGE-HCA Document 14-1 Filed 08/11/26 Page N of 40`), added by the court and not part of our render; the exemplar's TOC and TOA are full (ours list only the sample's headings and authorities); the exemplar's body carries pages 2 to 32, ours carries 1 to 6 of a transcription. The page pairing is coarse, so pages 2 and 3 (the TOC and TOA) pair with exemplar pages that share few words; the overlay is a diagnostic, not a score.

## Gate 2 review (every page of the final PDF, rendered at 60 dpi and looked at)

sha256 of the reviewed PDF: `bdd908b4e8160476161a897332121e9da8a6ef176f573d15a910c9c248bf2c44`. Re-rendered 2026-10-14 for the fonts pass (no font change then: the template kept EB Garamond); all 9 pages were rendered at 60 dpi and looked at again on this PDF, and the layout matches the rows below. The earlier PDF's hash (`6ff6a834…`) is not reproducible because typst stamps a creation date into each render.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 (cover, i) | exemplar p.1 | Court title, caption, `Case No.`, title in bold caps, `ORAL ARGUMENT REQUESTED`. The title's first line was indented (the paragraph's first-line indent applied to the caption); fixed. | FIXED (first-line indent in the caption column); PASS after the fix |
| 2 (TOC, ii) | exemplar p.ii | Entries INTRODUCTION 1, FACTUAL BACKGROUND 1, ARGUMENT 3, I. 3, CONCLUSION 5; the page numbers match the body pages (checked against the rendered body). Exemplar lists more headings; the sample has fewer. | PASS |
| 3 (TOA, iii) | exemplar p.iii–vii | Cases group only (the sample cites no statutes or rules in the text it transcribes). Long citations wrapped and their page numbers wrapped onto a second line; the page numbers now have their own column. | FIXED (TOA page-number column); PASS after the fix |
| 4 (body 1) | exemplar body p.1 (PDF p.8) | INTRODUCTION centered bold; first-line indent; `FACTUAL BACKGROUND` heading; footnote 1 at the foot. | PASS |
| 5 (body 2) | exemplar body p.2 (PDF p.9) | Block quotation (Cookie Banner) single spaced and indented; the `(E.g., …)` continuation has no first-line indent, as in the exemplar; footnotes 2 and 3 at the foot. | PASS |
| 6 (body 3) | exemplar body p.3 (PDF p.10) | Privacy Policy block quotation; `ARGUMENT` centered; `I.` heading with hanging indent; footnote 3 (hyperlinks note). | PASS |
| 7 (body 4) | exemplar body p.7–8 (PDF p.14–15) | Continuation of Argument I; the block quotation from *Jones*; the `Id.` and `See, e.g.` signals in italic; `Arndt` reasoning. | PASS |
| 8 (body 5) | exemplar body p.8–9 (PDF p.15–16) | The remaining argument paragraphs; `CONCLUSION` centered; the conclusion sentence. | PASS |
| 9 (body 6) | exemplar body p.32–33 (PDF p.39–40) | `Dated:` on the left; the signature block at the caption's party column (`/s/ Matthew A. McGuire`, both offices, `ATTORNEYS FOR DEFENDANT GRINNELL COLLEGE`). The signature falls alone on page 6 because the conclusion ends page 5; the exemplar does the same. | ACCEPTED: tier 2 choice, as in the exemplar |

Every page is recorded above; none is `OPEN`.

## Known gaps and open choices

1. **TOC on the first page (LR 10(b)(4)).** The rule says a brief of more than 10 pages "must include, on the first page, a subject matter table of contents." This template puts the TOC on page ii, after the cover (the exemplar does the same). The cover carries the caption, which takes most of the first page. **Question for David:** does the court read "first page" as the first page of the brief (the caption page), in which case the TOC must share page 1 with the caption; or as the first page after the cover, as the exemplar and this template do?
2. **Oral argument in the conclusion (LR 7(c)).** The caption carries `ORAL ARGUMENT REQUESTED` (from `oral_argument`). The rule also requires it in the conclusion; that is author content, and the template cannot check the wording.
3. **Page limit (LR 7(h)).** The exemplar's body runs 32 pages (pages 1 to 32, then the signature on page 33). The Local Rules set a 20-page limit for a brief, excluding the TOC, TOA and signature block, unless another limit is set or leave is granted. The exemplar was filed as is; whether leave was granted is not shown in the copy. The template does not count pages. The sample is 6 body pages.
4. **Typeface.** The Local Rules give no typeface rule (checked 2026-10-14 against the Local Rules PDF's text layer; LR 10(b) lists none). So no court face applies, and the template uses Times New Roman 12 pt (footnotes 12 pt), the house standard (`docs/FONTS.md`, rule 6), as the exemplar is set. It was EB Garamond before.
5. **Certificate of service (LR 5(a)).** The exemplar has none (service is by ECF notice). A certificate is required where a paper is served otherwise; LR 5(a) requires the time and manner of service and one of: a written acknowledgment, a certification by a member of the bar, or a declaration under 28 U.S.C. § 1746. Not generated.
6. **Exemplars: one filer.** EVAL-LOOP tier 2 asks for two or three filers. The search (CourtListener RECAP, `type=r`, `court=iasd`, query "motion to dismiss") found Randolph v. Iowa Health System (4:26-cv-00347), whose PDF is a Central District of Illinois filing (4:26-cv-04110), so it was rejected. Hanfling is the only S.D. Iowa brief used. Tier 2 is therefore **not judged against two filers** for this doc type.
7. **Sample excerpt.** The sample is the cover, the introduction, the factual background, the start of Argument I (from the paragraph beginning "A plaintiff must plead facts," which is the exemplar's page 7; the paragraphs before it on page 6 are not transcribed), and the conclusion, with the signature. Arguments I (the rest), II, III and IV are not transcribed; the authorities cited only there are not in the TOA. The TOA is therefore a partial list of the sample's authorities, not the exemplar's full TOA.
8. **Tool checks not run.** Same reason as the complaint: `tools/check.sh` expects a court folder.
9. **File names.** The brief asked for `usage/<id>.md`, `usage/<id>.pdf` and `<id>-overlay.pdf`. The repo's file-role names are used instead: `usage/INPUT-<id>.md` (input), `usage/OUTPUT-<id>.pdf` (render), `usage/OVERLAY-<id>.pdf` and `.txt` (overlay), because `tools/render.sh` and `tools/overlay.sh` read and write those names by default and are shared tools.
10. **Argument I has no subheadings in the sample**, so the `A.`/`B.` heading levels are not exercised by this sample. They are exercised by the CAND motion template, which is the same heading code.

## Engines

Doc type `motion-brief`, in this folder. The typst template above is the primary engine and is unchanged.

| Engine | State |
|---|---|
| typst | `typst/`, as above. |
| latex | not built in this change (`latex/` has no template for this doc type). |
| docx | `docx/reference.xml` (the Word styles; fb render builds `reference.docx` from it, `tools/fb/src/docxref.rs`) and `docx/iasd-motion-brief.lua`, rendered by fb render's multi-pass docx engine (`tools/fb/src/docxpass.rs`: pandoc, the footers, LibreOffice, repeated until the table pages stop changing). `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` are written by `tools/render.sh --engine docx`; `tools/check.sh --engine docx` passes (fb-595.57, 2026-10-21). The table of contents and table of authorities pages (ii, iii) of the `.docx.pdf` were viewed. |

**docx: what the template sets, from the same parameters as the typst form.** Letter paper, 1-inch margins; Times New Roman 12 pt; body at 24 pt exact line spacing with a half-inch first-line indent; footnotes and block quotations single-spaced at 12 pt (the block quotation indented 0.5 in on both sides); level 1 headings centered bold capitals; levels 2 to 4 bold with a hanging label (`I.`, `A.`, `1.`, typed by the filter, a half inch hanging); the front matter (cover, table of contents, table of authorities) in its own section numbered `i`, `ii`, ..., and the body numbered from 1 at the bottom centre; the cover caption as a borderless table with a right and bottom rule on the party column, the case number, the title, and `ORAL ARGUMENT REQUESTED` when `oral_argument` is true; the table of authorities grouped Cases, Statutes, Rules, Other Authorities, built from the `toa:` links, each authority's name in italics; the signature block with the date at the margin and the lines at 3.45 in. The `.docx` passes the zip and XML checks in `tools/render-docx.sh` and reads back in pandoc with the same text and footnotes. LibreOffice converts it; it has **not** been opened in Word, so "no repair prompt" there is unverified.

**docx: what differs, or is not verified.**
- Pagination is LibreOffice's. Word may break lines and paginate differently (`docs/DOCX.md`).
- The table of contents and table of authorities pages are measured in the LibreOffice PDF: the filter writes a needle for every heading and citation, and each pass reads the pages of the one before. Each entry ends in a right tab with dot leaders and its page; an authority on five or more pages reads `passim`.
- Headings are labelled by the filter (`I.`, `A.`, `1.`) from the heading order, as the typst template numbers them; a heading style change in Word does not renumber them.
- Lettered and numbered list items are not used in this brief's sample; `docx/iasd-motion-brief.lua` does not number lists.
- Fonts: the docx names Times New Roman; it must be installed on the machine that opens the file, or Word substitutes silently (`docs/DOCX.md`).
- The footers (`rIdFtrPage`) are written by fb render; a `.docx` built by plain `pandoc` has no page numbers.

**docx: BLOCKED**: none. The `.docx` has not been opened in Word.
