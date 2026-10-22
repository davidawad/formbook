# Gate 2 review: complaint, typst and docx engines (fb-595.68.24)

Reviewer: the porting agent of fb-595.68.24. Every page of both renders rendered at 60 dpi with pdftoppm and viewed
with the image reader side by side (typst | docx), after the last template change, against
`usage/FILED-EXAMPLE-complaint.pdf` pages 1 and 2 and the court's rules (`../rules.md`).

## sample complaint

- `OUTPUT-complaint.typst.pdf` sha256: 523871c8530e3cf885aa8bda261baebf7069d6f0d4a89ce02c74fa7b74ce42bf
- `OUTPUT-complaint.docx` sha256: 35d934dabcae3422a7634fefbe6f28588076c9c5df6be8682af3f1365e43c543
- `OUTPUT-complaint.docx.pdf` sha256: 1fd356a1a6e4f65dcb2c00f33c23db0b024e5abf83e0e755869be876ae5b8a52
- Pages: 10 of 10 viewed on each engine. `check.sh --engine docx`: XENG-001..003 PASS (219/219 lines break alike).

| page | content (both engines) | result |
|---|---|---|
| 1 | Counsel single spaced on lines 1 to 4; court title on lines 5 to 7, centred; blank line 8; caption on lines 9 to 12 (the party box ruled at its right and foot, the rule on a numbered line), case number, bold title (two lines) and DEMAND FOR JURY TRIAL at right; paragraph 1 from line 13; INTRODUCTION on line 16; footer "PLAINTIFF’S CLASS ACTION COMPLAINT - 1" below line 20. | Pass |
| 2 | Paragraphs 3 to 8; JURISDICTION AND VENUE on line 10. | Pass |
| 3 | Paragraphs 8 (end) to 13; PARTIES (line 6) and FACTUAL ALLEGATIONS (line 10). | Pass |
| 4 | Paragraphs 13 (end) to 18. | Pass |
| 5 | Paragraphs 19 to 22; the call list (i) to (xiii) runs inside paragraph 19 as text; line 20 empty (paragraph 23 keeps its two lines together). | Pass |
| 6 | Paragraphs 23 to 26 (consumer quotations shortened, marked [...]). | Pass |
| 7 | Paragraphs 26 (end) to 30; LEGAL STANDARD (line 6), CLASS ACTION ALLEGATIONS (line 12); line 20 empty (widow control). | Pass |
| 8 | Paragraphs 30 (end) to 37; line 20 empty. | Pass |
| 9 | Paragraphs 38 to 42; FIRST CAUSE OF ACTION and its two sub-headings on lines 9 to 11. | Pass |
| 10 | RELIEF REQUESTED; paragraph 43 with items A to F (D and F wrap under their text); JURY DEMAND; paragraph 44; a blank single line, then DATED and the signature block (lines 15 to 19); nothing in the footer area. | Pass |

Body text sits on the numbered lines on every page in both engines (`fb diff --engines`: 0.00 pt baseline difference
over 219 lines, line numbers and footer included).

Open or accepted (tier 2 or 3):
- ACCEPTED: the docx pleading rules are page borders around the text area, not full-height rules from the page edge
  as typst draws them (Word has no full-height page rule without a drawing).
- ACCEPTED (tier 3): the exemplar sets the court title bold and single spaced, the headings underlined, and runs 21
  lines a page; the template keeps 20 numbered lines inside the 1 in bottom margin (the rule fixes no count).
- OPEN (not verified): the .docx was not opened in Microsoft Word; LibreOffice only.
