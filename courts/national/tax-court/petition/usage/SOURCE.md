# Exemplars: petition (Tax Court)

**Exemplar found (2026-10-15): 1 of 2 filers.** A real, filed Tax Court petition is in `usage/`. Tier 2 needs 2 or 3 exemplars from different filers (docs/EVAL-LOOP.md), so the petition's tier-2 judgement is against this one filer only; see the README.

| File | Case and docket | Filer | Filed | Source (public record) | Fetched |
|---|---|---|---|---|---|
| `FILED-EXAMPLE-petition.pdf` (pages 1 to 52 of 58 of the filing; 52 pages, scanned, OCR text layer added) | *Walter Jesse Lawrence v. Commissioner of Internal Revenue*, U.S. Tax Court Docket No. 20370-09. Amended petition (Form 1 items 1 to 6, notice of deficiency dated May 29, 2009 and July 1, 2009, Ogden, Utah; years 2003, 2004 and 2005) | Walter Jesse Lawrence, petitioner, pro se | Attached as Exhibit 6 to a filing dated 12/09/2009, entered 12/10/2009, in *In re Motors Liquidation Company*, Bankr. S.D.N.Y. No. 09-50026-mg, Doc 4636-1 (the bankruptcy filing that reproduced it). The petition's own signature date is handwritten (read as 10/19/09; not verified against the original). | Document: https://storage.courtlistener.com/recap/gov.uscourts.nysb.233396/gov.uscourts.nysb.233396.4636.1.pdf . Docket page: https://www.courtlistener.com/docket/4327513/4636/1/motors-liquidation-company/ (the RECAP search API gives the file path `recap/gov.uscourts.nysb.233396/gov.uscourts.nysb.233396.4636.1.pdf`, document 4636, attachment 1, Exhibit 6). | 2026-10-15 |

Not included: pages 53 to 58 of the same exhibit (the IRS letters attached to the petition and the bankruptcy forms). The file's pages 1 to 52 have their scanned images unchanged; the OCR text layer was added with `ocrmypdf --force-ocr` (tesseract, English) so that `tools/overlay.sh` can pair pages by text. The filing has no text layer in the original download.

Searched 2026-10-14 (earlier pass, before the find above):

| Search or source | Result |
|---|---|
| WebSearch: Tax Court petition Form 1 pdf, filed petitioner, deficiency notice | Only the Court's own Form 1 (Appendix I, a scanned image with no text layer) and practitioner copies: [Justia print-only form](https://forms.justia.com/official-federal-forms/us-tax-court/petition-other-than-in-small-tax-case-5851.html), [Starkman petition kit](https://www.starkman.com/taxcourt/petition.pdf) (checked: a form kit with sample values, "123 Main Street", not a filed petition). |
| WebSearch: "United States Tax Court" "petition" "Docket No." "assignments of error" courtlistener | No CourtListener copy of a Tax Court petition. Tax Court index pages list cases by docket number, not the filings. |
| WebFetch: CourtListener RECAP search for "United States Tax Court" petition | HTTP 403 (not retrievable). |
| Court's own Appendix I (https://www.ustaxcourt.gov/resources/ropp/Appendix_I.pdf) | HTTP error page, not a PDF. Form 1 text taken from the complete rules PDF instead (see the README). |
| DAWSON public docket search | Not reachable from this box; filings there are not public by default. |

Second search pass, 2026-10-14 (appendices and exhibits, where filed petitions get reproduced):

| Search or source | Result |
|---|---|
| WebSearch (extended): courtlistener storage / complaint exhibits, "United States Tax Court" PETITION caption | No CourtListener-hosted petition. Blank forms only. |
| WebSearch (extended): court of appeals appendix, Tax Court petition with assignments of error | No Form 1 deficiency petition in any appendix surfaced. |
| WebSearch (extended): supremecourt.gov DocketPDF appendices with Tax Court petitions | Several candidates, downloaded and checked (see below). |
| Tax Notes "Meta Petitions Tax Court" and "Electronically Filed Tax Court Petition" | HTTP 403 from this box, not read. |
| Coca-Cola (Docket for 2007-09 years), Medtronic, Amazon, Altera | SEC filings and commentary only; no petition text. |

**Closest real filed petition found, not used.** *Boechler, P.C. v. Commissioner*, Tax Court No. 18578-17L (collection due process, a lien/levy case), petition filed 09/01/2017 by Petitioner Boechler, P.C. It is reproduced at JA-31 to JA-34 of the Joint Appendix in *Boechler, P.C. v. Commissioner*, No. 20-1472 (U.S.), filed 2021-11-15: https://www.supremecourt.gov/DocketPDF/20/20-1472/199964/20211115155049927_2021-11-15%20Boechler%20No.%2020-1472%20Joint%20Appendix.pdf (fetched 2026-10-14). It is the Court's simplified **Form 2** ("Petition": check-box notice, date of notice, year, reasons and facts), not the Rule 34(b) Form 1 deficiency petition this template models (no notice of deficiency, no lettered assignments of error, no deficiency amount). Transcribing it would fit the template to a different pleading, so it is not saved as `SAMPLE-*`. Re-open this if the user wants a CDP-type petition exemplar instead.

Checked and not petitions (Tax Court opinions, orders or decisions reproduced in appendices): *Diebold Foundation* / *Salus Mundi* appendix (No. 18-1069, 2nd Cir.); *Battat* cert petition appendix (No. 25-719, Tax Court orders, 17784-12); *Francis* (No. 19-175); *Sanders* (No. 25-28, Tax Court memo and order, 14986-19); *Sanders* cert petition (No. 20-5444).

Next step if an exemplar is wanted: a named Tax Court docket number whose deficiency petition is public (an attachment to a district-court complaint, an appellate appendix, or a public-interest filing), then download it into `usage/` and record it here (filer, case, docket, date filed, URL, date retrieved).

Retrieved and not used (not filed documents): `Complete-Rules-of-Practice-and-Procedure.pdf` (https://ustaxcourt.gov/files/documents/Complete-Rules-of-Practice-and-Procedure.pdf, "as amended through August 2024"); `Rule-23_Amended_03202023.pdf` (https://www.ustaxcourt.gov/resources/ropp/Rule-23_Amended_03202023.pdf).
