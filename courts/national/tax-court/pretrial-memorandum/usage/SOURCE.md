# Exemplars: pretrial memorandum (Tax Court)

**Exemplar found (2026-10-15): 1 of 2 filers.** A real, filed Tax Court pretrial memorandum (for the respondent) is in `usage/`. Tier 2 needs 2 or 3 exemplars from different filers (docs/EVAL-LOOP.md), so the tier-2 judgement is against this one filer only, and the petitioner-side memorandum is still missing. See the README.

| File | Case and docket | Filer | Filed | Source (public record) | Fetched |
|---|---|---|---|---|---|
| `FILED-EXAMPLE-pretrial-memorandum.pdf` (pages 4 to 26 of the 26-page filing; memorandum pages 1 to 23; OCR text layer added) | *Edward J. Duffy & Shannon L. Duffy v. Commissioner of Internal Revenue*, U.S. Tax Court Docket No. 8711-16. "Respondent's Pretrial Memorandum" / "Pretrial Memorandum for Respondent", Trial Calendar Portland, Oregon, December 10, 2018 | Respondent: Nhi T. Luu, Senior Attorney, U.S. Department of Justice, Tax Division (Portland, Group 2) | Memorandum dated and eFiled in the Tax Court November 26, 2018 (received stamp NOV 26 2018). It was attached to DOJ correspondence filed in the bankruptcy on January 28, 2019. | Document: https://storage.courtlistener.com/recap/gov.uscourts.orb.496563/gov.uscourts.orb.496563.66.0.pdf (26 pages, ECF Doc 66, in *In re Edward J. Duffy*, Bankr. D. Or. No. 18-33339-tmb13). Docket page: https://www.courtlistener.com/docket/7933526/66/edward-j-duffy/ (entry: "Correspondence Re: IRS Pretrial Memorandum filed in U.S. Tax Court case"). | 2026-10-15 |

Not included: pages 1 to 3 of the bankruptcy document (the DOJ cover letter, its service page and the certificate of mailing). The pages are scanned, and the OCR text layer was added with `ocrmypdf --force-ocr` (tesseract, English) so that `tools/overlay.sh` can pair pages by text.

Searched 2026-10-14 (earlier pass, before the find above):

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

Next step if an exemplar is wanted: a named Tax Court docket whose pretrial memorandum is public (the *Blum* or *GFS Holding* filings, if they can be obtained, are the first check), downloaded into `usage/` with this table updated (filer, case, docket, date filed, URL, date retrieved).

Retrieved and used as the form source (not a filed document): `SPTO_regular_sample.pdf`, https://www.ustaxcourt.gov/resources/taxpayer/SPTO_regular_sample.pdf.
