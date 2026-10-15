# Exemplars: bap9 reply-brief

**No exemplar found (last searched 2026-10-14).** This folder holds no filed PDF. The overlay cannot run (`tools/overlay.sh` exits 1: "no exemplar pdf").

Searches tried, all without a BAP appellant's reply brief:

- CourtListener REST (`https://www.courtlistener.com/api/rest/v4/search/?type=r&court=bap9`): `q=brief`, `q="opening brief"`: 0 results. `type=rd&court=bap9` with `q="reply brief"` and `q="answering brief"`: 0 results.
- CourtListener REST, unfiltered phrase searches: `"Reply Brief" "Bankruptcy Appellate Panel"`, `"Appellant's Reply Brief" "BAP No"`. Results were other courts only. The Ninth Circuit appeal 15-56800 (a bankruptcy appeal heard by the court of appeals, not the BAP) is not this court.
- CourtListener `type=rd`, `q=Meridian Stadtmueller`: 380 hits, all bankruptcy-court docket entries (casb 3:16-bk-00629), not appellate briefs.
- Web search (standard and extended): BAP rules and manual; "\"Bankruptcy Appellate Panel\" \"Ninth Circuit\" \"reply brief\" \"BAP No\" pdf"; "\"County of Imperial\" \"reply brief\" \"RW Meridian\""; "\"Appellant's Reply Brief\" \"Bankruptcy Appellate Panel\" \"BAP No.\" pdf"; BAP tax-sale and stay-violation appeals. Results: the Litigants Manual, BAP rules, Ninth Circuit memoranda with BAP captions, a BAP 10 opinion (not this court), and the BAP opinion in the Meridian case (filed Feb. 3, 2017). No reply brief.
- The Meridian case (BAP No. SC-16-1227) is the one BAP9 case with a public brief (the appellant's opening brief, now `../../opening-brief/exemplars/`). The County's reply brief in that case was not found.
- Not checked: www.bap9.uscourts.gov case-document pages; PACER (not accessible from this box).

If a filing is found later, add the PDF as `exemplars/FILED-EXAMPLE-<short-case>-<docket>-reply-brief.pdf` and fill in this file with: URL fetched from, case name, docket number, filer, date filed, date fetched.

Status: BLOCKED: no public exemplar.

## Re-search 2026-10-15 (bead fb-595.20.9)

Still no exemplar. Searches this session:

- CourtListener REST, anonymous (no API token on this box; queries paced at 5/min). With the court filter, `court=bap9`: `type=rd` `q="reply brief"` = 0; `type=rd` `q="answering brief"` = 0; `type=r` `q=brief` = 0.
- CourtListener `type=rd` `q="SC-16-1227"`: 0; with `"answering"`: 0.
- Web search (standard, extended): "appellant's reply brief" with BAP number and the Meridian case. Results: BAP memoranda and manuals; the Meridian CSAC amicus motion (SC-16-1227, in support of the appellant; not a reply brief). No reply brief.
- Ruled out: Hujazi v. Wirum (ca9 No. 14-1030, a Ninth Circuit appeal, not the BAP).

Status: BLOCKED: no public exemplar (re-confirmed 2026-10-15).
## Re-search 2026-10-15 (batch bap9, bead fb-595.20.25 / fb-595.20.26)

Still no exemplar. Searches this pass: CourtListener REST (anonymous, `type=r`): `"Reply Brief" "Stadtmueller" "BAP"` (6 hits, all district/circuit dockets, none an appellate brief of this court); `"Appellant's Reply Brief" "BAP No"` covered in the earlier pass. Web search (standard): `"Bankruptcy Appellate Panel" Ninth Circuit "Appellant's Reply Brief" BAP No. pdf`: returned the Litigants Manual, BAP rules and memoranda; the only reply brief hit (NCLC, McAdory) is a Ninth Circuit brief, not this court. Status unchanged: BLOCKED: no public exemplar.
