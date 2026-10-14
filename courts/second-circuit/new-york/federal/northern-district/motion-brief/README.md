# nynd: motion-brief

Doc type: **motion-brief**, the memorandum of law in support of a motion (here a Fed. R. Civ. P. 12(b)(6) motion to dismiss), in the United States District Court for the Northern District of New York (`nynd`).
Folder: `courts/second-circuit/new-york/federal/northern-district/motion-brief/` (self-contained; the court root `typst/` and `samples/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-mistry-3-26-cv-01419-motion-brief.pdf` (1 filer: defendants' counsel Bond, Schoeneck & King, PLLC; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-mistry-motion-brief.md`: cover, preliminary statement, factual background (A and B, with footnote 1), argument standard, Point I, Point II.A.1 to II.A.3 (with footnote 2), conclusion, signature block. The filed table of authorities is not transcribed (see Known gaps 2). |
| render | ok: `samples/OUTPUT-mistry-motion-brief.pdf`, 10 pages (cover, contents, 8 body pages), typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-mistry-motion-brief.pdf` and `OVERLAY-mistry-motion-brief.txt` (the tools' names; see Known gaps 10) |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

Primary source: N.D.N.Y. Local Rules of Practice (2025 edition, effective 2025-01-01), <https://www.nynd.uscourts.gov/sites/nynd/files/local_rules/Local%20Rules%202025_Final.pdf>. Fetched and text-extracted 2026-10-14. L.R. 7.1 and 10.1 read "Amended January 1, 2024". The search index also lists a 2026 edition that I did not check; re-verify before filing.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| L.R. 7.1(b)(1) | "No party shall file or serve a memorandum of law that exceeds twenty-five (25) pages in length, double-spaced, unless that party obtains leave of the judge hearing the motion." | `max-pages = 25`. The check at the end reads the body's page count (from PRELIMINARY STATEMENT to the end of the signature block) and fails the render above the limit. A `leave.pages` frontmatter value replaces the limit. Negative test run 2026-10-14: `leave.pages: 2` on the 8-page body fails with "allows 2 without leave". |
| L.R. 7.1(b)(1) | "All memoranda of law shall contain a table of contents and numbered pages." | `toc()` is generated from the headings (`outline`), with page numbers; body pages numbered from 1; front matter numbered i, ii. |
| L.R. 7.1(b)(1) | "When a moving party makes a motion based upon a rule or statute, the moving party must specify in its moving papers the rule or statute upon which it bases its motion." | `motion_basis` frontmatter is required (assert). Negative test run 2026-10-14: missing `motion_basis` fails the render. The rule is also stated in the body (sample: "Rule 12(b)(6)"). |
| L.R. 7.1(b)(2) | An affidavit is not required for a motion under Fed. R. Civ. P. 12(b)(6). | Not produced (no affidavit in the template). |
| L.R. 7.1(b) | Papers required: memorandum of law, Notice of Motion (for dispositive motions), proof of service. | Only the memorandum is produced here. The Notice of Motion (which must state the grounds for any oral-argument request, L.R. 7.1(b)(5)) and the proof of service are separate filings. |
| L.R. 10.1(a)(1)–(4), (a)(7) | 12-point type including footnotes; one-inch margins; double-spaced body; block quotations and footnotes may be single-spaced; consecutive page numbers. | `type-size`, `margin`, `body-leading`, `single-leading`, page numbering (see the complaint README for the same rows). |
| L.R. 10.1(b)(1) | 8½ × 11 inch paper for paper filings. | `paper: "us-letter"`. |
| L.R. 10.1(c)(1) | Caption: title of the Court, title of the action, civil action number, the assigned judge's initials, and the name of the paper. | `caption(meta)`; `judges` required (assert). |
| L.R. 10.1(c)(2) | Filer identification: signature, typed name, bar roll number, office address, telephone and e-mail. | `firm-block` (cover) and `signature-block`; `bar_roll` required for each signer (assert). |
| L.R. 5.1(a) | Papers in the form prescribed by L.R. 10.1. | Whole template. |

## Layout

- Cover (page 1, no page number): court title top left, caption with a rule above and below the party block, "Case No. ... (judges)" in the right column, the title of the paper in bold capitals at the middle of the page, and the firm block (name, signing attorneys with bar roll and e-mail, address, telephone, role in italics) at the lower right.
- Table of contents (page i): generated from the headings, single-spaced entries with dot leaders; the "TABLE OF CONTENTS" heading is not itself an entry.
- Body (page 1 onward): level 1 headings centered in capitals (a POINT heading wraps to two lines and the text stays on the 24 pt grid); level 2 centered bold; level 3 bold left (the A., B. and 1., 2. subsections). Paragraphs: 0.5 inch first-line indent, double-spaced, not numbered. Bullets: markdown `-` lists, double-spaced. Block quotations: single-spaced, indented 1 inch on each side (style set, not exercised by this sample).
- Footnotes: markdown `[^n]` references with `[^n]:` definitions at the end of the document; 12-point, single-spaced (rendered and checked: footnotes 1 and 2 appear at the foot of the page of their reference).
- Signature block after the conclusion: the date at the left; the firm name in bold capitals, a signature line, each signer's typed name, bar roll number and e-mail, the address, the telephone number and the role line in italics, at the right.
- Footer: centered page number (roman on front matter, arabic on the body).

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`; `judges`; `caption.parties` (list of `{names, designation}`); `caption.between` (`v.`); `brief_title`; `motion_basis` (required); `counsel_role`; `signature` (`dated`, `firm`, `signers` list of `{name, bar_roll, email}`, `address` lines, `phone`); optional `leave.pages` (the leave-granted page limit).
- Body: one markdown document (not chunked), so footnote references and definitions resolve. `#` for level 1, `##` for level 2, `###` for level 3 headings; blank-line-separated paragraphs; `-` bullets; `>` quotations.

## Known gaps and open choices

1. **One exemplar.** EVAL-LOOP tier 2 asks for 2 or 3 filers. The CourtListener search (`type=r`, `court=nynd`, 2026) found other motion papers (replies, notices of motion, a letter request for a 40-page limit on a motion to dismiss) but I did not collect a second memorandum by a different filer, such as a plaintiff's opposition. Tier 2 is therefore not judged against two filers. Open.
2. **Table of authorities.** The filed memorandum has a table of authorities (pages i to iv). L.R. 7.1(b)(1) requires a table of contents, not a table of authorities, so the template has none, and the sample does not transcribe the filed one. A professional brief usually carries one, and a manual TOA with page references is not generated; whether to add it is a question for David. Open (tier 2).
3. **Italics.** Case names and signals are set in roman in the sample. The filed PDF uses an italic font (TimesNewRomanPS-ItalicMT) but its text layer carries no italic markup, so I did not guess which words are italic. The template does support `*...*` italics. Open (tier 2/3).
4. **Bar roll numbers.** The filed memorandum's signature block has no bar roll number, but L.R. 10.1(c)(2) requires one. The rule governs. The sample carries `Bar Roll No. [to be supplied]` for each signer. The cover also prints the bar roll (the filed cover does not). L.R. 10.1(c)(2) applies to each document, so the cover is kept as it is.
5. **Signature line.** The template draws a blank signature line after "By:". The filed memorandum types "/s/" and the attorney's name. The template does not print "/s/". Open (tier 2, minor).
6. **Typeface.** As the complaint README, item 4: EB Garamond is the only vendored font; the filed exemplar is Times New Roman, which looks larger at 12 point. The 12-point minimum is met. Open for David.
7. **Alignment.** Body text is ragged right; the exemplar's justification could not be read from its text layer. Not asserted.
8. **Sample length and coverage.** The sample is an excerpt: the filed memorandum's body is 25 pages, its signature block on the last; the sample's body is 8 pages and covers preliminary statement, factual background A and B, the argument standard, Point I, Point II.A.1 to II.A.3 and the conclusion. Points II.B onward and Points III to VII are not transcribed. The body would have to exceed 25 pages before the template's check fails.
9. **Block quotations.** The style is set in the template but no block quotation is in the transcribed portion, so it has not been seen in a render.
10. **Overlay names.** `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt`, and `tools/render.sh` writes `OUTPUT-<id>.pdf` from `INPUT-<id>.md`. The brief's `<id>.md` and `<id>-overlay.pdf` names were not used, to match the tools and the repo's role-prefix convention.
11. **Overlay pairing** is by word overlap and skips pages the sample does not contain. Some pairs are weak (for example ours p.5 pairs with filed p.14 at 29.7%, because the sample's text there is a partial transcription). The overlay is a diagnostic, not a score.
12. **Check scripts not run.** As the complaint README, item 10: `tools/check.sh` and `tools/check-selftest.sh` expect `court.json` and `rules.md`, which this folder does not have, and the brief forbids editing `tools/`.
13. **Negative tests** (run 2026-10-14): missing `motion_basis` and `leave.pages: 2` each exit 1 with the rule message. The complaint folder has the judges' and bar roll tests.
14. **Accepted layout note.** PDF page 7 (body page 5) ends with white space because the POINT II heading, the A. heading and the 1. heading are kept together and move to the next page with their first paragraph.

## Review of the rendered pages (Gate 2 equivalent)

Every page rendered at 60 dpi and looked at after the last template change. Page numbers below are PDF pages (page 1 is the cover, page 2 the contents, body page n is PDF page n+2).

- Page 1 (cover): court title; caption with rule above and below the party block; case number with judges' initials at the right; title centered at the middle of the page; firm block at the lower right with bar roll placeholders and the role line. Pass.
- Page 2 (contents): "TABLE OF CONTENTS"; entries for PRELIMINARY STATEMENT, FACTUAL BACKGROUND (with A and B), ARGUMENT, POINT I, POINT II (with A, A.1, A.2, A.3), CONCLUSION; dot leaders and page numbers in roman front matter. Pass.
- Page 3 (body 1): PRELIMINARY STATEMENT, two paragraphs double-spaced, first-line indents, no heading at the foot. Pass.
- Page 4 (body 2): FACTUAL BACKGROUND with its first paragraph and footnote 1 at the foot; heading A. kept with its first paragraph (fixed: the first version overlapped the paragraph above). Pass.
- Page 5 (body 3): A. continued, B. heading, ARGUMENT with the Iqbal and Twombly paragraph, POINT I heading on two lines with a full double-spaced line after it (fixed: the first version had no space after the heading). Pass.
- Page 6 (body 4): Point I continued with the Article 78 citations. Pass.
- Page 7 (body 5): Point I's last paragraphs, the conclusion of Point I. Pass.
- Page 8 (body 6): POINT II heading on two lines, A. and A.1 headings, the three-item bullet list of time-barred acts, A.2 heading and paragraph. Pass.
- Page 9 (body 7): A.2 continued, A.3 heading, national-origin paragraphs, footnote 2 at the foot. Pass.
- Page 10 (body 8): "The speaker:" paragraph, CONCLUSION, date, firm block with signature line, signers, address, telephone, role. Pass.

[Formbook index](../../../../../../README.md)
