# Appellee's Brief template (Texas Court of Appeals, Fifth District at Dallas)

Typst template for an appellee's brief in the Fifth Court of Appeals at Dallas. Engine: typst (`typst/`). latex and docx are not built for this doc type.

## Governing rules (checked 2026-10-15)

Verification status: the primary text, the Texas Rules of Appellate Procedure as updated February 6, 2026 (https://www.txcourts.gov/media/1463134/texas-rules-of-appellate-procedure-02062026.pdf), returned HTTP 403 to every fetch from this box on 2026-10-15 (WebFetch, and curl with browser headers). The Rule 9.4 text below comes from secondary summaries (appeal.pro, RuleDex, state-rules.com). Re-check each line against the primary PDF before relying on it.

| Rule | Requirement | Where the template uses it | Verification |
|---|---|---|---|
| TRAP 9.4(c) | margins at least 1 inch on both sides, top and bottom | `page-margin` = 1in | secondary |
| TRAP 9.4(e) | conventional typeface no smaller than 14-point; footnotes no smaller than 12-point | `type-size` = 14pt, `footnote-size` = 12pt | secondary |
| TRAP 9.4 (spacing) | body text double-spaced; footnotes, block quotations, short lists and issues may be single-spaced | `body-leading` = 1.6em (pitch 2.25em, about 31.5pt); `single-leading` = 0.5em (pitch 1.15em, about 16pt) | secondary |
| TRAP 9.4(i) | word limit 15,000 words for a computer-generated brief; word-count certificate | not enforced by the template; counsel supplies the certificate | secondary |
| TRAP 38.2 | contents of an appellee's brief | the template orders the headings the sample supplies; no index of authorities is generated | not verified against primary text |
| TRAP 9.5 | service certificate | counsel supplies | not verified |
| Fifth Court local rules | local length and briefing limits (including the combined appellee and cross-appellant brief) | not encoded | secondary (search summary of the local-rules page) |

Typeface: no face is named by the rules, so EB Garamond (vendored; `docs/FONTS.md`).

## Markdown contract

Same as the opening brief (`../opening-brief/README.md`): frontmatter fields `case_number`, `appellant`, `appellee`, `trial_court`, `county`, `trial_cause`, `brief_title`, optional `caption`, and `counsel` as a list. The cover prints "Respectfully submitted," above the `counsel` lines. Paragraphs shorter than 100 characters are not indented.

## Exemplar and overlay

- Exemplar: `exemplars/FILED-EXAMPLE-answering-brief.pdf`; source, filer, date and hash in `exemplars/SOURCE.md`. A different filer from the two appellant exemplars.
- Overlay: `samples/OVERLAY-answering-brief.pdf` and `.txt`. A diagnostic (tier 3), not a score.

## Sample

`samples/INPUT-answering-brief.md` is transcribed from the exemplar: the statement regarding oral argument, the statement of the case, the abbreviations and record references, the summary of argument's reply issues 2 to 4 (issue 1 omitted), the standard-of-review section, and the start of reply issue I. The parties' personal and financial detail is left out and marked in brackets. The render is 8 pages (cover, contents, six body pages).

## Render and review

```
sh tools/render.sh courts/fifth-circuit/texas/state/court-of-civil-appeals/answering-brief samples/INPUT-answering-brief.md
sh tools/overlay.sh courts/fifth-circuit/texas/state/court-of-civil-appeals/answering-brief answering-brief
```

Output: `samples/OUTPUT-answering-brief.pdf`. Review: `reviews/2026-10-15.md`.

## Known gaps

1. No index of authorities is generated (TRAP 38.2 and 38.1). Counsel supplies it. OPEN in the review.
2. No word-count certificate or service certificate is generated (TRAP 9.4(i), 9.5). Counsel supplies them.
3. The transcription omits most of the statement of facts and the argument's factual passages (personal detail of the parties), so the overlay compares the cover, contents, procedural statements and law only.
4. One filer for this doc type (Karen M. Billingham). Tier 2 needs two or three filers; this doc type has one.
5. Rule text from secondary sources (see the table above).
6. `tools/check.sh` was not run for this doc type. No stamp is written.
7. Pagination: the cover is unnumbered and the following pages are numbered from the cover as page 1.

## Engines

- **typst** (`typst/`): the reference for the form.
- **docx** (`docx/render.sh`, `docx/build-reference.sh`, `docx/reference.docx`, `docx/texapp.lua`): `samples/OUTPUT-answering-brief.docx` and `.docx.pdf` (8 pages, LibreOffice; typst is 8). Matches typst: EB Garamond 14 pt (embedded), 31.5 pt double-spaced body with 0.5 in first-line indent, single-spaced block quotations and headings, 1 in margins, centered page number from page 2 (cover unnumbered), the cover built from the frontmatter, a contents page with page numbers, body lines under 100 characters not indented. Differs: the contents page numbers for "Argument & Authorities" (docx 6, typst 5), its A (6 and 5) and B. Reply Issue I (8 and 7), (the page breaks differ by a few lines before them); headings render at Typst's default sizes (19.5 pt level 1, 17 pt level 2), which the docx matches; headings keep about 6 pt more space after them in LibreOffice; typst does not indent some long paragraphs with italics (its short-paragraph helper), the docx does. Star paging is escaped in the build. Contents page numbers come from a LibreOffice layout (two passes in `docx/render.sh`), not from Word.
- BLOCKED: tools/check.sh docx gates 0 to 3: not run. The court folder has no `checks.yaml`, `rules.md` or `court.json` at the level `check.sh` reads, so the gates cannot start and no `.check-docx.txt` stamp is written.
- Word was not available: the `.docx` was opened with LibreOffice only (the PDF conversion succeeded, which is the no-repair proof here); Word was not checked.
