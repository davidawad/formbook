# Exemplar source: Appellate Division answering brief (respondent's brief)

**Result: no exemplar. BLOCKED: no exemplar.** No `FILED-EXAMPLE-*.pdf` is saved in this folder. No filed answering brief (brief for respondent / defendant-respondent / plaintiff-respondent) of any of the four Departments of the Appellate Division could be downloaded from a public source during this search.

Date of searches: 2026-10-14.

## Documents found and not used

| Document | URL | Why not used |
|---|---|---|
| *Behler v. Tao*, APL-2024-00041 (Court of Appeals, not the Appellate Division), "Brief for Defendant-Respondent" | <https://www.nybusinessdivorce.com/wp-content/uploads/sites/94/2025/03/BehlervTao-res-Tao-Brf.pdf> | Wrong court. Host returned HTTP 403 to curl and to WebFetch. |
| "2024 04 17 Respondents Brief" (court and docket not confirmed from the search snippet; the host is a commercial-division blog) | <https://www.nybusinessdivorce.com/wp-content/uploads/sites/936/2024/08/2024-04-17-Respondents-Brief.pdf> | Right doc type, possibly an Appellate Division brief, but the host returned HTTP 403 to curl (a 25 KB HTML page was saved instead of a PDF) and to WebFetch. Not saved. Retry from another source; confirm the court before use. |
| *Hurrell-Harring v. State of New York*, Reply Brief for Plaintiffs-Appellants, Court of Appeals, 2010 | <https://www.nyclu.org/uploads/2008/05/Reply-Brief-for-Plaintiffs-Appellants.pdf> | Wrong court and wrong doc type (reply). |
| NYLS Digital Commons, `maynard_briefs` (1971 First Department brief) | <https://digitalcommons.nyls.edu/maynard_briefs> | Defendant-appellant brief, not an answering brief; not downloaded. |

## Second search pass, 2026-10-14 (fb-595.32.2)

**Candidate found, not saved.** A First Department brief matches the doc type and court:

| Document | URL | Why not saved |
|---|---|---|
| *Fuks v. Rakia Associates* (App Div 1st Dept, App Nos. 2023-02618, 2023-02621, 2023-06798, 2024-00643; appealed from Supreme Court, New York County), "Brief for Plaintiff-Respondent," Catafago Fini LLP, filed 2024-04-17 (2024 NY Slip Op 03327, 228 AD3d 501) | <https://www.nybusinessdivorce.com/wp-content/uploads/sites/936/2024/08/2024-04-17-Respondents-Brief.pdf> | Host returns HTTP 403 to curl (with browser headers and referer; an HTML page was saved instead of a PDF) and to WebFetch. Search snippets show a cover and a table of authorities, but the body was not read. Retry from another copy (NYSCEF, the filer, or the Department clerk); the sibling defendants' briefs on the same host (2024-02-13 Appellants Brief, 2024-05-03 Reply Brief) are not answering briefs. |

Other searches in this pass (no App Div answering brief returned):

1. Web: "Brief for Defendant-Respondent" Second Department with printing specifications. Returned AD2 forms and instructions only.
2. Web: "Brief for Respondent" Fourth Department with table of authorities. Returned Fourth Department decision PDFs only.
3. Web: "Brief for Plaintiff-Respondent" First or Third Department, NYSCEF. Returned the Fuks candidate above and First Department calendars.
4. Web (extended): "Brief for Defendant-Respondent" First Department with index number and printing specifications, 2023–2025. Returned AD2 respondent instructions and a Buffalo CLE packet.
5. Web: respondent's brief in any Judicial Department on courtlistener, justia or scribd. Returned California and New Jersey filings and Fourth Department decisions.
6. Web: Fuks case numbers with "respondent" and Catafago. Returned the same host only.
7. Web: trellis.law briefs with the App Div and index number. No trellis.law hits.
8. CourtListener API, RECAP, `court=nyappdiv`, "brief for defendant-respondent": zero results. nycourts.gov (Fourth Department clerk) returned HTTP 403.

## Searches tried (no answering brief found)

1. Web search: Fourth Department "brief for respondent" PDFs, 2024 (standard). Returned only Fourth Department motion decisions on assigned counsel, not briefs.
2. Web search: 22 NYCRR 1250.8 typeface and word-count rules (standard). Returned printing-specifications forms (AD2, AD3) but not the full rule text.
3. Web search: Third Department "Brief for Respondent" with the Attorney General (standard). Returned Third Department session calendars only.
4. Web search: Second Department "Brief for Defendant-Respondent" PDFs (standard). Returned Second Department 2018 scheduling orders and forms only.
5. Web search: "Brief for Respondents" with the printing-specifications statement and index number (extended). Returned forms and the Buffalo CLE materials, no filed brief.
6. Web search: NYCLU / CCR / Legal Aid First Department "brief for defendants-respondents" (standard). Returned the two Court of Appeals briefs above and no App Div brief.
7. Web search: Appellate Division respondent's brief with index number and table of authorities, 2019–2022 (extended). Returned rules and forms only.
8. CourtListener API, `type=r` (RECAP), `court=nyappdiv`, query "brief for respondent": zero results. CourtListener's HTML search page returned HTTP 403.
9. Direct fetch of the nycourts.gov AD3 printing-specifications form: HTTP 403.

## Rule source (not an exemplar)

22 NYCRR 1250.8 was read from the Cornell LII copy: <https://www.law.cornell.edu/regulations/new-york/22-NYCRR-1250.8>, fetched 2026-10-14. LII marks the section as adopted 9/17/2018 (New York State Register, October 31, 2018). The official nycourts.gov copy was not reachable from this box. See `../README.md`.

## Next steps for whoever retries

- A respondent's brief in an Appellate Division appeal that is filed on NYSCEF (public records are sometimes viewable without login), or posted by the Attorney General, a public-interest firm, or a law-school clinic. Confirm the Department, the docket number and the filer from the cover.
- Once a text-layer PDF is saved here, name it `FILED-EXAMPLE-<short-case>-<docket>-answering-brief.pdf`, record the filer and date here, and re-run `sh tools/overlay.sh` on this folder.
