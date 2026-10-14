# Exemplar source

**BLOCKED: no exemplar.** No filed adversary complaint from the U.S. Bankruptcy Court, N.D. W. Va. was found. No `FILED-EXAMPLE-*.pdf` is in this folder, so `tools/overlay.sh` cannot run for this doc type.

- Doc type: adversary complaint (FRBP 7001 et seq.; LBR 7001-1, 7003-1).
- Date searched: 2026-10-14.

## Searches tried (all returned no party-filed complaint)

1. WebSearch: "Northern District of West Virginia" bankruptcy adversary proceeding complaint pdf "adversary proceeding no." trustee. Found court opinions (In re Russell, 2024; In re Warner, 2012), InForuptcy docket pages, and the court's pro hac vice form. No complaint.
2. WebSearch: "Bankruptcy Court" "Northern District of West Virginia" complaint, wvnb, courtlistener. Found forms and the 2003 local rules. No complaint.
3. WebSearch: "Bankruptcy Court for the Northern District of West Virginia" adversary complaint trustee plaintiff 2024/2025. Found the Russell opinion and InForuptcy dockets. No complaint.
4. WebSearch: adversary complaint fraudulent transfer Chapter 7 trustee Wheeling/Clarksburg/Martinsburg. Found the Truth Tellers v. Levine opinion (20-ap-36, 2022) and Sheehan v. Saoud (district court, appeal to the Fourth Circuit). Opinions only.
5. WebFetch: CourtListener search filtered to wvnb. HTTP 403.
6. WebFetch: InForuptcy docket page for 5:24-bk-00267. HTTP 403.
7. WebFetch: GovInfo USCOURTS-wvnb-3_18-ap-00054 (Weaver v. Hartman). This is a court-issued Memorandum Opinion (Doc. 23, 2019), not a party complaint. Its caption was used as a reference for the court name and the "In re" block, and it is not an exemplar.
8. WebFetch: Tika govdocs PDFs surfaced by search. DNS failure in this box.
9. WebSearch: Local rules, wvnb amended 2024/2025. Nothing current found on wvnb.uscourts.gov. courtrules.net returned HTTP 403.

## Sources actually used for the rules (not exemplars)

- Local Bankruptcy Rules, N.D. W. Va., effective Nov. 21, 2003 (adopted by order Oct. 22, 2003): https://www.wvnb.uscourts.gov/sites/wvnb/files/local_rules/Local%20Rules.pdf (fetched 2026-10-14; LBR 7001-1, 7003-1, 9004-2, 9013-1). Saved text was extracted with pdftotext to /tmp and is not in the repo.
- Fed. R. Bankr. P. 7010, 9004 (subd. (b)), 7008, 9013: https://www.law.cornell.edu/rules/frbp/ (fetched 2026-10-14).
- Fed. R. Civ. P. 10: https://www.law.cornell.edu/rules/frcp/rule_10 (fetched 2026-10-14).

## Caveat for the sample

`samples/INPUT-example-adversary-complaint.md` is **fictional**. Its parties, numbers and transfers are invented, and its legal citations are illustrative. It is not a transcription of any filing. It exists to exercise the template's structure: caption, numbered paragraphs, counts, prayer and signature.
