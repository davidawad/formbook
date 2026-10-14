# Exemplars: complaint (M.D. Ala.)

Both files are public records of the United States District Court for the Middle District of Alabama, obtained from the RECAP archive of CourtListener (the document as filed on the court's ECF docket). Retrieved 2026-10-14 with `curl`, unmodified. Each file's text layer was checked with `pdftotext` (it yields text).

| File | Case / docket | Filer | Date filed (per footer) | Pages | sha256 | URL fetched |
|---|---|---|---|---|---|---|
| `FILED-EXAMPLE-allstate-lg-1-26-cv-00215-complaint.pdf` | *Allstate Vehicle and Property Insurance Company v. LG Electronics USA, Inc.*, No. 1:26-cv-00215-KFP (M.D. Ala., Southern Division) | Plaintiff Allstate Vehicle and Property Insurance Company, by counsel Scott Dukes & Geisler, P.C. | 03/27/2026 | 13 | `9609e3df9cadc14eda5d5dfde651bc2767cafef535e1ce5029866d1cf12b59c8` | https://storage.courtlistener.com/recap/gov.uscourts.almd.90104/gov.uscourts.almd.90104.1.0.pdf |
| `FILED-EXAMPLE-first-horizon-2-24-cv-00605-complaint.pdf` | *First Horizon Bank v. Premier Holdings, LLC*, No. 2:24-cv-00605 (M.D. Ala., verified complaint) | Plaintiff First Horizon Bank | 09/26/2024 | 30 | `3451d6b45f6a8d111e84866063ca64b5bfdf4dc623c7a55b8280f8cf09d14c4c` | https://storage.courtlistener.com/recap/gov.uscourts.almd.84364/gov.uscourts.almd.84364.1.0.pdf (docket: https://www.courtlistener.com/docket/69201439/1/first-horizon-bank-v-premier-holdings-llc-lead/) |

Filers: two different parties (an insurer's subrogation complaint through outside counsel, and a bank's verified complaint), so the tier-2 comparison is not one filer's house style.

Used as follows: the Allstate complaint is transcribed into `samples/INPUT-allstate-complaint.md` and overlaid (`samples/OVERLAY-allstate-complaint.pdf`). The First Horizon complaint is compared for the caption and the signature conventions and for type size (its body is 12 pt double-spaced, where Allstate's is 14 pt).
