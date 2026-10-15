# Exemplars: Georgia Court of Appeals, petition-for-rehearing (Rule 37 motion for reconsideration)

Status: **no exemplar**. `BLOCKED: no exemplar`. No filed motion for reconsideration (Ga. Ct. App. R. 37) from this court was downloaded, so `exemplars/` holds no PDF and nothing here is a transcription. The sample in `samples/` is synthetic and written from the rules.

Date searched: 2026-10-15 (fetched from the box, which has network access to CourtListener and general web but is refused by the court's own sites; see below).

## Searches tried

| # | Where | Query | Result |
|---|---|---|---|
| 1 | CourtListener REST v4, `type=r`, `court=gactapp` | `q=` (empty) and `"motion for reconsideration"` | 0 results (no RECAP records for this court) |
| 2 | CourtListener REST v4, `type=o`, `court=gactapp` | `"motion for reconsideration" "Rule 37"` | no results |
| 3 | CourtListener REST v4, `type=r`, no court filter | `"motion for reconsideration" "Court of Appeals of Georgia"` | 50 results, all federal (N.D. Ga., M.D. Ga., S.D. Ga., bankruptcy courts); none is a Georgia Court of Appeals filing |
| 4 | Web search | Georgia Court of Appeals rules, brief form and typeface | official rules found only as a listing (`https://www.gaappeals.gov/wp-content/uploads/2026/03/COA-Rules-Complete-Eff-9-Oct-2025.pdf`) |
| 5 | Web search | "motion for reconsideration" pdf "Court of Appeals of Georgia" Rule 37 word count certificate | the court's `efast.gaappeals.us` archive: a 2015 motion for reconsideration with a separate certificate of service (index 7-2) and clerk return notices (2-16, 4-16), as the search summary describes; the files are prisoner correspondence and were not reachable from the box. `SampleForm7.pdf` on gaappeals.us is a court form, not a filed motion (404 from the box). |

## Why nothing could be downloaded

- `https://www.gaappeals.gov/` and `https://www.gaappeals.us/`: HTTP 403 from CloudFront ("configured to block access from your country") on the rules index, the rules PDF and the sample form. The rules PDF, fetched twice with curl and once through WebFetch, returned 403 each time.
- `https://efast.gaappeals.us/`: redirects (302) to a login-style page; the 2015 archive file names fetched with curl returned 404.
- `https://state-rules.com/georgia/appellate/24/` and `/37/`: Cloudflare managed challenge ("Just a moment..."); WebFetch returned 403.
- `https://www.courtrules.net/...rule-24` and `rule-37`: Cloudflare challenge.

No court-published filed motion of this type was reachable. The search for a text-based filed PDF therefore failed.

## What to do next

Someone with access to the court's e-filing archive (`efast.gaappeals.us`) or a Georgia appellate brief bank can supply a filed motion for reconsideration from this court; it would show the caption, the case-number format and the certificate layout. Drop it into this folder as `FILED-EXAMPLE-<short-case>-<docket>-petition-for-rehearing.pdf`, add its URL and filer here, and then transcribe it into `samples/` to replace the synthetic sample.
