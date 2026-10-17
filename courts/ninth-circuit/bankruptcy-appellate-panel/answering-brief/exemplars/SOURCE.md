# Exemplars: bap9 answering-brief

**Resolved 2026-10-16: exemplar found.** See "Resolved 2026-10-16" at the end of this file. The earlier status lines below ("No exemplar found", "BLOCKED") are kept as search history; they are superseded.

Searches tried, all without a BAP appellee's answering brief:

- CourtListener REST (`https://www.courtlistener.com/api/rest/v4/search/?type=r&court=bap9`): `q=brief`, `q="opening brief"`: 0 results. `type=rd&court=bap9` with `q="answering brief"` and `q="reply brief"`: 0 results.
- CourtListener REST, unfiltered phrase searches: `"Appellant's Opening Brief" "Bankruptcy Appellate Panel"`, `"Appellee's Answering Brief" "BAP No"`, `"Reply Brief" "Bankruptcy Appellate Panel"`. Results were other courts only (ca9, cand, caed, orb, cacb).
- CourtListener `type=rd`, `q=Meridian Stadtmueller`: 380 hits, all bankruptcy-court docket entries (casb 3:16-bk-00629), not appellate briefs.
- Web search (standard and extended): BAP rules and manual; "Ninth Circuit Bankruptcy Appellate Panel appellant's opening brief pdf"; "courtlistener bap9 opening brief"; "\"Bankruptcy Appellate Panel of the Ninth Circuit\" \"Appellant's Opening Brief\" pdf"; "\"Appellee's Answering Brief\" \"Bankruptcy Appellate Panel of the Ninth Circuit\""; "Kretsch answering brief Stadtmueller"; "cacttc meridian bap brief"; "Tracht Gut bap briefs"; "Ninth Circuit BAP chapter 7 trustee appellee brief 2015-2024". Results: the Litigants Manual, BAP rules, Ninth Circuit BAP memoranda and calendars, pro se forms, and the BAP opinion in the Meridian case (County of Imperial Treasurer-Tax Collector v. Stadtmueller, filed Feb. 3, 2017). No answering brief.
- The Meridian case (BAP No. SC-16-1227) is the one BAP9 case with a public brief (the appellant's opening brief, now `../../opening-brief/exemplars/`). The trustee's answering brief in that case was not found. The CSAC amicus motion in that case is hosted at csac.counties.org, but the link returned an HTML page, not the file.
- Not checked: www.bap9.uscourts.gov case-document pages; PACER (not accessible from this box).

If a filing is found later, add the PDF as `exemplars/FILED-EXAMPLE-<short-case>-<docket>-answering-brief.pdf` and fill in this file with: URL fetched from, case name, docket number, filer, date filed, date fetched.

Status: BLOCKED: no public exemplar.

## Re-search 2026-10-15 (bead fb-595.20.9)

Still no exemplar. Searches this session:

- CourtListener REST, anonymous (no API token on this box; unthrottled requests are limited to 5/min, so each query was paced). With the court filter, `court=bap9`: `type=rd` `q="answering brief"` = 0; `type=rd` `q="reply brief"` = 0; `type=r` `q=brief` = 0.
- CourtListener `type=rd` `q="Bankruptcy Appellate Panel" "appellee's answering brief"`: 2 hits, both other courts (a 2014 ca9 brief, a 2019 bankruptcy docket). `type=rd` `q="SC-16-1227"`: 0.
- Web search (standard, extended): "appellee's answering brief" with BAP number; BAP-caption answering briefs 2023-2025. Results: BAP memoranda (SC-25-1091, CC-25-1037; no briefs), the Litigants Manual, and the Meridian CSAC amicus motion (SC-16-1227, dated 2016-10-14), which supports the appellant and is not an answering brief.
- Ruled out: Hujazi v. Wirum (ca9 No. 14-1030, a Ninth Circuit appeal, not the BAP). **Corrected 2026-10-16: this was wrong.** Hujazi v. Wirum is BAP No. NC-14-1030 (the filed answering brief is captioned "United States Bankruptcy Appellate Panel of the Ninth Circuit ... BAP No. NC-14-1030"). CourtListener files BAP9 dockets under the court id `ca9` with the short number (ca9 "14-1030" = BAP No. NC-14-1030; ca9 "25-1042" = BAP No. CC-25-1042), which is why the `court=bap9` searches above returned nothing. cacttc.org hosts only the Meridian appellant's opening brief (already in `../../opening-brief/exemplars/`).

Status: BLOCKED: no public exemplar (re-confirmed 2026-10-15).
## Re-search 2026-10-15 (batch bap9, bead fb-595.20.25 / fb-595.20.26)

Still no exemplar. Searches this pass: CourtListener REST (anonymous, `type=r`): `"answering brief" "BAP No"` (150 hits, all other courts: ca9, nvd, ded); `"Appellee's Answering Brief" Stadtmueller` (0); `"Imperial County" "answering brief" Stadtmueller` (0). Web search (standard): `"Bankruptcy Appellate Panel of the Ninth Circuit" "Appellee's Answering Brief" pdf`: returned the Litigants Manual and Ninth Circuit memoranda only, no brief. Status unchanged: BLOCKED: no public exemplar.

## Resolved 2026-10-16 (bead fb-595.20.22)

### FILED-EXAMPLE-klein-CC-25-1042-answering-brief.pdf (primary)

- URL: https://storage.courtlistener.com/recap/gov.uscourts.ca9.22113/gov.uscourts.ca9.22113.8.0.pdf
- Court: United States Bankruptcy Appellate Panel of the Ninth Circuit
- Case: *Leslie Klein, as Trustee of the Marital Deduction Trust of Erika Klein and Trustee of the Credit Trust of Erika Klein v. Bradley D. Sharp, Chapter 11 Trustee of Leslie Klein*; appeal from Bankr. C.D. Cal. No. 2:23-bk-10990 (Hon. Neil W. Bason)
- Docket: BAP No. CC-25-1042 (cover: "Case CC-25-1042"; CourtListener docket ca9 "25-1042", entry 8)
- Document: Appellee's Answering Brief, 15 PDF pages (cover, TOC, TOA, 9 body pages with signature, compliance certificate, BAP R. 8015(a)-1(a) interested-parties certification, BAP R. 8015(a)-1(b) related-cases certification). No certificate of service in the file.
- Filer: appellee Bradley D. Sharp, Chapter 11 trustee. Counsel: Jeffrey W. Dulberg, John W. Lucas, Jeffrey P. Nolan, Pachulski Stang Ziehl & Jones LLP (Los Angeles); signed by John W. Lucas.
- Date filed: May 2, 2025 (dated on the signature page and certificates; the PDF has no ECF header; PDF creation date 2025-05-02)
- Date retrieved: 2026-10-16. Saved unmodified (sha256 `e06753a8ef162e477aa5f09848aa60b15bf62d5eb436b80bea4f6f94e4fb8fdd`).
- Format: born-digital (Word, Acrobat Distiller 25.0); embedded Times New Roman (regular, bold, italic) subsets; text layer extracts cleanly. 14 pt, double spaced.
- How found: CourtListener RECAP search API (`type=r`). BAP dockets are filed under the circuit's court id, `ca9`, with the short number: ca9 docket "25-1042" is BAP No. CC-25-1042. Searches restricted to `court=bap9` (all earlier passes) return nothing for that reason.
- Used for: the transcription `samples/INPUT-klein-answering-brief.md` (whole body), the render `samples/OUTPUT-klein-answering-brief.pdf`, the overlay `samples/OVERLAY-klein-answering-brief.pdf` and `.txt`.

### Alternate exemplar (different filer, tier 2), not saved

- *Hujazi v. Wirum (In re North Oxford Bright Horizons Group)*, BAP No. NC-14-1030, "Answering Brief", 16 PDF pages, filed 10/21/2014 (ECF header "Case: 14-1030, Document: 29, Filed: 10/21/2014"). Filer: appellee Andrea A. Wirum, former chapter 7 trustee; counsel Charles P. Maher, McKenna Long & Aldridge LLP (San Francisco). URL: https://storage.courtlistener.com/recap/gov.uscourts.ca9.18072/gov.uscourts.ca9.18072.29.0.pdf. Born-digital Word file (Times New Roman, not embedded). Viewed pages 1, 2, 4, 5, 6, 7 at 60 dpi and compared: cover layout (court name first, a boxed caption with "In re: North Oxford Bright Horizons Group, Debtor" and the BAP and bankruptcy numbers at the right), TOC (sub-headings indented under their section), TOA, body headings (left-aligned, numbered "I.", not centered), certifications placed before the TOC.
- Other candidates seen in the download set, not used: `gov.uscourts.ca9.22314.14.0.pdf` (*Andrew v. Official Committee of Unsecured Creditors*, BAP No. NC-25-1238) and `gov.uscourts.ca9.22108.8.0.pdf` (*Second Amended Klein Living Trust v. Sharp*, BAP No. CC-25-1037, 51 pp): both Pachulski Stang Ziehl & Jones, the same firm as the primary, so not a different filer.
