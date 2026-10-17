# Exemplar source

- File: `FILED-EXAMPLE-supor-26-01475-adversary-complaint.pdf`
- Court: United States Bankruptcy Court, District of New Jersey (`njb`)
- Case: *Supor Properties Enterprises LLC, et al. v. Everest Blue Capital LLC and Does I-V*
- Bankruptcy case: No. 24-13427 (SLM), jointly administered, Chapter 11 (Hon. Stacey L. Meisel)
- Adversary: No. 26-01475-SLM (Document 1)
- Document: Complaint (34 pages), text-based PDF
- Filer: Plaintiffs Supor Properties Enterprises LLC, J Supor 136-1 Realty LLC, Supor-172 Realty LLC and Supor Properties 600 Urban Renewal, LLC, by K&L Gates LLP (Daniel M. Eliades, David S. Catuogno) and Forman Holt (Michael E. Holt)
- Date filed: 2026-10-12 (header "Filed 10/12/26" on every page)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.njb.1148422/gov.uscourts.njb.1148422.1.0.pdf (CourtListener RECAP; docket https://www.courtlistener.com/docket/74950181/1/)
- Date fetched: 2026-10-14
- Text layer: yes (`pdftotext` yields text). Body face Times New Roman, measured body size about 14 pt from word boxes.
- Public court record (RECAP). Used as a structural reference only.

Second filer: not collected. Tier 2 (2 or 3 filers) is not met for this doc type; see `../README.md`.

## 2. Second filer: `FILED-EXAMPLE-orcafunding-26-01421-adversary-complaint.pdf`

- Court: United States Bankruptcy Court, District of New Jersey (`njb`)
- Case: *OrcaFunding LLC v. David Arthur Shabsels*, Adv. Pro. No. 26-01421 (CMG), in *In re David Arthur Shabsels*, Chapter 11, Case No. 26-16530 (CMG)
- Docket / document: Adversary 26-01421, Doc 1
- Pages: 14
- Text layer: yes (`pdftotext` yields the text; embedded CID fonts plus Times; 12 pt, line pitch about 27-28 pt)
- Document: Complaint (nondischargeability under 11 U.S.C. § 523(a)(2) and (a)(6)); "Caption in Compliance with D.N.J. LBR 9004-1(b)" block with counsel at top left; para. 6 states consent to entry of final orders under FRBP 7008
- Filer: Plaintiff OrcaFunding LLC, by Jacobs P.C. (Adam Sherman; Aaron Slavutin, pro hac vice forthcoming), New York
- Date filed: 2026-09-15 (ECF footer "Filed 09/15/26")
- URL fetched: https://storage.courtlistener.com/recap/gov.uscourts.njb.1147323/gov.uscourts.njb.1147323.1.0.pdf (CourtListener RECAP; URL found in the Internet Archive CDX index of `storage.courtlistener.com`, since the CourtListener search API was throttled on 2026-10-17)
- Date retrieved: 2026-10-17
- sha256: `544353a33d5b67ff7d106a205e3d5611de2673e23f46d2093df8464739941708`
- Different party and counsel from Supor (K&L Gates).

## 3. Third filer: `FILED-EXAMPLE-goldberg-26-01030-adversary-complaint.pdf`

- Court: United States Bankruptcy Court, District of New Jersey (`njb`)
- Case: *Michael Goldberg, as Plan Administrator for 20230930-DK-Butterfly-1, Inc. f/k/a Bed Bath & Beyond, Inc. v. Internal Revenue Service*, Adv. Pro. No. 26-01030 (VFP), in *In re 20230930-DK-Butterfly-1, Inc.*, Chapter 11, Case No. 23-13359 (VFP) (jointly administered)
- Docket / document: Adversary 26-01030, Doc 1
- Pages: 8
- Text layer: yes (Times New Roman embedded; 12 pt, line pitch about 27-28 pt)
- Document: Complaint (tax refund and objection to proofs of claim); counsel block at top left of page 1 above the caption
- Filer: Plaintiff Michael Goldberg, Plan Administrator, by Akerman LLP (Steven R. Wirth, Peter O. Larsen, Raye Elliott), Tampa
- Date filed: 2026-02-03 (ECF footer "Filed 02/03/26")
- URL fetched: https://storage.courtlistener.com/recap/gov.uscourts.njb.1137652/gov.uscourts.njb.1137652.1.0.pdf (CourtListener RECAP; URL found in the Internet Archive CDX index)
- Date retrieved: 2026-10-17
- sha256: `ad81c7a323e0e067b0a2bde43a5159ea052fe973b3e05feb094c8c78ffcb4416`
- Different party and counsel from Supor and OrcaFunding. No FRBP 7008 consent statement appears in the text (searched for "consent").

Note for `tools/overlay.sh`: its default exemplar is the first PDF by name, now the Goldberg file; pass the Supor PDF as the third argument to reproduce the existing overlay.
