# Exemplar source

**No exemplar.** No text-layer filed motion with a memorandum (or brief) from the District of South Dakota bankruptcy court was found. The search is logged so the next person does not repeat it. Searches were run 2026-10-14.

## Searches tried

CourtListener RECAP (API v4 search, `type=r`, `court=sdb`), keyword queries: "motion to dismiss memorandum", "brief in support motion", "memorandum in support motion adversary", "brief", "memorandum of law", "memorandum brief support", "motion to dismiss adversary brief", "Dozier Arendt Allred motion dismiss", "Keithahn Heritage summary judgment". Downloaded and checked:

| Candidate | Why it was not usable |
|---|---|
| *Northern Beef Packers LP*, 13-10118, Doc 134 "Brief filed by White Oak Global Advisors LLC" (brief in support of a cash-collateral motion, main case) | The RECAP PDF was not on file (storage returned an error page, not a PDF). |
| *Leiferman*, 10-40718, Doc 24 "Brief in Support of Chapter 13 Plan Confirmation" (filed 2010-12-09, 4 pages) | Downloaded: the PDF is an image with no text layer (`pdftotext` returns nothing). Not usable as a text-based exemplar. It is also a plan-confirmation brief, not a motion. |
| *Keithahn v. Heritage Construction Companies*, 25-04005, Doc 13 (debtor-plaintiff's motion for summary judgment) | The motion itself has no RECAP PDF. Doc 16 (the court's decision, 9 pages, 2026-05-13) is on file and is a decision, not a filing. |
| *Paulson v. Mars*, 12-01005, Doc 14 (motion to dismiss adversary proceeding) | The RECAP PDF was not on file (storage returned an error page). Doc 18 is a decision. |
| CourtListener docket-entry endpoint for doc 13 of 25-04005 | Requires authentication (HTTP 401 / detail "Authentication credentials were not provided"). |

Web searches (WebSearch): standard mode, three queries ("District of South Dakota" bankruptcy adversary complaint 7001; "Bankr. D.S.D." motion memorandum brief 9013; "motion to dismiss" "brief in support" adversary sdb.uscourts.gov or CourtListener); extended mode, one query ("Bankruptcy Court" "District of South Dakota" "motion" "memorandum in support" or "brief in support", adversary, debtor counsel). Results were the court's local rules (Rule 7007-1, Rule 9004-1(f)), the court's sample adversary caption (a court form, not a filing), a 2021 court update (*Allred v. Arendt (In re Dozier)*, no motion papers linked), and Garrett orders (main-case dismissal orders, no briefs). No filed motion or memorandum with a text layer turned up.

Not tried: PACER (not accessible from this box; it is the official source); the court's own "Adversary - Opening" or appendix forms (sample forms, not filings).

## What would settle it

A text-layer PDF of a motion (or motion-with-memorandum) filed in an sdb case: from PACER, or from a RECAP upload of such a docket. Save it here as `FILED-EXAMPLE-<short-case>-<docket>-motion-brief.pdf`, add its row to this file, and transcribe the sample from it.
