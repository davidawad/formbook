# Exemplar source: bap1 reply brief
**Status: exemplar found (2026-10-21).** Reply brief of appellant Christine Marie Ansin, BAP No. NH 23-025, filed March 7, 2024; details below. Earlier blocked searches are retained as search history.
**Status: BLOCKED: no exemplar** (re-searched 2026-10-16, see the end of this file). No public, filed bap1 reply brief was found after the searches below. No PDF is saved here; the `usage/` markdown is a fictional, rule-structured sample, not a transcription.

## Searches tried (2026-10-14 and 2026-10-15)

- CourtListener REST search, `court=bap1`, queries "opening brief", "brief of appellant", "appellant" (type=r): 0 results (2026-10-14; "appellant" re-run 2026-10-15, HTTP 200, count 0). No query for "reply brief" was run against bap1 with a clean response; the bap1 filter returned 0 for "appellant" on 2026-10-15, which the reply brief would also match.
- CourtListener `court=bap1` dockets (type=d), query "appeal" (2026-10-15): 0 results. The bap1 court has 456 opinions indexed (type=o), but no RECAP documents or dockets.
- CourtListener unfiltered search, "Bankruptcy Appellate Panel" + "reply brief" (type=r, 2026-10-15): throttled (HTTP 429) on the retry; the unfiltered query of "Bankruptcy Appellate Panel for the First Circuit" + "brief" (2026-10-15, 168 hits) showed no bap1 brief.
- Web search (standard, 2026-10-15) for bap1 reply briefs: BAP opinions and the BAP quick reference. No brief.
- Web search (extended, 2026-10-14) for the BAP reply brief: the BAP guide and quick reference; no brief in a BAP docket.
- bap1.uscourts.gov: the public site lists forms, rules, calendars and opinions; no briefs posted.

## Sources of rules (not exemplars)

- BAP guide and quick reference, bap1.uscourts.gov (see `../README.md`).
- Opinions on bap1 list counsel "on brief"; these are not exemplars of the brief.

## Re-search 2026-10-16 (still BLOCKED)

CourtListener files the First Circuit BAP's dockets under the circuit's court id `ca1`, not `bap1` (that is why the searches above returned nothing; the opening and answering exemplars were found this way, see `../../opening-brief/usage/SOURCE.md`). Searches on 2026-10-16 (by the lead agent of batch fb-u6nx, recorded here):

- CourtListener RECAP full text `"BANKRUPTCY APPELLATE PANEL FOR THE FIRST CIRCUIT" "REPLY BRIEF"`: 24 hits, none a bap1 reply brief (mab, mad, prd, prb, med and ca1 circuit filings).
- `caseName:Blumsack court=ca1` (BAP No. MW 23-03, the case of both saved exemplars): no reply brief docketed or uploaded.
- `caseName:Akouete court=ca1` and `caseName:Muszynski court=ca1`: bap1 dockets 24-11, 24-14, 24-16 and 26-3. The Muszynski docket (BAP No. PR 24-011) shows "Appellant Charles Muszynski reply brief filed" on 03/07/2025, but the document is not on RECAP (only the docket sheet is).
- `description:(brief) AND "Bankruptcy Appellate Panel" court=ca1`: no bap1 reply brief.

Result: no public bap1 reply brief. The reply template shares the opening and answering template (only `doc-kind` differs), so the 2026-10-16 template changes (see `../README.md`) apply to it, but no reply-specific layout was checked against a filing.

## Search 2026-10-17 (fb-595.21.1): no further exemplar

- CourtListener RECAP search API (`court=ca1`, query `"Statement Regarding Interested Parties" "Bankruptcy Appellate Panel"`, the Official Form 2 title that only BAP briefs carry): not answered; the anonymous quota was exhausted by the box (HTTP 429, "50/hour", then "125/day").
- Web searches (standard and extended) for First Circuit BAP appellant, appellee and reply briefs and for U.S. Trustee Program BAP briefs on justice.gov: only BAP forms, local rules, opinions, and a redacted sample brief (nlrg.com "Peter Rabbit" sample, no real filer; not used).
- Result: no new public filed bap1 brief from a different filer. Recorded in `docs/box-blocked.md`.

## Resolved 2026-10-21: FILED-EXAMPLE-reply-brief.pdf

- Court: United States Bankruptcy Appellate Panel for the First Circuit (docket filed under First Circuit case 23-25).
- Case: *Christine Marie Ansin v. Robert Ansin* (BAP No. NH 23-025; bankruptcy case no. 23-10366-BAH).
- Document: Reply Brief of Appellant, 9 pages, with cover, contents, authorities, reply argument, conclusion, certificate of compliance and certificate of service.
- Filer: Appellant Christine Marie Ansin, through counsel Darlene M. Daniele, Esq. (signature and filing counsel).
- Date filed: March 7, 2024 (ECF header: Case 23-25, Document 001149021, Entry ID 2187664).
- Docket URL: https://ecf.ca1.uscourts.gov/n/beam/servlet/TransportRoom?servlet=CaseSummary.jsp&caseNum=23-25&incOrigDkt=Y&incDktEntries=Y
- Public document URL: https://www.ncbrc.org/wp-content/uploads/Ansin-Reply-Brief.pdf
- Date fetched: October 21, 2026. Downloaded from the public NCBRC-hosted filing; original ECF header and text layer retained.
- Text layer and fonts: born-digital; judiciary iText ECF header. The certificate identifies Times New Roman 12 point. The source is legible and extracts with `pdftotext`.
- Transcribed to `usage/INPUT-reply-brief.md`; output `usage/OUTPUT-reply-brief.typst.pdf`; overlay `.overlay/courts/first-circuit/bankruptcy-appellate-panel/reply-brief/OVERLAY-reply-brief.pdf` and `.txt`.

This resolves the earlier searches recorded above. The 2026-10-16/17 search conclusions predate discovery of the publicly hosted Ansin brief.
