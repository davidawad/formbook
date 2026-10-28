# Exemplar source

- File: `FILED-EXAMPLE-amicus-brief-2.pdf`
- Court: Supreme Court of the United States
- Case: *Loper Bright Enterprises v. Raimondo* (Secretary of Commerce), No. 22-451 (merits stage)
- Document: Brief for National Shooting Sports Foundation, Inc. as Amicus Curiae in Support of Petitioners (27 pages, letter-size PDF of a booklet-format brief; Century Schoolbook text)
- Filer: National Shooting Sports Foundation, Inc. (amicus; counsel Schaerr | Jaffe LLP)
- Date filed: July 24, 2023
- Source URL: https://www.supremecourt.gov/DocketPDF/22/22-451/272727/20230724143335950_22-451%20Amicus%20Brief%20of%20NSSF.pdf
- Docket page: https://www.supremecourt.gov/docket/docketfiles/html/public/22-451.html
- Date fetched: 2026-10-14
- Text layer: yes (`pdftotext` returns the body text)
- Public court record (supremecourt.gov docket file); no sealed or restricted material.
- sha256 (computed 2026-10-17): 9169d45fbac40e38793ebac84f1deac1b5dda583923de973ee0533340282c04f

## 2. `FILED-EXAMPLE-amicus-brief.pdf` (second filer, tier-2 comparison)

- Court: Supreme Court of the United States
- Case: *Loper Bright Enterprises v. Raimondo*, No. 22-451 (merits stage)
- Document: "Brief for Amicus Curiae the Chamber of Commerce of the United States of America in Support of Petitioners", 35 pages, US Letter PDF of a booklet-format brief; text layer yes (New Century Schoolbook embedded)
- Filer: Amicus Chamber of Commerce of the United States of America, by Helgi C. Walker, Counsel of Record (Gibson, Dunn & Crutcher LLP), with U.S. Chamber Litigation Center
- Date filed: 2023-07-24 (docket entry date)
- URL: https://www.supremecourt.gov/DocketPDF/22/22-451/272688/20230724120208874_Chamber%20-%20Loper%20Bright%20Amicus%20Brief.pdf (docket: https://www.supremecourt.gov/RSS/Cases/JSON/22-451.json)
- Date retrieved: 2026-10-17
- sha256: 126ad84e71fd0155223308f00efe4edc26b78614f22389a1642abe4c2b402497
- Notes: "other amicus" class (8,000 words, light green on paper).

## 3. `FILED-EXAMPLE-amicus-brief-3.pdf` (third filer, tier-2 comparison)

- Court: Supreme Court of the United States
- Case: *Loper Bright Enterprises v. Raimondo*, No. 22-451 (merits stage)
- Document: "Brief of Amici Curiae State of West Virginia and 26 Other States in Support of Petitioners", 51 pages, US Letter PDF of a booklet-format brief; text layer yes (Century Expanded BT embedded)
- Filer: Amici State of West Virginia and 26 other States, by Lindsay S. See, Solicitor General, Counsel of Record (Office of the West Virginia Attorney General)
- Date filed: 2023-07-24 (docket entry date)
- URL: https://www.supremecourt.gov/DocketPDF/22/22-451/272740/20230724151234261_Loper%20Bright%20States%20Merits%20Amicus.pdf (docket: https://www.supremecourt.gov/RSS/Cases/JSON/22-451.json)
- Date retrieved: 2026-10-17
- sha256: 0b36393e2d850e8adbe4fc28648d0e6e44d4146e9300926c47e6d098a4de78b5
- Notes: a Rule 37.6 class amicus (a State by its Attorney General: 9,000 words, and exempt from the authorship/funding disclosure).

## Selected replacement

The West Virginia filing is flagged for Century Expanded BT. The saved Chamber brief is the closest selected replacement: a same-court amicus brief with a text layer, filed by a different organization, in New Century Schoolbook. The Loper Bright NSSF brief is another text-layer option in Century Schoolbook. Both better reflect the Supreme Court's booklet typography than a Times New Roman replacement would. The existing West Virginia sample remains paired with its original source.

## 4. `FILED-EXAMPLE-amicus-brief-4.pdf` (replacement search)

- Court: Supreme Court of the United States
- Case: *Bowe v. United States*, No. 24-5438 (merits stage)
- Document: Brief of Court-Appointed Amicus Curiae in Support of Judgment Below on First Question Presented, 82 pages; text layer present, body in Century Schoolbook
- Filer: Court-appointed amicus curiae Kasdin M. Mitchell (Kirkland & Ellis LLP)
- Date filed: 2025-08-22 (Supreme Court docket entry)
- Source URL: https://www.supremecourt.gov/DocketPDF/24/24-5438/370491/20250822124903073_20250822%20FINAL%20Amicus%20ISO%20QP1%20Brief%20w%20Addendum.pdf
- Docket: https://www.supremecourt.gov/docket/docketfiles/html/public/24-5438.html
- Date retrieved: 2026-10-28
- SHA-256: `b5e9dece0b455a1a0bb61a857b3763e0d5414e0663226a057c0fd5cc408ce048`
- Text-layer verification: `pdftotext` yields body text; pages 63–82 contain image-based addendum material, while the brief pages are text-based; `pdffonts` reports embedded CenturySchoolbook and NewCenturySchlbk faces.
