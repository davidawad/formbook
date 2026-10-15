# Exemplar source: answering-brief, United States Bankruptcy Appellate Panel for the Eighth Circuit (bap8)

**BLOCKED: no exemplar.** No public filed appellee's (answering) brief from this court was found in two passes of searching, so no `FILED-EXAMPLE-*.pdf` is stored here.

The Brief of Appellant in BAP No. 11-6012 (*In re Fisette*) is the one public filed BAP brief found; it is the opening-brief exemplar (`../../opening-brief/exemplars/`). Its trustee-appellee brief was searched for and not found (pass 2, row 7-11 below).

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
| 1 | WebSearch (standard): "Bankruptcy Appellate Panel for the Eighth Circuit" "brief of appellant" "Fed. R. Bankr. P. 8014" pdf | Found the Fisette opening brief (`../../opening-brief/exemplars/SOURCE.md`). No appellee brief. |
| 2 | WebSearch (standard): "B.A.P. No." "Eighth Circuit" "appellee's brief" bankruptcy appeal pdf "Table of Authorities" | Eighth Circuit and BAP opinions; clerk letters. No appellee brief. |
| 3 | WebSearch (standard): courtlistener recap "BAP" "8th Cir." ... "reply brief of appellant" | Federal rules and general brief checklists. No RECAP brief. |
| 4 | WebSearch (standard): ecf.ca8.uscourts.gov newbap briefs appellant appellee pdf | BAP operating procedures and brief checklists. No BAP party brief. |
| 5 | WebSearch (extended): "Bankruptcy Appellate Panel" "Eighth Circuit" "BRIEF OF APPELLEE" OR "APPELLANT'S BRIEF" storage.courtlistener.com | BAP local rules, standing order, opinions. No RECAP brief. |
| 6 | WebSearch (extended): bankruptcy appellate panel 8th circuit appellant brief attached exhibit ... "Statement of Jurisdiction" | Surfaced the Fisette debtor brief (row 1 of the opening log). No appellee brief. |
| 7 | WebSearch (standard): Fisette Keller BAP 11-6012 brief of appellee trustee pdf | Clerk letter on Justia (counsel: Margaret Culp for appellee). No brief text. |
| 8 | WebSearch (standard): Fisette 11-6012 "reply brief" BAP Eighth Circuit Andresen | Case history (455 B.R. 177; 695 F.3d 803). No reply brief. |
| 9 | WebSearch (standard): ncbrc.org BAP 8th Cir brief appellee OR "reply brief" pdf | Rules and checklists. Nothing from ncbrc.org beyond the Fisette debtor brief. |
| 10 | WebSearch (extended): "UNITED STATES BANKRUPTCY APPELLATE PANEL" "FOR THE EIGHTH CIRCUIT" "BRIEF OF APPELLEE" "Trustee-Appellee" pdf | BAP opinions only. |
| 11 | WebSearch (extended): "Culp" "Fisette" "Brief of Appellee" ... | Opinions (CourtListener opinion pages). No appellee brief. |
| 12 | WebSearch (standard): BAP "reply brief" "Reply Brief of Appellant" ... 2012 OR 2013 OR 2014 | Clerk letters (Justia), opinions. No reply brief. |
| fetch a | curl, Justia docket entries for 11-6012 (`cases.justia.com/.../811734875/{1,3,4,5,6}.pdf`) and the Justia docket page | HTTP 403 from this box. Not retrieved. |
| fetch b | ncbrc.org Fisette brief, `http://` with a default client, then `https://` with a browser user agent | HTTP 406 over `http://`; HTTP 200 PDF over `https://`. The debtor's opening brief, not an appellee brief. |

Not checked: PACER (login required; not a public source in this box); the BAP's own docket pages (not reachable from this box); a RECAP-hosted trustee brief in the Fisette case (Justia blocked, no alternate host found).

## Pass 3, 2026-10-15 (nine searches, CourtListener API probes)

Anonymous CourtListener API: 5 requests/min (HTTP 429-style `throttled` body), no API key on this box, so queries were paced. Results with `court=bap8` came back empty (`count: 0`).

| # | Tool / query | Result |
|---|---|---|
| 1 | CourtListener v4 search, `type=r&court=bap8`, `q="brief of appellee"`, `"reply brief"`, `"appellee's brief"` | 200, `count: 0` each. No bap8 RECAP document indexed under those terms. |
| 2 | CourtListener v4 search, `type=r&court=bap8`, no query | `count: 0`. |
| 3 | CourtListener v4 search, `type=d&court=bap8` | `count: 0`. No bap8 docket indexed. |
| 4 | CourtListener v4 search, `type=r`, `q="Bankruptcy Appellate Panel" "Eighth Circuit" "brief of appellee"` (no court filter) | 4 hits, none a BAP brief. One ca8 RECAP entry: *Todd Christenson v. Steven Breitenfeldt*, No. 25-6003 (Eighth Circuit BAP appeal; judgment of Jan. 20, 2026 dismissing for lack of jurisdiction, signed by BAP judges Surratt-States, Norton, and Jones). The only RECAP document in the hit is the judgment, not a brief. The docket page is CloudFront-blocked (403) and the API needs a token. |
| 5 | CourtListener v4 search, `type=r`, `q="B.A.P. 8th Cir" "reply brief"` (no court filter) | 273 hits, none a bap8 brief. |
| 6 | WebSearch (standard): "Bankruptcy Appellate Panel" "Eighth Circuit" "brief of appellee" pdf BAP No. | Clerk letters (Justia) and BAP opinions. No brief. |
| 7 | WebSearch (standard): BAP "reply brief of appellant" "appellant's reply brief" pdf | Eighth Circuit unpublished orders, BAP IOPs, and the *Delta Engineering* opinion (270 F.3d 584). No brief. |
| 8 | WebSearch (extended): ncbrc.org / brief bank, trustee-appellee, "BAP No." | Opinions and a Ninth Circuit BAP order (not this court). No brief. |
| 9 | WebSearch (standard): "8th Cir. BAP" appellee's brief Chapter 13 trustee, "Table of Authorities", Rule 8015 | Rule text and BAP opinions. No brief. |

Still not searched: PACER (login); a CourtListener API token (the only route to the bap8 RECAP docket listings, which need one for full docket and document lookups).

If a filer later supplies a public BAP appellee's brief, add it here as `exemplars/FILED-EXAMPLE-<short-case>-<docket>-answering-brief.pdf` with the URL, case name, docket, filer, date filed, and date fetched.
