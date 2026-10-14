# Exemplar source: adversary complaint, Bankruptcy Court M.D. La. (lamb)

Status: **BLOCKED: no public exemplar.** No text-based filed adversary complaint from this court was found, so there is no `FILED-EXAMPLE-*.pdf` in this folder and no transcription is based on a filing. The template is built from the rules (see `../README.md`). The sample is fictitious.

Date searched: 2026-10-14 (second pass; the first pass was the same day).

## Sources reached

| Source | Result |
|---|---|
| CourtListener, `court=lamb` RECAP search (`https://www.courtlistener.com/api/rest/v4/search/?q=...&court=lamb&type=r`, and the web UI `?q=...&type=r&court=lamb`) | Not reachable from this box: API calls timed out; the web UI returned HTTP 403 (second pass, WebFetch: HTTP 403). |
| The court's own site, `https://www.lamb.uscourts.gov/` | Direct HTTP requests rejected by a proxy. WebFetch reached the local rules PDF, Standing Order 2026-1, the caption setup form (`Caption Setup Form - AP 08 18 2021.docx`), the blank motion form and the court's opinion PDFs (for example `opinions/2004-09-29_04-1006.pdf`, `opinions/2020-09-22_17-10579.pdf`). No adversary complaint is posted. |
| govinfo, `USCOURTS-lamb-3_23-ap-01002` (*Foster v. Capital City Credit*, Adv. 23-1002, Doc. 67) | Memorandum opinion after trial, not a complaint. The package has no attachment; its `-1` and `-2` URLs return HTML, not a PDF. |
| govinfo, `USCOURTS-lamb-3_18-ap-01025` (*Schott v. Massengale*, Adv. 18-1025, Docs. 89-90) | Proposed findings and conclusions and the court's order on the motion to dismiss. Not a complaint. The `-1` URL is the same order (Doc. 90). |
| govinfo, `USCOURTS-lamd-3_24-cv-00593` (district-court withdrawal of reference, Canseco; the civil action that mentions Kologik) | The URL returns an HTML error page, not a PDF. |
| `kellyhart.com/pleadings/Filing/10311/PLEADDoc1.pdf` to `PLEADDoc12.pdf` (Kologik, Case 24-10311) | All first-day papers; none is an adversary complaint. (The motion in Doc. 8 is the exemplar for `../../motion-brief/`.) |
| Justia dockets (`dockets.justia.com/browse/state-louisiana/court-lamb`) | HTTP 403. |
| inforuptcy.com docket pages (e.g. Informd 3:17-bk-10579 with adversary 18-1025; Kologik 3:24-bk-10311) | Docket summaries only. Direct fetches return HTTP 403; search results show no complaint link. |
| `https://clearinghouse.net/doc/141139/` (a 2020 memorandum in support of a motion to dismiss) | HTTP 403. Court not confirmed. Not used. |
| WebSearch, about 16 queries in both passes (adversary complaint, "Adv. Proc. No.", Chapter 7 trustee names Martin A. Schott, Dwayne M. Murray and Samera L. Abide, Kologik adversary, "gov.uscourts.lamb", storage.courtlistener, Justia / Scribd / docs.justia, Sherry Foster) | Returned the court's local rules, Standing Order 2026-1, caption forms, docket pages, opinions (Watson, Adv. 04-1006, a 2004 opinion; Foster and Schott as above), and complaints from other courts (W.D. La., E.D. La., N.D. Tex.). No M.D. La. adversary complaint PDF. |

## Other leads checked and rejected

- *Watson*, Adv. 04-1006 (memorandum opinion, 2004): plaintiffs were two LLCs, and the opinion is about standing. Not a complaint.
- *Foster*, Adv. 23-1002 (the debtor's own adversary, Doc. 67 memorandum opinion, 14 pp.): opinion only. Its complaint is not published.
- *Schott*, Adv. 18-1025 (the chapter 7 trustee's first amended complaint is described in the order): the complaint itself is not posted.
- Kologik's district-court withdrawal of reference (24-cv-00593, dismissed July 1, 2025 per inforuptcy): the withdrawal motion is not available from a public source reachable from this box.

Docket aggregators (inforuptcy.com) list adversary numbers for some Baton Rouge cases but show no documents. A complaint from one of those dockets would need PACER or the court's CM/ECF, which this box cannot reach.

## Governing text used instead (not an exemplar)

- Local Rules of the Bankruptcy Court, M.D. La., amended January 1, 2022: https://www.lamb.uscourts.gov/sites/lamb/files/2022_Local_Rules.pdf (fetched 2026-10-14 via WebFetch; the PDF text was extracted with `pdftotext`).
- Standing Order 2026-1, Cover Sheet for Adversary Proceedings, signed by Judge Michael A. Crawford, Feb. 24, 2026, effective March 1, 2026: https://www.lamb.uscourts.gov/sites/lamb/files/Standing%20Order%202026-1%20adversary%20cover%20sheet.pdf (text extracted with `pdftotext`).
- Fed. R. Bankr. P. 7008 and 7010, Fed. R. Bankr. P. 9004 (legibility), via https://www.law.cornell.edu/rules/frbp/rule_7008 , rule_7010 , rule_9004 (fetched 2026-10-14).

## To unblock

Get one text-based filed complaint from this court (any adversary, any filer) from PACER, CM/ECF, or RECAP, and save it here as `FILED-EXAMPLE-<short-case>-<adv-no>-adversary-complaint.pdf` with its source recorded in this file. Then transcribe it into `../samples/` and re-run the overlay.
