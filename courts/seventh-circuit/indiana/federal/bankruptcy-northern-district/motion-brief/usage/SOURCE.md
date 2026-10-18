# Exemplar source

- File: `FILED-EXAMPLE-motion-brief.pdf` (13 pages, text layer present; `pdffonts` shows embedded TimesNewRoman, Bold and Italic, `pdftotext` reads it)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.innb.362606.318.0.pdf (CourtListener RECAP document, Doc 318)
- Found via: CourtListener API search `court_id:innb "brief in support"` (`https://www.courtlistener.com/api/rest/v4/search/?q=court_id%3Ainnb%20%22brief%20in%20support%22&type=r`, HTTP 200). Downloaded with curl from the storage URL above.
- Court: United States Bankruptcy Court, Northern District of Indiana, Fort Wayne Division
- Case: *In re River Terrace Estates, Inc.*, Chapter 11, Case No. 14-11829-reg (header `Case 14-11829-reg Doc 318`)
- Document: Brief in Support of Motion to Determine Bid of Danbury Road Holdings IV, LLC as a Conforming Bid in Connection with Sale Under Confirmed Plan of Reorganization (Doc 318). The motion it supports is a separate document, not in this exemplar.
- Filer: Creditor Danbury Road Holdings IV, LLC, by Taft Stettinius & Hollister LLP (Michael P. O'Neil, Andrew T. Kight)
- Date filed: 01/05/15 (ECF header "Filed 01/05/15"; signature block "Dated: January 5, 2015")
- Date fetched: 2026-10-14
- Public court record (RECAP). Used as a structural and content reference for the brief.

## Why this one

The CourtListener search for innb motions and briefs returned 31 results (its first 19 were read), most of them without a PDF. This brief has a PDF, is 13 pages, has a full caption, numbered headings, two footnotes, a block quotation, a signature block, and it is a separate brief supporting a motion, which is what Local Rule B-7007-1(a) requires. The other PDFs considered were Homman v. Schwartz (adv. 22-03010, Doc 4, a 2-page motion for remand for mandatory abstention), Rudecki v. Price (adv. 11-03033, Doc 4, a 5-page brief for a temporary restraining order, 2011, chapter 13), and Homann, Trustee v. One Advantage (adv. 22-03017, Doc 13, a 4-page brief for default judgment). The River Terrace brief is the fullest of these.

## Searches tried

- WebSearch: N.D. Ind. bankruptcy brief and motion PDFs; results were leagle opinions, inforuptcy docket pages and local rules.
- CourtListener web search pages: HTTP 403 to WebFetch.
- CourtListener API, `court_id:innb` with "brief in support" and "memorandum of law": results read as above.
- Only one exemplar is saved for this doc type. A second filer for tier 2 is not in the folder (see README.md, known gaps).
