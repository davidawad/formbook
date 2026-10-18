# Exemplar sources: answering brief (USCMCR)

The first row is the primary exemplar: `usage/INPUT-answering-brief.md` is transcribed from it, and `tools/overlay.sh` is run against it.
The second row is a second answering-type filing in the same case from the other side. It is kept for comparison only, not transcribed.

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-answering-brief.pdf` (49 pages, text-based; `pdftotext` yields the text; 9.3 MB) |
| URL fetched from | https://ccrjustice.org/sites/default/files/assets/Hicks%20v.%20United%20States%20-%20Gvt.%20Brief%20Re%20Jurisdiction%20(Dec.%2019,%202013).pdf (hosted by the Center for Constitutional Rights) |
| Case | *David M. Hicks v. United States*, U.S. Court of Military Commission Review, CMCR Case No. 13-004 |
| Document | "Brief of the United States on the Court's Lack of Authority to Hear This Case" |
| Filer | Appellee, the United States: Chief Prosecutor BG Mark S. Martins, Capt Edward S. White, JAGC, USN, Marc A. Wallenstein, and Danielle S. Tarin (Office of the Chief Prosecutor, Office of Military Commissions) |
| Date filed | December 19, 2013 |
| Date fetched | 2026-10-14 |
| Note | This is the appellee's response to the Court's December 4, 2013 briefing order on its own authority to hear the case. It is not a response to an opening brief on the merits, so its issues and argument follow the Court's order. |

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-answering-brief-2.pdf` (26 pages, text-based) |
| URL fetched from | https://ccrjustice.org/sites/default/files/assets/Answer%20Brief%20Re%20Jurisdiction%20(Jan.%2010,%202014).pdf |
| Case | *David M. Hicks v. United States*, CMCR Case No. 13-004 |
| Document | "Answer Brief Re Jurisdiction" (the appellant's answer to the government's December 19, 2013 brief) |
| Filer | Appellant David M. Hicks, through his counsel (Center for Constitutional Rights and the detailed defense counsel) |
| Date filed | January 10, 2014 |
| Date fetched | 2026-10-14 |

Public record: both filings were served in the case and posted by the counsel's organization.

## Font-audit text-layer verification

The audit inventory labels `FILED-EXAMPLE-answering-brief-2.pdf` as having no text layer, but local inspection contradicts that label: `pdftotext` extracts 8,111 words from this 26-page PDF. The government brief `FILED-EXAMPLE-answering-brief.pdf` yields 16,497 words across 49 pages. Both public filings in CMCR Case No. 13-004 are text-based answering-type briefs and use Times-Roman; the appellant's answer is the text-layer replacement reference for its audit row, and the government brief is the saved text-layer alternate. Neither requires an image-scan replacement.
