# E.D. Wis. Bankruptcy: motion with brief in support (`wieb`, doc type `motion-brief`)

Governs a motion in an adversary proceeding or contested matter, with a memorandum (brief) in support, filed in the United States Bankruptcy Court for the Eastern District of Wisconsin. Template: `typst/wieb-motion-brief.typ`; entry point `typst/main.typ`.

## Exemplar

- `usage/FILED-EXAMPLE-motion-brief.pdf`: Gray & Associates, L.L.P. for the defendants, "Motion ... to Dismiss Adversary Complaint" with notice of motion and "Brief in Support of Motion to Dismiss Adversary Complaint", Adv. No. 22-02024-rmb, filed 04/08/2022 (38 pp. including Exhibits A-G). Provenance and checksum in `usage/SOURCE.md`.
- Sample: `usage/INPUT-motion-brief.md` (portion transcription; citations not checked against reporters; see the header of the sample). Render: `usage/OUTPUT-motion-brief.typst.pdf` (12 pp.; docx `usage/OUTPUT-motion-brief.docx` and `.docx.pdf`, 12 pp.). Overlay: `usage/OVERLAY-vongermeten-motion.pdf` and `.txt`.

## Governing rules (verified 2026-10-14)

| Requirement | Source | Verified | Template use |
|---|---|---|---|
| Font not smaller than 12-point; double-spaced; one-inch margins on all sides | E.D. Wis. Bankruptcy Local Rule (LR) 9004-1(a), 2026 Local Rules: https://www.wieb.uscourts.gov/sites/default/files/forms/2026%20Local%20Rules%20WIEB.pdf | 2026-10-14 | `type-size = 12pt`, `body-leading = 1.35em` (about 24 pt pitch, measured), `page-margin = 1in` |
| Effective date of the 2026 Local Rules | Order Approving Local Bankruptcy Rules, dated 12/17/2025, effective 01/01/2026: https://www.wieb.uscourts.gov/sites/default/files/general-ordes/ORDER%20Adopting%202026%20Local%20Rules.pdf | 2026-10-14 | source for all LR cites below |
| Motion must state its grounds with particularity and the relief requested | Fed. R. Bankr. P. 9013 (eff. Dec. 1, 2024): https://www.law.cornell.edu/rules/frbp/rule_9013; LR 9013-1(d) | 2026-10-14 | motion grounds numbered, WHEREFORE clause |
| Title describes the relief; the motion states the Code sections, Rules, and other authority relied on; exhibits referenced | LR 9013-1(a), (b), (e) | 2026-10-14 | `title` and `brief_title` (title line); `authority` field recorded in the sample |
| Notice of motion with the objection period (at least 14 days, unless the rule or court sets another), and the statement that the court may act without a hearing if no timely objection is filed | LR 9014-1(a)(1)-(3); the template panics if `objection_days` is below 14 | 2026-10-14 | page 1 "Notice of Motion" generated from frontmatter |
| Proposed order filed after no objection | LR 9014-1(a)(5), LR 9014-2 | 2026-10-14 | cited in the notice; the proposed order is not in this template |
| Certificate of service: names and addresses for non-CM/ECF service, date, method, and person | LR 9013-2(a); LR 7005-1 applies it in adversary proceedings | 2026-10-14 | certificate page from frontmatter `certificate` |
| Attachment of the court matrix when serving all creditors | LR 9013-2(b) | 2026-10-14 | not in the template (the sample serves only ECF and one non-ECF party) |
| Signature: "/s/" followed by the printed name | LR 5005-2(a)(1)(A) | 2026-10-14 | signature block |
| Text-searchable PDF | LR 5005-1(a)(2)-(3) | 2026-10-14 | the render embeds fonts and has text |
| Motion to dismiss under FRCP 12(b)(6), via FRBP 7012 | FRBP 7012(b) (as cited in the exemplar) | 2026-10-14 | sample content only |

Checked and not found: a page limit for motions or briefs in the 2026 Local Rules (no match for page or pages limits).

## Markdown contract

