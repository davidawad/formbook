# Exemplar source: complaint (D. Md.)

| Item | Value |
|---|---|
| File | `FILED-EXAMPLE-grecco-1-26-cv-03723-complaint.pdf` |
| Case | *Michael Grecco Productions, Inc. v. New Century Foundation, et al.* |
| Court | United States District Court, District of Maryland (`mdd`), Northern Division |
| Docket no. | 1:26-cv-03723-BAH (Hon. Brendan A. Hurson) |
| Document | Doc. 1, Complaint (16 pages; text layer present; no images in the text layer) |
| Filer | Plaintiff Michael Grecco Productions, Inc. (counsel: Mikhael D. Charnoff, Charnoff Simpson PLLC) |
| Date filed | September 18, 2026 (ECF header: "Filed 09/18/26") |
| Fetched from | https://storage.courtlistener.com/recap/gov.uscourts.mdd.613916/gov.uscourts.mdd.613916.1.0.pdf (RECAP archive copy) |
| Docket page | https://www.courtlistener.com/docket/74816649/1/michael-grecco-productions-inc-v-new-century-foundation/ |
| Date fetched | 2026-10-14 |
| SHA-256 | `48766bb58219f24db14cdbbf4ce7aa85f6c2b598feb84d109eefd72d5b90caf2` |

Public court record (RECAP). The ECF header on each page (case number, document number, filed date, page count) is the court system's, not part of the form; the template does not draw it.

## How it was found

CourtListener search API (`https://www.courtlistener.com/api/rest/v4/search/?type=r&court=mdd`), query `"complaint" "demand for jury trial"`, ordered by filing date. Results were filtered to documents marked `is_available` and to complaints of 8 to 20 pages with a text layer. Chosen: this one (attorney-drafted, 16 pages, Times New Roman, full section structure, prayer, Rule 38 jury demand, signature block with bar number, fax and email).

## Other complaints looked at (not saved)

| Case | Docket | Pages | Why not saved |
|---|---|---|---|
| Yukich v. USA Fencing | 8:26-cv-04238, Doc. 3 | 13 | Text layer present; not compared in full (second exemplar candidate for tier 2) |
| Mestek Machinery, Inc. v. 1987 Machinery LLC | 8:26-cv-03857, Doc. 1 | 7 | Text layer present; short (7 pages), counsel Kramon & Graham |
| Liverpool v. American Express National Bank | 1:26-cv-03805, Doc. 1 | 13 | Text layer only ~130 words (image-only pages); not usable |
| Heath v. The Michaels Companies, Inc. | 1:26-cv-03833, Doc. 2 | 19 | Docket text shows clerk entry ("ybs, Deputy Clerk"); filer status not checked; not chosen |

Tier 2 (EVAL-LOOP) asks for two or three exemplars from different filers. Only one is saved here, as the brief asks; Yukich and Mestek are the next candidates if David wants a second filer.
