# txed: motion to dismiss with memorandum (Rule 12(b)(6))

Doc type: **motion-brief** (a Rule 12(b)(6) motion to dismiss, with its memorandum, in one document) in the United States District Court for the Eastern District of Texas (`txed`).
Folder: `courts/fifth-circuit/texas/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (Defendants' Motion to Dismiss the Amended Complaint, Texarkana Division, Dkt. 53, filed 2026-06-18; text-based, 57 pages). Source and provenance in `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md`: an **excerpt** transcription of Dkt. 53 (caption; brief pages 1 to 10 of 46 in full, including the introduction, background and legal standard; the signature block from page 46; the certificate of service from page 47). The argument is not transcribed. `excerpt: true` in its frontmatter. |
| typeface | Rule names no face: E.D. Tex. CV-10(a)(5) (text read 2026-10-15 from the 2018 copy, the only one retrievable) requires double spacing and "a font no smaller than 12-point type". Vendored substitute: none needed; **Times New Roman** 12 pt, the house standard (`docs/FONTS.md` rule 6) and the exemplar's face (EB Garamond 13 pt before fb-595.68). Metric compatibility: n/a. The exemplar's Times New Roman is a filer's choice, not a rule. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 13 pages each (sample 2: 10), vendored Times New Roman only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with the local rules overlaid in `typst/layout.yaml` (fb-595.17.7) |
| overlay | **fail**: `tools/overlay.sh` exits 1 with "no exemplar pdf" because `usage/` holds only `SOURCE.md` in this snapshot (the `SAMPLE-*.pdf` file is not tracked). No `OVERLAY-hcsc-motion-to-dismiss.pdf` is produced. The `.txt` on disk is from an earlier run and was not rewritten. |
| pages reviewed | 13 of 13 and 10 of 10 on typst, latex and docx, read as laid-out text after the move onto the FRCP base, 2026-10-29 (see "Gate 2 review on the FRCP base"; the older reviews below were made on earlier renders) |
| checks | the 30-page limit of CV-7(a)(1) is `eval.yaml` params.page_limit (DEF-LEN-001, every engine). The render-time statement-of-issues check is gone with the move onto the FRCP base (see "Gate 2 review on the FRCP base", DECIDED). |

## Governing rules

Primary sources. Local Rules read 2026-10-14 from the court-posted PDF, https://www.txed.uscourts.gov/sites/default/files/LocalRules.pdf (headed "as of [December 1, 2018]"; amendments through General Order [18-10], filed October 25, 2018). Same caveat as the complaint folder (`../complaint/README.md`): a later revision may exist that this box could not retrieve.

| Rule | Requirement (as read) | Where it is in the template |
|---|---|---|
| CV-7(a) | All motions in writing, conforming to CV-5 and CV-10, accompanied by a separate proposed order (searchable and editable PDF, endorsed with style and number, no date or signature block); each motion a separate document, except alternative relief; searchable PDF with no copy-blocking security. | The motion is one document. The proposed order is not produced (see gap 3). |
| CV-7(a)(1) | Case dispositive motions "shall not exceed thirty pages, excluding attachments, unless leave of court is first obtained"; "shall contain a statement of the issues to be decided by the court." | The 30-page limit: `counter(page).final()` panics above 30. The statement of the issues: the template panics without a "Statement of the Issue" heading, except in an excerpt sample (`excerpt: true`). See gap 1. |
| CV-7(c) | "The motion and any briefing shall be contained in one document." Concise statement of reasons and citation of authorities. | The motion and memorandum are one document (this resolves the question left open in the earlier README: the memorandum is not a separate file). |
| CV-7(b) | Documents supporting a motion are filed with it; cited portions highlighted; only relevant, cited-to excerpts attached. | Exhibits are not produced; not part of this build. |
| CV-10(a)(1) to (3) | Endorsed with style and number; caption with the filer's name, designation and character of the document; signed by the lead attorney or with his or her permission. | `court`, `case_number`, `caption`, `brief_title`, `signature`. |
| CV-10(a)(4), (5) | 8 1/2 by 11 inch paper; double spaced; font no smaller than 12-point. | `page-w`, `page-h`; `pitch-double` (27.6 pt pitch); `type-size = 12pt`, footnotes and page number too. |
| CV-5(c) (as cited in the earlier README) | A certificate of service showing the date and method of service. | `service` frontmatter (`date`, `method`), generated as "CERTIFICATE OF SERVICE". |
| CV-7(h), (i) | Meet and confer / certificate of conference; motions to dismiss are exempt. | Not produced (deliberately). |
| Fed. R. Civ. P. 12(b)(6) | Failure to state a claim may be raised by motion. Text fetched earlier from https://www.law.cornell.edu/rules/frcp/rule_12 ("Apr. 2, 2024, eff. Dec. 1, 2024"); not re-fetched today. | The defense named in the title. |
| Fed. R. Civ. P. 10(a) | Caption (court, title, file number, parties). Text fetched earlier from https://www.law.cornell.edu/rules/frcp/rule_10; not re-fetched today. | `court`, `caption`, `case_number`. |

Not verified, and not used: judge-specific standing orders on page limits. The exemplar's case had a scheduling order with its own page limits (per the Georgetown tracker's listing); its terms were not read, and they are not the district rule.

## Layout

- Letter, 1 inch margins, page numbers centered in the footer (12 pt, CV-10(a)(5); 11 pt before fb-595.68).
- Court title (three lines), caption, title of the paper, as in the complaint folder. The caption wraps long party names by one 13.8 pt single-spaced line per wrapped line (`sline` grows with its lines; before this fix a wrapped name overprinted the next line). A bold line below the case number (the `jury_demand` field) carries "ORAL ARGUMENT REQUESTED" for this sample.
- Body double spaced (27.6 pt pitch). Level-1 headings are sections (centered, bold, capitals, `I.`, `II.`, ... by the template); level-2 headings are subsections (bold, left, `A.`, `B.`, ... restarting under each section); level-3 headings are bold italic run-in lines.
- Footnotes are supported (cmarker `[^n]`), and render at the foot of the page. The sample uses two.
- Lists are lettered (`a.`, `b.`, ...) with a hanging indent (the relief list in the conclusion).
- Signature block (single spaced), then "CERTIFICATE OF SERVICE" with the date and method from the frontmatter.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `court`, `caption`, `case_number`, `brief_title`, `signature` (`firm`, `signer`, `lines`, `role`), `service` (`date`, `method`); optional `jury_demand` (a bold line under the case number; the name is historical), optional `excerpt: true` (see gap 1).
- Body: a `# Statement of the Issue(s) to Be Decided` heading (required unless `excerpt: true`); `#` headings for sections; `##` and `###` for subsections; `-` items for the relief list; plain paragraphs; `[^n]` footnotes; `\* \* \*` for the asterisk section breaks in the filing. Use `*...*` for case names and signals.
- Not supported: tables (the filing's tables of contents and authorities are not produced), raw typst, numbered lists in the body (the template letters `-` lists only).

## What the overlay shows

`tools/overlay.sh` pairs each page of the render with the filed page sharing the most words, then draws the render in red and the filed page in blue (black where both agree). At 60 dpi the lines overlap rather than align, which is the expected result for this pair: the filed caption is a § column with a different layout from ours; the filed text runs from brief page 1 at a different line pitch and wrapping; footnotes fall on different pages; and our page 11 (signature and certificate) pairs with filed page 57 (the certificate), so the signature line itself does not overlap. The overlay is a diagnostic, not a score. (This reading is from the earlier EB Garamond render, before fb-595.68.) What it does show: our pages 1 to 10 pair with filed pages 11 to 19 in order, and the body text (word overlap about 42 to 67 percent per page) is the transcription, not a different document.

## Known gaps and open choices

1. **No statement of the issues in the exemplar (decision for David).** CV-7(a)(1) requires "a statement of the issues to be decided by the court" (content). The template enforces a level-1 heading; the exemplar (Dkt. 53) has none, though its introduction states the grounds. The template therefore does not accept the exemplar in full: a non-excerpt transcription of Dkt. 53 would be refused by the check. The sample uses `excerpt: true` to skip the check, because the excerpt does not reach a statement of issues and no text may be added to it. Choices: (a) keep the heading check and treat `excerpt` as the transcription-only escape (current state); (b) accept a statement in any form (paragraph under an "Introduction" heading) and drop the heading requirement; (c) keep the heading and treat Dkt. 53 as a non-complying filing. The rule text supports (b); the heading is our layout choice.
2. **Excerpt, not the whole filing.** The brief runs 46 pages plus a table of contents and table of authorities; the transcription covers brief pages 1 to 10 and the end. The argument (from brief page 11), the table of contents and table of authorities, and the footnotes after page 10 are not transcribed. This keeps the render at the 8 to 14 page target.
3. **Proposed order not produced.** CV-7(a) requires a separate proposed order. It is a separate file and is not part of this template.
4. **Signature block: one firm only.** The template has one `firm` block. The filing has a lead block (McDermott, lead attorney) and a local-counsel block (Pickett); the local block is not transcribed. The filing's "Dated:" line is not produced.
5. **Certificate of service wording.** The template generates "I hereby certify that on [date], the foregoing document was served on all counsel of record through the Court's CM/ECF system, which sends notice of the filing by e-mail to all counsel of record." The filing's text is "I hereby certify that the foregoing document was electronically filed with the Clerk of the Court using the CM/ECF filing system, which will generate and send an e-mail notification of said filing to all counsel of record on June 18, 2026." The filing also carries a "/s/" signature under the certificate, which the template does not produce.
6. **Font.** Times New Roman, as in the complaint folder (see `../complaint/README.md`, known gaps 2), the house standard (`docs/FONTS.md` rule 6) and the exemplar's face. Before fb-595.68 the template was EB Garamond, then the only vendored font.
7. **Local-rule version.** See the version caveat above.
8. **Page limit check uses the rendered page count.** It counts every page of the document (signature and certificate included), which is the conservative reading: CV-7(a)(1) excludes attachments only.
9. **Excerpt flag.** `excerpt: true` is set only in the transcription's frontmatter. A real filing built from this template must not set it; the statement-of-issues check is the only thing it skips.

## Review record

- Pages 1 to 11 of `usage/OUTPUT-motion-brief.typst.pdf` rasterized at 60 dpi and viewed after the last template change (the EB Garamond 13 pt render, before fb-595.68). Page 1: caption wraps cleanly, case number and "ORAL ARGUMENT REQUESTED" clear of each other. Page 2: footnote 1 sits at the foot of the page. Page 7: footnote 2 at the foot. Page 11: signature block and certificate of service, with the signature block kept with the last body line.
- Pages 1 to 4 of `usage/OUTPUT-txed-motion-brief-genericmotiontodismiss.typst.pdf` viewed after the last template change.
- Defects found and fixed during review: (a) `sline` fixed each line to one 13.8 pt box, so the caption's wrapped party names overprinted the next line ("Reserve Company," over "Plaintiff,") and the oral-argument line overprinted the case number (fixed: lines grow with their wrapping); (b) the statement-of-issues check blocked the transcription (fixed: `excerpt: true` skips it; a non-excerpt mutant still fails with exit 1).
- Earlier review items (kept): the two-line title overlap, subsection heading size, heading gaps.

## Gate 2 review on the FRCP base (2026-10-29, every page of the typst, latex and docx renders read)

Pages read as laid-out text (`pdftotext -layout`) on all three engines; XENG-001..003 show the latex and docx pages break every line where typst does.

- Sample 1, page 1: court's name with the division, the caption (parties at the left, the column of section marks, "Case No.:" and the bold legend at the right), the title, the opening. PASS. DEF-COVER-002 is reported, not counted (`eval.yaml`): the exemplar's page 1 is a cover with every counsel group under the caption, one filer's style.
- Sample 1, pages 2 to 10: body, section headings centered in capitals numbered I., II., argument headings A., B., footnotes 1 (page 3) and 2 (page 7) at the foot. PASS.
- Sample 1, page 11: ACCEPTED (tier 2): eight lines only; the body's last paragraph is kept with the signature block on page 12 (the base keeps the closing with the last paragraph, so no signature stands alone on a page).
- Sample 1, pages 12 and 13: the signature block in the right half; the certificate of service (CV-5(c): date and method) signed in the signature column. PASS.
- Sample 2, page 1: the caption with the MDL line over the civil action number. PASS. OPEN (tier 2): the address line "TO THE HONORABLE ..." is set as an indented paragraph (the exemplar sets it flush left); the base indents every body paragraph's first line.
- Sample 2, pages 2 to 9: the statement of the issues (CV-7(a)(1)) as typed numbered paragraphs, argument headings hung under their letter, the block quotation on page 7. PASS.
- Sample 2, page 10: conclusion, signature block, certificate of service. PASS.
- DECIDED: the render no longer stops when a sample lacks a "Statement of the Issues" heading (CV-7(a)(1)): the base's `checks.sections` cannot exempt the excerpt sample (`excerpt: true`), and the requirement is content the filer writes; sample 2 carries it.
- Frontmatter now: `division`, `caption.parties`, `case_lines` (lines over the number, an MDL number), `case_label`, `case_number`, `legend` (was `jury_demand`), `brief_title`, `signature.{firm, signer, lines, counsel_for}` (was `role`), `service.{date, method}`; the court's name is the layout's, not the sample's.

## Engines

On the shared document model (docs/EVAL-LOOP.md, "Generated engines"; fb-595.17.7): `typst/layout.yaml` names the generic FRCP brief (`base: /lib/layouts/frcp-motion-brief.yaml`, fb-595.17) and overlays only what this court sets itself, each with its rule; `latex/` and `docx/` are generated from the merged layout by `fb engines gen`, and the per-folder docx filter (`docx/txed-motion-brief.lua`) is removed. The 30-page limit of CV-7(a)(1) is `eval.yaml` params.page_limit (DEF-LEN-001, every engine). The sections above that name the old template's parameters (`pitch-double`, `caption-left` and the like) predate the move; the layout is now `typst/layout.yaml`.

| Engine | Status |
|---|---|
| typst | reference; `sh tools/check.sh <dir>` exits 0 |
| latex | generated; `--engine latex` exits 0, XENG-001..003 pass (every page and line breaks where typst breaks it) |
| docx | generated; `--engine docx` exits 0, XENG-001..003 pass; `.docx.pdf` by LibreOffice. BLOCKED: none |
