# U.S. Army Court of Criminal Appeals (acca): opening brief (brief on behalf of the appellant)

- Court: `acca`, U.S. Army Court of Criminal Appeals (`courts/military/army-court-of-criminal-appeals/`)
- Doc type: `opening-brief`. The appellant's brief, under 32 CFR 150.15 and its Appendix B format. One self-contained folder, no shared files.
- Exemplar: **BLOCKED: no exemplar.** No public ACCA brief found; searches listed in `exemplars/SOURCE.md`.
- Sample: `samples/INPUT-fictional-opening-brief.md`. **FICTIONAL** structural fixture (invented names, docket, record cites and holdings), not a transcription of a filing.
- Template: `typst/acca-opening-brief.typ` (entry `typst/main.typ`).
- Status: template built and rendered (5 pages, 0 typst warnings; re-rendered 2026-10-14, unit acca-32.22). Overlay: **fail** (no exemplar to pair). Page review: done (5 of 5, below; all 5 re-viewed on 2026-10-14). The second exemplar search also found nothing (`exemplars/SOURCE.md`, "Second pass"). Tier-1 is **not asserted**: the ACCA rule for typeface, size, margins and length was not retrieved (see Known gaps 1-2). `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...`, calls `acca-brief`. |
| `typst/acca-opening-brief.typ` | Template. Parameter block at the top: `doc-kind`, `brief-title`, `court-line`, `font-family`, `type-size`, `body-leading`, `page-margin`. |
| `samples/INPUT-fictional-opening-brief.md` | Markdown contract sample (frontmatter + body). FICTIONAL. |
| `samples/OUTPUT-fictional-opening-brief.pdf` | `sh tools/render.sh courts/military/army-court-of-criminal-appeals/opening-brief samples/INPUT-fictional-opening-brief.md` (5 pages). |
| `samples/OVERLAY-fictional-opening-brief.*` | Not produced: `sh tools/overlay.sh courts/military/army-court-of-criminal-appeals/opening-brief fictional-opening-brief` exits 1 with "no exemplar pdf". The tools' names are `OVERLAY-<id>.pdf` and `.txt`, not `<id>-overlay`, so they follow the tools. |
| `exemplars/SOURCE.md` | BLOCKED record and the searches tried. |

## Markdown contract

Frontmatter (YAML, first block of the file):

- `docket`: docket number, printed under the caption.
- `appellant`: `name`, `rank`, `service`.
- `trial`: `place`, `dates`, `court-type` (e.g. "general"), `convening` (App. B: "Tried at (location), on (date(s)) before a (type) court-martial appointed by (convening authority)").
- `counsel`: list of `{lines: [...]}` blocks, two columns on the cover.
- `signature`: lines of the signature block (rank, name, address, telephone).
- `certificate`: `date` and `signature` lines for the Certificate of Filing and Service.
- `appendix`: optional list of strings (App. B: copies of unpublished opinions, statute extracts). Empty list: no appendix page.

Body (Markdown): `#` section headings (STATEMENT OF THE CASE, STATEMENT OF FACTS, ERRORS AND ARGUMENT; the sample writes them in capitals); `##` each error, stated in capitals with a Roman numeral (App. B: "each error is stated in uppercase letters"); `###` for "Standard of Review" and "Argument" under each error. The closing WHEREFORE prayer is ordinary body text at the end of the last error.

## Governing rules

