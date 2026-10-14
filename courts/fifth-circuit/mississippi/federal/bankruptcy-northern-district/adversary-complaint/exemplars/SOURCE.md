# Exemplar source: adversary complaint (msnb)

**Status: BLOCKED: no exemplar.** No public filed adversary complaint from the U.S. Bankruptcy Court for the
Northern District of Mississippi was found, so `exemplars/` holds no PDF and the overlay was not run.

Searches tried on 2026-10-14 (no complaint PDF returned):

| Route | Result |
|---|---|
| CourtListener RECAP search, `court=msnb`, `type=r`, complaint query (WebFetch) | HTTP 403; not reachable from this box |
| Web search: msnb adversary complaint, "Adversary Proceeding No.", RECAP / courtlistener | Only msnb hearing calendars (Judge Woodard, 2018 to 2025), court opinions, and PACER/UniCourt pages |
| Web search: § 523 dischargeability complaint, "Comes now", N.D. Miss. | Calendars and opinions only (e.g. A.P. Dkt. 1 described, not printed) |
| Web search: storage.courtlistener.com recap msnb adversary | Southern District of Mississippi statistics only |
| govinfo USCOURTS-msnb packages | Opinions only (e.g. USCOURTS-msnb-1_16-ap-01053); no complaint found |

Filers of any filed document: none. The sample in `samples/` is **synthetic** (fictional parties, numbers and
addresses); it is not a transcription and must not be read as the court's format.

A future box with CourtListener access should search RECAP for msnb adversary numbers (e.g. the 24-01002 and
22-01005 entries in the court's calendars) and save a PDF here as `FILED-EXAMPLE-<short-case>-<docket>-adversary-complaint.pdf`.
