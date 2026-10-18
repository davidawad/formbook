# Exemplar sources: D. Nev. complaint

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-complaint.pdf` |
| URL fetched from | https://storage.courtlistener.com/recap/gov.uscourts.nvd.180252/gov.uscourts.nvd.180252.1.0.pdf (RECAP copy of ECF No. 1) |
| CourtListener docket | https://www.courtlistener.com/docket/72509967/ (search result: `docketNumber` 2:26-cv-00801) |
| Case | *Shanita Williams v. Comoto Holdings, Inc.* |
| Docket no. | 2:26-cv-00801 (D. Nev.) |
| Document | Complaint for Damages; Demand for Jury Trial, ECF No. 1, 14 pages |
| Filer | Plaintiff's counsel, Greenberg Gross LLP (Jemma E. Dunn, Matthew T. Hale, Michael A. Burnette) |
| Date signed | March 17, 2026 |
| Date filed | March 18, 2026 (ECF header: "Filed 03/18/26") |
| Date fetched | 2026-10-14 |
| Text layer | Yes: `pdftotext -layout` reads the whole document; `pdffonts` shows Times New Roman and Arial (the ECF header), not embedded. |

## How it was found

CourtListener search API (`/api/rest/v4/search/?type=r&court=nvd`), query `COMPLAINT "DEMAND FOR JURY TRIAL" "Nevada"`, filed after 2025-06-01. Candidates with a text layer and a complete complaint were compared: Williams (14 pp.), Ward v. Tesla, 2:26-cv-00800 (17 pp., same filer), Nguyen v. Wynn Las Vegas, 2:26-cv-00176 (19 pp., same filer), Baerga (13 pp.). Williams was chosen as the complete document closest to the 8 to 14 page target.

## Filer and tier-2 coverage

One filer (Greenberg Gross LLP, plaintiff's counsel). The tier-2 rule in the eval loop asks for two or three exemplars from different filers; this doc type has one. Open gap, see `../README.md`.

Public court record (ECF filing on PACER, mirrored by RECAP). No sealed or redacted material is in this copy.
