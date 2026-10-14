# Exemplars: motion with memorandum (alnb)

Retrieved 2026-10-14. Public court records from the CourtListener RECAP archive. Both PDFs are text-based: `pdftotext` reads them.

| File | Filer (counsel) | Case | Document | Date filed | Fetched from |
|---|---|---|---|---|---|
| `FILED-EXAMPLE-dombrowski-v-american-estate-17-80079-motion-brief.pdf` | United States of America (Mary Elizabeth Smith, Trial Attorney, Tax Division, U.S. Department of Justice; Richard E. O'Neal, AUSA, N.D. Ala.) | *Dombrowski v. American Estate & Trust, LC*, Adv. Proc. No. 17-80079-CRJ (main case 16-81412-CRJ-11), Bankr. N.D. Ala., Northern Division | United States' Motion to Dismiss (Fed. R. Civ. P. 12(b)(1) and 12(b)(6), with argument), Doc 37, 11 pages | 2018-05-07 | https://storage.courtlistener.com/recap/gov.uscourts.alnb.649537/gov.uscourts.alnb.649537.37.0_2.pdf (docket: https://www.courtlistener.com/docket/6391081/37/dombrowski-v-american-estate-trust-lc/) |
| `FILED-EXAMPLE-wright-v-belmont-hill-19-80069-motion-brief.pdf` | Defendant National Credit Systems, Inc. (William P. Traylor III, private counsel) | *Wright v. Belmont Hill Apartments*, Adv. No. 19-80069-CRJ (main case 19-81669-CRJ-7), Bankr. N.D. Ala., Northern Division | Defendant NCS's Motion to Dismiss Complaint Pursuant to Fed. R. Civ. P. 12(b)(6), with memorandum, Doc 6, 8 pages | 2019-10-14 | https://storage.courtlistener.com/recap/gov.uscourts.alnb.677000/gov.uscourts.alnb.677000.6.0.pdf (docket: https://www.courtlistener.com/docket/16070392/6/wright-v-belmont-hill-apartments/) |

Primary exemplar: the Dombrowski motion (sorted first; the default for `tools/overlay.sh`). It is a Rule 12 motion in an adversary proceeding, filed by the United States, with the argument embedded in the motion (Roman-numbered parts, A./B./C. sub-headings, a WHEREFORE prayer, a signature block, and a certificate of service listing every party served).

Second filer: Wright (a private practitioner). It has the same Roman/A. heading scheme, numbered paragraphs, and a running footer carrying the document title and "Page n". Used for the tier-2 comparison across filers.

The Dombrowski motion is set by the same ECF stamp as the complaint ("Case 17-80079-CRJ Doc 37 Filed ...") and the Wright motion's footer is the filer's own. Neither stamp is reproduced in the template.

The N.D. Ala. bankruptcy local rules (current revision, March 1, 2023 PDF) have no typeface, margin or page-limit rule for motions; the 2023 text was read in full for the rules cited in the README. The exemplars settle only the open choices (heading style, caption layout, signature block).
