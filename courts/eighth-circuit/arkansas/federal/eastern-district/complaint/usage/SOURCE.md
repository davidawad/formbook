# Exemplar source

- File: `FILED-EXAMPLE-complaint.pdf`
- Court: United States District Court, Eastern District of Arkansas (caption has no division line in this filing)
- Case: *Hess v. Equifax Information Services, LLC and Trans Union, LLC*
- Docket: No. 3:26-cv-00016-DPM (Document 1)
- Document: "Class Action Complaint and Demand for Jury Trial" (11 pages), FCRA
- Filer: Plaintiff Malcolm Hess, by counsel Eliyahu R. Babad, Stein Saks, PLLC (Hackensack, NJ). The signature block gives no Arkansas bar number (see README.md, gap 3).
- Date filed: 2026-01-12 (stamped "Filed 01/12/26" on every page; clerk's "FILED ... JAN 12 2026" stamp on page 1). Dated by counsel: December 18, 2025.
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.ared.150985/gov.uscourts.ared.150985.1.0.pdf (CourtListener RECAP; docket https://www.courtlistener.com/docket/72132978/)
- Date fetched: 2026-10-14
- Text layer: partial. The PDF is a scan with an OCR layer (`pdffonts`: LiberationSans and Helvetica; `pdftotext` yields the text, with OCR errors such as "Plaintifrs", "maccuracy", "Trans Union" split in places). The sample transcribes the text and corrects clear OCR errors; it is not a verbatim copy of the scan.
- Public court record (RECAP). Used as a structural reference only.

Second filer: not collected. The brief asks for one exemplar per doc type, so EVAL-LOOP's tier-2 rule (2 or 3 filers) is not met (README.md, gap 1).

Search trail (CourtListener API v4 `search/?type=r&court=ared`, query `"COMPLAINT with Jury Demand"`, 2019 onward, filtered to 8 to 16 pages; first-page text read for each):
- Read, rejected as state-court complaints attached to a notice of removal (not federal pleadings): Stiritz v. Martell Growth Solutions (4:26-cv-00565), Ryburn v. Centene (4:25-cv-00765), Pittman v. Rock Region MTA (4:25-cv-01007), Rebeiro v. Mississippi County Hospital System (3:26-cv-00068), Leflar v. HP (4:22-cv-00690), Adair v. City of Dumas (2:24-cv-00163).
- Read, rejected as pro se or not text-based: Pierce v. Payne (4:24-cv-01115, prisoner form complaint); Barnes v. Kerstein (2:25-cv-00103, 24 pages, stamp-only text layer).
- Read, rejected as a state-court complaint: Moats v. Love, Beal & Nixon (4:26-cv-00668, White County Circuit Court complaint).
- Chosen: Hess (federal, counsel-signed, text layer, 11 pages with jurisdiction, parties, facts, causes of action, jury demand, prayer, signature block). Frazier v. People Trust CU (4:26-cv-00328, 8 pages, federal, filed by the plaintiff as attorney) was the other federal candidate; not chosen (it is a pro se attorney's filing and its text layer is hidden OCR).
