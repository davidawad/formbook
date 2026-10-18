# E.D. Wis. Bankruptcy: motion with brief in support (`wieb`, doc type `motion-brief`)

Governs a motion in an adversary proceeding or contested matter, with a memorandum (brief) in support, filed in the United States Bankruptcy Court for the Eastern District of Wisconsin. Template: `typst/wieb-motion-brief.typ`; entry point `typst/main.typ`.

## Exemplar

- `usage/SAMPLE-wieb-motion-brief-vongermetenvlindblom2202024.pdf`: Gray & Associates, L.L.P. for the defendants, "Motion ... to Dismiss Adversary Complaint" with notice of motion and "Brief in Support of Motion to Dismiss Adversary Complaint", Adv. No. 22-02024-rmb, filed 04/08/2022 (38 pp. including Exhibits A-G). Provenance and checksum in `usage/SOURCE.md`.
- Sample: `usage/INPUT-wieb-motion-brief-vongermetenmotion.md` (portion transcription; citations not checked against reporters; see the header of the sample). Render: `usage/OUTPUT-wieb-motion-brief-vongermetenmotion.typst.pdf` (11 pp.). Overlay: `usage/OVERLAY-vongermeten-motion.pdf` and `.txt`.

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

Frontmatter: `debtor`, `plaintiff`, `defendant`, `adversary_number` (as in the complaint); `movants` and `notice_verb` (for the notice); `objection_days` (integer, at least 14); `title` (the motion's title) and `brief_title`; `dated`; `signers` (`signer`, `lines`); `certificate` (`ecf` list, `non_ecf` list of `name`, `lines`). The body is one markdown file split into the motion and the brief by a line reading exactly `%%BRIEF%%`. Headings: level 1 is a centered bold section (INTRODUCTION, I. BACKGROUND, ...); level 2 is a bold subhead (A., B., ...). Subheads and paragraph numbers are typed by the drafter.

## What the overlay shows

`usage/OVERLAY-vongermeten-motion.pdf`: red is our render, blue is the filed exemplar, black is agreement. Pages pair by word overlap (`OVERLAY-vongermeten-motion.txt`). Our page 1 (the generated notice) overlaps the filed page 1 at 22.6%, which is expected: the notice text is rule-driven and not the filed notice. Our page 4 (signature alone) pairs weakly (8.8%) with the filed page 2. Other pages overlap 46-70%, which reflects the font and line breaks.

## Page review (Gate 2, every page rendered at 60 dpi and viewed)

Pages reviewed: 11 of 11.

- p.1 (notice of motion and signature): clean; objection period from frontmatter.
- p.2 (caption and motion start): clean; caption lines single-spaced; motion title centered.
- p.3 (motion grounds 3-4 and WHEREFORE): clean.
- p.4 (signature block alone): OPEN, see gaps.
- p.5 (brief caption and INTRODUCTION): clean; first-line indents applied.
- p.6-7 (background, standard of review): clean.
- p.8 (argument A and B start): clean.
- p.9 (argument B end, D, block quote): clean; block quote is indented and single-spaced.
- p.10 (argument E, conclusion, signature): clean.
- p.11 (certificate of service): clean; ECF and non-ECF service with date and person.

Fixed during review: first-line indents were missing from the motion and brief body paragraphs, so the paragraphs ran together. Caption and signature line overlap was fixed by single-spacing the stacked lines.

## Known gaps / OPEN and ACCEPTED findings

- OPEN: the motion's final WHEREFORE paragraph and its signature block split across pages 3-4; page 4 holds the signature block alone. The signature block is kept whole, but the template does not keep it with the preceding paragraph (needs keep-with-next across cmarker output). Clerks accept it, but a tier-2 pass would fix it.
- ACCEPTED: font is EB Garamond 12 pt (the only vendored font); it looks smaller than the filed Times-like face at the same size. The rule sets the size, not the face.
- OPEN: the notice text is rule-driven and does not follow the Official Form notice (LR 9014-1(a)(1)(A) asks for a notice that "substantially complies" and conforms with the appropriate Official Form). The Official Form was not fetched or compared. Before filing, check it against the form.
- OPEN: the exemplar's footnotes (footnotes 1-3 in the brief) and its Exhibits A-G are not transcribed.
- OPEN: argument C (claim preclusion under Wisconsin law) of the exemplar is omitted from the transcription and marked in the sample.
- OPEN: the OCR-derived citations are not checked against reporters (see the sample header).
- ACCEPTED: the sample is a portion of the filing, as the header states; the template is not built around this one filing.
- Not in template: proposed order (LR 9014-2), which must be a separate editable PDF; hearing notices under LR 9014-1(a)(3) if an objection is filed.

## BLOCKED status

No: an exemplar was found (CourtListener RECAP, E.D. Wis. adversary 22-02024). This doc type is not blocked.

## Build

    sh tools/render.sh courts/seventh-circuit/wisconsin/federal/bankruptcy-eastern-district/motion-brief usage/INPUT-wieb-motion-brief-vongermetenmotion.md courts/seventh-circuit/wisconsin/federal/bankruptcy-eastern-district/motion-brief/usage/OUTPUT-wieb-motion-brief-vongermetenmotion.typst.pdf

The overlay step is run on a temporary `OUTPUT-wieb-motion-brief-vongermetenmotion.typst.pdf` copy, and its outputs are renamed to `OVERLAY-vongermeten-motion.pdf` and `.txt`, as for the complaint.

## Engines

- **typst** (primary, `typst/`): the reference for the court's form.
- **docx** (`docx/reference.docx`, `docx/build-reference.sh`, `docx/wieb.lua`): pandoc on a reference.docx built from pandoc's default (EB Garamond 12 pt, exact 24 pt line pitch, 1 in margins on letter paper, centered PAGE footer, bold centered level-1 headings, bold level-2, italic level-3, body paragraphs with a 0.5 in first-line indent, numbered paragraphs typed by the drafter). The filter lays out the notice of motion (page 1), the motion and the brief in support (each with its own caption), and the certificate of service, split at the `%%BRIEF%%` line. The captions and signature blocks are styled paragraphs with tab stops; no tables; the only raw openxml is the page breaks. Every case word comes from the frontmatter. Built to `usage/OUTPUT-wieb-motion-brief-vongermetenmotion.docx`; the zip and XML parts were checked (`unzip -tq`, `xmllint --noout`).
  - Matches the typst form: font and size, double spacing, margins, page order (notice, motion, brief, certificate), the caption order, the notice text and objection period from frontmatter, the "Respectfully submitted" and "/s/" signature blocks, the certificate text.
  - Differs or unverified: the typst caption is a two-column grid with a vertically centred right column; the docx approximates it with tab stops and puts the adversary number on the "v." row. Its rules are paragraph borders, not checked against typst's lines. The numbered-paragraph layout is a pleading convention, not the typst enum layout. The motion's signature block is kept together but not with the preceding paragraph (the typst template does not do this either; see the Known gaps above). Word's line breaks may differ from typst's.
  - BLOCKED on this box: `soffice` (LibreOffice) is not installed, so `usage/OUTPUT-vongermeten-motion.docx.pdf` was not produced and the docx Gates 0 to 3 cannot run. No page was rendered or reviewed (0 pages). Not opened in Word. The typst template has no table of contents or table of authorities, so the TOC/TOA field caveat does not apply to this doc type.
