# Exemplar source: motion with memorandum, N.D. Okla. Bankruptcy Court (oknb)

**Status: exemplar=yes.** One filed motion with its argument in the same document and a prescribed notice of opportunity for hearing, text-based, saved as `SAMPLE-oknb-motion-brief-okf2411060.pdf`.

| Field | Value |
|---|---|
| URL (PDF, RECAP) | https://storage.courtlistener.com/recap/gov.uscourts.oknb.157483/gov.uscourts.oknb.157483.409.0.pdf |
| Docket entry page | https://www.courtlistener.com/docket/69051495/409/okf-llc/ (CourtListener docket 69051495, entry 409) |
| Case | *In re OKF, LLC*, Bankr. N.D. Okla., Case No. 24-11060-T, Chapter 11 |
| Document | Docket 409: "AMENDED JOINT MOTION OF OKF, LLC AND THE OFFICIAL COMMITTEE OF UNSECURED CREDITORS TO SURCHARGE PURSUANT TO 11 U.S.C. § 506(c) AND EXCLUDE CERTAIN FEES AND CHARGES FROM SECURED CLAIM AND NOTICE OF OPPORTUNITY FOR HEARING." 15 pages. |
| Filer | OKF, LLC, Debtor-in-Possession, and the Official Committee of Unsecured Creditors (joint). Counsel: Mark A. Craige, OBA #1992, and Alexander Sokolosky, OBA #33614, Crowe & Dunlevy, Tulsa (for the Debtor); Gus Kallergis, OH 0071557, Bernstein-Burkley, P.C., Cleveland (for the Committee) |
| Date filed | September 15, 2025 (RECAP entry date for docket 409; the case was opened August 16, 2024) |
| Date fetched | 2026-10-14 (CourtListener v4 search API, anonymous; PDF from storage.courtlistener.com) |
| Text layer | Yes. Body text extracts with `pdftotext` (4,257 words over 15 pages). Scanned-image check: none. |
| Why this one | Text-based; a contested motion (not an adversary request) argued in the same document, with the prescribed NOTICE OF OPPORTUNITY FOR HEARING under LBR 9013-1(B) and a 14-day response period; filed under the current local rules (the court's LBR is "Updated March 21, 2025"); the caption carries the "And Notice of Opportunity for Hearing" title phrase. |

## Searches that led here

1. WebSearch, several queries (standard and extended): returned the court's local rules, the lien-avoidance forms (Rev. 1/2019, official forms, not filings), and govinfo orders on motions to dismiss (orders, not party filings). Not used.
2. CourtListener HTML search returns HTTP 403 to automated fetches. The v4 REST search (`type=r&court=oknb&q=...`) answers anonymously. Queries: `"notice of opportunity for hearing" motion`, `"brief in support" motion "notice of opportunity"`, `motion to avoid lien "notice of opportunity"`.
3. Candidate motions with an available RECAP document, each downloaded and checked with `pdftotext` and `pdfimages`:
   - 16-12042 *Express Integrated Technologies*, Doc 233 (8 pp.): **scanned** (79 images, 112 words). Rejected.
   - 19-10949 *Carroll*, Doc 53 (32 pp.): **scanned** (32 images, 448 words). Rejected.
   - 19-10653 *Innova Global* (Chapter 15), Doc 70 (27 pp., 8,518 words): text-based, motion for relief from stay with "AND NOTICE OF OPPORTUNITY FOR HEARING" in the title. A valid alternate; not chosen because it is a Chapter 15 stay motion filed in 2019, and it would need a longer excerpt.
   - **24-11060 *OKF, LLC*, Doc 409 (15 pp., 4,257 words): chosen.**

## Known differences from the template (recorded in `../README.md`)

- The filing is joint (debtor and committee). The template's signature block takes one signer; the transcription uses the Debtor's counsel (Craige) and carries Sokolosky and Kallergis as the firm and committee counsel in the `for` field only. The second counsel block is not reproduced.
- The filing's certificate is an electronic-service certificate (CM/ECF only), with no served list. The template's certificate sentence says "on the parties listed below"; the transcription passes an empty served list and the template now handles it (see `../typst/oknb-motion-brief.typ`).
- The filing's footnote 4 (after "$3,500,000" in ¶ 27) has no text in the PDF's text layer. The transcription omits it and notes the gap.
- Font-audit note: this filed PDF is not image-only. `pdftotext` extracts 4,212 words; `pdffonts` reports Times-Roman text. The TSV audit's "no text layer" classification is inconsistent with the PDF and should be corrected rather than prompting an exemplar swap.
- Only one exemplar from this court, from one filer (OKF). Tier 2 is judged against this filing and the rules, not against two or three filers.
