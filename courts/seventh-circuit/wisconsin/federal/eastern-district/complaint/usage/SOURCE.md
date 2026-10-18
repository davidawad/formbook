# Exemplar sources: E.D. Wisconsin, complaint

Found through the CourtListener search API (`https://www.courtlistener.com/api/rest/v4/search/?type=r&court=wied`), RECAP documents, `type=r`, filed 2026-10-12 and 2026-10-13. Both are attorney-filed complaints (the RECAP "Complaint" entry, document 1). Fetched 2026-10-14 from the RECAP storage URLs below. Public court records; no sealed or redacted material.

| File | Case | Docket | Filer | Date filed | Fetched from | Pages |
|---|---|---|---|---|---|---|
| `SAMPLE-wied-complaint-taylor226cv01900.pdf` | Taylor v. City of Racine, et al. | 2:26-cv-01900 (E.D. Wis.), CourtListener docket 74952583 | William Taylor, by McDonald Law Firm, LLC (Shannon D. McDonald) | 2026-10-13 | https://storage.courtlistener.com/recap/gov.uscourts.wied.118725/gov.uscourts.wied.118725.1.0.pdf | 13 |
| `SAMPLE-wied-complaint-testolin226cv01895.pdf` | Testolin v. Bank of America, N.A., et al. | 2:26-cv-01895 (E.D. Wis.) | Catherine Testolin, by McCarthy Law, PLC (Joseph Panvini) | 2026-10-12 | https://storage.courtlistener.com/recap/gov.uscourts.wied.118720/gov.uscourts.wied.118720.1.0.pdf | 9 |

## Use

- The overlay (`usage/OVERLAY-taylor-complaint.pdf`) compares against the first file in this folder (Taylor, alphabetically first).
- Taylor is the layout reference: plain double-spaced 12-point serif, no line numbers, numbered paragraphs. Testolin is the second filer. It uses pleading paper (numbered lines 1 to 28, Bookman Old Style). E.D. Wis. General L.R. 5(a) does not require line numbers, so Testolin is treated as an accepted variant (see `../README.md`), not a target.
- The Taylor sample (`usage/INPUT-wied-complaint-taylor.md`) transcribes the whole filing from its text layer, with exhibit references kept as filed. Typos in the filing (for example "Talor", "Mobeck") are kept as filed.

## Why these two

Searched: CourtListener RECAP, `court=wied`, queries "complaint" and "motion to dismiss", result pages sorted by date filed (2026-10-13 back to 2026-07). Complaints downloaded and checked for a text layer: Taylor (13 pp.), Testolin (9 pp.). Also listed with a RECAP PDF but not downloaded: Mill Metro LLC v. United States (2:26-cv-01901, 18 pp.), Jackson v. Strzyzewski (1:26-cv-01898, 16 pp.). Taylor and Testolin were chosen because they are counsel-filed complaints with a jury demand and a prayer, from two different firms.
