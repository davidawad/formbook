# Exemplar source: adversary complaint (E.D. Ky. bankruptcy)

Two filed complaints from two different filers, as the eval-loop tier-2 rule asks (docs/EVAL-LOOP.md). Both are public court records copied from a public host; neither was obtained from PACER or CourtListener (both returned HTTP 403 to this box).

## 1. `FILED-EXAMPLE-adversary-complaint-2.pdf` (16 pages, text layer present)

- URL fetched from: https://oversight.house.gov/wp-content/uploads/2023/10/US-Bankruptcy-Court-Complaint.pdf
- Catalog record (same document, govinfo): https://www.govinfo.gov/app/details/GOVPUB-JU14-PURL-gpo219471
- Court: United States Bankruptcy Court, Eastern District of Kentucky, London Division
- Main case: *In re Americore Holdings, LLC, et al.*, Case No. 19-61608 (jointly administered; lead case as the complaint states)
- Adversary: No. 22-06032-grs (the ECF header reads "Case 22-06032-grs Doc 1"; the caption's "Adversary No. 22 _____" is blank)
- Document: Complaint to Recover Fraudulent Transfer and for Turnover (Doc 1)
- Filer: Carol L. Fox, Chapter 11 Trustee of Americore Health, LLC (plaintiff); counsel Nelson Mullins Riley & Scarborough LLP (Gary M. Freedman, Frank P. Terzo)
- Date filed: July 7, 2022 (ECF header "Filed 07/07/22")
- Date fetched: 2026-10-14
- Note: the copy hosted by the House Oversight Committee is the same filing that govinfo catalogs. The defendant is a private individual; the document is a public record.

## 2. `FILED-EXAMPLE-adversary-complaint.pdf` (17 pages, text layer present; 14 transcribed)

- URL fetched from: https://document.epiq11.com/document/getdocumentbycode?docId=3955467&projectCode=CDC (Epiq document server for the Cambrian Holding claims docket)
- Court: United States Bankruptcy Court, Eastern District of Kentucky, Lexington Division
- Main case: *In re Cambrian Holding Company, Inc., et al.*, Case No. 19-51200 (GRS), jointly administered
- Adversary number: blank on the copy (`Adv. No. ____________`). The ECF header reads "Case 19-51200-grs Doc 1800 Filed 06/15/21", so the complaint is docket entry 1800 in the main case. Whether a separate adversary docket number was later assigned is not shown in the copy.
- Document: Complaint to Avoid Transfers Pursuant to 11 U.S.C. §§ 547, 548, 549, 502 and to Recover Property Transferred Pursuant to 11 U.S.C. § 550
- Filer: Ellen Arvin Kennedy, solely as Liquidating Trustee of the Cambrian Liquidating Trust (plaintiff); counsel Dinsmore & Shohl LLP (John M. Spires, Esq.; Ellen Arvin Kennedy, Esq.)
- Date filed: June 15, 2021 (ECF header and signature block "Dated: June 15, 2021")
- Date fetched: 2026-10-14

## Searches tried (for both, and for the motion exemplar)

- WebSearch: E.D. Ky. bankruptcy adversary complaint PDFs; results were docket aggregators (PacerMonitor, Inforuptcy) that show docket text only, with no link to a document.
- CourtListener search API and website: HTTP 403 to this box (curl and WebFetch).
- govinfo (USCOURTS-kyeb-*): found the Fox complaint's House Oversight copy via search. Other govinfo kyeb PDFs found were opinions and orders (for example 16-ap-01040, 22-05020), not complaints.
- Epiq document server (document.epiq11.com): found the Kennedy complaint and other Cambrian filings (an affidavit, a confirmation order).
- PacerMonitor docket pages (Edwards v. Saylor, 24-ap-06054; Spradlin v. 3D Dycus, 16-ap-01033): docket text only, no document links.
