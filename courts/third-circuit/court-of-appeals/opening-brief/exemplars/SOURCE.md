# Exemplar source

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-tresslar-26-1367-opening-brief.pdf` (70 pp.; the brief is pp. 1-42, then the Joint Appendix Volume I cover and index) |
| Case name | *Lisa Tresslar v. J. Jermaine Greene, Sr., et al.* |
| Court / docket | U.S. Court of Appeals for the Third Circuit, No. 26-1367 |
| Filing | Brief of Appellant (with Joint Appendix Vol. I, Appx0001-Appx0022) |
| Filer | Lisa Tresslar, Appellant; counsel The Gold Law Firm, P.C. (Brian C. Farrell, William Rieser, Sidney L. Gold) |
| Date filed | 2026-07-27 (ECF docket entry 22; the brief is dated July 27, 2026) |
| Fetched from | https://storage.courtlistener.com/recap/gov.uscourts.ca3.127300/gov.uscourts.ca3.127300.22.0.pdf (CourtListener RECAP; docket page https://www.courtlistener.com/docket/72354879/22/lisa-tresslar-v-northampton-county-court-of-common-pleas/) |
| Date fetched | 2026-10-14 |
| Text layer | yes (`pdftotext` returns the body; the Joint Appendix pages are not needed) |
| Public record | yes: a public ECF filing in a federal appellate docket, retrieved from RECAP |

## Why this exemplar

It is a text-based, complete brief in this court with the full section order required by FRAP 28(a) and L.A.R. 28.1 (cover, TOC, TOA, jurisdiction, issues with appendix designations, related-cases statement after the issues, statement of the case, summary, standard of review, argument, conclusion, signature, certificates). It is one filer.

## Second reference, consulted but not saved

For the tier-2 cross-check the template also looked at a second filer's appellant brief in this court: *Gaia Gardens LLC v. Township of Montclair*, No. 26-2749, "Plaintiffs-Appellants' Opening Brief and Joint Appendix" (Van Ness Feldman LLP), CourtListener RECAP `gov.uscourts.ca3.128701.16.0`, filed 2026-09-08. It is set in Century Schoolbook and places a corporate disclosure statement at page i (the Tresslar filing has none, as its filer is an individual). It was not saved here because `overlay.sh` pairs against the first PDF in `exemplars/`.

## 2. Second filer: United States v. Harris, No. 21-3031 (Brief for Appellant)

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-harris-21-3031-opening-brief.pdf` (73 pp.; the brief with Appendix Volume I, Appx1-9, bound in) |
| Court | U.S. Court of Appeals for the Third Circuit |
| Case | *United States of America v. Erik Matthew Harris* (on appeal from W.D. Pa. No. 2:19-cr-00313) |
| Docket / document | No. 21-3031, Document 25-1 (ECF header "Case: 21-3031 Document: 25-1 Page: 1 Date Filed: 04/06/2022") |
| Document title | Brief for Appellant |
| Filer | Appellant Erik Matthew Harris; counsel Federal Public Defender for the Western District of Pennsylvania (Lisa B. Freeland, Federal Public Defender; Renee Pietropaolo, Assistant Federal Public Defender) |
| Date filed | 2022-04-06 (ECF header) |
| Fetched from | https://storage.courtlistener.com/recap/gov.uscourts.ca3.116073/gov.uscourts.ca3.116073.25.1.pdf (CourtListener RECAP) |
| Date retrieved | 2026-10-17 |
| Text layer | yes (`pdftotext` yields the text; Times New Roman embedded; the certificate states 14-point Times New Roman) |
| sha256 | `66cb46ebaf809c4afe2d9ed90864ec4579fcbd0ed70f9a8be13381c9c99e33a5` |

Found by: the CourtListener search API was throttled for the day on 2026-10-17, so RECAP URLs were listed from the Internet Archive CDX index of `storage.courtlistener.com/recap/gov.uscourts.ca3.*` and page 1 of each was read with `pdftotext`. Different party and counsel from Tresslar (The Gold Law Firm). Shows: TOC, TOA, jurisdictional statement, statement of issues, "Statement of Related Cases and Proceedings", argument, conclusion, one "Certificates" section (bar membership; virus check and identical compliance; word count) and a certificate of service.

Note for `tools/overlay.sh`: its default exemplar is the first PDF in `exemplars/` by name, which is now this file. Pass the Tresslar PDF as the third argument to reproduce the existing overlay.
