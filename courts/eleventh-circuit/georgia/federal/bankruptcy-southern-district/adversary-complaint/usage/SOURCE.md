# Exemplar source

- File: `SAMPLE-gasb-adversary-complaint-masterlending2604010.pdf` (8 pages, text layer present, `pdftotext` reads it; Times New Roman and Courier, none embedded)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.gasb.349965/gov.uscourts.gasb.349965.1.0.pdf (RECAP copy of ECF 1; docket page https://www.courtlistener.com/docket/73342608/1/master-lending-group-llc-adversary-proceeding/)
- Court: United States Bankruptcy Court, Southern District of Georgia, Savannah Division
- Case: *Caron v. Synergy Homes of Georgia, LLC, et al.* (Adv. Pro. No. 26-04010-EJC), within the Chapter 7 case *In re Master Lending Group, LLC*, No. 23-40569-EJC
- Document: Complaint (ECF 1), with Exhibit 1 (notice of default) at ECF 1-1 (3 pages, not included here)
- Filer: Tiffany E. Caron, Chapter 7 Trustee, by Hunter Maclean Exley & Dunn, P.C. (Francesca Macchiaverna, Robert Hurst, Luckshume Ketheeswaran)
- Date filed: May 14, 2026 (from the ECF header "Filed:05/14/26")
- Date fetched: 2026-10-14

## Why this one

Searched CourtListener's RECAP index for S.D. Ga. bankruptcy adversary complaints (`/api/rest/v4/search/?type=rd&court=gasb`). This is the most recent text-based complaint in the index with a Savannah caption, numbered paragraphs, a jurisdiction and core-proceeding statement, claims and a prayer for relief, and a signature block. It is the only complaint saved here. A second filer was downloaded and checked (Darhyl Butler v. Ally Financial, adv. 24-01001-SDB, ECF 1, 26 pages, filed Jan. 17, 2024, Terry Leiden), but it is 9.6 MB, which is over the snapshot size limit, so it was not kept. Its RECAP URL is https://storage.courtlistener.com/recap/gov.uscourts.gasb.341146/gov.uscourts.gasb.341146.1.0.pdf for anyone who needs the second filer for tier 2.

## Caveats

- Only one complaint exemplar is saved. The eval-loop tier-2 rule asks for two or three from different filers. The second one above is not kept (size), so tier 2 is judged against this one exemplar. Recorded in README.md.
- The exemplar's page 1 (ECF header) has no printed page number; pages 2-8 do. The template follows LR 10.1 (number every page, cover included). See README.md.

## Searches tried

- WebSearch: "Southern District of Georgia" bankruptcy adversary proceeding complaint pdf (returned only court forms and fee schedules, no complaint PDF).
- WebSearch: courtlistener gasb adversary complaint Savannah (returned unrelated district-court dockets).
- CourtListener REST search (type=rd, court=gasb): several complaints in the index; the Master Lending complaint is the one used.
