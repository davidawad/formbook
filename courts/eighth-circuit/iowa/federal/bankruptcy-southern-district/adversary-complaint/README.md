# iasb: adversary complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court, Southern District of Iowa (`iasb`), an adversary proceeding under Fed. R. Bankr. P. 7001 (objection to dischargeability, § 523(a)(6)).
Folder: `courts/eighth-circuit/iowa/federal/bankruptcy-southern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-sturm-25-01022-adversary-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-sturm-complaint.md`: caption, all 20 numbered allegations of the filing (plus the two paragraphs the template generates for FRBP 7008), all four headings, the table after ¶ 18, prayer (A to D), signature block. The cover sheet (Form 1040) is not transcribed. |
| render | ok: `samples/OUTPUT-sturm-complaint.pdf`, 5 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh <dir> samples/INPUT-sturm-complaint.md`) |
| overlay | ok: `samples/OVERLAY-sturm-complaint.pdf` and `samples/OVERLAY-sturm-complaint.txt` (`sh tools/overlay.sh <dir> sturm-complaint`) |
| pages reviewed | 5 of 5 (every page rendered at 60 dpi and viewed after the last template change) |
| BLOCKED | none for this doc type. A second filer was not found (see Known gaps 1). |

File names: the brief lists `samples/<id>.pdf` and `samples/<id>-overlay.pdf`. The shared tools write and read `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` by default, and the tools are not to be edited, so the render and overlay follow the tools' names.

## Governing rules

There is **no local rule** for this court's typography, page limits or pleading form. The court's website says: "Effective August 4, 2003, this court's local rules were abolished. Attorneys and pro se parties shall consult the Federal Rules of Bankruptcy Procedure." (https://www.iasb.uscourts.gov/bankruptcy-rules, fetched 2026-10-14.) The brief's reference to "this court's local bankruptcy rules" therefore has nothing to cite; the rules below are the national rules, and the court's own forms.

| Rule | Requirement | Kind | Where in the template | Source (verified) |
|---|---|---|---|---|
| Fed. R. Bankr. P. 7010 | Fed. R. Civ. P. 10 applies in an adversary proceeding; the caption must substantially conform to Official Form 416D. | M | `caption()` (court name, debtor, plaintiff, defendant, Case No., Chapter, Adv. Proc. No.) | https://www.law.cornell.edu/rules/frbp/rule_7010 (as amended eff. 2024-12-01), verified 2026-10-14 |
| Fed. R. Bankr. P. 7008 | The allegation of jurisdiction names the case (name, number, Code chapter), the district and the division; a complaint must state whether the pleader consents to final orders or judgment by the bankruptcy court. | M | Numbered ¶¶ 1 and 2 are generated from `chapter`, `debtors`, `case_number`, `division` and `final_orders_consent`; the template asserts the two fields exist. | https://www.law.cornell.edu/rules/frbp/rule_7008 (eff. 2024-12-01), verified 2026-10-14 |
| Fed. R. Bankr. P. 9004(a) | Documents must be legible; commonly used abbreviations are acceptable. | M | Text is Times-metric serif, 12 pt, black (`type-size`); no typeface is required. | https://www.law.cornell.edu/rules/frbp/rule_9004 (eff. 2024-12-01), verified 2026-10-14 |
| Fed. R. Bankr. P. 9004(b) | Caption: court name, case title, case number and adversary number if any, and a brief designation of the document. | M | `caption()`, `brief_title`. | same |
| Fed. R. Civ. P. 10(a) (via 7010) | Caption with the court's name, a title, a file number, and a Rule 7(a) designation. | M | `caption()`; the title line is `brief_title`. | https://www.law.cornell.edu/rules/frcp/rule_10 (as amended eff. 2007-12-01), verified 2026-10-14 |
| Fed. R. Civ. P. 10(b) (via 7010) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | M | Each paragraph of the body is numbered by the template (`body-content()`); headings, the WHEREFORE paragraph, tables, quotations and the list are not. | same |
| Fed. R. Bankr. P. 9011(a) | Signed by at least one attorney of record in the attorney's individual name; the document states the signer's address and telephone number. | M | `signature-block()`: "/s/" signature, counsel lines (address, telephone). | https://www.law.cornell.edu/rules/frbp/rule_9011 (eff. 2024-12-01), verified 2026-10-14 |
| Official Form 416D (12/15) | The caption for an adversary proceeding (the form the rule names). | M (by 7010) | `caption()` labels follow the form: "In re", "Debtor", "Plaintiff", "v.", "Defendant", "Adv. Proc. No.". | https://www.uscourts.gov/file/18775/download (form text as printed, 12/15), fetched 2026-10-14 |
| Official Form 1040 (cover sheet) | Adversary Proceeding Cover Sheet, completed and filed with each complaint (the exemplar's instructions say so; in CM/ECF it is captured at filing). | C (form instructions as printed on the exemplar, 12/15) | Not produced by the template. A separate filing. | exemplar pages 1 to 2 |
| Fed. R. Bankr. P. 9037 / Fed. R. Civ. P. 5.2 | Redaction of social security numbers, taxpayer ID numbers, birth dates, and minors' names; the filer's responsibility. | A | Not checked. The sample uses names only. | not re-verified this pass |

Not produced here: the summons (Official Form 287 or the court's summons form), the cover sheet, the filing fee, the exhibits (the exemplar's Exhibits A to O are not in this folder), and any separate jury demand (none is made in the exemplar).

## Markdown contract (for samples)

A sample is one `.md` file.

- YAML frontmatter. Required: `case_number` (e.g. `"25-01022-lmj7"`), `chapter`, `debtors` (list of names, printed as they appear in the caption), `caption.plaintiffs` and `caption.defendants` (each a list of `{names, designation}`), `division` (FRBP 7008), `final_orders_consent` (FRBP 7008: the pleader's statement, which the author writes), `brief_title`, `date`, `signature` (`signer`, `lines`; `firm` optional, printed before the "By:" line). Optional: `adv_number` (blank by default, printed as a blank line), `lead_in` (the unnumbered "COMES NOW ..." paragraph).
- The body is blank-line-separated chunks. A `#` heading is a centered section in capitals; `##` a bold sub-heading; `###` bold italic. A paragraph is numbered by the template: **do not type the number in the sample**. A paragraph starting `WHEREFORE` is unnumbered. A list (`- ` items) is lettered A., B., C. A table (`|` rows) is rendered as a table and not numbered. A `>` quotation is single-spaced and indented.
- Case names are italic in `*...*`. Markdown is rendered by `cmarker` (vendored).
- Not supported: footnotes (none are used here; `cmarker` would render them).

