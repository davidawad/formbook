# Exemplar source: motion-brief (a motion with its brief in support, okwb)

All three exemplars are public RECAP copies of filings in the U.S. Bankruptcy Court for the Western District of Oklahoma, by three different filers. They were found by listing the RECAP archive's public bucket for `gov.uscourts.okwb.*` (the CourtListener web search and API refused this pod: HTTP 403 and 401), extracting page 1 of every PDF and keeping the motions with a brief in support signed by counsel. Each has a text layer and carries the court's CM/ECF header. Used only as visual and structural references.

Fetched: 2026-10-29. Each file in `usage/` is the download, byte for byte (sha256 below).

## 1. `FILED-EXAMPLE-motion-brief.pdf` (primary; transcribed in `INPUT-motion-brief.md`, used for the overlay and DEF-COVER-002)

- Case: *In re Fairfax Best Living, LLC*, No. 26-11985-SAH (Bankr. W.D. Okla.), chapter 11
- Document: docket entry 31, "Debtor's Emergency Motion for Turnover of Property of the Estate and Brief in Support" (11 pages: the motion with its Notice of Opportunity for Hearing and Notice of Hearing on page 1, the certificate of service on page 8, and pages 9-11 the CM/ECF mailing matrix, which the INPUT does not transcribe)
- Filer: the debtor, by Lindauer & Vaughn (Joyce W. Lindauer), proposed attorneys for the debtors
- Date filed: 06/24/26 (CM/ECF header: "Case: 26-11985 Doc: 31 Filed: 06/24/26")
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.okwb.329861/gov.uscourts.okwb.329861.31.0.pdf
- sha256: `dcc4c2c7605ed5adcb0ec457c981716f7ab802016085ad2fd7fe6345edb7ee75`
- Notes: Times New Roman; the caption and the notices set in bold; a running footer with the short title and "PAGE n" (one filer's style). The service list names counsel and parties with their business addresses and e-mail addresses only; the mailing matrix (pp. 9-11) is not part of the sample.

## 2. `FILED-EXAMPLE-motion-brief-2.pdf` (second filer; tier-2 comparison)

- Case: *In re Jack and Deborah Fortenberry*, No. 12-15384-SAH (Bankr. W.D. Okla.), chapter 7, filed also in Adv. No. 14-01121
- Document: docket entry 42 in the adversary proceeding (entry 70 in the case), "First Amended Motion to Compromise Controversy and Settle Pending Suit/Adversary and Brief in Support and Notice of Opportunity for Hearing" (9 pages; pages 8-9 the attached mailing matrix)
- Filer: the chapter 7 trustee, by Garvin, Agee, Carlton & Mashburn, P.C. (John D. Mashburn)
- Date filed: 04/23/15 (CM/ECF header)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.okwb.278604.42.0.pdf
- sha256: `274024a33c3fb4b3562d652755d7d76d0097a52b5804f700c176ae039be7a7cd`

## 3. `FILED-EXAMPLE-motion-brief-3.pdf` (third filer; tier-2 comparison)

- Case: *In re Trent Dwight Ford and Jill Nicole Ford*, No. 21-10574-SAH (Bankr. W.D. Okla.), chapter 7
- Document: docket entry 28, "Motion to Extend Time for Potential Filing of Complaint to Determine Dischargeability of a Debt, Notice Opportunity for Hearing and Brief in Support" (5 pages; a block quotation of FRBP 4007(c), a certificate of service)
- Filer: the United States ex rel. Small Business Administration, by the United States Attorney for the Western District of Oklahoma (Kay Sewell, Assistant U.S. Attorney)
- Date filed: 05/26/21 (CM/ECF header)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.okwb.310435/gov.uscourts.okwb.310435.28.0.pdf
- sha256: `07be99fdb361eb10c41116ccd4d2a366211819706d99fe16e52ea87e09cba7b5`

## What the three agree on (tier 2)

The court's name bold and centered ("IN THE UNITED STATES BANKRUPTCY COURT FOR THE" / "WESTERN DISTRICT OF OKLAHOMA" in Mashburn and Sewell); "In re:", the debtor and its designation at the left, the case number with the judge's letters and the chapter at the right (LR 1005-1); a bold, centered title naming every request and the brief and notice it contains (LR 9004-1(C), 9013-1(C), (G)); numbered paragraphs and centered capital headings; the Notice of Opportunity for Hearing (below the title in Lindauer, as LR 9013-1(G) places it; Mashburn and Sewell put it later); the signature at the right with "s/" or "/s/" and the LR 9004-1(D) lines beneath; a certificate of service on its own page.
