# Exemplar source

- File: `SAMPLE-kywb-adversary-complaint-keatsvspecialized2103007.pdf` (8 pages, complete; text layer present, `pdftotext` reads it; Helvetica not embedded).
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.kywb.349241/gov.uscourts.kywb.349241.1.0.pdf (CourtListener RECAP copy of the filing). Docket page: https://www.courtlistener.com/docket/43034224/1/keats-v-specialized-attorney-services-inc/
- Court: United States Bankruptcy Court, Western District of Kentucky, Louisville Division.
- Case: *Robert W. Keats, Chapter 7 Trustee v. Specialized Attorney Services Inc.* (adversary proceeding). Main case: *In re M&P Collections, Inc. and F&M Law Firm, P.S.C.*, No. 19-30311-acs (jointly administered with No. 19-30312), Chapter 7.
- Docket no.: Adv. Proc. No. 21-03007-acs (CourtListener docket number 21-03007; the caption on the filing itself leaves the adversary number blank).
- Filer: Robert W. Keats, Chapter 7 Trustee, by Fowler Bell PLLC (John E. Hinkel, Jr.; Matthew D. Ellison).
- Document: Complaint to Recover Preferential Transfers (Doc. 1), with Exhibit A (transfer table) on page 8.
- Date filed: January 26, 2021 (ECF header: "Filed 01/26/21").
- Date fetched: 2026-10-14.

## Why this one

Searched CourtListener's RECAP index for complaints filed in the Western District of Kentucky bankruptcy court (`court=kywb`, `type=rd`, `available_only`). The trustee's preference complaint is the most common adversary-complaint form in this court's docket. This one is 8 pages, has a clean text layer, uses the W.D. Ky. caption (court title, debtor block, adversary block), and carries a jurisdiction and consent paragraph (FRBP 7008) and an Exhibit A table. Other kywb complaints found and not used: Reisz v. Daikin Comfort (25-03051, 5 pp.), Brody v. Upstart (25-03044, 13 pp.), McMurry v. Rushmore (22-01002, 15 pp.), Premier Acceptance v. Geary (19-03013, 18 pp.), Backlotcars v. Geary (19-03015, 17 pp.).

## Searches tried

- CourtListener REST search API (anonymous; rate-limited to 5 requests a minute, so requests were spaced): kywb RECAP documents for "adversary complaint" and "complaint"; kywb dockets for adversary cases.
- CourtListener docket pages (HTML) to see which RECAP entries are available.
- RECAP document endpoint (`/api/rest/v4/recap-documents/`): requires authentication, not used.
- WebSearch for W.D. Ky. adversary complaint forms and PDFs: court pages and docket listings only, no complaint PDFs.
- kywb.uscourts.gov local-forms page: no adversary-complaint form or cover sheet among the local forms (the court's own adversary cover sheet, Official Form 104, is not a local form).
- Not used: the Official Forms (Form 416 caption) could not be fetched from uscourts.gov (HTTP 404 on the URL tried).

## Caveat

One exemplar. The eval-loop tier-2 rule asks for two or three from different filers; not done (see README.md).
