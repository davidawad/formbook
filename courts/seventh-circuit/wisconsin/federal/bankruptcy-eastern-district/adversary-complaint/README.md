# E.D. Wis. Bankruptcy: adversary complaint (`wieb`, doc type `adversary-complaint`)

Governs an adversary complaint filed in the United States Bankruptcy Court for the Eastern District of Wisconsin under Fed. R. Bankr. P. 7001 et seq. Template: `typst/wieb-adversary-complaint.typ`; entry point `typst/main.typ`.

## Exemplar

- `usage/FILED-EXAMPLE-adversary-complaint.pdf`: the U.S. Trustee's complaint to deny a Chapter 7 discharge, *Layng v. Clarke* (In re Marissa J. Clarke), Adv. No. 22-02003-kmp, filed 01/13/2022 (11 pp.). Provenance and checksum in `usage/SOURCE.md`.
- Sample: `usage/INPUT-adversary-complaint.md` (full transcription, 87 numbered paragraphs, 10 rendered pages in typst and docx). Render: `usage/OUTPUT-adversary-complaint.typst.pdf`. Overlay: `usage/OVERLAY-layng-clarke.pdf` and `usage/OVERLAY-layng-clarke.txt`.

## Governing rules (verified 2026-10-14)

| Requirement | Source | Verified | Template use |
|---|---|---|---|
| WIEB-FORM-001: proportional font not smaller than 12-point | E.D. Wis. Bankruptcy Local Rule (LR) 9004-1(a), 2026 Local Rules: https://www.wieb.uscourts.gov/sites/default/files/forms/2026%20Local%20Rules%20WIEB.pdf | 2026-10-14 | `type-size = 12pt` |
| WIEB-FORM-002: double-spaced | LR 9004-1(a) | 2026-10-14 | `pitch-body = 24pt`: exact 24 pt line boxes on the shared cross-engine model (`lib/typst/xengine.typ`), typst and docx alike |
| WIEB-FORM-003: one-inch margins on all sides | LR 9004-1(a) | 2026-10-14 | `page-margin = 1in` |
| Sequential page numbers | LR 9004-1(c) (stated for paper filings; applied to all) | 2026-10-14 | page number, bottom center |
| Text-searchable PDF filing | LR 5005-1(a)(2)-(3) | 2026-10-14 | the render has embedded fonts and extractable text |
| Caption substantially conforms to Form 416 | Fed. R. Bankr. P. 7010 (restyled eff. Dec. 1, 2024): https://www.law.cornell.edu/rules/frbp/rule_7010 | 2026-10-14 | caption: court, debtor and case, adversary number, party designations |
| Statement whether the pleader does or does not consent to entry of final orders | Fed. R. Bankr. P. 7008(a) (eff. Dec. 1, 2024): https://www.law.cornell.edu/rules/frbp/rule_7008; LR 7008-1 (omission forfeits the right to withhold consent) | 2026-10-14 | required `consent` field ("does" or "does not"); the template panics if it is missing or invalid |
| Signature: "/s/" followed by the printed name | LR 5005-2(a)(1)(A) | 2026-10-14 | signature block |
| Numbered paragraphs | FRCP 10(b), as applied through FRBP 7010 (Rule 7010 incorporates FRCP 10 caption rules) | 2026-10-14 | drafter-typed paragraph numbers, rendered by cmarker with the same numbers |

Note: the 2016 amendment removed the old FRBP 7008(a) core/non-core statement; the 2024 restyling kept only the consent statement. The template does not print a core/non-core statement.

Not found in the 2026 Local Rules: a page limit for complaints. The text search returned none.

## Markdown contract

Frontmatter fields: `debtor` (`name`, `designation`, `case_number`, `chapter`); `plaintiff` and `defendant` (`names` list, `designation`); `adversary_number`; `title`; `consent` (`does` or `does not`); `dated`; `signers` (list of `signer` and `lines`). The body is cmarker markdown. Headings: level 1 is a centered bold section, level 2 and 3 are run-in subheads. Numbered paragraphs are written as `1.`, `2.`, ... and keep their numbers across headings.

## What the overlay shows

`usage/OVERLAY-layng-clarke.pdf`: red is our render, blue is the filed exemplar, and black is where both agree. Each page is paired with the exemplar page sharing the most words (`OVERLAY-layng-clarke.txt`). Pages pair 1:1 for the caption and the first two pages. Later pages pair with an offset (ours p.3 to filed p.4, ours p.8 to filed p.10) because our rendering is shorter per page with different breaks. Word overlap is 46-71%, which reflects the font difference (EB Garamond vs. the filed Times-like face) and paragraph breaks rather than a content mismatch.

## Page review (Gate 2, every page rendered at 50 dpi and viewed; 2026-10-22, fb-595.68.28)

