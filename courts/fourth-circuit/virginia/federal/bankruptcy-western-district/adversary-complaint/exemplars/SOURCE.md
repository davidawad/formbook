# Exemplar source

- File: `FILED-EXAMPLE-rosen-24-06016-adversary-complaint.pdf` (4 pages, text layer present, `pdftotext` reads it)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.vawb.282430/gov.uscourts.vawb.282430.1.0.pdf (RECAP copy; docket page https://www.courtlistener.com/docket/68982498/1/james-alan-rosen-and-robin-leslie-rosen-adversary-proceeding/)
- Court: United States Bankruptcy Court, Western District of Virginia (`vawb`)
- Case: *James Alan Rosen v. Texas Guaranteed Student Loan Corporation (n/k/a Trellis)*, adversary proceeding, bankruptcy case No. 23-61235 (Chapter 7; Debtors James Alan Rosen and Robin Leslie Rosen)
- Docket no.: Adv. Pro. No. 24-06016 (ECF header: `Case 24-06016 Doc 1`); the adversary number is printed in the header, the caption's "Adversary Pro No." line is blank
- Filer: plaintiff James Alan Rosen, by counsel Lynn A. Bradley, VSB No. 35761, Tucker Griffin Barnes, PC, Charlottesville, Virginia
- Document: Complaint Seeking Student Loan Discharge (ECF 1), 11 U.S.C. § 523(a)(8)
- Date filed: May 31, 2024 (ECF header: "Filed 05/31/24 Entered 05/31/24 09:26:22")
- Date fetched: 2026-10-14

## Why this one

Searched CourtListener's RECAP index for W.D. Va. bankruptcy filings described as adversary complaints; this is the one that has a stored, text-based PDF, a complete caption, numbered allegations, a prayer, a signature block and a service address. Other hits were either scanned (no text layer: `Kabbash v. Stotts`, 17-06002, ECF 30, a Konica Minolta scan) or not complaints. Limit: it is a short complaint (4 pages, one debtor-plaintiff, one creditor), so it sets the caption, paragraph and signature layout but not long-form pleading practice.

## Searches tried

- CourtListener REST search API, `type=rd`, `court=vawb`, `q="adversary complaint"`: 66 results; the complaint entries with stored PDFs were Rosen (24-06016, this one), Kabbash v. Stotts (17-06002, scanned), Henry v. Wells Fargo Bank (12-07044, ECF 1, 4 pages, RECAP copy not checked) and Garber/USTrustee complaints (2008-2009, Adv. 08-05038, 09-06023; RECAP PDFs not checked).
- CourtListener search API, `q=complaint`, `type=rd`, `court=vawb`, two pages: no further complaints with stored PDFs.
- WebSearch: "Western District of Virginia bankruptcy adversary complaint pdf courtlistener vawb": no complaint PDFs; returned the 2025 local rules and Inforuptcy docket pages.
- Not retrieved from the box: www.courtlistener.com web pages (HTTP 403 to curl and WebFetch); the API and `storage.courtlistener.com` answered. The API limit for anonymous use is 5 requests per minute.
