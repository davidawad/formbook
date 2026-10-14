# Exemplars: txed motion to dismiss (Rule 12(b)(6)) with memorandum

BLOCKED: no exemplar. No downloadable filed E.D. Tex. Rule 12(b)(6) motion to dismiss with memorandum was found, so this folder holds no `FILED-EXAMPLE-*.pdf`. Searches run on 2026-10-14:

| # | Query or source | Result |
|---|---|---|
| 1 | Web search: E.D. Tex. "Defendant's Motion to Dismiss" "Rule 12(b)(6)" with Marshall/Plano/Sherman divisions, 2025 | Docket-aggregator pages and orders; no PDF of a defendant's motion. Leads (docket pages, not files): Daedalus Prime v. MediaTek (2:24-cv-235); Touchstream v. Charter (2:23-cv-59); Calibrate Networks v. Lee Hecht Harrison (2:25-cv-1075). |
| 2 | Web search: E.D. Tex. motion to dismiss, "Local Rule CV-7", courtlistener/RECAP | Orders and local-rule commentary only. The Texas v. Google order (4:20-cv-957, Dkt. 217) was downloaded from storage.courtlistener.com; it is an order striking a second 12(b)(6) motion, not a motion. |
| 3 | Web search: `storage.courtlistener.com` txed "MOTION TO DISMISS" (extended mode) | Mostly W.D. and N.D. Tex. items and Clearinghouse entries. No txed motion PDF. |
| 4 | Download: texaspolicy.com `Motion-to-Dismiss-ESI-v.-City-of-Dallas.pdf` (a motion to dismiss, E.D. Tex.) | HTTP 403; the body was an HTML error page, not a PDF. Not usable. |
| 5 | Download: eff.org / kittens.eff.org `lifescan_mtd_re_101.pdf` (My Health v. LifeScan, Marshall Div., 2014 Rule 12(b)(6) motion) | HTTP 401. Not usable. |
| 6 | Download: cases.justia.com txedce 2:2016cv00535/168392/78 and 2:2016cv00134/166036/232 | HTTP 403 (Justia refused the download). Not usable. |
| 7 | Web search: cdn.lawlytics.com E.D. Tex. motion to dismiss 2025 | No lawlytics motion found. |
| 8 | Web search: eff.org-hosted E.D. Tex. defendant motion to dismiss, section 101 | An EFF blog post on § 101 practice in E.D. Tex. and secondary sources. No motion PDF. |

Searches 1 through 8 found no downloadable E.D. Tex. Rule 12(b)(6) motion. The E.D. Tex. complaint exemplars are in `../../complaint/exemplars/`.

## What this means for the build

- The template (`typst/txed-motion-brief.typ`) is built from the rules alone (see `../README.md`).
- The sample `samples/INPUT-generic-motion-to-dismiss.md` is fictional. It is not a transcription of any filing, so there is nothing for `tools/overlay.sh` to compare against.
- To close the block: download a text-based E.D. Tex. motion to dismiss (CourtListener RECAP, PACER, or a court-provided copy) into this folder as `FILED-EXAMPLE-<short-case>-<docket>-motion-brief.pdf`, add the source to this file, then transcribe it into `samples/`.
