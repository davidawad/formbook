# Exemplar source: adversary complaint (nysb)

Two filed complaints from two different filers, both public court records (CourtListener RECAP), both text-based
(`pdftotext` reads them; Times fonts embedded). Fetched 2026-10-14 with curl.

## 1. `FILED-EXAMPLE-adversary-complaint.pdf` (primary; used for the sample)

- Court: United States Bankruptcy Court, Southern District of New York
- Case: *Celsius Network Limited and Celsius Network LLC (Post-Effective Date Debtors) v. Tether Limited et al.*,
  Adv. Proc. No. 24-04018 (MG), in *In re Celsius Network LLC et al.*, Case No. 22-10964 (MG) (Jointly Administered)
- Document: Complaint (ECF Doc. 1), 30 pages
- Filer: Quinn Emanuel Urquhart & Sullivan, LLP, counsel to Blockchain Recovery Investment Consortium, LLC, Litigation
  Administrator and Complex Asset Recovery Manager, as representative for the Post-Effective Date Celsius Debtors
- Date filed: August 9, 2024 (ECF stamp "Filed 08/09/24" on every page; signature block "DATED: August 9, 2024")
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.nysb.325136/gov.uscourts.nysb.325136.1.0.pdf
- Docket: https://www.courtlistener.com/docket/69033248/1/celsius-network-llc-adversary-proceeding/
- Date fetched: 2026-10-14

## 2. `FILED-EXAMPLE-adversary-complaint-2.pdf` (second filer; structure comparison)

- Court: United States Bankruptcy Court, Southern District of New York
- Case: *The Lawyers' Fund for Client Protection of the State of New York v. Samuel Ehrenfeld*, Adv. Pro. No. 19-01128,
  in *In re Samuel Ehrenfeld*, Chapter 7, Case No. 19-10290-mkv
- Document: Complaint to Determine Dischargeability of Debt (11 U.S.C. § 523), 4 pages
- Filer: Letitia James, Attorney General of the State of New York, for The Lawyers' Fund for Client Protection
- Date filed: May 3, 2019 (CourtListener docket entry 1 metadata; the PDF text has no ECF stamp)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.nysb.292749/gov.uscourts.nysb.292749.1.0.pdf
- Docket: https://www.courtlistener.com/docket/15049418/1/samuel-ehrenfeld-adversary-proceeding/
- Date fetched: 2026-10-14
- Note: this is a short complaint (not a full commercial pleading). It is used for the second-filer comparison of the
  caption and numbered paragraphs, not transcribed into `usage/`.

## Searches tried

- WebSearch for nysb adversary complaint PDFs: returned Madoff trustee dockets and court forms, not complaints.
- WebFetch of the CourtListener search API (court=nysb): returned docket pages; the PDF paths were then taken from
  the `filepath_local` field and downloaded directly.
- Not used: courtrules.net and the nysb.uscourts.gov pages (HTTP 403 / Cloudflare challenge to the fetch tool).
