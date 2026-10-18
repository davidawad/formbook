# Exemplar source: nysd complaint

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-complaint.pdf` (20 pages, text layer present, `pdftotext` reads it) |
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

## 2. SEC v. Asudani (added 2026-10-17)

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-complaint-2.pdf` (12 pages, letter, native text layer from Word via Acrobat PDFMaker, `pdftotext` reads it; not scanned) |
| Case | *Securities and Exchange Commission v. Mukesh Asudani* |
| Court | United States District Court, Southern District of New York |
| Docket no. | 1:26-cv-08626 (page header: `Case 1:26-cv-08626 Document 1 Filed 09/30/26`; caption reads "26 Civ. 8626") |
| Document | Document 1: Complaint, with "JURY TRIAL DEMANDED" in the caption and a closing "JURY DEMAND" section |
| Filer | Plaintiff Securities and Exchange Commission, staff counsel of the New York Regional Office (Chevon Walker, Joseph G. Sansone, Assunta Vivolo, Joshua R. Geller). Different party and counsel from entry 1 (Sacchi / Simoni). |
| Date filed | September 30, 2026 (header; signature block dated September 30, 2026) |
| URL fetched | https://www.sec.gov/files/litigation/complaints/2026/comp26662.pdf (linked as "SEC Complaint" from Litigation Release LR-26662, Sept. 30, 2026, on https://www.sec.gov/enforcement-litigation/litigation-releases) |
| How found | SEC litigation releases index; each 2026 complaint PDF there was checked with `pdftotext` for "SOUTHERN DISTRICT OF NEW YORK" and an ECF file stamp. The CourtListener search API was throttled for the day on 2026-10-17 (other RECAP routes return 401/403 anonymously). |
| Fonts (`pdffonts`) | Times New Roman (regular, bold, italic) for the text; Liberation Sans is the ECF stamp |
| Date retrieved | 2026-10-17 |
| sha256 | `3092a06ee8a12d7025e47f8625ee7abe4611487c57bc7444ee9cec119f902c67` |

Form notes (tier 2): counsel block at the upper left of page 1 above the court name; caption with the parties at left and "COMPLAINT", the civil number and "JURY TRIAL DEMANDED" at right; "-against-" between the sides; centered caps section headings (SUMMARY, ...); numbered paragraphs with a first-line indent; prayer items numbered with centered roman numerals; page number centered at the foot; one signature block ("/s" name) after the jury demand.
