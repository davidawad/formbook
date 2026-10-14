# Exemplar source: motion-brief (S.D. Miss.)

Date fetched for every file below: 2026-10-14. All are public court records, downloaded from the RECAP archive
(CourtListener's copy of PACER documents, storage.courtlistener.com). Each PDF is text-based: `pdftotext` reads it.

## FILED-EXAMPLE-bryant-3-24-cv-00260-motion-brief.pdf (primary: the sample and the overlay use this file)

- URL fetched: https://storage.courtlistener.com/recap/gov.uscourts.mssd.124854/gov.uscourts.mssd.124854.10.0.pdf
- Docket page: https://www.courtlistener.com/docket/68518473/10/bryant-v-rosenberg/
- Case: *Phil Bryant & Deborah Bryant v. Michael Rosenberg & The Arena Group Holdings, Inc.*
- Docket no.: 3:24-cv-260-KHJ-MTP (S.D. Miss., Northern Division)
- Document: Defendant Michael Rosenberg's Memorandum in Support of Motion to Dismiss (ECF 10; the motion it supports is ECF 9), 8 pages, with a certificate of service on page 8
- Filer: Defendant Michael Rosenberg, by S. Ray Hill, III (MSB No. 100088), Clayton O'Donnell, PLLC, Oxford, Mississippi
- Date filed: 07/22/2024 (ECF header "Filed 07/22/24")
- Notes: the filing carries two footnotes (on page 1). The text layer shows italics on only a few spans (for example "Federal Rules of Civil Procedure", "Favre v. Sharpe", "Twombly", "Cook v. Mardi Gras Casino", "Prescott", "See e.g."); most case names are roman in the filing. The sample italicizes case names per L.U.Civ.R. 7(b)(5)(C) (see the README, gaps). The ECF header is not part of the sample.

## FILED-EXAMPLE-petrini-1-25-cv-00233-motion-brief.pdf (second filer; for the tier-2 comparison; not transcribed)

- URL fetched: https://storage.courtlistener.com/recap/gov.uscourts.mssd.129977/gov.uscourts.mssd.129977.67.0.pdf
- Docket page: https://www.courtlistener.com/docket/70906957/67/petrini-v-city-of-biloxi-mississippi/
- Case: *Yuri Petrini and Sumire Maeda v. City of Biloxi, Mississippi, et al.*, administratively consolidated with 1:25cv178-LG-RPM and 1:25cv254-LG-RPM
- Docket no.: 1:25-cv-00233-LG-RPM (S.D. Miss., Southern Division)
- Document: Brief in Support of Motion to Dismiss Defendants Peter C. Abide and Currie Johnson & Myers, P.A. (ECF 67; the motion, a Rule 12(b)(1) motion for lack of jurisdiction, is ECF 66), 15 pages
- Filer: Defendants Peter C. Abide and Currie Johnson & Myers, P.A., by their counsel of record
- Date filed: 01/20/2026 (ECF header "Filed 01/20/26")
- Notes: Times New Roman body text; a 12(b)(1) brief, so the case names and signals differ from the Bryant brief.

## Searches tried

- CourtListener REST search, `type=rd` and `type=r`, `court=mssd`, queries for "memorandum in support of motion to dismiss", "memorandum brief in support", "motion to dismiss" with "12(b)(6)" and "memorandum". Results were filtered to documents with a stored PDF (`filepath_local`). Most MSSD memoranda in RECAP are attachments without a stored PDF.
- Not used as a file: Lewis v. Mississippi Department of Public Safety (3:25-cv-721-KHJ-MTP, ECF 8, memorandum in support of motion to dismiss, 10 pp., filed Dec. 5, 2025; URL https://storage.courtlistener.com/recap/gov.uscourts.mssd.130596/gov.uscourts.mssd.130596.8.0.pdf). Its body is Times New Roman (checked with pdftohtml). It is a usable third filer for the tier-2 comparison, but it is not saved here: Bryant is complete in 8 pages and includes the certificate of service. Schmidt v. Rankin County (3 pp.) and Harvison v. G.A. West (7 pp.) were too short to show the full structure.
- The motion itself (the four-page motion under L.U.Civ.R. 7(b)(2)(B)) is a separate document and was not searched for; see the README.
