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
