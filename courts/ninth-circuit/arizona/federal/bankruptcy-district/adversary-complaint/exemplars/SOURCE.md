# Exemplar source

BLOCKED: no exemplar

No public filed adversary complaint from the United States Bankruptcy Court for the District of Arizona was found, so there is no `FILED-EXAMPLE-*.pdf` in this folder and no exemplar was transcribed. The template is built from the rules (see `../README.md`). The sample (`samples/INPUT-generic-complaint.md`) is fictional.

Searched on 2026-10-14:

- CourtListener RECAP (`court=arb`, the Arizona bankruptcy court ID): the REST API returned `Request was throttled. Expected available in 31822 seconds`; the web front end returned HTTP 403 to curl. Nothing retrieved.
- WebSearch: "gov.uscourts.arb" pdf adversary complaint. No Arizona documents; results were other districts' templates.
- WebSearch: Arizona bankruptcy adversary complaint pdf, "Adv. No. 2:" with 13 point. Results were docket summaries (Inforuptcy, PacerMonitor) and form-seller pages. Docket pages show 2:26-ap complaints filed by named firms, but not the complaint text.
- WebSearch: "District of Arizona" bankruptcy adversary complaint on DocumentCloud and Scribd. Nothing.
- WebSearch: storage.courtlistener.com RECAP complaint for "arb" with a named Arizona firm. Only opinions and firm pages.
- Court site: `www.azb.uscourts.gov` root and the rules pages were reachable through WebFetch but returned no filings. The court's "Adversary Handout for Pro Se" and "Glossary of events" say each complaint is unique and no court form exists; they are not exemplars. The Arizona court's own site is not fetched by curl from this box (requests are rejected by the proxy).
- PacerMonitor and Inforuptcy docket pages for Arizona adversaries (2:15-ap-00944, 2:16-ap-00123, 2:26-ap-00222 and others): docket text only, no complaint PDF.

What would settle it: a RECAP complaint from an `arb` adversary (2:24-ap or 2:25-ap, 2:26-ap), fetched from `storage.courtlistener.com/recap/gov.uscourts.arb.<docket>/` once the CourtListener API throttle lifts, or a PACER copy.

Date fetched: 2026-10-14.
