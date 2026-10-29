# ncwd: motion-brief

Doc type: **motion-brief** (the memorandum of law supporting a motion to dismiss under Fed. R. Civ. P. 12(b), with the
court's required certifications) in the United States District Court for the Western District of North Carolina (`ncwd`).
Folder: `courts/fourth-circuit/north-carolina/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (25 pages, one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: a portion of the memorandum (caption, opening, statement of the case, part of the facts, standard of review, arguments I to IV in part, conclusion, signature, AI certification, certificate of service) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 10 pages each, vendored faces only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with the local rules overlaid in `typst/layout.yaml` (fb-595.17.9) |
| overlay | ok: `usage/OVERLAY-noble-motion-brief.pdf` and `usage/OVERLAY-noble-motion-brief.txt` (`tools/overlay.sh`) |
| typeface | face required: none named (LCvR 7.1(d) sets a 12-point minimum only; a judge's standing order may set a face). Template face: **Times New Roman** 12 pt, the house standard where no face is named (`docs/FONTS.md` rule 6; Liberation Serif as fallback), on typst and docx; EB Garamond before 2026-10-17 (the docx until fb-595.68.19). |
| pages reviewed | 10 of 10 on typst, latex and docx after the move onto the FRCP base (2026-10-29: every page's text layout and the checks' geometry; see "Gate 2 review on the FRCP base") |

File names follow the tools' defaults (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf/.txt`) rather than the
`<id>.md` / `<id>-overlay.pdf` names in the task brief, because `tools/render.sh` and `tools/overlay.sh` read and write
those names. The overlay is a diagnostic, not a score.

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LCvR 7.1(c) (W.D.N.C. Local Civil Rules, as revised effective 2022-12-01; https://www.ncwd.uscourts.gov/sites/default/files/local_rules/Revised%20Local%20Rules%20120122.pdf, printed p. 13; fetched and read 2026-10-14) | A brief is filed with the motion, contemporaneously. Factual contentions are supported by citation to the exhibit number and page. | Content; the template does not check citations. |
| LCvR 7.1(d) (same PDF, printed p. 14) | Absent a judge's Standing Civil Order or Case Management Order: the page limit for any brief is 25 pages; font at least 12 point; lines double-spaced; one-inch margins; each page numbered. | the base's 12 pt, one-inch margins and page numbers; `pitch.body` 27.6 (double spacing); the 25-page limit is `eval.yaml` `params.page_limit` (see Known gaps). |
| LCvR 7.1(j) (same PDF, printed p. 15) | Notice of supplemental authority: at most two pages, no argument. | Not produced (a separate filing). |
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10, fetched 2026-10-14) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `typst/layout.yaml` `front`. |
| Fed. R. Civ. P. 11(a) (https://www.law.cornell.edu/rules/frcp/rule_11, fetched 2026-10-14) | Every paper is signed by an attorney of record, who states the address, e-mail address and telephone number. | `closing`: date line, then each firm's "By: /s/" block with the lines the sample gives. |
| Standing Order of June 18, 2024, *In re: Use of Artificial Intelligence*, No. 3:24-mc-104 (W.D.N.C.) | A certification that no artificial intelligence was used in the research (except AI built into Westlaw, Lexis, FastCase, Bloomberg, Google and Google Scholar) and that every citation was checked. | `after_tail`, printed when the sample sets `ai_certification: true`. **Wording taken from the exemplar, not from the order** (see Known gaps). |

Primary sources for LCvR 7.1 and the Rules: as listed. The standing order's text was not fetched: the only source
seen was a PACER docket listing for 3:24-mc-104, and secondary summaries (Ropes & Gray's AI court-order tracker, and
North Carolina Lawyers Weekly, July 2024). Those summaries agree on the date, the research carve-out, and the
certification's two parts. They do not quote the order.

## Layout

- US Letter, one-inch margins on all four sides, 12 pt Times New Roman (no face is named by the rules; the house standard, `docs/FONTS.md` rule 6).
- First page: the court title (UNITED STATES DISTRICT COURT / FOR THE WESTERN DISTRICT OF NORTH CAROLINA / the division),
  "Civil Action No." centered under it, then a caption: the party column (each designation and "v." an inch in), a ")"
  column as tall as it, the title centered in bold at the right with the rules it moves under, and a rule under the
  parties and their ")" (the exemplar's).
- Double spacing is a 27.6 pt pitch (`pitch.body`, twice the 13.8 pt single line), the same as the filed exemplar
  (`pdftotext -bbox` on the earlier EB Garamond render: baselines 27.6 pt apart in both).
- Body paragraphs: unnumbered (a brief is not a pleading), first-line indent 0.5 in.
- Headings: level 1 centered bold caps (the sections: STATEMENT OF THE CASE, ARGUMENT, CONCLUSION); level 2 bold, left
  (argument headings such as "I. ..."); level 3 bold italic, left. Headings are single-spaced, each with a 24 pt space
  above, and stay with the text after them.
- Signature: the date line at the left ("This the 13th day of March, 2026."), then the firm block at the right half,
  "By: /s/" for the signer, the other counsel and the address, e-mail and telephone.
- AI certification (when the sample asks): a centered heading, the standing order's introduction, the two numbered
  statements, the date and a signature block. Printed after the first signature block, as in the exemplar.
- Certificate of service (when the sample has `service`): a centered heading, the CM/ECF sentence with the filing's
  title (`brief_title`), each counsel served as a block, the date and the signature block.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `case_number`, `division`, `caption.parties` (list of
  `{names: [...], designation}`; "v." is inserted between the parties; the names wrap in the 2.9 in party column),
  `brief_title` (the title, bold, also in the certificate of service), `brief_rules` (optional: the rules it moves under), `ai_title` (the filing's title in sentence case, for the AI certification),
  `ai_certification` (true or absent), `signature` (`date_line` and `blocks` of `{firm, by, lines}`), and `service`
  (`counsel`: a list of counsel blocks, each a list of lines).
- Body chunks separated by blank lines: `#` heading (level 1), `##` (level 2), `###` (level 3); a `1.` list; a `>`
  chunk (no first-line indent); or a plain paragraph (first-line indented).
- Footnotes `[^n]` with a `[^n]:` definition. Not supported: tables, raw typst. Italics (`*...*`) and `_..._` work through the markdown renderer.
- The template's own certification wording (the AI certification) and section headings are case-neutral; the
  case-specific words are only in the sample.

## Overlay

`usage/OVERLAY-noble-motion-brief.pdf` (made on the earlier 9-page EB Garamond render, before fb-595.68) shows the render in red and the filed page in blue; black where they agree.
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
3. **Page limit.** LCvR 7.1(d) sets 25 pages for "any brief" and does not say which pages count. `eval.yaml`
   `params.page_limit` 25 counts every page (DEF-LEN-001, every engine; the conservative reading); the filed exemplar is 25 pages including the signature and the certificate of service. Per-judge
   standing orders can change the limit.
4. **Font.** Same as the complaint: no face is named (LCvR 7.1(d)), so the template is Times New Roman 12 pt, the house
   standard (`docs/FONTS.md` rule 6, David 2026-10-17), the exemplar's face too; EB Garamond before 2026-10-17 (the docx until fb-595.68.19).
5. **Footnotes.** The exemplar has footnote 1 (exhibits); the sample omits it. The FRCP base sets footnotes (12 pt,
   single-spaced), so a sample may carry them.
6. **Argument headings.** The filed text layer puts the roman numeral ("I.") on its own line above the heading text. The
   template sets the numeral and the text on one bold left line, as the sample is transcribed; the exemplar's layout of
   those headings was not checked on the page.
7. **Tables.** No table of contents or table of authorities is produced. The exemplar has none, and LCvR 7.1 does not
   require one in the text read; not verified for 25-page briefs in general.
8. **ECF header and footer.** The exemplar's "Case 5:26-cv-00006-SCR-DCK" header/footer and document number are added
   by the court's system and are not reproduced.
9. **Sample is an excerpt.** Arguments V and VI, most of the facts and part of argument IV are not transcribed.

## Review of the rendered pages (`usage/OUTPUT-motion-brief.typst.pdf`, 9 pages, the earlier EB Garamond render)

Each page was rendered at 60 dpi and viewed, before fb-595.68; the current render is 10 pages.

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

## Gate 2 review on the FRCP base (2026-10-29, typst, latex and docx)

Every page of the three renders was reviewed as text layout (`pdftotext -layout`, page by page) with the checks' geometry (DEF-COVER-002 against the exemplar's page 1, XENG-001..003: every typst line identical in latex and docx); the pod that did the move could not open images, so a visual look at the pages is left to the PM.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court, division, Civil Action No., caption with ")" column and the title beside it, the rule under it, the opening | OK; DEF-COVER-002 passes |
| 2-7 | Statement of the case, facts (I., II.), standard of review, ARGUMENT I. to IV. | OK; page 7 ends short: CONCLUSION moves with the signature block |
| 8 | CONCLUSION, date line, the firm block in the right half, the AI certification (introduction, statement 1) | OK |
| 9 | AI statement 2 kept with its signature, CERTIFICATE OF SERVICE (start) | OK |
| 10 | The counsel served, the date line, the signature block | OK |

## Engines

On the shared document model (docs/EVAL-LOOP.md, "Generated engines"; fb-595.17.9): `typst/layout.yaml` names the generic FRCP brief (`base: /lib/layouts/frcp-motion-brief.yaml`, fb-595.17) and overlays what W.D.N.C. sets itself, each with its rule: the court's name and division, the caption with its ")" column, the 27.6 pt double pitch (LCvR 7.1(d)), the signature (Fed. R. Civ. P. 11(a)), the AI certification of the June 18, 2024 standing order and the certificate of service. `typst/ncwd-motion-brief.typ` names the face and asserts the signature fields. `latex/` and `docx/` are generated from the merged layout by `fb engines gen` (do not edit them); the per-folder typst code and the docx filter are removed. The page limit is `eval.yaml` `params.page_limit` (DEF-LEN-001, every engine).

| Engine | Status |
|---|---|
| typst | reference; `sh tools/check.sh <dir>` exits 0 |
| latex | generated; `--engine latex` exits 0, XENG-001..003 pass |
| docx | generated; `--engine docx` exits 0, XENG-001..003 pass; `.docx.pdf` by LibreOffice. BLOCKED: none |
