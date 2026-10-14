# Exemplar source

**BLOCKED: no exemplar.** No filed motion with memorandum from the U.S. Bankruptcy Court, N.D. W. Va. was found. No `FILED-EXAMPLE-*.pdf` is in this folder, so `tools/overlay.sh` cannot run for this doc type.

- Doc type: motion with memorandum (FRBP 9013; LBR 9013-1).
- Date searched: 2026-10-14.

## Searches tried

1. WebSearch: "Bankruptcy Court" "Northern District of West Virginia" motion memorandum pdf courtlistener wvnb. Found court forms (WVNB 420A notice of motion for stay relief; pro hac vice form), the 2003 local rules, and a 2008 Wheeling hearing calendar. No motion PDF.
2. WebSearch: "Northern District of West Virginia" "motion to dismiss" adversary "memorandum in support" pdf, 2023 to 2025. Found the Shreck opinion (2006), Russell (Bankr. N.D. W. Va. 2024), and Clutter (Bankr. N.D. W. Va., Sept. 28, 2026). Clutter refers to a motion to dismiss at dkt. 4 and a memorandum at dkt. 5, but neither document was retrievable. Opinions only.
3. WebSearch (extended): courtlistener "West Virginia Northern Bankruptcy Court" adversary complaint. No CourtListener result; the closest hit was the Weaver v. Hartman opinion on GovInfo.
4. WebFetch: CourtListener docket search, wvnb. HTTP 403.
5. WebFetch: InForuptcy docket pages (case summaries, no document links). HTTP 403.
6. WebFetch: courtrules.net LBR 9004-1 and 7007-1 pages. HTTP 403. The LBR 9004-1 text (10-point minimum, 25-page limit) is taken from a search-result excerpt and is not verified against the court's own document. See the README.

The complaint folder's `SOURCE.md` lists further searches of the same kind (wvnb, GovInfo, Tika govdocs, Leagle). They apply here as well.

## Caveat for the sample

`samples/INPUT-example-motion-brief.md` is **fictional**. Parties, dates and the motion are invented. The case citations (*Iqbal*, *Twombly*) are real, but their reporter and pin cites were written from memory and have not been checked against the reporters; the other authorities in the sample are illustrative. It exists to exercise the template: caption, negative-notice box, memorandum headings, signature, and certificate of service.
