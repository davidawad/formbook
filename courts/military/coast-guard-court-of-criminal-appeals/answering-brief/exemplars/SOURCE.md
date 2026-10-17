# Exemplar source: uscgcoca answering brief

**Exemplar found (fourth pass, 2026-10-16, bead fb-595.20.21).** The Government's Answer to Appellant's Assignments of Error in *United States v. Steen*, published by the CGCCA on its Appellate Briefs page; fetched from the Internet Archive because uscg.mil returns 403 to this box.

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-steen-1464-answering-brief.pdf` (8 pages, an extract; see page map) |
| Case | *United States v. Boatswain's Mate Third Class (E-4) Justin D. Steen, U.S. Coast Guard*, CGCCA Docket No. 1464, CGCMSP 24978 |
| Document | "Answer to Appellant's Assignments of Error on Behalf of the United States", 19 pp. |
| Filer | Appellate Government Counsel, Commandant (CG-LMJ): Stephen P. McCleary and LT Z. N. Godsey, USCG |
| Date filed | 6 May 2019 (caption date and certificate of service) |
| URL fetched from | `https://web.archive.org/web/20200919020847id_/https://www.uscg.mil/Portals/0/Headquarters/Legal/cca/Court_of_Criminal_Appeals_Opinions/AppellantBriefs/US%20v%20BM3%20Steen%20Govt%20Answer_Redacted.pdf?ver=2019-06-06-153015-353` (listed on the court's Appellate Briefs page, Wayback capture 20190820115734) |
| Date fetched | 2026-10-16 |
| Public record | Yes: published by the court, redacted by it. |
| PDF type | Acrobat Paper Capture (OCR text layer over the scan). |

Page map of the extract:

| Extract p. | Source p. | Content |
|---|---|---|
| 1-4 | 1-4 | Caption, "TO THE HONORABLE ...", introduction, Statement of the Case (footnote 1), Statement of Facts (footnote 2) |
| 5-6 | 5-6 | Issue I heading, Standard of Review, Discussion, heading A |
| 7 | 18 | End of the sufficiency argument, Conclusion, Prayer for Relief, two signature blocks |
| 8 | 19 | Certificate of Service |

Source pp. 7-17 are left out. `samples/INPUT-steen-answering-brief.md` transcribes exactly the extracted pages.

## First pass (2026-10-14): superseded record

At the time (superseded by the fourth pass): BLOCKED, no public exemplar.

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

## Fourth pass (2026-10-16, bead fb-595.20.21)

New routes only. Result: **found**. The court's own "Appellate Briefs" page and its PDFs are archived in the Internet Archive, which this box can reach although uscg.mil returns 403.

1. Live `https://www.uscg.mil/Resources/Legal/Court-of-Criminal-Appeals/Court-of-Criminal-Appeals-Appellate-Briefs/` with curl and a browser User-Agent: HTTP 403 (unchanged).
2. Wayback CDX for `uscg.mil/Resources/Legal/Court-of-Criminal-Appeals*`: the briefs index is archived once, `20190820115734`. Fetched it: it lists Appellant's Assignments of Error / Government Answer / Appellant's Reply for Steen, Harpole, Guzman, Pacheco, Rodriguez, Livingstone, Hernandez and Rogers, linking to `uscg.mil/Portals/0/Headquarters/Legal/cca/Court_of_Criminal_Appeals_Opinions/AppellantBriefs/`.
3. Wayback CDX for that `AppellantBriefs/` folder: 45 PDF captures (2020-2021), adding Goodell II, Schwartz, Stoddard-Castro, Piccininno, Flores (Art. 62), Olsen, Tucker (habeas) and Weiser. All fetched with the raw `id_` form (Wayback rate-limits; retried with backoff). 38 of 45 downloaded; Weiser AOE, Harpole AOE, Steen reply, Livingstone AOE, Rogers answer, Piccininno answer and Flores response did not download (timeouts).
4. Triage: Goodell II AOE has a broken text layer (no ToUnicode; extracts as garbage), so the overlay cannot pair it. Schwartz, Stoddard-Castro and Piccininno AOEs are 2-4 page merits-type filings. 2017-2018 filings (Hernandez, Rodriguez, Guzman, Livingstone, Pacheco) predate the 1 January 2019 rules. **Steen** (Dkt. 1464) is the newest full pair under the JRAP-era rules with a usable text layer: the AOE (dated 4 April 2019, 31 pp., Acrobat ClearScan OCR) and the Government answer (6 May 2019, 19 pp., text layer). Used for both doc types; different filers (defense / government).
5. Rules: Wayback CDX for `uscg.mil/Portals/0/Headquarters/Legal/cca/*` gave the rules PDFs. Fetched `CGCCA Rules of Appellate Procedure with JRAP (March 2025).pdf` (capture 20250428115614, 33 pp.), `Coast Guard Rules of Appellate Procedure with JRAP (effective 1Jan19).pdf` (20191130041821, 28 pp.) and `Joint Rules of Appellate Procedure (May 2024).pdf` (20240705065445). Rule 17.1 (format), 17.2 (content), 17.3 (length, word certificate) and 14 (signature) were read; see `../README.md`.

Not used: the other 37 downloaded filings (older rules, broken text, merits-only, or other doc types: replies, habeas, Art. 62).
