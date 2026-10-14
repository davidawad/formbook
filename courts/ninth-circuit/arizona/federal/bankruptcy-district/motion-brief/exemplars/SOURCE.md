# Exemplar source

BLOCKED: no exemplar

No public filed motion (with memorandum of points and authorities) from the United States Bankruptcy Court for the District of Arizona was found, so there is no `FILED-EXAMPLE-*.pdf` in this folder and no exemplar was transcribed. The template is built from the rules (see `../README.md`). The sample (`samples/INPUT-generic-motion.md`) is fictional.

Searched on 2026-10-14:

- CourtListener RECAP (`court=arb`): the REST API returned `Request was throttled. Expected available in 31822 seconds`; the web front end returned HTTP 403 to curl. Nothing retrieved.
- WebSearch: "LRBP 9013-1" motion pdf Arizona with Snell & Wilmer, Quarles or Gallagher. Results were the court's Rule 9013-1 text (courtrules.net) and other districts' rules (Tennessee, New Hampshire, Guam). No Arizona motion.
- WebSearch: District of Arizona bankruptcy "motion to dismiss" adversary with "memorandum" pdf "LRBP". Results were 2015 to 2016 docket entries (PacerMonitor) that show Rule 12(b)(6) motions, with no papers, and the Hawaii local rules.
- WebSearch: DocumentCloud or Scribd, Arizona bankruptcy adversary complaint and motion. Nothing.
- Court pages: the court's rule pages (`rule-9013-1`, `rule-9004-1`, `rule-1005-1`) and the June 1, 2026 Local Rules PDF were read through WebFetch, which returned rule text summaries. The court's own site returns 404 or a proxy rejection to curl from this box.

What would settle it: a RECAP motion from an `arb` adversary or a main-case contested matter (2:24-ap, 2:25-ap, 2:26-ap; or 2:xx-bk contested matters), fetched from `storage.courtlistener.com/recap/gov.uscourts.arb.<docket>/` once the CourtListener API throttle lifts, or a PACER copy.

Date fetched: 2026-10-14.
