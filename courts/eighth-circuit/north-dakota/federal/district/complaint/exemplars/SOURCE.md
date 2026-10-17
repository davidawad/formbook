# Exemplar source

- File: `FILED-EXAMPLE-bitcanary-3-25-cv-00181-complaint.pdf` (10 pages, text layer present; `pdftotext` reads it)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.ndd.69407/gov.uscourts.ndd.69407.1.0_3.pdf (CourtListener RECAP archive, docket id 69407; found with the RECAP search at https://www.courtlistener.com/api/rest/v4/search/?type=r&court=ndd&q=COMPLAINT+against)
- Court: United States District Court, District of North Dakota (the caption reads "EASTERN DISTRICT OF NORTH DAKOTA")
- Case: *BitCanary, LLC v. Minecore, LLC, Saamar Siddiqui and George Baltes*
- Docket: No. 3:25-cv-00181-PDW-ARS, Document 1
- Document: Complaint, with a jury demand (no separate civil cover sheet in the sample)
- Filer: Plaintiff BitCanary, LLC, by counsel Michael Shacter (Shacter Law; of counsel to Centaurus Legal Services, P.C.)
- Date filed: 07/29/25 (from the ECF header on every page)
- Date fetched: 2026-10-14
- Public court record (RECAP). Used as a visual and structural reference.

## Why this one

The search (CourtListener RECAP, `court=ndd`, document type complaint, 2025-2026) returned several North Dakota complaints, but most RECAP entries had no stored PDF. This is a short complaint with a text layer, in the same court, with the usual parts: caption, jurisdiction and venue, parties, background, numbered counts, prayers for relief, jury demand and signature block. It is one filer only.

## Searches tried

- CourtListener RECAP search, `court=ndd`, `q=complaint`: most results were orders or administrative records. `Lipps v. City of Fargo` (3:26-cv-00294, doc 1, 35 pages) and `Doosan Bobcat v. Doe` (1:26-cv-00351) had no stored PDF.
- Clearinghouse.net entries for ND complaints (Brakebill, Turtle Mountain, Catholic Benefits): https://clearinghouse.net/doc/135174 and similar returned HTTP 403 to WebFetch.
- `Hoefer v. Teigen` (1:25-cv-00207, doc 1): downloaded and checked, but 244 pages long, which is outside the depth target for a complaint.
- Direct storage URLs for the Lipps, Doosan, Turtle Mountain and Balva complaints returned HTTP 404.

## Notes on the exemplar

- The caption gives the court as "EASTERN DISTRICT OF NORTH DAKOTA" with no separate division line. Civil Rule 3.1(A) requires the division in the caption of a complaint, so the template asks for a division and the sample supplies "EASTERN DIVISION". See `../README.md`.
- The caption uses a column of ")" marks, not a rule. The template copies that.
- Paragraph numbers in the filed text are the numbers the filer wrote. The sample does not carry them; the template numbers the allegations.

## Second filer

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-travelers-1-26-cv-00212-complaint.pdf` (7 pages) |
| Court | U.S. District Court, District of North Dakota |
| Case / docket | *Travelers Casualty and Surety Company of America v. Chamley Pipe & Salvage, LLC*, No. 1:26-cv-00212-DLH-CRH, Document 1 |
| Filer | Plaintiff Travelers Casualty and Surety Company of America, through its counsel of record |
| Date filed | 2026-06-29 (ECF header on the filing) |
| URL | https://storage.courtlistener.com/recap/gov.uscourts.ndd.72850/gov.uscourts.ndd.72850.1.0.pdf |
| Date retrieved | 2026-10-17 |
| SHA-256 | `a746256143daf7e8ab69c667ba5779c2cabf158c3508ebf3961002c16916f8b4` |
| Public filing | Yes, CourtListener RECAP; searchable text is present. |
| Caution | This filed caption omits the division even though D.N.D. Civ. R. 3.1(A) directs plaintiffs to designate the appropriate division. Use only for otherwise-unspecified complaint conventions. |
