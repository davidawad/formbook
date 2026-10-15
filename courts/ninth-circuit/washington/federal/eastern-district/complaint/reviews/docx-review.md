# Gate 2 review: complaint, docx engine (LibreOffice PDF)

Reviewer: the lead's docx sub-agent (every page rendered at 60 dpi with pdftoppm and viewed with the image reader, after the last template change). check.sh could not run on this folder (see README "## Engines"), so this record is the review.

## sample plenty-complaint docx

- `OUTPUT-plenty-complaint.docx` sha256: 787a2e9e9501da2bf7f7d895250f3e37bee1dbd480e2bc0abcf817cf664db736
- `OUTPUT-plenty-complaint.docx.pdf` sha256: 070edc11093cdd5e8c7c67fd9f682daee587605059d19b78eb2e467840addf03
- Pages: 9 of 9 viewed.

| page | content | result |
|---|---|---|
| 1 | Counsel lines 1 to 4; court title lines 5 to 7; caption lines 9 to 12 (right and bottom rules under the parties); case number and bold title at right; body from line 13; footer "PLAINTIFF’S CLASS ACTION COMPLAINT - 1". | Pass |
| 2 | Paragraphs 2 (end) to 8; JURISDICTION AND VENUE on line 9; text to line 21. | Pass |
| 3 | Paragraphs 8 (end) to 15; PARTIES (line 3) and FACTUAL ALLEGATIONS (line 7) centered. | Pass |
| 4 | Paragraphs 15 (end) to 19; the call list (i) to (xiii) runs inside paragraph 19 as text. | Pass |
| 5 | Paragraphs 19 (end) to 26. | Pass |
| 6 | Paragraphs 26 (end) to 28 (consumer quotations shortened, marked [...]); LEGAL STANDARD on line 15. | Pass |
| 7 | CLASS ACTION ALLEGATIONS on line 1; paragraphs 29 to 36. | Pass |
| 8 | Paragraphs 37 to 42; FIRST CAUSE OF ACTION and its two sub-heading lines on lines 11 to 13. | Pass |
| 9 | Paragraph 42 (end); RELIEF REQUESTED; 43 with items A to F; JURY DEMAND; 44; DATED and signature block on lines 14 to 18; nothing in the footer area. | Pass |

Page starts match the typst output (same first line on every page, 9 pages). Body text sits on the numbers (checked with pdftotext -bbox: body line 13 at the same y as number 13).

Open or accepted (tier 2 or 3):
- ACCEPTED: the pleading rules are page borders over the text area, not full-height rules from the page edge; one line of reason in README "## Engines".
- ACCEPTED: the caption rules are cell borders; a Word table may differ by a fraction of a point.
- OPEN (not verified): the file was not opened in Microsoft Word; LibreOffice only.
