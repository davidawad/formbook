# Exemplar source: adversary-complaint (almb)

- File: `FILED-EXAMPLE-adversary-complaint.pdf`
- Fetched from: `https://storage.courtlistener.com/recap/gov.uscourts.almb.196680/gov.uscourts.almb.196680.1.0.pdf` (CourtListener RECAP archive, document 1 of the adversary docket). The docket page is `https://www.courtlistener.com/docket/5181913/1/southeastern-stud-and-components-inc-adversary-proceeding/`.
- Case: *J. Lester Alexander, III, Chapter 7 Trustee v. The Mill Steel Company, Mill Steel Birmingham, LLC and MSSES Holdings, LLC*, Adv. Proc. No. 15-03014, in bankruptcy case *In re Southeastern Stud and Components, Inc.*, Case No. 14-32906-DHW-7 (Bankr. M.D. Ala., Northern Division).
- Title on the document: "Adversary Complaint for a Declaratory Judgment to Determine the Validity, Extent and Priority of Liens and Disallow the Proof of Claim of MSSES Holdings, LLC".
- Filer: J. Lester Alexander, III, Chapter 7 Trustee, by counsel Fishman Haygood Phelps Walmsley Willis & Swanson LLP (Brent B. Barriere, pro hac vice) and William Dennis Schilling.
- Date filed: 2015-03-04 (ECF header "Doc 1 Filed 03/04/15").
- Date fetched: 2026-10-14.
- Public record: RECAP-hosted PDF of a filing on the public docket. The file is 13 pages, a ScanSnap scan with an embedded OCR text layer (`pdftotext` yields the body). Body font is an embedded Liberation Sans; the caption and headings are Helvetica (non-embedded). The ECF header is stamped on each page.

## Filer count (tier 2)

Two public almb adversary complaints are now saved. `FILED-EXAMPLE-adversary-complaint-2.pdf` is a text-layer filing from a different filer and is designated as the replacement font/text exemplar for both scanned Southeastern Stud records below. The eval-loop rule asks for 2 or 3 exemplars from different filers for tier 2; those two filers are now represented. See `../README.md`, Gaps, for any remaining comparison limits.

## Replacement for the audited scanned exemplars

- File: `FILED-EXAMPLE-adversary-complaint-2.pdf` (8 pages)
- Court: United States Bankruptcy Court, Middle District of Alabama, Northern Division
- Case: *Plant Bae, LLC v. QuickBridge Funding LLC*, Adv. No. 24-03037, in *In re Plant Bae, LLC*, Case No. 24-30639, Chapter 11
- Document: Doc. 1, Complaint (automatic-stay violations; damages and injunctive relief)
- Filer: Plant Bae, LLC, debtor-in-possession, by Paul D. Esco (ASB-3772-O61P)
- Date filed: 2024-07-24 (CM/ECF header on each page)
- URL: https://storage.courtlistener.com/recap/gov.uscourts.almb.261137/gov.uscourts.almb.261137.1.0.pdf
- Docket page: https://www.courtlistener.com/docket/68976255/1/plant-bae-llc-adversary-proceeding/
- Date retrieved: 2026-10-17
- SHA-256: `99cf5b2476b38d39de5fd2464fb81223a04eeadbc9d683ea854c815a73eb1188`
- Text layer: yes (`pdftotext` extracts the 8-page complaint); `pdffonts` reports embedded Times New Roman, Liberation Sans, and standard fonts.
- Public filing: CourtListener RECAP copy.

This text-layer Times New Roman filing replaces the scanned `FILED-EXAMPLE-adversary-complaint-3.pdf` and `FILED-EXAMPLE-adversary-complaint.pdf` for font/text-layer comparison. The originals are retained as historical source material.

## Searches tried

- CourtListener REST search API (`/api/rest/v4/search/`, `type=rd`, `court=almb`): throttled by the service (HTTP 429, "Expected available in 16193 seconds") after the first two requests, so it could not be used for the rest of this session.
- CourtListener web search page (`/?q=...&court=almb&type=r`): returned results once (adversary and Alabama dockets) and then empty responses.
- Web search for `gov.uscourts.almb`, "adversary complaint", "motion for relief from stay", "motion to dismiss", "objection to claim" with `almb`: no RECAP complaint or motion PDFs. Results were the court's hearing calendars (almb.uscourts.gov), govinfo opinions, and Leagle summaries.
- The court's own site (`almb.uscourts.gov`) hosts calendars, the attorney adversary guide, and local rules, but no filed complaints.

## Second replacement for the audited scanned exemplars (fb-9fyu)

- File: `FILED-EXAMPLE-adversary-complaint-4.pdf` (42 pages)
- Court: United States Bankruptcy Court, Middle District of Alabama
- Case: *Jackson Hospital & Clinic, Inc. v. Blue Cross and Blue Shield of Alabama*, Adv. No. 25-03025, in *In re Jackson Hospital & Clinic, Inc., et al.*, Case No. 25-30256, Chapter 11 (jointly administered)
- Document: Doc. 1, Plaintiff's Original Complaint
- Filer: Jackson Hospital & Clinic, Inc., debtor, by Chase J. Potter, Joshua L. Shepherd and Anna Olin Richardson (pro hac vice), Iacuone McAllister Potter PLLC
- Date filed: 2025-12-18 (CM/ECF header "Doc 1 Filed 12/18/25")
- URL: https://storage.courtlistener.com/recap/gov.uscourts.almb.269993/gov.uscourts.almb.269993.1.0.pdf
- Date retrieved: 2026-10-28 (PM RECAP staging branch `newbox/fb-9fyu-recap-files`)
- SHA-256: `04ea914f810cc36671b6b5f8ca30569ab93f4d5012aa5d781a12bd71e8e1ee50`
- Text layer: yes (`pdftotext` extracts all 42 pages); body is embedded Times New Roman. `pdffonts` also lists an Aptos subset, used only for blank space glyphs (`pdftohtml -xml`: 13 space-only runs).
- Public filing: CourtListener RECAP copy.

Replacement for `FILED-EXAMPLE-adversary-complaint-3.pdf` and `FILED-EXAMPLE-adversary-complaint.pdf` (fb-9fyu: scanned, OCR text layer). The originals are kept.
