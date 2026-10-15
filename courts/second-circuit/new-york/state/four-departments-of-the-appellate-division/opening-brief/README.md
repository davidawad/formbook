# Fourth Department (nyappdiv): brief for the appellant (opening brief)

- Court: `nyappdiv`, Supreme Court of the State of New York, Appellate Division (`courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/`)
- Doc type: `opening-brief`. The appellant's brief (22 NYCRR 1250.8(b)). Self-contained folder.
- Status: **exemplar found** (one, from the Third Department; see Exemplar below). Render ok, overlay ok, all 11 rendered pages reviewed.

| Gate | Result |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-hussain-CR-23-1493-opening-brief.pdf` (Third Dept, NYSCEF Doc. 39, filed 2024-03-29; see `exemplars/SOURCE.md`) |
| render | ok: `sh tools/render.sh courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/opening-brief samples/INPUT-synthetic-opening-brief.md`, 11 pages, EB Garamond only, no typst warnings (2026-10-15) |
| overlay | ok: `sh tools/overlay.sh …/opening-brief synthetic-opening-brief`, wrote `samples/OVERLAY-synthetic-opening-brief.pdf` and `.txt` (2026-10-15) |
| pages reviewed | 11 of 11 (every page rasterized at 60 dpi and viewed, 2026-10-15). Exemplar: pages 1–48 viewed as contact sheets; 49–93 not viewed |

## Exemplar

The only filed opening brief found in a public source is a Third Department appellant's brief, *People v. Hussain*, CR-23-1493. It is a real text-layer PDF, 93 pages, copied from a news site that republished the NYSCEF filing. The court folder covers all four Departments, so the doc type matches; the Department does not. The Fourth Department's own filings are not public from this box (nycourts.gov and NYSCEF return 403).

What the exemplar settled (and what the template now does):

1. **Front matter numbering.** TOC and TOA are numbered in lowercase roman (`i`, `ii`); the body restarts at arabic `1`. The template did this wrong (arabic from the TOC). Fixed in `typst/nyappdiv-opening-brief.typ`, "Front matter is numbered in lowercase roman".
2. **Statement heading.** The exemplar heading is "STATEMENT OF FACTS". The template's required-sections check accepted only "statement of the case". Widened to accept "facts" (1250.8(b)(4) allows either). Fixed in `required-sections`.
3. **Cover.** Title block, court name in two lines, caption with "A.D. No." on the right, counsel block lower left; the template's cover is consistent with this. The NYSCEF header line and "To Be Argued By / Time Requested" block are not generated (a filing artifact; the rules do not dictate them, and the sample does not include them).
4. **POINT headings.** "POINT I" centred bold above a centred bold title; sub-headings lettered A., B. (template matches).
5. **Block quotations.** Single-spaced and indented from both sides (template matches).

## Known gaps (not fixed here)

1. **Exemplar is from another Department.** Rule choices (cover fields, word-count statement, the Fourth Department's Part 1000 limits) are still unverified against Fourth Department sources. A Fourth Department opening brief would replace or join this exemplar.
2. **Questions presented.** The Third Department exemplar has no "Statement of Questions" section; 1250.8(b)(3) requires one, so the template keeps it. Not settled by the exemplar.
3. **Table of authorities page references** are generated from the sample's `toa:` links. Coverage is only as complete as the markup in the sample.
4. **Word count** in the printing statement is the template's whitespace count of the markdown body, not a word-processor count (see the answering-brief README for the same caveat).
5. **Exemplar pages 49–93** were not viewed in contact sheets.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `nyappdiv-brief`. |
| `typst/nyappdiv-opening-brief.typ` | Template. Parameter block at the top: `court-lines`, `word-limit` (14,000), `footnotes-allowed` (false), `required-sections`. |
| `samples/INPUT-synthetic-opening-brief.md` | Markdown contract sample, invented parties and record cites; structure follows the exemplar; labelled SYNTHETIC in its frontmatter. |
| `samples/OUTPUT-synthetic-opening-brief.pdf` | Render output, 11 pages. |
| `samples/OVERLAY-synthetic-opening-brief.pdf`, `.txt` | Overlay of our render on the exemplar, page map in `.txt`. |
| `exemplars/FILED-EXAMPLE-hussain-CR-23-1493-opening-brief.pdf` | The filed exemplar (Third Dept). |
| `exemplars/SOURCE.md` | URL, case, docket, filer, filing date, date fetched, sha256, and what the exemplar shows. |

[Formbook index](../../../../../../README.md) | [Court folder](../README.md)
