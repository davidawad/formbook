# vawd: motion-brief

Doc type: **motion-brief**, the brief in support of a motion to dismiss under Fed. R. Civ. P. 12(b) (with its memorandum), in the United States District Court for the Western District of Virginia (`vawd`).
Folder: `courts/fourth-circuit/virginia/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `exemplars/FILED-EXAMPLE-fitch-6-26-cv-00001-motion-brief.pdf` (26 pages; Woods Rogers for Centra Health; box caption) and `exemplars/FILED-EXAMPLE-azimi-3-26-cv-00001-motion-brief.pdf` (9 pages; TimberlakeSmith for two defendants; ")" caption). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-fitch-motion-brief.md`: a portion of the Fitch brief (caption, introduction, the Background, the Legal Standard, the opening of the Argument, its sections 2 and 3, the Conclusion, the signature block). It renders to 12 pages. `samples/INPUT-azimi-motion-brief.md`: the whole Azimi memorandum, with its certificate of service (9 pages). |
| render | ok: `samples/OUTPUT-fitch-motion-brief.pdf` (12 pages) and `samples/OUTPUT-azimi-motion-brief.pdf` (9 pages), letter, typst 0.15.0, EB Garamond only (embedded), no warnings. |
| overlay | ok: `samples/OVERLAY-fitch-motion-brief.pdf` and `.txt`; `samples/OVERLAY-azimi-motion-brief.pdf` and `.txt`. |
| pages reviewed | 21 of 21: the Fitch sample pages 1 to 12, and the Azimi sample pages 1 to 9, each rendered at 60 dpi and viewed after the last layout change. |

