# Exemplar source: adversary-complaint (pamb)

- File: `FILED-EXAMPLE-webb-sheils-5-20-ap-00078-adversary-complaint.pdf`
- Fetched from: `https://storage.courtlistener.com/recap/gov.uscourts.pamb.270156/gov.uscourts.pamb.270156.1.0.pdf` (CourtListener RECAP archive, document 1 of the adversary docket; found through the CourtListener search API, `type=rd`, `court=pamb`).
- Case: *Sheils, Jr. v. National Debt Relief, LLC*, Adversary No. 5:20-ap-00078-MJC, in bankruptcy case *In re Joseph Ryan Webb*, Chapter 7, Case No. 5-20-00695 (M.D. Pa. Bankr.). Title on the document: "Trustee's Complaint for Turnover of Funds".
- Docket no.: 5:20-ap-00078-MJC (adversary); 5-20-00695 (main case).
- Filer: Robert P. Sheils, Jr., Esquire, Chapter 7 Trustee, by counsel Sheils Law Associates, P.C. (signed by Jill M. Spott, Esquire).
- Date filed: 2020-11-18 (ECF header: "Filed 11/18/20").
- Date fetched: 2026-10-14.
- Public record: RECAP-hosted PDF of a filing on the public docket.
- Text layer: yes (3 pages; `pdftotext` yields the body). Fonts are Helvetica (non-embedded) and an embedded Liberation Sans; the filing is a word-processor PDF with the ECF header stamp on each page.

## Why this one

- It is the only text-based adversary complaint of the M.D. Pa. Bankruptcy Court I could retrieve from the public archive. Other RECAP hits for "Adversary Complaint" were orders, certificates of service, stipulations, or scanned complaints (for example 5:17-ap-00098, doc 1, which is a scan with no text layer and was not used).
- It is short (3 pages). The "target 8-14 pages" depth rule applies to exemplars of that length; this one is three pages, so the sample is the whole document.
- It is one filer's document. A second and third M.D. Pa. adversary complaint from another filer was not found; the eval-loop tier-2 rule (2 or 3 exemplars from different filers) is not met. See `../README.md`.

## Searches tried

- CourtListener search API (`/api/rest/v4/search/`), `type=r` and `type=rd`, `court=pamb`, queries: "adversary complaint", "Adversary Complaint", "complaint filed by", "complaint summons adversary proceeding plaintiff", "complaint dischargeability", "complaint for declaratory". Hits with a hosted PDF were the candidates above.
- Web search for `gov.uscourts.pamb` adversary complaint PDFs: no hosted complaint beyond the RECAP archive; results were opinions (Roodhof, Piazza, Kishbaugh) that describe complaints without reproducing them.
- The court's website (`pamb.uscourts.gov`) lists forms and cover-sheet rules but does not host filed complaints.