| Rule | Requirement | Where the template uses it | Status |
|---|---|---|---|
| 32 CFR 150.15(a) | "Briefs and assignments of errors shall be typed or printed, double-spaced on white paper, and securely fastened at the top." Record references show page numbers and exhibit designations. | `body-leading` (double spacing); page `us-letter`; record cites are the author's job | Read verbatim (LII, 2026-10-14). |
| 32 CFR 150, App. B (§ 150.15) | Cover: court name (footnote: "United States Army Court of Criminal Appeals"); caption "United States v." with the accused's name, rank, service, service number, and "Appellant"; "Tried at ... before a ... appointed by ..." line; Statement of the Case; Statement of Facts; Errors and Argument (each error in uppercase, a separate argument, standard of review, prayer); counsel signature; Certificate of Filing and Service; optional Appendix. | `cover`, `closing`, section headings | Read as a summary by WebFetch of the LII page (2026-10-14), not verbatim. Re-check the wording against the e-CFR before any tier-1 claim. |
| Joint Rules of Appellate Procedure, Rule 17 (2024) | "Except as otherwise expressly provided in these rules, form, content, and space limitations for pleadings and briefs shall be pursuant to CCA rules." | Explains why no typeface or size is set from the joint rules | Read from the Air Force CCA's reproduction of the joint rules (2026). The USCG-hosted copy and the ACCA rules were not readable (403, 502). |
| AFCCA Rule 17.1(a) (Air Force, not ACCA) | 12-point proportional type (Times New Roman or Century Schoolbook); double-spaced; one side of white 8.5 x 11 paper; margins at least one inch on all four sides. | `type-size = 12pt`, `page-margin = 1in`, marked PROVISIONAL in the template | Used only as a stand-in. It is another court's rule. |

## Overlay

Not produced. The exemplar is missing, so `tools/overlay.sh` has nothing to pair against (exit 1, "no exemplar pdf").

## Page review (Gate 2)

Every page of `OUTPUT-fictional-opening-brief.pdf` was rendered at 60 dpi and viewed (5 of 5). Fonts embedded: EB Garamond (regular, bold, bold italic). Typst printed no warnings.

| Page | Content | Result |
|---|---|---|
| 1 | Cover: court line, caption, docket, title, trial line, counsel block | OK. One page; no spill onto page 2. Caption restacked (fixed: the "v." had been stranded in a second column). |
| 2 | Statement of the Case; Statement of Facts; the Q/A block quote | OK. Level-1 headings sticky (fixed: "ERRORS AND ARGUMENT" had been orphaned at the foot of this page). |
| 3 | Footnote-reference line; ERRORS AND ARGUMENT I (Standard of Review, Argument) | ACCEPTED: the "(Trial Tr. 212.)" line starts page 3 and its footnote sits on page 3. Fixture text, not a layout defect. |
| 4 | ERRORS AND ARGUMENT II; WHEREFORE prayer; signature block | OK. Signature block single-spaced, indented to 3 in. |
| 5 | Certificate of Filing and Service; certifier block | OK. The certificate starts a new page (App. B order). |

Pitch measured with `pdftotext -bbox`: body lines 26.4 pt apart on 12 pt type (about 2.2 x size, double spacing); single-spaced blocks 13.7 pt apart.

Tier-2 findings (OPEN or ACCEPTED): the cover follows the caption layout of a typical filing; the court's cover rule and any required Appendix contents are not confirmed (Known gaps 2). Heading style (bold caps, centered; error headings flush left, bold caps) is a convention chosen for this template, not checked against a filed ACCA brief.

## Known gaps

1. **Typeface, size and margins are PROVISIONAL.** The ACCA rule (Rules of Practice and Procedure, the court's own rule on brief form) was not retrieved. `type-size = 12pt` and `page-margin = 1in` are the Air Force court's Rule 17.1 values. Tier-1 is not asserted until the ACCA text is read.
2. **Page limit, cover, and TOC/TOA not confirmed.** App. B names no table of contents or table of authorities and no page limit. The ACCA Citation Guide (JAGCNet) that might say more was not readable (502). The template has no TOC/TOA and no length check.
3. **Brief title is a convention.** App. B's title is "Assignment of Errors and Brief on Behalf of Accused". The template uses "... on Behalf of Appellant" (`brief-title`). Unverified.
4. **Font.** Only EB Garamond is vendored under `fonts/` (shared, not edited here). ACCA's typeface is unknown, so EB Garamond is a stand-in.
5. **No exemplar, no overlay.** Nothing to compare against. The fixture is FICTIONAL; its length (5 pages) is shorter than the 8-14 page target because there is no filed length to match.
6. **Standard of review and prayer are not checked by the template.** App. B requires both in each error. The template does not parse them; they are in the sample only.
7. **Certificate wording** follows the App. B summary ("mailed or delivered to the Court and to the Government Appellate Division"). Not verbatim.
8. **No `tools/check.sh` gates run.** The check gates were not part of this unit's brief; the template is not stamped.
