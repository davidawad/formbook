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

## Second search pass (2026-10-14, after the motion exemplar was found)

Still no filed adversary complaint from this court. The searches below were run on the same day, from the same box:

- Court-hosted filings for the large *Titan Solar* jointly administered case (`azb.uscourts.gov/re-titan-solar-power-inc-and-its-affiliates`): the page lists the trustees' motions, notices and a fee application (Docs 759, 760, 762, 764, 765) but no adversary complaint. The trustees' settlement motion (Doc 759) describes the complaint in *Birdsell v. Williams* (2:25-ap-00115-MCW, "Adv. ECF No. 1", filed March 26, 2025, 52 pages, ten causes of action, ten exhibits). The complaint is not attached and is not posted. Not in the search index under the adversary number, the defendants' names, or the phrases "Titan" and "adversary complaint".
- Adversary dockets with complaint text not posted: 2:25-ap-00330 (UniCourt docket summary, 12/15/2025), 2:26-ap-00169 *Goernitz v. Moore* (Titan NV docket), 4:25-ap-00133 *Kartchner v. Westlake Services* (Tucson, Nach firm; PacerMonitor and Trellis show docket text only).
- Ninth Circuit and BAP: excerpts of record for Arizona adversary appeals were not found online; the BAP opinions (*In re Searles*, *In re First Protection*) are opinions, not filings. The Ninth Circuit memoranda found (2025, 2021) are opinions.
- govinfo `USCOURTS-azb-*` packages (e.g. `2_13-ap-00486`, `2_20-ap-00045`, `2_18-ap-00054`): court orders and opinions, not party complaints. Checked by text extraction.
- District of Arizona (D. Ariz.) orders on bankruptcy appeals (*WVSV Holdings v. 10K LLC*, 2:20-ap-00060; *Rhoads v. JPMorgan Chase*, 2:11-ap-01880): orders, not complaints.
- Court forms and guides (`Adversary_Handout_for_Pro_Se.pdf`, "Dual Caption/Adversary Pleading Form", the glossary of events): forms and instructions, not filings.
- Government agencies (FTC, SEC, DOJ, CFPB) and the Arizona AG filing adversary complaints in this court: none found. The Arizona AG 23andMe complaint is in the Eastern District of Missouri (case 25-04035), not this court.
- CourtListener RECAP (`courtlistener.com/?type=r&court=arb`) and Justia dockets (`dockets.justia.com/browse/state-arizona`): HTTP 403 from this box.

What would settle it: the complaint in *Birdsell v. Williams*, 2:25-ap-00115-MCW, from PACER or from the trustees' counsel (Nach, Rodgers, Hilkert & Santilli, which posted the motions); or a RECAP copy from `storage.courtlistener.com/recap/gov.uscourts.arb.<docket>/` once the CourtListener block lifts.
