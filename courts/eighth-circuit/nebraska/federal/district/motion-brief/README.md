# ned: motion-brief

Doc type: **brief in support of a motion to dismiss** (memorandum) in the United States District Court for the District of Nebraska (`ned`). The sample is a Rule 12(b)(6) partial-dismissal brief.
Folder: `courts/eighth-circuit/nebraska/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, 1 filer: `usage/FILED-EXAMPLE-motion-brief.pdf` (see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the whole 16-page brief's text, from the introduction through the certificates) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 13 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-sandoval-motion-brief.pdf` and `OVERLAY-sandoval-motion-brief.txt` (page map) |
| pages reviewed | 13 of 13 (every page rendered at 60 dpi and viewed in the final state) |
| typeface | face required: none (NECivR names no typeface). Substitute: none; EB Garamond kept (no-face default, `docs/FONTS.md`). Fit: n/a. Exemplar is Times New Roman, a filer's choice (see Known gaps, 1). |
| tier 2 | not yet judged against 2 or 3 filers: one exemplar only (see Known gaps, 2) |

## Governing rules

Each rule was read from the primary source on 2026-10-14. The District's rules are the Civil Rules "Effective December 1, 2021".

| Rule | Requirement | Where it is in the template |
|---|---|---|
| NECivR 7.1(a)(1)(A) (https://www.ned.uscourts.gov/sites/default/files/documents/7.1.pdf) | A motion raising a substantial issue of law is supported by a brief filed with it; the brief is separate from the motion, concisely states the reasons, and cites authority. The brief must not recite facts unless supported as NECivR 7.1(a)(2) describes. | The brief's own text (the author's content). The template does not separate it from the motion; that is a filing step. |
| NECivR 7.1(a)(2) (same URL) | Facts not in the pleadings need an index of evidence, filed separately, identifying the motion. | Not produced. The exemplar cites its Exhibit A (body-camera video) by timestamp; the index is a separate filing. |
| NECivR 7.1(d)(1)(A) (same URL) | A supporting brief may not exceed 13,000 words, all text included (caption, headings, footnotes, quotations). | `word-limit`; `compliance-certificate` stops the build if the stated count is over 13,000. The template does not count words (see Known gaps, 5). |
| NECivR 7.1(d)(3) (same URL) | A brief includes a certificate of compliance: the word count, and the name and version of the word-processing software used. | `compliance-certificate` (required: the build fails without a `compliance` block). |
| NECivR 10.1(a)(3) (https://www.ned.uscourts.gov/sites/default/files/documents/10.1.pdf) | The caption shows the paper's description, the party filing it, and the docket number. | `caption`: "Case No." and the bold title (`brief_title`). |
| NECivR 11.1(a)(1)(A) (https://www.ned.uscourts.gov/sites/default/files/documents/11.1.pdf) | Electronic signature "s/ (attorney name)", then Bar Number, Attorney for, firm, address, telephone, fax, e-mail. | `signature-block` and the certificates' signature lines (`signature` frontmatter). |
| Fed. R. Civ. P. 12(b)(6) (https://www.law.cornell.edu/rules/frcp/rule_12) | A defense of failure to state a claim may be asserted by motion. | Not a template item; the brief's argument (author content). |
| Fed. R. Civ. P. 5(d)(1)(B) (https://www.law.cornell.edu/rules/frcp/rule_5) | A certificate of service is required when a paper is served by means other than the court's e-filing system; none is required for CM/ECF service. | `service-certificate` (rendered when a `service` block is given). The exemplar includes one for the e-mail service it also made. |

Checked on 2026-10-14. NECivR 12.1 (a motion to dismiss suspends the time to answer) is not a brief item.

## Layout

- US Letter, 1-inch margins. EB Garamond 12 pt (vendored; see Known gaps, 1).
- Double spacing: 24 pt baseline pitch. Single spacing (14.4 pt): caption, block quotations (indented 0.5 inch on both sides), signature block, certificates, multi-line headings.
- Court title on two centered lines at the top of page 1 (no counsel block: the exemplar has none, and no District rule requires one for a brief).
- Caption: a two-column box (party column with right and bottom rules, "v." between the parties, designations indented); case number and the bold title on the right.
- Lead-in ("COME NOW ...") as an unnumbered paragraph, first line indented.
- Body: unnumbered paragraphs with a 0.5-inch first-line indent. Headings: level 1 centered bold caps (INTRODUCTION, STANDARD OF REVIEW, FACTUAL BACKGROUND, LEGAL ARGUMENT, CONCLUSION); level 2 bold with a hanging indent (I. ...); level 3 bold italic with a hanging indent (a. ..., b. ...).
- Facts: a markdown list, numbered 1., 2., ... at a 0.5-inch indent.
- Signature block, right of centre, after the conclusion. The last paragraph is kept on the same page as the signature (a signature never starts a page alone).
- Certificate of compliance: "I hereby certify that this Brief complies with NECivR 7.1(d)(1). It contains N words, including the caption, headings, footnotes, and quotations, as calculated by the word-count function of [software]." with a signature.
- Certificate of service: heading, the filer's sentence, recipient blocks, signature.
- Footer from page 2 on: the page number centered; below it the title in capitals at left and "Case No." at right.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `case_number`, `caption.parties` (list of `{names, designation}`), `brief_title`, `footer_title`, `lead_in`, `signature` (`signer`, `bar_number`, `attorney_for`, `firm` lines), `compliance` (`word_count` as the filer states it, `software` with name and version), `service` (`date`, `text`, `recipients` as lists of lines).
- `#` = level-1 heading; `##` = level-2; `###` = level-3. Each heading in its own blank-line-separated chunk.
- A blank-line-separated paragraph is an unnumbered body paragraph. A `>` block is a block quotation (single-spaced). A `1.` list is the facts list.
- Case names are roman in the sample (see Known gaps, 4). `*...*` renders italic.
- The certificates are rendered by the template from frontmatter; the sample body does not repeat them.

## What the overlay shows

`OVERLAY-sandoval-motion-brief.pdf`: red is our render, blue is the filed exemplar, black is where both agree. Pages are paired by shared words, not by index. Sample pages pair with exemplar pages at 46–79% word overlap. The gap is the exemplar's line and page breaks in Times New Roman against ours in EB Garamond, and the 2-to-3-line differences that follow. The overlay is a diagnostic, not a score; the map (`.txt`) lists each pairing.

## Known gaps and open choices

1. **Font.** The District's rules name no font: NECivR 7.1 and 10.1 in the 2022 text (`NECivR.2022.pdf`, read 2026-10-14) contain no typeface, type-size or spacing rule beyond 10.1(b)(1)'s paper size and top margin. `docs/FONTS.md` says a court that names no face keeps EB Garamond, so the template does. The exemplar is Times New Roman, which is the filer's choice, not a rule; Liberation Serif (metric-compatible with Times New Roman) is vendored but is not used, because no rule calls for it. The text looks smaller than the exemplar at 12 pt because of EB Garamond's smaller x-height.
2. **One exemplar.** Tier 2 asks for 2 or 3 filers. Hingorani v. Board of Regents, No. 4:26-cv-03157 (27 pp., Century Schoolbook, table of contents) is the likely second filer; it is listed in `usage/SOURCE.md` but not saved, per the one-exemplar rule.
3. **Second signer.** The exemplar has two signers (Justin P. Smith, #28283, and Matthew G. Dunning, #20057). The template takes one signer; Dunning is omitted from the sample's signature blocks.
4. **Case names are roman.** The exemplar's text layer has italic runs for case names (its PDF embeds an italic face), but the transcription does not mark them. The template supports `*...*`.
5. **Word count.** The certificate states the exemplar's own count (4,679). The sample's body is the exemplar's text, so the count is the filer's, not one the template recounted; the template checks only that the stated number is within 13,000. A certificate for a real filing has to be counted by the filer's word processor (NECivR 7.1(d)(3)).
6. **Index of evidence.** The brief cites Exhibit A (body-camera video) by timestamp. NECivR 7.1(a)(2) requires an index of evidence filed separately; the template does not produce it.
7. **Caption style.** The exemplar uses a column of ")" marks; the template uses a bordered box, which the District does not prescribe (both are seen in filings).
8. **Signature label.** NECivR 11.1(a)(1)(A) gives "s/ Justin P. Smith" with no "By:" label; the exemplar writes "By: /s/". The template follows the rule.
9. **No "Dated" line.** The exemplar has none; the template has none.
10. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, and this doc-type folder has neither. The brief forbids editing `tools/`, so the gates were not run; render, overlay and the page review above are this doc type's record.

## Review of the rendered pages (final render)

- Page 1: court title, caption box with the plaintiff and the three defendants, the bold title, the "COME NOW" lead-in, INTRODUCTION, the first two paragraphs. No footer. Pass.
- Page 2: the introduction's last paragraph; STANDARD OF REVIEW; two paragraphs. Footer shows page 2, title, case number. Pass.
- Page 3: the standard's last paragraph; FACTUAL BACKGROUND; facts 1 to 5 (hanging list). Pass.
- Page 4: facts 6 to 13. Pass.
- Page 5: facts 14 to 18; LEGAL ARGUMENT and its opening paragraph. Pass.
- Page 6: the Kelly paragraph; heading I. (bold, hanging, single-spaced over four lines) and heading a. (bold italic); the argument. The level-2 heading's lines are single-spaced, so it no longer runs into the level-3 heading. Pass.
- Page 7: the Walz and Chestnut paragraphs; the Just introduction; the block quotation (single-spaced, indented, with its "* * *" separator). Pass.
- Page 8: the rest of the block quotation; "Id. at 765" paragraph; the statutes; the complaint-alleges paragraph. Pass.
- Page 9: "Here, as in Just"; the reasonable-basis paragraph; the Hosea paragraph; the Rule 12(b)(6) paragraph. Pass.
- Page 10: heading b. (bold italic, two lines); the qualified-immunity paragraphs; the Aldridge and Jenkins citations. Pass.
- Page 11: the Ehlers quotation paragraph; the Hosea and Cotten paragraph. Pass.
- Page 12: "Officer Peden had arguable probable cause"; "entitled to qualified immunity because"; CONCLUSION; the closing sentence; the signature block (with the conclusion, not alone on a page). Pass.
- Page 13: CERTIFICATE OF COMPLIANCE (4,679 words, Microsoft Word 2016) with its signature; CERTIFICATE OF SERVICE with the e-mail sentence, the two recipients, and the signature. Pass.

Defects found in review and fixed before this render: the footer's long title wrapped into the page number, so it is now a two-row footer; a multi-line heading was double-spaced inside a single-spaced gap, so its last line ran into the next heading (fixed by single-spacing headings); the signature block was split from the conclusion onto its own page (fixed by keeping the last paragraph with the signature).

File names follow `tools/render.sh` and `tools/overlay.sh` (and CLAUDE.md's role prefixes): `INPUT-motion-brief.md` (input), `OUTPUT-motion-brief.typst.pdf` (our render), `OVERLAY-sandoval-motion-brief.pdf` and `.txt` (the comparison). The brief's `<id>.pdf` and `<id>-overlay.pdf` names are not what the tools write.

## Engines

| Engine | Folder | Output in `usage/` | Status |
|---|---|---|---|
| typst (primary) | `typst/` | `OUTPUT-motion-brief.typst.pdf` (13 pages; not in the snapshot, rendered for comparison only) | the reference |
| docx | `docx/` (`reference.docx` from `make-reference.sh`, and `ned-motion-brief.lua`) | `OUTPUT-motion-brief.docx` and `OUTPUT-motion-brief.docx.pdf` (14 pages, LibreOffice 26.8.1 headless) | rendered; every page of the `.docx.pdf` viewed against the typst render |

**Matches typst** (checked on the LibreOffice PDF): EB Garamond 12 pt (embedded, `pdffonts`); double spacing at 24 pt; 1-inch margins on US Letter; the two court-title lines; the caption as a table with a right and a bottom rule on the party column, "v." between the parties, the case number and the bold title; the lead-in paragraph; unnumbered body paragraphs with a half-inch first-line indent; the facts list numbered 1., 2., ... with a hanging indent; level-1 headings centered in bold capitals, level-2 bold and level-3 bold italic, both with a hanging indent; block quotations single-spaced and indented a half inch on both sides; the signature block at 3.25 in, kept with the conclusion; the certificate of compliance (the word count and software, from the frontmatter) and the certificate of service (recipients at a half-inch indent); the footer from page 2 on (page number, title in capitals, "Case No.") and no footer on page 1.

The text matches typst word for word (the same comparison as in the complaint's Engines section; one character differs at a page boundary). Some line breaks fall one word differently.

**Differs from typst:**
- Pagination. The docx runs 14 pages against typst's 13, for the reason given in the complaint's Engines section (LibreOffice's baseline placement in exact-height lines). Page breaks are not forced.
- The footer title and case number are document properties (`subject`, `description`), shown by the `SUBJECT` and `COMMENTS` fields.
- The word count is the filer's (as in the typst template): the build stops if the stated count is over 13,000 words or the `compliance` block is missing, as the typst template does. The template does not count words.
- Word was not available. The `.docx` was converted and checked in LibreOffice only.

**docx BLOCKED:** `tools/check.sh --engine docx` (Gates 0 to 3) was not run. This folder has no `rules.md` or `checks.yaml`, and the brief forbids adding them or changing `tools/`. So no docx check ID is green or red: `BLOCKED: check.sh (all gates): no rules.md / checks.yaml in this folder; gates not run`.
