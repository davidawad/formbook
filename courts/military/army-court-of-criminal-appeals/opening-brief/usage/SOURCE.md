# Exemplar source: opening brief (appellant), U.S. Army Court of Criminal Appeals

**Exemplar found (fourth pass, 2026-10-16, bead fb-595.20.20).** The Defense's Brief on Behalf of Appellant in *United States v. Akbar*, filed in ACCA. The court posted it on its JAGCNet site; the copy is the Internet Archive capture of that page.

| Field | Value |
|---|---|
| File | `SAMPLE-acca-opening-brief-akbar20050514.pdf` (11 pages, an extract; see page map) |
| Case | *United States v. Sergeant (E-5) Hasan K. Akbar*, U.S. Army Court of Criminal Appeals, Docket No. ARMY 20050514 |
| Document | Brief on Behalf of Appellant (assignments of error and argument), 483 numbered pages plus index (502 PDF pages) |
| Filer | Defense Appellate Division, U.S. Army Legal Services Agency: MAJ Timothy Thomas, CPT Shay Stanford, LTC Jonathan F. Potter, MAJ Bradley M. Voorhees, COL Mark Tellitocci |
| Date filed | 1 February 2010 (certificate of service, "Assignment of Error" box checked) |
| URL fetched from | `https://web.archive.org/web/20161221054805id_/https://www.jagcnet.army.mil/sites/acca.nsf/0/5D43DA05091A516B85257B43005496C2/$FILE/Akbar%20Appellant's%20Brief.pdf` (original: ACCA site `jagcnet.army.mil/sites/acca.nsf`, "Akbar Appellant's Brief.pdf") |
| Date fetched | 2026-10-16 |
| Public record | Yes: posted by the court on its public site; some names are blacked out by the filer. |
| PDF type | Scanned with an OCR text layer on most pages. Source pp. 15-24 and 26-31 (including the caption page, source p. 19) have **no text layer**. |

Page map of the extract (built with `pdfseparate` and `pdfunite`):

| Extract p. | Source PDF p. | Brief page | Content |
|---|---|---|---|
| 1 | 19 | 1 ("Panel No. 2") | Caption (Appendix A form), "TO THE HONORABLE ...", Part One: Introduction (start), footnotes 1-2. No text layer. |
| 2-7 | 35-40 | 17-22 | Assignments of Error and Argument, Part Four summary, Assignment of Error I (law and standard of review) |
| 8-10 | 499-501 | 481-483 | Assignments LVII and LVIII, closing prayer, signature blocks |
| 11 | 502 | unnumbered | Certificate of Service (form with check boxes) |

The index (source pp. 1-18), brief pp. 2-16 and 23-480 are left out. The sample `usage/INPUT-acca-opening-brief-akbar.md` transcribes exactly the extracted pages (extract p. 1 from the page image).

Caveat: filed under the pre-2019 ACCA rules (set in Courier). The current rules (effective 15 January 2019, see `../README.md`) govern the template; the exemplar settles only what they leave open.

## First pass (2026-10-14): superseded record

At the time (superseded by the fourth pass): No public filed brief of this type in ACCA was found. No `SAMPLE-*.pdf` is saved here.

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
