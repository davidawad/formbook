# Exemplar source

- File: `FILED-EXAMPLE-motion-brief.pdf` (11 pages, text layer present; pages 1-7 and 10-11 are text, page 9 is a scanned image, rotated 180 degrees, of the declaration's last paragraphs and signature)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.cacb.1968732/gov.uscourts.cacb.1968732.48.0.pdf (RECAP document; docket page https://www.courtlistener.com/docket/67651461/48/james-capital-advisors-inc/)
- Court: United States Bankruptcy Court, Central District of California, Los Angeles Division (Hon. Sheri Bluebond)
- Case: *In re James Capital Advisors, Inc.*, Chapter 7 (petition filed July 31, 2023)
- Bankruptcy case no.: 2:23-bk-14820-BB
- Document: Notice of Motion and Trustee's Motion for Authority to Compromise in Classes Under FRBP 9019(b); Memorandum of Points and Authorities and Declaration of Carolyn Dye in Support Thereof (Doc 48). Contents: notice (pp. 1-2), memorandum (pp. 3-7), declaration (pp. 8-9), proof of service (pp. 10-11).
- Filer: Carolyn A. Dye, Chapter 7 trustee, by Danning, Gill, Israel & Krasnoff, LLP (Eric P. Israel, Zev Shechtman)
- Date filed: August 23, 2023 (ECF header "Doc 48 Filed 08/23/23 Entered 08/23/23"; signature block "DATED: August 23, 2023"). Hearing set for September 13, 2023, 10:00 a.m., Courtroom 1539.
- Date fetched: 2026-10-14

## Why this one

Searched for a text-based, public motion with a memorandum of points and authorities in this court. This is a complete chapter 7 trustee motion in the Los Angeles Division: single caption with the case number and chapter, a combined notice and motion, a memorandum with numbered sections (Introduction, Factual Statement, Legal Discussion, Conclusion), the signature block, the declaration of the trustee, and the proof of service. It is 11 pages, in the 8-14 page range for a full-depth transcription. It was found through CourtListener's RECAP search (`type=r`, `court=cacb`), which returned it with a stored PDF.

## Searches tried

- WebSearch (standard and extended, several phrasings): C.D. Cal. bankruptcy "memorandum of points and authorities" with notice-of-motion terms. Returned court forms (F 4001-1, F 9013 notice forms), docket aggregators (inforuptcy, Angeion) and a 2017 Levene Neale exclusivity motion whose PDF was not reachable.
- WebSearch: claims-agent sites (Omni casedocs, Kroll, Stretto, Epiq). Returned Omni-hosted filings for Palo Verde Healthcare District (6:25-bk-17084-SY, a chapter 9 motion to appoint Omni; Doc 98 is a motion and declaration with no memorandum section, Doc 100 is its notice) and the Zetta Jet fee application (2:17-bk-21386-BR, not a motion). Not used.
- WebSearch: court notice-of-sales PDFs on cacb.uscourts.gov (World of Mistry 1:25-bk-10602-VK, Santa Ana 8:24-bk-11703-SC and others). The URLs returned HTTP 404 from curl and WebFetch on this box. Not used.
- archive.org (`gov.uscourts.cacb.*` items): about 132,500 items, but most hold only a docket JSON file, not the filing PDFs. Not used.
- CourtListener RECAP search API (`https://www.courtlistener.com/api/rest/v4/search/?type=r&court=cacb&q=...`), reachable from this box: returned several motions with memoranda. Candidates considered: Zions Bancorporation v. Stupin, 8:26-ap-01060, Doc 16 (30 pages, remand motion, creditor filer; too long for the 8-14 page transcription); Nguyen v. Nguyen, 8:26-ap-01027, Doc 23 (27 pages, adversary); James Capital Advisors, 2:23-bk-14820-BB, Doc 48 (11 pages, chosen).

## What would settle it

A second filed C.D. Cal. bankruptcy motion with a memorandum, from a filer other than a Danning Gill trustee (for example, a creditor's or debtor's motion, such as Zions Bancorporation's remand motion, 8:26-ap-01060 Doc 16), would give a second tier-2 comparison.

- File: `FILED-EXAMPLE-motion-brief-2.pdf`
- Filer: Debtor Lordon Enterprises, Inc., by Salvato Boufadel LLP (Misty Perry Isaacson and Joseph Boufadel)
- Case: *In re Lordon Enterprises, Inc.*, No. 2:25-bk-19832-BR (Doc. 71)
- Date filed: 2026-02-02
- URL: https://storage.courtlistener.com/recap/gov.uscourts.cacb.2029850/gov.uscourts.cacb.2029850.71.0.pdf
- Date retrieved: 2026-10-17
- sha256: `765045fb1e822e7924d168a3577df6960e25a4ccaacb0f49c4be1dcc5778bd2d`
