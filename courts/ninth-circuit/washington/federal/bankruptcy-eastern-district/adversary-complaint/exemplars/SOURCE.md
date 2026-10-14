# Exemplar source

Doc type: adversary complaint, United States Bankruptcy Court, Eastern District of Washington (`waeb`).

## 1. `FILED-EXAMPLE-icap-25-80041-adversary-complaint.pdf`

- Court: United States Bankruptcy Court, Eastern District of Washington
- Case: *Miller and Freeman, as Co-Trustees of the iCap Trust v. Liang* (adversary, within the jointly administered iCap Enterprises Inc. chapter 11 case, Lead Case No. 23-01243-WLH11)
- Docket: Adv. Pro. No. 25-80041-WLH, Doc 1
- Document: Adversary Complaint for Avoidance and Recovery of Fraudulent Transfers (18 pages, with Exhibits 1 and 2)
- Filer: Plaintiffs Lance Miller and Seth Freeman, co-trustees, by counsel Bush Kornfeld LLP (Jason Edward Wax) and Meland Budwick, P.A.
- Date filed: 2025-09-26 (stamp "Filed 09/26/25" on every page)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.waeb.218358/gov.uscourts.waeb.218358.1.0.pdf (CourtListener RECAP; docket page https://www.courtlistener.com/docket/71467531/icap-enterprises-inc-adversary-proceeding/)
- Date fetched: 2026-10-14
- Text layer: yes (`pdftotext` yields text; checked on all 18 pages)
- Public court record (RECAP). Used as a visual and structural reference only.

## 2. `FILED-EXAMPLE-cle-elum-25-80033-adversary-complaint.pdf`

- Court: United States Bankruptcy Court, Eastern District of Washington (Yakima Division)
- Case: *City of Cle Elum v. (defendants)*, adversary within Chapter 9 Case No. 25-01128-WLH9
- Docket: Adv. Pro. No. 25-80033-WLH, Doc 1
- Document: Complaint to Avoid and Recover Transfers Pursuant to 11 U.S.C. §§ 547 and 550 and to Disallow Claims Pursuant to 11 U.S.C. § 502 (14 pages)
- Filer: Plaintiff City of Cle Elum, by counsel Stoel Rives LLP (John S. Kaplan, Bryan T. Glover, Brandon E. Lira)
- Date filed: 2025-08-13 (stamp "Filed 08/13/25" on every page)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.waeb.218078/gov.uscourts.waeb.218078.1.0.pdf (CourtListener RECAP; docket page https://www.courtlistener.com/docket/71103420/city-of-cle-elum-adversary-proceeding/)
- Date fetched: 2026-10-14
- Text layer: yes (`pdftotext` yields text)
- Public court record (RECAP). Second filer, different caption layout and a different chapter; used for the tier-2 comparison.

## Searches tried

- CourtListener REST search (`/api/rest/v4/search/?type=r&court=waeb&q=adversary complaint`): 205 hits; complaint-level RECAP PDFs exist for 1 Min LLC (25-80007), Water Station Management v. Riverside (25-80017), iCap (25-80041), City of Cle Elum (25-80033), Giga Watt (19-80012). iCap and Cle Elum were chosen: both text-based, both signed by counsel of record, both post-2024 (the current FRBP restyling).
- CourtListener web search page (`/?type=r&court=waeb`): blocked (HTTP 403 to the fetch tool); the REST API was used instead.
- Web search for "Eastern District of Washington" bankruptcy adversary complaint: returned only statistics reports and other districts' forms.
