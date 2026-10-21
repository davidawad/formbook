# Exemplar source

Exemplar: `FILED-EXAMPLE-motion-brief-2.pdf` (19 pages, text-based, public).

It is two RECAP documents from one filing, concatenated in ECF order: ECF Doc. 8 (the motion, pages 1-3) then ECF Doc. 8-1 (the memorandum in support, pages 4-19).

- Court: United States Bankruptcy Court, N.D. West Virginia (wvnb).
- Case: *Sheehan v. Levine* (Martin P. Sheehan, Trustee of the bankruptcy estate of Geostellar, Inc., v. David A. Levine and Indeco Union), adversary proceeding No. 3:19-ap-00024; main case *In re Geostellar, Inc.*, No. 3:18-bk-0045. Adversary docket id 15649091 on CourtListener.
- Document: Defendants' Motion to Dismiss and Strike (Doc. 8) with Defendants' Memorandum in Support of Motion to Dismiss and Strike (Doc. 8-1), both filed 2019-08-23.
- Filer: David A. Levine and Indeco Union (defendants), by Cortland C. Putbrese, Dunlap Bennett & Ludwig PLLC.
- Date fetched: 2026-10-14 (`curl` from RECAP storage; no login).
- URLs (docket entries): https://www.courtlistener.com/docket/15649091/8/sheehan-v-levine/ (Doc. 8) and https://www.courtlistener.com/docket/15649091/8/1/sheehan-v-levine/ (Doc. 8-1, attachment 1).
- URLs (PDFs, CourtListener RECAP): https://storage.courtlistener.com/recap/gov.uscourts.wvnb.75581/gov.uscourts.wvnb.75581.8.0.pdf (motion, 3 pp.) and https://storage.courtlistener.com/recap/gov.uscourts.wvnb.75581/gov.uscourts.wvnb.75581.8.1_1.pdf (memorandum, 16 pp.).
- Found by: CourtListener search API (v4, `type=rd`, `court=wvnb`, query `"memorandum in support" "motion to dismiss"`). Both documents are marked available.

## Why this one

It is a filed motion to dismiss, with its memorandum, in this court's adversary proceeding. It has the adversary caption, a relief paragraph, a memorandum with headings, footnotes, a signature block and a certificate of service. It is text-based, so the transcription and the overlay use the real words.

## Caveats for the sample

- `usage/INPUT-motion-brief-2.md` is a verbatim transcription of both documents, including the filer's own typos (e.g. "MARTING" in the caption, "failed to alleged" in the conclusion). The authorities are the filer's and were not checked by us.
- The filed caption has no chapter line and no judge line. The template's chapter line is therefore optional now, and the sample omits it.
- The filed caption label is "Civil No." for the adversary number and "BK. NO." for the main case; the template prints "Adv. Pro. No." and "Case No.". The overlay shows the difference, and it is left as a template convention.

## Other candidates considered (not used)

- Storj Labs, Inc. (2026): Doc. 131, "Brief/Memorandum in Support of Motion to Strike and Dismiss", 14 pp., available. Not used because it is a standalone memorandum with no motion in the same document. It is the best candidate for a second filer, and one 2026 filing would help the newer-practice comparison.
- Patel (adv. 2020, *Carrie Goodwin Fenwick for Mayur Patel*): "Brief/Memorandum in Support" to Doc. 12 (motion to dismiss adversary proceeding). The RECAP entry is not available (not in storage).
- CIT Bank / One West Bank (adv. 2016, Doc. 46): memorandum in support of a motion to dismiss. Not available in RECAP storage.
- Emerald Grande (2021, Doc. 62): memorandum in support of a motion for summary judgment. Available, but it is a different doc type.

## Searches tried earlier (2026-10-14, first pass)

These found no filed motion with memorandum, and are kept for the record:

1. WebSearch: "Bankruptcy Court" "Northern District of West Virginia" motion memorandum pdf courtlistener wvnb. Court forms, the 2003 local rules, a 2008 Wheeling hearing calendar. No motion PDF.
2. WebSearch (extended): "Northern District of West Virginia" "motion to dismiss" adversary "memorandum in support" pdf, 2023 to 2025. Opinions only (Gorman, Johns, Russell).
3. WebFetch: CourtListener docket search (HTTP 403 at that time); InForuptcy and courtrules.net (HTTP 403).

The CourtListener search API, which the first pass did not use, is what found this exemplar.
