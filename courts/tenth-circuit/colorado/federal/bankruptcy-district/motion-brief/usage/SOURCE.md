# Exemplar source

## Primary: `FILED-EXAMPLE-motion-brief.pdf`

- Court: United States Bankruptcy Court for the District of Colorado
- Case: *Katzenberger v. Point Digital Finance Inc.*, Adv. Proc. No. 26-01048-MER (main case No. 25-17421-MER, Chapter 13)
- Document: Defendants' Motion to Compel Arbitration of Counts I Through V and to Stay the Adversary Proceeding (with the argument in one document; no separate memorandum). ECF/Doc 28, 15 pages.
- Filer: Defendant Point Digital Finance, Inc., individually and as Trustee for Point Titling Trust. Counsel: McGuireWoods LLP (Jeffrey Paul Ehrlich) and Markus Williams LLC (Lacey S. Bryan).
- Date filed: 2026-08-17 (ECF header "Filed:08/17/26" on every page)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.cob.536044/gov.uscourts.cob.536044.28.0.pdf (CourtListener RECAP; found by the RECAP search `court=cob`, `type=r`, query "Motion to dismiss adversary")
- Date fetched: 2026-10-14
- Text layer: yes (`pdftotext` reads it; embedded fonts).
- Public court record (RECAP). Used as the structural and tier-2 reference.

## Second filer (found, not transcribed): `FILED-EXAMPLE-motion-brief-2.pdf`

- Court: United States Bankruptcy Court for the District of Colorado, main case
- Case: *In re Maverix LLC*, Case No. 26-16423-MER, Chapter 11
- Document: Ex Parte Motion for Rule 2004 Examination of Debtor Maverix LLC and Production of Documents. ECF/Doc 58, 12 pages.
- Filer: Sonoran Capital Advisors, LLC (receiver), by David R. Laird (counsel).
- Date filed: 2026-09-22 (ECF header "Filed:09/22/26")
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.cob.541614/gov.uscourts.cob.541614.58.0.pdf (CourtListener RECAP)
- Date fetched: 2026-10-14
- Text layer: yes. Not transcribed into a sample (the sample is the Katzenberger motion). Kept for the second-filer comparison that EVAL-LOOP tier 2 asks for; it is a main-case ex parte motion, not an adversary motion, so it does not show the adversary caption.

## Searches tried

- CourtListener REST search (`/api/rest/v4/search/`, `court=cob`, `type=r`) for "motion to dismiss adversary", "Motion to Dismiss Adversary Proceeding", and "Complaint adversary". Results gave docket entries with RECAP storage paths for orders and a few motions; the entries used here had storage paths that fetched with HTTP 200.
- The unauthenticated API is rate-limited (5 requests per minute) and does not return RECAP document metadata; the `recap-documents` endpoint requires authentication.
- Docket-entry-1 complaints for the adversaries (Village Pointe 26-01170, Lofstedt 26-01228, CooperReilly 26-01240, Franklin 25-01328) are listed on CourtListener but have no RECAP storage copy (guessed storage paths return an error page), so they could not be downloaded.
- WebSearch: the court's own site and inforuptcy.com pages were found, but returned forms and docket listings, not filed motions.
- courtrules.net (the Colorado local bankruptcy rules) returns HTTP 403; cob.uscourts.gov local-rule PDFs return 404 from this box. The local rule text could not be read (see `../README.md`).
