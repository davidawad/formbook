# Exemplar source: motion with memorandum, Bankruptcy Court M.D. La. (lamb)

Status: **BLOCKED: no exemplar.** No filed motion (with or without memorandum) from this court was found, so there is no `FILED-EXAMPLE-*.pdf` in this folder and no transcription is based on a filing. The template is built from the rules (see `../README.md`). The sample is fictitious.

Date searched: 2026-10-14.

## Sources reached

| Source | Result |
|---|---|
| CourtListener, `court=lamb` RECAP search | Not reachable from this box: API calls timed out; the web UI returned HTTP 403. |
| The court's own site, `https://www.lamb.uscourts.gov/` | Direct HTTP requests rejected by a proxy. WebFetch reached the 2022 local rules PDF (rules 9013-1, 9013-2, 9013-4, 9013-5, 5005-2 read from it). No filed motion is posted. |
| `https://www.courtrules.net/...bankruptcy-middle-district-louisiana/local-rules/6168` (LR 9013-2) | HTTP 403 to WebFetch. Same text is in the court's PDF. |
| WebSearch, about 6 queries ("Rule 9013" memorandum, "motion to dismiss" adversary Baton Rouge 2025/2026, courtlistener / recap site filters, justia / casetext / pacermonitor) | Returned local rules, forms, and inforuptcy.com **docket pages** for Baton Rouge cases (e.g. 3:26-bk-10182, 3:24-bk-10311). Those are docket summaries, not filings. One 2020 clearinghouse.net memorandum appeared; it returned HTTP 403 and its court was not confirmed. |

## Governing text used instead (not an exemplar)

- Local Rules of the Bankruptcy Court, M.D. La., amended January 1, 2022: https://www.lamb.uscourts.gov/sites/lamb/files/2022_Local_Rules.pdf (rules 5005-2, 9013-1, 9013-2, 9013-4, 9013-5).
- Fed. R. Bankr. P. 9013 via https://www.law.cornell.edu/rules/frbp/rule_9013 (fetched 2026-10-14; text fetched in summary form, see `../README.md`).

## To unblock

Get one text-based filed motion with memorandum from this court (any filer, any case or adversary) from PACER, CM/ECF, or RECAP, and save it here as `FILED-EXAMPLE-<short-case>-<docket>-motion-brief.pdf` with its source recorded in this file. Then transcribe it into `../samples/` and re-run the overlay.
