# Exemplar source: bap1 opening brief

**Status: exemplar found (2026-10-16).** `FILED-EXAMPLE-opening-brief.pdf`, details under "Resolved 2026-10-16" below. The earlier status was "BLOCKED: no exemplar"; the search history that led to it is kept below.

## Searches tried (2026-10-14 and 2026-10-15)

- CourtListener REST search, `court=bap1`, queries "opening brief", "brief of appellant", "appellant" (type=r): 0 results (2026-10-14; "appellant" re-run 2026-10-15, HTTP 200, count 0).
- CourtListener `court=bap1` dockets (type=d), query "appeal" (2026-10-15): 0 results. The bap1 court has 456 opinions indexed (type=o), but no RECAP documents or dockets, so there is no filed brief to pull.
- CourtListener unfiltered search, "BAP No." + "brief for appellant" (type=r, 2026-10-15): 22 hits, none a bap1 brief (meb, ca1, mab filings).
- CourtListener unfiltered search, "Bankruptcy Appellate Panel for the First Circuit" + "brief" (type=r, 2026-10-14): 18 hits; re-run 2026-10-15: 168 hits, none a bap1 brief (prd, ca1, mad filings).
- CourtListener "BAP No. MB", "BAP NO. EB", "BAP No. NH" + "appellant" (2026-10-15): throttled (HTTP 429); not re-run after the throttle.
- Web search (standard, 2026-10-15) for bap1 appellant briefs: BAP opinions with counsel captions ("on brief"), the quick reference, the local rules and the related-cases form. No brief.
- Web search (extended, 2026-10-14) for the BAP opening brief: the BAP guide and quick reference; no brief filed in a BAP docket.
- bap1.uscourts.gov: the public site lists forms, rules, calendars and opinions; no briefs posted.

## Sources of rules (not exemplars)

- BAP guide and quick reference, bap1.uscourts.gov (see `../README.md`).
- Opinions on bap1 list counsel "on brief"; these are not exemplars of the brief.

## Resolved 2026-10-16

The earlier searches filtered on CourtListener court id `bap1`, which has opinions only. CourtListener files the First Circuit BAP's dockets under the circuit's court id `ca1`: BAP No. MW 23-03 is ca1 docket "23-3". Found with the CourtListener RECAP search API (`type=r`, `court=ca1`, `caseName:Blumsack`).

### FILED-EXAMPLE-opening-brief.pdf (primary exemplar)

- Court: United States Bankruptcy Appellate Panel for the First Circuit
- Case: *Blumsack v. Harrington, United States Trustee (In re Scott H. Blumsack)*
- Docket: BAP No. MW 23-03 (CourtListener ca1 docket 23-3; ECF header "Case: 23-3, Document: 001147641, Entry ID: 2186973"); Bankruptcy Case No. 21-40248-EDK (Bankr. D. Mass.)
- Document: Brief for Appellant, Scott H. Blumsack (39 PDF pages: cover, TOC, TOA, oral-argument statement, body pp. 6-35, certificate of compliance, statement regarding related cases, statement regarding interested parties, certificate of service)
- Filer: Appellant Scott H. Blumsack (debtor). Counsel: Dmitry Lev, BBO # 665236, Law Offices of D. Lev, PC, Watertown, MA.
- Date filed: May 5, 2023 (ECF header "Date Filed: 05/05/2023"; signature and certificate of service dated May 5, 2023)
- URL: https://storage.courtlistener.com/recap/gov.uscourts.ca1.2190/gov.uscourts.ca1.2190.1147641.0.pdf
- Date retrieved: 2026-10-16. The file is the original as downloaded, unmodified (sha256 7ec15d50d0f0e8487a6e70c9e81a2145313fc055d30ba0107d8a5b01d64d0db5).
- Text layer and fonts: born-digital (Microsoft Word for Microsoft 365, stamped by the judiciary's iText ECF header). Body in Courier New (monospaced, about 12 pt, baseline pitch about 27 pt, i.e. double spaced); cover, TOC, TOA and certificates in Times New Roman; case names underlined. Text extracts cleanly with `pdftotext`.
- Used for: the transcription `usage/INPUT-opening-brief.md`, the render `usage/OUTPUT-opening-brief.typst.pdf` and the overlay `usage/OVERLAY-blumsack-opening-brief.pdf`/`.txt`.

### Alternate exemplar (different filer, same case; not saved here)

- Brief of Appellee William K. Harrington, United States Trustee, BAP No. MW 23-003, filed June 26, 2023 by the U.S. Trustee Program (Frederick Gaston Hall, Trial Attorney, signing; Ramona D. Elliott, Deputy Director/General Counsel). URL https://storage.courtlistener.com/recap/gov.uscourts.ca1.2190/gov.uscourts.ca1.2190.1147963.0.pdf. It is the primary exemplar of `../answering-brief/` (saved there). Compared with this brief for the tier-2 choices recorded in `../README.md` (cover order, level-1 and level-2 headings, TOA leaders, the Official-Form caption on the statement regarding related cases).
- No second appellant's opening brief from another filer was found (see `../reply-brief/usage/SOURCE.md` for the 2026-10-16 searches), so tier 2 is judged against two filers in one case, one opening and one answering brief.

## Search 2026-10-17 (fb-595.21.1): no further exemplar

- CourtListener RECAP search API (`court=ca1`, query `"Statement Regarding Interested Parties" "Bankruptcy Appellate Panel"`, the Official Form 2 title that only BAP briefs carry): not answered; the anonymous quota was exhausted by the box (HTTP 429, "50/hour", then "125/day").
- Web searches (standard and extended) for First Circuit BAP appellant, appellee and reply briefs and for U.S. Trustee Program BAP briefs on justice.gov: only BAP forms, local rules, opinions, and a redacted sample brief (nlrg.com "Peter Rabbit" sample, no real filer; not used).
- Result: no new public filed bap1 brief from a different filer. Recorded in `docs/box-blocked.md`.
