# Exemplar source: adversary-complaint (almb)

- File: `FILED-EXAMPLE-southeastern-stud-adversary-complaint.pdf`
- Fetched from: `https://storage.courtlistener.com/recap/gov.uscourts.almb.196680/gov.uscourts.almb.196680.1.0.pdf` (CourtListener RECAP archive, document 1 of the adversary docket). The docket page is `https://www.courtlistener.com/docket/5181913/1/southeastern-stud-and-components-inc-adversary-proceeding/`.
- Case: *J. Lester Alexander, III, Chapter 7 Trustee v. The Mill Steel Company, Mill Steel Birmingham, LLC and MSSES Holdings, LLC*, Adv. Proc. No. 15-03014, in bankruptcy case *In re Southeastern Stud and Components, Inc.*, Case No. 14-32906-DHW-7 (Bankr. M.D. Ala., Northern Division).
- Title on the document: "Adversary Complaint for a Declaratory Judgment to Determine the Validity, Extent and Priority of Liens and Disallow the Proof of Claim of MSSES Holdings, LLC".
- Filer: J. Lester Alexander, III, Chapter 7 Trustee, by counsel Fishman Haygood Phelps Walmsley Willis & Swanson LLP (Brent B. Barriere, pro hac vice) and William Dennis Schilling.
- Date filed: 2015-03-04 (ECF header "Doc 1 Filed 03/04/15").
- Date fetched: 2026-10-14.
- Public record: RECAP-hosted PDF of a filing on the public docket. The file is 13 pages, a ScanSnap scan with an embedded OCR text layer (`pdftotext` yields the body). Body font is an embedded Liberation Sans; the caption and headings are Helvetica (non-embedded). The ECF header is stamped on each page.

## Filer count (tier 2)

This is the only public almb adversary complaint retrieved. The eval-loop rule asks for 2 or 3 exemplars from different filers for tier 2; that is **not met**. See `../README.md`, Gaps.

## Searches tried

- CourtListener REST search API (`/api/rest/v4/search/`, `type=rd`, `court=almb`): throttled by the service (HTTP 429, "Expected available in 16193 seconds") after the first two requests, so it could not be used for the rest of this session.
- CourtListener web search page (`/?q=...&court=almb&type=r`): returned results once (adversary and Alabama dockets) and then empty responses.
- Web search for `gov.uscourts.almb`, "adversary complaint", "motion for relief from stay", "motion to dismiss", "objection to claim" with `almb`: no RECAP complaint or motion PDFs. Results were the court's hearing calendars (almb.uscourts.gov), govinfo opinions, and Leagle summaries.
- The court's own site (`almb.uscourts.gov`) hosts calendars, the attorney adversary guide, and local rules, but no filed complaints.
