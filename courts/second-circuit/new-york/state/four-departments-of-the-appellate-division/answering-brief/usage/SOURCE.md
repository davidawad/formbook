# Exemplar source: Appellate Division answering brief (respondent's brief)

**Result: one filed exemplar saved (search pass 2026-10-16, fb-595.26.22).** `SAMPLE-nyappdiv-answering-brief-nycla202203908.pdf`. The earlier passes (2026-10-14, 2026-10-15) found none; their record is kept below.

## Exemplar 1

| Field | Value |
|---|---|
| File | `SAMPLE-nyappdiv-answering-brief-nycla202203908.pdf` (52 pages, US letter, text layer present; made in Microsoft Word 2019, NYSCEF stamp added with iText; `pdffonts`: Times New Roman family embedded, Bookman Old Style, Arial Bold, Courier for the stamp) |
| Case | *New York County Lawyers Association, et al. v. The State of New York, et al.* (plaintiffs-respondents: the bar associations; defendant-respondent: the State; defendants-appellants: the City of New York, its Department of Finance and its Commissioner) |
| Court | Supreme Court of the State of New York, Appellate Division, **First** Department |
| Docket | Appellate No. 2022-03908 (New York County Clerk's Index No. 156916/2021); NYSCEF Doc. No. 17 |
| Document | "Brief for Plaintiffs-Respondents" (cover: "To be argued by: Michael J. Dell, Esq., 15 minutes requested") |
| Filer | Kramer Levin Naftalis & Frankel LLP (Michael J. Dell, Jason M. Moff, Nathan Schwartzberg), attorneys for plaintiffs-respondents |
| Date filed | 2023-04-19 (NYSCEF header "FILED: APPELLATE DIVISION - 1ST DEPT 04/19/2023 08:35 PM"; cover and signature dated April 19, 2023) |
| URL | <https://www.nycla.org/wp-content/uploads/2023/04/2022_03908_NEW_YORK_COUNTY_LAWYER_v_NEW_YORK_COUNTY_LAWYER_RESPONDENT_S_BRIEF_17.pdf> (posted by NYCLA, a party; a copy of the NYSCEF document) |
| Date fetched | 2026-10-16 (plain `curl`, no special headers) |
| sha256 | `95941c8b6d6249c2b7acf1c30103d197e066076acb992728ca2e52cf4d6ad520` |

**Public record.** A brief filed on NYSCEF in a public appeal, reposted by a party without access control.

**Department caveat.** First Department. Part 1250 applies to all four Departments, so the doc type and the governing rule match; Department-specific practice (Part 600 for the First, Part 1000 for the Fourth) is not settled by it.

**Limit.** The court banner on the cover ("Supreme Court of the State of New York, Appellate Division—First Department") is an image, so `pdftotext` does not return it; it is visible on the rendered page.

### What the exemplar shows

- Cover: NYSCEF header; "To be argued by / 15 minutes requested" upper right (1250.8(a)); the index number; "APPELLATE NO.:" to the right of the caption; a three-part caption (plaintiffs-respondents, "—against—" the State as defendant-respondent, "—and—" the City defendants-appellants); title "BRIEF FOR PLAINTIFFS-RESPONDENTS"; counsel, address, telephone and three email addresses lower right; date lower left.
- TOC (`-i-`) with "Page" heading, dot leaders; sections in capitals; Counterstatement of Facts sub-headings A.–D.; Argument points I., II. in capitals, II.A–C in title case. TOA (`-ii-` to `-v-`): "Cases", "Statutes", "Other Authorities"; case name in italics, citation on an indented second line; `passim` for heavily cited authorities.
- Body from arabic 1 (`- 1 -`): an untitled opening paragraph, then Preliminary Statement, Counterstatement of Question Presented, Counterstatement of Facts, Argument (an untitled standard-of-review paragraph, then points), Conclusion, signature block. Double-spaced Times New Roman 14; block quotations single-spaced and indented; footnotes single-spaced.
- Last page: Printing Specifications Statement (Times New Roman, 14, double, 10,394 words). No proof of service in this copy.

## Search pass 2026-10-16 (fb-595.26.22)

1. WebSearch: ag.ny.gov Fourth Department "Brief for Respondent": forms and decisions only.
2. WebSearch: "Brief for Respondents" "22 NYCRR 1250.8": forms, rules, motion decisions.
3. DocumentCloud search API with curl: blocked by Cloudflare.
4. WebSearch: "Brief for Respondent" "Printing Specifications Statement" filetype:pdf: Second Department blank forms and guides.
5. WebSearch: NYCLU Fourth Department respondent brief: an ACLU amicus page and decisions.
6. WebSearch: ag.ny.gov Third Department briefs: AG-hosted decisions and orders only.
7. WebSearch: "Brief for Respondent" "Fourth Judicial Department" 2022–2024: returned the NYCLA brief above (saved).
8. WebSearch: "FILED: APPELLATE DIVISION - 4TH DEPT" brief respondent: decisions, rules, out-of-state briefs.
9. WebSearch: Fourth Department respondents' brief on wp-content hosts: only *Behler v. Tao* (Court of Appeals; host returns 403).
10. WebSearch / WebFetch: statecourtreport.org (Oneida County election case): Court of Appeals filings only; the Fourth Department respondents' brief is not posted.
11. WebSearch: "4TH DEPT" "RECEIVED NYSCEF" respondents: one Fourth Department amicus filing (CA 23-00179), not a respondent's brief.
12. curl <https://www.nyclu.org/uploads/2022/11/brief.pdf>: downloads, but it is a Second Department appellant's brief (No. 2022-04443). Not used.
13. WebSearch: Fourth Department "Brief for Plaintiffs-Respondents" / "Defendants-Respondents" from Rochester and Buffalo firms; DA "Attorney for Respondent" KA briefs; courthousenews uploads: decisions only.

No Fourth Department respondent's brief was found that can be downloaded.

## Earlier passes (2026-10-14, 2026-10-15): no exemplar found then

### Documents found and not used

| Document | URL | Why not used |
|---|---|---|
| *Behler v. Tao*, APL-2024-00041 (Court of Appeals, not the Appellate Division), "Brief for Defendant-Respondent" | <https://www.nybusinessdivorce.com/wp-content/uploads/sites/94/2025/03/BehlervTao-res-Tao-Brf.pdf> | Wrong court. Host returned HTTP 403 to curl and to WebFetch. |
| "2024 04 17 Respondents Brief" (court and docket not confirmed from the search snippet; the host is a commercial-division blog) | <https://www.nybusinessdivorce.com/wp-content/uploads/sites/936/2024/08/2024-04-17-Respondents-Brief.pdf> | Right doc type, possibly an Appellate Division brief, but the host returned HTTP 403 to curl (a 25 KB HTML page was saved instead of a PDF) and to WebFetch. Not saved. Retry from another source; confirm the court before use. |
| *Hurrell-Harring v. State of New York*, Reply Brief for Plaintiffs-Appellants, Court of Appeals, 2010 | <https://www.nyclu.org/uploads/2008/05/Reply-Brief-for-Plaintiffs-Appellants.pdf> | Wrong court and wrong doc type (reply). |
| NYLS Digital Commons, `maynard_briefs` (1971 First Department brief) | <https://digitalcommons.nyls.edu/maynard_briefs> | Defendant-appellant brief, not an answering brief; not downloaded. |

### Second search pass, 2026-10-14 (fb-595.32.2)

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

### Searches tried (no answering brief found)

1. Web search: Fourth Department "brief for respondent" PDFs, 2024 (standard). Returned only Fourth Department motion decisions on assigned counsel, not briefs.
2. Web search: 22 NYCRR 1250.8 typeface and word-count rules (standard). Returned printing-specifications forms (AD2, AD3) but not the full rule text.
3. Web search: Third Department "Brief for Respondent" with the Attorney General (standard). Returned Third Department session calendars only.
4. Web search: Second Department "Brief for Defendant-Respondent" PDFs (standard). Returned Second Department 2018 scheduling orders and forms only.
5. Web search: "Brief for Respondents" with the printing-specifications statement and index number (extended). Returned forms and the Buffalo CLE materials, no filed brief.
6. Web search: NYCLU / CCR / Legal Aid First Department "brief for defendants-respondents" (standard). Returned the two Court of Appeals briefs above and no App Div brief.
7. Web search: Appellate Division respondent's brief with index number and table of authorities, 2019–2022 (extended). Returned rules and forms only.
8. CourtListener API, `type=r` (RECAP), `court=nyappdiv`, query "brief for respondent": zero results. CourtListener's HTML search page returned HTTP 403.
9. Direct fetch of the nycourts.gov AD3 printing-specifications form: HTTP 403.

### Rule source (not an exemplar)

22 NYCRR 1250.8 was read from the Cornell LII copy: <https://www.law.cornell.edu/regulations/new-york/22-NYCRR-1250.8>, fetched 2026-10-14. LII marks the section as adopted 9/17/2018 (New York State Register, October 31, 2018). The official nycourts.gov copy was not reachable from this box. See `../README.md`.

### Search pass, 2026-10-15 (fb-595.20.13)

No respondent's brief from any Department was found. Searches, all public sources:

1. CourtListener REST, `court=nyappdiv`, types `r` (RECAP), `rd`, `o`, queries "brief", "appellant", "respondent brief", "Appellate Division brief": zero RECAP hits. Opinion hits are opinions, not briefs.
2. WebSearch (standard) x2: NYSCEF header string with "BRIEF FOR RESPONDENT" and the Fourth/Third/Second/First Dept names. Returned Behler v. Tao (Court of Appeals, 403 from host), a Stefanik letter, Second Dept orders and motion decisions.
3. WebSearch (standard): "RESPONDENT'S BRIEF" with "NYSCEF DOC. NO." and "APPELLATE DIVISION". Returned ag.ny.gov trial-level filings, not appellate briefs.
4. WebSearch (standard): Hussain CR-23-1493 respondent's brief. Returned only the appellant's brief (see opening-brief/usage/SOURCE.md); no People's brief.
5. WebSearch (standard) x2: ag.ny.gov respondent brief; Fourth Dept respondent brief with table of authorities. Returned the Fuks candidate (below), Fourth Dept decision PDFs and Court of Appeals filing notices.

Candidate still not saved: the Fuks respondent's brief (First Dept, Catafago Fini, filed 2024-04-17, URL in the table above). Its host returns 403 to curl and WebFetch. This box does not spoof headers to get around that.
