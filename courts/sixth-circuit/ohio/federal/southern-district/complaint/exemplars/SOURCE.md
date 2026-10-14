# Exemplar source

- File: `FILED-EXAMPLE-doe-v-columbus-2-26-cv-00684-complaint.pdf` (53 PDF pages: complaint pp. 1–20, then state-court exhibits pp. 21–53; only the complaint is in the sample)
- Court: United States District Court, Southern District of Ohio, Eastern Division (Columbus)
- Case: *Jane Doe v. City of Columbus, et al.*
- Docket: No. 2:26-cv-00684 (CourtListener docket 73448655), Document 1
- Document: "Complaint" with "Jury Demand Endorsed Herein" (20 pages of pleading)
- Filer: Plaintiff Jane Doe (pseudonym), by counsel Jeckering & Associates, LLC (Bradley N. Jeckering, Kristie A. Campbell, Patrick M. Quinn, Taylor V. Fairbanks)
- Date filed: 2026-06-05 (CourtListener docket entry 1, "Entered: 06/05/2026")
- Fetched from: `https://storage.courtlistener.com/recap/gov.uscourts.ohsd.312810/gov.uscourts.ohsd.312810.1.0.pdf` (RECAP). The docket HTML page is blocked for this box (CloudFront 403); the RECAP file path came from the CourtListener search API (`/api/rest/v4/search/?court=ohsd&type=r`), field `filepath_local`.
- Date fetched: 2026-10-14
- Text layer: yes (`pdftotext` yields text; Paper Capture OCR, Garamond fonts embedded)
- Public court record (RECAP). Used only as a structural and visual reference.

## Redaction in the transcription

The complaint is a pseudonymous civil action by a sexual-assault survivor. The sample (`samples/INPUT-doe-complaint.md`) keeps the caption, the parties, jurisdiction, the count headings, the prayer, the jury demand and the signature block, and transcribes a few allegations verbatim. The factual narrative of the 1994 offence (complaint ¶¶ 31–64) and the detail of the count paragraphs that restate it is replaced by a bracketed note. This is a deliberate choice; the filing itself remains public.

## Second filer

Not yet found. A second S.D. Ohio complaint from a different filer was not located in this pass (the RECAP entries for *Xiao v. General Electric*, 1:26-cv-01033, and other October 2026 complaints show no available document). EVAL-LOOP's tier-2 rule (2 or 3 filers) is therefore not met and is recorded in `../README.md`.
