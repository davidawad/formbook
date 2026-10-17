# Exemplar source

- Case: *Oracle America, Inc. v. United States*, No. 18-1880C (U.S. Court of Federal Claims), bid protest (JEDI cloud procurement)
- Docket / document: Doc. 59 (Plaintiff's Motion for Judgment on the Administrative Record, pp. 1-3), Doc. 59-1 (Memorandum of Law, pp. 4-75), Doc. 59-2 (Proposed Order, pp. 76-78). The exemplar is the complete 78-page filing package in that order.
- Filer: Oracle America, Inc. (counsel: Arnold & Porter Kaye Scholer LLP, Craig A. Holman, attorney of record)
- Date filed: 02/12/2019 (redacted public version; the stamped filing dates in the documents read 02/05/2019 and 02/12/2019)
- URL fetched from: https://www.washingtontechnology.com/media/ps360/GIG/Washington-Technology/Documents/Oracle-JEDI-filing-Feb-12.pdf
  (found through a web search for uscfc motion for judgment on the administrative record; the file is the court's public redacted filing as posted by the press. Found on CourtListener's RECAP index only as opinions, not the motion itself.)
- Date fetched: 2026-10-14
- Text layer: pp. 1-3 are text-based. Pp. 4-78 are scanned images with no text layer. The memorandum (pp. 4-75) was OCR'd for transcription. The overlay tool needs a text layer to pair pages, so an OCR text-layer copy was made outside the repo at `/work/artifacts/uscfc-motion-brief/oracle-18-1880C-textlayer.pdf` and passed to `tools/overlay.sh` as the third argument. The filed file in this folder is unchanged.
- Search log: CourtListener API v4 (search type=rd, court=uscfc, motion for judgment on the administrative record; motion-only filter): no motion PDF with an available file. Docket-entries and docket pages need auth or return 403. WebSearch returned the Oracle filing above.

## Exemplar 2 (added 2026-10-17, fb-595.21.1)

- File: `FILED-EXAMPLE-united-states-26-458-motion-brief.pdf`
- Case: *Sublime Systems, Inc. v. United States*, No. 1:26-cv-00458-EDK (U.S. Court of Federal Claims; Judge Kaplan), breach of a Department of Energy cooperative agreement (not a bid protest)
- Docket / document: Doc. 11, "Defendant's Motion to Dismiss and in the Alternative Motion to Strike" (RCFC 12(b)(6) and 12(f)), with its appendix (Index to the Appendix p. 45, Appx pages pp. 46-92). Cover p. 1, table of authorities pp. 2-5 (i-iv), motion and argument pp. 6-43 (1-38), signature p. 44 (39). No table of contents and no certificate of service in the filing.
- Filer: defendant the United States (U.S. Department of Justice, Civil Division, Commercial Litigation Branch; Matthew D. Lewis, Trial Attorney, signing; of counsel Brighton Springer, U.S. Department of Energy). Different party and counsel from exemplar 1 (Oracle America, Inc. / Arnold & Porter).
- Date filed: 2026-07-01 (CM/ECF banner "Filed 07/01/26"; signature "Dated: July 1, 2026")
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.uscfc.54021/gov.uscourts.uscfc.54021.11.0.pdf (CourtListener RECAP storage; docket found through the Internet Archive CDX index of `storage.courtlistener.com/recap/gov.uscourts.uscfc.*`, document number by direct request)
- Date retrieved: 2026-10-17
- Pages: 92. Text layer: yes on every page (Word to PDF, "Acrobat PDFMaker 24 for Word"); `pdffonts` shows Times New Roman in the brief; the appendix carries the agreement's own fonts (Calibri, Arial).
- SHA-256: `09cc7ffb80fefe84d31171ea50d59534e6ed9e7350be98c4b7e8e0c396850ca6`
- Doc-type note: a motion to dismiss, not a motion for judgment on the administrative record. Both are RCFC 7.2(b) dispositive motions whose supporting brief follows RCFC 5.4 and 5.5, so the form comparison (caption, cover, tables, headings, signature) carries over; the RCFC 52.1(c) statement of facts does not.
