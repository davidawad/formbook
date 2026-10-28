# Exemplar source: answering-brief (bap10)

**Status: BLOCKED: no public exemplar.** No public, filed answering-brief from a Tenth Circuit BAP appeal was found. No file is stored in this folder.

| Field | Value |
|---|---|
| Exemplar file | none (`usage/FILED-EXAMPLE-*.pdf` does not exist) |
| Searches (2026-10-14, WebSearch) | Standard and extended modes, five queries: "Appellee's Brief" with "Bankruptcy Appellate Panel of the Tenth Circuit" and "BAP No."; "Reply Brief" with BAP No. prefixes (CO, KS, NM, UT, WY); CourtListener RECAP with "BAP" and "Appellant's Opening Brief"; BAP 10th Cir. appellant briefs by state. Results: BAP opinions, the BAP pro se guide, the BAP local rules, and Tenth Circuit orders. No BAP brief. |
| CourtListener API (2026-10-14, curl) | `courts/bap10` exists. RECAP search `type=r&court=bap10` returns **0 documents** for an empty query and for "opening brief", "reply brief" and "brief" (dockets, `type=d`, also 0). Opinion search `type=o&court=bap10` returns BAP opinions only (e.g. BAP Nos. CO-24-009, UT-99-036), not briefs. Queries for "appellant" and "appellee" were rate-limited (HTTP 429) and were retried without success on the first attempt. |
| Tenth Circuit RECAP (same API, `court=ca10`) | Dockets for BAP-origin appeals exist (e.g. 24-4 McGann, 25-4 Darger, 26-4021 Lopez; BAP notices of appeal and orders). These are Tenth Circuit filings under FRAP 28, not BAP filings under FRBP 8014, so they are **not used** as exemplars for this court. |
| Justia | Dockets returned for Tenth Circuit (ca10) appeals only; none is a BAP appeal |
| govinfo | The search page is a JavaScript application; no text search result was reachable. BAP opinions appear in govinfo, not briefs. |
| BAP site | Pages under `bap10.uscourts.gov/node/...` returned "Request Rejected" to curl (WAF). The BAP "Briefs" and "Search Decisions" pages could not be read from this box. |
| Court-published material (not a filed brief) | https://www.bap10.uscourts.gov/sites/bap10/files/Pro%20Se%20Guide%20Sample%20Brief%20and%20Appendix_0.pdf : "Tenth Circuit Bankruptcy Appellate Panel (BAP) Pro Se Guide", 12 pages, with a sample opening brief and appendix. Its caption ("United States Bankruptcy Appellate Panel of the Tenth Circuit", "BAP No.", "Bankr. No.", "Chapter") and its section order were used for the template. It is a court-authored template, not a filing, so it is NOT an exemplar and is NOT stored here. |
| Rules source | https://www.bap10.uscourts.gov/sites/bap10/files/clerk/Bankruptcy%20Rule%20and%20BAP%20Local%20Rules%20%28eff.%201.1.2026%29.pdf (BAP Local Rules, Part VIII, eff. 1.1.2026). Fetched 2026-10-14; text extracted with `pdftotext`. |

Next step for a human: a BAP appellate brief can be requested from the BAP Clerk, or found in a PACER/CM-ECF docket for a known BAP number if the appellee filed one there. When one is found, store it as `usage/FILED-EXAMPLE-answering-brief.pdf`, fill in this table, and re-run the overlay.

## Re-check 2026-10-15 (answering brief, same search)

Still **BLOCKED: no public exemplar**. Each row below was run on 2026-10-15 from this box.

| Source | Result |
|---|---|
| CourtListener API, paced (no API key is configured on this box; anonymous calls returned HTTP 429 with `retry-after` about 30 s, so each call waited and was retried) | `type=r&court=bap10&q=appellee`: HTTP 200, `count: 0`. `type=d&court=bap10`: HTTP 200, `count: 0`. `type=o&court=bap10&q=brief`: HTTP 200, `count: 390`, all BAP opinions (e.g. *In re Williams*, BAP No. CO-10-020), none a brief. The 429 gaps recorded above are closed: the zero RECAP counts are real results, not throttling. |
| WebSearch, standard (3 queries) and extended (1 query) | Appellant's, appellee's and reply briefs of the Tenth Circuit BAP, with BAP No. prefixes. Results: BAP opinions (e.g. *In re Amy Liebl Darter, MD, PC*, BAP No. WO-25-6), the court's sample brief, Form 417C, and a govinfo BAP docket sheet (11-57; a docket, not a brief). No filed brief. |
| WebFetch, https://www.bap10.uscourts.gov/filing/briefs (the BAP's Briefs page) | Posted documents: the court-authored sample brief and appendix (Pro Se Guide), Form 417C, Brief Writing Tips, and the Appendix Checklist. The page states that no real filed brief is posted. |
| WebFetch, https://www.bap10.uscourts.gov/node/128 | Links only to `/filing/briefs` and the notice-of-appeal form. No filed brief. |

