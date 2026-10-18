# Exemplar source: motion with memorandum (M.D. Ga. Bankruptcy Court)

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-motion-brief.pdf` |
| URL fetched from | https://storage.courtlistener.com/recap/gov.uscourts.gamb.341504/gov.uscourts.gamb.341504.63.0.pdf (RECAP archive copy of ECF Doc. 63) |
| Court | United States Bankruptcy Court, Middle District of Georgia, Valdosta Division |
| Case | *Gordon, as Trustee for Alpha Protective Services, Inc. v. American Pawn Shop, Inc. et al.*, Adv. Pro. No. 14-07017; *In re Alpha Protective Services, Inc.*, Bankr. Case No. 12-70482 (Chapter 7) |
| Document | "Memorandum in Support of Motion for Full or Partial Summary Judgment and Final Judgment Under R.Bankr.Pro. 7054(a)", ECF Doc. 63, 16 pages |
| Filer | Neil C. Gordon, Trustee, by counsel Fife M. Whiteside (Columbus, Georgia) |
| Date filed | 11/20/2015 ("Respectfully submitted this 20th day of November, 2015") |
| Date fetched | 2026-10-14 |
| Text layer | Yes: `pdffonts` shows TimesNewRoman (TrueType, not embedded) for the text; `pdftotext -layout` reads the whole document. |
| Search | CourtListener search API, `type=r`, `court=gamb`, queries `"motion to dismiss" "brief in support"`, `"memorandum of law" "motion to dismiss"`, `"motion for summary judgment" "brief"`. Results with RECAP PDFs: Gordon 14-07017 doc 63 (16 pp.), Farr 11-01009 doc 10 (9 pp.), McDaniel 13-04013 doc 7 (7 pp., not downloadable), Simmons 21-01001 doc 27 (7 pp.). Gordon was the longest text-based brief. |

Notes:
- The motion itself (ECF Doc. 62, the "Motion for Summary Judgment") is not available in the RECAP archive (`is_available: false`). This exemplar is therefore the supporting memorandum only. The template's motion-with-memorandum structure is taken from the rules, not from a filed combined document.
- The exemplar's printed title reads "MEMORANDUM IN SUPPORT OF MOTION FOR MOTION FOR FULL OR PARTIAL SUMMARY JUDGMENT ..."; the sample uses "MEMORANDUM IN SUPPORT OF MOTION FOR FULL OR PARTIAL SUMMARY JUDGMENT ..." (the repeated word removed).
- No certificate of service appears in the exemplar. The template's certificate follows LBR 9013-3(a) (amended April 7, 2021), and its service details in the sample are bracketed placeholders, not facts from the exemplar.
- Only one exemplar. See `../README.md`, known gaps.