File names: the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` and read `INPUT-<id>.md` by default, so the samples and their outputs use those names (not `<id>.pdf`).

## Governing rules

The local rules set no type size, margin, line spacing, page limit, or table of contents or authorities for a brief. The layout values are therefore the convention both exemplars show (tier 2), not a mandate. The rules below are the mandates the template serves (tier 1).

| Rule | Kind | Requirement | Where in the template | Source (date verified) |
|---|---|---|---|---|
| Fed. R. Civ. P. 7(b)(1) | M | A request for a court order is made by motion, which states the grounds with particularity and the relief sought. | The brief is the support for the motion. The title (`brief_title`) and the relief in the conclusion are author content; the template does not check them. | https://www.law.cornell.edu/rules/frcp/rule_7 (2026-10-14) |
| Fed. R. Civ. P. 7(b)(2) | M | The rules on captions and other matters of form for pleadings apply to motions and other papers. | `court-title`, `caption-box` / `caption-parens`, the `case_label` and `case_number` lines, and the title. | same |
| Fed. R. Civ. P. 10(a) | M | Caption: the court's name, a title, a file number, and a Rule 7(a) designation. | Same as Rule 7(b)(2). | https://www.law.cornell.edu/rules/frcp/rule_10 (2026-10-14) |
| Fed. R. Civ. P. 11(a) | M | Signed by an attorney of record, who states the signer's address, e-mail address, and telephone number. | `signature-block` and `signer-block`: the e-signature line, the names with bar numbers, the firm, the address, telephone, fax and e-mail, and the role. | https://www.law.cornell.edu/rules/frcp/rule_11 (2026-10-14) |
| W.D. Va. Local Rule 11(a) | M | All pleadings and motions include the attorney's office address, telephone number, e-mail address, and bar identification number. | The same signature lines as Rule 11(a). The brief has no counsel block at the top (both exemplars put it at the end). | https://www.vawd.uscourts.gov/sites/Public/assets/File/court/local_rules.pdf, Rule 11(a) (2026-10-14) |
| W.D. Va. Local Rule 11(c)(1) | M | A motion is accompanied by a written brief setting out a concise statement of the facts and supporting reasons, with the authorities the movant relies on. This template is that brief. The response is due 14 days after service; the reply rebuttal 7 days after the reply (not a format rule). | The whole document. | same PDF, Rule 11(c)(1) (2026-10-14) |
| W.D. Va. Local Rule 11(c)(2) | M | A separate brief is not required where the motion itself contains the legal and factual argument. Use the motion alone in that case. | Not a template rule. | same PDF, Rule 11(c)(2) (2026-10-14) |
| Fed. R. Civ. P. 5(d)(1)(B) | M | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system. A certificate is needed for service on a non-ECF participant (mail). | `certificate()`, rendered when the frontmatter has a `service` block (the Azimi memorandum, mailed to the pro se plaintiff). | https://www.law.cornell.edu/rules/frcp/rule_5 (2026-10-14) |
| W.D. Va. ECF procedures, para. 5(a) | M (clerk's procedure) | A PDF created from a word processor is flattened and text searchable. | The render is a typst text PDF with embedded fonts and a text layer. | https://www.vawd.uscourts.gov/sites/Public/assets/File/court/ecfprocedures.pdf (revised 2025-10-25) (2026-10-14) |
| Fed. R. Civ. P. 5.2(a) | A | Redact SSNs, taxpayer numbers, birth dates, minors' names, and account numbers. | Not a template rule. The samples have none of these. | https://www.law.cornell.edu/rules/frcp/rule_5.2 (2026-10-14) |

No local rule, ECF procedure, or standing order on brief format was found. The local rules PDF (revised 2025-10-01) has no typeface, margin, spacing, or page-length rule for briefs (its only "page" hits are a county name and a rule on separately numbered exhibits). A search of the web for a W.D. Va. font or page-limit rule found nothing for this court. The court's standing-order index lists appointment and assignment orders; I did not read every judge's practice standing orders, so check the assigned judge's before filing.

Not produced by this template: the Rule 7.1 disclosure statement (a separate filing; the Fitch brief's defendants are a corporation and a committee); the proposed order (the ECF procedures ask for it as an attachment to the motion, filed separately from the motion, and e-mailed to the judge in a Word-compatible format, since judges do not accept a PDF of it); and the ECF header line, which the clerk adds.

## Layout (tier 2: the convention both exemplars show)

- Letter, 1-inch margins. Page number centered at the foot of each page.
- Body: EB Garamond 13 pt (see Known gaps). Double spacing: a 27.6 pt baseline pitch (measured on both exemplars). Paragraphs are indented 0.5 in; no extra space between paragraphs; lines ragged right.
- Court title in three centered lines, plain capitals. Caption: `caption.style: box` (Fitch) or `parens` (Azimi); the file number labelled by `case_label`.
- Title in bold capitals, centered, under the caption.
- Section headings (`#`): centered, bold, capitals; unnumbered (INTRODUCTION, ARGUMENT, CONCLUSION, and Background, Legal Standard in the Fitch sample).
- Sub-headings: level 2 is numbered 1., 2., ... and restarts under each section; level 3 is a., b., ...; level 4 is (i), (ii). The number hangs at the left margin.
- Block quotations: single-spaced, indented 0.5 in on both sides.
- Footnotes: 11 pt, single-spaced, with a rule above them.
- Signature: "Dated:" at the left margin (when the frontmatter has a `date`); the signer block from 3.25 in: an optional preamble (the parties, or "Respectfully submitted,"), the e-signature line, one group per counsel, the role lines.
- Certificate of service (optional): centered bold heading, the sentence from the frontmatter, the recipients, then the signer block without the preamble.

## Markdown contract (for samples)

The sample is one `.md` file: YAML frontmatter, then the body.

Frontmatter:
- `case_number` (required): the file number. `case_label` (required here): the label before it, e.g. `"Case No."` or `"Civil Action No.:"`.
- `division` (required): printed in capitals in the court title.
- `caption` (required): `style` (`box`, the default, or `parens`) and `parties`, a list of `{names: [...], designation: "..."}`.
- `brief_title` (required): the title, printed in capitals.
- `signature` (required): `preamble` (optional, a list of lines above the e-signature line), `signed_by` (the e-signature line, e.g. `"/s/ J. Benjamin Rottenborn"` or `"By: /s/ Kelly C. MacCluen"`), `counsel` (a list of `{names: [...], lines: [...]}`; the names are printed in order, then the lines), `role` (optional, the lines under the counsel).
- `date` (optional): printed as "Dated:" above the signature block.
- `service` (optional): `text` (the sentence of the certificate) and `recipients` (lines).

