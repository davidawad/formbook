# Exemplar source: bap1 answering brief

**Status: exemplar found (2026-10-16).** `FILED-EXAMPLE-blumsack-MW-23-03-answering-brief.pdf`, details under "Resolved 2026-10-16" below. The earlier status was "BLOCKED: no exemplar"; the search history that led to it is kept below.

## Searches tried (2026-10-14 and 2026-10-15)

- CourtListener REST search, `court=bap1`, queries "opening brief", "brief of appellant", "appellant" (type=r): 0 results (2026-10-14; "appellant" re-run 2026-10-15, HTTP 200, count 0). No "brief of appellee" or "answering brief" query was run against bap1 with a clean response; the appellant query above covers the same case dockets.
- CourtListener `court=bap1` dockets (type=d), query "appeal" (2026-10-15): 0 results. The bap1 court has 456 opinions indexed (type=o), but no RECAP documents or dockets.
- CourtListener unfiltered search, "BAP No." + "brief for appellant" (type=r, 2026-10-15): 22 hits, none a bap1 brief.
- CourtListener unfiltered search, "Bankruptcy Appellate Panel for the First Circuit" + "brief" (type=r, 2026-10-15): 168 hits, none a bap1 brief.
- CourtListener "BAP No. MB" and "BAP NO. EB" + "appellant" (2026-10-15): throttled (HTTP 429); not re-run after the throttle.
- Web search (standard, 2026-10-15) for bap1 briefs: BAP opinions with counsel captions ("on brief"), the quick reference, the local rules and the related-cases form. No brief.
- Web search (standard, 2026-10-14) for bap1 appellant briefs: BAP forms, local rules, quick reference, BAP guide, BAP opinions; no brief.
- bap1.uscourts.gov: the public site lists forms, rules, calendars and opinions; no briefs posted.

## Sources of rules (not exemplars)

- BAP guide and quick reference, bap1.uscourts.gov (see `../README.md`).
- Opinions on bap1 list counsel "on brief"; these are not exemplars of the brief.

## Resolved 2026-10-16

The earlier searches filtered on CourtListener court id `bap1`, which has opinions only. CourtListener files the First Circuit BAP's dockets under the circuit's court id `ca1`: BAP No. MW 23-03 is ca1 docket "23-3". Found with the CourtListener RECAP search API (`type=r`, `court=ca1`, `caseName:Blumsack`).

### FILED-EXAMPLE-blumsack-MW-23-03-answering-brief.pdf (primary exemplar)

- Court: United States Bankruptcy Appellate Panel for the First Circuit
- Case: *Blumsack v. Harrington, United States Trustee (In re Scott H. Blumsack, d/b/a Mass Athletics, LLC)*
- Docket: BAP No. MW 23-003 on the cover (the appellant's cover writes MW 23-03; CourtListener ca1 docket 23-3; ECF header "Case: 23-3, Document: 001147963, Entry ID: 2187132"); Bankruptcy Case No. 21-40248-EDK (Bankr. D. Mass.)
- Document: Brief of Appellee William K. Harrington, United States Trustee (36 PDF pages: cover, TOC and TOA in roman pages i-v, oral-argument statement p. vi, body pp. 1-27, certificate of compliance, statement regarding related cases)
- Filer: Appellee William K. Harrington, United States Trustee for Region 1 (a governmental party). Counsel: U.S. Department of Justice, Executive Office for United States Trustees (Ramona D. Elliott, Deputy Director/General Counsel; P. Matthew Sutko, Associate General Counsel; Frederick Gaston Hall, Trial Attorney, who signs) and the Office of the United States Trustee, Worcester (Richard T. King, Eric K. Bradford, Stephen E. Meunier).
- Date filed: June 26, 2023 (ECF header "Date Filed: 06/26/2023"; signature dated June 26, 2023)
- URL: https://storage.courtlistener.com/recap/gov.uscourts.ca1.2190/gov.uscourts.ca1.2190.1147963.0.pdf
- Date retrieved: 2026-10-16. The file is the original as downloaded, unmodified (sha256 a99075c50ee105a68416cec747c4656f5d97d02227f94c344e36aba1e01623a3).
- Text layer and fonts: born-digital (Acrobat PDFMaker 23 for Word, stamped by the judiciary's iText ECF header). Body in Garamond 14 pt (embedded), baseline pitch about 31.5 pt (double spaced); case names italic. Text extracts cleanly with `pdftotext`.
- No statement regarding interested parties: the filer is a governmental party, which 1st Cir. BAP L.R. 8014-1(a)(3) exempts.
- Used for: the transcription `samples/INPUT-blumsack-answering-brief.md`, the render `samples/OUTPUT-blumsack-answering-brief.pdf` and the overlay `samples/OVERLAY-blumsack-answering-brief.pdf`/`.txt`.

### Alternate exemplar (different filer, same case; not saved here)

- Brief for Appellant, Scott H. Blumsack, BAP No. MW 23-03, filed May 5, 2023 by Dmitry Lev, Law Offices of D. Lev, PC. URL https://storage.courtlistener.com/recap/gov.uscourts.ca1.2190/gov.uscourts.ca1.2190.1147641.0.pdf. It is the primary exemplar of `../opening-brief/` (saved there). Compared with this brief for the tier-2 choices recorded in `../README.md`.
- No second appellee's brief from another filer was found, so tier 2 is judged against two filers in one case, one opening and one answering brief.
