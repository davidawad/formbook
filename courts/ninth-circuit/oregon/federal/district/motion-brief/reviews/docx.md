# ord motion-brief: Gate 2 review, docx engine

Reviewer: docx engine build (agent), 2026-10-15. Every page of the current LibreOffice PDF was rasterized at 60 dpi
(`pdftoppm -r 60`) and viewed, after the last re-render. The typst reference (12 pages) was rasterized and viewed for
comparison (pages 1, 2, 11 and 12 compared directly). `tools/check.sh` cannot run on this doc-type folder (see the
Engines section of ../README.md), so this file is the Gate 2 record for the docx engine.

## sample zoetis-rule-12-motion-to-dismiss docx

- pdf: `usage/OUTPUT-zoetis-rule-12-motion-to-dismiss.docx.pdf`, sha256 `6d813f664694e6704c25f84125b50e309cc08cec895262b05ec6e205596b81f8`, 12 pages, letter, EB Garamond embedded
- docx: `usage/OUTPUT-zoetis-rule-12-motion-to-dismiss.docx`, sha256 `00f7a099179ea52c6dd1cc011ddc5d8e470434454254d073f12a98250e08abad`
- pages reviewed: 12 of 12

| Page | Content | Finding |
|---|---|---|
| 1 | Cover: counsel block (two firms, blank lines kept), court title, caption, case number at the page center, title in capitals, legend; footer "Page 1 - ..." | OK |
| 2 | LR 7-1 certification; the motion; the start of the memorandum | OK |
| 3 | Introduction (end); FACTS ALLEGED | OK |
| 4 | Facts (end); LEGAL STANDARD | OK |
| 5 | ARGUMENT; I. heading (bold, left); argument text | OK |
| 6 | Block quotation (single-spaced, indented both sides); paragraph; II. heading | OK |
| 7 | II. text; A. heading (bold, indented) | OK |
| 8 | A. text; B. heading (wraps to two lines, indented) | OK |
| 9 | B. text; C. heading | OK |
| 10 | C. text (end); III. heading and its paragraph; the page ends early because CONCLUSION is kept with the signature block (same as typst) | OK |
| 11 | CONCLUSION; DATED and the signature block (two firms) | ACCEPTED: the phone and fax line wraps in the right column at the same place as in typst. |
| 12 | Certificate of service: wording, served party, method, signature | OK |
