# Exemplar source: uscgcoca answering brief

BLOCKED: no public exemplar

No filed government answer or answering brief from the U.S. Coast Guard Court of Criminal Appeals was found, so there is no `FILED-EXAMPLE-*.pdf` here.

- Case name, docket no., filer, date filed: none
- URL fetched from: none
- Date fetched: n/a

The CGCCA labels the government's brief "Government Answer", not "answering brief". The searches below cover both labels. The opening-brief search trail (`../../opening-brief/exemplars/SOURCE.md`) also applies, since the same index and CourtListener routes were tried for both.

## Searches tried (2026-10-14)

Pass 1:

1. Web search: "courtlistener uscgcoca brief appellee answer brief pdf". Returned unrelated state and federal forms only.
2. Web search: CGCCA "Government Answer" / "Assignments of Error" filings. Returned the uscg.mil briefs index entry (see the opening-brief SOURCE.md) but no PDF.
3. WebFetch of the uscg.mil Appellate Briefs index: HTTP 403.
4. WebFetch of CourtListener search: HTTP 403.

Pass 2 (same day):

5. Web search: `"Coast Guard Court of Criminal Appeals" "Government Answer" pdf brief United States v.`. Returned CGCCA opinions on media.defense.gov and a CAAF amicus. No government answer.
6. Web search: `courtlistener uscgcoca recap document brief "Coast Guard" appellant`. Returned Coast Guard administrative decisions. No CourtListener or CGCCA filing.
7. Web search: `"UNITED STATES COAST GUARD COURT OF CRIMINAL APPEALS" "ANSWER" "Brief on Behalf of the United States" pdf appellee`. Returned CGCCA opinions only (Bickle, Sylvester, Latham, Upham and others). Each lists appellate government counsel in its caption, but none is a government brief.
8. Web search: `"USCG" "Court of Criminal Appeals" "Brief on Behalf of the United States" OR "Brief on Behalf of Appellant" Docket No. pdf` (extended). Returned CAAF government briefs in Air Force and Army cases and CGCCA opinions. No CGCCA government brief.
9. WebFetch of the CourtListener API v4 search (`type=r`, `court=uscgcoca`): **0 results**.
10. WebFetch of the CourtListener web search (`type=r`, "Coast Guard Court of Criminal Appeals" "assignments of error"): HTTP 403.
11. WebFetch of the uscg.mil CGCCA-Orders page: HTTP 403.
12. WebFetch of the Navy JAG "Coast Guard Court Filings & Records" page: the records table is empty in the fetched capture. The RSS feed (`/feed/tables/filings-records-uscg/`) returned HTTP 500.
13. Web search for CGCCA government briefs via `armfor.uscourts.gov` and CAAF. See the near-miss below.

## Near-miss, not used

- CAAF, *United States v. Lopez*, USCA Dkt. No. 24-0226/CG, government appellee brief: `https://www.armfor.uscourts.gov/briefs/2024Term/Lopez240226AppelleeBrief.pdf`. It is a Coast Guard government brief, but it was filed in the Court of Appeals for the Armed Forces, not this court. It does not qualify as an exemplar for a CGCCA government answer. It was not downloaded.

## Not yet tried (next steps for a person with access)

- The uscg.mil CGCCA Appellate Briefs index, from a browser or a box that can reach uscg.mil. It returned HTTP 403 to this box.
- The Navy JAG Coast Guard filings table, from a browser.
- A request to the CGCCA clerk or Appellate Government Counsel for a public copy of a redacted government answer.

## Pass 3 (2026-10-15, bead fb-595.20.5)

Routes not tried before:

15. CourtListener API v4 search, `type=r&court=uscgcoca`: **0 results** (re-run). The courts endpoint rejects `q`, and the anonymous limit is 5 requests/min. No CourtListener API key is set on this box.
16. CourtListener API v4 search, `type=o&court=uscgcoca` (opinions): not completed. Throttled. Retry with a key.
17. CourtListener unfiltered RECAP search for "Coast Guard Court of Criminal Appeals" with "brief": 53 hits, none from a CGCCA docket. Hits came from district courts, the Trump dockets and the CA11 and CADC dockets.
18. WebSearch (standard), "Coast Guard Court of Criminal Appeals" "Government Answer" appellee brief pdf: CGCCA opinions on media.defense.gov and the CAAF Lopez brief (near-miss, see below). No CGCCA government answer.
19. WebSearch (standard), media.defense.gov "Brief on Behalf of the United States": only CGCCA opinions (Butler, Bickle, Johnston, Zrike, Bungert and others).
20. WebSearch (extended), uscg.mil "Government Answer" PDF: returned the uscg.mil Appellate Briefs index as a result. The index lists "Government Answer" links per case (search snippet: MKSR Goodell, CSC Flores, SN Tucker). Opening the index with WebFetch returned HTTP 403.
21. curl with a browser user agent: the index, the CGCCA Rules of Appellate Procedure (Rev. 03/25) and a media.defense.gov opinion PDF all returned HTTP 403. The hosts are blocked from this box.

The index in item 20 is the most likely source of a public government answer. It needs a box that can reach uscg.mil. Once a PDF is in hand, it can be filed as `FILED-EXAMPLE-<case>-<docket>-answering-brief.pdf` with a row here.
