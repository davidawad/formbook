# Exemplar source: complaint, dcd

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-terre-du-soleil-1-26-cv-03510-complaint.pdf` |
| URL fetched | https://storage.courtlistener.com/recap/gov.uscourts.dcd.297436/gov.uscourts.dcd.297436.1.0.pdf |
| Docket page | https://www.courtlistener.com/docket/74934336/terre-du-soleil-ltd-v-united-states-small-business-administration/ (entry 1) |
| Case | *Terre du Soleil, Ltd. d/b/a Auberge du Soleil v. United States Small Business Administration, et al.* |
| Docket no. | 1:26-cv-03510 (D.D.C.) |
| Document | ECF No. 1, Complaint for Declaratory and Injunctive Relief and Vacatur (APA), 29 pages |
| Filer | Terre du Soleil, Ltd. d/b/a Auberge du Soleil, by counsel Clark Hill PLC (J. Chris White, D.C. Bar No. 1742758) |
| Date filed | 2026-10-07 (PDF header: "Filed 10/07/26") |
| Date fetched | 2026-10-14 |
| Text layer | yes (`pdftotext` yields text; fonts are not embedded, Times New Roman by name) |
| Public record | RECAP document, public court record |
| Second filer | not saved (the brief asks for one exemplar per doc type). Search hit for a second DDC complaint: *McWilliams Ballard, Inc. v. 1128 Tenth Street NW, LLC*, 1:26-cv-03533, ECF 1 (5 pages, storage.courtlistener.com/recap/gov.uscourts.dcd.297485/gov.uscourts.dcd.297485.1.0.pdf). Not judged; tier 2 is therefore judged against one filer (see README.md). |

## 2. Second filer: Senate Majority PAC v. Federal Election Commission

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-smp-1-26-cv-00336-complaint.pdf` |
| Court | United States District Court for the District of Columbia |
| Case | *SMP (Senate Majority PAC) v. Federal Election Commission* |
| Docket no. | 1:26-cv-00336 (D.D.C.); the complaint's caption leaves "Civil Action No." blank. The number is from the FEC's case page title "SMP v. FEC (26-336)", where this complaint is listed, and from the ECF header "Case 1:26-cv-00336-BAH" on later filings in the case posted on the same page. |
| Document | "COMPLAINT FOR DECLARATORY AND INJUNCTIVE RELIEF" (12 pages, 46 numbered paragraphs, requested relief, signature) |
| Filer | Plaintiff Senate Majority PAC, by David R. Fox (D.C. Bar No. 1015031), Elias Law Group LLP, Washington, D.C. |
| Date filed | 2026-02-05 (signature "Dated: February 5, 2026"; the FEC case page lists the complaint under 02-05-2026) |
| URL fetched | https://www.fec.gov/documents/6084/elg-pls-comp-for-dec-and-inj-relief-02-05-2026.pdf (Federal Election Commission litigation page https://www.fec.gov/legal-resources/court-cases/smp-v-fec-26-336/) |
| Date retrieved | 2026-10-17 |
| Text layer | Yes (Microsoft Print to PDF; `pdftotext` yields the full text). No ECF header stamp: this is the filer's PDF as posted by the FEC, not the court's stamped copy. Fonts: embedded CID subsets plus non-embedded Times-Roman. |
| sha256 | `dd53718cda0e4d30aedbd65921091ed008d19c56a66d400911f78a1710a38c14` |
| Different filer | Yes: different party and different counsel from Terre du Soleil (Clark Hill PLC) |
| Why not RECAP | CourtListener storage returned HTTP 429 (rate limit) on 2026-10-17, so the McWilliams Ballard complaint noted above could not be fetched. |
