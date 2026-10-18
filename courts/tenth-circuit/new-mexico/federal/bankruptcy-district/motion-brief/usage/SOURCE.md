# Exemplar source: motion-brief (D.N.M. bankruptcy)

| Field | Value |
|---|---|
| File | `SAMPLE-nmb-motion-brief-romancatholic1813027.pdf` |
| Court | United States Bankruptcy Court, District of New Mexico (`nmb`) |
| Case | In re Roman Catholic Church of the Archdiocese of Santa Fe, a New Mexico corporation sole, Case No. 18-13027-t11 (Chapter 11). Main case, contested matter; no adversary number. |
| Document | Memorandum of Points and Authorities in Support of Motion of the Official Committee of Unsecured Creditors (i) for exclusive and irrevocable authority to commence, prosecute, and settle adversary proceedings on behalf of the bankruptcy estate against certain diocese-related entities; and (ii) to compel the debtor to produce information revealing the ten parishes with the largest purported interests in the Deposit and Loan Fund (ECF Doc. 383, 54 pages) |
| Filer | Official Committee of Unsecured Creditors (counsel: Pachulski Stang Ziehl & Jones LLP, James I. Stang) |
| Date filed | 2020-05-29 (header: "Filed 05/29/20"; docket entry "Entered 05/29/20 13:48:37") |
| Fetched from | https://storage.courtlistener.com/recap/gov.uscourts.nmb.163984/gov.uscourts.nmb.163984.383.0_2.pdf |
| Docket page | https://www.courtlistener.com/docket/8344906/383/roman-catholic-church-of-the-archdiocese-of-santa-and-associated-case-in-us/ (CourtListener docket 8344906; the CourtListener entry label is "Motion to Compel Memorandum of Points and Authorities in Support of Motion ...") |
| Date fetched | 2026-10-15 |
| sha256 | `77345ead28057aaec19694bb3ac19ee61b0f5be83f3c4b24c8617aa1a0a7c151` (763,260 bytes) |

Text layer: yes. `pdffonts` shows Times New Roman (non-embedded) and Liberation Sans for the ECF header and footer; body text extracts with `pdftotext`. Pages read for the sample: 1 (caption), 3 to 20 (text extracted and cleaned), 50 to 51 (conclusion, prayer, signature). The rest of the 54 pages (tables, argument, service list) was not transcribed.

Public court record (RECAP). Found by CourtListener REST search `type=rd`, `court=nmb`, query `"memorandum in support"`. The motion this memorandum supports is a separate filing and is not in `usage/`. The ECF service list (pp. 52 to 54) follows the signature block.

## Why this exemplar

- It is the only motion-with-memorandum found in this court with a text layer and a party filer (the others were opinions or images): see the README's "Searches tried".
- It is a main-case contested matter, not an adversary filing. The sample uses the no-adversary caption (debtor box, chapter, case number). The adversary caption stays in the template for adversary-complaint and adversary motions.

## Rejected candidates (checked 2026-10-15)

| Case | Docket | Filer | Filed | Reason |
|---|---|---|---|---|
| Smith v. Wilson | Adv. 12-01330-t, Doc 21 | Linda Wilson (defendant) | 2013-04-12 | Brief in Support of Motion to Dismiss, 5 pp. The text layer has only the ECF header; the body is an image. Not a text PDF. |
| Van Winkle (Belleview Land Co.) | 13-11743-t7, Doc 123 | Belleview Land Co. (creditor) | 2020-10-29 | Withdrawn memorandum in support of summary judgment, 23 pp. The text layer has only the ECF header; the body is not extractable. |

## Not used (other filings in this court, for the next pass)

| Case | Docket | Filer | Filed | Notes |
|---|---|---|---|---|
| Monarchy Rancheros de Santa Fe LLC | 25-10691-j11, Doc 131 | (court) | 2025-08-04 | Entry is "Memorandum Opinion Regarding Motion to Dismiss", a court opinion. |
| Lashinsky v. Lincoln III | Adv. 24-1011-j, Doc 29 | Lincoln (counter-claimant) | 2024-09-13 | Entry is a brief, but RECAP has no PDF for it (`is_available: false`). Not downloadable. |
