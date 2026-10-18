# Exemplar source

- File: `FILED-EXAMPLE-adversary-complaint.pdf` (4 pages, text layer present; `pdftotext` reads it; fonts are Times New Roman and Courier, some Helvetica and not embedded)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.mtb.87374/gov.uscourts.mtb.87374.1.0.pdf (RECAP archive copy of docket entry 1; the CourtListener docket is https://www.courtlistener.com/docket/69943483/1/britani-nichole-bache-and-jason-robert-bache-adversary-proceeding/)
- Court: United States Bankruptcy Court for the District of Montana (judge suffix BPH; the case-number prefix is the filing division under LBR 9004-1)
- Case: *Robert G. Drummond, Chapter 13 Standing Trustee v. Teri A. Noble*, Adversary No. 9:25-ap-09005-BPH, in *In re Britani Nichole Bache and Jason Robert Bache*, Bankr. No. 9:23-bk-90138-BPH
- Document: Complaint (adversary proceeding; lien avoidance under 11 U.S.C. §§ 362 and 549; FRBP 7001), ECF Doc 1
- Filer: Robert G. Drummond, Chapter 13 Standing Trustee (self-filed; signed "By/s/ Robert G. Drummond, Trustee/Plaintiff")
- Date filed: April 25, 2025 (ECF header "Filed: 04/25/25")
- Date fetched: 2026-10-14

## Why this one

Searched CourtListener's RECAP search (`/api/rest/v4/search/`, court `mtb`) for complaints in Montana bankruptcy adversary proceedings and kept only those whose RECAP copy is in the public archive (`filepath_local` set). Most 2026 adversary complaints (e.g. Thomas v. Marlette, 2:26-ap-02005) are listed as not available. This is the only 2025-or-later Montana complaint in the archive that I could fetch; it is a short complaint (4 pages) with the full caption, a jurisdiction paragraph, counts, prayer, signature and a certificate of mailing, which is the structure the template needs.

## Searches tried

- WebSearch: "Montana bankruptcy court adversary complaint pdf"; results were court web pages and opinions, no complaint PDFs.
- CourtListener RECAP search with `q` = complaint, adversary complaint, cover sheet, etc., `court=mtb`: most hits had `is_available: false`.
- Montana bankruptcy court local rules (`LocalBankruptcyRules_12012025.pdf`, linked from mtb.uscourts.gov/rules-statutes) were read for format; they have no adversary-specific caption rule, so the caption follows FRBP 7010 and Fed. R. Civ. P. 10 (see README.md).

## Limits of this exemplar

- Only one exemplar. The eval-loop tier 2 rule asks for two or three filed exemplars from different filers. A second Montana adversary complaint with a public archive copy was not found.
- Filed under the previous Local Bankruptcy Rules (the current text is effective December 1, 2025). Where the two differ, the template follows the current rule.
