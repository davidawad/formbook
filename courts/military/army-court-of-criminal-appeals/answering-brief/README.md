# U.S. Army Court of Criminal Appeals (acca): answering brief (brief on behalf of the United States)

- Court: `acca`, U.S. Army Court of Criminal Appeals (`courts/military/army-court-of-criminal-appeals/`)
- Doc type: `answering-brief`. The Government's answer to the appellant's brief, under 32 CFR 150.15 (App. B covers the accused's brief; App. B says an answer may adopt the appellant's facts, add facts, or restate them from the Government's view, and that uncontroverted matter is not repeated). One self-contained folder, no shared files.
- Exemplar: **BLOCKED: no exemplar.** No public ACCA Government answer found; searches listed in `exemplars/SOURCE.md`.
- Sample: `samples/INPUT-fictional-answering-brief.md`. **FICTIONAL** structural fixture (invented names, docket, record cites and holdings), not a transcription of a filing.
- Template: `typst/acca-answering-brief.typ` (entry `typst/main.typ`). Copied from `../opening-brief/typst/`; the differences are the title, the `doc-kind`, and the certificate recipient.
- Status: template built and rendered (5 pages, 0 typst warnings). Overlay: **fail** (no exemplar to pair). Page review: done (5 of 5, below). Tier-1 is **not asserted** (the ACCA form rule was not retrieved; see Known gaps 1-2). One OPEN tier-2 finding (signature block alone on page 4). `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...`, calls `acca-brief`. |
| `typst/acca-answering-brief.typ` | Template. Parameter block at the top: `doc-kind = "answering-brief"`, `brief-title`, `court-line`, `font-family`, `type-size`, `body-leading`, `page-margin`. |
| `samples/INPUT-fictional-answering-brief.md` | Markdown contract sample (frontmatter + body). FICTIONAL. Same frontmatter schema as the opening brief (see `../opening-brief/README.md`, "Markdown contract"). |
| `samples/OUTPUT-fictional-answering-brief.pdf` | `sh tools/render.sh courts/military/army-court-of-criminal-appeals/answering-brief samples/INPUT-fictional-answering-brief.md` (5 pages). |
| `samples/OVERLAY-fictional-answering-brief.*` | Not produced: `sh tools/overlay.sh courts/military/army-court-of-criminal-appeals/answering-brief fictional-answering-brief` exits 1 with "no exemplar pdf". |
| `exemplars/SOURCE.md` | BLOCKED record and the searches tried. |

## Governing rules

The same rules as the opening brief (`../opening-brief/README.md`, "Governing rules"): 32 CFR 150.15(a) (typed, double-spaced, white paper), 32 CFR 150 App. B (cover, section order, certificate), JRAP Rule 17 (form pursuant to each CCA's rules), and the Air Force Rule 17.1 values used only as a stand-in. Read on 2026-10-14; wording caveats are in that README.

Answer-specific points from App. B (paraphrased from the WebFetch summary, not verbatim): an answer may adopt the appellant's facts, add facts, or restate them from the Government's viewpoint; uncontroverted matter is not repeated. The template therefore has no mandatory Statement of the Case in the answer; the fixture uses an "adopts" paragraph.

## Overlay

Not produced. The exemplar is missing, so `tools/overlay.sh` has nothing to pair against (exit 1, "no exemplar pdf").

## Page review (Gate 2)

Every page of `OUTPUT-fictional-answering-brief.pdf` was rendered at 60 dpi and viewed (5 of 5). Fonts embedded: EB Garamond (regular, bold, bold italic). Typst printed no warnings. After the counsel-line fix on page 1, the text of pages 2-5 was compared with the earlier render (`pdftotext -layout`): unchanged.

| Page | Content | Result |
|---|---|---|
| 1 | Cover: court line, caption, docket, title "BRIEF ON BEHALF OF THE UNITED STATES", trial line, Government counsel block | OK. One page. Counsel block was wrapping ("Attorney-Advisor, Government Appellate / Division"); fixed by splitting the fixture's line, not by the template. |
| 2 | Statement of the Case (adopts appellant's); Statement of Facts (Government's view); ERRORS AND ARGUMENT; Error I heading, Standard of Review | OK. Level-1 headings are sticky. |
| 3 | Error I Argument; Error II heading, Standard of Review, Argument; WHEREFORE prayer | OK. |
| 4 | Signature block alone | **OPEN**: the signature block is the only content on page 4. Page 3 was full, so the last paragraph (WHEREFORE) ends page 3 and the signature block starts a new page. A clerk would expect the prayer and the signature together. The template has no keep-with-previous control for markdown content. |
| 5 | Certificate of Filing and Service; certifier block | OK. |

Tier-2 findings (OPEN or ACCEPTED): (a) page 4 signature alone (OPEN, above). (b) The title "BRIEF ON BEHALF OF THE UNITED STATES" is a convention, not checked against a filed ACCA Government answer (ACCEPTED as a placeholder until an exemplar is found). (c) The certificate names "appellate defense counsel for the appellant": App. B's wording covers the Court and opposing counsel; the exact recipients are not verified.

Pitch measured on the opening brief's template (same parameters): body lines 26.4 pt apart on 12 pt type (about 2.2 x size, double spacing); single-spaced blocks 13.7 pt apart.

## Known gaps

1. **Typeface, size and margins are PROVISIONAL.** The ACCA rule was not retrieved. `type-size = 12pt` and `page-margin = 1in` are the Air Force court's Rule 17.1 values. Tier-1 is not asserted until the ACCA text is read.
2. **Page limit, cover and TOC/TOA not confirmed** (see `../opening-brief/README.md`, Known gap 2). No TOC/TOA and no length check.
3. **Title is a convention** (`brief-title`). App. B's form is for the accused; the Government answer's title is not from a source.
4. **Font.** EB Garamond is the only vendored serif; ACCA's typeface is unknown.
5. **No exemplar, no overlay.** The fixture is FICTIONAL, five pages, and shorter than the 8-14 page target because no filed length exists to match.
6. **Signature with prayer** (OPEN, page 4 above): no keep-with-previous control.
7. **Standard of review and prayer are not checked by the template** (the sample has them).
8. **No `tools/check.sh` gates run.** Not in this unit's brief; the template is not stamped.
