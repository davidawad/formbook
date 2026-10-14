# Exemplar source

- File: `FILED-EXAMPLE-henry-3-26-cv-00038-complaint.pdf` (20 pages, text layer present; `pdffonts` shows embedded Times New Roman, Calibri and Arial on the pleading and exhibit pages)
- Court: District Court of the Virgin Islands, Division of St. Thomas and St. John
- Case: *Henry v. Brooks*, No. 3:26-cv-00038-ER-GAT (the caption carries "Civil Action No. ____": the number is assigned on filing and is blank on the filed copy)
- Document: Complaint for Declaratory and Injunctive Relief (ECF 1), with the caption and the signature block of counsel for plaintiffs
- Filer: Plaintiffs Sean Dale Henry, Gun Owners of America, Inc., and Gun Owners Foundation, by Kyle R. Waldner, Esq. (Waldner Law, P.C., St. Thomas)
- Date filed: 07/20/26 (ECF header: `Filed: 07/20/26`; signature block: "Dated: July 20, 2026")
- URL the PDF was fetched from: `https://storage.courtlistener.com/recap/gov.uscourts.vid.42297/gov.uscourts.vid.42297.1.0.pdf` (RECAP archive; the docket entry is at https://www.courtlistener.com/docket/73639875/1/1/henry-v-brooks/, which returns HTTP 403 to curl and WebFetch)
- Date fetched: 2026-10-14

## Why this one

It is a complaint in this court, filed by a private party, with a text layer, a caption on the court's own division heading, numbered paragraphs under FRCP 10(b), count headings, a prayer, and a signature block with the V.I. bar number. Other D.V.I. complaints found in the index were government filings (`United States v. Government of the Virgin Islands`, a DOJ complaint), criminal complaints, or pro se forms. Moorhead v. Fawkes (1:26-cv-00014, ECF 1, 33 pages) is a second candidate with storage; it was not saved, because the brief asks for one exemplar per doc type.

## Searches tried

- WebSearch: "District Court Virgin Islands complaint filed pdf courtlistener vid"; results were clearinghouse.net listings (HTTP 403 to fetch) and the court's blank pro se forms (not filings).
- CourtListener REST search API (`type=r`, `court=vid`, `q=complaint`): returned docket listings; the storage URLs above come from its `recap_documents` field. The API is rate-limited to 5 requests per minute.
- CourtListener docket pages and clearinghouse.net: HTTP 403 to curl and WebFetch.
- govinfo / vid.uscourts.gov: opinions only, no filed complaints.
