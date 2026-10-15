# Exemplar source: opening brief (appellant), U.S. Army Court of Criminal Appeals

**BLOCKED: no exemplar.** No public filed brief of this type in ACCA was found. No `FILED-EXAMPLE-*.pdf` is saved here.

| Field | Value |
|---|---|
| File | none |
| Searches tried (2026-10-14) | WebSearch: ACCA rules of practice and procedure, brief format, typeface, margins. WebSearch: "Army Court of Criminal Appeals" "brief on behalf of appellant" pdf. WebSearch: "brief on behalf of the United States" answer pdf courtlistener. WebSearch (extended): courtlistener ACCA appellant brief, Statement of Facts, Assignment of Error. WebSearch: "Docket No. ARMY" "BRIEF ON BEHALF OF APPELLANT". |
| What the searches returned | Only filings of the Court of Appeals for the Armed Forces (CAAF), hosted at armfor.uscourts.gov (e.g. Guinn 19-0384, Scott 19-0365, Davis 24-0152, Robinson 2025 supplement). Those are filings in a different court, so they are not used as exemplars. No CourtListener, RECAP or ACCA-hosted brief surfaced. |
| Other candidates seen | JAGCNet ACCA Citation Guide (8th ed., 2019): a guide, not a brief. Not used as an exemplar. |
| URL fetched from | none usable |
| Case name / docket / filer / date | none |
| Date fetched | 2026-10-14 (search only) |
| Public record | n/a |

## Second pass (2026-10-14, unit acca-32.22)

Searches run on this pass, all for an ACCA-filed appellant brief. None produced one.

- WebSearch: "IN THE UNITED STATES ARMY COURT OF CRIMINAL APPEALS" "BRIEF ON BEHALF OF APPELLANT" pdf. Returned CAAF briefs only (Scott 19-0365, Hennis 17-0263, English 19-0050, Long 21-0085, Givens 21-0086).
- WebSearch (extended): "U.S. Army Court of Criminal Appeals" "Brief on Behalf of Appellant" "ARMY 2" pdf Government Appellate Division. Returned CAAF briefs (Ellis 25-0197, Washington 25-0044) and AFCCA rules.
- WebSearch: Army Court of Criminal Appeals appellant brief pdf "ARMY 2024" / "ARMY 2023" assignments of error. Returned CAAF briefs (Davis 24-0152 appellant brief, Guinn 19-0384 appellant brief, Robinson 26-0130 supplement).
- WebFetch: CourtListener search (`court=acca`, phrase "brief on behalf of appellant"). HTTP 403; no results read.

Rejected near-misses (not ACCA filings, so not used): CAAF appellant briefs in Army cases (Davis 24-0152, Guinn 19-0384, Scott 19-0365, Hennis 17-0263, Abdullah 25-0070 supplement). Air Force CCA filings on afcca.law.af.mil. The Pritchard amicus in ACCA (protectourdefenders), which is an amicus, not an opening brief.

Result: still no ACCA-filed appellant brief. The rules-only template stays. Overlay cannot run.

To unblock: a public ACCA appellant brief (CourtListener RECAP, the court's own site, or a public brief bank). The docket number format and the cover can then be checked against a real filing.

## Third pass (2026-10-15, bead fb-595.20.4)

CourtListener API v4 (anonymous; no API key is configured in this box, so requests are limited to 5/min) and public web search. Still no ACCA-filed Government answer or appellant brief.

- RECAP document searches (`type=rd`, with and without `court=acca`): phrases "Army Court of Criminal Appeals" with "brief on behalf of the United States", "brief on behalf of appellant", "Assignment of Error", "Government Appellate Division", "Docket No. ARMY". No RECAP document with an ACCA caption. `court=acca` returns 0 results for every query.
- CourtListener docket HTML pages return HTTP 403 (CloudFront) to non-browser requests; the `recap-documents` endpoint requires authentication.
- Lead, not usable: the Government's Answer and Return in *Lorance v. Hilton* (habeas, D. Kan. No. 5:18-cv-03297-JWL, CourtListener docket 14586211, Doc. 13, filed 2019-04-17) lists "Attach. H: Brief on Behalf of Appellant to the Army Court of Criminal Appeals" (an ACCA appellant brief). The attachment is not in RECAP storage (`recap/gov.uscourts.ksd.124482/gov.uscourts.ksd.124482.13.8.pdf` returns NoSuchKey; attachment numbers 1-7 and 9 also absent). The petition docket (CourtListener 16461579, Doc. 1, attachments A onward) has the same gap. Obtaining Attach. H needs PACER or a RECAP upload; the ACCA brief is then a public record of a federal filing. Not downloaded, not saved.
- Web search (3 queries, 2026-10-15): all hits are CAAF briefs on armfor.uscourts.gov (Steele 22-0254, Alfaro 26-0170, Scott 19-0365, Ellis 25-0197, English 19-0050, Davis 24-0152, Cole 23-0162, Briggs 16-0711, Matti 25-0148) or Air Force filings. Not ACCA; not used.

Result: still no ACCA-filed document of this type. Overlay cannot run. To unblock: the Lorance Attach. H (PACER, or a RECAP upload of the answer's attachments) would supply an ACCA appellant brief for opening-brief; no lead found yet for an ACCA Government answer.
