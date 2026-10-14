# Exemplars: motion-brief (txnb)

BLOCKED: no exemplar. No filed motion or brief from the U.S. Bankruptcy Court for the Northern District of Texas was found or downloaded, so there is no `FILED-EXAMPLE-*.pdf` in this folder.

Date of search: 2026-10-14. Public court records only.

## Searches tried

| # | Route | Result |
|---|---|---|
| 1 | CourtListener REST API, `type=r`, `court=txnb`, query "adversary complaint" (curl) | Timed out after 20 s, no response. |
| 2 | CourtListener web search, `court=txnb`, `type=r` (WebFetch) | HTTP 403 Forbidden. |
| 3 | Web search: txnb adversary proceeding complaint, courtlistener | Court hearing calendars, the N.D. Tex. local rules, the BTXN105 pro hac vice form, General Order 2015-01. No complaint PDF. |
| 4 | Web search: Highland Capital 19-34054 adversary complaint PDF | Court opinions (adversaries 21-03067, 21-03003/-03005/-03006/-03007, 22-03052, 25-03055) and calendars. The opinions are not complaints. No complaint PDF. |
| 5 | Web search: govinfo USCOURTS-txnb bankruptcy adversary complaint | No govinfo bankruptcy filings for txnb. Results were other districts' forms and court pages. |
| 6 | Web search (extended): N.D. Tex. bankruptcy adversary complaint, Dallas Division | Only a govinfo district-court complaint (txnd, 3:22-cv-02170, not a bankruptcy adversary) and the N.D. Tex. local rules. |
| 7 | Web search: Highland Capital Kroll claims-agent docket, "Original Complaint" | No Kroll docket page or complaint PDF. Justia shows an appellate docket (3:20-cv-3390) with metadata only. |
| 8 | Web search: adversary motion to dismiss brief, N.D. Tex. bankruptcy | Judge's hearing calendars list motions to dismiss adversary proceedings (e.g. 25-03049, 25-03115, 21-03033). No brief text. |

Not tried: PACER/CM-ADV (login required; not public access in this box), direct requests to the court's own docket search (not reachable from this box), state e-filing brief banks (not applicable to federal bankruptcy).

## What would settle it

A filed adversary complaint in an N.D. Tex. bankruptcy adversary (any division), as a text-based PDF from CourtListener RECAP, the court's docket, or a party's public exhibit. Once one is found, save it here as `FILED-EXAMPLE-<short-case>-<adv-no>-motion-brief.pdf`, add its row to this file, and transcribe a sample into `samples/`.
