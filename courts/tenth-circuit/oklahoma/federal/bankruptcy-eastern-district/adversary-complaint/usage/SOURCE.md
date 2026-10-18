# Exemplar sources: adversary complaint (okeb)

All exemplars are public court records from the U.S. Bankruptcy Court for the Eastern District of Oklahoma (PACER/RECAP). Each PDF was fetched from the RECAP archive mirror on CourtListener. Fetched 2026-10-14.

| File | Case | Docket | Filer | Date filed | Document | Pages | Text layer | SHA-256 |
|---|---|---|---|---|---|---|---|---|
| `FILED-EXAMPLE-adversary-complaint.pdf` | *Loud, Trustee v. Apache Transportation, LLC and Rick Reynolds* (Adv. 26-08003), main case *In re CM Heavy Machinery, LLC* No. 24-80617 | 26-08003, ECF 1 | Kelley G. Loud, Chapter 7 Trustee (counsel: Titus Hills Reynolds Love, Tulsa; signed by Kelley G. Loud, OBA #15808) | 2026-02-27 | Complaint (counts: turnover; determination of lien validity; automatic stay violation) | 7 | yes (`pdftotext` yields full text) | 69e10e3e3bbf4f1d5d82d51f81fe0a09774237e27365a17ce96ba63352be59b5 |
| `FILED-EXAMPLE-adversary-complaint-2.pdf` | *Loud, Trustee v. Meadors* (Adv. 25-08019), main case No. 24-80617 | 25-08019, ECF 1 | Kelley G. Loud, Chapter 7 Trustee (same counsel) | 2025-09-09 | Complaint (one count: turnover) | 3 | yes | 3afafb14b34fc03e2eedf88fbb838caf1a18ef97f6bf4fcc8a3fb2ebe5257934 |

Source URLs (RECAP archive, found through the CourtListener search API for `court=okeb`):

- `https://storage.courtlistener.com/recap/gov.uscourts.okeb.91827/gov.uscourts.okeb.91827.1.0.pdf`
- `https://storage.courtlistener.com/recap/gov.uscourts.okeb.91224/gov.uscourts.okeb.91224.1.0.pdf`

## Filer note

Both exemplars come from the same filer (the Chapter 7 trustee's firm). The second exemplar does not give a second filer. No other archived E.D. Okla. adversary complaint was found: searches for complaints by creditors and debtors (Farmers Insurance, Tinker FCU, Vision Bank, AVB Bank, Blackbeard Marine/Ramon) returned no RECAP PDF for the complaint itself (document 1 not archived). See `../README.md`, "Exemplar search".

## What the exemplars settle, and what they do not

- The complaint text, paragraph numbering, count headings, WHEREFORE clauses, footnote and signature block come from the Apache complaint (`usage/INPUT-adversary-complaint.md` transcribes it).
- The caption is Form 416D (adversary caption, not filed by a debtor). Both exemplars omit the chapter number and the judge's initials, which LBR 9004-2 requires. The template follows the rule.
- Line spacing differs between the two exemplars. The Loud v. Meadors complaint is double spaced (about 27 pt baseline pitch, measured from the PDF). The Loud v. Apache complaint is single spaced (about 14 pt). LBR 9004-1(A) requires double spacing ("All pleadings and briefs shall be double spaced"), so the template follows the rule and the Apache spacing is not copied.