Body:
- `# Heading` (section), `## Heading` (level 2, "1."), `### Heading` (level 3, "a."). Do not type the numbers.
- Paragraphs are not numbered in a brief.
- Footnotes: `text[^key]` and `[^key]: text` anywhere in the file. A reference and its definition are kept in the same render.
- Block quotations: `> text`.
- Literal asterisks (for example a Westlaw star page, "at \*7") are escaped in the markdown.
- Not supported: tables, images, raw typst, a table of contents or authorities (neither exemplar has one, and no rule requires one).

## Overlay

`samples/OVERLAY-fitch-motion-brief.pdf` (red is ours; blue is filed; black is where both agree). Pages are paired by shared words. Fitch map:

| Ours | Filed (paired by text) | Word overlap |
|---|---|---|
| p.1 | p.1 | 96.3% |
| p.2 | p.2 | 82.3% |
| p.3 | p.3 | 72.8% |
| p.4 | p.4 | 61.2% |
| p.5 | p.5 | 57.7% |
| p.6 | p.6 | 56.5% |
| p.7 | p.7 | 51.1% |
| p.8 | p.8 | 47.7% |
| p.9 | p.9 | 49.2% |
| p.10 | p.24 | 39.4% |
| p.11 | p.25 | 62.1% |
| p.12 | p.26 | 75.8% |

Ours pp.10 to 12 pair with filed pp.24 to 26, the end of the filed brief, because the sample's last sections (the Argument's sections 2 and 3, the Conclusion, the signature) are also the end of the filed brief. The overlap there is lower because the filed pages carry the rest of the Argument. The pairing is by words, not by position, and the page overlap is not a score.

`samples/OVERLAY-azimi-motion-brief.pdf` (the whole memorandum). Azimi map:

| Ours | Filed (paired by text) | Word overlap |
|---|---|---|
| p.1 | p.1 | 93.7% |
| p.2 | p.2 | 92.9% |
| p.3 | p.3 | 95.6% |
| p.4 | p.4 | 95.2% |
| p.5 | p.5 | 93.3% |
| p.6 | p.6 | 92.5% |
| p.7 | p.7 | 87.5% |
| p.8 | p.8 | 44.4% |
| p.9 | p.8 | 87.8% |

The filing puts its conclusion on p.7 and splits its signature block across the page break: the party block and the first counsel lines are on p.8, the rest on p.9. Its certificate of service heading is on p.8, and its signature for the certificate is on p.9. Ours keeps the conclusion and the whole signature block on p.8, and the certificate on p.9. That difference is deliberate: a split signature block is not a convention to copy. Hence the 44% on our p.8 and the 88% of our p.9 against filed p.8.

The overlay tool writes its pages at 240 by 311 pt (its image density setting); the page images are complete and legible at higher zoom. The tool is shared (`tools/overlay.sh`) and was not changed.

## Gate 2: page review (each page viewed)

Fitch sample (12 pages):
- p.1: court title, boxed caption with "Case No." on the right, title in bold capitals, the introduction. Pass.
- p.2: BACKGROUND centered, footnote 1; "1. Statutory Framework" with the paragraph under it indented. Pass.
- p.3: "2. Stable Value Funds"; footnotes 2 to 4 at the foot of the page. Pass.
- p.4: the three block quotations single-spaced, indented; "3. Centra Plan" begins at the foot. Pass.
- p.5: footnotes 5 to 7 at the foot; the Centra paragraphs. Pass.
- p.6: footnote 8; "4. Plaintiff's Claims". Pass.
- p.7: "Plaintiff's Claims" continues; LEGAL STANDARD centered. Pass.
- p.8: the Legal Standard continues; ARGUMENT centered. Pass.
- p.9: the argument's paragraphs; footnote 9 at the foot. Pass.
- p.10: "1. The Factual Allegations..." heading with the portion note in italics (the note marks the omission); "2. Plaintiff's Duty to Monitor"; "3. Plaintiff Lacks Standing". Pass.
- p.11: the standing paragraph ends; the filed footnote 21 (rendered as 10) at the foot. The CONCLUSION moves to p.12 with the signature (see Known gaps). Pass.
- p.12: CONCLUSION with its sentence; "Dated: July 2, 2026"; the signer block for both counsel groups and the role lines. Pass.

