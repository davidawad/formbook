# Exemplars: petition (Tax Court)

**BLOCKED: no exemplar.** No public, filed Tax Court petition (a real case, with a docket number, parties and a filing date) was found. No `FILED-EXAMPLE-*.pdf` is present, so `tools/overlay.sh` cannot run for this doc type.

Searched 2026-10-14:

| Search or source | Result |
|---|---|
| WebSearch: Tax Court petition Form 1 pdf, filed petitioner, deficiency notice | Only the Court's own Form 1 (Appendix I, a scanned image with no text layer) and practitioner copies: [Justia print-only form](https://forms.justia.com/official-federal-forms/us-tax-court/petition-other-than-in-small-tax-case-5851.html), [Starkman petition kit](https://www.starkman.com/taxcourt/petition.pdf) (checked: a form kit with sample values, "123 Main Street", not a filed petition). |
| WebSearch: "United States Tax Court" "petition" "Docket No." "assignments of error" courtlistener | No CourtListener copy of a Tax Court petition. Tax Court index pages list cases by docket number, not the filings. |
| WebFetch: CourtListener RECAP search for "United States Tax Court" petition | HTTP 403 (not retrievable). |
| Court's own Appendix I (https://www.ustaxcourt.gov/resources/ropp/Appendix_I.pdf) | HTTP error page, not a PDF. Form 1 text taken from the complete rules PDF instead (see the README). |
| DAWSON public docket search | Not reachable from this box; filings there are not public by default. |

Next step if an exemplar is wanted: a named Tax Court docket number whose petition is public (for example, one attached to an opinion or a public filing), then download it into `exemplars/` and record it here (filer, case, docket, date filed, URL, date retrieved).

Retrieved and not used (not filed documents): `Complete-Rules-of-Practice-and-Procedure.pdf` (https://ustaxcourt.gov/files/documents/Complete-Rules-of-Practice-and-Procedure.pdf, "as amended through August 2024"); `Rule-23_Amended_03202023.pdf` (https://www.ustaxcourt.gov/resources/ropp/Rule-23_Amended_03202023.pdf).
