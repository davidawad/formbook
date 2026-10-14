# Exemplars: pretrial memorandum (Tax Court)

**BLOCKED: no exemplar.** No public, filed Tax Court pretrial memorandum was found. No `FILED-EXAMPLE-*.pdf` is present, so `tools/overlay.sh` cannot run for this doc type.

Searched 2026-10-14:

| Search or source | Result |
|---|---|
| WebSearch: "United States Tax Court" "pretrial memorandum" "Docket No." petitioner respondent pdf filed | The Court's blank form and sample orders only: [Pretrial_Memorandum_Form.pdf](https://ustaxcourt.gov/files/documents/Pretrial_Memorandum_Form.pdf), [sample_pretrial_memorandum.pdf](https://ustaxcourt.gov/files/documents/sample_pretrial_memorandum.pdf), [SPTO_regular_sample.pdf](https://www.ustaxcourt.gov/resources/taxpayer/SPTO_regular_sample.pdf). These are court forms, not filings. |
| Download of the form (https://www.ustaxcourt.gov/resources/forms/Pretrial_Memorandum_Form.pdf) | Returned an HTML error page, not the PDF. |
| WebFetch: CourtListener RECAP search for "pretrial memorandum" | HTTP 403. |

The field set and headings in this template come from the form printed in the SPTO sample (which states "A Pretrial Memorandum form is attached to this Order"). That copy has placeholder values (docket 16225-21 and 12345-00, Reno trial calendar, 2000 date), so it is a form layout, not a filed exemplar.

Second search pass, 2026-10-14:

| Search or source | Result |
|---|---|
| WebSearch (extended): Tax Court pretrial memorandum, exhibit or attached to a motion | Court sample orders and the form only. |
| WebSearch (standard): "United States Tax Court" "pretrial memorandum" "Docket No." filed pdf | Court forms and sample orders only (`Pretrial_Memorandum_Form_old.pdf`, `SPTO_small_sample.pdf`, `STPO_regular_sample.pdf`). Not filings. |
| Tax Notes "Couple Files Pretrial Memo" (*Blum*, Docket No. 5313-16, petitioner memorandum dated April 2024) and "Company Files Pretrial Memo" (*GFS Holding Inc.*, Docket No. 11800-22, petitioner memorandum dated May 2023) | HTTP 403 from this box. Summaries only in search snippets. No full text, so nothing was saved. These two are the most promising leads: if the full PDFs can be reached from another route, record them here and transcribe. |
| Supreme Court and appellate appendices (searched for "pretrial memorandum" with exhibit terms) | None found. |

Next step if an exemplar is wanted: a named Tax Court docket whose pretrial memorandum is public (the *Blum* or *GFS Holding* filings, if they can be obtained, are the first check), downloaded into `exemplars/` with this table updated (filer, case, docket, date filed, URL, date retrieved).

Retrieved and used as the form source (not a filed document): `SPTO_regular_sample.pdf`, https://www.ustaxcourt.gov/resources/taxpayer/SPTO_regular_sample.pdf.