## Layout and convention choices (tier 2)

- Letter paper, one-inch margins, page number centered at the foot of each page.
- EB Garamond 12 pt, body double-spaced (`body-leading` = 1.35em), block quotations and the table single-spaced, numbered paragraphs with a half-inch first-line indent.
- Caption: court name centered in bold capitals; the parties in a left column with a rule on the right and the bottom; the case number, chapter and adversary number in the right column; the title centered in bold below.
- Headings: section headings centered and bold in capitals, as in the exemplar.
- Signature block: date on the left; "Respectfully submitted," the firm, "By: /s/" the signer and the counsel lines on the right.

## What the overlay shows

`samples/OVERLAY-sturm-complaint.pdf`: red is our render, blue is the filed exemplar pages (complaint pages 3 to 8, paired by shared words), black where both agree. Pairing (from `OVERLAY-sturm-complaint.txt`): our p.1 to exemplar p.3, p.2 to p.4, p.3 to p.6, p.4 to p.7, p.5 to p.8. Word overlap is per page as listed in the txt file. The overlay is a diagnostic, not a score: the differences are the typeface (EB Garamond vs Times New Roman; the exemplar's x-height is larger), the line pitch, the numbered-paragraph indent and the caption rule. Our render is 5 pages against the exemplar's 6 for the same content; the difference is the font and the pitch, not omitted text.

## Gate 2 review (every page of the current PDF)

Current PDF: `samples/OUTPUT-sturm-complaint.pdf`, 5 pages, rendered after the last template change (division and consent paragraphs added to ¶¶ 1 and 2). Compared with exemplar p.3 (caption and first allegations) to p.8 (prayer and signature).

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.3 | Caption: court name bold centered (two lines, spacing fixed; first render had the two lines overlapping); debtor, plaintiff, defendant in the left column with a rule; Case No., Chapter, Adv. Proc. No. right; title centered. Numbered ¶¶ 1 and 2 (rule 7008 sentences) generated by the template. | FIXED (line overlap in the court name; the first render also overlapped numbered paragraphs because the paragraph spacing was zero; fixed by removing the zero spacing). Re-viewed: PASS. |
| 2 | exemplar p.4 | Block quotation single-spaced, indented both sides; ¶¶ 9 to 13 numbered. | PASS |
| 3 | exemplar p.5 | ¶¶ 14 to 18 (¶ 18 runs onto the foot of the page). | PASS |
| 4 | exemplar p.6 | Table (eight rows and total) single-spaced, indented to paragraph text, with a border; ¶¶ 19 to 22; heading "III." centered. | PASS |
| 5 | exemplar p.7 | Prayer heading and WHEREFORE unnumbered; lettered items A to D with hanging indent; signature block with date, firm, "By: /s/" and counsel lines. | PASS |
| 1 to 5 | exemplar p.3 to p.8 | Italic case names, "Kraus Anderson" citation as filed (see Known gaps 6). | ACCEPTED (tier 3: the exemplar's own citation form) |

## Known gaps and open choices

1. **One exemplar.** EVAL-LOOP asks for 2 or 3 filers for tier 2. The CourtListener search (`court=iasb`, `type=r`, 2026-10-14) found several adversary complaints (e.g. Taylor Builders v. DeBoth, 26-30006; Christenson Revocable Living Trust v. DeBoth, 26-30007; Smith v. Schappert, 25-30006; Smith v. Neely, 26-30017) with no downloadable document 1 (`is_available: false`), and Lindsay Sturm adversary 25-30032 (scanned, no text layer). Tier 2 is therefore **not** judged against two filers. It is judged against one.
2. **Typeface and size.** No rule mandates either. EB Garamond at 12 pt is the only serif vendored in `fonts/`; the exemplar is Times New Roman. Recorded as a choice, not a defect. If the court or David prefer Times-metric output, a Times-compatible font must be vendored (not done here: `fonts/` is not ours to change).
3. **Consent sentence (FRBP 7008).** The exemplar complaint has no consent statement; the rule requires one. The template takes it from the frontmatter and the sample's sentence is a placeholder: the author chooses the wording. This is a finding about the exemplar (a tier-1 gap in the filed document), not something the template can decide.
4. **Division (FRBP 7008).** The exemplar's jurisdiction paragraphs do not name the case number or the division; the division (Central) is on the cover sheet only. The template generates a case-reference paragraph from the case fields, so the rule's content is present in every render. The sample's `division` value comes from the cover sheet, not the complaint text.
5. **Adversary number.** The filed copy's "Adversary Case No." is blank (the clerk assigns the number on filing). The template prints a blank line when `adv_number` is empty, and the sample leaves it blank.
6. **Citation form.** The exemplar's citation "14 Fed App. 0001 (6th Cir. BAP, 3-26-2014, footnote 2)" is transcribed as filed. A correct citation would be to the reporter's form; that is an author responsibility (Bluebook/Local practice), not a template rule, and is not corrected here.
7. **Transcription.** The text layer has OCR artifacts ("Gran tor", "!>", "Plaintiffs"); the sample reads them as the filing does ("Grantor", the close quotation mark, "Plaintiff's"). Paragraph 6's "(b)(2)(1)" in the text layer is transcribed as "(b)(2)(I)". The consent sentence is the only added text (see gap 3).
8. **Signature date.** The exemplar's signature block has no date line; the template prints "Dated:" as a convention. Recorded as ACCEPTED.
9. **Paper.** FRBP 9004 (restyled 2024) no longer states a paper size; 8½ × 11 is used.
10. **Summons, cover sheet, fee, exhibits, redaction** are not produced or checked (see "Not produced here").
