# Exemplar source

- File: `FILED-EXAMPLE-knosp-5-26-cv-05092-complaint.pdf`
- Court: United States District Court, District of South Dakota (Rapid City Division)
- Case: *Knosp v. Equifax Information Services, LLC, et al.*
- Docket: No. 5:26-cv-05092-CCT, Document 1
- Document: Complaint for a Civil Case (AO form "Pro Se 1 (Rev. 12/16)"), 7 pages in the filing: pages 1 to 6 are the form with the filed entries, page 7 is the civil cover sheet (JS 44), which is not part of the complaint and is not transcribed.
- Filer: Plaintiff Daniel Everett Knosp, pro se (no attorney)
- Date filed: 07/21/2026 (header "Filed 07/21/26" on every page)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.sdd.86634/gov.uscourts.sdd.86634.1.0.pdf (CourtListener RECAP; found through the CourtListener search API, `court=sdd`, `type=r`, `q=complaint`, `order_by=dateFiled desc`; docket page not recorded)
- Date fetched: 2026-10-14
- Text layer: yes (`pdftotext` yields the entries; the form's pre-printed labels and entries are both text; the civil cover sheet is an image-like layer with OCR noise)
- Public court record (RECAP). Used as a structural and content reference only.

## Filer count

One filer. The CourtListener search for complaints in this court returned other complaints (e.g. Moyes v. Regency of South Dakota Inc., 5:26-cv-05126; Albergo v. City of Lake Andes, 4:26-cv-04196; several Federal Express Corporation suits), but none of their RECAP documents is marked available, so no second complaint could be downloaded. See `../README.md` (known gaps).

## Known differences between the exemplar and the sample

- The sample transcribes only the filed content of the form: the caption, the parties, the jurisdiction entries, the statement of claim, the relief, and the signature block. The AO instruction text, the Rule 11 boilerplate and the civil cover sheet are not transcribed.
- Plaintiff's street address, telephone number and e-mail address are redacted in the sample (`[redacted]`).
- Two text-layer characters are corrected in the transcription: "15U.S.C." is written "15 U.S.C."; the subsection "(a)(l)" is written "(a)(1)".
