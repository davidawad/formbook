# Exemplar source: brief on behalf of appellant (opening brief), AFCCA

Both exemplars are text-based (`pdftotext` yields the body, caption, tables and certificates). Both came from the AFCCA website's published appellate filings (redacted, public record). CourtListener was not searched directly in this run (the exemplars were found by web search and fetched from the AFCCA site).

## Exemplar 1: `FILED-EXAMPLE-opening-brief.pdf` (13 pages; primary, used by `usage/INPUT-opening-brief.md`)

| Field | Value |
|---|---|
| URL fetched from | https://afcca.law.af.mil/afcca_opinions/cp/douglas_-_40324_f_rev_-_appellate_filings_redacted_2141748.pdf |
| Source pages used | 9–21 of the 37-page compilation (brief pp. 1–12 and the certificate of filing and service, p. 21) |
| Case name | *United States v. Dekota M. Douglas* (the caption reads "Air Force Cadet DEKOTA M. DOUGLAS") |
| Docket no. | ACM 40324 (f rev) |
| Document | "Brief on Behalf of Appellant" (supplemental, filed after remand: "Additional Statement of the Case", "Additional Arguments", two assignments of error) |
| Filer | Heather M. Bruha, Maj, USAF, Appellate Defense Counsel, Appellate Defense Division (signature block) |
| Date filed | 26 April 2024 (cover date and certificate; the court's own order set 2 May 2024 as the deadline) |
| Date fetched | 2026-10-14 |
| Public record | Yes: published by the AFCCA as an appellate filing (redacted version). |
| Notes | No table of contents or table of authorities (under 30 pages). Footnotes 1–4 are in the filing. |

## Exemplar 2: `FILED-EXAMPLE-opening-brief-2.pdf` (12 pages; excerpt, used by `usage/INPUT-opening-brief-2.md`)

| Field | Value |
|---|---|
| URL fetched from | https://afcca.law.af.mil/afcca_opinions/cp/howard_-_40478_f_rev_-_appellate_filings_redacted_2665186.pdf |
| Source pages used | 7–17 and 66 of the 261-page compilation (cover, table of contents, table of authorities, assignments of error, statement of the case, start of the statement of facts; certificate of filing and service). The brief's argument (pp. 24–66 of the compilation) is not in this extract. |
| Case name | *United States v. Brian D. Howard* (caption: "BRIAN D. HOWARD, Airman, USAF") |
| Docket no. | ACM 40478 (f rev) |
| Document | "Brief on Behalf of Appellant" (initial brief: six assignments of error; table of contents and table of authorities) |
| Filer | Matthew L. Blyth, Maj, USAFR, Appellate Defense Counsel, Air Force Appellate Defense Division (cover and certificate) |
| Date filed | 29 September 2024 (cover date; certificate says the same) |
| Date fetched | 2026-10-14 |
| Public record | Yes: published by the AFCCA as an appellate filing (redacted version). |
| Notes | The source PDF has broken cross-reference entries; poppler reconstructs them, so `pdftotext` and `pdftoppm` read it fine, but the overlay tool prints "xref" warnings when it reads the file. The sample is an excerpt (`excerpt: true`) and does not carry the argument. |
