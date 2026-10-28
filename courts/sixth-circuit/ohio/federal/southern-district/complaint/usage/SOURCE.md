# Exemplar source

- File: `FILED-EXAMPLE-complaint.pdf` (53 PDF pages: complaint pp. 1–20, then state-court exhibits pp. 21–53; only the complaint is in the sample)
- Court: United States District Court, Southern District of Ohio, Eastern Division (Columbus)
- Case: *Jane Doe v. City of Columbus, et al.*
- Docket: No. 2:26-cv-00684 (CourtListener docket 73448655), Document 1
- Document: "Complaint" with "Jury Demand Endorsed Herein" (20 pages of pleading)
- Filer: Plaintiff Jane Doe (pseudonym), by counsel Jeckering & Associates, LLC (Bradley N. Jeckering, Kristie A. Campbell, Patrick M. Quinn, Taylor V. Fairbanks)
- Date filed: 2026-06-05 (CourtListener docket entry 1, "Entered: 06/05/2026")
- Fetched from: `https://storage.courtlistener.com/recap/gov.uscourts.ohsd.312810/gov.uscourts.ohsd.312810.1.0.pdf` (RECAP). The docket HTML page is blocked for this box (CloudFront 403); the RECAP file path came from the CourtListener search API (`/api/rest/v4/search/?court=ohsd&type=r`), field `filepath_local`.
- Date fetched: 2026-10-14
- Text layer: yes (`pdftotext` yields text; Paper Capture OCR, Garamond fonts embedded)

## Font-audit replacement candidate (not downloaded)

The Doe PDF is flagged for Garamond. A possible same-court, same-document-type text-layer replacement is *Thomas v. Wayner*, No. 2:26-cv-00734, Doc. 1, filed June 16, 2026 (14 pages), available at https://docketnexus.com/doc/483024133.pdf. The browser-rendered filing includes the ECF header and searchable complaint text. Direct PDF download from this environment returned an HTML access challenge, so a PDF could not be saved and verified locally; it is not yet a replacement exemplar.
- Public court record (RECAP). Used only as a structural and visual reference.

## Redaction in the transcription

The complaint is a pseudonymous civil action by a sexual-assault survivor. The sample (`usage/INPUT-complaint.md`) keeps the caption, the parties, jurisdiction, the count headings, the prayer, the jury demand and the signature block, and transcribes a few allegations verbatim. The factual narrative of the 1994 offence (complaint ¶¶ 31–64) and the detail of the count paragraphs that restate it is replaced by a bracketed note. This is a deliberate choice; the filing itself remains public.

## Second filer

Not yet found. A second S.D. Ohio complaint from a different filer was not located in this pass (the RECAP entries for *Xiao v. General Electric*, 1:26-cv-01033, and other October 2026 complaints show no available document). EVAL-LOOP's tier-2 rule (2 or 3 filers) is therefore not met and is recorded in `../README.md`.

## Replacement exemplar (fb-9fyu, RECAP): `FILED-EXAMPLE-complaint-2.pdf`

- File: `FILED-EXAMPLE-complaint-2.pdf` (21 pages)
- Case: *United States v. Assorted Property Seized on October 4, 2019*, No. 2:26-cv-00147-SDM-CMV (Doc. 1)
- Document: Verified Complaint for Forfeiture In Rem
- Filer: Plaintiff United States, through AUSA William B. King II, United States Attorney's Office for the Southern District of Ohio
- Date filed: 2026-02-10
- URL: https://storage.courtlistener.com/recap/gov.uscourts.ohsd.309490/gov.uscourts.ohsd.309490.1.0.pdf
- Date retrieved: 2026-10-28 (CourtListener RECAP search, staged by the PM)
- Text layer: yes (`pdftotext` returns 6752 words); Times New Roman embedded for the body (`pdffonts`; `fb fonts audit` class metric-exact, body timesnewroman 0.966)
- SHA-256: `9359a4aef0b94c633be355577ae8e41d5ff19aa2ea9f97e5b4c922125f23fbfa`
- Replacement for `FILED-EXAMPLE-complaint.pdf` (fb-9fyu: Garamond: commercial face, no redistributable metric-compatible face). The old exemplar is kept; no INPUT is transcribed from this one.
