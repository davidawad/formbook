# Exemplars: bap9 reply-brief

**Resolved 2026-10-16: exemplar found.** See "Resolved 2026-10-16" at the end of this file. The earlier status lines below ("No exemplar found", "BLOCKED") are kept as search history; they are superseded.

Searches tried, all without a BAP appellant's reply brief:

- CourtListener REST (`https://www.courtlistener.com/api/rest/v4/search/?type=r&court=bap9`): `q=brief`, `q="opening brief"`: 0 results. `type=rd&court=bap9` with `q="reply brief"` and `q="answering brief"`: 0 results.
- CourtListener REST, unfiltered phrase searches: `"Reply Brief" "Bankruptcy Appellate Panel"`, `"Appellant's Reply Brief" "BAP No"`. Results were other courts only. The Ninth Circuit appeal 15-56800 (a bankruptcy appeal heard by the court of appeals, not the BAP) is not this court.
- CourtListener `type=rd`, `q=Meridian Stadtmueller`: 380 hits, all bankruptcy-court docket entries (casb 3:16-bk-00629), not appellate briefs.
- Web search (standard and extended): BAP rules and manual; "\"Bankruptcy Appellate Panel\" \"Ninth Circuit\" \"reply brief\" \"BAP No\" pdf"; "\"County of Imperial\" \"reply brief\" \"RW Meridian\""; "\"Appellant's Reply Brief\" \"Bankruptcy Appellate Panel\" \"BAP No.\" pdf"; BAP tax-sale and stay-violation appeals. Results: the Litigants Manual, BAP rules, Ninth Circuit memoranda with BAP captions, a BAP 10 opinion (not this court), and the BAP opinion in the Meridian case (filed Feb. 3, 2017). No reply brief.
- The Meridian case (BAP No. SC-16-1227) is the one BAP9 case with a public brief (the appellant's opening brief, now `../../opening-brief/usage/`). The County's reply brief in that case was not found.
- Not checked: www.bap9.uscourts.gov case-document pages; PACER (not accessible from this box).

If a filing is found later, add the PDF as `usage/SAMPLE-<short-case>-<docket>-reply-brief.pdf` and fill in this file with: URL fetched from, case name, docket number, filer, date filed, date fetched.

Status: BLOCKED: no public exemplar.

## Re-search 2026-10-15 (bead fb-595.20.9)

Still no exemplar. Searches this session:

- CourtListener REST, anonymous (no API token on this box; queries paced at 5/min). With the court filter, `court=bap9`: `type=rd` `q="reply brief"` = 0; `type=rd` `q="answering brief"` = 0; `type=r` `q=brief` = 0.
- CourtListener `type=rd` `q="SC-16-1227"`: 0; with `"answering"`: 0.
- Web search (standard, extended): "appellant's reply brief" with BAP number and the Meridian case. Results: BAP memoranda and manuals; the Meridian CSAC amicus motion (SC-16-1227, in support of the appellant; not a reply brief). No reply brief.
- Ruled out: Hujazi v. Wirum (ca9 No. 14-1030, a Ninth Circuit appeal, not the BAP). **Corrected 2026-10-16: this was wrong.** Hujazi v. Wirum is BAP No. NC-14-1030 (the filed answering brief is captioned "United States Bankruptcy Appellate Panel of the Ninth Circuit ... BAP No. NC-14-1030"). CourtListener files BAP9 dockets under the court id `ca9` with the short number (ca9 "14-1030" = BAP No. NC-14-1030; ca9 "25-1042" = BAP No. CC-25-1042), which is why the `court=bap9` searches above returned nothing.

Status: BLOCKED: no public exemplar (re-confirmed 2026-10-15).
## Re-search 2026-10-15 (batch bap9, bead fb-595.20.25 / fb-595.20.26)

Still no exemplar. Searches this pass: CourtListener REST (anonymous, `type=r`): `"Reply Brief" "Stadtmueller" "BAP"` (6 hits, all district/circuit dockets, none an appellate brief of this court); `"Appellant's Reply Brief" "BAP No"` covered in the earlier pass. Web search (standard): `"Bankruptcy Appellate Panel" Ninth Circuit "Appellant's Reply Brief" BAP No. pdf`: returned the Litigants Manual, BAP rules and memoranda; the only reply brief hit (NCLC, McAdory) is a Ninth Circuit brief, not this court. Status unchanged: BLOCKED: no public exemplar.

## Resolved 2026-10-16 (bead fb-595.20.22)

### FILED-EXAMPLE-reply-brief.pdf (primary)

- URL: https://storage.courtlistener.com/recap/gov.uscourts.ca9.22121/gov.uscourts.ca9.22121.20.0.pdf
- Court: United States Bankruptcy Appellate Panel of the Ninth Circuit
- Case: *Christopher Beavor, et al. v. Reno City Center Owner, LLC, et al. (In re Reno City Center Owner, LLC)*; appeal from Bankr. D. Nev. No. 24-50152-hlb (Hon. Hilary L. Barnes)
- Docket: BAP case 25-1050 (cover: "Case No. 25-1050"; CourtListener docket ca9 "25-1050", entry 20)
- Document: "Appellants' Reply to Brief of Appellee Reno City Center Owner, LLC", 23 PDF pages (cover, TOC, 2-page TOA, 15 body pages, signature page, compliance certificate under FRBP 8015(h), certificate of service with service list).
- Filer: appellants Christopher Beavor, et al. Counsel: Brian L. Davidoff and Cole F. Nicholas, Greenberg Glusker Fields Claman & Machtinger LLP (Los Angeles); signed by Brian L. Davidoff.
- Date filed: August 29, 2025 (dated on the signature page; the certificate of service states it was filed electronically that day; PDF creation date 2025-08-29)
- Date retrieved: 2026-10-16. Saved unmodified (sha256 `ffafb5a0d8f42b78671fcdde1eafc6041d15c64197dba3383b0bfda556bf136e`).
- Format: born-digital (Word, Acrobat Distiller 24.0); embedded Times New Roman PS (regular, bold, italic) and Century Schoolbook italic subsets; text layer extracts cleanly. 14 pt, double spaced, with footnotes and block quotations.
- How found: CourtListener RECAP search API (`type=r`). BAP dockets are filed under the circuit's court id, `ca9`, with the short number (ca9 "25-1050" here).
- Why this one: counsel-filed, born-digital, complete, with three heading levels, footnotes and block quotations. Its title names the plural appellants and the brief it replies to, which showed the template's fixed title could not identify the filing parties (see `../README.md`).
- Used for: the transcription `usage/INPUT-reply-brief.md` (abridged), the render `usage/OUTPUT-reply-brief.typst.pdf`, the overlay `usage/OVERLAY-beavor-reply-brief.pdf` and `.txt`.

### Alternate exemplars (different filers, tier 2), not saved

- *Moehling v. Select Portfolio Servicing, Inc.*, BAP No. SC-26-1081, "Appellant's Reply Brief", 21 PDF pages. Filer: appellant Steven M. Moehling, pro se (signed "/s/ Steven M. Moehling, Appellant, Pro Se"). URL: https://storage.courtlistener.com/recap/gov.uscourts.ca9.22437/gov.uscourts.ca9.22437.12.0.pdf. Born-digital (PDF creation date 2026-06-19). Viewed pages 1-2 at 60 dpi: cover with court name first, "In re: Steven M. Moehling, Debtor" caption with the BAP and bankruptcy numbers at the right, then the parties; TOC with a running header, numbered level-1 entries.
- *Reznick v. U.S. Trustee*, BAP No. CC-22-1128, Appellant's Reply Brief, 16 PDF pages, pro per, a scan (OmniPage OCR). URL: https://storage.courtlistener.com/recap/gov.uscourts.ca9.21514/gov.uscourts.ca9.21514.47.0.pdf. Not viewed or compared (pro per scan; the two above cover the comparison).
- The answering-brief alternate *Hujazi v. Wirum* (BAP No. NC-14-1030, see `../../answering-brief/usage/SOURCE.md`) was also compared for the cover caption.

## FILED-EXAMPLE-reply-brief-3.pdf

- Filer: appellant Steven M. Moehling, pro se.
- Case: *Moehling v. Select Portfolio Servicing, Inc.*, BAP No. SC-26-1081.
- Date filed: June 19, 2026 (PDF creation date; signature page bears filing date).
- URL: https://storage.courtlistener.com/recap/gov.uscourts.ca9.22437/gov.uscourts.ca9.22437.12.0.pdf
- Date retrieved: 2026-10-17.
- SHA-256: `a1798469456e88cff87e74074da6e8daa38cfd079977ee4a9c27588ab17ed694`.
- Alternate filer to the Beavor exemplar above.