Azimi sample (9 pages):
- p.1: the ")" caption, "Civil Action No.: 3:26-CV-1", the title, the opening sentence, INTRODUCTION centered. Pass.
- p.2: ARGUMENT centered; "1. Legal standard." with "a. 12(b)(1) standard." and "b. 12(b)(6) standard." indented. Pass.
- p.3: "2. Plaintiff Lacks Article III Standing." Pass.
- p.4: the standing discussion; the Azimi citation with the escaped star page. Pass.
- p.5: the standing paragraphs; "3. The Complaint fails to state a First Amendment claim..." heading (bold, wrapping to two lines, the second line indented). Pass.
- p.6: the First Amendment discussion; "4. ... denial-of-access-to-courts claim." Pass.
- p.7: the remaining argument; the CONCLUSION kept with its signature block on p.8. Pass.
- p.8: CONCLUSION, the signature block (parties preamble, "By: /s/ Kelly C. MacCluen", three counsel names with bar numbers, the firm, the address, the contact lines, the role). Pass.
- p.9: CERTIFICATE OF SERVICE centered; the sentence; the recipient's address; the signer block without the preamble. Pass.

## Known gaps and choices

1. **Typeface.** Face required: none. The W.D. Va. Local Civil Rules name no typeface, font size, or spacing rule (checked in full; see the complaint README), so EB Garamond stays. The exemplars are Times New Roman (pdffonts on both); that is a filer's habit, not a rule. EB Garamond at 13 pt is used so its x-height is close to Times at 12 pt. That size is a judgment, not a rule (see the complaint README).
2. **Portion (Fitch).** The Argument's section 1 is cut to its heading and a note (its parts 1(a) to 1(c) are not transcribed); footnotes 10 to 13 and 20 are not transcribed. Footnote numbers are assigned by typst in order, so the filed footnote 21 renders as 10. Footnote 4 is placed at the sentence it follows in the text layer; the placement was reconstructed from the text layer and is approximate.
3. **Heading numbers.** The template's sub-headings are arabic and letter (Fitch). The Azimi memorandum uses roman numerals for its points, which renders as "1." in our template: a style of one filer, so tier 3. Accepted.
4. **Case names.** Roman in the sample (the text layer carries no italics), the same as the complaint and the cand samples. The template italicises `*...*` when a sample marks it.
5. **Signature.** A final section under 1,200 characters is kept on one page with the signature block (the Conclusion in both samples). A longer final section leaves the signature block to start its own page.
6. **No table of contents or authorities.** Neither exemplar has one, and no local rule requires one. A long brief (the Fitch brief is 26 pages) would normally carry one in some courts; this template does not build it.
7. **The ECF header line** is not reproduced; the clerk adds it when the PDF is filed.
8. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` read a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids touching `tools/`. `tools/tracker.sh` was not run. The render and the overlay were run; the review above is the Gate 2 record.

[Vawd court README](../README.md) | [Federal courts README](../../README.md)

## Engines

DOCX (`docx/`): `docx/build-reference.sh` builds `docx/reference.docx` from pandoc's default reference; `docx/vawd-motion-brief.lua` builds the cover, the caption (box or ")" style), the brief title, the numbered headings (1., a., (i)) with a hanging label, the lettered lists, the native footnotes, the signature block, and the certificate of service. Rendered with `sh tools/render.sh --engine docx motion-brief samples/INPUT-<id>-motion-brief.md` (LibreOffice PDFs: `samples/OUTPUT-<id>-motion-brief.docx.pdf`).

- Matches the typst form: EB Garamond 13 pt (embedded), 1 in margins on letter, 27.6 pt double spacing, 0.5 in first-line indent on every paragraph, footnotes at 11 pt single spaced, centered caps section headings, bold numbered sub-headings, block quotations single spaced and indented 0.5 in each side, the signature block at 3.25 in, the certificate of service on its own block, centered page number at 12 pt. The last section is kept with the signature block when it is short (no footnote), as in typst.
- Differs: pagination of the LibreOffice PDF is longer than typst: azimi 10 pages (typst 9), fitch 12 (typst 12). The last section of azimi moves to the next page with its signature block, leaving page 8 short. Word may paginate differently again.
- BLOCKED: every gate of `sh tools/check.sh <court-dir> --engine docx` (gates 0 to 3). The court folder has no `checks.yaml` (and no `rules.md`), so check.sh cannot run; `check-selftest.sh` needs the same file and is not run.
