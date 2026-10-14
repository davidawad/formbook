# Exemplar source: motion-brief (almb)

**No exemplar.** No public filed motion from the United States Bankruptcy Court for the Middle District of Alabama was retrieved, so this folder has no `FILED-EXAMPLE-*.pdf` and no transcribed sample. The sample in `samples/` is synthetic (see its frontmatter comment), and `tools/overlay.sh` cannot run here.

## Searches tried (2026-10-14)

- CourtListener REST search API (`type=rd`, `court=almb`, motion terms): throttled after two requests (HTTP 429, "Expected available in 16193 seconds").
- CourtListener web search page (`type=r`, `court=almb`): one successful response (adversary complaint dockets only, see `../adversary-complaint/exemplars/SOURCE.md`), then empty responses.
- Web search: `gov.uscourts.almb` + motion; "Motion for Relief from Stay" + `Bankr. M.D. Ala.` + RECAP; "motion to sell" + Alabama bankruptcy + CourtListener. Results were court hearing calendars (`almb.uscourts.gov/sites/almb/files/20xx*.pdf`, which list motions by case number and movant but are not the motions), Leagle and govinfo opinions, and other districts' filings.
- The court's hearing calendars name motions and docket numbers (for example, a motion for relief from stay, Doc 185, in case 14-32906). A motion could be found by fetching a RECAP docket for one of those case numbers; that was not possible within the rate limit.

To close this gap: find a RECAP-hosted almb motion (a motion for relief from stay or a motion to sell is the most common) and record it here as `FILED-EXAMPLE-<name>-motion.pdf`, then transcribe `samples/INPUT-<id>.md` from it and run `tools/overlay.sh`.
