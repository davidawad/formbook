# N.D. Okla. (oknd): motion brief

Doc type: **motion with brief in support** (one filed document: a motion to dismiss and the memorandum supporting it) in the United States District Court for the Northern District of Oklahoma. Folder: `courts/tenth-circuit/oklahoma/federal/northern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-gideon-4-25-cv-00450-motion-brief.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-gideon-motion-to-dismiss.md`: the full filing (caption, motion, summary, facts, standard, three propositions, GTCA section, conclusion, signature, footnotes 1-2, certificate of service) |
| typeface | face required: none (LGnR2-4(a) sets a 12-pt floor and names no face). Substitute: none needed; **EB Garamond kept** (`docs/FONTS.md`: "no face named"). Fit: not metric-compatible with the Times exemplar; visual only. |
| render | ok: `samples/OUTPUT-gideon-motion-to-dismiss.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings; `pdffonts`: EBGaramond Regular, Bold, Italic, BoldItalic embedded |
| overlay | ok: `samples/OVERLAY-gideon-motion-to-dismiss.pdf` and `samples/OVERLAY-gideon-motion-to-dismiss.txt` |
| pages reviewed | 12 of 12 (every page rendered at 70 dpi and viewed, fonts pass; see the table below) |

## Governing rules

Primary sources, all fetched 2026-10-14.

| ID | Rule | Requirement | Source | Where in the template |
|---|---|---|---|---|
| OKND-FORM-001 | LGnR2-4(a) | "All papers ... must be double-spaced, if typewritten." | 2026 Local Rules, p. 9: https://www.oknd.uscourts.gov/sites/default/files/2026-07-31%20Local%20Rules.pdf | `line-pitch` = 24 pt, `body-leading`. Measured: 24.0 pt body pitch (`pdftotext -bbox-layout`). |
| OKND-FORM-002 | LGnR2-4(a) | "The print style, including footnotes, must not be smaller than 12-point font." | same | `type-size` = 13 pt (body, footnotes, block quotations); `footer-size` = 12 pt. |
| OKND-FORM-003 | LGnR2-4(a) | 8½ × 11 inch paper, one side; "margins must be a minimum of one inch on the top, bottom, and sides"; no "Exactly 24 pt" spacing; "clearly legible." | same | `margins` (1 in), `paper: us-letter`. |
| OKND-MOT-001 | LCvR7-1(b) | "A motion and the brief in support may be filed as one document if clearly stated in the title of the pleading." | 2026 Local Rules, p. 31 | The title is in the cover (`title` in the frontmatter); the template does not check its wording. The sample's title says "Motion to Dismiss and Brief in Support". |
| OKND-MOT-002 | LCvR7-1(d) | Opening briefs are limited to 25 pages absent leave; "Briefs exceeding fifteen pages shall be accompanied by an indexed table of contents ... and an indexed table of statutes, rules, ordinances, cases, and other authorities cited." | 2026 Local Rules, pp. 31-32 | `toc_toa: true` in the frontmatter adds an indexed TOC and TOA (built from `toa:` links). The template does not count pages; the author sets the flag for any brief over 15 pages. |
| OKND-CAP-001 | Fed. R. Civ. P. 10(a) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." | https://www.law.cornell.edu/rules/frcp/rule_10 (verified 2026-10-14). A motion is not a pleading; the form follows the court's filings and the exemplar. | `court-title()`, `caption-table()`, the title in `cover()`. |
| OKND-MOT-003 | Fed. R. Civ. P. 12(b)(1)-(6) | Defenses "may be asserted ... by motion"; "A motion asserting any of these defenses must be made before pleading if a responsive pleading is allowed." | https://www.law.cornell.edu/rules/frcp/rule_12 (verified 2026-10-14) | Author content (the sample's stated grounds: 12(b)(1), (5), (6)). |
| OKND-MOT-004 | Fed. R. Civ. P. 5(d)(1)(B) | "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system." | https://www.law.cornell.edu/rules/frcp/rule_5 (verified 2026-10-14) | `certificate` in the frontmatter: a certificate of service on its own page, required when any party is served outside ECF (the exemplar serves a pro se plaintiff by mail). |
| OKND-CONT-001 | LCvR5.2-1; Fed. R. Civ. P. 5.2 | Personal data identifiers are redacted by counsel and the parties. | 2026 Local Rules, p. 29 | Author responsibility. |

Not produced by this template: the proposed order (LCvR7-1(c), "A separate proposed order shall be submitted"), any declarations or exhibits, and any Local Rule 7.1 / LCvR7.1-1 disclosure statement.

## Layout

- Plain page, no line numbers, no pleading rules. Footer: centered page number only. One continuous Arabic sequence from the caption page (the exemplar counts its caption page as page 1).
- Cover on page 1, body begins under the title on the same page (no forced page break): the court name (two centered lines), the caption (parties in the left column with a rule down the right and across the bottom; "Case No." on the right), and the title (bold, centered). No hearing line and no counsel block at the top: neither the local rules nor the exemplar requires them; counsel appears in the signature block.
- If `toc_toa` is true, a TOC and a TOA follow the cover, each on its own page, and the body follows.
- Headings: level 1 is centered bold caps and unnumbered (SUMMARY OF ARGUMENT, ARGUMENT AND AUTHORITY, CONCLUSION). Levels 2-5 are numbered by the template (I., A., 1., a.), bold, hanging from the margin. Headings are sticky.
- Body paragraphs: double-spaced, 0.5 in first-line indent (also after a heading, as in the exemplar). Not numbered (motions are not numbered-paragraph pleadings).
- Block quotations (`>`): single-spaced, indented 0.5 in on both sides.
- Footnotes: 13 pt, single-spaced, at the foot of the page.
- Signature block: "Dated:" on the left when `date` is given; "Respectfully submitted," then "/s/" and the signer's name, then the lines of the signature (OBA numbers, address, telephone, email, the party represented).
- Certificate of service: its own page, centered bold caps heading, the certifying paragraph, the service list indented, then "/s/" and the signer, at the right.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `case_number` (string, verbatim); `caption` (list of `{names: [...], designation: "..."}`; "v." is inserted between sides); `title` (the title of the paper); `date` (optional); `signature` (`signer`, and `lines` for the signature block); `certificate` (optional: `text`, `service` lines, `signer`); `toc_toa` (optional, true above 15 pages); `authorities` (required when `toc_toa` is true: a mapping from a key to `{kind: case|statute|rule|regulation|other, name, cite}`; the body links to an authority with `[text](toa:KEY)`).
- Body: blank-line-separated chunks. `#` (level 1), `##` (level 2), `###` (level 3) and so on are headings; `>` is a block quotation; `[^n]` and `[^n]: ...` are footnotes; `*...*` is italics.
- Not supported: tables, raw typst. Do not type the heading numbers: the template numbers level 2 and deeper.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/tenth-circuit/oklahoma/federal/northern-district/motion-brief samples/INPUT-gideon-motion-to-dismiss.md
sh tools/overlay.sh courts/tenth-circuit/oklahoma/federal/northern-district/motion-brief gideon-motion-to-dismiss
```

File names follow the tools: `tools/render.sh` writes `samples/OUTPUT-<id>.pdf`; `tools/overlay.sh` writes `samples/OVERLAY-<id>.pdf` and `OVERLAY-<id>.txt`. The brief's `<id>.pdf` / `<id>-overlay.pdf` names do not match the tools, and the tools are not edited here.

The TOC/TOA path is not exercised by the committed sample (the brief is 12 pages). It was tested with a temporary sample (`toc_toa: true`, three authorities, three `toa:` links) that rendered to 15 pages with the TOC on page 2 and the TOA on page 3, and that temporary input was deleted. Re-run it when a brief goes past 15 pages.

The overlay is a diagnostic, not a score. Red is our render, blue is the exemplar, black is both. Pages pair by word overlap (`OVERLAY-gideon-motion-to-dismiss.txt`): ours p.1 ↔ filed p.1 (86.4%), p.2 ↔ p.2 (71.7%), p.3 ↔ p.3 (48.2%), p.4 ↔ p.4 (39.6%), p.5 ↔ p.6 (59.6%), p.6 ↔ p.7 (81.9%), p.7 ↔ p.8 (83.4%), p.8 ↔ p.9 (66.4%), p.9 ↔ p.11 (56.2%), p.10 ↔ p.12 (82.0%), p.11 ↔ p.13 (87.5%), p.12 ↔ p.14 (86.4%). The exemplar is 14 pages in Times, with a pleading-style header line on each page; the sample is the same text in EB Garamond with no header, so the layers agree on words and not on line positions. The lower percentages (pages 3-4, 9) are where the sample's footnote and quotation layout differs from the exemplar's.

## Visual review (Gate 2 record, all 12 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court name, caption, title, opening paragraph, start of SUMMARY OF ARGUMENT | OK. Caption rule right and bottom; "Case No." vertically centered on the right. Cover and body share the page. |
| 2 | SUMMARY OF ARGUMENT (end), FACTUAL BACKGROUND (start) | OK. Italic *Id.* throughout. |
| 3 | FACTUAL BACKGROUND (end) | OK. Footnote 1 at the foot of the page, single-spaced, 13 pt. |
| 4 | STANDARD FOR DISMISSAL | OK. Page ends with space: ARGUMENT AND AUTHORITY moves to the next page with its first heading and paragraph (headings are kept with the text). |
| 5 | ARGUMENT AND AUTHORITY, I. (heading), start of the Rule 4(j) block quotation | OK. Hanging heading label "I." at the margin. Footnote 2 at the foot. |
| 6 | Rule 4(j) quotation (end), argument on service | OK. |
| 7 | Oklahoma statute block quotation (51 O.S. § 163(E)), II. heading | OK. Block quotation single-spaced and indented. |
| 8 | II. (continues), Eleventh Amendment text, Frazier/Kentucky/Peterson | OK. |
| 9 | II. (end), III. heading (Younger) | OK. |
| 10 | III. (continues), IV. heading (GTCA damages) | OK. "¶" and the paragraph number are kept together. |
| 11 | IV. (continues), CONCLUSION, signature block | OK. Signature block: "Dated" left, "Respectfully submitted," and "/s/" right. |
| 12 | CERTIFICATE OF SERVICE on its own page | OK. Service list indented, signature at the right. |

Reviewed pages: 12 of 12.

## Known gaps and open choices

1. **One exemplar only.** Tier 2 of the eval loop asks for two or three filers. The CourtListener search (`type=r`, `court=oknd`, "motion to dismiss" filings from 2024 onward) also surfaced Stephens v. State of Oklahoma, 4:25-cv-00322 (doc 47, a motion to dismiss with brief, 10 pages, RECAP available), which was not downloaded. Tier 2 is **not** judged against two filers.
2. **Font and size.** EB Garamond (vendored) at 13 pt, not Times New Roman at 12 pt. The rule's floor is 12 pt and is met. 13 pt is chosen to look like the Times 12 pt exemplar; a style choice.
3. **Footnotes single-spaced.** LGnR2-4 requires double spacing for "all papers" and a 12 pt floor for footnotes, and does not exempt footnotes from double spacing. Footnotes are single-spaced as in the exemplar. Flagged for David's call.
4. **Block quotations single-spaced.** The rule does not exempt them either; single spacing is the exemplar's convention. Flagged with item 3.
5. **Page limit not counted.** LCvR7-1(d)'s 25-page limit is not checked: the template has no page counter. The sample is 12 pages. The TOC/TOA requirement above 15 pages is handled by the `toc_toa` flag, which the author sets.
6. **Title wording not checked.** LCvR7-1(b) allows a motion and brief as one document "if clearly stated in the title." The template does not check the title.
7. **Case-name italics.** The text layer of the exemplar has no italic markup. The sample italicizes *Id.*, *See*, *pro se*, *supra*, *aff'd*, and case names by convention; those are not verified against the filed PDF.
8. **Content not checked.** The sample reproduces the exemplar's text, including its standard for dismissal ("no set of facts"), which the Supreme Court retired in *Bell Atlantic Corp. v. Twombly*, 550 U.S. 544 (2007). The template does not check authority or citation form (CAND-style checks are not in scope here). The sample is a transcription, not a model brief.
9. **ECF header dropped.** The exemplar's ECF header line ("Case 4:25-cv-00450-JFH-JFJ Document 43 Filed in USDC ND/OK on 11/07/25 Page n of 14") is not reproduced. The template does not generate ECF headers.
10. **Certificate of service.** Required here because one party is served by mail (FRCP 5(d)(1)(B)); not required for a paper served only through ECF. The template includes it when the frontmatter has `certificate`.
11. **Proposed order, declarations, disclosure statement.** Not produced (see Governing rules).
12. **Tools gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` at the court directory level. This doc-type folder is not that shape, and the brief forbids editing `tools/`. Render and overlay were run; the Gate 2 table above is the review for this doc type.

