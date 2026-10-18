# Exemplar source

- File: `SAMPLE-vawb-motion-brief-thomas1705010.pdf` (19 pages, text layer present, `pdftotext` reads it)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.vawb.254556/gov.uscourts.vawb.254556.4.0.pdf (RECAP copy; docket page https://www.courtlistener.com/docket/6132481/4/thomas-v-midland-funding-llc/)
- Court: United States Bankruptcy Court, Western District of Virginia, Harrisonburg Division (`vawb`)
- Case: *Karen M. Thomas, et al. v. Midland Funding, LLC, and Midland Credit Management, Inc.*, adversary proceedings Nos. 17-AP-05009 and 17-AP-05010 (ECF header `Case 17-05010`), underlying Chapter 13 cases No. 16-50612 (Thomas) and No. 16-50396 (Brooks and Gillespie-Brooks)
- Docket no.: 17-05010 (ECF header); caption: Case Nos. 17-AP-05009 & 17-AP-05010
- Filer: defendants Midland Funding, LLC and Midland Credit Management, Inc., by counsel Timothy G. Moore (VSB No. 31698) and James K. Donaldson (VSB No. 80307), Spotts Fain PC, Richmond, Virginia
- Document: Defendants' Motion to Dismiss and Memorandum in Support (ECF 4); one combined document, motion paragraphs and memorandum together
- Date filed: August 7, 2017 (ECF header: "Filed 08/07/17 Entered 08/07/17 16:50:15"; signature block "DATED: August 7, 2017")
- Date fetched: 2026-10-14

## Why this one

Searched CourtListener's RECAP index for W.D. Va. bankruptcy motions with a supporting memorandum. This is a text-based, complete filing: caption with two debtor cases and two adversaries, a title that combines the motion and the memorandum, numbered paragraphs, headings, footnotes, a counsel block, a signature block and a certificate of service. It is an adversary-proceeding motion to dismiss (the FRBP 7012 path), not a contested-matter motion under FRBP 9014; the form is the same. Other memoranda in the search were court opinions or responses. Limit: the sample transcribes paragraphs 1–12 and 26 and the closing matter; paragraphs 13–25 and footnotes 2–3 are not transcribed.

## Searches tried

- CourtListener REST search API, `type=rd`, `court=vawb`: `"memorandum in support"` (two hits that are not motions: a 2017 Memorandum In Support of Credit Counseling Waiver, and a 2006 U.S. Trustee memorandum in response to a motion for summary judgment), `"brief in support"` (no party motions), `motion memorandum` (court opinions), `"Memorandum in Support of" Motion`, `motion "memorandum in support" dismiss` (found the Midland motion and a 2015 Battaglia motion to dismiss an adversary proceeding, with a 9-page memorandum attached as a separate document, not used), `motion "memorandum" "Filed by Debtor"`: rate limited (429) on some calls; those were retried.
- WebSearch: "Western District of Virginia" bankruptcy "motion" "memorandum in support" 9013 pdf: calendars and an old administrative order; no filing.
- WebFetch of the 2025 W.D. Va. local rules (text extracted with pdftotext; see README.md): no memorandum requirement for motions found.
- Not retrieved: www.courtlistener.com web pages (HTTP 403). The API and `storage.courtlistener.com` answered.
