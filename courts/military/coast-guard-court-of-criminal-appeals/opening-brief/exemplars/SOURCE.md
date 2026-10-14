# Exemplar source: uscgcoca opening brief

BLOCKED: no public exemplar

No filed opening brief (Assignments of Error and Brief on Behalf of Appellant) from the U.S. Coast Guard Court of Criminal Appeals was found, so there is no `FILED-EXAMPLE-*.pdf` here.

- Case name, docket no., filer, date filed: none
- URL fetched from: none
- Date fetched: n/a

## Searches tried (2026-10-14)

Pass 1:

1. Web search: "Coast Guard Court of Criminal Appeals appellant's brief pdf filed opening brief". Returned CAAF filings (Lopez, Fernandez amicus) and CGCCA opinions on media.defense.gov. None is an appellant's brief from the CGCCA.
2. Web search: CGCCA Rules of Appellate Procedure, brief format. Returned the rules index only.
3. Web search: CourtListener uscgcoca brief. No CourtListener or CGCCA results.
4. WebFetch of CourtListener search (`q="Coast Guard Court of Criminal Appeals" brief`): HTTP 403.
5. WebFetch of the uscg.mil Appellate Briefs index (`/Resources/Legal/Court-of-Criminal-Appeals/Court-of-Criminal-Appeals-Appellate-Briefs/`): HTTP 403. A search snippet of that index lists the CGCCA's filings as "Appellant's Assignments of Error", "Government Answer" and "Appellant's Reply", not "opening brief" / "answering brief". PDFs were not reachable.
6. Web search for "Assignments of Error" appellant brief on jag.navy.mil / media.defense.gov: no appellant brief PDF returned.

Pass 2 (same day):

7. Web search: `"Coast Guard Court of Criminal Appeals" "Assignments of Error" appellant brief pdf`. Returned CGCCA opinions on media.defense.gov, the 32 CFR 150 App. B format, and CAAF amicus briefs. No CGCCA party brief.
8. Web search: `"Brief on Behalf of Appellant" "Coast Guard Court of Criminal Appeals" pdf`. Returned a format guide on an unofficial mirror (`mirror.hep.gg`, not used) and CAAF material. No CGCCA appellant brief.
9. Web search: `"IN THE UNITED STATES COAST GUARD COURT OF CRIMINAL APPEALS" "BRIEF ON BEHALF OF APPELLANT" "Assignments of Error" Dkt`. Returned CGCCA opinions (Thibodeau, Naputi) and 32 CFR 150 App. B. No brief.
10. WebFetch of the CourtListener API v4 search (`type=r`, `court=uscgcoca`, query "Coast Guard Court of Criminal Appeals" brief): **0 results**, `document_count` 0.
11. WebFetch of the CourtListener web search for RECAP documents (`type=r`): HTTP 403.
12. WebFetch of the uscg.mil CGCCA-Orders page: HTTP 403.
13. WebFetch of the Navy JAG "Coast Guard Court Filings & Records" pages (`/military-justice/uscg-filings-records/` and `/usgc-filings-records/`): the records table is empty in the fetched capture (the only document link is a trial docket PDF). The RSS feed behind the table (`/feed/tables/filings-records-uscg/`) returned HTTP 500.
14. Web search for jag.navy.mil documents with "assignments of error": no appellate filing PDF returned.
15. Web search for CAAF briefs in Coast Guard cases (`armfor.uscourts.gov` "On Appeal from the United States Coast Guard Court of Criminal Appeals"). See the near-miss below.

## Near-miss, not used

- CAAF, *United States v. Lopez*, USCA Dkt. No. 24-0226/CG, government appellee brief: `https://www.armfor.uscourts.gov/briefs/2024Term/Lopez240226AppelleeBrief.pdf`. It is a Coast Guard case, but it was filed in the Court of Appeals for the Armed Forces, not this court, and it is a government brief, not an appellant's opening brief. It does not qualify as an exemplar for this doc type. It was not downloaded.
- CAAF, *United States v. Fernandez*, USCA Dkt. No. 24-0101/AF, Coast Guard OLADS amicus brief: wrong court and wrong filer. Not used.

## Not yet tried (next steps for a person with access)

- The uscg.mil CGCCA Appellate Briefs index and Orders page, from a browser or a box that can reach uscg.mil. Both returned HTTP 403 to this box.
- The Navy JAG Coast Guard filings table, from a browser (the table is populated client-side and was empty in this capture).
- A request to the CGCCA clerk for a public copy of a redacted appellant's brief.
