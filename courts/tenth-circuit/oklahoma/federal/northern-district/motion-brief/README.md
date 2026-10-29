# N.D. Okla. (oknd): motion brief

Doc type: **motion with brief in support** (one filed document: a motion to dismiss and the memorandum supporting it) in the United States District Court for the Northern District of Oklahoma. Folder: `courts/tenth-circuit/oklahoma/federal/northern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the full filing (caption, motion, summary, facts, standard, three propositions, GTCA section, conclusion, signature, footnotes 1-2, certificate of service) |
| typeface | face required: none (LGnR2-4(a) sets a 12-pt floor and names no face). **Times New Roman 12 pt** (vendored; `("Times New Roman", "Liberation Serif")`), the house standard (`docs/FONTS.md`) and the exemplar's face, on both engines. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` and `usage/OUTPUT-motion-brief.docx.pdf`, 13 pages each, typst 0.15.0 and LibreOffice, vendored Times New Roman only, no warnings |
| cross-engine | the docx breaks every line and page as typst does: `fb check --engine docx` XENG-001..003 PASS (303/303 lines, 13 = 13 pages), `params.cross_engine: gate` in `eval.yaml` (fb-595.68.33) |
| pages reviewed | 13 of 13 typst and 13 of 13 docx (every page rendered at 50 dpi and viewed side by side) |

## Governing rules

Primary sources, all fetched 2026-10-14.

| ID | Rule | Requirement | Source | Where in the template |
|---|---|---|---|---|
| OKND-FORM-001 | LGnR2-4(a) | "All papers ... must be double-spaced, if typewritten." | 2026 Local Rules, p. 9: https://www.oknd.uscourts.gov/sites/default/files/2026-07-31%20Local%20Rules.pdf | `pitch-body` = 27.6 pt: the face's own double spacing (twice Times New Roman's 13.8 pt single line, what a word processor's "Double" sets at 12 pt), in typst and in the docx (552 twips). |
| OKND-FORM-002 | LGnR2-4(a) | "The print style, including footnotes, must not be smaller than 12-point font." | same | `type-size` = 12 pt (body, block quotations), `note-size` = 12 pt (footnotes; docx Footnote Text 24 half points), `footer-size` = 12 pt. |
| OKND-FORM-003 | LGnR2-4(a) | 8½ × 11 inch paper, one side; "margins must be a minimum of one inch on the top, bottom, and sides"; "The use of 'Exactly 24 pt' spacing is not permitted"; "clearly legible." | same (rule text re-read 2026-10-22) | `margin` (1 in), letter page. No 24 pt pitch anywhere: the body is 27.6 pt, true double spacing of the face. The docx states it as exact 27.6 pt line boxes (the cross-engine model; see gaps). |
| OKND-MOT-001 | LCvR7-1(b) | "A motion and the brief in support may be filed as one document if clearly stated in the title of the pleading." | 2026 Local Rules, p. 31 | The title is in the cover (`title` in the frontmatter); the template does not check its wording. The sample's title says "Motion to Dismiss and Brief in Support". |
| OKND-MOT-002 | LCvR7-1(d) | Opening briefs are limited to 25 pages absent leave; "Briefs exceeding fifteen pages shall be accompanied by an indexed table of contents ... and an indexed table of statutes, rules, ordinances, cases, and other authorities cited." | 2026 Local Rules, pp. 31-32 | `toc_toa: true` in the frontmatter adds an indexed TOC and TOA (built from `toa:` links). The template does not count pages; the author sets the flag for any brief over 15 pages. |
| OKND-CAP-001 | Fed. R. Civ. P. 10(a) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." | https://www.law.cornell.edu/rules/frcp/rule_10 (verified 2026-10-14). A motion is not a pleading; the form follows the court's filings and the exemplar. | `court-title()`, `caption-table()`, the title in `cover()`. |
| OKND-MOT-003 | Fed. R. Civ. P. 12(b)(1)-(6) | Defenses "may be asserted ... by motion"; "A motion asserting any of these defenses must be made before pleading if a responsive pleading is allowed." | https://www.law.cornell.edu/rules/frcp/rule_12 (verified 2026-10-14) | Author content (the sample's stated grounds: 12(b)(1), (5), (6)). |
| OKND-MOT-004 | Fed. R. Civ. P. 5(d)(1)(B) | "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system." | https://www.law.cornell.edu/rules/frcp/rule_5 (verified 2026-10-14) | `certificate` in the frontmatter: a certificate of service on its own page, required when any party is served outside ECF (the exemplar serves a pro se plaintiff by mail). |
| OKND-CONT-001 | LCvR5.2-1; Fed. R. Civ. P. 5.2 | Personal data identifiers are redacted by counsel and the parties. | 2026 Local Rules, p. 29 | Author responsibility. |

