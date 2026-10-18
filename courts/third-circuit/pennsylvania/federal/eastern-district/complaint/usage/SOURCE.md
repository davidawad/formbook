# Exemplar sources: paed complaint

| Field | Value |
|---|---|
| Saved file | `SAMPLE-paed-complaint-murphy226cv07848.pdf` (22 pages, text layer present, pdffonts: TimesNewRoman embedded) |
| URL fetched from | https://storage.courtlistener.com/recap/gov.uscourts.paed.663619/gov.uscourts.paed.663619.1.0.pdf (RECAP document 1 of docket 2:26-cv-07848, reached from https://www.courtlistener.com/docket/74955140/1/murphy-v-lexisnexis-risk-solutions-inc/) |
| Case | *Murphy v. LexisNexis Risk Solutions, Inc.* |
| Court | United States District Court, E.D. Pa. |
| Docket no. | 2:26-cv-07848 (assigned judge initials GAW in the ECF header) |
| Document | Complaint and Jury Demand (FCRA, 15 U.S.C. § 1681e(b), 1681i) |
| Filer | Plaintiff Logan Reid Murphy, counsel Richard H. Kim, The Kim Law Firm, LLC, Philadelphia (signature block on page 22) |
| Date filed | October 13, 2026 (ECF header "Filed 10/13/26") |
| Date fetched | October 14, 2026 |
| Public record | Yes: RECAP copy of a public ECF filing; no sealed or redacted material in the transcribed parts |

## Search trail

CourtListener REST search, `type=r`, `court_id:paed`, query `short_description:complaint`, ordered by filing date (2026-10-08 to 2026-10-13). Candidates checked for a text layer with `pdftotext`:

| Case | Docket | Pages | Text layer | Filer | Status |
|---|---|---|---|---|---|
| Murphy v. LexisNexis Risk Solutions | 2:26-cv-07848 | 22 | yes | Kim Law Firm (Richard H. Kim) | **saved** |
| Evenstad v. CoilPlus, Inc. | 2:26-cv-07849 | 28 | yes | Gurmankin (Caren Gurmankin) | not saved; second-filer check |
| J v. La Academia Partnership Charter School | 5:26-cv-07843 | 15 | not checked | Zeff (Gregg Zeff) | not saved |
| Johnson v. La Academia Partnership Charter School | 5:26-cv-07834 | 12 | yes | Zeff (Gregg Zeff) | not saved; second-filer check |
| Gaines v. Urban Outfitters Inc. | 2:26-cv-07850 | 8 | no (528 characters: image or fonts without text) | not identified | rejected |
| Rabidoux v. Novo Nordisk A/S | 2:26-cv-07835 | 11 | no (695 characters) | Aminolroaya | rejected |

The tier-2 rule asks for two or three exemplars from different filers. The brief asks for one saved exemplar per doc type. The second-filer candidates (Evenstad, Johnson) were located and their text layers confirmed but not saved, so **tier 2 is judged against one filer only** (see the README, "Known gaps").

The overlay pairs against `SAMPLE-paed-complaint-murphy226cv07848.pdf` (the first `usage/*.pdf` in the folder).

## 2. Second filer: `SAMPLE-paed-complaint-doe525cv02070.pdf`

| Field | Value |
|---|---|
| Court | United States District Court, E.D. Pa. (`paed`) |
| Case | *Student Doe v. Kristi Noem, in her official capacity as Secretary of Homeland Security, et al.* |
| Docket / document | No. 5:25-cv-02070 (judge initials CH in the ECF header), Document 1 |
| Pages | 19 |
| Text layer | yes (`pdftotext` yields the text; Times New Roman embedded; about 14 pt, line pitch about 32 pt) |
| Document | Complaint (untitled beyond the caption; sections "INTRODUCTION" through "PRAYER FOR RELIEF"; numbered paragraphs) |
| Filer | Plaintiff Student Doe; counsel Karen L. Hoffmann, Ellenberg Law Group, Philadelphia (counsel block at the top left of page 1, Pa. attorney ID printed) |
| Date filed | 2025-04-24 (ECF header "Filed 04/24/25") |
| URL fetched | https://web.archive.org/web/20250426081354id_/https://storage.courtlistener.com/recap/gov.uscourts.paed.636620/gov.uscourts.paed.636620.1.0.pdf (Internet Archive copy of the CourtListener RECAP file) |
| Date retrieved | 2026-10-17 |
| sha256 | `3934539fd18bf4a4cd1102c1c6409be3c4e2e2dbd6770208a5cb38c60ee7ca1b` |

Found by: the CourtListener search API was throttled on 2026-10-17; RECAP URLs for `paed` were listed from the Internet Archive CDX index of `storage.courtlistener.com`, and docket-entry-1 files of recent cases were read by page 1. Different party and counsel from Murphy (The Kim Law Firm).
