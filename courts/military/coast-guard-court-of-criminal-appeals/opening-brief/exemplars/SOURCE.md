# Exemplar source: uscgcoca opening brief

**Exemplar found (fourth pass, 2026-10-16, bead fb-595.20.21).** The appellant's Assignment of Error and Brief in *United States v. Steen*, published (redacted) by the CGCCA on its Appellate Briefs page; fetched from the Internet Archive because uscg.mil returns 403 to this box.

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-steen-1464-opening-brief.pdf` (8 pages, an extract; see page map) |
| Case | *United States v. Boatswain's Mate Third Class Justin D. Steen, U.S. Coast Guard*, CGCCA Dkt. 1464, Case No. SP 24978 |
| Document | "Appellant's Assignment of Error and Brief", 31 pp. as published (redacted; the published copy ends at the Conclusion, with no signature or certificate page) |
| Filer | Appellate defense counsel for the appellant (signature page not in the published copy) |
| Date filed | Dated 4 April 2019 (caption) |
| URL fetched from | `https://web.archive.org/web/20200919035023id_/https://www.uscg.mil/Portals/0/Headquarters/Legal/cca/Court_of_Criminal_Appeals_Opinions/AppellantBriefs/US%20v%20BM3%20Steen%20AOE%20and%20Brief_Redacted.pdf?ver=2019-06-06-154540-357` (listed on the court's page `https://www.uscg.mil/Resources/Legal/Court-of-Criminal-Appeals/Court-of-Criminal-Appeals-Appellate-Briefs/`, Wayback capture 20190820115734) |
| Date fetched | 2026-10-16 |
| Public record | Yes: published by the court, redacted by it (the witness's name). |
| PDF type | Acrobat Pro DC Paper Capture with ClearScan (OCR text; OCR errors such as "Comt" for "Court"). |

Page map of the extract (`pdfseparate` / `pdfunite`):

| Extract p. | Source p. | Content |
|---|---|---|
| 1 | 1 | Caption, "TO THE HONORABLE ...", Statement of the Case and Jurisdiction |
| 2-3 | 2-3 | Statement of Facts (A. Background; B. the M.R.E. 404(b) motion, with a block quotation; C. start) |
| 4 | 10 | Summary of Argument |
| 5 | 11 | Issues Presented I and II |
| 6 | 12 | Argument I: Standard of review, Analysis (numbered quotation), heading A |
| 7-8 | 30-31 | End of Argument II (C.), Conclusion |

Source pp. 4-9 and 13-29 are left out. `samples/INPUT-steen-opening-brief.md` transcribes exactly the extracted pages.

## First pass (2026-10-14): superseded record

At the time (superseded by the fourth pass): BLOCKED, no public exemplar.

No filed opening brief (Assignments of Error and Brief on Behalf of Appellant) from the U.S. Coast Guard Court of Criminal Appeals was found, so there is no `FILED-EXAMPLE-*.pdf` here.

- Case name, docket no., filer, date filed: none
- URL fetched from: none
- Date fetched: n/a

## Searches tried (2026-10-14)

Pass 1:

1. Web search: "Coast Guard Court of Criminal Appeals appellant's brief pdf filed opening brief". Returned CAAF filings (Lopez, Fernandez amicus) and CGCCA opinions on media.defense.gov. None is an appellant's brief from the CGCCA.
2. Web search: CGCCA Rules of Appellate Procedure, brief format. Returned the rules index only.
3. Web search: CourtListener uscgcoca brief. No CourtListener or CGCCA results.
4. WebFetch of CourtListener search (`q="Coast Guard Court of Criminal Appeals" brief`): HTTP 403.
5. WebFetch of the uscg.mil Appellate Briefs index (`/Resources/Legal/Court-of-Criminal-Appeals/Court-of-Criminal-Appeals-Appellate-Briefs/`): HTTP 403. A search snippet of that index lists the CGCCA's filings as "Appellant's Assignments of Error", "Government Answer" and "Appellant's Reply", not "opening brief" / "answering brief". PDFs were not reachable.
6. Web search for "Assignments of Error" appellant brief on jag.navy.mil / media.defense.gov: no appellant brief PDF returned.

Pass 2 (same day):

7. Web search: `"Coast Guard Court of Criminal Appeals" "Assignments of Error" appellant brief pdf`. Returned CGCCA opinions on media.defense.gov, the 32 CFR 150 App. B format, and CAAF amicus briefs. No CGCCA party brief.
8. Web search: `"Brief on Behalf of Appellant" "Coast Guard Court of Criminal Appeals" pdf`. Returned a format guide on an unofficial mirror (`mirror.hep.gg`, not used) and CAAF material. No CGCCA appellant brief.
9. Web search: `"IN THE UNITED STATES COAST GUARD COURT OF CRIMINAL APPEALS" "BRIEF ON BEHALF OF APPELLANT" "Assignments of Error" Dkt`. Returned CGCCA opinions (Thibodeau, Naputi) and 32 CFR 150 App. B. No brief.
10. WebFetch of the CourtListener API v4 search (`type=r`, `court=uscgcoca`, query "Coast Guard Court of Criminal Appeals" brief): **0 results**, `document_count` 0.
11. WebFetch of the CourtListener web search for RECAP documents (`type=r`): HTTP 403.
12. WebFetch of the uscg.mil CGCCA-Orders page: HTTP 403.
13. WebFetch of the Navy JAG "Coast Guard Court Filings & Records" pages (`/military-justice/uscg-filings-records/` and `/usgc-filings-records/`): the records table is empty in the fetched capture (the only document link is a trial docket PDF). The RSS feed behind the table (`/feed/tables/filings-records-uscg/`) returned HTTP 500.
14. Web search for jag.navy.mil documents with "assignments of error": no appellate filing PDF returned.
15. Web search for CAAF briefs in Coast Guard cases (`armfor.uscourts.gov` "On Appeal from the United States Coast Guard Court of Criminal Appeals"). See the near-miss below.

## Near-miss, not used

- CAAF, *United States v. Lopez*, USCA Dkt. No. 24-0226/CG, government appellee brief: `https://www.armfor.uscourts.gov/briefs/2024Term/Lopez240226AppelleeBrief.pdf`. It is a Coast Guard case, but it was filed in the Court of Appeals for the Armed Forces, not this court, and it is a government brief, not an appellant's opening brief. It does not qualify as an exemplar for this doc type. It was not downloaded.
- CAAF, *United States v. Fernandez*, USCA Dkt. No. 24-0101/AF, Coast Guard OLADS amicus brief: wrong court and wrong filer. Not used.

## Not yet tried (next steps for a person with access)

- The uscg.mil CGCCA Appellate Briefs index and Orders page, from a browser or a box that can reach uscg.mil. Both returned HTTP 403 to this box.
- The Navy JAG Coast Guard filings table, from a browser (the table is populated client-side and was empty in this capture).
- A request to the CGCCA clerk for a public copy of a redacted appellant's brief.

## Pass 3 (2026-10-15, bead fb-595.20.5)

The same routes as the answering-brief pass 3 (`../../answering-brief/exemplars/SOURCE.md`, items 15 to 21) were run for the opening brief. Results:

- CourtListener API v4, `type=r&court=uscgcoca`: 0 results. Unfiltered RECAP search for "Coast Guard Court of Criminal Appeals" with "brief": no CGCCA docket. Anonymous limit 5/min; no API key on this box.
- WebSearch (standard), "Brief on Behalf of Appellant" "Assignments of Error" pdf: CAAF Fernandez amicus, 32 CFR 150 App. B, and CGCCA opinions (Ryder, Crawford, King, Naputi, Gogo). No CGCCA appellant's brief.
- WebSearch (standard), "ASSIGNMENTS OF ERROR" "Appellant" brief Docket 2025: CGCCA opinions Ducker (No. 1508, 22 Jul 2025) and Ray (No. 1498), both on uscg.mil opinion pages. Opinions, not briefs. Older briefs quoted in opinions (Tamayo No. 1425, Coker No. 1188, Gogo No. 1292) are on media.defense.gov as opinions.
- The uscg.mil Appellate Briefs index lists the CGCCA's filings by case, and the search snippet shows "Assignments of Error" links (see answering-brief pass 3, item 20). Opening it returned HTTP 403, as did the rules PDF and media.defense.gov, even with a browser user agent.

## Fourth pass (2026-10-16, bead fb-595.20.21)

New routes only. Result: **found**. The court's own "Appellate Briefs" page and its PDFs are archived in the Internet Archive, which this box can reach although uscg.mil returns 403.

1. Live `https://www.uscg.mil/Resources/Legal/Court-of-Criminal-Appeals/Court-of-Criminal-Appeals-Appellate-Briefs/` with curl and a browser User-Agent: HTTP 403 (unchanged).
2. Wayback CDX for `uscg.mil/Resources/Legal/Court-of-Criminal-Appeals*`: the briefs index is archived once, `20190820115734`. Fetched it: it lists Appellant's Assignments of Error / Government Answer / Appellant's Reply for Steen, Harpole, Guzman, Pacheco, Rodriguez, Livingstone, Hernandez and Rogers, linking to `uscg.mil/Portals/0/Headquarters/Legal/cca/Court_of_Criminal_Appeals_Opinions/AppellantBriefs/`.
3. Wayback CDX for that `AppellantBriefs/` folder: 45 PDF captures (2020-2021), adding Goodell II, Schwartz, Stoddard-Castro, Piccininno, Flores (Art. 62), Olsen, Tucker (habeas) and Weiser. All fetched with the raw `id_` form (Wayback rate-limits; retried with backoff). 38 of 45 downloaded; Weiser AOE, Harpole AOE, Steen reply, Livingstone AOE, Rogers answer, Piccininno answer and Flores response did not download (timeouts).
4. Triage: Goodell II AOE has a broken text layer (no ToUnicode; extracts as garbage), so the overlay cannot pair it. Schwartz, Stoddard-Castro and Piccininno AOEs are 2-4 page merits-type filings. 2017-2018 filings (Hernandez, Rodriguez, Guzman, Livingstone, Pacheco) predate the 1 January 2019 rules. **Steen** (Dkt. 1464) is the newest full pair under the JRAP-era rules with a usable text layer: the AOE (dated 4 April 2019, 31 pp., Acrobat ClearScan OCR) and the Government answer (6 May 2019, 19 pp., text layer). Used for both doc types; different filers (defense / government).
5. Rules: Wayback CDX for `uscg.mil/Portals/0/Headquarters/Legal/cca/*` gave the rules PDFs. Fetched `CGCCA Rules of Appellate Procedure with JRAP (March 2025).pdf` (capture 20250428115614, 33 pp.), `Coast Guard Rules of Appellate Procedure with JRAP (effective 1Jan19).pdf` (20191130041821, 28 pp.) and `Joint Rules of Appellate Procedure (May 2024).pdf` (20240705065445). Rule 17.1 (format), 17.2 (content), 17.3 (length, word certificate) and 14 (signature) were read; see `../README.md`.

Not used: the other 37 downloaded filings (older rules, broken text, merits-only, or other doc types: replies, habeas, Art. 62).
