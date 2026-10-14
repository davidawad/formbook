# Exemplar source

- File: `FILED-EXAMPLE-vendramin-henry-13-03061-adversary-complaint.pdf` (10 pages, text layer present; `pdffonts` shows embedded TimesNewRomanPS-Bold and LiberationSans, `pdftotext` reads it)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.innb.352692.1.0.pdf (CourtListener RECAP document, Doc 1)
- Found via: CourtListener API search `court_id:innb` (`https://www.courtlistener.com/api/rest/v4/search/?q=court_id%3Ainnb%20complaint&type=r`, HTTP 200). The docket page itself returned HTTP 403 to WebFetch; the document was downloaded with curl from the storage URL above.
- Court: United States Bankruptcy Court, Northern District of Indiana, South Bend Division
- Case: *In re Daniel Thomas Henry and Margaret Jean Henry*, Chapter 7, Case No. 3:12-BK-34152 (joint debtors); adversary proceeding *Carolyn A. Vendramin v. Daniel Thomas Henry and Margaret Jean Henry*, Adv. Proc. No. 13-03061 (the header on every page reads `Case 13-03061-hcd Doc 1`; the caption's "AP NO." line is blank)
- Document: Complaint to Determine Dischargeability, Objection to Discharge, & Request for Relief of Stay (Doc 1)
- Filer: Plaintiff Carolyn A. Vendramin, a creditor, by Gordon A. Etzler & Associates, LLP (Blake N. Dahl, attorney no. 30576-64)
- Date filed: 09/23/2013 (ECF header "Filed 09/23/13")
- Date fetched: 2026-10-14
- Public court record (RECAP). Used as a structural and content reference for the complaint; the filing has irregular paragraph numbering and typographical errors, which the sample transcribes as filed (see README.md).

## Second candidate (not saved)

- Fischer, Trustee v. Radio Shack Credit Services, Adv. No. 08-01025 (Fort Wayne Division), Complaint, Doc 1, filed 02/06/08, from `https://storage.courtlistener.com/recap/gov.uscourts.innb.259912/gov.uscourts.innb.259912.1.0.pdf`. Two pages, Helvetica fonts not embedded, text layer present. It is a trustee's filing (a different filer from this one), so it would serve a second-filer comparison for tier 2. Downloaded and read on 2026-10-14, not saved, because the brief asks for one exemplar per doc type.

## Searches tried

- WebSearch: N.D. Ind. bankruptcy adversary complaint PDFs; results were court forms, opinions and dockets, no filed complaints.
- WebSearch: `gov.uscourts.innb` filename prefix; results were other districts.
- WebFetch of CourtListener web search pages: HTTP 403. The CourtListener API search worked (see above).
- CourtListener API, `court_id:innb` complaints: 2,164 results; the first 16 were read. Vendramin was the one selected.
