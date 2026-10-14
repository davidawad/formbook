# Exemplar source

- File: `FILED-EXAMPLE-joye-25-80012-adversary-complaint.pdf` (9 pages, text layer present; `pdftotext` reads it; fonts are Times, embedded by Word/Acrobat)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.scb.316746/gov.uscourts.scb.316746.1.0_2.pdf (CourtListener RECAP; docket page https://www.courtlistener.com/docket/69703871/)
- Court: United States Bankruptcy Court, District of South Carolina
- Case: *Janet B. Haigler, Chapter 7 Trustee for Joye Roofing, LLC v. Derek Joye, by and through his personal representative Donna H. Joye, and Donna H. Joye*
- Bankruptcy case: Chapter 7, No. 24-03393-eg (debtor Joye Roofing, LLC)
- Adversary number: left blank on the filed copy (`Adv. Pro. No.______`); the clerk assigns it. The filed copy shows `25-80012-eg` in the ECF header.
- Document: Complaint (Doc 1), 9 pages
- Filer: Plaintiff Janet B. Haigler, Chapter 7 Trustee, by counsel Richard R. Gleissner, Gleissner Law Firm, L.L.C. (Columbia, SC)
- Date filed: 2025-03-04 (ECF header: "Filed 03/04/25"; signature block "Dated: March 4, 2025")
- Date fetched: 2026-10-14
- Public court record (RECAP). Used only as a structural and visual reference. The ECF header line at the top of each filed page is added by CM/ECF and is not reproduced by the template.

## Second filer (not saved; candidate for a tier-2 comparison)

- *Fort, Trustee v. Kauffman Precast, LLC*, Adv. No. 18-80024-hb (Bankr. D.S.C.), Complaint (Doc 1), 6 pages, filed 2018-04-13 by counsel Roe Cassidy Coates & Price, P.A. (Joshua J. Hudson). Source: https://storage.courtlistener.com/recap/gov.uscourts.scb.282365/gov.uscourts.scb.282365.1.0_7.pdf (docket https://www.courtlistener.com/docket/6518626/). Its caption uses a `)` column, not the bordered caption of the exemplar above; it was checked and found text-based, not saved.

## Searches tried

- WebSearch: "District of South Carolina" bankruptcy adversary complaint; results were orders and docket pages, not the complaint PDF.
- CourtListener search API (`/api/rest/v4/search/?type=r&court=scb`) with queries for "Complaint by ... Core Proceeding", "Adversary Proceeding", and trustee complaints. This returned RECAP PDFs; the Joye complaint was chosen as the newest trustee complaint in the results with a text layer and a clean caption.
