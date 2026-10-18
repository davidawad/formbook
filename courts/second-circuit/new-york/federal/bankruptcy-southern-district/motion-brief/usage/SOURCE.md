# Exemplar source: motion with memorandum of law (nysb)

Two filed memoranda from two different filers, both public court records (CourtListener RECAP), both text-based
(`pdftotext` reads them; Times fonts embedded). Fetched 2026-10-14 with curl.

## 1. `SAMPLE-nysb-motion-brief-revlon2201167.pdf` (primary; used for the sample)

- Court: United States Bankruptcy Court, Southern District of New York
- Case: *AIMCO CLO 10 Ltd., et al. v. Revlon, Inc., et al.*, Adv. Pro. No. 22-01167 (DSJ), in *In re Revlon, Inc., et al.*,
  Case No. 22-10760 (DSJ) (Jointly Administered)
- Document: Debtors' Memorandum of Law in Support of Their Motion to Dismiss the Adversary Complaint (ECF Doc. 16), 68 pages
  (the proposed order follows at the end and is not part of the template)
- Filer: Paul, Weiss, Rifkind, Wharton & Garrison LLP; MoloLamken LLP; Kaplan Rice LLP, counsel for the Debtors
  (signature of Lewis R. Clayton, Paul Weiss)
- Date filed: December 5, 2022 (ECF stamp "Filed 12/05/22" on every page; signature block "Dated: December 5, 2022")
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.nysb.314128/gov.uscourts.nysb.314128.16.0.pdf
- Docket: https://www.courtlistener.com/docket/65650767/ (AIMCO CLO 10 Ltd. v. Revlon, Inc.)
- Date fetched: 2026-10-14

## 2. `SAMPLE-nysb-motion-brief-celsiustether2404018.pdf` (second filer; structure comparison)

- Court: United States Bankruptcy Court, Southern District of New York
- Case: *Celsius Network Limited and Celsius Network LLC (Post-Effective Date Debtors) v. Tether Limited et al.*,
  Adv. Proc. No. 24-04018 (MG), in *In re Celsius Network LLC et al.*, Case No. 22-10964 (MG)
- Document: Memorandum of Law in Support of Defendants' Motion to Dismiss (ECF Doc. 33), 57 pages, with table of
  authorities (the motion itself is ECF Doc. 32, a 6-page notice; not used)
- Filer: Kramer Levin Naftalis & Frankel LLP, counsel for the Tether defendants
- Date: dated January 17, 2025 (signature block; the ECF header is not in the text layer)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.nysb.325136/gov.uscourts.nysb.325136.33.0.pdf
- Docket: https://www.courtlistener.com/docket/69033248/ (Celsius adversary, 24-04018)
- Date fetched: 2026-10-14

## Searches tried

- WebSearch for nysb memoranda and notices: returned Madoff trustee dockets and court forms.
- CourtListener search API (court=nysb, type=r): returned the Revlon docket (22-01167), whose entry 15 is a 3-page notice
  of motion. Entry 16 (the memorandum) was then fetched directly.
- The Celsius motion (ECF Doc. 32) is a 6-page notice of motion and was not used; ECF Doc. 33 is the memorandum.
