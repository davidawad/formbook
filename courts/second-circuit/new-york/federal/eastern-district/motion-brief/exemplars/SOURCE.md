# Exemplars: nyed memorandum of law in support of a motion to dismiss

| File | Case | Docket | Filer | Date filed | Pages | Fetched |
|---|---|---|---|---|---|---|
| `FILED-EXAMPLE-force-1-20-cv-02578-memorandum.pdf` | Force v. Qatar Charity et al., E.D.N.Y. | 1:20-cv-02578 (BMC), ECF 56-1 | Ropes & Gray LLP for Qatar National Bank (Q.P.S.C.) | 2022-02-14 | 47 (memorandum pp. 1 to 40, certificate of service p. 41) | 2026-10-14 |
| `FILED-EXAMPLE-saldarriaga-1-20-cv-03529-memorandum.pdf` | Saldarriaga v. Coffin, E.D.N.Y. | 1:20-cv-03529 (RPK)(JRC), ECF 19 | Counsel for defendant Ann Coffin (Florida Child Support Enforcement Program Director) | 2022-06-08 | 34 | 2026-10-14 |

URLs fetched from (both found by CourtListener search, court=nyed, type=r; storage path per the RECAP document):
- Force: https://storage.courtlistener.com/recap/gov.uscourts.nyed.448903/gov.uscourts.nyed.448903.56.1_1.pdf (docket https://www.courtlistener.com/docket/17237528/56/1/force-v-qatar-charity/)
- Saldarriaga: https://storage.courtlistener.com/recap/gov.uscourts.nyed.451241/gov.uscourts.nyed.451241.19.0.pdf (docket https://www.courtlistener.com/docket/17421936/19/saldarriaga-v-coffin/)

Notes:
- Both are public court records with a text layer (pdftotext yields the text). Both carry Times New Roman, embedded in one and not in the other; the template uses the vendored EB Garamond.
- Both predate the 2025 word-limit rule (LCR 7.1(c) in the 2026 joint rules). They are page-limited filings, so neither has a word-count certificate. The template adds one.
- Two filers, so tier 2 is judged against two (EVAL-LOOP). The Force memorandum is the overlay reference (`tools/overlay.sh` uses the first exemplar in name order); the Saldarriaga memorandum is compared by hand in the review.
- The sample `samples/INPUT-force-memorandum.md` transcribes selected passages of the Force memorandum (preliminary statement, Argument I.A to I.C, II, conclusion, certificate of service) and links its citations to the template's table of authorities.
