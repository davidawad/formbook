# Exemplar source

- File: `FILED-EXAMPLE-merits-brief.pdf`
- Document: "Brief for the Petitioner" (merits brief for a petitioner), with the cover "On Writ of Certiorari to the United States Court of Appeals for the Ninth Circuit"
- Case: *In re Grand Jury*, No. 21-1397 (Supreme Court of the United States)
- Docket: 21-1397
- Filer: Petitioner, counsel of record Daniel B. Levin (Munger, Tolles & Olson LLP), with Evan J. Davis (Hochman Salkin Toscher Perez P.C.) and Donald B. Verrilli, Jr. (Munger, Tolles & Olson LLP)
- Filed: the DocketPDF path carries the upload timestamp 2022-11-16 (20221116131246505); confirm the filing date on the case docket.
- Source URL: https://www.supremecourt.gov/DocketPDF/21/21-1397/246643/20221116131246505_21-1397%20-%20Brief%20for%20the%20Petitioner.pdf
- Date fetched: 2026-10-14
- Format facts (pdfinfo / pdffonts): 53 pages, US Letter media box, Aspose.PDF producer; text layer present; body set in New Century Schoolbook (embedded Type 1C).
- Why this exemplar: a real, public, text-based merits brief in this court, filed by a petitioner, in the booklet typography Rule 33.1(b) requires (Century family).

Only one exemplar is held for this doc type. A second filer's merits brief (a respondent's brief) was not yet located; the tier-2 comparison in the README is therefore against one filer.

## 2. `FILED-EXAMPLE-merits-brief-3.pdf` (second filer, tier-2 comparison)

- Court: Supreme Court of the United States
- Case: *In re Grand Jury*, No. 21-1397 (on writ of certiorari to the Ninth Circuit)
- Document: "Brief for the United States" (respondent's brief on the merits, Rule 24.2), 58 pages, US Letter PDF of a booklet-format brief; text layer yes (Century Expanded BT embedded)
- Filer: Respondent United States, by Elizabeth B. Prelogar, Solicitor General, Counsel of Record (Office of the Solicitor General, Department of Justice)
- Date filed: 2022-12-16 (docket entry date in the Court's case JSON)
- URL: https://www.supremecourt.gov/DocketPDF/21/21-1397/250234/20221216175930869_21-1397%20Grand%20Jury.pdf (docket: https://www.supremecourt.gov/RSS/Cases/JSON/21-1397.json)
- Date retrieved: 2026-10-17
- sha256: d8b0b48488a613b0e220662555d30944a07b7185cf7bf83370b2fd4f34c29591
- Notes: a Solicitor General filing (gray cover on paper, Rule 33.1(e)); its table of authorities uses "passim", which Rule 34.2 (2026 text) says should not be used. A respondent's brief: Rule 24.2 lets it omit items 24.1(a), (d)-(g); it still carries a Question Presented page.

## 3. `FILED-EXAMPLE-merits-brief-2.pdf` (third filer, tier-2 comparison)

- Court: Supreme Court of the United States
- Case: *Loper Bright Enterprises v. Raimondo*, No. 22-451 (on writ of certiorari to the D.C. Circuit)
- Document: "Brief for Petitioners" (petitioner's brief on the merits, Rule 24.1), 69 pages, US Letter PDF of a booklet-format brief; text layer yes (Century Schoolbook embedded)
- Filer: Petitioners Loper Bright Enterprises et al., by Paul D. Clement, Counsel of Record (Clement & Murphy, PLLC), with Cause of Action Institute
- Date filed: 2023-07-17 (docket entry date; date on the cover)
- URL: https://www.supremecourt.gov/DocketPDF/22/22-451/272199/20230717152715108_2023-07-17%20Loper%20Bright%20Opening%20Brief%20FINAL.pdf (docket: https://www.supremecourt.gov/RSS/Cases/JSON/22-451.json)

## Selected replacement

The United States merits brief is flagged for Century Expanded BT. The saved Loper Bright petitioner merits brief is a same-court, same-document-type alternative with an extractable text layer and Century Schoolbook, consistent with the Court's booklet typography. Its filer differs from the United States, and the existing United States sample remains paired with its source.
- Date retrieved: 2026-10-17
- sha256: 893d935b37fa60ea71b07a518c8e3b5963746983056dc0a1275aff695bfa861b

## 4. `FILED-EXAMPLE-merits-brief-4.pdf` (third filer, replacement search)

- Court: Supreme Court of the United States
- Case: *Bowe v. United States*, No. 24-5438 (on writ of certiorari to the Eleventh Circuit)
- Document: Brief for Petitioner Michael Bowe, 74 pages, text-based PDF; body face New Century Schoolbook embedded
- Filer: Petitioner Michael Bowe, through the Federal Public Defender for the Southern District of Florida (Andrew L. Adler, counsel of record)
- Date filed: 2025-04-07 (Supreme Court docket entry)
- Source URL: https://www.supremecourt.gov/DocketPDF/24/24-5438/354841/20250407132513522_Bowe%20Merits%20Brief%20FINAL.pdf
- Docket: https://www.supremecourt.gov/docket/docketfiles/html/public/24-5438.html
- Date retrieved: 2026-10-28
- SHA-256: `56fc9ef1288cdadbc16a2750a6835c5d9f9195c455eb901410f15c43c4a2ac99`
- Text-layer verification: `pdftotext` yields body text; `pdfimages -list` reports no page images; `pdffonts` reports embedded NewCenturySchlbk-Roman and related Century-family faces.
