# Exemplar source: motion with memorandum brief (msnb)

**Status: BLOCKED: no exemplar.** No public filed motion with a memorandum brief from the U.S. Bankruptcy Court
for the Northern District of Mississippi was found, so `exemplars/` holds no PDF and the overlay was not run.

Searches tried on 2026-10-14 (no motion or memorandum PDF returned):

| Route | Result |
|---|---|
| CourtListener RECAP search, `court=msnb`, `type=r`, motion query (WebFetch) | HTTP 403; not reachable from this box |
| Web search: Rule 9013 motion, "memorandum brief", Chapter 13, N.D. Miss. bankruptcy | Hearing calendars only (relief from stay, trustee motions to dismiss, Judge Woodard, 2021 to 2026) |
| Web search: msnb local rules 9013-1 / 9013, motion and memorandum format | Other districts' local rules only |
| msnb.uscourts.gov local-rules page (WebFetch) | "Summary of Local Rules" heading only; no rule text |
| courtrules.net copy of N.D. Miss. local rule 9013-1 (WebFetch) | HTTP 403 |

Filers of any filed document: none. The sample in `samples/` is **synthetic** (fictional parties, numbers and
addresses); it is not a transcription and must not be read as the court's format.

A future box with CourtListener access should search RECAP for msnb motions for relief from stay and save a
PDF here as `FILED-EXAMPLE-<short-case>-<docket>-motion-brief.pdf`.
