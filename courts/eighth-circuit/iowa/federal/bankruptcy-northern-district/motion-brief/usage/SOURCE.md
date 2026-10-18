# Exemplars: motion with memorandum, United States Bankruptcy Court, N.D. Iowa (ianb)

Fetched 2026-10-14. Both are public court records from CourtListener RECAP, downloaded from `storage.courtlistener.com`. Both have a text layer.

Neither exemplar is a complete "motion with memorandum" in one PDF. The N.D. Iowa filings found either attach the brief to a motion (Gray) or argue the grounds in the motion itself without a separate brief (VeroBlue). The template covers both shapes; see `../README.md`.

## 1. FILED-EXAMPLE-motion-brief.pdf (3 pages): the memorandum only

| Item | Value |
|---|---|
| Case | *First Security Bank & Trust Company v. James A. Gray*, Adversary No. 20-09040, in *In re McQuillen Place Company, LLC*, Chapter 7 Case No. 19-00507 |
| Court | United States Bankruptcy Court, N.D. Iowa |
| Document | "Brief in Support of Motion to Dismiss" (RECAP attachment 1 to the motion, docket entry 5 on CourtListener docket 105036). The motion itself (entry 5, main document) is **not** in RECAP storage: `gov.uscourts.ianb.105036.5.0.pdf` returns NoSuchKey. |
| Filer | Defendant James A. Gray, by counsel Peter C. Riley, AT0006611, Tom Riley Law Firm, P.L.C., Cedar Rapids, IA |
| Date filed | Not on the document. The RECAP entry date was not retrieved (the CourtListener docket API returned no record for 105036). |
| Fetched from | https://storage.courtlistener.com/recap/gov.uscourts.ianb.105036/gov.uscourts.ianb.105036.5.1.pdf |
| Found by | CourtListener search API, `type=rd`, `court=ianb`, query "Brief" filtered to descriptions containing "Motion" (entry: "Motion to Dismiss Adversary Proceeding Filed by James A. Gray. (Attachments: # 1 Brief)") |
| Notes | The search result carried no case name or date; the caption on the brief itself supplies the case, the number, and the filer. Typeset in Times New Roman (per `pdffonts`). |

## 2. FILED-EXAMPLE-motion-brief-2.pdf (6 pages): motion with facts, no separate brief

| Item | Value |
|---|---|
| Case | *VeroBlue Farms USA, Inc. v. Cassels Brock & Blackwell LLP*, Adversary No. 19-09015, in *In re VeroBlue Farms USA, Inc.*, Chapter 11 Bankruptcy No. 18-01297 |
| Court | United States Bankruptcy Court, N.D. Iowa |
| Document | Doc. 13, "Motion to Strike and to Seal Portions of Doc. No. 1 Pursuant to Fed. Bank. R. 7012 and Fed. R. Civ. P. 12(f)" |
| Filer | Cassels Brock & Blackwell LLP (defendant), by local counsel Michael D. Schwartz, AT0013972, Schwartz Law Firm, Oakdale, MN |
| Date filed | July 15, 2019 (dated and "Entered: 07/15/2019" on the CourtListener record) |
| Fetched from | https://storage.courtlistener.com/recap/gov.uscourts.ianb.102432/gov.uscourts.ianb.102432.13.0.pdf |
| Docket page | https://www.courtlistener.com/docket/1781320/13/veroblue-farms-usa-inc-v-cassels-brock-blackwell-llp/ |
| Found by | CourtListener search API, `type=r`, `court=ianb`, query "motion": "Motion to Strike and Seal Portions of Doc. No. 1 ..." |
| Notes | Produced in Microsoft Word 2016. It is a motion with a "facts upon which the motion is based" section and a certificate of service, with no separate brief. |

## Searches that did not produce a complete memorandum

- `type=rd` queries for "Motion to Dismiss", "Motion for Summary Judgment", "Brief in support", "Memorandum", "Motion to Dismiss brief" with the court set to `ianb` returned nothing with the description filter.
- Brief-type RECAP entries for Viner Law Firm (`gov.uscourts.ianb.111821.16.0.pdf`, 13 pages, a brief supporting a summary-judgment motion) were not downloaded; the brief supports a motion for summary judgment (FRCP 56 / FRBP 7056), which the template does not separately cover.
