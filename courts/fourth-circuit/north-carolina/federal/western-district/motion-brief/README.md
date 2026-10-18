# ncwd: motion-brief

Doc type: **motion-brief** (the memorandum of law supporting a motion to dismiss under Fed. R. Civ. P. 12(b), with the
court's required certifications) in the United States District Court for the Western District of North Carolina (`ncwd`).
Folder: `courts/fourth-circuit/north-carolina/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-ncwd-motion-brief-noble526cv00006.pdf` (25 pages, one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-ncwd-motion-brief-noble.md`: a portion of the memorandum (caption, opening, statement of the case, part of the facts, standard of review, arguments I to IV in part, conclusion, signature, AI certification, certificate of service) |
| render | ok: `usage/OUTPUT-ncwd-motion-brief-noble.typst.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`) |
| overlay | ok: `usage/OVERLAY-noble-motion-brief.pdf` and `usage/OVERLAY-noble-motion-brief.txt` (`tools/overlay.sh`) |
| typeface | face required: none named (LCvR 7.1(d) sets a 12-point minimum only; a judge's standing order may set a face). Substitute: none; **EB Garamond kept** per `docs/FONTS.md` ("No face named"). Metric-compatible: n/a. |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change; re-checked 2026-10-14 with the font pass, no template change) |

File names follow the tools' defaults (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf/.txt`) rather than the
`<id>.md` / `<id>-overlay.pdf` names in the task brief, because `tools/render.sh` and `tools/overlay.sh` read and write
those names. The overlay is a diagnostic, not a score.

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCvR 7.1(c) (W.D.N.C. Local Civil Rules, as revised effective 2022-12-01; https://www.ncwd.uscourts.gov/sites/default/files/local_rules/Revised%20Local%20Rules%20120122.pdf, printed p. 13; fetched and read 2026-10-14) | A brief is filed with the motion, contemporaneously. Factual contentions are supported by citation to the exhibit number and page. | Content; the template does not check citations. |
| LCvR 7.1(d) (same PDF, printed p. 14) | Absent a judge's Standing Civil Order or Case Management Order: the page limit for any brief is 25 pages; font at least 12 point; lines double-spaced; one-inch margins; each page numbered. | `type-size = 12pt`, `margin = 1in`, `body-leading` (double spacing), `page-number()` in the footer. The 25-page limit is not counted by the template (see Known gaps). |
| LCvR 7.1(j) (same PDF, printed p. 15) | Notice of supplemental authority: at most two pages, no argument. | Not produced (a separate filing). |
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10, fetched 2026-10-14) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `court-title`, `caption`. |
| Fed. R. Civ. P. 11(a) (https://www.law.cornell.edu/rules/frcp/rule_11, fetched 2026-10-14) | Every paper is signed by an attorney of record, who states the address, e-mail address and telephone number. | `signature-block()`: date line, then each firm's "By: /s/" block with the lines the sample gives. |
| Standing Order of June 18, 2024, *In re: Use of Artificial Intelligence*, No. 3:24-mc-104 (W.D.N.C.) | A certification that no artificial intelligence was used in the research (except AI built into Westlaw, Lexis, FastCase, Bloomberg, Google and Google Scholar) and that every citation was checked. | `ai-certification(meta)`, printed when the sample sets `ai_certification: true`. **Wording taken from the exemplar, not from the order** (see Known gaps). |

Primary sources for LCvR 7.1 and the Rules: as listed. The standing order's text was not fetched: the only source
seen was a PACER docket listing for 3:24-mc-104, and secondary summaries (Ropes & Gray's AI court-order tracker, and
North Carolina Lawyers Weekly, July 2024). Those summaries agree on the date, the research carve-out, and the
certification's two parts. They do not quote the order.

## Layout

- US Letter, one-inch margins on all four sides, 12 pt EB Garamond (vendored in `fonts/`; no face is named by the rules, so it stays per `docs/FONTS.md`).
- First page: the court title (UNITED STATES DISTRICT COURT / FOR THE WESTERN DISTRICT OF NORTH CAROLINA / the division),
  then a caption: the party column with one line per row, a ")" column the same height, and the right column with
  "Civil Action No." and the title lines.
- Double spacing is a 27.6 pt pitch (single line 13.8 pt, body leading 1.65em), the same as the filed exemplar
  (`pdftotext -bbox`: baselines 27.6 pt apart in both). Paragraph spacing equals the leading, because a paragraph's
  last line takes no leading of its own.
- Body paragraphs: unnumbered (a brief is not a pleading), first-line indent 0.5 in.
- Headings: level 1 centered bold caps (the sections: STATEMENT OF THE CASE, ARGUMENT, CONCLUSION); level 2 bold, left
  (argument headings such as "I. ..."); level 3 bold italic, left. Headings are single-spaced, each with a 24 pt space
  above, and stay with the text after them.
- Signature: the date line at the left ("This the 13th day of March, 2026."), then the firm block at the right half,
  "By: /s/" for the signer, the other counsel and the address, e-mail and telephone.
- AI certification (when the sample asks): a centered heading, the standing order's introduction, the two numbered
  statements, the date and a signature block. Printed after the first signature block, as in the exemplar.
- Certificate of service (when the sample has `service`): a centered heading, the CM/ECF sentence with the filing's
  title in caps (`service_title`), each counsel served as a block, the date and the signature block.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `case_number`, `division`, `caption.parties` (list of
  `{lines: [...], designation}`; "v." is inserted between the parties; each entry in `lines` is one printed line and must
  not wrap in the 2.9 in party column), `title` (list of bold lines), `service_title` (the filing's title in caps, for
  the certificate of service), `ai_title` (the filing's title in sentence case, for the AI certification),
  `ai_certification` (true or absent), `signature` (`date_line` and `blocks` of `{firm, by, lines}`), and `service`
  (`counsel`: a list of counsel blocks, each a list of lines).
- Body chunks separated by blank lines: `#` heading (level 1), `##` (level 2), `###` (level 3); a `1.` list; a `>`
  chunk (no first-line indent); or a plain paragraph (first-line indented).
- Not supported: footnotes, tables, raw typst. Italics (`*...*`) and `_..._` work through the markdown renderer.
- The template's own certification wording (the AI certification) and section headings are case-neutral; the
  case-specific words are only in the sample.

## Overlay

`usage/OVERLAY-noble-motion-brief.pdf` shows the render in red and the filed page in blue; black where they agree.
The text map (`OVERLAY-noble-motion-brief.txt`) pairs each rendered page with the filed page that shares the most
words. The sample is an excerpt: rendered pages 7 to 9 (conclusion, AI certification, certificate of service) pair with
filed pages 23 to 25, and the middle of the filed memorandum (filed pages 9 to 22) is not transcribed. Overlap numbers
do not measure quality.

## Known gaps and open choices

1. **One exemplar.** The task asks for one filed exemplar per doc type; the tier-2 bar in the protocol asks for two or
   three from different filers. A second WDNC memorandum was checked for text and format and not transcribed: *Coshland
   v. Bolton*, No. 3:26-cv-00291, ECF 8 (25 pages, Print-to-PDF, CID fonts). Tier 2 is therefore **not** judged against
   two filers.
2. **AI certification wording and scope.** The standing order's text was not fetched (see the rules section). The
   wording in the template is the exemplar's, and the sample sets `ai_certification: true`. Whether every filing needs
   it, or only briefs, and whether the carve-out list is complete, are **open questions for David**; the template does
   not decide them. The complaint template does not print it.
3. **Page limit.** LCvR 7.1(d) sets 25 pages for "any brief" and does not say which pages count. The template does not
   count pages; the filed exemplar is 25 pages including the signature and the certificate of service. Per-judge
   standing orders can change the limit.
4. **Font.** Same as the complaint: no face is named (LCvR 7.1(d)), so EB Garamond at 12 pt stays per `docs/FONTS.md`; the exemplar uses Times New Roman,
   which looks larger at 12 pt. A Times-metric font would remove the difference; a decision for David.
5. **Footnotes.** The exemplar has footnote 1 (exhibits). The markdown contract has no footnotes, so the sample omits
   it and the template cannot print one.
6. **Argument headings.** The filed text layer puts the roman numeral ("I.") on its own line above the heading text. The
   template sets the numeral and the text on one bold left line, as the sample is transcribed; the exemplar's layout of
   those headings was not checked on the page.
7. **Tables.** No table of contents or table of authorities is produced. The exemplar has none, and LCvR 7.1 does not
   require one in the text read; not verified for 25-page briefs in general.
8. **ECF header and footer.** The exemplar's "Case 5:26-cv-00006-SCR-DCK" header/footer and document number are added
   by the court's system and are not reproduced.
9. **Sample is an excerpt.** Arguments V and VI, most of the facts and part of argument IV are not transcribed.

## Review of the rendered pages (`usage/OUTPUT-ncwd-motion-brief-noble.typst.pdf`, 9 pages)

Each page was rendered at 60 dpi and viewed after the last template change.

- Page 1: court title (three lines), caption with ")" column, "Civil Action No. 5:26-CV-6", title and rule line at the
  right, opening paragraph, STATEMENT OF THE CASE. Pass.
- Page 2: STATEMENT OF RELEVANT FACTS, I heading and its paragraphs, II heading with its first paragraph. Pass.
- Page 3: the rest of II, STANDARD OF REVIEW with its two paragraphs. Pass.
- Page 4: the standard of review's last paragraph, ARGUMENT heading, I heading and its two paragraphs, II heading
  (three lines, single-spaced) and its first paragraph. Pass.
- Page 5: argument II in part, III heading and its first paragraph. Pass.
- Page 6: argument III in part, IV heading (two lines, single-spaced) and its paragraphs. Pass.
- Page 7: argument IV continued, CONCLUSION, date line, signature block, AI certification heading and first statement.
  Pass.
- Page 8: AI certification statement 2, date line, signature block, CERTIFICATE OF SERVICE heading and the CM/ECF
  sentence, first counsel block. Pass.
- Page 9: remaining counsel block, date line and signature block. Pass.

Gate 2 rows for these pages are recorded here (this doc type has no `reviews/` folder).

## Engines

**docx** (`docx/reference.docx` built by `docx/make-reference.sh`; `docx/motion-brief.lua` builds the caption, the signature blocks, the AI certification and the certificate of service). Output: `usage/OUTPUT-ncwd-motion-brief-noble.docx` and `usage/OUTPUT-ncwd-motion-brief-noble.docx.pdf` (LibreOffice, 9 pages, the same page count as typst). Checked by eye, not by `tools/check.sh` (this court has no `checks.yaml` yet). Not opened in Word; `unzip -tq` and `xmllint` pass on every XML part, and LibreOffice converted it without error.

- *Matches typst:* EB Garamond 12 pt (the PDF embeds EB Garamond Regular, Bold and Italic only); US Letter with one-inch margins; double-spaced body at the 27.6 pt pitch and single lines at 13.8 pt; the court title with the division; the caption with the ")" column at 3.0 in and the right column at 3.5 in, with "Civil Action No. 5:26-CV-6", the bold title lines wrapping as in typst; the first paragraph 24 pt below the caption; unnumbered body paragraphs with a half-inch first-line indent; the centered section headings and left argument headings (I., II., ... with the bold and bold italic levels); the date line and the firm blocks at 3.0 in, with "By: /s/" for the signer; the AI certification with the standing order's wording; the certificate of service with each counsel block; a centered page number on every page.
- *Differs (tier 2):* line breaks differ from typst's in places, so the page breaks fall at other lines: the heading "II." moves from page 4 (typst) to page 5 (docx), and the certificate of service starts at the foot of page 8 in both but breaks differently across pages 8 and 9. Section headings are 17 pt and argument headings 14.5 pt to approximate typst's default heading sizes; the space around a heading is within a few points of typst's. Typst sets the AI certification heading on two lines; the docx sets it on one. Word may substitute a font if EB Garamond is not installed on the reader's machine.
- *Pages reviewed:* docx pages 1 to 9 of `OUTPUT-ncwd-motion-brief-noble.docx.pdf` (all 9), and typst pages 1 to 9 of the typst render (all 9), at 60 dpi.
- *BLOCKED:* none. The memorandum has no footnotes, table of contents or table of authorities in the template, so no field or footnote is needed.
