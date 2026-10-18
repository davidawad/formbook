# Exemplar source

- File: `SAMPLE-mieb-adversary-complaint-griffin2604189.pdf` (7 pages, text layer present, `pdftotext` reads it)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.mieb.1033239/gov.uscourts.mieb.1033239.1.0.pdf (CourtListener RECAP; docket page https://www.courtlistener.com/docket/73485225/1/griffin-v-national-debt-relief-llc/)
- Court: United States Bankruptcy Court, Eastern District of Michigan, Southern Division at Detroit
- Case: *Deborah L. Griffin v. National Debt Relief LLC*, Adversary Proceeding No. 26-04189-mar (main case *In re Deborah L. Griffin*, No. 25-47309-MAR, Chapter 13, Hon. Mark A. Randon)
- Document: Adversary Complaint to Avoid Fraudulent Transfers, for Damages Pursuant to the Michigan Debt Management Act, and for Damages under the Michigan Consumer Protection Act (ECF Doc 1)
- Filer: Plaintiff Deborah L. Griffin (Chapter 13 debtor), by counsel Firebaugh & Andrews, P.L.L.C. (Samuel G. Firebaugh, P-34276)
- Date filed: June 15, 2026 (stamped "Filed 06/15/26" on every page; signature block "dated: June 15, 2026")
- Date fetched: 2026-10-14
- Public court record (RECAP). Used only as a visual and structural reference.

## Why this one

Searched CourtListener RECAP (`type=r`, `court=mieb`, query "complaint adversary") for E.D. Mich. bankruptcy adversary complaints. The candidates that had a text layer were: Griffin (this one, 7 pp.), Leland House LP v. Kraemer Design Group (26-04015, 8 pp.), Bullock v. Darana Hybrid (26-04029, 8 pp.), and United States v. Kaplan (25-04239, 7 pp.; a government filer). Griffin is the only one in the list filed by a private debtor-plaintiff with the full set of adversary-complaint parts: caption with the main case block, jurisdiction and venue with the FRBP 7008 core statement and the consent to final orders, parties, general allegations, numbered counts with WHEREFORE clauses, and the signature block. It is a single filer; a second filer was not collected (see `../README.md`, known gaps).

## Searches tried

- CourtListener API, RECAP search, `court=mieb`, adversary complaint terms: returned the candidates above and several related dockets (Perez/Jayakumar, Stockman/Daoud, Clark, Kaplan).
- WebSearch, E.D. Mich. bankruptcy adversary complaint PDF: returned court guidance pages and opinions, no filed complaint.
- Not retrieved: CourtListener docket pages (HTML) were not needed; the RECAP PDFs were fetched directly.
