# uscgcoca: answering brief (Brief on Behalf of the United States)

**Status: BLOCKED: no exemplar. Template is a rules-derived skeleton, not a tier-1 template.**

The CGCCA calls the government's filing a "Government Answer" to the appellant's "Assignments of Error". This folder uses the 1997 rule's wording for the government's brief (32 CFR 150.15(a): a brief on behalf of the government "shall be of like character" as the accused's).

## Governing rules

Same as `../opening-brief/README.md`. The CGCCA Rules of Appellate Procedure with JRAP (Rev. 03/25) could not be read on 2026-10-14 (uscg.mil HTTP 403). The only primary text read is 32 CFR 150.15 and App. B (62 Fed. Reg. 2017, 15 Jan 1997), which is superseded in part and is silent on typeface, margins, page or word limits, cover and tables.

## What the template does (`typst/uscgcoca-answering-brief.typ`)

Same structure and same UNVERIFIED parameters as the opening-brief template (EB Garamond 12 pt, 1 in margins, leading 1.3 em for double spacing, placeholder). The title is "Brief on Behalf of the United States", and the caption's government side is "Appellee". Both wordings need confirming against the JRAP text.

## Sample and render

| File | What |
|---|---|
| `samples/INPUT-smoke.md` | Placeholder sample, template structure only. **Not** transcribed from an exemplar. |
| `samples/OUTPUT-smoke.pdf` | `sh tools/render.sh courts/military/coast-guard-court-of-criminal-appeals/answering-brief samples/INPUT-smoke.md`. Exit 0, no typst warnings, 3 pages. |

Pages reviewed (rasterized at 60 dpi and viewed, 2026-10-14, after the heading fix): 3 of 3 (`OUTPUT-smoke.pdf` pp. 1-3, re-rendered).

Re-run 2026-10-15 (bead fb-595.20.5): `sh tools/render.sh courts/military/coast-guard-court-of-criminal-appeals/answering-brief samples/INPUT-smoke.md` exit 0 (the sample path is relative to the court directory). `OUTPUT-smoke.pdf` is 3 pages, letter. All 3 pages rasterized at 60 dpi and viewed: p. 1 caption and the Statement of the Case, p. 2 Errors and Argument with the "B. Argument" sub-heading and Relief Requested, p. 3 certificate. Layout only; the text is placeholder. No exemplar, so nothing was compared.

## Overlay

`sh tools/overlay.sh courts/military/coast-guard-court-of-criminal-appeals/answering-brief smoke` **failed**: `no exemplar pdf in .../answering-brief/exemplars` (exit 1). No overlay written.

## Findings from the page review

- Level-1 and level-2 headings are now `block(sticky: true)` (same fix as the opening brief). Page 1 now ends with "I. ..." and its "A. Standard of review" sub-heading, and only "B. Argument" flows to page 2. Level-3 headings are not sticky; the template has no level-3 show rule. Left as is: placeholder text, and the layout is unverified.
- Sample text is placeholder throughout; the layout proves structure only.
- Cover: none; the case block and caption open page 1 (App. B has no cover sheet).

## Known gaps

- **No exemplar.** No filed CGCCA government answer was found; the searches are in `exemplars/SOURCE.md`.
- **Rules unreadable** (see Governing rules). Every UNVERIFIED value is a placeholder.
- **Name mismatch.** The court's own label is "Government Answer", not "answering brief". The folder name follows the brief.

BLOCKED: no public exemplar (CGCCA government answer). Two search passes on 2026-10-14 (listed in `exemplars/SOURCE.md`, with the opening-brief trail) found no filed CGCCA government answer. CourtListener returned 0 results for this court; the uscg.mil pages returned HTTP 403; the Navy JAG filings table is empty in the fetched capture. Needs a public copy from the uscg.mil Appellate Briefs index or the Navy JAG filings table, and the JRAP text, before tier-1 work can start.
