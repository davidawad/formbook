# Exemplar source

Public filings of the U.S. Bankruptcy Court, E.D. California, from CourtListener RECAP (the PDFs are the RECAP copies
of the documents as filed; nothing is edited). Found by listing the RECAP storage bucket for `gov.uscourts.caeb.*`
(the CourtListener search API needs a token; the storage URLs do not) and reading page 1 of each candidate.
Retrieved 2026-10-29.

| File | Filer (party and counsel) | Case | Filed | Pages | Source URL | sha256 |
|---|---|---|---|---|---|---|
| `FILED-EXAMPLE-motion-brief.pdf` | Debtors Oroville Hospital and OroHealth Corporation (Fox Rothschild LLP: Keith C. Owens, Nicholas A. Koffroth) | *In re Oroville Hospital, et al.*, Lead Case No. 25-26876 (Ch. 11), DCN KCO-7 (Doc. 53): Memorandum of Points and Authorities in Support of Debtors' Emergency Motion ... to Honor Prepetition Obligations to Physicians as Critical Vendors | 2025-12-09 | 21 | https://storage.courtlistener.com/recap/gov.uscourts.caeb.695309/gov.uscourts.caeb.695309.53.0.pdf | `3087bfa23642959c25f609dc1073b8c7c683a2184e2beca3a9e378df8bff3c01` |
| `FILED-EXAMPLE-motion-brief-2.pdf` | Creditor California Geologic Energy Management Division (Attorney General of California: Deborah M. Smith, Alice M. Segal) | *In re Griffin Resources, LLC*, Case No. 24-12873 (Ch. 11, Subchapter V), DC No. DOJ-1 (Doc. 94): Memorandum of Points and Authorities in Support of Objection to Debtor's Election to be Designated as a Small Business Subchapter V Debtor | 2024-12-06 | 10 | https://storage.courtlistener.com/recap/gov.uscourts.caeb.681034/gov.uscourts.caeb.681034.94.0.pdf | `71599f1bb56c53a21ac88da7db4788c757a7638d1a5d06deb3df652e05c2c80e` |
| `FILED-EXAMPLE-motion-brief-3.pdf` | Debtor Madera Community Hospital (Wanger Jones Helsley: Riley C. Walter et al.) | *In re Madera Community Hospital*, Case No. 23-10457 (Ch. 11), DC No. WJH-7 (Doc. 40): Memorandum of Points and Authorities in Support of Emergency Motion to Limit Scope of Notice for Chapter 11 Case | 2023-03-13 | 7 | https://storage.courtlistener.com/recap/gov.uscourts.caeb.665812/gov.uscourts.caeb.665812.40.0.pdf | `bcee42a35b4f6a17e597300dcc09fa4c4aff4d978d6227ccfc89ce1304dc928c` |

Three filers, three firms; each a memorandum filed as a document of its own, as LBR 9004-2(c)(1) and 9014-1(d)(4)
ask. All three have a text layer. Fox Rothschild and Wanger Jones Helsley note the page total at the upper left of
page 1 (LBR 9004-2(c)(4)); the Attorney General's filing does not.

`usage/INPUT-motion-brief.md` is transcribed from the Fox Rothschild memorandum: the caption (the joint debtors'
"Affects ..." check boxes and the jointly administered case number are not transcribed), the introduction and its
footnote, I-II whole except the table of the Physicians' specialties and footnote 4 (HCAI) (the line that cites it is
one LibreOffice fits 0.04 pt fuller than typst, the shared model's open line-fit tolerance item; README "Known gaps"),
III whole (its bullets as a list), IV.A without its three paragraphs on unpublished critical-vendor orders and the
business judgment, IV.B whole (the CoServ test as a block quotation), V-X whole, and the signature. The other
two exemplars are used for the tier-2 comparison only.

Searches: CourtListener RECAP storage listing (`https://com-courtlistener-storage.s3.amazonaws.com/?list-type=2&prefix=recap/gov.uscourts.caeb.69`,
`.70`, `.68`, `.67`, `.66`), 500 candidate documents read at page 1 for "points and authorities"; hits besides the
three kept: two oppositions (694537 Docs. 28, 32), a memorandum of the same Fox Rothschild case (695309 Doc. 25), a
second Wanger Jones Helsley memorandum (665812 Doc. 31), a combined stay-relief motion and memorandum (674616 Doc.
126).
