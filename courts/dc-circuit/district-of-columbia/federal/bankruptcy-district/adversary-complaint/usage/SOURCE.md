# Exemplar source

- File: `FILED-EXAMPLE-adversary-complaint-2.pdf` (13 pages, text layer present: `pdffonts` shows embedded TimesNewRomanPSMT and Times-Roman/Bold/Italic; `pdftotext` reads it)
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

## 2. Second filer: Woodcrest Condominiums IX, LLC v. Welch Family Limited Partnership Five

- File: `FILED-EXAMPLE-adversary-complaint-3.pdf` (25 pages)
- Court: United States Bankruptcy Court for the District of Columbia (`dcb`)
- Case: *Woodcrest Condominiums IX, LLC v. Welch Family Limited Partnership Five*, Adv. Proc. No. 25-10036-ELG (ECF header; the caption leaves "Adv. Pro. No. ____" blank), in the chapter 11 case of *Woodcrest Condominiums IX, LLC*, No. 25-00265 (ELG)
- Docket / document: Doc 1, "COMPLAINT"
- Filer: Plaintiff Woodcrest Condominiums IX, LLC, debtor and debtor in possession, by Brent C. Strickland (Bar No. 452880) and Joshua D. Stiff (pro hac vice), Whiteford, Taylor & Preston L.L.P. Different party and different counsel from Webster (The VerStandig Law Firm).
- Date filed: 2025-08-29 (ECF header "Filed 08/29/25 Entered 08/29/25 16:55:13"; signature "Dated: August 29, 2025")
- URL fetched: https://storage.courtlistener.com/recap/gov.uscourts.dcb.50605/gov.uscourts.dcb.50605.1.0.pdf (CourtListener RECAP)
- Date retrieved: 2026-10-17
- Text layer: yes (Power PDF Create; `pdftotext` yields the full text; Times New Roman named but not embedded)
- sha256: `e2ba283651aa3149691a18f059392d012b90866443b93e835ae0aa947f0f61ca`
- Notes: counsel block in the footer of page 1 (the LBR 5005-1(c) footer option); the jurisdiction paragraph states that "the Debtor consents to entry of final judgment by the Bankruptcy Court" (FRBP 7008; LBR 7012-1).
- Found by: the CourtListener search API was rate-limited (HTTP 429), so RECAP storage URLs `gov.uscourts.dcb.<id>.1.0.pdf` were checked by id near the existing exemplars' ids and each hit's first page was read to find adversary complaints.

## 3. Third filer: Bolog v. Swain Landing LaPlata JC, LLC

- File: `FILED-EXAMPLE-adversary-complaint.pdf` (8 pages)
- Court: United States Bankruptcy Court for the District of Columbia (`dcb`)
- Case: *Erik D. Bolog v. Swain Landing LaPlata JC, LLC*, Adversary Proceeding No. 25-10019-ELG (ECF header; caption "No. ______"), in the case of *Swain Landing LaPlata JC, LLC*, No. 25-184-ELG
- Docket / document: Doc 1, "ADVERSARY PROCEEDING AGAINST SWAIN LANDING LAPLATA JC, LLC" (the complaint; with a DEMAND FOR JURY TRIAL)
- Filer: Plaintiff Erik D. Bolog, by Douglas F. Gansler (Bar ID 425465), Cadwalader, Wickersham & Taft LLP. Different party and counsel from Webster and Woodcrest.
- Date filed: 2025-06-24 (ECF header "Filed 06/24/25 Entered 06/24/25 12:56:53")
- URL fetched: https://storage.courtlistener.com/recap/gov.uscourts.dcb.50478/gov.uscourts.dcb.50478.1.0.pdf (CourtListener RECAP)
- Date retrieved: 2026-10-17
- Text layer: yes (Acrobat Distiller; embedded Times New Roman; `pdftotext` yields the full text)
- sha256: `2d44d57324a1c506ea8a81484ea28425859a8915ec23c66ad484e46955adfcb8`
- Notes: counsel block at the top left of page 1; paragraph 5 states that Mr. Bolog "does not consent to the entry of final orders or judgment"; signature block has no "/s/" line in the text layer.
