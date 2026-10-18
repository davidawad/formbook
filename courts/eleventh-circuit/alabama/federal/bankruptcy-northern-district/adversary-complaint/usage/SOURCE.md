# Exemplars: adversary complaint (alnb)

Retrieved 2026-10-14. Public court records from the CourtListener RECAP archive (free-law RECAP copies of PACER documents). Each PDF is a text-based file: `pdftotext` reads it.

| File | Filer (counsel) | Case | Document | Date filed | Fetched from |
|---|---|---|---|---|---|
| `FILED-EXAMPLE-adversary-complaint.pdf` | BciCapital, Inc. (Glenn E. Glover and Hirshel M. Hall, Bradley Arant Boult Cummings LLP, Birmingham) | *BciCapital, Inc. v. Montalbano*, Adv. Pro. No. 21-00015 (main case 20-03696-TOM7), Bankr. N.D. Ala., Southern Division | Complaint to Determine the Dischargeability of a Debt under 11 U.S.C. § 523, Doc 1, 7 pages | 2021-03-12 | https://storage.courtlistener.com/recap/gov.uscourts.alnb.693519/gov.uscourts.alnb.693519.1.0.pdf (docket: https://www.courtlistener.com/docket/59728510/1/christopher-anthony-montalbano-adversary-proceeding/) |
| `FILED-EXAMPLE-adversary-complaint-2.pdf` | Debtor-plaintiff Angelica Elizabeth Garner (Melissa W. Larsen, Attorney for Debtor/Plaintiff, Huntsville) | *Garner v. Afterpay*, Adv. Pro. No. 21-80046 (main case 21-80004-CRJ-13), Bankr. N.D. Ala., Northern Division | Adversary Complaint, Doc 1, 3 pages | 2021-04-05 | https://storage.courtlistener.com/recap/gov.uscourts.alnb.694116/gov.uscourts.alnb.694116.1.0.pdf (docket: https://www.courtlistener.com/docket/59795505/1/garner-v-afterpay/) |

Primary exemplar: the BciCapital complaint (sorted first; `tools/overlay.sh` uses the first `usage/*.pdf` by default). It is the more complete form: caption with the `Adv. Pro. No.` line, numbered paragraphs under headings, counts with a prayer each, a jury-free signature block with the filer's name, firm, address and email.

Second filer: Garner. It is short (3 pages) and is used for the tier-2 "different filer" comparison (caption, FACTS heading, signature block with an OF COUNSEL block). Two filers, not three: no further adversary complaint from another filer was located on CourtListener's alnb RECAP search (the API query was `complaint` with `court=alnb`; several other complaints are 2 to 3 pages, mostly pro se).

Caveats: the ECF header line ("Case 21-00015-TOM Doc 1 Filed ...") is the court's stamp, not part of the filed text, and is not reproduced in the template. Social Security numbers in the Garner caption are already masked (XXX-XX-nnnn) by the filer, as Fed. R. Bankr. P. 9037 requires.
