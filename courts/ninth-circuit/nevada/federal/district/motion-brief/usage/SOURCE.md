# Exemplar sources: D. Nev. motion to dismiss with memorandum

| Field | Value |
|---|---|
| File | `SAMPLE-nvd-motion-brief-lynch226cv00895.pdf` |
| URL fetched from | https://storage.courtlistener.com/recap/gov.uscourts.nvd.180465/gov.uscourts.nvd.180465.5.0.pdf (RECAP copy of ECF No. 5) |
| CourtListener docket | https://www.courtlistener.com/docket/72808707/ (search result: `docketNumber` 2:26-cv-00895) |
| Case | *Ossiris Lynch v. Granbury at Valley Vista Homeowners Association* |
| Docket no. | 2:26-cv-00895-APG-EJY (D. Nev.) |
| Document | Defendant Granbury at Valley Vista Homeowners Association's Motion to Dismiss First Amended Complaint [ECF No. 1-1], with Memorandum of Points and Authorities and Certificate of Service, ECF No. 5, 11 pages |
| Filer | Defendant's counsel, O'Hagan Meyer PLLC (Inku Nam, Esq.) |
| Date signed | April 6, 2026 |
| Date filed | April 6, 2026 (ECF header: "Filed 04/06/26") |
| Date fetched | 2026-10-14 |
| Text layer | Yes: `pdftotext -layout` reads the whole document. Fonts: Times New Roman and Arial (the ECF header), not embedded. |

## How it was found

CourtListener search API (`/api/rest/v4/search/?type=r&court=nvd`), query `"MOTION TO DISMISS" "MEMORANDUM OF POINTS AND AUTHORITIES" "12(b)(6)"`, filed after 2025-06-01. Candidates with a text layer were compared: Lynch (11 pp., this one, combined motion and memorandum), Advanced Solution v. New Horizon, 2:26-cv-00958 (9 pp., a motion for partial dismissal, Wiley Petersen), Logan v. Citizen's Bank, 2:26-cv-00887 (9 pp., a motion by MERS, Malcolm Cisneros; its memorandum was not checked), and Browning v. Station Casinos, 2:26-cv-00603 (31 pp.). Lynch was chosen because it is a single document with a full memorandum of points and authorities, at a length within the 8 to 14 page target, and because it follows LR 7-2(a).

## Filer and tier-2 coverage

One filer (O'Hagan Meyer PLLC, defendant's counsel). The eval loop's tier-2 rule asks for two or three exemplars from different filers; this doc type has one. Open gap, see `../README.md`.

Public court record (ECF filing on PACER, mirrored by RECAP). No sealed or redacted material is in this copy.
