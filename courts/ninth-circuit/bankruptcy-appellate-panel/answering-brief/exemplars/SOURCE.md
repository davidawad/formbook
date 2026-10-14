# Exemplars: bap9 answering-brief

**No exemplar found (last searched 2026-10-14).** This folder holds no filed PDF. The overlay cannot run (`tools/overlay.sh` exits 1: "no exemplar pdf").

Searches tried, all without a BAP appellee's answering brief:

- CourtListener REST (`https://www.courtlistener.com/api/rest/v4/search/?type=r&court=bap9`): `q=brief`, `q="opening brief"`: 0 results. `type=rd&court=bap9` with `q="answering brief"` and `q="reply brief"`: 0 results.
- CourtListener REST, unfiltered phrase searches: `"Appellant's Opening Brief" "Bankruptcy Appellate Panel"`, `"Appellee's Answering Brief" "BAP No"`, `"Reply Brief" "Bankruptcy Appellate Panel"`. Results were other courts only (ca9, cand, caed, orb, cacb).
- CourtListener `type=rd`, `q=Meridian Stadtmueller`: 380 hits, all bankruptcy-court docket entries (casb 3:16-bk-00629), not appellate briefs.
- Web search (standard and extended): BAP rules and manual; "Ninth Circuit Bankruptcy Appellate Panel appellant's opening brief pdf"; "courtlistener bap9 opening brief"; "\"Bankruptcy Appellate Panel of the Ninth Circuit\" \"Appellant's Opening Brief\" pdf"; "\"Appellee's Answering Brief\" \"Bankruptcy Appellate Panel of the Ninth Circuit\""; "Kretsch answering brief Stadtmueller"; "cacttc meridian bap brief"; "Tracht Gut bap briefs"; "Ninth Circuit BAP chapter 7 trustee appellee brief 2015-2024". Results: the Litigants Manual, BAP rules, Ninth Circuit BAP memoranda and calendars, pro se forms, and the BAP opinion in the Meridian case (County of Imperial Treasurer-Tax Collector v. Stadtmueller, filed Feb. 3, 2017). No answering brief.
- The Meridian case (BAP No. SC-16-1227) is the one BAP9 case with a public brief (the appellant's opening brief, now `../../opening-brief/exemplars/`). The trustee's answering brief in that case was not found. The CSAC amicus motion in that case is hosted at csac.counties.org, but the link returned an HTML page, not the file.
- Not checked: www.bap9.uscourts.gov case-document pages; PACER (not accessible from this box).

If a filing is found later, add the PDF as `exemplars/FILED-EXAMPLE-<short-case>-<docket>-answering-brief.pdf` and fill in this file with: URL fetched from, case name, docket number, filer, date filed, date fetched.

Status: BLOCKED: no public exemplar.
