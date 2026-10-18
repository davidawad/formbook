# Exemplars: complaint (txnd)

Both files are public court records from CourtListener's RECAP archive (documents uploaded by PACER users).
Date fetched for both: 2026-10-14. Both PDFs carry a text layer (`pdftotext` yields text).

| File | URL fetched | Case | Docket no. | Filer | Date filed | Pages |
|---|---|---|---|---|---|---|
| `FILED-EXAMPLE-complaint.pdf` (**transcribed** into `usage/INPUT-complaint.md`) | https://storage.courtlistener.com/recap/gov.uscourts.txnd.428372/gov.uscourts.txnd.428372.1.0.pdf (docket: https://www.courtlistener.com/docket/74935394/1/eli-lilly-and-company-v-brown/) | *Eli Lilly and Company v. Brown* (William "Ian" Brown d/b/a LiveWell Peptides), Dallas Division | 3:26-cv-03514 | Plaintiff Eli Lilly and Company (counsel: Kirkland & Ellis LLP), non-class complaint | 2026-10-08 | 35 |
| `FILED-EXAMPLE-complaint-2.pdf` (second filer; **not transcribed**, kept for the tier-2 comparison of the caption and signature block) | https://storage.courtlistener.com/recap/gov.uscourts.txnd.428582/gov.uscourts.txnd.428582.1.0.pdf (docket: https://www.courtlistener.com/docket/74950421/1/burkes-v-baylor-scott-white-health/) | *Burkes v. Baylor Scott & White Health*, Dallas Division (class action complaint) | 3:26-cv-03570 | Plaintiff Amy Burkes (counsel: Kendall Law Group, PLLC; Siri & Glimstad LLP) | 2026-10-12 | 37 |

Search that found them: CourtListener API, `type=r`, `court=txnd`, `document_type=1`, query `complaint AND "Northern District of Texas"`, ordered by filing date (2026-10-14).
