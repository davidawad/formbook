# Exemplar source

- File: `FILED-EXAMPLE-adversary-complaint.pdf` (7 pages, text layer present: `pdftotext` reads it, `pdffonts` shows embedded TimesNewRomanPSMT)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.insb.780833/gov.uscourts.insb.780833.4.0.pdf (RECAP copy of the docket entry; the docket page is https://www.courtlistener.com/docket/73539236/rabo-agrifinance-llc-v-bayes/)
- Court: United States Bankruptcy Court, Southern District of Indiana, New Albany Division
- Case: *Rabo AgriFinance LLC v. Bayes* (adversary) within *In re Jeffery H. Bayes*, Chapter 13
- Adversary number: 26-59007 (ECF header). Bankruptcy case no. 25-90845 (caption).
- Document: Amended Complaint (ECF Doc 4), objecting to dischargeability under 11 U.S.C. § 523(a)(2)(A). Amends Doc 1 (the original complaint, not downloaded). Doc 7 is the summons.
- Filer: Rabo AgriFinance LLC, by Womble Bond Dickinson (US) LLP (Eudora F. S. Arthur, pro hac vice)
- Date filed: July 8, 2026 (ECF header "Filed 07/08/26"; signature block "Dated: July 8, 2026")
- Date fetched: 2026-10-14
- Caption spelling: the filed caption reads "RABO AGRFINANCE LLC"; the body reads "Rabo AgriFinance LLC". The sample transcribes the caption as filed.

## Why this one

Searched CourtListener's RECAP index (insb, adversary proceedings) for a text-based adversary complaint filed in this court. This is a public record, text-based, and a complaint with the full structure the form needs: court title and division, bankruptcy caption with the debtor, adversary caption, numbered allegations under Fed.R.Civ.P. 10(b), the jurisdiction paragraph, the statute quoted, counts, a prayer, and the signature block. The adversary is a real filing in the S.D. Indiana (New Albany) court.

It is an amended complaint, not the original. It has the complaint form in full. Its text on the first page reads "AMENDED COMPLAINT"; the template takes its title from the sample.

## Searches tried

- CourtListener REST search, `court=insb`, `type=r` (dockets) and `type=rd` (documents), for "adversary complaint" and "complaint adversary". Most hits were chapter 7 and 11 petitions and Department of Education dockets. The Rabo docket was the only insb adversary complaint with a hosted complaint PDF in the first results. Murena v. Linarducci (25-50110) has a hosted complaint PDF (doc 1, 13 pages) but was not downloaded: the motion-to-dismiss filing in that docket is not hosted. Johnson v. Trewartha (25-50031) has only an order in its hosted RECAP documents.
- CourtListener API rate limit: 5 requests per minute; searches paced accordingly.
- Court site https://www.insb.uscourts.gov/ : form pages and local rules only; no sample complaints.