Not produced by this template: the proposed order (LCvR7-1(c), "A separate proposed order shall be submitted"), any declarations or exhibits, and any Local Rule 7.1 / LCvR7.1-1 disclosure statement.

## Layout

The numbers are in `typst/oknd-motion-brief.typ` (Parameters) and, in twips, in `docx/oknd-motion-brief.lua` and `docx/reference.xml`; both engines lay the page out on the shared cross-engine model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`: every line a box of its pitch, the space between blocks the larger of the two, first-fit breaks, no kerning, ligatures or hyphenation).

- Plain page, no line numbers, no pleading rules. Footer: the page number centred at 12 pt in a single line whose box ends 0.5 in above the page edge. One continuous Arabic sequence from the caption page (the exemplar counts its caption page as page 1).
- Times New Roman 12 pt. Body lines 27.6 pt apart (the face's double spacing, LGnR2-4(a)); the court name, caption, title, headings, block quotations, signature block and footnotes in single 13.8 pt lines.
- Cover on page 1, body begins under the title on the same page (no forced page break): the court name (two centered bold lines), a blank double line, the caption (parties in the left column, each side's designation 1.8 in in, "v." centred between sides, the column ruled down its right and across its foot; "Case No." on the right, centred on the party column's height), and the title (bold, centered, 27.6 pt below the caption, 13.8 pt above the body). No hearing line and no counsel block at the top: neither the local rules nor the exemplar requires them; counsel appears in the signature block.
- If `toc_toa` is true, a TOC and a TOA follow the cover, each on its own page, and the body follows (typst only; rows on the shared `listing-row`: the text wraps before a 36 pt (contents) or 56 pt (authorities) page column, a dot leader to the page number).
- Headings: level 1 is centered bold caps and unnumbered (SUMMARY OF ARGUMENT, ARGUMENT AND AUTHORITY, CONCLUSION). Levels 2-5 are numbered by the template (I., A., 1., a.), bold, the label in a 0.5 in box at the level's indent (0, 0.5, 1, 1.5 in), the lines after the first hanging after it. Single-spaced, a blank single line above and below, kept with their text.
- Body paragraphs: double-spaced, no space between them, 0.5 in first-line indent (also after a heading, as in the exemplar). Not numbered (motions are not numbered-paragraph pleadings). A paragraph that anchors a footnote has no widow or orphan rule (typst `costs` 0, docx "Body Text Note"), so the line with the mark moves on with its note.
- Block quotations (`>`): each paragraph single-spaced, indented 0.5 in on both sides, a blank single line above and below the quotation.
- Footnotes: 12 pt, single-spaced (13.8 pt), 6 pt between notes, under a 2 in rule.
- A web address breaks only after a slash before a letter, each piece between kept whole (typst would otherwise break inside it where Word does not).
- Signature block (single-spaced, on one page, kept with the last paragraph): "Dated:" at the left margin when `date` is given and "Respectfully submitted," 3.3 in in on the same line, then a blank double line, "/s/" and the signer's name, then the lines of the signature (OBA numbers, address, telephone, email, the party represented).
- Certificate of service: its own page, centered bold caps heading, the certifying paragraph on the body pitch, the service list indented 0.5 in, then "/s/" and the signer in the signature column.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `case_number` (string, verbatim); `caption` (list of `{names: [...], designation: "..."}`; "v." is inserted between sides); `title` (the title of the paper); `date` (optional); `signature` (`signer`, and `lines` for the signature block); `certificate` (optional: `text`, `service` lines, `signer`); `toc_toa` (optional, true above 15 pages); `authorities` (required when `toc_toa` is true: a mapping from a key to `{kind: case|statute|rule|regulation|other, name, cite}`; the body links to an authority with `[text](toa:KEY)`).
- Body: blank-line-separated chunks. `#` (level 1), `##` (level 2), `###` (level 3) and so on are headings; `>` is a block quotation; `[^n]` and `[^n]: ...` are footnotes; `*...*` is italics.
- Not supported: tables, raw typst. Do not type the heading numbers: the template numbers level 2 and deeper.