The court-authored sample is still **not** an exemplar: it is a template, not a filing.

Render and overlay on the same date: `tools/render.sh` exit 0, no typst warnings, 7 pages. Output in `/work/artifacts/bap10/`, not `usage/`. The snapshot has no PDFs, so no existing `usage/` PDF was regenerated. `tools/overlay.sh` exit 1 (no OUTPUT in `usage/`; no exemplar exists either).

## Re-check 2026-10-17 (second attempt)

Still blocked: no public filed answering brief located. Fresh web searches for an appellee/answering brief with Tenth Circuit BAP case identifiers surfaced only BAP opinions, appellate opinions, the court's sample, and a public pro se appellant brief in *Rusk v. Beutler* (BAP No. UT-25-10). The Rusk filing is an appellant's brief and does not establish answering-brief conventions, so it is not stored or used as an answering-brief exemplar. The BAP's publicly hosted decision in that case is an opinion, not a brief.

A direct anonymous CourtListener RECAP API request for `type=r&court=bap10&q=answering brief` and a docket request returned `Anonymous users don't have permission to access the API` on 2026-10-17. The web searches did not surface a public filed answering brief from another accessible source. With no filing to compare, no exemplar-derived transcription or overlay can be made without substituting a different document type.

## Re-check 2026-10-21

Still **BLOCKED: no public filed exemplar**. New searches targeted the court's own docket identifiers and brief titles:

| Source | Result |
|---|---|
| Web search: `"Bankruptcy Appellate Panel of the Tenth Circuit" "Appellant's Opening Brief" PDF`, `"BAP No." "Tenth Circuit" "Reply Brief" bankruptcy PDF`, and related exact-phrase queries | Results were BAP opinions and the court's briefs-rules page. No filed answering brief. |
| BAP briefs page, https://www.bap10.uscourts.gov/filing/briefs | Lists required brief contents, links the rules and forms, and hosts court-authored guidance; no filed briefs are offered. |
| CourtListener and search results for cited BAP appeals (including CO-19-043, 24-19, and 25-15) | Found opinions discussing briefs, not the briefs themselves. No publicly downloadable answering brief. |

The court-authored sample and opinions are not filed answering briefs and were not substituted. No `FILED-EXAMPLE` file or transcription was created.

## Re-check 2026-10-28

Still **BLOCKED: no public filed exemplar**.

| Source | Result |
|---|---|
| CourtListener v4 search API, anonymous | HTTP 403 `Authentication credentials were not provided.` No API token on this host. |
| Web search: `"Bankruptcy Appellate Panel of the Tenth Circuit" "brief of appellee" OR "appellant's brief" OR "reply brief" filetype:pdf` | govinfo and bap10 opinions (e.g. WO-11-093, CO-18-085), the court-authored Pro Se Guide sample, the BAP local rules, a Supreme Court appendix (19-787) reprinting a BAP opinion. No filed brief. |
| Web search: NCBRC brief bank (`ncbrc.org` uploads, "10th-BAP") | *Jubber* BAP opinion (2017), a Tenth Circuit opinion (*Williams*, 2022), briefs from other courts (7th Cir. *Johnson*, 9th Cir. *Oliver*). No Tenth Circuit BAP brief. |
| Web search: UST / justice.gov BAP briefs | BAP opinions only (*Funderburgh*, *Miller*). No brief. |
| Web search: BAP docket-prefix queries (`"BAP No. UT-"`, `CO-`, `KS-`, `NM-`, `WY-`, `EO-`) with brief titles | Unrelated brief-writing guides. No filing. |

Still not searched: PACER (login) and a CourtListener API token. Both need a PM decision.

## Authenticated RECAP search 2026-10-28: permanently without an exemplar

| Source | Result |
|---|---|
| CourtListener v4 search, authenticated, `type=rd` (RECAP documents), court `bap8` / `bap10`, `q=brief` (and the brief-title queries) | 0 documents. Control: court `ca10`, same query, 4004 documents. |
| CourtListener v4 search, `type=r` (RECAP dockets), court `bap8` / `bap10` | 0 dockets. CourtListener lists `bap10` with no PACER court id, so RECAP holds no BAP filings; it has the panels' opinions only (`type=o`: bap10 554, bap8 1376). |

The only remaining source is PACER, which charges per page and is out of scope (CoS ruling 2026-10-28). This folder is accepted as permanently without a `FILED-EXAMPLE`: tier 1 comes from the court's rules (rules.md); its INPUT is fictional. Re-open only if a public filing of this panel's brief becomes available.
