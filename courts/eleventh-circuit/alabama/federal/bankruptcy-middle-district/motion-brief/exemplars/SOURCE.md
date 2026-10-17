# Exemplar source: motion-brief (almb)

Two filed papers from the United States Bankruptcy Court for the Middle District of Alabama. Both carry the court's CM/ECF header stamp, and both were modified with iText (the RECAP archive's stamp). The retrieval URL was not recorded when they were added (harvest batch, commit `9239ac7`). Identification below is from the documents themselves.

| File | Paper | Case | Filer | Pages | Used for |
|---|---|---|---|---|---|
| `FILED-EXAMPLE-ebury-street-24-10499-motion-brief.pdf` | Bankruptcy Administrator's Motion to Dismiss (11 U.S.C. § 1112(b)), with the LBR 1017-2 negative-notice legend | In re Ebury Street Capital, LLC, et al., No. 24-10499 (Chapter 11), Doc 176, filed 2024-10-07 | Britt B. Griggs, Bankruptcy Attorney, United States Bankruptcy Administrator, M.D. Ala. | 12 | **Primary.** A main-case motion with numbered grounds, which is this doc type. Transcribed in full as `samples/INPUT-ebury-motion-brief.md`; `tools/overlay.sh` picks it (first PDF in `exemplars/` by name). |
| `FILED-EXAMPLE-wheat-18-03041-motion-brief.pdf` | Defendant's Memorandum of Law in Support of Motion to Alter or Amend Judgment (FRBP 9023, FRCP 59(e)) | Wheat v. Great Lakes Higher Education Corp., Adv. No. 18-03041-WRS (in Case 18-30745-WRS, Chapter 7), Doc 40, filed 2019-08-12 | Samantha R. Miller and R. Randolph Neeley, Assistant United States Attorneys (Louis V. Franklin, Sr., United States Attorney) | 19 | **Second filer, tier-2 comparison only.** A brief in an adversary proceeding (adversary caption, unnumbered argument), so it is not transcribed for this main-case motion template. |

Both are Word documents set in Times New Roman (per `pdffonts`), body double-spaced.
