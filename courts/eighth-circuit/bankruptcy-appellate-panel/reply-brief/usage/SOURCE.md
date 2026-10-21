# Exemplar source: reply-brief, United States Bankruptcy Appellate Panel for the Eighth Circuit (bap8)

**BLOCKED: no exemplar.** No public filed reply brief from this court was found in four passes of searching, so no `SAMPLE-*.pdf` is stored here.

Two BAP briefs have been found so far: the debtor's opening brief in BAP No. 11-6012 (*In re Fisette*, `../../opening-brief/usage/`) and the appellees' brief in BAP No. 22-6006 (*Farm Credit Services of America v. Swackhammer*, `../../answering-brief/usage/`). The appellant's reply in 22-6006 (due 2023-01-06, later extended) is not in RECAP.

## Pass 4, 2026-10-16 (new route: BAP dockets are filed in RECAP under court id `ca8`)

| # | Tool / query | Result |
|---|---|---|
| 1 | CourtListener v4 `type=r`, no court filter: `"Bankruptcy Appellate Panel" "Eighth Circuit" "Reply Brief"`; `"BANKRUPTCY APPELLATE PANEL FOR THE EIGHTH CIRCUIT" brief` | 68 and 104 hits. One BAP brief: the appellees' brief in ca8 22-6006 (now the answering-brief exemplar). No reply brief. The rest are bankruptcy-court briefing schedules (mnb, ianb), district-court bankruptcy appeals, and BAP judgments. |
| 2 | CourtListener v4 `type=r&court=ca8`: `Swackhammer` | Docket 67093634 (22-6006): appellee brief available; an extension motion and an argument form listed but not available; no reply entry in RECAP. |
| 3 | CourtListener v4 `type=r&court=ca8&available_only=on`: `docketNumber:*-60* AND "REPLY BRIEF"`, `docketNumber:*-6* AND brief` | Only 22-6006, 25-6003 (judgment), 26-6021 (briefing schedule) have available documents. No reply. |
| 4 | CourtListener v4 `type=r&available_only=on`: `"8014A" reply`; `"L.R. BAP 8th Cir" "reply brief"`; `"Bankruptcy Appellate Panel" "Eighth Circuit" "reply brief of appellant"` | 4, 2 and 1 hits: the 22-6006 appellee brief, unrelated district filings, a BAP judgment. No reply. |
| 5 | CourtListener v4 `type=r`, courts mnb ianb iasb nebraskab ndb sdb areb arwb moeb mowb and the 8th Cir. district courts, available only: `"reply brief" "Bankruptcy Appellate Panel"`; `"reply brief" BAP` | 27 and 42 hits; district-court bankruptcy appeals (e.g. mnd 0:09-cv-03645 appellant's reply, a district-court appeal, not BAP) and BAP briefing schedules. No BAP reply. Kaltved (mnb 26-04027) docs 58, 60, 63 fetched: notices and the BAP briefing schedule, not briefs. |
| 6 | CourtListener v4 `type=r&court=ca8&available_only=on`: `APPENDIX "Bankruptcy Appellate Panel"`; `"BAP" "reply brief" appellant` | Court of Appeals appeals from the BAP (23-2491, 25-1654); no BAP reply in an appendix. |
| 7 | WebSearch (extended): "Reply Brief" "Bankruptcy Appellate Panel" "Eighth Circuit" "Appellate Case" "Date Filed" pdf | BAP opinion 11-6036 and Justia-hosted BAP clerk letters. No reply. |
| 8 | WebSearch (standard): "8014A(b)" "reply brief" appellant bankruptcy appellate panel | Rule text (FRBP 8014, 8018). No reply. |
| 9 | WebSearch (extended): "United States Bankruptcy Appellate Panel for the Eighth Circuit" "Reply Brief of Appellant" OR "Appellant's Reply Brief" OR "Reply Brief of Appellants" | 10th Cir. BAP brief page, Justia clerk letters. No reply. |
| 10 | WebSearch (standard): BAP 8th Cir. reply brief pdf trustee appellant, -opinion | Court of Appeals opinions, BAP IOPs, a judicial-conference presentation. No reply. |
| 11 | WebFetch: `cases.justia.com/federal/appellate-courts/ca8/11-6013/811728524/2.pdf` | HTTP 403 (Justia still blocked). |
| 12 | curl: `justice.gov/ust/appellate-briefs` | HTTP 404. |

Still not searched: PACER (login); a CourtListener API token (docket listings for the `ca8` 6000-series dockets, which would show whether a reply was ever bought into RECAP).

## Pass 1, 2026-10-14 (eight searches)

| # | Tool / query | Result |
|---|---|---|
| 1 | WebSearch (standard): "Eighth Circuit Bankruptcy Appellate Panel brief of appellant pdf" | BAP clerk letters on Justia (counsel lists only), an Eighth Circuit judgment on a BAP appeal (No. 11-2938). No brief. |
| 2 | WebSearch (standard): courtlistener bap8 appellant brief ... recap | Eighth Circuit opinions and BAP rules. No CourtListener brief. |
| 3 | WebSearch (extended): "B.A.P. 8th Cir." appellant's brief ... 2024 OR 2025 | Older BAP opinions; other circuits' forms. No brief. |
| 4 | WebSearch (extended): "Bankruptcy Appellate Panel" "Eighth Circuit" "brief of appellant" "BAP No." | Opinions only (e.g., No. 08-6038 opinion). No brief. |
| 5 | WebSearch (standard): courtlistener docket bap8 "appellant's brief" | Opinions and listing pages. No brief. |
| 6 | WebFetch: CourtListener search, `court=bap8`, "brief of appellant" | HTTP 403; not retrieved. |
| 7 | WebSearch (standard): "... 'brief of appellee' OR 'appellee's brief' BAP No." | Clerk letters naming appellee counsel (Nos. 10-6046, 12-6054). No brief text. |
| 8 | WebSearch (standard): "... 'reply brief' 'BAP No.' pdf filed" | Opinions and the BAP IOPs. No brief. |

## Pass 2, 2026-10-14 (twelve searches, three direct fetch attempts)

| # | Tool / query | Result |
|---|---|---|
| 1 | WebSearch (standard): "Bankruptcy Appellate Panel for the Eighth Circuit" "brief of appellant" "Fed. R. Bankr. P. 8014" pdf | Found the Fisette opening brief (`../../opening-brief/usage/SOURCE.md`). No reply brief. |
| 2 | WebSearch (standard): "B.A.P. No." "Eighth Circuit" "appellee's brief" bankruptcy appeal pdf "Table of Authorities" | Eighth Circuit and BAP opinions; clerk letters. No reply brief. |
| 3 | WebSearch (standard): courtlistener recap "BAP" "8th Cir." ... "reply brief of appellant" | Federal rules (FRBP 8018) and general brief checklists. No RECAP brief. |
| 4 | WebSearch (standard): ecf.ca8.uscourts.gov newbap briefs appellant appellee pdf | BAP operating procedures and brief checklists. No BAP party brief. |
| 5 | WebSearch (extended): "Bankruptcy Appellate Panel" "Eighth Circuit" "BRIEF OF APPELLEE" OR "APPELLANT'S BRIEF" storage.courtlistener.com | BAP local rules, standing order, opinions. No RECAP brief. |
| 6 | WebSearch (extended): bankruptcy appellate panel 8th circuit appellant brief attached exhibit ... "Statement of Jurisdiction" | Surfaced the Fisette debtor brief. No reply brief. |
| 7 | WebSearch (standard): Fisette Keller BAP 11-6012 brief of appellee trustee pdf | Clerk letter on Justia. No brief text. |
| 8 | WebSearch (standard): Fisette 11-6012 "reply brief" BAP Eighth Circuit Andresen | Case history (455 B.R. 177; 695 F.3d 803). No reply brief. |
| 9 | WebSearch (standard): ncbrc.org BAP 8th Cir brief appellee OR "reply brief" pdf | Rules and checklists. Nothing from ncbrc.org beyond the Fisette debtor brief. |
| 10 | WebSearch (extended): "UNITED STATES BANKRUPTCY APPELLATE PANEL" "FOR THE EIGHTH CIRCUIT" "BRIEF OF APPELLEE" "Trustee-Appellee" pdf | BAP opinions only. |
| 11 | WebSearch (extended): "Culp" "Fisette" "Brief of Appellee" ... | Opinions (CourtListener opinion pages). No appellee brief. |
| 12 | WebSearch (standard): BAP "reply brief" "Reply Brief of Appellant" ... 2012 OR 2013 OR 2014 | Clerk letters (Justia), opinions. No reply brief. |
| fetch a | curl, Justia docket entries for 11-6012 (`cases.justia.com/.../811734875/{1,3,4,5,6}.pdf`) and the Justia docket page | HTTP 403 from this box. Not retrieved. |
| fetch b | ncbrc.org Fisette brief, `http://` with a default client, then `https://` with a browser user agent | HTTP 406 over `http://`; HTTP 200 PDF over `https://`. The debtor's opening brief, not a reply. |

Not checked: PACER (login required; not a public source in this box); the BAP's own docket pages (not reachable from this box); a RECAP-hosted reply in the Fisette case (Justia blocked, no alternate host found).

## Pass 3, 2026-10-15 (nine searches, CourtListener API probes)

Anonymous CourtListener API: 5 requests/min, no API key on this box, so queries were paced. Results with `court=bap8` came back empty (`count: 0`).

| # | Tool / query | Result |
|---|---|---|
| 1 | CourtListener v4 search, `type=r&court=bap8`, `q="reply brief"`, `"brief of appellant"`, `"appellant's reply brief"` | 200, `count: 0` each. No bap8 RECAP document indexed under those terms. |
| 2 | CourtListener v4 search, `type=r&court=bap8`, no query | `count: 0`. |
| 3 | CourtListener v4 search, `type=d&court=bap8` | `count: 0`. No bap8 docket indexed. |
| 4 | CourtListener v4 search, `type=r`, `q="Bankruptcy Appellate Panel" "Eighth Circuit" "brief of appellee"` (no court filter) | 4 hits, none a BAP brief. One ca8 RECAP entry, *Todd Christenson v. Steven Breitenfeldt*, No. 25-6003: a BAP-judge judgment of Jan. 20, 2026, not a brief. Docket page CloudFront-blocked; API needs a token. |
| 5 | CourtListener v4 search, `type=r`, `q="B.A.P. 8th Cir" "reply brief"` (no court filter) | 273 hits, none a bap8 reply brief. |
| 6 | WebSearch (standard): BAP "reply brief of appellant" pdf, Eighth Circuit | Eighth Circuit orders, BAP IOPs, *Delta Engineering* (270 F.3d 584). No reply brief. |
| 7 | WebSearch (standard): "Bankruptcy Appellate Panel" "Eighth Circuit" "reply brief" pdf BAP No. | Clerk letters and opinions. No reply brief. |
| 8 | WebSearch (extended): ncbrc.org / brief bank, "reply brief", trustee-appellee, "BAP No." | Opinions and a Ninth Circuit BAP order. No reply brief. |
| 9 | WebSearch (standard): "8th Cir. BAP" reply brief, Rule 8014(c) table of authorities | Rule text and opinions. No reply brief. |

Still not searched: PACER (login); a CourtListener API token (needed for full bap8 docket and document lookups).

## Pass 5, 2026-10-21

| # | Tool / query | Result |
|---|---|---|
| 1 | Web search: `Goetz 2023 Eighth Circuit BAP debtor reply brief March 14 2023 appeal bankruptcy court filed`; `"22-6009" "Reply Brief" Goetz BAP`; `"22-6009" "REPLY BRIEF OF APPELLANT"` | Confirmed that Machele L. Goetz filed a reply on 2023-03-14 in BAP No. 22-6009. The BAP opinion is public at <https://ecf.ca8.uscourts.gov/opndir/23/06/226009P.pdf>. No reply brief PDF surfaced. |
| 2 | Public brief-bank search result: NCBRC, `Appellant-Goetz-Brief.pdf` | The Eighth Circuit appellate brief says the BAP reply was included at App. 134. Retrieved PDF is a scanned, 58-page appellate filing with no extractable text, not a text PDF of the reply. It does not meet the exemplar requirement. |
| 3 | CourtListener API availability check | Anonymous API access is denied on this host; no API token is configured. |

The brief itself was found to have been filed, but no qualifying text PDF of that BAP filing was publicly accessible in this search. Keep the sample synthetic and blocked until a text PDF is available. If one is supplied, save it as `usage/FILED-EXAMPLE-reply-brief.pdf` and record the URL, case, docket, filer, filing date, and fetch date here.
