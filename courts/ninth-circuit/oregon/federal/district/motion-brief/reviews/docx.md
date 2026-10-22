# ord motion-brief: Gate 2 review, typst and docx engines

Reviewer: agent (fb-595.68.24), 2026-10-22, after the move onto the shared cross-engine layout model. Every page of
both current renders was rasterized at 60 dpi (`pdftoppm -r 60`) and viewed side by side; pages 1 and 2 were also
compared with `usage/FILED-EXAMPLE-motion-brief.pdf` (the Zoetis motion to dismiss, 11 pages) and with the rules in
`../rules.md` (LR 7-1, LR 10-1, LR 10-2).

## sample motion-brief

- typst: `usage/OUTPUT-motion-brief.typst.pdf`, sha256 `1c4e3e259be39f9ad63d49eca22599b3d8687fa7289555a1a5eb726325f6ee9f`, 11 pages
- docx: `usage/OUTPUT-motion-brief.docx.pdf`, sha256 `1ddcc43c357f8f0b5b31b21987a5655ba2e46bf5fc6d12c0b314d682411f5668`, 11 pages (LibreOffice), Times New Roman embedded
- cross-engine: XENG-001..003 PASS, 295/295 typst lines break after the same word in the docx
- pages reviewed: 11 of 11, both engines

| Page | Content | Finding |
|---|---|---|
| 1 | Counsel block (two firms, blank lines kept); court title 1 in below it, centred, capitals, double-spaced; caption (parties at the margin, "vs."; case number, title in capitals and "(Oral Argument Requested)" from the page center); footer "Page 1 - DEFENDANT ZOETIS, INC.'S RULE 12 MOTION TO DISMISS" | OK. The exemplar's first page also holds only the cover. |
| 2 | LR 7-1 CERTIFICATION (LR 7-1(a): conferral in the first paragraph); the motion; MEMORANDUM OF POINTS AND AUTHORITIES | OK. Headings bold, centred, at the type size, as in the exemplar (which also underlines them: tier 3, not chased). |
| 3 | Memorandum (end of introduction); FACTS ALLEGED | OK |
| 4 | Facts (end); LEGAL STANDARD | OK |
| 5 | ARGUMENT; heading I (bold, at the margin); the block quotation begins (single-spaced, indented both sides) | OK |
| 6 | Quotation ends; Fowler citation; heading II | OK |
| 7 | II text; heading A (bold, half an inch in) | OK |
| 8 | A text (end); heading B | OK |
| 9 | B text (end); heading C | OK |
| 10 | C text (end); III; CONCLUSION; DATED and the signature block (two firms), kept with the last paragraph | OK. Long signature lines wrap in the 3.4 in column at the same words in both engines. |
| 11 | Certificate of service on its own page: wording, the party served, the method, the signature | OK |
