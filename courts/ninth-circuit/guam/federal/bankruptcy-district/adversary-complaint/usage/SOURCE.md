# Exemplar source: adversary complaint, Bankr. D. Guam

| Field | Value |
|---|---|
| File | `SAMPLE-gub-adversary-complaint-archbishopagana1900001.pdf` (23 pages, text layer present, `pdffonts`: Times, Helvetica, Calibri) |
| Court | United States Bankruptcy Court, District of Guam (the caption reads "IN THE DISTRICT COURT OF GUAM, TERRITORY OF GUAM, BANKRUPTCY DIVISION") |
| Case | *Official Committee of Unsecured Creditors v. Archbishop of Agaña, a Corporation Sole*, Adv. Proc. No. 19-00001, main case No. 19-00010 (Chapter 11) |
| Filer | Official Committee of Unsecured Creditors, by Stinson Leonard Street LLP (Robert T. Kugler, Edwin H. Caldie, Andrew J. Glasnovich; Minneapolis) |
| Document | Complaint (Declaratory Judgment Regarding Property of the Estate), ECF Doc. 1, with Exhibit A and Statement Exhibits 8, 9 and 10 |
| Date filed | 04/06/19 (ECF header "Document 1 Filed 04/06/19"); signed "5th day of April, 2019" |
| URL (docket) | https://www.courtlistener.com/docket/14887831/1/official-committee-of-unsecured-creditors-v-archbishop-of-agana-a/ |
| URL (document) | https://storage.courtlistener.com/recap/gov.uscourts.gub.4608/gov.uscourts.gub.4608.1.0.pdf |
| Date fetched | 2026-10-14 |
| SHA-256 | `8bf05842138a56caef2f5040428d8d415154d25d8ceaa472112f2870c777a921` |

How it was found: `courtlistener.com/api/rest/v4/search/?type=r&court=gub&q=adversary complaint` (RECAP search, bankruptcy court gub). The search returned seven results; the complaint was the only Guam adversary complaint with a RECAP copy of the document itself (the other complaint entries have no local copy). Web searches for "District of Guam adversary complaint" returned no other filed complaint.

Filer caveat: this is one filer and one document. The Guam caption and pleading form (numbered lines, 28 lines per page, 24-point pitch) are this filer's; they are not shown to be the court's convention. Tier-2 comparison against a second filer is not done.

Gap in the exemplar: the complaint has no statement whether the Committee consents to the entry of final orders (Fed. R. Bankr. P. 7008(a)). The template requires one (see `../README.md`).
