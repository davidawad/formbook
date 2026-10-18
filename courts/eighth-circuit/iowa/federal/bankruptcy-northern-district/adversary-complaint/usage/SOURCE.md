# Exemplars: adversary complaint, United States Bankruptcy Court, N.D. Iowa (ianb)

Fetched 2026-10-14. Both are public court records from CourtListener RECAP (the free archive of PACER documents), downloaded from `storage.courtlistener.com`. Both have a text layer (`pdftotext` reads them).

## 1. SAMPLE-ianb-adversary-complaint-hanrahancomstar2509028.pdf (6 pages)

| Item | Value |
|---|---|
| Case | *Hanrahan v. Comstar Supply, Inc.*, Adversary No. 25-09028, in *In re BDC Group, Inc.*, Chapter 7 Case No. 23-00484 |
| Court | United States Bankruptcy Court, N.D. Iowa |
| Document | Doc. 1, Complaint to Avoid Preferential Transfers |
| Filer | Renee Hanrahan, Chapter 7 Trustee (plaintiff) |
| Filer's counsel | Elizabeth M. Lally, AT0013010, Lally Legal Group LLC, Omaha, NE |
| Date filed | May 27, 2025 (ECF header: "Filed 05/27/25") |
| Fetched from | https://storage.courtlistener.com/recap/gov.uscourts.ianb.110632/gov.uscourts.ianb.110632.1.0.pdf |
| Found by | CourtListener search API, `type=rd`, `court=ianb`, query "Adversary case complaint": docket entry "Adversary case 25-09028. Complaint by Renee K. Hanrahan against Comstar Supply, Inc." |
| Notes | The signature block is on page 6 as visible text in the page image; `pdftotext` does not return it, so it was transcribed from the page image. The filing has no Adversary Cover Sheet attached (the cover sheet, Director's Form 1040, is a separate attachment on RECAP entry 1.1 in this docket, not part of this PDF). |

## 2. SAMPLE-ianb-adversary-complaint-childersroche2509079.pdf (4 pages)

| Item | Value |
|---|---|
| Case | *Childers v. Roche Diagnostics Corporation*, Adversary No. 25-09079, in *In re Mercy Hospital, Iowa City, Iowa, et al.*, Chapter 11 Case No. 23-00623 |
| Court | United States Bankruptcy Court, N.D. Iowa |
| Document | Doc. 1, Complaint to Avoid Preference |
| Filer | Dan R. Childers, Liquidation Trustee (plaintiff) |
| Filer's counsel | Abbe M. Stensland, AT0008831, Shuttleworth & Ingersoll, P.L.C., Cedar Rapids, IA |
| Date filed | July 25, 2025 (ECF header: "Filed 07/25/25") |
| Fetched from | https://storage.courtlistener.com/recap/gov.uscourts.ianb.110913/gov.uscourts.ianb.110913.1.0.pdf |
| Docket page | https://www.courtlistener.com/docket/70916762/1/childers-v-roche-diagnostics-corporation/ |
| Found by | CourtListener search API, `type=rd`, `court=ianb`, query "Complaint" (description "Complaint"): "Adversary case 25-09079. Complaint by Dan R. Childers against Roche Diagnostics Corporation" |
| Notes | Different filer from exemplar 1 (a liquidation trustee in a Chapter 11 plan, not a Chapter 7 trustee), different counsel, different debtor. The PDF's fonts are Helvetica and Courier for the caption and LiberationSans for the body text; the text layer reads fine. |

## Searches that did not produce a usable adversary complaint

- CourtListener `type=rd` searches for "Adversary complaint", "Complaint to avoid", "Complaint objecting to discharge" returned nothing for ianb.
- The RECAP complaint results for ianb are few: only the three complaints above (plus Hanrahan's 25-09032 *v. Ostafi Communications*, 6 pages, which has the same structure as exemplar 1 and was not saved, because the brief asks for one per filer).
- Adversary-proceeding dockets (`type=r`, `court=ianb`, "Adversary Proceeding") were listed, but most entries are docket-level records with no archived complaint PDF.
