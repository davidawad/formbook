# Exemplar source

- File: `FILED-EXAMPLE-motion-brief.pdf` (26 pages, text layer present; `pdftotext` reads it)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.ndd.62094/gov.uscourts.ndd.62094.42.0.pdf (CourtListener RECAP archive, docket id 62094; RECAP search at https://www.courtlistener.com/api/rest/v4/search/?type=r&court=ndd&q=MOTION+to+Dismiss+for+Failure+to+State+a+Claim+memorandum)
- Court: United States District Court, District of North Dakota, Eastern Division
- Case: *In re DMS Health Technologies, Inc., Data Breach Litigation* (consolidated; the plaintiffs are Stacy Kolkind and Constance Boyd)
- Docket: No. 3:23-cv-00204-ARS, Document 42 (the ECF header reads "Case 3:23-cv-00204-ARS Document 42")
- Document: Defendant DMS Health Technologies, Inc.'s Motion to Dismiss and Memorandum in Support of Its Motion to Dismiss Plaintiffs' Amended Consolidated Complaint, under Fed. R. Civ. P. 12(b)(1) and 12(b)(6), with a certificate of service
- Filer: Defendant DMS Health Technologies, Inc., by counsel O'Hagan Meyer LLC (James W. Davidson, admitted pro hac vice)
- Date filed: 10/09/24 (from the ECF header on every page and the certificate)
- Date fetched: 2026-10-14
- Public court record (RECAP). Used as a visual and structural reference.

## Why this one

The RECAP search for motions to dismiss in this court returned several candidates. Most had no stored PDF, or were a motion alone with the memorandum in a separate entry, or were a reply or an order. This document is a Rule 12(b) motion with its memorandum in one filing, with the caption, introduction, summary of allegations, standard, argument, conclusion and signature block in one document. It is a private defendant, which is useful against the government-filer exemplars. It is one filer only.

## Searches tried

- RECAP search `MOTION to Dismiss ... memorandum` (court=ndd): many entries were orders or memoranda with no stored PDF. Turtle Mountain v. Jaeger (3:22-cv-00022, ECF 191, 21 pages) is a Rule 12(c) memorandum and was not used. Christian Employers Alliance v. EEOC (1:25-cv-00007, ECF 52-2) is a settlement agreement, not a brief.
- Hoefer v. Teigen (1:25-cv-00207, ECF 12, the motion itself): storage URL returned HTTP 404; only the response (ECF 18) and reply (ECF 23) are stored.
- Clearinghouse.net entries for ND motions (Spirit Lake Tribe, Cross v. Fox): HTTP 403 to WebFetch.

## Notes on the exemplar

- The title in the exemplar reads "DMS HEATH TECHNOLOGIES" (a typo in the filing). The sample uses "DMS HEALTH TECHNOLOGIES".
- The exemplar has no table of contents or table of authorities. D.N.D. Civ. R. 7.1(A)(1)(a) makes them optional ("if a party chooses to include them"), so the template does not require them.
- The sample is a portion: it transcribes the introduction, the summary of allegations, the standard, the start of the argument (heading V, subheading 1 and its subheading A with the first paragraph of A), the conclusion, the signature block and the certificate of service. Other argument sections (A to D of V, IV conflicts of law, and the rest of the motion) are not transcribed. See `../README.md`.

## Second filer

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-motion-brief-2.pdf` (36 pages) |
| Court | U.S. District Court, District of North Dakota |
| Case / docket | *Hoefer v. Teigen*, No. 1:25-cv-00207-DLH-CRH, Document 13 |
| Document | Defendants' Memorandum of Law in Support of Motion to Dismiss |
| Filer | Defendants Josh Teigen, Shayden Akason, Richard Garman, David Lehman, and James Albrecht, by counsel |
| Date filed | 2025-11-17 (ECF header on each page) |
| URL | https://storage.courtlistener.com/recap/gov.uscourts.ndd.69636/gov.uscourts.ndd.69636.13.0.pdf |
| Date retrieved | 2026-10-17 |
| SHA-256 | `eec7415e3a56883e8e95cbeab300b5faa0f93fa4c7e5a1d7052bd454c5b0e770` |
| Public filing | Yes, CourtListener RECAP; searchable text is present. |
