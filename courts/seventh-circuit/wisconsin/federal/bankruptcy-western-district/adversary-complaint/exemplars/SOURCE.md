# Exemplar source: adversary complaint, W.D. Wis. Bankruptcy Court

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-wenzel-3-15-00105-adversary-complaint.pdf` |
| Court | United States Bankruptcy Court, Western District of Wisconsin |
| Case | *Wenzel v. Green Tree Servicing LLC* (In re Theodore Charles Wenzel, Bankr. No. 13-15445) |
| Adversary number | 3-15-00105 |
| Document | Doc 1, "Complaint Determining the Validity of a Claimed Lien under Rule 7001(2)" |
| Filer | Theodore Charles Wenzel, debtor/plaintiff, by Roger G. Merry (Merry Law Offices, Monroe, WI) |
| Date filed | 2015-07-17 (ECF header: "Filed 07/17/15") |
| Pages | 3 |
| Fetched from | https://storage.courtlistener.com/recap/gov.uscourts.wiwb.165451/gov.uscourts.wiwb.165451.1.0.pdf |
| Docket page | https://www.courtlistener.com/docket/5205577/wenzel-v-green-tree-servicing-llc/ (entry 1) |
| Date fetched | 2026-10-14 |
| Provenance | CourtListener RECAP archive (public court record, ECF Doc 1). Text layer present (pdffonts: Times-Roman, Times-Bold, Helvetica; pdftotext reads the body). |

## Why this one

Found by searching CourtListener's W.D. Wis. adversary filings (`type=r`, `court=wiwb`) for "Complaint filed by Plaintiff" and "adversary" and filtering for RECAP PDFs with a text layer. It is a real, filed bankruptcy adversary complaint in this court, and its title cites Rule 7001(2), so it is the right doc type. It is from 2015: it predates the December 1, 2016 amendment to Rule 7008(a) (consent to entry of final orders). See `../README.md`.

## Searches tried (2026-10-14)

- CourtListener search API, `court=wiwb`, RECAP documents: "adversary complaint", "Complaint filed by Plaintiff" + adversary, "Adversary case" + "Complaint filed by", "Motion to Dismiss Adversary Proceeding", "Brief in Support", "Memorandum in support".
- Rejected: Jung v. IRS (1-18-00052, doc 1), the RECAP file would not open as a PDF; Johnson adversary (1-23-00041) docs 11 and 14 and Kasdorf v. Bank of Lake Mills (3-08-00111, doc 1) — Kasdorf is a scanned PDF with no text layer, which the eval loop does not accept as tier-2 evidence.
- Web search (WIWB site, "adversary complaint" pdf): only court forms (AO 187) and opinions, no filed complaints.
