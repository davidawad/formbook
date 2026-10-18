# Exemplar source: complaint (S.D. Miss.)

Date fetched for every file below: 2026-10-14. All are public court records, downloaded from the RECAP archive
(CourtListener's copy of PACER documents, storage.courtlistener.com). Each PDF is text-based: `pdftotext` reads it.

## SAMPLE-mssd-complaint-mariano125cv00363.pdf (primary: the sample and the overlay use this file)

- URL fetched: https://storage.courtlistener.com/recap/gov.uscourts.mssd.131543/gov.uscourts.mssd.131543.1.0.pdf
- Docket page: https://www.courtlistener.com/docket/71988265/1/mariano-v-enviva-llc/
- Case: *Frank Mariano v. Enviva, LLC; Enviva Management Company, LLC; Chevron U.S.A. Inc.; Gulf LNG Energy, LLC; and John Doe Defendants 1–10* (CourtListener's docket caption: *Mariano v. Gulf LNG Energy, LLC*)
- Docket no.: 1:25-cv-00363-HSO-MTP (S.D. Miss., Southern Division)
- Document: Complaint and Demand for Jury Trial (ECF 1), 10 pages. The RECAP entry also carries the civil cover sheet as an attachment; it is not saved here.
- Filer: Plaintiff Frank Mariano, by Marshall Goff (MSB No. 105593), Barlow & Goff, PLLC, Brandon, Mississippi
- Date filed: 12/03/2025 (ECF header "Filed 12/03/25")
- Notes: the counsel block has no fax number (see the complaint README, gaps). The ECF header at the top of each page is not part of the sample.

## SAMPLE-mssd-complaint-myers126cv00266.pdf (second filer; for the tier-2 comparison; not transcribed)

- URL fetched: https://storage.courtlistener.com/recap/gov.uscourts.mssd.135967/gov.uscourts.mssd.135967.1.0.pdf
- Docket page: https://www.courtlistener.com/docket/74790183/1/myers-v-pfizer-inc/
- Case: *Mocha Myers, individually and on behalf of her deceased minor child, K.W., v. Pfizer, Inc. and Global Blood Therapeutics, Inc.*
- Docket no.: 1:26-cv-00266-LG-RPM (S.D. Miss., Southern Division)
- Document: Complaint for Damages (ECF 1, with jury demand), 19 pages
- Filer: Plaintiff, by William H. Eckert, Michael J. Tarleton and Daniel G. Collarini (Eckert & Tarleton, LLC) and Toby Tatum (Tatum Law Firm)
- Date filed: 09/14/2026 (ECF header "Filed 09/14/26")
- Notes: a minor is identified by initials (K.W.), as Fed. R. Civ. P. 5.2(a)(3) requires.

## Searches tried

- CourtListener REST search (`/api/rest/v4/search/`, `type=r` and `type=rd`, `court=mssd`), queries for "COMPLAINT", "COMPLAINT with jury demand" and "COMPLAINT for". Results were filtered to complaints with a stored PDF (`filepath_local`). Pages of 10 to 25 pages with a text layer were preferred.
- Not used: Lewis v. Mississippi Department of Public Safety is a motion memorandum, not a complaint. Wogan v. City of Ridgeland (3:24-cv-431, 60 pp.) and Black v. Luckey (3:26-cv-377, 22 pp., class action) are longer than the 8 to 14 page target.
- The local rules at https://www.mssd.uscourts.gov/court-info/local-rules-and-orders/local-rules were read for the form rules (see the README).
