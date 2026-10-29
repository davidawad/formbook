# Exemplar source

Public filings of the U.S. Bankruptcy Court, N.D. California, from CourtListener RECAP (the PDFs are the RECAP copies
of the documents as filed; nothing is edited). Found by listing the RECAP storage bucket for `gov.uscourts.canb.*`
(the CourtListener search API needs a token; the storage URLs do not) and reading page 1 of each candidate.
Retrieved 2026-10-29.

| File | Filer (party and counsel) | Case | Filed | Pages | Source URL | sha256 |
|---|---|---|---|---|---|---|
| `FILED-EXAMPLE-motion-brief.pdf` | Defendants Roman Catholic Welfare Corporation of Oakland, Roman Catholic Cemeteries of the Diocese of Oakland, and Adventus (Norton Rose Fulbright US LLP: Rebecca J. Winthrop, Ryan E. Manns, Jason I. Blanchard) | *In re The Roman Catholic Bishop of Oakland*, Case No. 23-40523 WJL (Ch. 11); *Official Committee of Unsecured Creditors v. The Roman Catholic Bishop of Oakland et al.*, Adv. Pro. No. 24-04053 WJL (Doc. 9): Motion to Dismiss Complaint, with Memorandum of Points and Authorities | 2025-01-24 | 28 | https://storage.courtlistener.com/recap/gov.uscourts.canb.603944/gov.uscourts.canb.603944.9.0.pdf | `32f43199fcdf69e4e0bab2a751081f59208cf0967be314c542aa0e279fc41b8b` |
| `FILED-EXAMPLE-motion-brief-2.pdf` | Plaintiffs Humboldt Growers Network, Inc. and Tobias Dodge (Ross B. Jones, Attorney at Law) | *In re David Preston Addington*, Case No. 25-40890 WJL (Ch. 11); *Humboldt Growers Network, Inc. v. Addington*, A.P. No. 25-04032 (Doc. 30): Plaintiffs' Memorandum of Points and Authorities in Support of Motion for Summary Judgment | 2026-08-13 | 22 | https://storage.courtlistener.com/recap/gov.uscourts.canb.608367/gov.uscourts.canb.608367.30.0.pdf | `2d611ced1697fb7a4ddaddba252f0ea21bcf4a1b0be8952fd1be1dc3e45275eb` |

Two filers, two firms. Both have a text layer (`pdftotext` reads them); the first is set in Times-style type with a
Norton Rose "DOCUMENT PREPARED ON RECYCLED PAPER" mark down its left margin, the second in Times New Roman.

`usage/INPUT-motion-brief.md` is transcribed from the Norton Rose Fulbright filing: the caption, the motion (its notice
paragraphs), and of the memorandum the preliminary statement, factual background II.B.6 and its footnote 1 (sections
II.A-B.5 are largely redacted in the public copy and are not transcribed; the layout numbers the one kept section
II.A), the legal standard, the argument's introduction, IV.A.1 whole, the first two paragraphs of IV.A.2, IV.B from
its third paragraph, the conclusion and the signature. Its U+2012 figure dashes are transcribed as en dashes (the
shared model breaks lines at a figure dash differently in each engine). The Ross B. Jones memorandum is used for the
tier-2 comparison only (caption, footer, page numbering).

Searches: CourtListener RECAP storage listing (`https://com-courtlistener-storage.s3.amazonaws.com/?list-type=2&prefix=recap/gov.uscourts.canb.6`),
150 candidate documents of 2024-2026 dockets read at page 1 for "points and authorities"; the four hits were an
opposition (605551 Doc. 7), an opposition to a motion to dismiss (600209 Doc. 8), the Ross B. Jones memorandum, and a
memorandum for stay relief (602392 Doc. 43-2). The Norton Rose filing was found on the docket of the adversary
proceeding the repo's canb adversary-complaint folder already cites (603944).
