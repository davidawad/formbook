# Exemplar source: answer brief (Government), U.S. Army Court of Criminal Appeals

**Exemplar found (fourth pass, 2026-10-16, bead fb-595.20.20).** The Government's Brief on Behalf of Appellee in *United States v. Akbar*, filed in ACCA. The court itself posted it on its JAGCNet site (high-profile capital case); the copy is the Internet Archive capture of that page.

| Field | Value |
|---|---|
| File | `SAMPLE-acca-answering-brief-akbar20050514.pdf` (11 pages, an extract; see page map) |
| Case | *United States v. Sergeant Hasan K. Akbar*, U.S. Army Court of Criminal Appeals, Docket No. 20050514 (Army) |
| Document | Brief on Behalf of Appellee (the United States' answer to the assignments of error), 218 numbered pages plus tables (233 PDF pages) |
| Filer | Government Appellate Division, U.S. Army Legal Services Agency: CPT Joshua W. Johnson, CPT Nicole L. Fish, MAJ Adam S. Kazin, MAJ Christopher B. Burgess |
| Date filed | 29 November 2010 (certificate of service "29 November 2010"; clerk's received stamp 29 Nov 2010 on the caption page) |
| URL fetched from | `https://web.archive.org/web/20161221055113id_/https://www.jagcnet.army.mil/sites/acca.nsf/0/5D43DA05091A516B85257B43005496C2/$FILE/Akbar%20Appellee's%20Brief.pdf` (original: ACCA site `jagcnet.army.mil/sites/acca.nsf`, "Akbar Appellee's Brief.pdf") |
| Date fetched | 2026-10-16 |
| Public record | Yes: posted by the court on its public site; names of some victims and witnesses are blacked out by the filer. |
| PDF type | Scanned (Fujitsu fi-5900C) with an Adobe Paper Capture OCR text layer; text extracts with OCR gaps. |

Page map of the extract (built with `pdfseparate` and `pdfunite`):

| Extract p. | Source PDF p. | Brief page | Content |
|---|---|---|---|
| 1 | 1 | caption (unnumbered, "Panel 2") | Caption page with the counsel blocks |
| 2-8 | 16-22 | 1-7 | Statement of the Case, Statement of Facts (The Crimes) |
| 9-11 | 231-233 | 216-218 | Assignment LVIII and its Law and Argument; Conclusion and signatures; Certificate of Service and Filing |

The source's pp. 2-15 (table of contents, table of authorities) and brief pp. 8-215 are left out. The sample `usage/INPUT-acca-answering-brief-akbar.md` transcribes exactly the extracted pages.

Caveat: the brief was filed under the pre-2019 ACCA rules (set in Courier). The current rules (effective 15 January 2019, see `../README.md`) govern the template; the exemplar settles only what they leave open.

## First pass (2026-10-14): superseded record

At the time (superseded by the fourth pass): No public Government answer (brief on behalf of the United States) filed in ACCA was found. No `SAMPLE-*.pdf` is saved here.

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

## Fourth pass (2026-10-16, bead fb-595.20.20)

New routes only (none of the queries above were repeated). Result: **found**, two ACCA-filed briefs in *Akbar* (appellant and appellee), plus the ACCA rules text.

1. Live `https://www.jagcnet.army.mil/ACCA` with a browser User-Agent: HTTP 200 but the body is a 2.6 KB access-denied (403) page. Nothing usable.
2. Wayback CDX, all PDFs under `jagcnet.army.mil` (`matchType=domain`, `filter=mimetype:application/pdf`): lists ACCA opinions (`Apps/ACCAOpinions/ACCAOpinions.nsf`), `ACCA Rules 20090731.pdf`, the 2012 ACCA Citation Guide, bar admission and notice-of-appearance forms.
3. Wayback CDX, `jagcnet.army.mil` URLs containing "Rules" or "Brief": ACCA-hosted briefs from ~2012 under `/8525749F00722CA8/` (Potter, Spicer, Gray, Giddens, Bean, Coleman appellant and appellee briefs). Every capture is HTTP 404; none archived. Not usable.
4. Wayback CDX, URLs ending `Brief.pdf` on `jagcnet.army.mil`: 192 captures, all from the ACCA site `sites/acca.nsf/0/5D43DA05091A516B85257B43005496C2/`: *Akbar* Appellant's Brief, Appellant's Reply Brief, Appellant's Supplemental Brief, Appellee's Brief, Appellee's Supplemental Brief; *Gray* Appellant's Brief and Appellee's Brief. HTTP 200 captures 2016-2019.
5. Downloaded (Wayback `id_` raw captures, 2026-10-16): *Akbar* Appellant's Brief (502 pp., OCR layer, filed 1 Feb 2010), *Akbar* Appellee's Brief (233 pp., OCR layer, filed 29 Nov 2010), *Gray* Appellant's Brief (25 pp.) and Appellee's Brief (50 pp.). The *Gray* PDFs (scanned 7 Mar 2012) are image-only with no text layer, so `tools/overlay.sh` cannot pair them; not used. *Akbar* used for both doc types (one filer per side: Defense Appellate Division for the opening brief, Government Appellate Division for the answer).
6. Wayback CDX, `jagcnet.army.mil/sites/acca.nsf/*`: also `ACCA Rules 20150115.pdf`, `ACCA Rules 20180601.pdf`, `ACCA Rules 20190115.pdf` (scanned, no text layer), `ACCA R. 35 (Interim) (19 May 2020)`, and writ papers in ARMY MISC 20120876/20120877 (GAD responses; writs, not briefs).
7. Wayback CDX, `jagcnet.army.mil/Home/assets/pdf/*`: `Home/assets/pdf/court/RulesofCourt.pdf`, capture 20250729125903: the ACCA Rules of Appellate Procedure effective 15 January 2019, 68 pp., with an OCR text layer. This is the rule text the template now cites (`../README.md`). The live URL returns the 403 page.
8. CAAF Joint Appendix route: Wayback CDX of `armfor.uscourts.gov/newcaaf/briefs/*` (1,423 URLs). No Joint Appendix is posted, only party and amicus briefs filed in CAAF; no ACCA brief reproduced there.

Not used: *Gray* (image-only), *Akbar* reply and supplemental briefs (other doc types), writ papers (other doc types).
