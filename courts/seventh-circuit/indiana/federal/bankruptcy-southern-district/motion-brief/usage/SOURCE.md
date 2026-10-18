# Exemplar source

- File: `FILED-EXAMPLE-motion-brief.pdf` (7 pages, text layer present: `pdftotext` reads the whole body. The body is embedded TimesNewRoman (subset, `pdffonts`), with LiberationSans and base-14 fonts also listed by the producer. It is a text PDF, not an image scan.)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.insb.561894/gov.uscourts.insb.561894.588.0.pdf (RECAP copy of the docket entry; the docket is https://www.courtlistener.com/docket/4265883/588/eastern-livestock-co-llc/)
- Court: United States Bankruptcy Court, Southern District of Indiana, New Albany Division
- Case: *In re Eastern Livestock Co., LLC*, Chapter 11, Case No. 10-93904-BHL-11
- Document: Motion to Set Aside Order Granting Fifth Third's Request for Rule 2004 Examination of Your Community Bank, filed by a non-party bank under B.R. 9024 (ECF Doc 588), with a certificate of service.
- Filer: Your Community Bank, by Reed Weitkamp Schell & Vice PLLC (Trevor L. Earl)
- Date filed: July 1, 2011 (ECF header "Filed 07/01/11"; "This the 1st day of July, 2011.")
- Date fetched: 2026-10-14
- Note on the era: the filing is from 2011, before the current S.D. Ind. Local Rules (as amended through December 1, 2025). Its layout is a 2011 filing. The format rules used by the template come from the current text, not from this exemplar.

## Why this one

Searched CourtListener RECAP for S.D. Indiana bankruptcy motions with an argument section and a hosted, text-based PDF. Most hosted motions were image scans (e.g. the Friedmeyer v. Tang motion to dismiss, doc 5, 4 pages, whose body is an image: `pdftotext` returns only the ECF header) or had no hosted PDF. This one is text-based, 7 pages, and has the parts a motion-brief needs: a caption naming the debtor, the title naming the relief, the relief and its grounds, numbered argument sections (I, II, III) with citations and block quotations, a conclusion, a signature block, and a certificate of service. It has no separate memorandum or table of contents: a combined motion and brief, which is the form the template covers.

## Searches tried

- CourtListener REST search, `court=insb`, `type=rd` and `type=r`, for "motion to dismiss" with "brief in support", "memorandum in support", "motion for relief" and "motion summary judgment". Hits with hosted PDFs that were text-based and motions: this one (doc 588), and the USA Gymnastics motion for withdrawal of the reference (19-50012 doc 37, 23 pages, not transcribed; text-based). Not used: the Friedmeyer v. Tang motion (image-only); the Eastern Livestock relief-from-stay motion (doc 263; 5 pages, 782 words; a shorter motion with no argument section).
- Many insb motions to dismiss (Eastern Livestock docs 40-44, ITT Educational, Dale Lynn Caldwell, Joseph Andrew McGinnis, Mireya Castillo, Murena v. Linarducci) have no hosted PDF in RECAP.
- CourtListener API rate limit: 5 requests per minute.
- No second exemplar from a different filer for this doc type. See the README gaps.
