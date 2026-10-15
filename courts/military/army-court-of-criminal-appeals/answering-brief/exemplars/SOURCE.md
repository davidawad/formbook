# Exemplar source: answer brief (Government), U.S. Army Court of Criminal Appeals

**BLOCKED: no exemplar.** No public Government answer (brief on behalf of the United States) filed in ACCA was found. No `FILED-EXAMPLE-*.pdf` is saved here.

| Field | Value |
|---|---|
| File | none |
| Searches tried (2026-10-14) | WebSearch: "Army Court of Criminal Appeals" "brief on behalf of the United States" answer to assignment of error pdf courtlistener. WebSearch: courtlistener "Army Court of Criminal Appeals" appellant brief "Statement of Facts" "Assignment of Error" pdf recap. WebSearch: ACCA rules of practice and procedure, brief form. |
| What the searches returned | Government appellee briefs at the Court of Appeals for the Armed Forces (CAAF), hosted at armfor.uscourts.gov (e.g. Steele 22-0254, Hennis 17-0263, Scott 19-0365). Those are CAAF filings, not ACCA filings, so they are not used. The Coast Guard CCA's briefs page (uscg.mil) is a different court. No CourtListener, RECAP or ACCA-hosted Government answer surfaced. |
| URL fetched from | none usable |
| Case name / docket / filer / date | none |
| Date fetched | 2026-10-14 (search only) |
| Public record | n/a |

## Second pass (2026-10-14, unit acca-32.22)

Searches run on this pass, all for an ACCA-filed Government answer. None produced one.

- WebSearch (extended): "Army Court of Criminal Appeals" "brief on behalf of the United States" courtlistener recap. Returned CAAF briefs and the JAGCNet ACCA rules page only.
- WebSearch: "ARMY" "BRIEF ON BEHALF OF APPELLEE" / "brief on behalf of the United States" "Court of Criminal Appeals" pdf 2024-2025. Returned CAAF appellee briefs (Forrest 25-0081, Abdullah 25-0070, Davis 24-0152), all filed at CAAF.
- WebSearch (extended): "IN THE UNITED STATES ARMY COURT OF CRIMINAL APPEALS" "BRIEF ON BEHALF OF THE UNITED STATES" "Government Appellate Division" pdf. Returned CAAF briefs and AFCCA filings only.
- WebFetch: CourtListener search (`court=acca`, phrase "brief on behalf of appellant"). HTTP 403; no results read.

Rejected near-misses (not ACCA filings, so not used): CAAF Government answers in Army cases (Forrest 25-0081, Abdullah 25-0070, Davis 24-0152, Steele 22-0254, Scott 19-0365, Long 21-0085, Givens 21-0086, Ellis 25-0197). Air Force CCA filings on afcca.law.af.mil (ACM dockets). The protectourdefenders amicus brief in ACCA (Pritchard), which is an amicus, not an answer.

Result: still no ACCA-filed Government answer. The rules-only template stays. Overlay cannot run.

To unblock: a public ACCA Government answer (CourtListener RECAP, the court's own site, or a public brief bank). The title and cover can then be checked against a real filing.

## Third pass (2026-10-15, bead fb-595.20.4)

CourtListener API v4 (anonymous; no API key is configured in this box, so requests are limited to 5/min) and public web search. Still no ACCA-filed Government answer or appellant brief.

- RECAP document searches (`type=rd`, with and without `court=acca`): phrases "Army Court of Criminal Appeals" with "brief on behalf of the United States", "brief on behalf of appellant", "Assignment of Error", "Government Appellate Division", "Docket No. ARMY". No RECAP document with an ACCA caption. `court=acca` returns 0 results for every query.
- CourtListener docket HTML pages return HTTP 403 (CloudFront) to non-browser requests; the `recap-documents` endpoint requires authentication.
- Lead, not usable: the Government's Answer and Return in *Lorance v. Hilton* (habeas, D. Kan. No. 5:18-cv-03297-JWL, CourtListener docket 14586211, Doc. 13, filed 2019-04-17) lists "Attach. H: Brief on Behalf of Appellant to the Army Court of Criminal Appeals" (an ACCA appellant brief). The attachment is not in RECAP storage (`recap/gov.uscourts.ksd.124482/gov.uscourts.ksd.124482.13.8.pdf` returns NoSuchKey; attachment numbers 1-7 and 9 also absent). The petition docket (CourtListener 16461579, Doc. 1, attachments A onward) has the same gap. Obtaining Attach. H needs PACER or a RECAP upload; the ACCA brief is then a public record of a federal filing. Not downloaded, not saved.
- Web search (3 queries, 2026-10-15): all hits are CAAF briefs on armfor.uscourts.gov (Steele 22-0254, Alfaro 26-0170, Scott 19-0365, Ellis 25-0197, English 19-0050, Davis 24-0152, Cole 23-0162, Briggs 16-0711, Matti 25-0148) or Air Force filings. Not ACCA; not used.

Result: still no ACCA-filed document of this type. Overlay cannot run. To unblock: the Lorance Attach. H (PACER, or a RECAP upload of the answer's attachments) would supply an ACCA appellant brief for opening-brief; no lead found yet for an ACCA Government answer.
