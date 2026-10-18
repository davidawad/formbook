# Exemplar sources: ca2 reply brief

Both exemplars are public court records: documents filed on the docket of the U.S. Court of Appeals for the Second Circuit and published through the RECAP archive. Each was found through the CourtListener search API (`/api/rest/v4/search/`, `type=r`, `court=ca2`, query "reply brief") and downloaded from the RECAP storage link below. Date fetched for both: 2026-10-14.

## 1. Primary: `SAMPLE-ca2-reply-brief-lowemoneylion26655.pdf`

| Field | Value |
|---|---|
| Case | *Lowe v. MoneyLion Technologies Inc.* (Second Circuit caption: James Lowe et al., Plaintiffs-Appellees, v. MoneyLion Technologies Inc. d/b/a MoneyLion, Defendant-Appellant) |
| Docket no. | 26-655 (S.D.N.Y. No. 1:25-cv-4098, Hon. Dale E. Ho) |
| Document | Reply Brief of Defendant-Appellant MoneyLion (DktEntry 53.1), 45 pages |
| Filer | Defendant-Appellant MoneyLion Technologies Inc. (counsel: McGuireWoods LLP; Cooley LLP) |
| Date filed | September 10, 2026 (ACMS service date 09/10/2026) |
| Fetched from | https://www.courtlistener.com/docket/72507074/53/lowe-v-moneylion-technologies-inc/ (docket entry page) |
| PDF | https://storage.courtlistener.com/recap/gov.uscourts.ca2.9b0bb736-84b9-4eb8-865d-57c33b012586/gov.uscourts.ca2.9b0bb736-84b9-4eb8-865d-57c33b012586.53.0.pdf |
| Date fetched | 2026-10-14 |
| Text layer | yes (`pdftotext` yields the full text; set in Century Schoolbook, which its own certificate of compliance states is 14-point) |

## 2. Second filer, for conventions: `SAMPLE-ca2-reply-brief-alisigwe24960.pdf`

| Field | Value |
|---|---|
| Case | *United States v. Alisigwe* (Chinwendu Alisigwe, a/k/a Sealed Defendant 1, Defendant-Appellant) |
| Docket no. | 24-960-cr (S.D.N.Y.) |
| Document | Reply Brief for Defendant-Appellant Chinwendu Alisigwe, 36 pages |
| Filer | Federal Defenders of New York, Inc., Appeals Bureau (criminal appeal; a different filer and style from the Lowe brief) |
| Date filed | December 18, 2024 (ACMS service date 12/18/2024) |
| Fetched from | https://www.courtlistener.com/docket/69014013/47/united-states-of-america-v-alisigwe/ (docket entry page) |
| PDF | https://storage.courtlistener.com/recap/gov.uscourts.ca2.5cc7d88d-b0f3-4cf3-bd2f-e3ab38b8e038/gov.uscourts.ca2.5cc7d88d-b0f3-4cf3-bd2f-e3ab38b8e038.47.0.pdf |
| Date fetched | 2026-10-14 |
| Text layer | yes (Palatino) |

The Alisigwe brief is kept for comparison of conventions (table of contents, point headings, certificate). It is not overlaid: the overlay (`usage/OVERLAY-lowe-reply-brief.pdf`) is against the Lowe exemplar, which is the one transcribed in `usage/`.

## Other sources tried

- Clearinghouse (clearinghouse.net/doc/21976, Abdullah v. INS, 1997 reply brief): HTTP 401/403 to this box.
- Justia (cases.justia.com ca2 docket PDFs): HTTP 403 to this box.
- NYLS Digital Commons: reachable, but its Second Circuit items are 1990s briefs, not used.
