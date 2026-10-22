# Gate 2 review: motion with memorandum, typst and docx engines (fb-595.68.24)

Reviewer: the porting agent of fb-595.68.24. Every page of both renders rendered at 60 dpi with pdftoppm and viewed
with the image reader side by side (typst | docx), after the last template change, against
`usage/FILED-EXAMPLE-motion-brief.pdf` pages 1, 2 and 5 and the court's rules (`../rules.md`).

## sample motion-brief

- `OUTPUT-motion-brief.typst.pdf` sha256: 769228565209dd831393bc1fa29982327c3ae4bd5bd9cba6a01ee4cc578c2d15
- `OUTPUT-motion-brief.docx` sha256: a7cd154cee552907d6b13261f3afb97bdaa4cea2203d65e18d866a6292cfe365
- `OUTPUT-motion-brief.docx.pdf` sha256: 59b2a1416aa17a345627c68c68392ce0ebb638347f87a80b0df36277c5fb7986
- Pages: 15 of 15 viewed on each engine. `check.sh --engine docx`: XENG-001..003 PASS (341/341 lines break alike).

| page | content (both engines) | result |
|---|---|---|
| 1 | Counsel single spaced on lines 1 to 6; the court title single spaced, centred, on lines 7 and 8; the caption row on lines 9 to 20 (the party box ruled at its right and foot), case number, bold title and "Hearing date: 8/31/2026", "Without Oral Argument" at right; footer "BATTELLE’S MOTION TO DISMISS - 1". | Pass |
| 2 | TABLE OF CONTENTS, a blank line, I to V with A. and B. indented, labels in their box, dot leaders, pages 3, 4, 8, 9, 9, 10, 14 (the pages the headings start on in both renders); B. wraps under its title. | Pass |
| 3 | I. INTRODUCTION; four paragraphs on the numbered lines. | Pass |
| 4 | Introduction ends; II. FACTUAL BACKGROUND on line 14. | Pass |
| 5 to 7 | Facts, paragraphs with a 0.5 in first-line indent. | Pass |
| 8 | Facts end, the bracketed note; III. PROCEDURAL BACKGROUND on line 8; line 20 empty (the next paragraph keeps two lines). | Pass |
| 9 | IV. AUTHORITY & ARGUMENT and A. Legal Standard on lines 7 and 8. | Pass |
| 10 | B. heading over two numbered lines (4 and 5). | Pass |
| 11 to 13 | Retaliation argument; citations in italics. | Pass |
| 14 | The bracketed note; V. CONCLUSION; a blank single line, then DATED and the signature block (firm, "By s/", the signers, e-mails, the attorneys' line) on lines 9 to 16. | Pass |
| 15 | CERTIFICATE OF SERVICE on its own page; the service paragraph, date and the legal assistant's line. | Pass |

Body text sits on the numbered lines on every page in both engines (`fb diff --engines`: 0.00 pt baseline difference
over 341 lines, line numbers and footer included).

Open or accepted (tier 2 or 3):
- OPEN (decision): the face. Liberation Mono (the exemplar's Courier New, audited) is kept; `../rules.md` WAED-FORM-002
  names only a proportional face, LCivR 10(d) as quoted in the README also allows a monospaced one. README gap 8.
- ACCEPTED: the docx pleading rules are page borders around the text area, not full-height rules from the page edge.
- ACCEPTED (tier 3): the docx contents' leader runs to the page number (Word's tab leader); typst's stops short of the
  page column. The exemplar's contents use roman page numbers and a single-spaced wrap; the template numbers pages
  sequentially (LCivR 10(a)(2)).
- OPEN (not verified): the .docx was not opened in Microsoft Word; LibreOffice only.
