# Exemplars: answering-brief (ca8)

One filed exemplar, a public court record (RECAP copy of a PACER document).

| File | Case | Docket | Filer | Document | Date filed | URL | Date fetched |
|---|---|---|---|---|---|---|---|
| `SAMPLE-ca8-answering-brief-banksvcostar253320.pdf` | *Desmond Banks v. CoStar Realty Information, Inc.* (8th Cir.), on appeal from E.D. Mo. No. 4:25-cv-00564-CMS | 25-3320 | CoStar Realty Information, Inc., defendant-appellee (counsel: Baker & Hostetler LLP) | Response Brief for Appellee CoStar Realty Information, Inc., 58 pages (certificate of compliance: 11,620 words; certificate dated April 29, 2026) | 2026-04-30 (CourtListener docket entry 04/30/2026 02:16 PM, "w/service 04/30/2026") | https://storage.courtlistener.com/recap/gov.uscourts.ca8.113264/gov.uscourts.ca8.113264.00805509246.0.pdf | 2026-10-14 |

How it was found: CourtListener's RECAP search API, `https://www.courtlistener.com/api/rest/v4/search/?type=r&court=ca8&q=%22brief+for+appellee%22&order_by=dateFiled+desc`, filtered to "BRIEF FILED - APPELLEE BRIEF" entries. The docket entry text reads "Length: 11,620 words". The PDF has embedded text (`pdffonts`: TrueType, `pdftotext` yields the text).

Other candidates seen but not saved (one exemplar per doc type is kept, so the overlay has an unambiguous reference): *Burnett v. Spring Way Center, LLC*, No. 24-2168 (filed by RE/MAX and Anywhere, Faegre Drinker; https://storage.courtlistener.com/recap/gov.uscourts.ca8.109127/gov.uscourts.ca8.109127.805154935.0.pdf).

Only one filer's brief is on file, so tier 2 (professional convention) is judged against this one exemplar only. A second filer's appellee brief is needed to tell convention from one filer's style (see README.md, "Known gaps").

## Second filer

| Field | Value |
|---|---|
| File | `SAMPLE-ca8-answering-brief-anywhereremax242143.pdf` (67 pages) |
| Case / docket | *Rhonda Burnett, et al. v. National Association of Realtors, et al.*, consolidated Nos. 24-2143, 24-2168, 24-2391 |
| Document | Anywhere and RE/MAX's Response Brief |
| Filer | Anywhere Real Estate Inc. and RE/MAX, LLC, by Aaron D. Van Oort, Faegre Drinker Biddle & Reath LLP, et al. |
| Date filed | 2024-12-11 (certificate of service states it was filed in CM/ECF that date) |
| URL | https://storage.courtlistener.com/recap/gov.uscourts.ca8.109127/gov.uscourts.ca8.109127.805154935.0.pdf |
| Date retrieved | 2026-10-17 |
| SHA-256 | `404061f6ad2d773feb4640f7e4292ae1314fa72f5384031913c3f51360422133` |
| Public filing | Yes, CourtListener RECAP; `pdftotext` confirms text on the 67-page PDF. |

## Third filer

| Field | Value |
|---|---|
| File | `SAMPLE-ca8-answering-brief-minnesotasimon262679.pdf` (72 pages) |
| Case / docket | *United States of America v. Steve Simon et al.*, No. 26-2679 |
| Document | Brief for Defendants-Appellees Steve Simon and Minnesota |
| Filer | Steve Simon and the State of Minnesota, by counsel for the Minnesota Attorney General |
| Date filed | 2026-09-15 (CourtListener RECAP docket entry) |
| URL | https://storage.courtlistener.com/recap/gov.uscourts.ca8.115359/gov.uscourts.ca8.115359.00805610678.0.pdf |
| Date retrieved | 2026-10-17 |
| SHA-256 | `2e07246e63a68b33f7d25740a51403ebe9932f74f222249baa60827e2682ac2e` |
| Public filing | Yes, CourtListener RECAP; `pdftotext` confirms text on the 72-page PDF. |