## Engines

DOCX engine (`docx/`: `reference.docx`, `oknd-motion-brief.lua`, `build-reference.sh`). Command: `sh tools/render.sh --engine docx courts/tenth-circuit/oklahoma/federal/northern-district/motion-brief samples/INPUT-gideon-motion-to-dismiss.md`.

- **Matches the typst form:** EB Garamond 13 pt body and footnotes (footnote text single-spaced), 12 pt centered page number, 1 in margins on letter paper, double-spaced body with 0.5 in first-line indent, the cover (two-line court name, caption with rule, bold centered title), level-1 headings centered bold caps and unnumbered, levels 2-5 labeled I., A., 1., a. with hanging indents, single-spaced block quotations indented 0.5 in both sides, the signature block, and the certificate of service on its own page.
- **Differs from typst:** line pitch is "double" rather than exactly 24 pt. The caption and signature block are Word tables. Heading labels are typed text. Heading spacing is 12 pt before and after at single line spacing. Word may paginate differently.
- **Not built (fails loudly):** `toc_toa: true` (indexed TOC and TOA, LCvR7-1(d)) stops the filter with an error. The committed sample is 12 pages and does not use it. Authority links (`toa:KEY`) are written as plain text.
- **Output:** `samples/OUTPUT-gideon-motion-to-dismiss.docx` is written. `render-docx.sh` then exits 1 (see below).
- **BLOCKED:** `docx.pdf` (LibreOffice PDF, check gates 0-3): `soffice` is not installed on this box and cannot be installed without root or conda-forge. Visual review of the docx pages: needs the same PDF; 0 docx pages reviewed. `unzip` is not installed, so the zip-integrity step of `tools/render-docx.sh` fails after the `.docx` is written. The XML parts were checked instead with `ziptool` and `xmllint` (15 of 15 well-formed). Opening in Word and LibreOffice without a repair prompt: not done. TOC and TOA: BLOCKED for any brief over 15 pages (see above).
