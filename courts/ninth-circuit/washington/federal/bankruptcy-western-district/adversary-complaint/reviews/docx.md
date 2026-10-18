# Gate 2 review, docx (LibreOffice PDF), harbor-custom-complaint

Reviewer: the docx engine agent, 2026-10-15. Method: `pdftoppm -r 60`, every page viewed. Comparison: the typst render of the same sample (`/work/artifacts/wawb/adversary-complaint/typst-harbor-custom-complaint.pdf`), pages 1, 8 and 9 viewed.

## sample harbor-custom-complaint docx

- PDF: `usage/OUTPUT-harbor-custom-complaint.docx.pdf`, sha256 `d1fda9b2d935dee8b9c676b826c7e53751367f1be202d7c40c26013801c6dae7`
- DOCX: `usage/OUTPUT-harbor-custom-complaint.docx`, sha256 `fdb35d92ac8bc2d784a1aa234387bbf57bcf5b9e137d35f82694dbf9094d026e`

| page | verdict | note |
|---|---|---|
| 1 | Pass | counsel top left, judge and chapter top right, court title, caption closed by the rules, adversary number and title at right, bottom notation |
| 2 | Pass | lead-in and paragraphs 1 to 9 on the numbered lines |
| 3 | Pass | paragraphs 10 to 16; FACTUAL ALLEGATIONS and the Debtors sub-heading |
| 4 | Pass | paragraphs 17 to 24; Loans by Sound Equity and the italic sub-heading kept with paragraph 21 |
| 5 | Pass | paragraphs 25 to 30; blank lines 26 to 28 at the foot because the next heading moves with its paragraph (as the typst render) |
| 6 | Pass | CLAIMS FOR RELIEF, Count I and II headings with their statutory lines, paragraphs 31 to 39 |
| 7 | Pass | Count III to V; paragraphs 40 to 48 |
| 8 | Pass | paragraph 49, PRAYER FOR RELIEF, lettered items A. to J. with the text at 0.9 in |
| 9 | Pass | date and the two firm signature blocks, kept whole |

Open: none in tier 1. Tier 2 pagination differs from typst (LibreOffice line breaks); recorded in the README Engines section, not a defect.
