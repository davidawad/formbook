# ord complaint: Gate 2 review, typst and docx engines

Reviewer: agent (fb-595.68.24), 2026-10-22, after the move onto the shared cross-engine layout model. Every page of
both current renders was rasterized at 60 dpi (`pdftoppm -r 60`) and viewed side by side; pages 1 and 2 were also
compared with `usage/FILED-EXAMPLE-complaint.pdf` (the Kliewer complaint) and with the rules in `../rules.md`
(LR 10-1, LR 10-2).

## sample complaint

- typst: `usage/OUTPUT-complaint.typst.pdf`, sha256 `fc36da4cd8900ea352f5c28e694292c6a2295176bf556637aa0a246bd7a5c0d4`, 9 pages
- docx: `usage/OUTPUT-complaint.docx.pdf`, sha256 `99a0d8911efa6b5527a14f6d7514ebf70535c1a7bd74a177f2a98629728495f2`, 9 pages (LibreOffice), Times New Roman embedded
- cross-engine: XENG-001..003 PASS, 229/229 typst lines break after the same word in the docx
- pages reviewed: 9 of 9, both engines

| Page | Content | Finding |
|---|---|---|
| 1 | Counsel block upper left; court title 1 in below it, centred, capitals, double-spaced; caption (parties at the margin, "vs."; case number blank and title in capitals from the page center; DEMAND FOR JURY TRIAL); lead-in; I. INTRODUCTION; paragraphs 1-2; footer "COMPLAINT - 1" | OK. Both engines alike. |
| 2 | Paragraph 3; the Hollings quotation single-spaced, indented both sides, unnumbered (as in the exemplar, whose next paragraph is 4); paragraphs 4-9; II heading | OK |
| 3 | Paragraph 10; III heading; "Lead Plaintiff Richard Kliewer" and "The Calls" sub-headings; paragraphs 11-20 | OK |
| 4 | Transcription note; the call table (rules, single-spaced, half an inch in, the elided rows as one "…" row); paragraphs 21-26 | OK |
| 5 | Paragraphs 27-31; IV heading; classes (a)-(c), lettered with a hanging indent; (c) runs on to page 6 | OK |
| 6 | (c) ends; paragraphs 32-39; V heading; "Allegations Applicable to All Counts" | OK |
| 7 | Paragraphs 40-49; "Count 1" heading kept with paragraph 45 | OK |
| 8 | Paragraphs 50-55; VI and VII headings; prayer (a)-(g) | ACCEPTED: the page ends four lines short, because the last prayer item is kept on one page with the signature block (a signature never starts a page alone); both engines alike. |
| 9 | Prayer (h); DATED at the margin, the signature block from 3.1 in | OK |
