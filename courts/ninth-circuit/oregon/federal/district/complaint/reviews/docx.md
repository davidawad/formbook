# ord complaint: Gate 2 review, docx engine

Reviewer: docx engine build (agent), 2026-10-15. Every page of the current LibreOffice PDF was rasterized at 60 dpi
(`pdftoppm -r 60`) and viewed, after the last re-render. The typst reference (8 pages) was rasterized and viewed for
comparison. `tools/check.sh` cannot run on this doc-type folder (see the Engines section of ../README.md), so this
file is the Gate 2 record for the docx engine.

## sample kliewer-complaint docx

- pdf: `samples/OUTPUT-kliewer-complaint.docx.pdf`, sha256 `139c2fa5473726a1c7393954190082d874f4d564221ab234fdf16caa476f94f5`, 9 pages, letter, EB Garamond embedded
- docx: `samples/OUTPUT-kliewer-complaint.docx`, sha256 `f71f90fa138db09a505f0b85aa75e0615ea48d485309850862a07eba69c0c455`
- pages reviewed: 9 of 9

| Page | Content | Finding |
|---|---|---|
| 1 | Counsel block upper left; court title; caption with the case number at the page center; title in capitals; DEMAND FOR JURY TRIAL; lead-in; Section I, paragraphs 1-2; footer "COMPLAINT - 1" | OK |
| 2 | Paragraphs 3-10; Section II heading | OK |
| 3 | Paragraphs 11-21; Section III; "Lead Plaintiff Richard Kliewer" and "The Calls" sub-headings | OK |
| 4 | Transcription note; the call table (first and last rows, with its rules); paragraphs 22-28 | ACCEPTED: the table spans the full text width with rules; the typst table is narrower with the same rules. Layout of a table is a tier-3 choice here. |
| 5 | Paragraphs 29-32; Section IV; classes (a)-(c) with hanging indents | OK |
| 6 | Paragraphs 33-41; Section V and "Allegations Applicable to All Counts" | OK |
| 7 | Paragraphs 42-51; "Count 1" heading (kept with paragraph 46) | OK |
| 8 | Paragraphs 52-56; Section VI; Section VII; prayer (a)-(g) | OK |
| 9 | Prayer (h); DATED and signature block | OPEN: the last prayer item and the signature are alone on the last page, because the docx runs one page longer than the typst output (8 pages; the text of the page breaks differs by a line or two per page). The last item is kept with the signature on purpose. Decide: tighten the layout or accept. |
