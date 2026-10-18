# Exemplar source

- File: `FILED-EXAMPLE-motion-brief.pdf` (31 pages, text layer present: `pdftotext` reads it, `pdffonts` shows embedded fonts)
- Court: United States District Court for the Northern Mariana Islands, Bankruptcy Division (the caption; the court's bankruptcy unit)
- Case: *In re Imperial Pacific International (CNMI), LLC*, Chapter 11, No. 1:24-bk-00002 (the caption reads "Case No. 1:24-0bk-00002"; Hon. Ramona V. Manglona)
- Document: Document No. 49, "Memorandum of Law in Support of Motion by Judgment Creditors Joshua Gray and U.S.A. Fanter for Entry of an Order Under 11 U.S.C. §§ 361, 362 and 541" (memorandum only; the motion itself is a separate filing and is not in this file)
- Filer: Judgment creditors Joshua Gray (counsel Bruce Berline, Aaron Halegua) and U.S.A. Fanter (counsel Colin Thompson)
- Date filed: May 13, 2024 (ECF header "Filed 05/13/24" on every page)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.nmib.136/gov.uscourts.nmib.136.49.0.pdf (CourtListener RECAP; the docket is listed at https://dockets.justia.com/ for court `nmib`, which shows it as "Judgment creditors' memorandum supporting motion for an order under 11 U.S.C. §§ 361, 362, 541 (Doc. 49)")
- Date fetched: 2026-10-14
- Public court record (RECAP). Used as a visual and structural reference only.

## Searches tried (to find this doc type)

- Filed-motion search for nmib on CourtListener's search page and API: HTTP 403 to the tool (not retrieved).
- Justia dockets court listing for `nmib` (https://dockets.justia.com/court/nmib): HTTP 200; 7 cases, 9 documents; 3 with a PDF. The Imperial Pacific Doc. 49 memorandum was the only motion-type document with a PDF. Other entries: attorney disclosures of compensation (Hong Kong Entertainment, Browne), Doc. 243 (response to show-cause order), Doc. 485 (fee application); "Close Adversary Case" entries with no PDF.
- Web searches for "Northern Mariana Islands bankruptcy" motions and memoranda: returned the court's own rules and general orders, not filings.

## Why this one

It is the only text-based public motion-type filing from this court found in the docket listing. It is a memorandum of law supporting a motion under the bankruptcy court's own caption: a numbered-paragraph memorandum with a TOC, TOA, argument headings and a signature block, 31 pages.

## Caveat

Doc. 49 is an unusually long memorandum (31 pages, of which the sample transcribes 9). Its caption omits the chapter line that LBR 5005-1(b)(1) requires; the template adds it (see `../README.md`). This is one filer's document; tier-2 comparison against a second filer is not done (see `../README.md`, known gaps).
