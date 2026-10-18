# Exemplar source: adversary complaint, Bankr. S.D. Ohio

| Field | Value |
|---|---|
| File | `SAMPLE-ohsb-adversary-complaint-caudill225ap02053.pdf` |
| URL fetched | https://storage.courtlistener.com/recap/gov.uscourts.ohsb.851047/gov.uscourts.ohsb.851047.1.0.pdf |
| Docket page | https://www.courtlistener.com/docket/71381132/1/caudill-v-pc-infinity-llc/ (CourtListener docket 71381132) |
| Case | *Caudill v. PC Infinity LLC* (In re Cusitech, LLC), Case No. 23-53233 (Chapter 7), Adv. Pro. No. 2:25-ap-02053 |
| Court | United States Bankruptcy Court, S.D. Ohio, Eastern Division (Judge Tiffany Strelow Cobb) |
| Document | Doc 1, "Complaint to (1) Avoid Preferential Transfers; (2) Recover Avoided Transfers; and (3) Disallow Claims", 10 pages with Exhibit A |
| Filer | Christal L. Caudill, chapter 7 trustee of the Cusitech, LLC estate (plaintiff). Counsel of record on the signature block: Allen Stovall Neuman & Ashton LLP (Whittaker, Stovall, Coutinho, Rebholz) |
| Date filed | 2025-09-18 (ECF stamp 09/18/25 13:43:29) |
| Date fetched | 2026-10-14 |
| Text layer | Yes: `pdftotext` reads the whole document (fonts: embedded Liberation Sans and Helvetica) |

## How it was found

- CourtListener search API, `type=r`, `court=ohsb`, query `"adversary proceeding" "complaint"`, ordered by score. The result list carried the RECAP document with `is_available: true` and a `filepath_local`.
- The other adversary complaints in the same results (e.g., *Joe's Drain Cleaning, LLC v. BayFirst National Bank*, 2:24-ap-02046) had no RECAP PDF in storage (`is_available: false`), so they could not be saved.
- A second, tier-2 filer was not saved: the CourtListener API then rate-limited the search (5 requests per minute) and no second adversary complaint with a PDF was retrieved. See `../README.md`, known gaps.
