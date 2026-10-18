# Exemplar source

Two filed complaints from this court, from two different filers. The first is the exemplar the sample transcribes;
the second is kept for the tier-2 comparison (EVAL-LOOP asks for 2 or 3 filers).

## 1. Primary exemplar: `FILED-EXAMPLE-complaint.pdf`

- Court: United States District Court, Eastern District of Washington (Spokane Division)
- Case: *Plenty v. Hilton Grand Vacations Inc.*
- Docket: No. 2:26-cv-00258-SAB (ECF No. 1)
- Document: Plaintiff's Class Action Complaint (12 pages), with demand for jury trial
- Filer: Plaintiff Melissa Plenty, by counsel Thomas Alvord, The HQ Firm, P.C. (Seattle)
- Date filed: 06/16/26 (file stamp "filed 06/16/26" on every page)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.waed.117490/gov.uscourts.waed.117490.1.0.pdf
  (CourtListener RECAP; docket https://www.courtlistener.com/docket/73493632/1/plenty-v-hilton-grand-vacations-inc/;
  found with the CourtListener search API, `type=r&court=waed`)
- Date fetched: 2026-10-14
- Text layer: yes (`pdftotext` yields text; Times New Roman embedded). Body text measures 14 pt (the
  line-number pitch is 32.2 pt, the double spacing of 14 pt Times).
- Public court record (RECAP). Used as a visual and structural reference only.

## 2. Second filer: `FILED-EXAMPLE-complaint-2.pdf`

- Court: United States District Court, Eastern District of Washington (Spokane Division)
- Case: *Price v. BNSF Railway Co.*
- Docket: No. 2:25-cv-00410 (ECF No. 1)
- Document: Complaint (5 pages), with demand for jury trial
- Filer: Plaintiff Charles Price, by counsel Grube Orehoski, PLLC (Seattle) and Casey Jones Law (pro hac vice forthcoming)
- Date filed: 10/13/25
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.waed.114209/gov.uscourts.waed.114209.1.0.pdf
  (docket https://www.courtlistener.com/docket/71634180/1/price-v-bnsf-railway-co/)
- Date fetched: 2026-10-14
- Text layer: yes. Body text measures about 12 pt, not the 14 pt that LCivR 10(d) requires (see README.md).

## Other filings found and not saved

- *Hartsock v. Battelle Memorial Institute* (4:26-cv-05098-TOR), motion to dismiss: saved under `motion-brief/usage/`.
- *Inman v. Covista Inc* (2:26-cv-00389-ACE, ECF 1, 36 pp.): scanned image with no text layer after page 1; not usable.
- *Angulo v. Providence Health* (4:25-cv-05029, Sixth Amended Complaint): amended pleading, not an original complaint.
