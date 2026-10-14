# Exemplars: adversary complaint (U.S. Bankruptcy Court, D. Utah)

Two filed complaints, from different filers, both public RECAP documents on CourtListener.

| File | Case | Docket | Filer | Date filed | Date fetched |
|---|---|---|---|---|---|
| `FILED-EXAMPLE-plaza106-26-02063-adversary-complaint.pdf` | *Plaza 106, LLC v. First Utah Bank*, Adv. No. 26-02063 (Bankr. D. Utah, Central Div.) | 26-02063 (bankr. no. 25-bk-25459-PH) | Plaza 106, LLC, debtor in possession, by Valerga Lawyers (Brody Valerga); "Verified Complaint" | 2026-04-17 | 2026-10-14 |
| `FILED-EXAMPLE-clauson-23-02053-adversary-complaint.pdf` | *Thomson v. Clauson*, Adv. No. 23-02053 (Bankr. D. Utah) | 23-02053 (bankr. no. 21-23249) | Michael Thomson, Chapter 7 trustee, by Greenberg Traurig, LLP (Michael F. Thomson, Carson Heninger) | 2023-07-26 | 2026-10-14 |

Source URLs (CourtListener docket pages; the PDFs were fetched from the RECAP archive):

- Plaza 106: https://www.courtlistener.com/docket/73210741/plaza-106-llc-adversary-proceeding/ (complaint, Doc 1; RECAP path `recap/gov.uscourts.utb.478798/gov.uscourts.utb.478798.1.0_1.pdf`)
- Clauson: https://www.courtlistener.com/docket/68100763/robert-ronald-clauson-adversary-proceeding/ (complaint, Doc 1; RECAP path `recap/gov.uscourts.utb.458698/gov.uscourts.utb.458698.1.0.pdf`)

Found via the CourtListener search API (`/api/rest/v4/search/?type=r&court=utb`), which lists the RECAP documents of the court's adversary dockets.

Other candidates considered and not kept: Bundy (24-02130, Doc 1, 55 pp. with exhibits; not kept as the sample because the complaint body runs to the exhibits), Plaza 106 Amended Complaint (Doc 18, not fetched).

## Notes for reviewers

- Neither filing contains the FRBP 7008(a) statement of consent to final orders by the bankruptcy court (see `../README.md`, gap ADV-7008). This is a finding about the filings, not a reason to omit the statement from the template.
- The sample (`../samples/INPUT-plaza106-verified-complaint.md`) transcribes the Plaza 106 filing, which is the exemplar the overlay uses.