## Render and check

```sh
sh tools/render.sh courts/tenth-circuit/oklahoma/federal/northern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/render.sh --engine docx courts/tenth-circuit/oklahoma/federal/northern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/check.sh courts/tenth-circuit/oklahoma/federal/northern-district/motion-brief --engine typst   # 10 passed, 0 failed
sh tools/check.sh courts/tenth-circuit/oklahoma/federal/northern-district/motion-brief --engine docx    # 14 passed, 0 failed (XENG-001..003 PASS)
just overlay courts/tenth-circuit/oklahoma/federal/northern-district/motion-brief                      # .overlay/, not committed
```

`eval.yaml` sets `params.page_limit: 25` (LCvR7-1(d), opening and response briefs; the check counts every page, so it is stricter than the rule) and `params.cross_engine: gate`.

The TOC/TOA path is not exercised by the committed sample (the brief is 13 pages). It was tested on typst with a temporary sample (`toc_toa: true`, one authority, one `toa:` link) that rendered the TOC on page 2 and the TOA on page 3 (both pages looked at), and that temporary input was deleted. Re-run it when a brief goes past 15 pages.

The overlay is a diagnostic, not a score. The exemplar is 14 pages in Times, with a pleading-style header line on each page; the layers agree on words, not on line positions.

## Visual review (Gate 2 record, all 13 pages of both engines, rendered at 50 dpi and looked at side by side; fb-595.68.33)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court name, caption, title, opening paragraph, SUMMARY OF ARGUMENT | OK on both engines. Caption rule right and bottom; "Case No." centred on the party column. |
| 2 | SUMMARY OF ARGUMENT (end), FACTUAL BACKGROUND (start) | OK. Italic *Id.* throughout. |
| 3 | FACTUAL BACKGROUND | OK. The page ends with two lines of the footnoted paragraph. |
| 4 | "October 06, 2023.¹" (the paragraph's last line, with footnote 1 at the foot), STANDARD FOR DISMISSAL | The line with the footnote mark opens the page alone (a widow), as both engines set it: the note does not fit on page 3. OPEN (tier 2). The web address in the note breaks after "dockets/". |
| 5 | STANDARD (end), ARGUMENT AND AUTHORITY, I. (heading), footnote 2 | OK. Hanging heading label "I." at the margin. |
| 6 | Rule 4(j) block quotation, argument on service | OK. Quotation single-spaced, 0.5 in in on both sides; its paragraphs (j), (1), (2), (A), (B) have no space between them, as written in one quotation. |
| 7 | Service argument, 51 O.S. § 163(E) quotation | OK. |
| 8 | II. heading, Eleventh Amendment | OK. |
| 9 | II. (continues) | OK. "§§" kept with its number. |
| 10 | II. (end), III. heading (Younger), two-line heading | OK. |
| 11 | III. (end), IV. heading (GTCA damages) | OK. |
| 12 | IV. (end), CONCLUSION, signature block | OK. Signature block whole, kept with the conclusion. |
| 13 | CERTIFICATE OF SERVICE on its own page | OK. Service list indented, signature in the right column. |

Reviewed pages: 13 of 13 (typst) and 13 of 13 (docx); the two engines set the same words on every line and page.

## Known gaps and open choices

1. **One exemplar only.** Tier 2 of the eval loop asks for two or three filers. The CourtListener search (`type=r`, `court=oknd`, "motion to dismiss" filings from 2024 onward) also surfaced Stephens v. State of Oklahoma, 4:25-cv-00322 (doc 47, a motion to dismiss with brief, 10 pages, RECAP available), which was not downloaded. Tier 2 is **not** judged against two filers.
2. **Font and size.** Times New Roman 12 pt on both engines, footnotes included (was EB Garamond 13 pt; the docx named EB Garamond and failed DEF-FONT-002). The rule's floor is 12 pt and is met; it names no face.
3. **Footnotes single-spaced.** LGnR2-4 requires double spacing for "all papers" and a 12 pt floor for footnotes, and does not exempt footnotes from double spacing. Footnotes are single-spaced as in the exemplar. Flagged for David's call.
4. **Block quotations single-spaced.** The rule does not exempt them either; single spacing is the exemplar's convention. Flagged with item 3.
5. **Page limit.** LCvR7-1(d)'s 25-page limit is checked on the whole document (`params.page_limit: 25`, DEF-LEN-001 PASS, 13 pages); a reply or supplemental brief (10 pages) needs its own limit. The TOC/TOA requirement above 15 pages is handled by the `toc_toa` flag, which the author sets.
6. **Title wording not checked.** LCvR7-1(b) allows a motion and brief as one document "if clearly stated in the title." The template does not check the title.
7. **Case-name italics.** The text layer of the exemplar has no italic markup. The sample italicizes *Id.*, *See*, *pro se*, *supra*, *aff'd*, and case names by convention; those are not verified against the filed PDF.
8. **Content not checked.** The sample reproduces the exemplar's text, including its standard for dismissal ("no set of facts"), which the Supreme Court retired in *Bell Atlantic Corp. v. Twombly*, 550 U.S. 544 (2007). The template does not check authority or citation form (CAND-style checks are not in scope here). The sample is a transcription, not a model brief.
9. **ECF header dropped.** The exemplar's ECF header line ("Case 4:25-cv-00450-JFH-JFJ Document 43 Filed in USDC ND/OK on 11/07/25 Page n of 14") is not reproduced. The template does not generate ECF headers.
10. **Certificate of service.** Required here because one party is served by mail (FRCP 5(d)(1)(B)); not required for a paper served only through ECF. The template includes it when the frontmatter has `certificate`.
11. **Proposed order, declarations, disclosure statement.** Not produced (see Governing rules).
12. **Selftest.** `tools/check-selftest.sh` takes a court folder (with `court.json`); it does not run on this doc-type folder. `tools/check.sh` runs here (see Render and check).
13. **"Exactly" line boxes in the docx.** LGnR2-4(a) bars "Exactly 24 pt" spacing. The docx sets its body lines as exact 27.6 pt boxes (Word shows "Exactly 27.6 pt"), the true double spacing of the face and the pitch Word's "Double" gives at 12 pt; Word's own "Double" (auto) would let LibreOffice and Word place a page's last line differently from typst. Whether the clerk reads the rule as barring any "Exactly" setting, or only the compressed 24 pt one, is David's call.

## Engines

DOCX engine (`docx/`: `reference.xml`, `oknd-motion-brief.lua`; no shell, no binary reference: `fb render` builds the reference document from `reference.xml`, `base="xengine"`, the face only as `{font}`). Command: `sh tools/render.sh --engine docx courts/tenth-circuit/oklahoma/federal/northern-district/motion-brief usage/INPUT-motion-brief.md`.

- **Matches the typst form, line for line:** the filter reads the sample chunk by chunk as typst does and writes every paragraph with the typst pitch and spaces (exact 552 twips body, 276 single and footnote lines); Times New Roman 12 pt, footnotes 12 pt; the 12 pt page number in a 276-twip footer line 0.5 in above the page edge; the caption as a two-column table; heading labels I., A., 1., a. in a 0.5 in tab; block quotations paragraph by paragraph; a paragraph that carries a footnote left to pandoc in "Body Text Note" (Body Text without widow control) so that pandoc writes the note; the certificate of service from a page break. XENG-001..003 PASS: 303/303 lines and 13 = 13 pages.
- **Differs from typst:** heading labels are typed text (they do not renumber when a heading is added by hand). The caption is a Word table.
- **BLOCKED:** `toc_toa: true` (indexed TOC and TOA, LCvR7-1(d)) stops the filter with an error rather than omit them; the typst template builds them. The committed sample (13 pages) does not use it. Authority links (`toa:KEY`) are written as their text.

## On the FRCP base (fb-595.17.20, 2026-10-29)

`typst/layout.yaml` names the generic federal district brief (`base: /lib/layouts/frcp-motion-brief.yaml`, fb-595.17) and overlays only what N.D. Okla. sets itself, each rule cited there; `typst/oknd-motion-brief.typ` names the face and hands the merged layout to the shared document model (`lib/typst/xdoc.typ`). `latex/` and `docx/` are generated from the merged layout by `fb engines gen` (do not edit them; `fb engines gen --check` fails on a stale one). The per-folder typst code and the docx filter `oknd-motion-brief.lua` are gone. The Layout, Render and check, Visual review and Engines sections above describe the earlier template where they differ from this list.

- Unchanged: Times New Roman 12 pt, footnotes too; 27.6 pt double pitch, 13.8 pt single lines (LGnR2-4(a)); headings numbered I., A., 1., a. by the template in half-inch label boxes at each level's indent; block quotations half an inch in on both sides; footnotes 6 pt apart; the signature column 3.3 in in with "Dated:" at the margin; the certificate of service on its own page; the 25-page `page_limit`. The frontmatter field names are kept (`caption`, `title`, `date`, `signature.signer`/`lines`, `certificate.text`/`service`/`signer`, `toc_toa`, `authorities`).
- Caption: as the exemplar sets it, no longer ruled: each side's names, its designation a single line below 1.8 in in, "v." at the margin (was centered), "Case No.:" (the exemplar's colon; `case_label` overrides it) at the right, centered on the parties' height. DEF-COVER-002 now passes on typst, latex and docx, so the folder's two lines leave `data/cover-structure-baseline.txt`.
- The footnote rule is the model's (30 % of the measure; was 2 in).
- Tables (LCvR7-1(d)): `toc_toa: true` sets a table of contents and a listed `authorities` mapping a table of authorities (the body's `[text](toa:KEY)` links; groups Cases, Federal Statutes, Federal Rules, Federal Regulations, Other Authorities; *passim* at 7 pages) on all three engines now (the docx was BLOCKED on `toc_toa`). They come before the caption page, in the one sequence of page numbers (the model sets the tables before `front`; the earlier typst set them after the caption page). Tried on typst with a temporary sample (`toc_toa: true`, one `toa:` link to a case): contents on page 1, authorities on page 2, the caption page 3; the temporary input was deleted. A level-1 row of the contents is printed as the sample writes the heading (the heading itself is set in capitals). Tier 2, OPEN: tables before the caption page.

Gate 2 review after the move (every page of the three renders, as text layout `pdftotext -layout` and word boxes `-bbox`; this pod's image viewer could not open a PNG, so no page was looked at as a picture; the latex and docx renders break every line where typst does, XENG-003):

| Page | What is on it | Finding | Status |
|---|---|---|---|
| 1 | Court name, caption, title, the opening paragraph, SUMMARY OF ARGUMENT | none | PASS |
| 2-3 | SUMMARY (end), FACTUAL BACKGROUND | none | PASS |
| 4 | "October 06, 2023.¹" alone at the top with footnote 1 at the foot, STANDARD FOR DISMISSAL | the line with the mark moves on with its note (a widow), as before | OPEN |
| 5 | STANDARD (end), ARGUMENT AND AUTHORITY, I., footnote 2 | none | PASS |
| 6-7 | The Rule 4(j) and 51 O.S. § 163(E) quotations | single-spaced, half an inch in on both sides | PASS |
| 8-11 | II., III., IV. | none | PASS |
| 12 | CONCLUSION; "Dated:" beside "Respectfully submitted,"; the signer's block ("OKLAHOMA ATTORNEY GENERAL'S OFFICE" wraps in the 3.2 in column, as before) | none | PASS |
| 13 | CERTIFICATE OF SERVICE on its own page, the person served, the signer | none | PASS |

- typst: `RESULT: 12 checks passed, 0 failed`.
- latex: `RESULT: 15 checks passed, 0 failed`; XENG-001..003 PASS (13 pages, 303/303 typst lines break after the same word).
- docx: `RESULT: 16 checks passed, 0 failed`; XENG-001..003 PASS (13 pages, 303/303).
- `tools/check-selftest.sh` reads a court folder's `court.json`; this doc-type folder has none, so it does not run here.
- BLOCKED: none.
