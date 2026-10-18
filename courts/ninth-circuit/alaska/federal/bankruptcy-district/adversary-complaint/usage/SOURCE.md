# Exemplar source

| Field | Value |
|---|---|
| File | `SAMPLE-akb-adversary-complaint-battleyfurie1890016.pdf` |
| Court | United States Bankruptcy Court, District of Alaska (`akb`) |
| Case | *Kenneth W. Battley, Trustee v. Furie Operating Alaska, LLC and Cornucopia Oil & Gas Company LLC*, Adv. Proc. No. 18-90016 (main case *In re Aurora Gas LLC*, No. 16-00130) |
| Document | Complaint for Avoidance and Recovery of Payments (Bankruptcy Code §§ 549 and 550), docket entry 1, 3 pages |
| Filer | Erik LeRoy, P.C., attorney for Chapter 7 Trustee Kenneth W. Battley |
| Date filed | May 14, 2018 (ECF header: "Filed 05/14/18") |
| Fetched from | https://www.courtlistener.com/docket/6674392/1/battley-v-furie-operating-alaska-llc/ (docket entry page: "Complaint (Used in Open AP Case) – #1") |
| PDF | https://storage.courtlistener.com/recap/gov.uscourts.akb.31652/gov.uscourts.akb.31652.1.0_2.pdf |
| Date fetched | 2026-10-14 |
| Provenance | RECAP upload on CourtListener; a public court record. Text layer present (embedded Times New Roman, read with `pdftotext`). |

Notes on the file:

- The filed caption reads "Adv Case No. 18-900" (truncated in the filing). The adversary number 18-90016 comes from the ECF header and the CourtListener docket page.
- The ECF header line ("Case 18-90016 Doc 1 Filed 05/14/18 ... Page 1 of 3") is added by the court's system and is not transcribed; the template does not reproduce it.
- The filing has no statement of consent to entry of final orders (FRBP 7008(a)), no e-mail address for counsel (LBR 9004-1(c)(2)(A), 12/2024), and no summons. See the README's gaps.

## Searches (to show what was tried)

- court's own site (akb.uscourts.gov): forms (B2500A summons, B1040 cover sheet), adversary case lists (2025 and 2026 reports), opinions in adversary proceedings (2009, 2012). No complaint PDFs.
- CourtListener search by court `akb` (HTML search via curl): dockets with complaints listed, e.g. Battley v. Furie (18-90016, complaint Doc 1, RECAP PDF available), Gebhardt v. Aegis Capital (16-90020), Cook Inlet Energy (17-90028, 17-90059). Battley was the only complaint whose RECAP PDF was reachable in this run; the others were throttled (HTTP 202) or had no free PDF.
- CourtListener API: requires authentication (HTTP 401), not used.
- govinfo.gov, Justia dockets, search-engine queries for "gov.uscourts.akb": no akb complaint PDFs found.
