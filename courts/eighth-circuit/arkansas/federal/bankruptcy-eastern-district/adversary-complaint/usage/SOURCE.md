# Exemplars: adversary complaint (areb, Eastern District of Arkansas)

Exemplar saved: `FILED-EXAMPLE-adversary-complaint.pdf` (9 pages).

- Pages 1-2: the B1040 adversary proceeding cover sheet, filed with the complaint.
- Pages 3-9: the complaint, through the signature block. The complaint body is 7 pages.
- Pages 10-22 of the RECAP document (state-court exhibits A and B, the Van Buren County orders) were removed. Nothing else was changed; the pages are copied as filed.

| Field | Value |
|---|---|
| Exemplar file | `FILED-EXAMPLE-adversary-complaint.pdf` |
| URL fetched from | https://storage.courtlistener.com/recap/gov.uscourts.areb.315556/gov.uscourts.areb.315556.1.0.pdf (RECAP document 1, 22 pp.; docket page https://www.courtlistener.com/docket/73210980/1/franks-v-watkins-ii/) |
| Case name / docket no. | *Franks et al. v. Watkins* (CourtListener caption "Bruce Watkins, II and Heida Farque Watkins - Adversary Proceeding"), Adv. No. 4:26-ap-01015, E.D. Ark., Central Division. Underlying Chapter 7 case No. 4:25-bk-10241 (Judge Rucker, per the cover sheet). |
| Filer | Plaintiffs (Margie Geniece Franks; Benny Rex Harper and Martha Ruth Harper, trustees; the Estate of William (Dub) Henry Harper; and others), by Branch T. Fields, Lax, Vaughan, Fortson, Rowe & Threet, P.A. |
| Date filed | 04/17/2026 (date on the cover sheet; CourtListener docket date 2026-04-17). The complaint body carries no date stamp. |
| Date fetched | 2026-10-14 |
| Why this one | Text-based (embedded text layer, 22-page RECAP document); recent (2026) E.D. Ark. filing by counsel; a caption with several plaintiffs and two debtors; a numbered complaint with counts, prayer and counsel block. |

## Search log (2026-10-14)

Earlier searches (2026-10-14, first pass) found no complaint PDF. This pass used the CourtListener REST search API, which answers without a login when the request carries a browser user agent. Its HTML search pages return 403. Storage downloads from `storage.courtlistener.com` work.

| Source | Result |
|---|---|
| `courtlistener.com/api/rest/v4/search/?type=r&court=areb` (RECAP) | About 2,480 RECAP hits for "adversary complaint". Many AREB adversary dockets carry an available complaint PDF. |
| Rice v. Riffenburg, 4:23-ap-01024, doc 1 (17 pp., 04/14/2023, trustee complaint) | Rejected. Scanned images only (CCITT); no text layer. |
| Young v. National Collegiate Student Loan Trust, 4:23-ap-01017, doc 1 (4 pp., 2023) | Text-based but only 4 pages. Kept as a fallback. |
| McCoy Counseling, LLC, 4:24-ap-01004, doc 10 (6 pp., 2024) | Text-based, 6 pages. Kept as a fallback. |
| Watkins, 4:26-ap-01015, doc 1 (22 pp., 2026) | Text-based, complete with cover sheet and complaint. **Used.** |
| govinfo, areb.uscourts.gov opinions, Justia, PACER | Opinions only, or login required. Not used for the complaint. |

Caveat: the chosen filing is a dischargeability complaint under § 523(a)(6) with a § 727(a)(6)(A) objection. It is not a turnover or trustee complaint. That is the only recent, text-based, complete AREB complaint found, and the template is built for general adversary complaints. The filing's exhibits are not part of the transcription.
