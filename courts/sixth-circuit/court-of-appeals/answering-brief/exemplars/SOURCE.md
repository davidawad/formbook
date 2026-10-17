# Exemplars: ca6 answering-brief

| File | Case | Docket | Filer | Date filed | Fetched |
|---|---|---|---|---|---|
| `FILED-EXAMPLE-bruneau-23-1761-answering-brief.pdf` | *Joe Bruneau, et al. v. Michigan Department of Environment, Great Lakes and Energy, et al.* | 6th Cir. No. 23-1761 (E.D. Mich.) | Defendants-Appellees Midland County, MI and Gladwin County, MI (counsel: Cummings, McClorey, Davis & Acho, P.L.C.) | 2024-01-31 (ECF Doc. 40, "Brief of Defendants-Appellees Midland County, MI and Gladwin County, MI on Appeal") | 2026-10-14 |

- PDF fetched from: https://courthousenews.com/wp-content/uploads/2024/06/sixth-circuit-michigan-dam-state-brief.pdf
- Found via: web search for a Sixth Circuit appellee brief with a table of authorities. The CourtListener RECAP hits for this court in the search were clerk's briefing letters, not briefs.
- Public court record: the PDF carries the ECF header on every page ("Case: 23-1761 Document: 40 Filed: 01/31/2024 Page: n"), so it is a filed brief copied from the court's docket. The copy is a 56-page scan with an OCR text layer (`pdftotext` yields the text; fonts are Times New Roman, with Arial and Helvetica in places).
- Pages: 56. The brief proper is printed pp. i-44 (PDF pp. 4-54), followed by the record designation (printed p. 45, PDF pp. 55-56). PDF pp. 2-3 are the clerk's disclosure form (Form 6CA-1, from an earlier docket entry, Doc. 12) attached to the front.
- Source-level errors seen in the exemplar (transcribed as filed except where marked in `samples/INPUT-bruneau-answering-brief.md`):
  - The signature block reads "Dated: January 31, 2023"; the certificate of service and the ECF stamp read 2024. The sample uses 2024.
  - The body cites the Krieger docket as "No. 359895" once (p. 27); the other cites say 359859. The sample uses 359859.
  - The Table of Authorities lists *Baird* at "346 F.3d 1346 (Fed. Cir. 2003)"; the body cites "5 Ct. Cl. 324, 329 (1984)". The sample uses the body cite.
  - OCR damage in the text layer (e.g. "56 F.4*111088", "sought summary in the district court"). The sample uses the printed text.

## Second filer

Not saved in this box. A second Sixth Circuit answering brief from a different filer is needed for the tier-2 comparison (see `README.md`, Known gaps).

## Additional filer

- File: `FILED-EXAMPLE-jb-k-cabinet-21-5074-answering-brief.pdf` (71 pages, text layer)
- Case: *J.B.-K. et al. v. Secretary of the Kentucky Cabinet for Health and Family Services et al.*, No. 21-5074
- Document: Brief of Defendants-Appellees, Document 24
- Filer: Secretary of the Kentucky Cabinet for Health and Family Services, Commissioner of the Kentucky Department for Community Based Services, and Elizabeth Caywood, by counsel for the Commonwealth
- Date filed: 2021-06-23 (ECF header)
- URL: https://www.courthousenews.com/wp-content/uploads/2021/10/ky-state-brief.pdf
- Date retrieved: 2026-10-17
- SHA-256: `58b450a55214ce841b31682b236b96f3e051ceec3fce2c1a0026abe748ac231c`

## Selected replacement

The Bruneau PDF is a scanned filing with OCR. The saved *JB-K Cabinet* answering brief is a same-court, same-document-type public filing with an extractable text layer and is the selected replacement. It uses Century Schoolbook rather than Times New Roman, but remains the best available typed brief from a different filer in this folder. Keep the Bruneau sample paired with its source unless the sample is rebuilt around the replacement.
