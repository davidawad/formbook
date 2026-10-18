# Exemplar source

- File: `FILED-EXAMPLE-adversary-complaint.pdf` (14 pages, text layer present; `pdftotext` reads it)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.txwb.377954/gov.uscourts.txwb.377954.1.0_2.pdf (RECAP copy of the ECF document)
- Docket page: https://www.courtlistener.com/docket/72093838/1/randolph-n-osherow-chapter-7-trustee-v-max/
- Court: United States Bankruptcy Court, Western District of Texas, Austin Division
- Case: *Randolph N. Osherow, Chapter 7 Trustee v. Tucker Max*, adversary proceeding, in *In re JTM2 Holdings, LLC*, Case No. 24-11105-SMR (Chapter 7)
- Docket no.: Adv. Pro. No. 25-01073-smr (ECF header; the caption copy has the adversary number left blank)
- Document: Complaint (ECF Doc #1)
- Filer: Plaintiff, Randolph N. Osherow, Chapter 7 Trustee, by Husch Blackwell LLP (Lynn Hamilton Butler, Ryan A. Burgett, Alejandra Garcia Castro)
- Date filed: December 31, 2025 (ECF header: "Filed 12/31/25")
- Date fetched: 2026-10-14

## Why this one

Searched CourtListener's RECAP search (`type=r`, `court=txwb`, adversary complaints in the Austin and San Antonio divisions). This complaint is a text-based, complete, recent Austin Division adversary complaint with the standard caption (IN RE block, Case No., Adv. Pro. No.), numbered paragraphs with headings, a request for relief and a signature block, 14 pages.

## Other complaints found (not saved)

- *Lowe, Chapter 7 Trustee v. Neugebauer*, Adv. No. 26-05011-alt (San Antonio Division, 19 pages, filed 3/2/26, RECAP `gov.uscourts.txwb.379516.1.0.pdf`). Text layer present. It uses a § column caption. A second filer for tier-2 comparison; not saved in this run (one exemplar per doc type).
- *Wood v. NewRez LLC d/b/a Shellpoint Mortgage Servicing*, Adv. No. 26-05012 (12 pages, filed 3/23/26). Text present; not reviewed in detail.
- *Texas Solar Integrated, LLC v. Wesco Distribution, Inc.*, Adv. No. 25-05064 (7 pages). Text present; not reviewed in detail.

## Searches tried

- WebSearch: "Western District of Texas bankruptcy adversary proceeding complaint pdf": returned court calendars, a court form order (`Form-Order-Adversary-Proceeding.docx`) and opinions, but no filed complaint PDF.
- WebSearch: "United States Bankruptcy Court" "Western District of Texas" motion memorandum "Adv. Proc.": court opinions and calendars only.
- CourtListener REST search (`/api/rest/v4/search/`, `type=r`, `court=txwb`): several queries; the complaint entries above came from it.
