# Exemplar source: motion-brief (a motion, or a motion with its brief, alsb)

All three exemplars are public RECAP copies of filings in the U.S. Bankruptcy Court for the Southern District of Alabama, by three different filers. They were found by listing the RECAP archive's public bucket for `gov.uscourts.alsb.*` (the CourtListener web search and API refused this pod: HTTP 403 and 401), extracting page 1 of every PDF and keeping the motions and briefs signed by counsel. Each has a text layer and carries the court's CM/ECF header. Used only as visual and structural references.

Fetched: 2026-10-29. Each file in `usage/` is the download, byte for byte (sha256 below).

## 1. `FILED-EXAMPLE-motion-brief.pdf` (primary; transcribed in `INPUT-motion-brief.md`, used for the overlay and DEF-COVER-002)

- Case: *Legalist, Inc. v. Thomasboro Landco, LLC, et al.*, Adv. Proc. No. 24-1038-HAC (Bankr. S.D. Ala.), in *In re Thomasboro Landco, LLC*, No. 22-10260-HAC-11, chapter 11
- Document: docket entry 39, "Motion for Leave to Amend Adversary Complaint" (9 pages; a motion with its "Basis for Relief and Memorandum of Law")
- Filer: plaintiff Legalist, Inc., by Baird Holm LLP (Jeremy C. Hollembeak; James T. Schmidt, pro hac vice) and Norman, Wood, Kendrick & Turner (Mark P. Williams)
- Date filed: 02/14/25 (CM/ECF header: "Case 24-01038 Doc 39 Filed 02/14/25 Entered 02/14/25 16:03:51")
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.alsb.165919/gov.uscourts.alsb.165919.39.0.pdf
- sha256: `d47e7684d423af6eb2791be3067d3ba14c8d95b8056b70cb0801e0ce6316e12c`
- Notes: Times New Roman; the caption set in bold; the INPUT types "¶¶" where the filing has "⁋⁋" (U+204B). The CM/ECF header is the court's stamp and is not reproduced.

## 2. `FILED-EXAMPLE-motion-brief-2.pdf` (second filer; tier-2 comparison)

- Case: *Brannan v. Wells Fargo Home Mortgage, Inc.*, Adv. Proc. No. 04-01037 (Bankr. S.D. Ala.), in *In the Matter of Mark Brannan and Kelly Brannan*, No. 02-16647-MAM, chapter 13
- Document: docket entry 25, "Defendant Wells Fargo's Motion to Withdraw the Reference and Supporting Brief" (8 pages; Roman-numbered argument headings, an OF COUNSEL block and a certificate of service)
- Filer: defendant Wells Fargo Bank, N.A., by Hand Arendall, L.L.C. (Henry A. Callaway, III)
- Date filed: 06/04/04 (CM/ECF header)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.alsb.64291.25.0.pdf
- sha256: `74184f1f03e57e824f854ce0143fb4d101a0a6446a0a039280f520aa5795d367`

## 3. `FILED-EXAMPLE-motion-brief-3.pdf` (third filer; tier-2 comparison)

- Case: *In re City of Prichard, Alabama*, No. 09-15000 (Bankr. S.D. Ala.), chapter 9
- Document: docket entry 193, "Memorandum in Support of Motion to Dismiss Bankruptcy Case" (5 pages; a block quotation, two footnotes, a certificate of service)
- Filer: movants (creditors and parties in interest), by Donald J. Stewart (Cabaniss, Johnston, Gardner, Dumas & O'Neal)
- Date filed: 08/19/10 (CM/ECF header)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.alsb.99643.193.0.pdf
- sha256: `03899216d40811df0ad2911c53dda644f7a153444807779cb2f65b493c58fcb0`

## What the three agree on (tier 2)

The court's name centered at the top (no counsel block above it); "In re:" (or "In the Matter of:"), the debtor and its designation at the left, a column of ")" (Hand Arendall ":"), the chapter and case number at the right; in an adversary proceeding the parties below with the adversary number beside them; the title bold and centered; text double-spaced in 12-point Times New Roman; the signature at the right with "/s/" and the typed name, address and telephone beneath; a certificate of service last when one is filed (Hand Arendall, Stewart).
