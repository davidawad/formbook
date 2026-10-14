# Exemplar sources: W.D. Pa. complaint

Date fetched for every item: **2026-10-14**. All three are public court records (RECAP copies of PACER filings).
How they were found: CourtListener search API (`https://www.courtlistener.com/api/rest/v4/search/?q=%22complaint%22+%22jury+trial+demanded%22&court=pawd&type=r`), then the RECAP storage URL of each document.

## 1. Primary exemplar (transcribed into `samples/INPUT-cragle-complaint.md`)

File: `FILED-EXAMPLE-cragle-2-26-cv-02200-complaint.pdf` (11 pages, text layer present, `pdftotext` yields text)

| Field | Value |
|---|---|
| Case | *Robert Cragle v. AVI Foodsystems, Inc.* |
| Court and docket | U.S. District Court, W.D. Pa., No. 2:26-cv-02200-WSS (civil action no. as printed: 2:26-cv-2200) |
| Document | ECF No. 1, "Complaint in a Civil Action" (with jury demand) |
| Filer | Plaintiff Robert Cragle, by Law Offices of Joel Sansone (Joel S. Sansone, Elizabeth A. Tuttle, Massimo A. Terzigni, Amanda N. Shields) |
| Date filed | 2026-10-07 (header: "Filed 10/07/26") |
| URL fetched | `https://storage.courtlistener.com/recap/gov.uscourts.pawd.336819/gov.uscourts.pawd.336819.1.0.pdf` |
| Docket page | `https://www.courtlistener.com/docket/74934781/1/cragle-v-avi-foodsystems-inc/` |

## 2. Second filer, for the tier-2 comparison (saved, not transcribed)

File: `FILED-EXAMPLE-snee-2-22-cv-00119-complaint.pdf` (41 pages, text layer present)

| Field | Value |
|---|---|
| Case | *Thomas Snee v. Philips North America LLC, et al.* |
| Court and docket | U.S. District Court, W.D. Pa., No. 2:22-cv-00119-JFC |
| Document | ECF No. 1, "Class Action Complaint (Jury Trial Demanded)" |
| Filer | Plaintiff Thomas Snee, by David Pastor (a different firm from the primary exemplar) |
| Date filed | 2022-01-04 (header: "Filed 01/04/22") |
| URL fetched | `https://storage.courtlistener.com/recap/gov.uscourts.pawd.286294/gov.uscourts.pawd.286294.1.0.pdf` |

Caption note: the printed court heading on this filing reads "UNITED STATES DISTRICT COURT / DISTRICT OF MASSACHUSETTS" with "C.A. No.", although the ECF header shows the W.D. Pa. case (2:22-cv-00119-JFC). The template does not follow that heading. The document is used for structure (class-action complaint, numbered paragraphs, prayer, jury demand) only.

## Search record (complaint)

- CourtListener RECAP, `court=pawd`, complaints with "jury trial demanded": hits included Cragle (2:26-cv-02200), Snee (2:22-cv-00119), Meyerl v. Carrington Mortgage (2:16-cv-00027, 14 pp., W.D. Pa. caption, not used: a third filer was not needed), and notices of removal (not complaints).
- Clearinghouse (`clearinghouse.net`) entries for W.D. Pa. complaints were found by web search, but its document pages returned HTTP 403 to curl and to WebFetch, so they were not used.
