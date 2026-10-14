# Exemplar source: adversary complaint, D. Kan. Bankr.

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-rebein-sandy-road-farms-25-07014-adversary-complaint.pdf` |
| URL fetched from | https://storage.courtlistener.com/recap/gov.uscourts.ksb.280252/gov.uscourts.ksb.280252.1.0.pdf (CourtListener RECAP archive; docket page https://www.courtlistener.com/docket/69864546/rebein-v-panhandle-eastern-pipe-line-company-lp/) |
| Case name | *Rebein v. Panhandle Eastern Pipe Line Company, LP* (Adversary Proceeding) |
| Main case | *In re Sandy Road Farms, LLC*, Case No. 22-40446, Chapter 7 (converted from Chapter 11) |
| Adversary docket no. | 25-07014 |
| Court | United States Bankruptcy Court, District of Kansas (Topeka proceedings begin with "7", LBR 7003.1(b)) |
| Document | Complaint to Avoid and Recover Preferential Transfers and to Disallow Claims, with Exhibit A (payment table) and Exhibit B (preference demand letter, 10/18/2024) |
| Filer | Seigfreid Bingham, P.C. (Robert D. Maher; Jonathan A. Margolies), for Steven R. Rebein, Chapter 7 Trustee |
| Date filed | April 9, 2025 (ECF header "Filed 04/09/25", Doc# 1, 13 pages) |
| Date fetched | 2026-10-14 |
| Text layer | Yes. `pdffonts` shows embedded Liberation Sans for the body; `pdftotext` reads it. |

## Search trail

- CourtListener search API (`court=ksb`, `type=r`), query "complaint adversary": listed ksb adversary complaints; those with `is_available: true` were candidates. Rejected: complaints whose RECAP copy is not in the archive (`is_available: false`), and 6-page or image-only PDFs.
- Chosen because: a Chapter 7 trustee complaint (the commonest ksb adversary type), numbered paragraphs, count structure, prayer per count, signature block, text layer, 13 pages.
- Other available ksb complaints seen but not saved: *Williamson v. U.S. Bank Trust* (24-05004), *Williamson v. Cordoba Legal Group* (25-06005, 6 pages, image-only text), *Taylor v. Community Loan Servicing* (23-06024, complaint not in archive).

## Caveats

- Public court record (PACER/RECAP). The ECF header and footer ("Case 25-07014 Doc# 1 Filed 04/09/25 Page n of 13") and the scanned return-receipt card are not transcribed.
- The caption shows no "Adv. Proc. No." (blank for the clerk). That is how the filer left it; the template prints the blank as the clerk's line.
- Only one exemplar. Tier-2 review would normally want 2 or 3 filers. Not done here; see the README gaps.
