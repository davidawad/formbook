# Gate 2 review: motion with memorandum, docx engine (LibreOffice PDF)

Reviewer: the lead's docx sub-agent (every page rendered at 60 dpi with pdftoppm and viewed with the image reader, after the last template change). check.sh could not run on this folder (see README "## Engines"), so this record is the review.

## sample hartsock-motion-to-dismiss docx

- `OUTPUT-hartsock-motion-to-dismiss.docx` sha256: aedd97801a2dac79086f1dc94f422308dda7bce2eb9b0d739188d2cd092a81be
- `OUTPUT-hartsock-motion-to-dismiss.docx.pdf` sha256: d795d35d28307293d1fefa71bb61c4fec4c9edebb889f3c8dfe2be4e908a0e53
- Pages: 11 of 11 viewed.

| page | content | result |
|---|---|---|
| 1 | Counsel lines 1 to 6; court title lines 7 to 9; caption from line 11 (right and bottom rules under the parties); case number, bold title, "Hearing date: 8/31/2026", "Without Oral Argument" at right; footer "BATTELLE’S MOTION TO DISMISS - 1". | Pass |
| 2 | TABLE OF CONTENTS on line 1; entries I to V and CERTIFICATE OF SERVICE, dot leaders, pages 3, 4, 6, 7, 7, 7, 10, 11 (checked against the body pages). | Pass |
| 3 | I. INTRODUCTION (line 1), paragraphs to line 21. | Pass |
| 4 | II. FACTUAL BACKGROUND; paragraphs to line 21 ("Id., ¶3.9." at the foot). | Pass |
| 5 | Facts June 12 to June 14, 2024; ends on line 20. | Pass |
| 6 | June 24, 2024 facts; bracketed note that July to November 2024 is not transcribed; III. PROCEDURAL BACKGROUND on line 9. | Pass |
| 7 | IV. AUTHORITY & ARGUMENT; A. Legal Standard; B. heading on line 12; first retaliation paragraph. | Pass |
| 8 | Retaliation paragraphs (protected activity, adverse action, causation). | Pass |
| 9 | "Shifted gears" and temporal-proximity paragraphs; bracketed note that Sections IV.C to IV.E are not transcribed. | Pass |
| 10 | V. CONCLUSION; "DATED this 6th day of July, 2026" with "Respectfully submitted," and the firm; "By s/" signer and lines on the grid. | Pass |
| 11 | CERTIFICATE OF SERVICE on its own page; service paragraph; date; legal assistant line. | Pass |

Page starts match the typst output on all 11 pages. The TOC page numbers match the body pages (checked by hand against the pages above).

Open or accepted (tier 2 or 3):
- ACCEPTED: the TOC is a Word TOC field with cached entries; its page numbers are the LibreOffice pagination. Word may paginate differently; update the field there (F9) if the pages move.
- ACCEPTED: the pleading rules are page borders over the text area, not full-height rules from the page edge.
- ACCEPTED: table of authorities not generated (as the typst output; sample gap 2).
- OPEN (not verified): the file was not opened in Microsoft Word; LibreOffice only.
