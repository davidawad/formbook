# uscgcoca: opening brief (Assignments of Error and Brief on Behalf of Appellant)

**Status: BLOCKED: no exemplar. Template is a rules-derived skeleton, not a tier-1 template.**

## Governing rules

| Source | Used for | Status |
|---|---|---|
| CGCCA Rules of Appellate Procedure with JRAP, Rev. 03/25: `https://www.uscg.mil/Portals/0/Headquarters/Legal/cca/CGCCA%20Rules%20of%20Appellate%20Procedure%20with%20JRAP%20(March%202025).pdf` | Typeface, point size, margins, spacing, page limits, cover, TOC/TOA, signature, certificates, brief order | **NOT VERIFIED.** uscg.mil returned HTTP 403 to both WebFetch and curl on 2026-10-14. No rule text from it was read. |
| 32 CFR 150.15 and App. B, Courts of Criminal Appeals Rules of Practice and Procedure, 62 Fed. Reg. 2017 (15 Jan 1997), `https://www.govinfo.gov/content/pkg/FR-1997-01-15/html/97-890.htm`, effective 1 May 1996 | Brief form ("typed or printed, double-spaced on white paper"), App. B order: caption, case block, Statement of the Case, Statement of Facts, Errors and Argument, signature, certificate of filing and service | Read on 2026-10-14. **Superseded in part** by the JRAP-based rules; this is the only primary text I could read. It says nothing on typeface, margins, page or word limits, cover design or tables. |
| Joint Rules of Appellate Procedure, amended 17 May 2024 (afcca.law.af.mil link) | Would supply the JRAP typeface and format rules | Link returned HTTP 404; not read. |

Rule numbers and dates in this README are as stated in the 1997 text (150.15 and App. B). Nothing else is verified.

## What the template does (`typst/uscgcoca-opening-brief.typ`)

- Caption: "In the United States Coast Guard Court of Criminal Appeals", then the parties as `caption`, then the brief title. The sides come from `caption` in the sample, so no case text is in the template.
- Typeface: EB Garamond (vendored), 12 pt. **UNVERIFIED.** Placeholder.
- Margins: 1 in on all sides. **UNVERIFIED.** Placeholder.
- Spacing: body leading 1.3 em, meant to read as double-spaced (150.15(a)). The exact value is **UNVERIFIED** and has not been measured against any filed brief.
- Page numbers centered in the footer. Headings: level 1 centered bold; level 2 bold, left.
- Signature block after the body (App. B item 7), and a certificate of filing and service (App. B item 8, 1997 wording).

Everything in the template that is marked `UNVERIFIED` must be replaced from the JRAP text before this doc type can claim tier 1.

## Sample and render

| File | What |
|---|---|
| `samples/INPUT-smoke.md` | Placeholder sample. It exercises the template structure only. It is **not** transcribed from an exemplar and must not be treated as one. |
| `samples/OUTPUT-smoke.pdf` | Render of `INPUT-smoke.md`. `sh tools/render.sh courts/military/coast-guard-court-of-criminal-appeals/opening-brief samples/INPUT-smoke.md`. Exit 0, no typst warnings, 3 pages, EB Garamond embedded. |

Pages reviewed (rasterized at 60 dpi and viewed): 3 of 3 (`OUTPUT-smoke.pdf` pp. 1-3).

## Overlay

`sh tools/overlay.sh courts/military/coast-guard-court-of-criminal-appeals/opening-brief smoke` **failed**: `no exemplar pdf in .../opening-brief/exemplars` (exit 1). There is nothing to overlay against. No overlay file was written. (The tool writes `OVERLAY-<id>.pdf` and `.txt`, not `<id>-overlay.pdf`.)

## Findings from the page review

1. **Orphaned heading at the foot of page 1.** "Errors and Argument" sits alone at the bottom of page 1 while its first sub-heading lands on page 2. Typst's default keep-with-next did not hold it. Fix: add `keep-with-next` to level-1 headings or move the heading into a `block(breakable: false)` with the next heading. Not fixed in this pass; it is a placeholder-level defect and the spacing rules are unverified.
2. The body text is placeholder content, so the page layout proves only that the structure compiles and the pieces appear in order. It says nothing about the rule-driven layout.
3. The heading styles (level 3 "A. Standard of review" in bold, level 2 in bold) are a convention choice, not from a rule. UNVERIFIED.

## Known gaps

- **No exemplar.** No filed CGCCA opening brief was found. The search trail is in `exemplars/SOURCE.md`.
- **Rules unreadable.** The JRAP rules that govern typeface, margins, page or word limits, cover, tables and certificates could not be read on this box. Every number marked UNVERIFIED comes from a placeholder, not from a rule.
- **Doc-type name mismatch.** The CGCCA labels the appellant's filing "Appellant's Assignments of Error", not an "opening brief". The doc-type folder name follows the brief, and the title in the template follows the 1997 App. B. Confirm the title against the JRAP text.
- **No cover page.** App. B has no cover sheet; the template has none. Confirm against JRAP.
- **Overlay naming.** `tools/overlay.sh` writes `OVERLAY-<id>.pdf`, which differs from the `<id>-overlay.pdf` in the brief. Kept the tool's name.
- **Render naming.** `tools/render.sh` writes `OUTPUT-<id>.pdf` by default, not `<id>.pdf`. Kept the tool's name.
- **Gate checks.** `tools/check.sh` is not run here: there is no `checks.yaml` for this doc type and no stamp is claimed.

## Searches for an exemplar

See `exemplars/SOURCE.md`.

BLOCKED: no exemplar (CGCCA opening brief). Needs a public copy from the uscg.mil Appellate Briefs index or the Navy JAG court-filings link, and the JRAP text (uscg.mil PDF, or its 2024 JRAP successor), before tier-1 work can start.
