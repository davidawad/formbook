# Exemplar source

Court: United States Bankruptcy Court, District of South Dakota (`sdb`). Document type: motion with memorandum (FRBP 9013; the brief half of a motion).
Fetched 2026-10-14 from CourtListener RECAP (`storage.courtlistener.com/recap/...`), the public docket documents of the case. Text layer: yes (`pdftotext` yields the text of all 15 pages; checked per page, 1,261 to 2,392 characters each).

| File | Case | Docket | Filer (counsel) | Date filed | Pages | Fetched from |
|---|---|---|---|---|---|---|
| `SAMPLE-sdb-motion-brief-northernbeefpackers1310118.pdf` (**the sample is transcribed from this one**) | *In re Northern Beef Packers Limited Partnership* (Bankr. D.S.D., Ch. 11, Hon. Charles L. Nail, Jr.) | Bankr. No. 13-10118, Doc 134 ("Brief filed by White Oak Global Advisors LLC", docketed as a memorandum in support of Doc 45, the debtor's motion for interim and final financing orders, cash collateral and adequate protection, and Doc 41, the application to employ Lincoln Partners Advisors LLC) | White Oak Global Advisors, LLC, as agent for the lenders (Roger W. Damgaard, Woods, Fuller, Shultz & Smith P.C.; Stephen R. Tetro II and Mark D. Rasmussen, Chapman and Cutler LLP, pro hac vice). Lender, not the debtor. | 2013-08-07 (`Filed: 08/07/13` in the PDF header; docket entry entered 08/07/2013) | 15 | https://storage.courtlistener.com/recap/gov.uscourts.sdb.47175.134.0.pdf ; docket https://www.courtlistener.com/docket/4555765/134/northern-beef-packers-limited-partnership/ |

sha256 of the exemplar PDF: `87fca48b6639d415a0075c2471f0ff1f58b8b12523e0eea6a978a51bd214bcd8`.

## Why this one

It is a real memorandum filed in support of a debtor's motion in this court, from a filer other than the debtor, with the caption, a bankruptcy-court signature block and a text layer on every page. Its structure (caption with hearing lines, a title, a preliminary statement, numbered point headings, a conclusion and a signature block) is the motion-brief structure the template uses.

**Limits of the match (diagnostic, not a score):**

- It is a memorandum supporting a motion, not a motion with a memorandum in one document. The motion it supports (Doc 45) is not on RECAP. The template's opening sentence (`<movant> moves the Court for ...`) is generated from the frontmatter and does not appear in the filing, which opens with "hereby submits this Memorandum". This difference is recorded in `../README.md`.
- Only one exemplar is available for this doc type. The adversary-complaint folder has three filers; this folder has one. The tier-2 check is therefore against one filer.
- The filing's certificate of service is docket Attachment 1 and is not in this PDF, so it is not transcribed.

## Searches (2026-10-14)

Earlier log (kept): the first pass found no usable motion with memorandum. Its Northern Beef Packers Doc 134 entry said the RECAP PDF "was not on file (storage returned an error page)". That is no longer true: this session's fetch of the same URL returned a valid 15-page PDF with a text layer (`%PDF-1.3`, `pdfinfo` 15 pages, `pdftotext` full text). The earlier error was a transient storage response.

This session, CourtListener search (`type=r`, `court=sdb`, via `https://courtlistener.com/api/rest/v4/search/`; the `www.` host returned no response for search queries):

- `"brief in support" motion`
- `"memorandum in support" motion`
- `"memorandum of law" motion`
- `"brief in support of motion"`
- `motion "relief from stay" brief`
- `"motion to dismiss" memorandum`

For every result with a stored PDF (`filepath_local` set), the document was checked for its type. Candidates considered:

| Candidate | Result |
|---|---|
| *Tri-State Ethanol*, 03-10194, Doc 101 "Copy of Memorandum of Law in Support of Motion for PARTIAL Relief from Stay" (2003) | Not on RECAP (`filepath_local` null, `is_available` false). |
| *Tri-State Ethanol / North Central Construction*, 03-01032, Doc 48 "Memorandum of Law in Support of Motion for Voluntary Abstention" (2003) | Not on RECAP. |
| *Hilltop Dairy*, 13-40002, Doc 189 (withdrawn) and Doc 195 "Amended Brief/Memorandum of Law in Support of Debtor's Motion" (2013) | Not on RECAP. |
| *Veblen West Dairy*, 10-10071, Doc 18 "Debtor's Motion for ... Use of Cash Collateral" (31 pp., 2010) | Text, but a motion with numbered grounds and no separate memorandum; not a memorandum-plus-motion. Kept as a fallback. |
| *Veblen West Dairy*, 10-10071, Doc 64 "AgStar's Motion for Appointment of Chapter 11 Trustee" (8 pp., 2010) | Text, motion only. Its memorandum is Doc 250 (54 pp., no RECAP description, not transcribed: too long for the 8 to 14 page target). |
| *Veblen East Dairy*, 10-10146, Doc 86 "Partners' Memorandum of Law" responding to AgStar's motion to excuse (11 pp., 2010) | Text, but a response by limited partners, not a memorandum in support of a motion. |
| *Veblen East Dairy*, 10-10146, Doc 52 "Debtor's Response to AgStar's Motion to Excuse Compliance with § 543" (49 pp., 2010) | Text, but a response, and too long. |
| *Rivett*, 24-50074, Doc 12 (13 pp., 2024, no description) | Almost no text layer (810 characters across 13 pages): image-scanned, not usable. |
| *Keithahn*, *Paulson*, *Leiferman*, *Northern Beef Packers* Doc 134 (earlier log) | See above. |
| Other stored results (decisions, orders, letter decisions) | Court decisions and orders, not filings of this type. Not used. |
| Briefs in support of summary judgment in adversary cases (Dakota Scents 04-04011 Doc 17; Vucurevich 12-04003 Doc 24) | Listed with a description but no stored PDF (`filepath_local` null), so not checked. Summary-judgment briefs are not motions with memoranda in any case. |

Web searches (WebSearch, standard mode, two queries in this session): form-vendor pages, the court's Appendix 2A and 4A forms, local rules 4001-1 and 9072-1, and other districts' local rules. No filed South Dakota motion-with-memorandum on the web.

Not tried: PACER (the official source, not reachable from this box). CourtListener docket-entry API for the Veblen documents (401, authentication required).

## Transcription

`usage/INPUT-sdb-motion-brief-northernbeefpackers.md` is a transcription of the whole filing (all 15 pages, including footnotes 1 to 3 and the conclusion and signature). Differences from the PDF, each deliberate:

- The debtor's SSN/ITIN is shown as the last four digits (`TIN xx-xxx0200`) in the caption, not the full number printed in the PDF (Fed. R. Bankr. P. 9037 and Bankr. D.S.D. R. 9004-2).
- Footnotes 1 to 3 are not supported by the template. Each is printed as its own paragraph directly after the paragraph that carries its marker, beginning with the superscript number.
- The template's generated opening sentence (movant, relief, basis) is added before the preliminary statement. The filing has no such sentence (see "Limits of the match" above).
- Italics for case names were not verified from the text layer, so the transcription is in roman type throughout.
- The certificate of service (docket Attachment 1) is not in this PDF and is not transcribed.
- The filing's pro hac vice counsel block is kept in the signature's firm lines.

## Render length

The filing is 15 pages. The render is 9 pages (one template at 12 pt, single-spaced; the filing is denser per page by layout). This is within the 8 to 14 page target for a transcription of an exemplar this long.