Pages reviewed: 10 of 10, typst and docx; the docx breaks every line and page as typst does (XENG-001..003).

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title; caption (In re: debtor, case number and chapter centered beside it, a rule; the parties with "v.", the adversary number centered beside them, a rule); title; consent sentence; the lead paragraph; JURISDICTION AND VENUE, paragraphs 1-4 | OK |
| 2 | Paragraphs 5-18, THE PARTIES, FACTS | OK |
| 3 | Paragraphs 19-28, "A. The Defendant's Schedules", "Assets" (level 3, bold italic) | OK |
| 4 | "Debts", paragraphs 29-36, "Income and Expenses", paragraphs 37-40 | OK |
| 5 | "Statement of Financial Affairs", paragraphs 41-45, "B. Undisclosed SBA ...", paragraphs 46-50 | OK |
| 6 | Paragraphs 51-62 | OK |
| 7 | Paragraphs 63-66, COUNT I and its title (bold, left, two lines), paragraphs 67-70 | OK |
| 8 | Paragraph 71, "a. Statement under Oath", 72-75, "b. False Statements", 76-79 | OK |
| 9 | Paragraph 79 (end), "c. Knowing and Fraudulent", 80-82, "d. Materiality", 83-87 | OK |
| 10 | CONCLUSION, the WHEREFORE paragraph, "Dated:", the two "/s/" signers at 3.25 in, kept on one page | OK |

Numbers in the drafter's markdown sit in a 0.4 in box after the 0.5 in indent; their lines hang at 0.9 in.

## Known gaps / OPEN and ACCEPTED findings

- Font: Times New Roman 12 pt (vendored), the house standard (`docs/FONTS.md`), in typst and docx alike; LR 9004-1(a) allows any proportional face of at least 12 points.
- OPEN: the consent sentence is generated by the template right after the title, and the transcription also keeps the filed paragraph 6 consent sentence. A drafter would normally keep one. The template statement is the rule requirement; the duplicate is a transcription artifact.
- OPEN: the Count heading subtitle is left-aligned bold; the filing centers it. Cosmetic.
- OPEN: summons (Official Form 417A) and the Civil Cover Sheet are not part of this template. A complaint is filed with them, and the summons is issued by the clerk.
- OPEN: Local chambers procedures (judge-specific) were not checked.
- Not built: ECF attachment and matrix requirements (LR 9013-2(b)) do not apply to complaints in this template.

## BLOCKED status

No: an exemplar was found (CourtListener RECAP, E.D. Wis. adversary 22-02003). This doc type is not blocked.

## Build

    sh tools/render.sh courts/seventh-circuit/wisconsin/federal/bankruptcy-eastern-district/adversary-complaint usage/INPUT-adversary-complaint.md courts/seventh-circuit/wisconsin/federal/bankruptcy-eastern-district/adversary-complaint/usage/OUTPUT-adversary-complaint.typst.pdf

The overlay step (`tools/overlay.sh`) reads `usage/OUTPUT-<id>.pdf`. The sample render is named `<id>.pdf` as specified, so the overlay is run on a temporary `OUTPUT-<id>.pdf` copy, and its outputs are renamed to `<id>-overlay.pdf` and `<id>-overlay.txt`.

## Engines

- **typst** (primary, `typst/`): the reference for the court's form, on the shared cross-engine layout model (`lib/typst/xengine.typ`): 24 pt body and 14.4 pt single line boxes, headings single-spaced.
- **docx** (`docx/reference.xml`, `docx/wieb.lua`): `reference.xml` holds the Word styles (`base="xengine"` in the typst face `{font}`, Times New Roman, 12 pt, 480-twip body and 288-twip single line boxes, the 12 pt page-number footer 0.5 in above the page edge; `fb render` builds the reference document from it); `wieb.lua` reads the sample's body chunk by chunk as the typst template does and writes the caption (a table of two rows ruled at their foot, the numbers centered beside the parties), the title, the consent sentence, headings, numbered paragraphs and the signature as WordprocessingML on `lib/docx/xengine.lua`. No script: `fb render` runs pandoc with the filter and packs the archive (fb-595.68.28; were `build-reference.sh` and a committed `reference.docx` naming EB Garamond, which failed DEF-FONT-002). Every case word comes from the frontmatter and body.
  - Cross-engine (fb-595.68.28): `sh tools/check.sh <this folder> --engine docx`: XENG-001..003 PASS (10 = 10 pages, 251/251 lines break after the same word); `params.cross_engine: gate` in `eval.yaml`. typst 9 and docx 13 checks passed, 0 failed.
  - The `.docx` converts in LibreOffice without error (the check's conversion); not opened in Word. No table of contents or table of authorities in this doc type.
