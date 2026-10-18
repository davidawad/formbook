# Exemplars: txed complaint

Date fetched for both: 2026-10-14.

| File | Case | Docket | Filer (counsel) | Date filed | Fetched from |
|---|---|---|---|---|---|
| `SAMPLE-txed-complaint-pacsec3lumen225cv00668.pdf` | *PacSec3, LLC v. Lumen Technologies, Inc.* (E.D. Tex., Marshall Div.) | 2:25-cv-00668, Dkt. 1 | Plaintiff PacSec3, LLC (Ramey LLP, William P. Ramey, III) | 2025-06-30 | https://cdn.lawlytics.com/law-media/uploads/2360/335701/original/COMPLAINT---PacSec-v.-Lumen.pdf |
| `SAMPLE-txed-complaint-wetrohacom215cv00416.pdf` | *Wetro LAN LLC v. Hacom LLC* (E.D. Tex., Marshall Div.) | 2:15-cv-00416, Dkt. 1 | Plaintiff Wetro LAN LLC (Austin Hansley P.L.L.C., Austin Hansley and Brandon LaPray) | 2015-03-23 | https://eff.org/files/2015/06/26/wetro_lan_v_hacom_complaint.pdf |

## Which one the sample uses

`usage/INPUT-txed-complaint-pacsec3.md` is the transcription of the PacSec3 complaint (the 2025 filing, the one the template is checked against with `overlay.sh`, because it is the first `usage/*.pdf` in name order). The Wetro complaint is a second filer, kept for the tier-2 comparison of conventions (caption, numbered paragraphs, prayer, signature). It is from 2015, so its layout is older than the current rules.

## Provenance and checks

- Both are public federal court filings (CM/ECF documents) that a third party re-hosted. The text layer was checked with `pdftotext`: both are text-based (not scans). The PacSec3 file is Word 2016/365 output (8 pages); the Wetro file is Word 2013 output (5 pages).
- The copies on CourtListener RECAP and PACER were not reachable from this box (CourtListener storage returned only an unrelated order; Justia and docketalarm refused downloads). The copies used are the re-hosted ones above, and the header lines (`Case ... Document 1 Filed ... Page x of y`) show they are the ECF-stamped Dkt. 1.
- Not used: the CourtListener RECAP order `gov.uscourts.txed.202878.217.0.pdf` (*Texas v. Google*, 4:20-cv-957, Dkt. 217); it is an order, not a complaint.
