# Exemplars: motion-brief (txnd)

Both files are public court records from CourtListener's RECAP archive (documents uploaded by PACER users).
Date fetched for both: 2026-10-14. Both PDFs carry a text layer (`pdftotext` yields text).

| File | URL fetched | Case | Docket no. | Filer | Date filed | Pages |
|---|---|---|---|---|---|---|
| `FILED-EXAMPLE-coney-4-26-cv-00713-motion-brief.pdf` (**transcribed** into `samples/INPUT-coney-motion-brief.md`; a brief in support of a Rule 12(b)(1), (4), (5), (6) motion, with table of contents and index of authorities) | https://storage.courtlistener.com/recap/gov.uscourts.txnd.421383/gov.uscourts.txnd.421383.35.0.pdf (docket: https://www.courtlistener.com/docket/73473848/35/coney-v-workers-united-southwest-regional-joint-board/) | *Coney v. Workers United Southwest Regional Joint Board, et al.*, Fort Worth Division; Defendants' Brief in Support of Renewed Motion to Dismiss | 4:26-cv-00713-P-BJ | Defendants Southwest Regional Joint Board, Jean Hervey, Workers United, Lynne Fox (Deats Durst & Owen PLLC; Gillespie Sanford LLP) | 2026-09-21 | 32 |
| `FILED-EXAMPLE-legacy-fertel-4-26-cv-00792-motion-brief.pdf` (second filer; **not transcribed**; a combined motion and brief, Times New Roman, no table of contents, used for the tier-2 comparison) | https://storage.courtlistener.com/recap/gov.uscourts.txnd.422184/gov.uscourts.txnd.422184.36.0.pdf (docket: https://www.courtlistener.com/docket/73541758/36/legacy-medical-consultants-lp-v-fertel/) | *Legacy Medical Consultants LP v. Fertel*, Fort Worth Division; Plaintiff's Motion to Dismiss Counterclaims and Third-Party Complaint and Brief in Support | 4:26-cv-00792-P | Plaintiff and counter-defendant Legacy Medical Consultants LP (Blank Rome LLP) | 2026-10-08 | 33 |

Search that found them: CourtListener API, `type=rd`, `court=txnd`, query `"brief in support" "motion to dismiss"`, ordered by filing date (2026-10-14).
