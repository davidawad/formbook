# Motion brief (memorandum in support of a motion), D. Wyo. (`wyd`)

Doc type `motion-brief`: a memorandum in support of a dispositive motion, filed in the District of Wyoming. Typst is the primary engine. The latex and docx engines are not built for this doc type yet.

## Files

- `typst/main.typ`: entry point. Reads the sample named by `--input sample=...`.
- `typst/wyd-motion-brief.typ`: the template. Parameters are at the top of the file, each with its rule or layout reason.
- `samples/INPUT-elizondo-memo.md`: transcription of the filed exemplar (YAML frontmatter: caption, attorney block, date, signature; markdown body, with `# CERTIFICATE OF SERVICE` last).
- `samples/OUTPUT-elizondo-memo.pdf`: our render (8 pages, EB Garamond, embedded).
- `samples/OVERLAY-elizondo-memo.pdf` and `.txt`: red = ours, blue = filed, black = both. The `.txt` is the page map from `tools/overlay.sh`.
- `exemplars/FILED-EXAMPLE-elizondo-1-26-cv-00263-motion-brief.pdf`: the filed memorandum (ECF Doc. 8, 12 pages). Source and filer in `exemplars/SOURCE.md`.

Build: `sh tools/render.sh courts/tenth-circuit/wyoming/federal/district/motion-brief samples/INPUT-elizondo-memo.md`, then `sh tools/overlay.sh courts/tenth-circuit/wyoming/federal/district/motion-brief elizondo-memo`.

## Rules

Each entry gives the source and how far it was checked. Nothing here is verified against the court's own PDF; the two D. Wyo. local rules could not be fetched (the courtrules.net pages returned HTTP 403), so their text comes from search-result summaries.

| ID | Requirement | Source | Status | Where in the template |
|---|---|---|---|---|
| WYD-FORM-1 (M) | Typed, double spaced, 8 1/2 x 11, one-inch margins on all sides, type not less than 12 point | D. Wyo. LR 10.1(a), as summarised at https://www.courtrules.net/courts/federal/district-wyoming/local-rules/10861 | Summary only. Page size, margins and 13 pt type are asserted in the template; the 12 pt floor is an `assert`. | `typst/wyd-motion-brief.typ`: `page-w`, `page-h`, `margin`, `type-size`, `body-leading` |
| WYD-CAP-1 (M) | Caption: court name, party names with designations, case number | Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10) | Verified against the rule text. The filed memo uses the same caption layout. | `caption()`, `court-title()` |
| WYD-LIMIT-1 (M?) | Page limit for a dispositive-motion brief | D. Wyo. LR 7.1, as summarised by a third-party aggregator (https://www.courtrules.net/courts/federal/district-wyoming/local-rules/rule-7-1): 25 pages for dispositive motions, 10 for non-dispositive. The reply-brief figures in that summary conflict and were not used. | Not verified; not enforced by the template. The 12-page exemplar is under either figure. | none (no check yet) |
| WYD-SIG-1 (C) | Signature block with "/s/", firm lines, role; dated line | Filed exemplar (one filer) | Convention only if shared by two filers; see the tier-2 note. | `signature-block()` |
| WYD-CERT-1 (C) | Certificate of service after the signature | Filed exemplar (one filer) | Filed memo puts it after the signature block. | `wyd-motion-brief()`, split at `# CERTIFICATE OF SERVICE` |

Not yet written as checks: the 12 pt floor and the margins can be measured on the PDF with the same methods as the complaint (`tools/check/lib.sh`), and the page limit needs the official text. `checks.yaml` and the Gate 0 to 3 review for this doc type do not exist yet, so no check stamp has been written.

## What the overlay shows

`samples/OVERLAY-elizondo-memo.pdf` pairs our 8 pages with the filed 12, by text. The page map is in `OVERLAY-elizondo-memo.txt`. Word overlap is a pairing score only, not a grade of the template.

- Page 1: the filed page carries an ECF header ("Case 1:26-cv-00263-SWS Document 8 Filed 10/05/26 Page 1 of 12"). That line is added by the court's filing system, so we do not reproduce it. The caption and title sit at different heights because the filed layout uses a different font and leading. Tier 3.
- Pages 2 to 7: the body text lines do not coincide, which is expected because the filed body is CenturySchoolbook and ours is EB Garamond at 13 pt. The line pitch and the heading positions line up closely enough to read.
- Page 8: the filed signature block sits at the left margin. Ours sits in the right half, following the complaint template. Only one filer is on file for this doc type, so this is one filer's style (tier 3) and is left as it is.
- Missing from ours: the filed running footer (short title, "U.S. District Court Case No. 26-CV-263") on every page. It is a convention that may matter for tier 2 and is listed as an open gap below.

## Gaps and tier status

- **Exemplars: one, not two.** `exemplars/` holds only the Elizondo memorandum. `EVAL-LOOP.md` needs two or three filers before a tier-2 judgement, so tier 2 cannot be finished for this doc type. The second candidate in `SOURCE.md` (*Redington v. dGEN Energy Partners*, 1:26-cv-00213-KHR, Doc. 16) was not downloaded. It is the obvious next exemplar.
- **Font.** The filed memo is in Century Schoolbook. Only EB Garamond is vendored, so the template uses it at 13 pt, as the complaint template does. This is a tier-3 difference.
- **Running footer.** Not implemented. Need a second filer to decide whether it is convention.
- **Page limit.** Not enforced. The official LR 7.1 text must be checked before a limit is written.
- **Local rules unverified.** LR 10.1 and LR 7.1 were summarised, not read from the court's PDF. Re-verify both against the official text, with the date verified, before this doc type is promoted.
- **Gate 2 review.** Our render was viewed page by page (pages 1 to 8). No `reviews/` record has been written for this doc type yet.
- **Tiers 1 and 2 not passed.** This is a template with a transcribed sample, not a court-approved one. No checks have been run against it.
