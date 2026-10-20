# Appellant's Opening Brief template (Texas Court of Appeals)

Typst template for an appellant's brief in a Texas court of appeals (TRAP 38.1). The district and seat on the cover come from the frontmatter (`district`, `seat`; default Fifth District at Dallas, the court of the exemplar). Engines: typst (`typst/`, primary) and docx (`docx/`, not regenerated in the 2026-10-16 pass; see "Engines").

## Governing rules (checked 2026-10-15, re-attempted 2026-10-16)

Verification status: the primary text, the Texas Rules of Appellate Procedure as updated February 6, 2026 (https://www.txcourts.gov/media/1463134/texas-rules-of-appellate-procedure-02062026.pdf), returned HTTP 403 to every fetch from this box on 2026-10-15 and again on 2026-10-16 (WebFetch and curl; the Supreme Court misc. docket orders on txcourts.gov and the syfert.com and state-rules.com copies of Rule 9.4 also returned 403 on 2026-10-16). The rule text below comes from secondary summaries (appeal.pro, RuleDex, state-rules.com search snippets). Re-check each line against the primary PDF before relying on it.

| Rule | Requirement | Where the template uses it | Verification |
|---|---|---|---|
| TRAP 9.4(c) | margins at least 1 inch on both sides, top and bottom | `page-margin` = 1in | secondary |
| TRAP 9.4(d) | text double-spaced; footnotes, block quotations, short lists and issues may be single-spaced | `body-leading` = 1.6em (pitch 31.5 pt, measured); `single-leading` = 0.5em (about 16 pt) for footnotes, block quotations (the issues are set as block quotations), tables, identity list, signature blocks, contents and index | secondary |
| TRAP 9.4(e) | conventional typeface no smaller than 14-point; footnotes no smaller than 12-point | `type-size` = 14pt, `footnote-size` = 12pt (measured: footnote glyph boxes are 12/14 of the body's) | secondary |
| TRAP 9.4(g) | cover: case style, case number, title, filing party, lead counsel's name, address, telephone, email, State Bar number | `cover()`: case number, court, caption, parties, lower court, title, `counsel` lines (the author supplies bar number, telephone and email there) | secondary (sibling `supreme-court/brief-on-the-merits/README.md`) |
| TRAP 39.7 | a party requesting oral argument notes the request on the cover | `oral_argument_requested: true` prints ORAL ARGUMENT REQUESTED on the cover | secondary |
| TRAP 9.4(i)(1) | parts not counted: caption, identity of parties and counsel, statement regarding oral argument, table of contents, index of authorities, statement of the case, issues presented, jurisdiction, procedural history, signature, certificates, appendix | `excluded-section` regex on level-1 headings; the count typed in the markdown (literal) in the certificate is replaced by the count | secondary |
| TRAP 9.4(i)(2)(B) | 15,000 words for a computer-generated brief in a court of appeals | `word-limit` = 15000; `assert` fails the render above it | secondary |
| TRAP 38.1(a)-(j) | identity of parties and counsel, table of contents, index of authorities, statement of the case, statement regarding oral argument, issues presented, statement of facts, summary of the argument, argument, prayer | identity grid from `identity`; contents generated from headings; index generated from `authorities` with page numbers found in the layout; other sections are markdown headings in the sample | secondary |
| TRAP 9.5 | certificate of service | markdown section in the sample, signed with `<!-- signer -->` | not verified (the exemplar cites Rule 9.5) |
| Fifth Court local rules | local length and briefing limits | not encoded | secondary |

Typeface: no face is named by the rules, so EB Garamond (vendored; `docs/FONTS.md`).

## Markdown contract

`usage/INPUT-opening-brief.md` starts with a YAML frontmatter block:

- `case_number`, `appellant`, `appellee`, `trial_court`, `county`, `trial_cause`, `brief_title`, `counsel` (list of lines for the cover): required.
- `district`, `seat` (cover court lines; default Fifth, Dallas), `caption`, `trial_judge`, `oral_argument_requested` (bool), `cover_notes` (list of bold lines under it, for example "ACCELERATED APPEAL"): optional.
- `identity`: list of `{role, lines}`; printed as a two-column, single-spaced list where the body holds `<!-- identity -->`.
- `signature` (list of lines; `<!-- signature -->`) and `signer` (list of lines; `<!-- signer -->`, for the certificates): single-spaced blocks in the right half of the page, never split. A certificate section is kept on one page with its `<!-- signer -->` block.
- `authorities`: list of groups `{group, items}`; each item `{name, cite, find, italic}`. `find` is a literal string (usually the reporter cite, such as `451 S.W.3d`) searched for in the body; every page where it appears is listed. An authority never found prints a bold "not cited".

Body:

- Everything before the `<!-- contents -->` line is front matter (identity, record citations), on lower-roman pages from ii after the unnumbered cover. At `<!-- contents -->` the template inserts the table of contents and the index of authorities, then starts the body on arabic page 1.
- `#` headings are centred, bold, upper case; `##` bold; `###` bold italic; all single-spaced and kept with the next block. The contents list levels 1 to 3.
- `>` block quotations are single-spaced and indented 0.5 in each side. Footnotes (`[^id]`) are 12 pt, single-spaced.
- Every body paragraph has a 0.5 in first-line indent, except paragraphs under 50 characters (a record or case citation after a quotation). A paragraph ending in a colon is kept on the page with what follows it.
- A two-column markdown table is a label/text table (first column 2.25 in, no header repeat); other tables keep equal columns.
- the count typed in the markdown (literal) is replaced by the TRAP 9.4(i)(1) count.
- "§ " is joined to its number with a no-break space.

## Exemplar and overlay

- Exemplar: `usage/FILED-EXAMPLE-opening-brief.pdf` (68 pages; Scott H. Palmer, P.C.); source, filer, date and hash in `usage/SOURCE.md`.
- Overlay: `usage/OVERLAY-opening-brief.pdf` and `.txt`. Page map (ours to filed, word overlap): 1-1 cover 73%, 2-3 identity 54%, 3-5 contents 73%, 4-7 index 36%, 5-11 issues 42%, 6-17 hearing facts 30%, 7-19 order 30%, 8-21 summary 60%, 9-24 standard of review 47%, 10-28 law 37%, 11-29 argument 41%, 12-30 law 72%, 13-32 R.E.M. quotation 35%, 14-61 prayer and signature 94%, 15-62 certificates 62%. Low overlaps are pages where the transcription brackets out the minor's facts or where our denser front matter shifts text; red/blue offsets are tier 3.

## Sample

`usage/INPUT-opening-brief.md` is transcribed from the exemplar in the filed order of contents, rearranged to the TRAP 38.1 order: cover, identity of parties, counsel and judges, citation to the record, contents, index of authorities (16 authorities in two groups), address to the court, statement of the case, statement concerning oral argument, issues presented, statement of facts (parts D and E), summary of the argument, standard of review and law (with a footnote), argument on the first issue (law section with three block quotations), conclusion and prayer, signature, certificate of compliance (generated word count) and certificate of service. Text about the minor's background, diagnoses and the complainant is bracketed out; some paragraphs are left out to keep the render near the 8-14 page target.

Render: 15 pages (cover; front matter ii-iv: identity and record citation, contents, index; body 1-11). Every page was rendered at 60 dpi and viewed on 2026-10-16; review in `reviews/2026-10-16.md`.

## Render and review

```
sh tools/render.sh courts/fifth-circuit/texas/state/court-of-civil-appeals/opening-brief usage/INPUT-opening-brief.md
sh tools/overlay.sh courts/fifth-circuit/texas/state/court-of-civil-appeals/opening-brief opening-brief
```

## What changed on 2026-10-16

- Cover: district and seat from frontmatter; optional trial judge line; counsel block pushed to the foot of the page; ORAL ARGUMENT REQUESTED (TRAP 39.7) and cover notes. The cover stays on one page with ten counsel lines.
- Pagination: cover unnumbered, front matter lower roman from ii, body arabic from 1 (previously one arabic sequence from the cover).
- Identity of parties as a single-spaced two-column list (`identity`), rows never split.
- Index of authorities generated from `authorities`, with page numbers found in the layout (TRAP 38.1(c); was a known gap). Dot leaders run to a right-aligned page column, so numbers never wrap away from their entry.
- Word count under TRAP 9.4(i)(1) and limit check under 9.4(i)(2)(B); the count typed in the markdown (literal) in the certificate (was a known gap).
- Signature blocks and certificate signers: single-spaced, right half, unbreakable; a certificate is never separated from its signature (was a known gap).
- Every body paragraph indented (Typst otherwise skips the first paragraph after a heading); the unindented short-line threshold dropped from 100 to 50 characters, which had left real one-line body paragraphs flush.
- Lists and tables single-spaced in their cells and unindented; two-column tables as label/text.
- Colon-ended lead-in paragraphs kept with the list or quotation they introduce; "§" never left at a line end.

## Known gaps

1. One filer for this doc type (Scott H. Palmer, P.C.); tier 2 is judged against this filer and the other doc types' exemplars (Billingham for the appellee's brief).
2. A citation paragraph longer than 50 characters right after a block quotation is indented (the filer sets it flush). The template cannot tell it from a body paragraph. OPEN, tier 2.
3. The contents list level-1 entries in the heading's own case (Title Case), while the headings print upper case. Tier 3.
4. Appendix (TRAP 38.1(k)) is not built; counsel attaches it.
5. Rule text is secondary (see table). `tools/check.sh` was not run (no `checks.yaml` or `rules.md` at the court level); no stamp is written.

## Engines

- **typst** (`typst/`): the reference for the form.
- **docx** (`docx/render.sh`, `docx/build-reference.sh`, `docx/reference.docx`, `docx/texapp.lua`): `usage/OUTPUT-opening-brief.docx` and `.docx.pdf` are from the earlier 8-page sample and were **not regenerated** on 2026-10-16: LibreOffice (`soffice`) is not installed on this box. The docx filter does not know the new contract: it would print `<!-- contents -->`, `<!-- identity -->`, `<!-- signature -->`, `<!-- signer -->` and the count typed in the markdown (literal) literally, and it builds no identity grid, index of authorities, roman front-matter numbering or ORAL ARGUMENT REQUESTED line. BLOCKED until `texapp.lua` is updated and the docx is re-rendered where `soffice` exists.
- BLOCKED: tools/check.sh docx gates 0 to 3 not run (no `checks.yaml`, `rules.md` at the level `check.sh` reads; no `.check-docx.txt` stamp).
- **latex**: not built for this doc type.
