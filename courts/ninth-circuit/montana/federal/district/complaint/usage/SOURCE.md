# Exemplar source

- File: `SAMPLE-mtd-complaint-fscknudsen924cv00067.pdf` (48 pages, text layer present, `pdftotext` reads it)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.mtd.76728/gov.uscourts.mtd.76728.1.0.pdf (the CourtListener RECAP archive, docket `gov.uscourts.mtd.76728`)
- Court: United States District Court for the District of Montana, Missoula Division
- Case: *Free Speech Coalition, Inc. et al. v. Austin Knudsen, in his official capacity as Attorney General of the State of Montana*
- Docket no.: No. 9:24-cv-00067-DWM (the ECF header on every page: `Case 9:24-cv-00067-DWM Document 1 Filed 05/14/24 Page N of 48`)
- Document: Complaint and Demand for Jury Trial (ECF 1)
- Filer: Plaintiffs, by Boone Karlberg P.C. (Natasha Prinzing Jones, Thomas J. Leonard), with Webb Daniel Friedlander LLP (Jeffrey Keith Sandman, pro hac vice pending) and The Law Office of D. Gill Sperlein (D. Gill Sperlein, pro hac vice pending)
- Date filed: May 14, 2024 (ECF header; signature block "DATED: May 14, 2024")
- Date fetched: 2026-10-14

## Why this one

The search for a text-based public D. Mont. filing of this type turned up the docket above. Entry 1 is the complaint. The same docket's RECAP entries are also in the archive (see the brief's `motion-brief/usage/SOURCE.md`, entry 18), so the complaint and the brief in support of the motion to dismiss come from one case and show the same caption and counsel conventions.

## Searches tried

- WebSearch: "District of Montana" motion to dismiss memorandum PDF courtlistener (2024–2025). Returned `storage.courtlistener.com/recap/gov.uscourts.mtd.76728/gov.uscourts.mtd.76728.17.0.pdf` (Defendant's Motion to Dismiss, 3 pp.; ECF 17 of 9:24-cv-00067-DWM). That docket ID was then used to fetch neighbouring entries by the same URL pattern: entry 1 (complaint, 48 pp.), entry 18 (brief in support, 43 pp.), entry 19 (a later filing, 41 pp.; not used).
- WebSearch: "United States District Court for the District of Montana" complaint PDF recap. Returned clearinghouse.net mirrors (Blackcrow v. Lake County, 9:21-cv-00097; Grey v. Jacobsen, 9:22-cv-00082; Montana Wildlife Federation v. Burgum, 4:26-cv-00133; Montana Environmental Information Center v. Burgum, 1:26-cv-00021; Jackson v. Board of Trustees of Wolf Point, 4:13-cv-00065; Montana Green Party v. Stapleton, 6:18-cv-00087). Not fetched: the clearinghouse "Open PDF" links were not retrieved, and the Montana Free Press 2021 filings are briefs, not complaints. Candidates for a second complaint (tier 2) are listed in the README's gaps.
- CourtListener website and API: HTTP 403 to curl from this box. The RECAP storage host (`storage.courtlistener.com`) is reachable.
- Court website (https://www.mtd.uscourts.gov/): reachable; the local rules PDFs were fetched from there (see the README's Governing rules).
