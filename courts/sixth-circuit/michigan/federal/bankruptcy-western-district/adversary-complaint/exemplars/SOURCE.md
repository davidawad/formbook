# Exemplars: adversary complaint (miwb)

Both are public court records from the W.D. Mich. Bankruptcy Court's CM/ECF docket, as published through RECAP. Fetched 2026-10-14 by a plain HTTPS GET of the storage URL (no login).

| File | Case | Docket | Filer (party, counsel) | Filed | Fetched from |
|---|---|---|---|---|---|
| `FILED-EXAMPLE-spiech-farms-17-05398-adversary-complaint.pdf` (8 pp., text layer, Word/Distiller) | *Spiech Farms, LLC v. Produce Pay, Inc.* (adversary of Ch. 11 *In re Spiech Farms, LLC*) | Main case 17-05398 (jtg); adversary 17-80191 per CourtListener (printed as "17-80" on the face of the filing); Doc #3 | Spiech Farms, LLC, Debtor/Plaintiff. Counsel: Rayman & Knight (Cody H. Knight, P64811) | 2017-11-22 | https://storage.courtlistener.com/recap/gov.uscourts.miwb.357771/gov.uscourts.miwb.357771.3.0.pdf (docket page: https://www.courtlistener.com/docket/6231057/spiech-farms-llc/) |
| `FILED-EXAMPLE-fuller-25-02060-adversary-complaint.pdf` (6 pp., text layer, Word) | *Fuller v. National Debt Relief, LLC* (adversary of Ch. 7 *In re Mary D. Fuller*) | Main case 25-02060 JTG; adversary 26-80003; Doc #1 | Mary D. Fuller, Debtor/Plaintiff. Counsel: Acclaim Legal Services, PLLC (Christopher W. Jones, P67955; Michael T. Brown, P71385) | 2026-01-07 | https://storage.courtlistener.com/recap/gov.uscourts.miwb.403476/gov.uscourts.miwb.403476.1.0.pdf (docket page: https://www.courtlistener.com/docket/72113186/mary-d-fuller-adversary-proceeding/) |

## Why these two

- Both are adversary complaints filed in this court (W.D. Mich.), by different filers (a Chapter 11 debtor through counsel, 2017; a Chapter 7 debtor, 2026).
- Each was searched for on CourtListener with `court=miwb`, `type=r` and a `Complaint by` / `Adversary case` description. The Spiech filing is the cleaner model (counsel block, jurisdiction section, numbered counts, prayer, signature). The Fuller filing is shown as a second data point.
- The Fuller filing is double-spaced by measurement (most body lines 27.5 to 27.6 pt baseline to baseline, as Spiech). It departs from LBR 9004(c) (its petition date is in paragraph 6, not right after the jurisdictional paragraph) and leaves the adversary number blank ("Adv. Pro. No." with no number).

## What the exemplar does not show

- The ECF header line ("Case:17-05398-jtg Doc #:3 Filed ... Page 1 of 8") is added by the court on filing. The template does not reproduce it.
- No exhibits are included in the downloaded PDF (Exhibits A, B and C are separate attachments on the docket).
- The Spiech adversary number is printed "17-80" on the face of the filing; the transcription keeps that text as printed.
- The Spiech filing shows no email address for counsel; the sample marks that field as not printed.
