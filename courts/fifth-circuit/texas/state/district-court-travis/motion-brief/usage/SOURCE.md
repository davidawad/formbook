# Exemplars: motion-brief (txdistrict-travis)

Public papers filed in a Travis County district court, reproduced in the appendix of a mandamus petition in the Third Court of Appeals (the appendix is the filer's, and the petition is in the public record on the court's site). Only the public filed pages are stored: the trial-court motion and the trial-court order, extracted from the appendix with `qpdf`. Retrieved 2026-10-06; the appellate docket page re-checked 2026-10-24.

## FILED-EXAMPLE-motion-brief.pdf

| Field | Value |
|---|---|
| Case | *Dobson v. Rebolledo, Last Mile Transportation Systems, LLC and Amazon.com Services, LLC* |
| Court, cause no. | 201st Judicial District Court, Travis County, Texas; D-1-GN-22-001827 |
| Document | Defendant Amazon.com Services, LLC's Motion to Dismiss under Tex. R. Civ. P. 91a, argument incorporated, with certificate of service (5 pp.: pp. 35-39 of the 48-page appendix PDF) |
| Filer | Chamberlain ♦ McHaney (counsel for the defendants) |
| Date filed | 2023-04-14 (clerk's stamp 4/14/2023 3:50 PM) |
| Where obtained | Appendix to the relator's petition for writ of mandamus, *In re Amazon.com Services, LLC*, No. 03-23-00634-CV (Tex. App.-Austin, filed 2023-10-16): https://search.txcourts.gov/Case.aspx?cn=03-23-00634-CV&coa=coa03 (the petition and appendix PDF are linked from that docket page, "Brief/PET MAND FLD") |
| Text layer | Yes |
| Transcribed as | `INPUT-motion-brief.md` (the whole motion; the clerk's stamp is not transcribed) |

## FILED-EXAMPLE-motion-brief-2.pdf

| Field | Value |
|---|---|
| Case, court, cause no. | Same as above |
| Document | Order Denying Defendant Amazon.com Services, LLC's Motion to Dismiss (1 p., p. 28 of the same appendix PDF) |
| Signed | 2023-06-14 (date from the matter file index; the printed judge's name and the clerk's stamp appear on the order) |
| Where obtained | Same as above |
| Text layer | Partly (a scan with the clerk's file stamp; the order's printed text layer is imperfect) |
| Transcribed as | `INPUT-motion-brief-2.md` (`document: proposed-order`; the judge's name and the stamps are not transcribed) |

Exemplars 1 and 2 are from one case and one filer's side and predate Local Rule 2.2 (in force since 2024-11-15), so the certificate of conference of INPUT 1 is rule-derived (rules.md TXTRAVIS-MOT-004, -005), not exemplar-derived. Exemplar 9 is a post-2024 Travis motion with a certificate of conference (not the Local Rule 2.2 wording; README Known gaps).

`INPUT-motion-brief-3.md` is fictional (no exemplar): a non-dispositive motion, to test the template against a second structure.

## FILED-EXAMPLE-motion-brief-5.pdf

A post-2024 Travis motion. Retrieved 2026-10-25; the URL returned HTTP 200 the same day. The paper is a state-court filing (Travis County District Clerk e-filing stamp) attached to a removal file in the W.D. Tex. (Austin) and published in CourtListener RECAP; only the motion's pages are stored (`qpdf --pages`). The CourtListener docket page returns 403 to non-browser clients (context only).

| Field | Value |
|---|---|
| Case, court, cause no. | *Texas Precious Metals, LLC v. Hancock & Douglas*; 459th District Court, Travis County; D-1-GN-26-000754 |
| Document | State Defendants' Opposed Motion to Quash Nonparty Subpoena and for Entry of Protective Order, with certificate of conference and certificate of service (7 pp.: pp. 91-97 of a 346-page PDF) |
| Filer | Office of the Texas Attorney General, Special Litigation Division (David Bryant, signing; Ali M. Thorburn, signing the certificates), for the defendants |
| Date filed | 2026-02-12 (stamp 2/12/2026 4:45 PM) |
| Where obtained | https://storage.courtlistener.com/recap/gov.uscourts.txwd.1172893103/gov.uscourts.txwd.1172893103.1.5.pdf (W.D. Tex. No. 1:26-cv-00513, doc. 1-5; docket https://www.courtlistener.com/docket/72352948/texas-precious-metals-llc-v-hancock/) |
| Text layer | Yes |
| Transcribed as | `INPUT-motion-brief-5.md` |

Notices of hearing, notices of appearance and proposed orders have their own folders (`../../notice-of-hearing/`, `../../notice-of-appearance/`, `../../proposed-order/`).
