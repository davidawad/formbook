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
