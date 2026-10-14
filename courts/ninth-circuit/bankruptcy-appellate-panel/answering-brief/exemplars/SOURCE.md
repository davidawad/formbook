# Exemplars: bap9 answering-brief

**No exemplar found (2026-10-14).** This folder holds no filed PDF. The overlay cannot run (`tools/overlay.sh` exits 1: "no exemplar pdf").

Searches tried, all without a BAP filing of this type:

- CourtListener REST (`https://www.courtlistener.com/api/rest/v4/search/?type=r&court=bap9`): `q=brief`, `q="opening brief"`: 0 results. The bap9 court has no RECAP documents in the index.
- CourtListener REST, unfiltered phrase searches: `"Appellant's Opening Brief" "Bankruptcy Appellate Panel"`, `"Appellee's Answering Brief" "BAP No"`, `"Reply Brief" "Bankruptcy Appellate Panel"`. Results were other courts only (ca9, cand, caed, orb, cacb). Some requests were throttled and retried.
- Web search (standard and extended): BAP rules and manual; "Ninth Circuit Bankruptcy Appellate Panel appellant's opening brief pdf"; "courtlistener bap9 opening brief"; "\"Bankruptcy Appellate Panel of the Ninth Circuit\" \"Appellant's Opening Brief\" pdf". Results: the BAP Litigants Manual (Rev'd 01/26), the 2024 manual, a 2020 published memorandum (caption form only), a 2017 BAP-dismissal memorandum. No brief.
- Not checked: www.bap9.uscourts.gov filings pages; PACER (not accessible from this box).

If a filing is found later, add the PDF as `exemplars/FILED-EXAMPLE-<short-case>-<docket>-answering-brief.pdf` and fill in this file with: URL fetched from, case name, docket number, filer, date filed, date fetched.

Status: BLOCKED: no exemplar.
