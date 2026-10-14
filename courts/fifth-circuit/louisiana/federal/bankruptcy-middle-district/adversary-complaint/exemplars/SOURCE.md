# Exemplar source: adversary complaint, Bankruptcy Court M.D. La. (lamb)

Status: **BLOCKED: no exemplar.** No filed adversary complaint from this court was found, so there is no `FILED-EXAMPLE-*.pdf` in this folder and no transcription is based on a filing. The template is built from the rules (see `../README.md`). The sample is fictitious.

Date searched: 2026-10-14.

## Sources reached

| Source | Result |
|---|---|
| CourtListener, `court=lamb` RECAP search (`https://www.courtlistener.com/api/rest/v4/search/?q=...&court=lamb&type=r`) | Not reachable from this box: API calls timed out (no bytes received after 25-30 s); the web UI returned HTTP 403. |
| The court's own site, `https://www.lamb.uscourts.gov/` | Direct HTTP requests were rejected by a proxy ("Request Rejected", 245 bytes). WebFetch reached the local rules PDF and Standing Order 2026-1 (text extracted from the saved PDFs, see below). No filing is posted on the site. |
| `https://www.courtrules.net/courts/federal/bankruptcy-middle-district-louisiana/local-rules/6168` | HTTP 403 to WebFetch. The rule text was taken from the court's own PDF. |
| `https://clearinghouse.net/doc/141139/` (a 2020 memorandum in support of a motion to dismiss) | HTTP 403. Court not confirmed. Not used. |
| WebSearch, about 9 queries (adversary complaint, Rule 9013 motion, M.D. La. / Baton Rouge / "Adv. Proc." / Chapter 7 trustee / justia / casetext / pacermonitor / docketbird / courtlistener / recap) | Returned the court's local rules, Standing Order 2026-1, Form B1040 and caption forms, change-of-address form, other districts' guides, and inforuptcy.com **docket summaries** (case pages only, no documents). No M.D. La. adversary complaint or motion PDF. |

Docket aggregators (inforuptcy.com) list adversary numbers for some Baton Rouge cases (e.g. 3:09-ap-1096) but show no documents. A complaint from one of those dockets would need PACER or the court's CM/ECF, which this box cannot reach.

## Governing text used instead (not an exemplar)

- Local Rules of the Bankruptcy Court, M.D. La., amended January 1, 2022: https://www.lamb.uscourts.gov/sites/lamb/files/2022_Local_Rules.pdf (fetched 2026-10-14 via WebFetch; the PDF text was extracted with `pdftotext`).
- Standing Order 2026-1, Cover Sheet for Adversary Proceedings, signed by Judge Michael A. Crawford, Feb. 24, 2026, effective March 1, 2026: https://www.lamb.uscourts.gov/sites/lamb/files/Standing%20Order%202026-1%20adversary%20cover%20sheet.pdf (text extracted with `pdftotext`).
- Fed. R. Bankr. P. 7008 and 7010, Fed. R. Bankr. P. 9004 (legibility), via https://www.law.cornell.edu/rules/frbp/rule_7008 , rule_7010 , rule_9004 (fetched 2026-10-14).

## To unblock

Get one text-based filed complaint from this court (any adversary, any filer) from PACER, CM/ECF, or RECAP, and save it here as `FILED-EXAMPLE-<short-case>-<adv-no>-adversary-complaint.pdf` with its source recorded in this file. Then transcribe it into `../samples/` and re-run the overlay.
