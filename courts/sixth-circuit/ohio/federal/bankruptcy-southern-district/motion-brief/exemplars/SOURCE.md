# Exemplar source: motion with memorandum in support, Bankr. S.D. Ohio

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-actual-brewing-2-19-bk-50813-motion-brief.pdf` |
| URL fetched | https://storage.courtlistener.com/recap/gov.uscourts.ohsb.777137/gov.uscourts.ohsb.777137.41.0.pdf |
| Docket page | https://www.courtlistener.com/docket/14554070/actual-brewing-company-llc/ (CourtListener docket 14554070) |
| Case | *In re Actual Brewing Company, LLC*, Case No. 19-50813 (Chapter 11), Judge Caldwell |
| Court | United States Bankruptcy Court, S.D. Ohio, Eastern Division |
| Document | Doc 41, "Motion of United States Trustee to Convert or Dismiss Case and Memorandum in Support", 9 pages (pages 1 to 7 are the motion and the memorandum; pages 8 and 9 are the mailing matrix, not transcribed) |
| Filer | Office of the United States Trustee, Region 9 (Matthew J. McDonald III, attorney for the U.S. Trustee) |
| Date filed | 2019-03-08 (ECF stamp 03/08/19 17:29:15) |
| Date fetched | 2026-10-14 |
| Text layer | Yes: `pdftotext` reads the whole document (embedded Times New Roman, `TimesNewRomanPSMT` and `-BoldMT`) |

## How it was found

- CourtListener search API, `type=r`, `court=ohsb`, query `"motion to dismiss" "memorandum in support"`. The result list carried a RECAP document with `is_available: true`, `page_count: 9` and a `filepath_local`. Other S.D. Ohio "with Memorandum in Support" motions in the results were either not in storage or were short (5 pages, 2023, 614 Ministries), and the 2023 filing has no mailing matrix.
- A debtor-side motion with a memorandum, filed after 2024, was wanted as a second filer for tier 2. The next CourtListener search was rate-limited (5 requests per minute) and did not return a usable result. See `../README.md`, known gaps.
