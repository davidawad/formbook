# Exemplar source: answering-brief (bap10)

**Status: BLOCKED: no public exemplar.** No public, filed answering-brief from a Tenth Circuit BAP appeal was found. No file is stored in this folder.

| Field | Value |
|---|---|
| Exemplar file | none (`exemplars/FILED-EXAMPLE-*.pdf` does not exist) |
| Searches (2026-10-14, WebSearch) | Standard and extended modes, five queries: "Appellee's Brief" with "Bankruptcy Appellate Panel of the Tenth Circuit" and "BAP No."; "Reply Brief" with BAP No. prefixes (CO, KS, NM, UT, WY); CourtListener RECAP with "BAP" and "Appellant's Opening Brief"; BAP 10th Cir. appellant briefs by state. Results: BAP opinions, the BAP pro se guide, the BAP local rules, and Tenth Circuit orders. No BAP brief. |
| CourtListener API (2026-10-14, curl) | `courts/bap10` exists. RECAP search `type=r&court=bap10` returns **0 documents** for an empty query and for "opening brief", "reply brief" and "brief" (dockets, `type=d`, also 0). Opinion search `type=o&court=bap10` returns BAP opinions only (e.g. BAP Nos. CO-24-009, UT-99-036), not briefs. Queries for "appellant" and "appellee" were rate-limited (HTTP 429) and were retried without success on the first attempt. |
| Tenth Circuit RECAP (same API, `court=ca10`) | Dockets for BAP-origin appeals exist (e.g. 24-4 McGann, 25-4 Darger, 26-4021 Lopez; BAP notices of appeal and orders). These are Tenth Circuit filings under FRAP 28, not BAP filings under FRBP 8014, so they are **not used** as exemplars for this court. |
| Justia | Dockets returned for Tenth Circuit (ca10) appeals only; none is a BAP appeal |
| govinfo | The search page is a JavaScript application; no text search result was reachable. BAP opinions appear in govinfo, not briefs. |
| BAP site | Pages under `bap10.uscourts.gov/node/...` returned "Request Rejected" to curl (WAF). The BAP "Briefs" and "Search Decisions" pages could not be read from this box. |
| Court-published material (not a filed brief) | https://www.bap10.uscourts.gov/sites/bap10/files/Pro%20Se%20Guide%20Sample%20Brief%20and%20Appendix_0.pdf : "Tenth Circuit Bankruptcy Appellate Panel (BAP) Pro Se Guide", 12 pages, with a sample opening brief and appendix. Its caption ("United States Bankruptcy Appellate Panel of the Tenth Circuit", "BAP No.", "Bankr. No.", "Chapter") and its section order were used for the template. It is a court-authored template, not a filing, so it is NOT an exemplar and is NOT stored here. |
| Rules source | https://www.bap10.uscourts.gov/sites/bap10/files/clerk/Bankruptcy%20Rule%20and%20BAP%20Local%20Rules%20%28eff.%201.1.2026%29.pdf (BAP Local Rules, Part VIII, eff. 1.1.2026). Fetched 2026-10-14; text extracted with `pdftotext`. |

Next step for a human: a BAP appellate brief can be requested from the BAP Clerk, or found in a PACER/CM-ECF docket for a known BAP number if the appellee filed one there. When one is found, store it as `exemplars/FILED-EXAMPLE-<short-case>-<bap-no>-answering-brief.pdf`, fill in this table, and re-run the overlay.
