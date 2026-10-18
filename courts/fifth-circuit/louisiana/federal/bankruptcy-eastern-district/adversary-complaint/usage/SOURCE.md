# Exemplar source: adversary complaint, Bankr. E.D. La.

| Item | Value |
|---|---|
| File | `FILED-EXAMPLE-adversary-complaint.pdf` (19 pages; the complaint begins on PDF page 3 after the Form B1040 cover sheet on pages 1-2) |
| Court | United States Bankruptcy Court, Eastern District of Louisiana (`laeb`) |
| Case | *Babin, Jr. v. Crescent Drilling & Production, Inc.*, Adv. Proc. No. 24-01028, in *In re Martin Energy, LLC*, No. 23-10898 (Chapter 7), Section A (Judge Grabill) |
| Document | Complaint (ECF Doc. 1 in the adversary), with Adversary Proceeding Cover Sheet (Form B1040) and Exhibit A (MSA) |
| Filer | Wilbur J. "Bill" Babin, Jr., solely as Chapter 7 Trustee; counsel Patrick S. Garrity and Albert J. Derbes, IV (The Derbes Law Firm, LLC) and Charles Blaize (Fondren Blaize Law Firm) |
| Date filed | 2024-09-30 (entered 09/30/24 16:43:45 per the ECF stamp) |
| Source URL | https://storage.courtlistener.com/recap/gov.uscourts.laeb.204467/gov.uscourts.laeb.204467.1.0.pdf (RECAP archive) |
| Docket page | https://www.courtlistener.com/docket/69216738/1/martin-energy-llc-adversary-proceeding/ |
| How found | CourtListener search API, `type=r`, `court=laeb`, query "adversary proceeding" complaint; the entry shows the document as RECAP-available with text |
| Date fetched | 2026-10-14 |
| Text layer | Yes: `pdftotext` yields the full text |

Public court record (RECAP). The filer is a Chapter 7 trustee's counsel, so the filing is a representative complaint in a pending adversary.

Other candidates found and not saved (the brief asks for one exemplar per doc type): *Crosby Tugs, L.L.C. v. Pelican Marine Logistics, LLC*, Adv. No. 26-01083, complaint filed 2026-10-12 (6 pages, RECAP `gov.uscourts.laeb.211046.1.0.pdf`); *Brown v. Burmaster*, Adv. No. 23-01032 (5 pages, `gov.uscourts.laeb.202033.1.0.pdf`). Tier 2 of EVAL-LOOP asks for 2 or 3 filers; see README.md.

## Replacement for the audited non-redistributable-font exemplar

- File: `FILED-EXAMPLE-adversary-complaint-2.pdf` (6 pages)
- Case: *Crosby Tugs, L.L.C. v. Pelican Marine Logistics, LLC*, Adv. No. 26-01083
- Document: Doc. 1, Complaint
- Filer: Crosby Tugs, L.L.C., by counsel Michael D. Rubenstein, Liskow & Lewis
- Date filed: 2026-10-12 (CM/ECF header on each page)
- URL: https://storage.courtlistener.com/recap/gov.uscourts.laeb.211046/gov.uscourts.laeb.211046.1.0.pdf
- Date retrieved: 2026-10-17
- SHA-256: `b0bb3a22b1b88295c7068814b21cd4cabc2ff850e87a84905048c216537ab011`
- Text layer: yes; `pdftotext` yields the complaint. Its body uses Times-Roman (unembedded), so it is a text-layer Times-family comparison, not a Times New Roman font-embedding reference.
- Public filing: CourtListener RECAP copy.

This public, text-based complaint replaces the audited `FILED-EXAMPLE-adversary-complaint.pdf` (Garamond) for font and text-layer comparison. The Babin PDF is retained as historical source material.
