# Exemplar source

- File: `FILED-EXAMPLE-complaint.pdf`
- Court: United States District Court, Southern District of California
- Case: *Bachman v. Chosen Foods, LLC*
- Docket: No. 3:26-cv-04862-AJB-MMP (Document 1)
- Document: Class Action Complaint for Damages and Injunctive Relief; Demand for Jury Trial (35 pages, including Exhibit 1, the CLRA venue declaration)
- Filer: Plaintiff Debra Bachman, by counsel Keller Grover LLP (Eric A. Grover, Sarah R. Holloway)
- Date filed: 2026-08-25 (stamped "Filed 08/25/26" on every page)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.casd.868295/gov.uscourts.casd.868295.1.0.pdf (CourtListener RECAP; found by the CourtListener API, `type=r&court=casd`, query "complaint for" "demand for jury trial")
- Date fetched: 2026-10-14
- Text layer: yes (`pdftotext` yields text; Times New Roman fonts embedded)
- Public court record (RECAP). Used only as a visual and structural reference.

Second filer: not collected in this pass. The CourtListener results also listed Novick v. Capricor Therapeutics (3:26-cv-05568, Pomerantz LLP) and Alo, LLC v. Derco (3:26-cv-04957, Name Game IP, PC) as S.D. Cal. complaints from 2026. A second filer is needed for a tier-2 comparison against 2 or 3 filers; that is not met here (see README.md, gap 1).

- File: `FILED-EXAMPLE-complaint-2.pdf`
- Filer: Plaintiff Bosa Development
- Case: *Bosa Development v. Shell Oil Company*, No. 3:01-cv-01179-W-CGA (Doc. 1)
- Date filed: 2001-06-29
- URL: https://storage.courtlistener.com/recap/gov.uscourts.casd.41021.1.0.pdf
- Date retrieved: 2026-10-17
- sha256: `3ff56b920ac728f7b6432aedfeb809a5d965f874b614ed0082e0434f240b868f`
- Note: Public RECAP scan; no text layer. Kept as a filer-independent comparison only.

## Selected replacement

The Bosa filing is the scan flagged by the font audit. The saved Bachman complaint is a same-court, same-document-type public filing with a native text layer and embedded Times New Roman, making it the selected replacement. The sample is already based on Bachman.

## Replacement exemplar (fb-9fyu, RECAP): `FILED-EXAMPLE-complaint-3.pdf`

- File: `FILED-EXAMPLE-complaint-3.pdf` (6 pages)
- Case: *In re Complaint and Petition of Brian Mackey*, No. 3:23-cv-00337-JAH-MSB (Doc. 1)
- Document: Complaint and Petition for Exoneration from or Limitation of Liability (admiralty; the initial pleading)
- Filer: Petitioner Brian Mackey, through Edwinth B. Barnes, Thomas Quinn, L.L.P.
- Date filed: 2023-02-21
- URL: https://storage.courtlistener.com/recap/gov.uscourts.casd.752954/gov.uscourts.casd.752954.1.0_1.pdf
- Date retrieved: 2026-10-28 (CourtListener RECAP search, staged by the PM)
- Text layer: yes (`pdftotext` returns 1820 words); Times New Roman embedded for the body (`pdffonts`; `fb fonts audit` class metric-exact, body timesnewroman 0.958)
- SHA-256: `779262ad5996de4648cab56cace52901d6e85100be5efb717ae00ea6a86287ab`
- Replacement for `FILED-EXAMPLE-complaint-2.pdf` (fb-9fyu: scanned image, no text layer). The old exemplar is kept; no INPUT is transcribed from this one.
