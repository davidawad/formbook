# Exemplar source

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-fisher-26-10536-reply-brief.pdf` |
| Document | Reply of Plaintiff-Appellant Ellen Mae Fisher (docket entry 53, 37 pages) |
| Case | *Fisher v. Texas Tech University Regents* |
| Court | U.S. Court of Appeals for the Fifth Circuit |
| Docket no. | 26-10536 (appeal from N.D. Tex. No. 5:26-CV-73) |
| Filer | Ellen Mae Fisher, Plaintiff-Appellant (counsel: Michael Thad Allen, Allen Harris PLLC) |
| Date filed | August 17, 2026 (per the "Date Filed" header on every page of the PDF) |
| Fetched from | RECAP document `https://storage.courtlistener.com/recap/gov.uscourts.ca5.230531/gov.uscourts.ca5.230531.53.0.pdf`, found via the CourtListener search API (`https://www.courtlistener.com/api/rest/v4/search/?type=r&court=ca5&q=%22reply+brief+of+appellant%22&order_by=dateFiled+desc`) |
| Date fetched | 2026-10-14 |
| Text layer | Yes (`pdftotext` returns text; fonts CenturySchoolbook and LiberationSans embedded) |
| Public record | Yes: a public docket filing on CM/ECF, reproduced through RECAP |

## Second filer

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-eeoc-houston-funding-12-20220-reply-brief.pdf` |
| Document | Appellant EEOC's Reply Brief (Document 00511898259, 22 pages) |
| Case | *Equal Employment Opportunity Commission v. Houston Funding Ltd. II, et al.* |
| Court | U.S. Court of Appeals for the Fifth Circuit |
| Docket no. | 12-20220 |
| Filer | Equal Employment Opportunity Commission, Plaintiff-Appellant (counsel: Susan L.P. Starr, EEOC) |
| Date filed | June 25, 2012 (PDF header and certificate of service) |
| URL | https://storage.courtlistener.com/recap/gov.uscourts.ca5.12-20220.00501898259.1.pdf (public RECAP docket copy) |
| Date retrieved | 2026-10-17 |
| SHA-256 | `d11e77c11d0244217f89567352d86ddf9bd8386eac69374e6c12cd2d2a6c49c6` |
| Text layer | Yes (`pdftotext`); PDF has 22 pages. |

Note on the date: the CourtListener search index lists this entry as filed 2026-06-08, but the PDF's own header reads "Date Filed: 08/17/2026" and the signature and certificate of service are dated August 17, 2026. The PDF header is used here.

Other candidate considered and not saved: *Anderton v. Dallas Independent School District*, No. 25-11351 (5th Cir.), Doc. 45, Appellant's reply (21 pages, Times New Roman and Bookman; RECAP `gov.uscourts.ca5.227848.45.0.pdf`). It is a different filer and would serve as a second exemplar for the tier-2 check, but the one exemplar in this folder is enough for the template's current scope.

Used for: the cover, the table of contents and table of authorities structure, the procedural background, Argument point A (transcribed in `../samples/INPUT-fisher-reply-brief.md`), the conclusion, the signature, the certificate of compliance and the certificate of service. Not transcribed: Argument points B to H and the remaining body pages (see the README's "Known gaps").
