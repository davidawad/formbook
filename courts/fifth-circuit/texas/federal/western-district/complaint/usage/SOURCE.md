# Exemplar source

Court: United States District Court, Western District of Texas (txwd). Doc type: complaint.

## 1. `FILED-EXAMPLE-complaint.pdf` (used for the sample)

- Case: *Eli Lilly and Company v. Astra LLC d/b/a Astra Peptides, et al.*, No. 5:26-cv-05147-FB (San Antonio Division)
- Document: First Amended Complaint, with jury trial demanded (35 pages). ECF/Document 6.
- Filer: Plaintiff Eli Lilly and Company, by counsel Kirkland & Ellis LLP (James John Lomeo, Texas Bar No. 24118993, Austin office; others pro hac vice).
- Date filed: 2026-08-31 (ECF header: "Filed 08/31/26").
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.txwd.1172926918/gov.uscourts.txwd.1172926918.6.0.pdf (CourtListener RECAP; found via the CourtListener search API, `type=r`, `court=txwd`, `q=complaint`, filed after 2026-01-01).
- Date fetched: 2026-10-14
- Text layer: yes (`pdftotext -layout` reads it; Times New Roman embedded).
- Public court record (RECAP). Used as a structural reference only.

## 2. `FILED-EXAMPLE-complaint-2.pdf` (second filer, not transcribed)

- Case: *Brandon Callier v. Referrals Tech Inc. d/b/a All Web Referrals, et al.*, No. EP-26-cv-01039-LS (El Paso Division; header "3:26-cv-01039")
- Document: Plaintiff's Original Complaint (19 pages). Document 3.
- Filer: Plaintiff Brandon Callier, appearing for himself (self-represented; no counsel block on the pleading).
- Date filed: 2026-04-10 ("Filed 04/10/26").
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.txwd.1172901208/gov.uscourts.txwd.1172901208.3.0.pdf
- Date fetched: 2026-10-14
- Text layer: yes. Times New Roman embedded; caption uses a `§` column, the same convention as exemplar 1.

Why two filers: EVAL-LOOP tier 2 asks for two or three exemplars from different filers. Exemplar 1 is counsel-drafted; exemplar 2 is self-represented. Both are the same court and doc type.

## Search notes

- WebSearch (standard) for W.D. Tex. complaints on RECAP gave mostly docket pages. The CourtListener REST search (`https://www.courtlistener.com/api/rest/v4/search/?type=r&court=txwd`) returned RECAP documents with downloadable PDFs and was used instead.
- The CourtListener search also returned `gov.uscourts.txwd.1172749163.62.1.pdf` (a proposed order in *United States v. Abbott*, 1:23-cv-00853). It is an order, not a complaint, so it was not used.
- Clearinghouse.net document 170513 (*L.M.L. v. Martin*, 1:26-cv-01170) returned HTTP 403 and was not retrieved.
