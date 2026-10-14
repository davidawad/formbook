# Exemplar source

Two exemplars from different filers. The first is the primary one; the second is kept for the tier-2 comparison.

## 1. Howard v. City of Douglas Utility Dept. (primary)

- File: `FILED-EXAMPLE-howard-23-05004-motion-brief.pdf` (7 pages, text layer present, `pdftotext` reads it; Times fonts not embedded)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.gasb.340787/gov.uscourts.gasb.340787.12.0.pdf (RECAP copy of ECF 12; docket https://www.courtlistener.com/docket/68122081/12/howard-v-city-of-douglas-utility-dept/)
- Court: United States Bankruptcy Court, Southern District of Georgia, Waycross Division (Judge Michele J. Kim)
- Case: *Howard v. City of Douglas Utility Dept.*, Adv. Pro. No. 23-05004, in Chapter 13 Case No. 23-50574-MJK
- Document: Defendant's Motion to Dismiss Adversarial Complaint and Memorandum of Law in Support (one document; the motion and memorandum combined, which LR 7.1(b) of the district rules allows)
- Filer: City of Douglas Utility Department, by Freeman Mathis & Gary, LLP (Brian S. Goldberg)
- Date filed: January 5, 2024 (from the signature block and the RECAP entry date 2024-01-05)
- Date fetched: 2026-10-14
- Caveat: the PDF's embedded document title is a SharePoint draft path ("AP DRAFT MTD for City of Douglas"). The RECAP entry is the filed document; the copy shows no ECF header on page 1.

## 2. Pruco Life Insurance Co. v. Hirsch (second filer, memorandum only)

- File: `FILED-EXAMPLE-pruco-hirsch-23-04021-motion-brief.pdf` (27 pages, text layer present; Times and Helvetica fonts, none embedded)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.gasb.340983/gov.uscourts.gasb.340983.29.0.pdf (RECAP copy of ECF 29; docket https://www.courtlistener.com/docket/68208886/29/pruco-life-insurance-company-v-hirsch/)
- Court: United States Bankruptcy Court, Southern District of Georgia, Savannah Division
- Case: *Pruco Life Insurance Co. v. Hirsch et al.*, Adv. Pro. No. 23-04021-EJC, in Chapter 7 Case No. 23-40569-EJC
- Document: Memorandum of Law in Support of Motion to Dismiss Crossclaim (ECF 29). The motion itself (ECF 28) is not in RECAP (no document available), so this exemplar covers the memorandum only, with no notice-of-motion part.
- Filer: Judith Hirsch, by Jones & Walden LLC (Leon S. Jones)
- Date filed: March 1, 2024
- Date fetched: 2026-10-14

## Why these

Searched CourtListener's RECAP index for S.D. Ga. bankruptcy motion-with-memorandum filings (type=rd, court=gasb, description containing "Motion" or "Memorandum"). Of the filings found, the Howard filing is the only single motion-with-memorandum document with a caption, relief, argument and a certificate of service that has a RECAP PDF. The Pruco memorandum is used for a second filer's memorandum style.

## Searches tried

- WebSearch (standard and extended): S.D. Ga. bankruptcy motion memorandum adversary, courtlistener; returned forms and opinions, no usable motion PDF.
- CourtListener REST search (type=rd, court=gasb), queries "motion" + "brief in support" and "motion to dismiss" + "memorandum": Howard ECF 12, Pruco ECF 29, and Hoffman/WBL and Thomas filings (not used: Thomas ECF 128 is a brief for a motion for relief from stay, a different doc type; Hoffman ECF 27 was not checked further).