Frontmatter: `debtor`, `plaintiff`, `defendant`, `adversary_number` (as in the complaint); `movants` and `notice_verb` (for the notice); `objection_days` (integer, at least 14); `title` (the motion's title) and `brief_title`; `dated`; `signers` (`signer`, `lines`); `certificate` (`ecf` list, `non_ecf` list of `name`, `lines`). The body is one markdown file split into the motion and the brief by a line reading exactly `<!-- BRIEF -->`. A markdown numbered list is set as numbered paragraphs (the number at the 0.5 in indent, the text from 1 in); a `>` quotation single-spaced, indented 0.5 in on both sides. Headings: level 1 is a centered bold section (INTRODUCTION, I. BACKGROUND, ...); level 2 is a bold subhead (A., B., ...). Subheads and paragraph numbers are typed by the drafter.

## What the overlay shows

`usage/OVERLAY-vongermeten-motion.pdf`: red is our render, blue is the filed exemplar, black is agreement. Pages pair by word overlap (`OVERLAY-vongermeten-motion.txt`). Our page 1 (the generated notice) overlaps the filed page 1 at 22.6%, which is expected: the notice text is rule-driven and not the filed notice. Our page 4 (signature alone) pairs weakly (8.8%) with the filed page 2. Other pages overlap 46-70%, which reflects the font and line breaks.

## Page review (Gate 2, every page of the typst and docx renders viewed at 50 dpi; fb-595.68.28)

Pages reviewed: 12 of 12 on both engines; the docx breaks every line and page as typst does (XENG-001..003).

- p.1 (notice of motion and signature): clean; objection period from frontmatter.
- p.2 (caption and motion start, numbered grounds 1-2): clean; caption single-spaced, the parties' row ruled above and below, the adversary number beside "v."; motion title centered bold.
- p.3 (motion grounds 3-4 and WHEREFORE): clean.
- p.4 (signature block alone): OPEN, see gaps.
- p.5 (brief caption, INTRODUCTION, I. BACKGROUND): clean; headings centered bold, kept with the text.
- p.6-7 (background, II. STANDARD OF REVIEW): clean.
- p.8 (standard of review end, III. ARGUMENT, A.): clean; level-2 heading bold at the margin.
- p.9 (A end, B, the bracketed omission note): clean.
- p.10 (D, block quotation, E): clean; quotation single-spaced, 0.5 in in on both sides.
- p.11 (E end, CONCLUSION, signature): clean.
- p.12 (certificate of service): clean; ECF and non-ECF service with date and person.

## Known gaps / OPEN and ACCEPTED findings

- OPEN: the motion's final WHEREFORE paragraph and its signature block split across pages 3-4; page 4 holds the signature block alone. (Still so after fb-595.68.28, in both engines.) The signature block is kept whole, but the template does not keep it with the preceding paragraph (needs keep-with-next across cmarker output). Clerks accept it, but a tier-2 pass would fix it.
- ACCEPTED: font is Times New Roman 12 pt (vendored), the house standard; LR 9004-1(a) allows any proportional face at 12 pt or more.
- OPEN: the notice text is rule-driven and does not follow the Official Form notice (LR 9014-1(a)(1)(A) asks for a notice that "substantially complies" and conforms with the appropriate Official Form). The Official Form was not fetched or compared. Before filing, check it against the form.
- OPEN: the exemplar's footnotes (footnotes 1-3 in the brief) and its Exhibits A-G are not transcribed.
- OPEN: argument C (claim preclusion under Wisconsin law) of the exemplar is omitted from the transcription and marked in the sample.
- OPEN: the OCR-derived citations are not checked against reporters (see the sample header).
- ACCEPTED: the sample is a portion of the filing, as the header states; the template is not built around this one filing.
- Not in template: proposed order (LR 9014-2), which must be a separate editable PDF; hearing notices under LR 9014-1(a)(3) if an objection is filed.

## BLOCKED status

No: an exemplar was found (CourtListener RECAP, E.D. Wis. adversary 22-02024). This doc type is not blocked.

## Build

    sh tools/render.sh courts/seventh-circuit/wisconsin/federal/bankruptcy-eastern-district/motion-brief usage/INPUT-motion-brief.md courts/seventh-circuit/wisconsin/federal/bankruptcy-eastern-district/motion-brief/usage/OUTPUT-motion-brief.typst.pdf

The overlay step is run on a temporary `OUTPUT-motion-brief.typst.pdf` copy, and its outputs are renamed to `OVERLAY-vongermeten-motion.pdf` and `.txt`, as for the complaint.

## Engines

- **typst** (primary, `typst/`): the reference for the court's form, on the shared cross-engine layout model (`lib/typst/xengine.typ`): 24 pt double pitch, 13.8 pt single lines, no extra space between paragraphs.
- **docx** (`docx/reference.xml`, `docx/wieb.lua`): `reference.xml` holds the Word styles (`base="xengine"` in the typst face `{font}`, Times New Roman 12 pt, 480-twip body and 276-twip single line boxes, the 12 pt page-number footer 0.5 in above the page edge); `fb render` builds the reference document from it. The filter writes every paragraph as WordprocessingML on `lib/docx/xengine.lua`: the notice of motion, the motion and the brief in support (each with its caption, a table whose parties' row is ruled above and below), and the certificate of service, each starting a page, split at the `<!-- BRIEF -->` line; the frontmatter strings come from fb render's `$FORMBOOK_META`. No script: `fb render` runs pandoc with the filter and packs the archive (fb-595.68.28; were `build-reference.sh` and a committed `reference.docx` naming EB Garamond).
  - Cross-engine (fb-595.68.28): `sh tools/check.sh <this folder> --engine docx`: XENG-001..003 PASS (286/286 lines, 12 = 12 pages); `params.cross_engine: gate` in `eval.yaml`. typst 9 and docx 13 checks passed, 0 failed.
  - The `.docx` converts in LibreOffice without error (the check's conversion); not opened in Word. No table of contents or of authorities.
