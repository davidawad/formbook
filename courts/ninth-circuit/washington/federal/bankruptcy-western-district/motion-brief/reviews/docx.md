# Gate 2 review, docx (LibreOffice PDF), smith-motion-memorandum

Reviewer: the docx engine agent, 2026-10-15. Method: `pdftoppm -r 60`, every page viewed. Comparison: the typst render of the same sample (`/work/artifacts/wawb/motion-brief/typst-smith-motion-memorandum.pdf`), pages 1 and 12 viewed.

## sample smith-motion-memorandum docx

- PDF: `usage/OUTPUT-smith-motion-memorandum.docx.pdf`, sha256 `d2952185cf7f12ddef25a96f213e336bea1d20d3cedc13338c87da6fd0296ad0`
- DOCX: `usage/OUTPUT-smith-motion-memorandum.docx`, sha256 `55bb04330125384687d0303c1ba23e9136b9259809fcad69d812ca467d3cc7c3`

| page | verdict | note |
|---|---|---|
| 1 | Pass | notation top right (judge, chapter, hearing data), court title, caption with the ")" column, title at right, notice-and-motion paragraph, background list |
| 2 | Pass | background list (continued), RELIEF REQUESTED, arrears paragraphs |
| 3 | Pass | reduction request, MEMORANDUM OF LAW, first statute-of-limitations paragraphs |
| 4 | Pass | Citing line; acceleration heading (two lines) kept with its paragraph; Merritt block quotation |
| 5 | Pass | POLICY heading, LUV block quotation, Impact of bankruptcy Filing heading |
| 6 | Pass | discharge and stay paragraphs; RCW 4.16.230 block quotation |
| 7 | Pass | Impact of US Bankruptcy laws; Hazel facts |
| 8 | Pass | 11 U.S.C. 108(c) block quotation |
| 9 | Pass | minority-jurisdiction and Ninth Circuit paragraphs |
| 10 | Pass | First mortgage history heading (two lines); loan transfer paragraphs |
| 11 | Pass | bankruptcy history; the three-item bullet list (text at 0.9 in); the omitted-table note; Dated and signature lines on the grid |
| 12 | Pass | certificate of service: party list at the foot |

Open: none in tier 1. Tier 2 pagination differs from typst (LibreOffice line breaks; the "Dated:" block and the certificate fall on different pages); recorded in the README Engines section, not a defect.
