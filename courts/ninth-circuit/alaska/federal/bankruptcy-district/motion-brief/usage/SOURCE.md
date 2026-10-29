# Exemplar source: motion-brief (a motion, or a memorandum in support of one, akb)

All three exemplars are public RECAP copies of filings in chapter 11 cases of the U.S. Bankruptcy Court for the District of Alaska, by three different filers. They were found by listing the RECAP archive's public bucket for `gov.uscourts.akb.*` (the CourtListener web search and API refused this pod: HTTP 403 and 401), extracting page 1 of every PDF and keeping the motions and memoranda signed by counsel. Each has a text layer. Used only as visual and structural references.

Fetched: 2026-10-29. Each file in `usage/` is the download, byte for byte (sha256 below).

## 1. `FILED-EXAMPLE-motion-brief.pdf` (primary; transcribed in `INPUT-motion-brief.md`, used for the overlay and DEF-COVER-002)

- Case: *In re Anchorage Sportsplex, Inc.*, No. 10-00475-DMD (Bankr. D. Alaska), chapter 11
- Document: docket entry 22, "Memorandum in Support of Motion to Compel Payment of Real Property Taxes" (8 pages)
- Filer: Anchorage Community Development, LLC (lessor), by Birch Horton Bittner & Cherot (Kathryn A. Black, Stanley T. Lewis)
- Date filed: dated June 17, 2010 (the RECAP copy carries no CM/ECF header stamp)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.akb.26542.22.0.pdf
- sha256: `f9bc747ff42222eb7d103036ae2ed346b317f9a35f681f5ed7c4c3219c1516e1`
- Notes: Arial throughout; the firm's letterhead runs down the left edge of every page, and the text column starts 84 pt to its right; a running footer carries the short title, case number and "PAGE n OF 8". The filed text says "Section 363(d)(3)" in the argument's second sentence and "§ 356(d)(3)" in the conclusion, where § 365(d)(3) is meant; the INPUT keeps both as filed.

## 2. `FILED-EXAMPLE-motion-brief-2.pdf` (second filer; tier-2 comparison)

- Case: *In re Anchorage Sportsplex, Inc.*, No. A-10-00475 (Bankr. D. Alaska), chapter 11
- Document: docket entry 40, "Motion to Determine Tax Liabilities Pursuant to 11 U.S.C. § 505(a)" (7 pages, the certificate of service on page 7)
- Filer: the debtor, Anchorage Sportsplex, Inc., by David H. Bundy, P.C. (David H. Bundy)
- Date filed: dated July 6, 2010 (no CM/ECF header stamp)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.akb.26542.40.0.pdf
- sha256: `87c34fab735fbfc0c404e2d1b7cb9a525a1ad0cc23791552b67f0a7da042de8a`

## 3. `FILED-EXAMPLE-motion-brief-3.pdf` (third filer; tier-2 comparison)

- Case: *In re Naknek Electric Association, Inc.*, No. A10-00824 (Bankr. D. Alaska), chapter 11
- Document: docket entry 9, "Debtor's Emergency Motion for Use of Cash Collateral" (8 pages)
- Filer: the debtor in possession, Naknek Electric Association, Inc., by Erik LeRoy, P.C. (Erik LeRoy)
- Date filed: dated September 29, 2010 (no CM/ECF header stamp)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.akb.26903.9.0.pdf
- sha256: `7e3c17a304db42e18fd31c3cdfc248b051248a54b2352959770ebe3add532d40`

## What the three agree on (tier 2)

Counsel's name, address and telephone and the party represented at the top left of page 1 (LBR 9004-1(c)(2)); the court's name centered (bold in Birch Horton and Bundy); "In re", the debtor and "Debtor." at the left, a column of ")" (LeRoy ":"), the case number and chapter at the right; a rule under the party column (drawn by Birch Horton, typed as underscores by Bundy; LeRoy has none); the title bold and centered; section headings centered; text double-spaced in 12-point type; a dated signature block at the right with "By: /s/" and the typed name beneath; a certificate of service last. Each also prints a running footer with a short title and the page number (one filer's wording each; the template numbers the page alone, see the README).
