# Exemplar source

- File: `FILED-EXAMPLE-webster-v-square-funding-25-10054-adversary-complaint.pdf` (13 pages, text layer present: `pdffonts` shows embedded TimesNewRomanPSMT and Times-Roman/Bold/Italic; `pdftotext` reads it)
- Court: United States Bankruptcy Court for the District of Columbia (`dcb`)
- Case: *Wendell Webster, chapter 7 trustee v. Square Funding LLC d/b/a Square Advance*, Adv. Proc. No. 25-10054-ELG, in the chapter 7 case of *Broughton Construction Co., LLC*, No. 23-378-ELG (the caption says "Case No. 23-378-ELG"; the ECF header says `Case 25-10054-ELG`)
- Document: Complaint (ECF Doc 1), five counts: fraudulent conveyance (11 U.S.C. § 548, two counts), D.C. Code § 28-3105, conversion, and unjust enrichment
- Filer: Plaintiff, by special counsel Maurice B. VerStandig (VerStandig Law Firm, LLC), Potomac, Maryland
- Date filed: 2025-12-14 (ECF header "Filed 12/14/25")
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.dcb.50855/gov.uscourts.dcb.50855.1.0.pdf (CourtListener RECAP)
- Date fetched: 2026-10-14
- Public court record (RECAP). Used as a visual and structural reference.

## How it was found

- CourtListener API (`https://www.courtlistener.com/api/rest/v4/search/?type=r&court=dcb&q=complaint+adversary&order_by=dateFiled+desc`, read through WebFetch; the HTML search page returns 403 to WebFetch, the API does not). The results listed ten Chapter 7 trustee complaints of 2025-12-14 with RECAP PDFs. Of those, Square Funding (50855, 13 pages) and CFG Merchant Solutions (50856, 10 pages) are text-based; Jaycee Development (50853, 8 pages) is text-based but uses a different caption layout.
- Two other adversary complaints in the index were scans and were not used: Akers, 17-10012 (4 pages, CCITT images, only the ECF header is text) and Elliot, 26-10013 (4 pages, scanned image).
- Second filer: not collected. CFG Merchant Solutions (25-10055) is filed by the same counsel on the same day, so it is not a second filer. Tier 2 is not judged against two filers yet (see README.md).

## Caveats

- The exemplar has no statement on whether the pleader consents to entry of final orders (FRBP 7008(a); LBR 7012-1), no jury demand, and a blank adversary number ("Adv. Case No. ____"). The template requires the consent statement; the sample adds it, marked, see README.md.

## 2. Second filer (added 2026-10-17)

- File: `FILED-EXAMPLE-mp-pph-23-00246-adversary-complaint.pdf` (21 pages, text layer present: `pdftotext` reads it; `pdffonts` lists TimesNewRomanPSMT and Times-Roman/Bold/Italic, not embedded, plus the ECF stamp's LiberationSans)
- Court: United States Bankruptcy Court for the District of Columbia (`dcb`)
- Case: *MP PPH LLC v. District of Columbia*, adversary complaint in the chapter 11 case *In re MP PPH LLC*, No. 23-00246-ELG. The caption leaves "Adv. Proc. No." blank; the PDF was docketed in the main case (ECF header `Case 23-00246-ELG Doc 88`)
- Document: Debtor's Complaint for Injunctive Relief (ECF Doc 88 in the main case), 75 numbered paragraphs, "PRAYER FOR RELIEF", signature block
- Filer: Plaintiff/Debtor MP PPH LLC, by Marc E. Albert, Bradley D. Jones, Tracey M. Ohm, Joshua W. Cox and Ruiqiao Wen (Stinson LLP), Washington, D.C. (different party and firm from entry 1)
- Date filed: 2023-10-25 (ECF header "Filed 10/25/23")
- Fetched from: https://web.archive.org/web/20250523073216id_/https://storage.courtlistener.com/recap/gov.uscourts.dcb.49591/gov.uscourts.dcb.49591.88.0.pdf (Internet Archive copy of the CourtListener RECAP file; storage.courtlistener.com itself returned HTTP 429 to this box)
- Date retrieved: 2026-10-17
- sha256: `30756fce31da02f2adc1641d9aef66cbbfc58995d341f9ae54490be582cb7c5f`
- Found via the Internet Archive CDX index of `storage.courtlistener.com/recap/gov.uscourts.dcb.*` (17 captures; this is the only adversary complaint among them).
- Caveats: docketed as a main-case entry rather than as Doc 1 of a new adversary; no FRBP 7008 / LBR 7012-1 consent statement; no jury demand.
