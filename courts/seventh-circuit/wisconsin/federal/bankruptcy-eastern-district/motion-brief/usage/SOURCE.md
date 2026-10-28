# Exemplar source: motion with brief in support (E.D. Wis. Bankruptcy)

- File: `FILED-EXAMPLE-motion-brief.pdf` (38 pp. including exhibits, text layer, sha256 dcbb4b6e13ae40c68f99d5b51d673bdcc74fd10d58a357ff44fb121271a7f59c)
- URL fetched: https://storage.courtlistener.com/recap/gov.uscourts.wieb.443392/gov.uscourts.wieb.443392.11.0.pdf
  (RECAP document 11 on the adversary docket; found through the CourtListener search API, `court=wieb`, query "motion to dismiss adversary proceeding brief in support")
- Case: *Vongermeten v. Lindblom COO et al.* (In re Dean Richard Vongermeten), Adversary No. 22-02024-rmb, Bankr. E.D. Wis.; main case No. 21-25409-rmb, Chapter 13
- Filer: Gray & Associates, L.L.P. (Christopher C. Drout), for defendants Mark Clauss, Christopher Drout and Suzy Lindblom
- Document: "Notice of Motion ... to Dismiss Adversary Complaint", "Motion ... to Dismiss Adversary Complaint" (Fed. R. Civ. P. 12(b)(6) via Fed. R. Bankr. P. 7012), and "Brief in Support of Motion to Dismiss Adversary Complaint"; the bundle also attaches Exhibits A–G (court orders)
- Date filed: 04/08/2022 (ECF stamp "Filed 04/08/22")
- Date fetched: 2026-10-14
- Note: the PDF is a scan with a text layer (OCR); the sample transcription corrects obvious OCR errors and does not reproduce exhibits or the Table of Contents, which the filing does not contain.

## Font-audit selected replacement — Ability Insurance Company

The Vongermeten filing is flagged as a scanned OCR PDF. The saved Ability Insurance Company brief is a same-court, same-document-type public filing with a native text layer and Times New Roman body text. It supports a separate motion to dismiss rather than combining the motion and memorandum in one file, so it is a font-audit selected replacement, not a direct sample substitute.

- File: `FILED-EXAMPLE-motion-brief-2.pdf`
- Case: *In re Green Box NA Green Bay, LLC*, No. 16-24179-beh, Chapter 11
- Document: Ability Insurance Company's Brief in Support of Motion to Dismiss (8 pages; Doc. 351)
- Filer: Ability Insurance Company, through Conway, Olejniczak & Jerry, S.C.
- Date filed: 2017-11-29
- URL: https://oneidaeye.com/wp-content/uploads/2017/11/2017-11-29-Ability-Ins.-Cos-Brief-in-Support-of-Motion-to-Dismiss-16-24179-Ch-11-GBNAGB.pdf
- Date retrieved: 2026-10-17
- Text layer: yes (`pdftotext` returns 2,189 words); Times New Roman embedded for body text
- SHA-256: `59e884ff003131ed9fecf7eacdf542db7f57888a4bfcfdbea1b09fbe8585eeff`

## Replacement exemplar (fb-9fyu, RECAP): `FILED-EXAMPLE-motion-brief-3.pdf`

- File: `FILED-EXAMPLE-motion-brief-3.pdf` (7 pages)
- Case: *In re Wisconsin & Milwaukee Hotel, LLC*, No. 24-21743-gmh, Chapter 11 (Doc. 786)
- Document: Lenders' Supplemental Brief in Support of Motion for Relief from the Automatic Stay
- Filer: Computershare Trust Company, N.A. and Wisconsin & Milwaukee Hotel Funding LLC, through Frank W. DiCastri and Sara C. McNamara, Reinhart Boerner Van Deuren s.c.
- Date filed: 2025-11-13
- URL: https://storage.courtlistener.com/recap/gov.uscourts.wieb.456155/gov.uscourts.wieb.456155.786.0.pdf
- Date retrieved: 2026-10-28 (CourtListener RECAP search, staged by the PM)
- Text layer: yes (`pdftotext` returns 2262 words); Times New Roman embedded for the body (`pdffonts`; `fb fonts audit` class metric-exact, body timesnewroman 0.975)
- SHA-256: `8cb262f5dcb9933795bddbcf5d891b736b87dd9e34307e0ddc3ba653078548cf`
- Replacement for `FILED-EXAMPLE-motion-brief.pdf` (fb-9fyu: scanned image with an OCR text layer). The old exemplar is kept; no INPUT is transcribed from this one.
