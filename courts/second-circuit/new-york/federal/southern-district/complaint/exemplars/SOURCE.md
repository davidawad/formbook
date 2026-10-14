# Exemplar source: nysd complaint

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-sacchi-26-cv-08973-complaint.pdf` (20 pages, text layer present, `pdftotext` reads it) |
| Case | *John Sacchi v. WeBull Financial LLC, et al.* (putative class action) |
| Court | United States District Court, Southern District of New York |
| Docket no. | 1:26-cv-08973 (page header: `Case 1:26-cv-08973 Document 1 Filed 10/11/26`) |
| Document | Document 1: Class Action Complaint, with a jury demand |
| Filer | Plaintiff's counsel, Stephen J. Simoni (Simoni Consumers Class Action Law Offices, c/o Jardim Meisner Salmon Sprague & Susser, P.C., Florham Park, NJ) |
| Date filed | October 11, 2026 (header; signature block dated Oct. 11, 2026) |
| URL fetched | https://storage.courtlistener.com/recap/gov.uscourts.nysd.674855/gov.uscourts.nysd.674855.1.0.pdf (RECAP copy) |
| Docket page | https://www.courtlistener.com/docket/74948864/1/sacchi-v-webull-financial-llc/ |
| How found | CourtListener RECAP search (`/api/rest/v4/search/?type=r&court=nysd`, filed after 2026-09-01, query "complaint"), then the document's `is_available` / `filepath_local` fields |
| Date fetched | 2026-10-14 |

## Why this one

- Real filed complaint in this court, public RECAP copy, text-based (native text layer, no OCR).
- Shows the SDNY complaint features the template needs: caption with the court name, the title of the action naming all parties, the file number, "CLASS ACTION COMPLAINT" and "JURY TRIAL DEMANDED" legends, headings (jurisdiction and venue, parties, factual allegations, class allegations, causes of action), numbered paragraphs, footnotes, a prayer for relief, a jury demand and a signature block.

## Limits of this exemplar (tier 2 caveat)

- One filer only. The tier-2 bar asks for two or three filers; not done. Other SDNY complaints found in the same search were not saved (most have no RECAP copy, `is_available: false`).
- The filing is unusually long and argumentative for a complaint (a class action with a Rule 23 section). Its formatting is conventional: caption, headings, double spacing. Only the form is used for tier-2 comparison, not its style.
- The complaint is not on pleading paper. The SDNY form has no numbered-line requirement; the rules are in `../README.md`.

## Searches tried (for the record)

- CourtListener RECAP, nysd, query "complaint", filed since 2026-09-01: the first page of results (20 dockets) was checked by document. One complaint had an available copy (Sacchi). Others checked and not available: Chouet'Press SAS v. Another Tomorrow (1:26-cv-08983), Barron v. Weill Cornell (1:26-cv-09000), and the other complaint entries on that page (`is_available: false`). Only the first page was checked, so the search is not exhaustive.
