# Appellant's Opening Brief template (Texas Court of Appeals, Fifth District at Dallas)

Typst template for an appellant's opening brief in the Fifth Court of Appeals at Dallas. Engine: typst (`typst/`). latex and docx are not built for this doc type.

## Governing rules (checked 2026-10-15)

Verification status: the primary text, the Texas Rules of Appellate Procedure as updated February 6, 2026 (https://www.txcourts.gov/media/1463134/texas-rules-of-appellate-procedure-02062026.pdf), returned HTTP 403 to every fetch from this box on 2026-10-15 (WebFetch, and curl with browser headers). The Rule 9.4 text below comes from secondary summaries (appeal.pro, RuleDex, state-rules.com). Re-check each line against the primary PDF before relying on it.

| Rule | Requirement | Where the template uses it | Verification |
|---|---|---|---|
| TRAP 9.4(c) | margins at least 1 inch on both sides, top and bottom | `page-margin` = 1in | secondary |
| TRAP 9.4(e) | conventional typeface no smaller than 14-point; footnotes no smaller than 12-point | `type-size` = 14pt, `footnote-size` = 12pt | secondary |
| TRAP 9.4 (spacing) | body text double-spaced; footnotes, block quotations, short lists and issues may be single-spaced | `body-leading` = 1.6em (pitch 2.25em, about 31.5pt); `single-leading` = 0.5em (pitch 1.15em, about 16pt) | secondary |
| TRAP 9.4(i) | word limit 15,000 words for an appellant's brief if computer-generated; word-count certificate | not enforced by the template; counsel supplies the certificate | secondary |
| TRAP 38.1 | contents of an appellant's brief (identity of parties, contents, index of authorities, statement, issues, facts, summary, argument, prayer, appendix) | the template orders the headings the sample supplies; no index of authorities is generated | not verified against primary text |
| TRAP 9.5 | service certificate | counsel supplies | not verified (the exemplar cites Rule 9.5) |
| Fifth Court local rules | local length and briefing limits | not encoded | secondary (search summary of the local-rules page) |

Typeface: no face is named by the rules, so EB Garamond (vendored; `docs/FONTS.md`).

Measured layout (from the rendered sample, `pdftotext -bbox`): body baseline pitch 31.5pt against 16.1pt for single-spaced block quotations, a ratio of 1.96.

## Markdown contract

`samples/INPUT-opening-brief.md` starts with a YAML frontmatter block:

- `case_number`, `appellant`, `appellee`, `trial_court`, `county`, `trial_cause`, `brief_title`: required.
- `caption`: optional line above the parties (for example "IN RE: J.R.").
- `counsel`: a list of lines for the lower-right block of the cover.

The body is ordinary markdown. `#` headings are centred and bold; `##` and `###` are single-spaced and bold or bold italic. The contents page is generated from the level-1 and level-2 headings. Paragraphs shorter than 100 characters (identity lines, short labels) are not indented.

## Exemplar and overlay

- Exemplar: `exemplars/FILED-EXAMPLE-opening-brief.pdf`; source, filer, date and hash in `exemplars/SOURCE.md`.
- Overlay: `samples/OVERLAY-opening-brief.pdf` and `.txt` (page map). Red is our render, blue the filed exemplar, black where both agree. It is a diagnostic (tier 3), not a score.

## Sample

`samples/INPUT-opening-brief.md` is transcribed from the exemplar: the identity of parties, citation to the record, oral-argument statement, statement of the case, issues presented, the standard-of-review and law section, and the start of the first issue's argument. Text that describes the minor's facts, diagnoses and the victim is bracketed out. The render is 8 pages (cover, contents, six body pages).

## Render and review

```
sh tools/render.sh courts/fifth-circuit/texas/state/court-of-civil-appeals/opening-brief samples/INPUT-opening-brief.md
sh tools/overlay.sh courts/fifth-circuit/texas/state/court-of-civil-appeals/opening-brief opening-brief
```

Output: `samples/OUTPUT-opening-brief.pdf`. Review: `reviews/2026-10-15.md`, one row per page of the current PDF, with the PDF's sha256.

## Known gaps

1. No index of authorities is generated or included (TRAP 38.1). Counsel supplies it. Listed as OPEN in the review.
2. No word-count certificate and no certificate of service (TRAP 9.4(i), 9.5). Counsel supplies them. The template does not count words.
3. Signature blocks in the sample are flush left but double-spaced, and can split across a page break. OPEN in the review; the reply sample shows the same case.
4. One filer for this doc type (Scott H. Palmer, P.C.). The EVAL-LOOP asks for two or three filers in tier 2; with one, tier 2 is judged against a single filer's practice.
5. The sample is an excerpt of 8 rendered pages, not the whole brief. The filed statement of facts is left out for the minor's sensitive details.
6. The rule text is from secondary sources (see the table above).
7. `tools/check.sh` (the gates) was not run for this doc type; the PR-level checks in `docs/EVAL-LOOP.md` are not part of this task. No stamp is written.
8. Pagination: the cover is unnumbered and the following pages are numbered from the cover as page 1.

## Engines

- **typst** (`typst/`): the reference for the form.
- **docx** (`docx/render.sh`, `docx/build-reference.sh`, `docx/reference.docx`, `docx/texapp.lua`): `samples/OUTPUT-opening-brief.docx` and `.docx.pdf` (8 pages, LibreOffice). Same page count and the same contents page numbers as typst (3, 3, 3, 3, 4, 5, 5, 5, 6, 6). Matches typst: EB Garamond 14 pt (embedded), 31.5 pt double-spaced body with 0.5 in first-line indent, single-spaced block quotations, 1 in margins, centered page number from page 2 (cover unnumbered), the cover built from the frontmatter, a contents page with page numbers, body lines under 100 characters not indented. Differs: headings in typst render at Typst's default sizes (19.5 pt level 1, 17 pt level 2), and the docx matches those; headings keep more space after them in LibreOffice (about 6 pt); LibreOffice keeps the space above a heading at the top of a page, typst does not. Star paging ("at *21") is escaped in the build so pandoc does not read it as emphasis. Contents page numbers come from a LibreOffice layout (two passes in `docx/render.sh`), not from Word.
- BLOCKED: tools/check.sh docx gates 0 to 3: not run. The court folder has no `checks.yaml`, `rules.md` or `court.json` at the level `check.sh` reads, so the gates cannot start and no `.check-docx.txt` stamp is written.
- Word was not available: the `.docx` was opened with LibreOffice only (the PDF conversion succeeded, which is the no-repair proof here); Word was not checked.
