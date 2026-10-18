# Exemplar source: adversary complaint (M.D. Ga. Bankruptcy Court)

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-adversary-complaint.pdf` |
| URL fetched from | https://storage.courtlistener.com/recap/gov.uscourts.gamb.402337/gov.uscourts.gamb.402337.1.0.pdf (RECAP archive copy of ECF Doc. 1) |
| Docket page | https://www.courtlistener.com/docket/63262380/1/galardi-jr-v-galardi/ |
| Court | United States Bankruptcy Court, Middle District of Georgia, Macon Division |
| Case | *Galardi, Jr. et al. v. Galardi*, Adv. Pro. No. 22-05008; *In re Teri G. Galardi*, Bankr. Case No. 22-50035-JPS (Chapter 11) |
| Document | Complaint for a Determination That Debt Is Not Dischargeable (11 U.S.C. § 523(a)(6), (a)(4), (a)(2)(A)), ECF Doc. 1, 21 pages, exhibits A-F filed as attachments (not included) |
| Filer | Plaintiffs Jack E. Galardi, Jr. and Emelita P. Sy, as Trustee of the Jack E. Galardi, Jr. Sub-Trust; counsel Will Geer (Geer Law Group, LLC) and Garrett Nail (Portnoy, Garner & Nail, LLC) |
| Date filed | 04/25/2022 (ECF header: "Filed 04/25/22") |
| Date fetched | 2026-10-14 |
| Text layer | Yes: `pdffonts` shows Helvetica and LiberationSans (embedded), `pdftotext -layout` reads the whole document. |
| Search | CourtListener search API, `type=r`, `court=gamb`, query `"adversary proceeding" complaint`. This docket was the first result with a RECAP-available complaint in a text-based PDF. |

Notes:
- The ECF header line ("Case 22-05008-JPS Doc 1 Filed 04/25/22 ...") and page footers are the court's own ECF stamp; the template does not reproduce them.
- The signature block prints "Will Geer" under the second `/s/ Garrett Nail` line. The sample transcribes the second signer as Garrett Nail (his name is in the `/s/` line and the bar number is his). This looks like a typo in the exemplar; it is not verified against the attorney's own records.
- Only one filer, so this is one exemplar. See `../README.md`, known gaps.
