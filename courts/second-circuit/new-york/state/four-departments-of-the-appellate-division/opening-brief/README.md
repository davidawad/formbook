# Fourth Department (nyappdiv): brief for the appellant (opening brief)

- Court: `nyappdiv`, Supreme Court of the State of New York, Appellate Division (`courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/`)
- Doc type: `opening-brief`. The appellant's brief (22 NYCRR 1250.8(b)). Self-contained folder.
- Status: **exemplar found** (one, from the Third Department; see Exemplar below). Render ok, overlay ok, all 11 rendered pages reviewed (verification pass 2026-10-16, below).

| Gate | Result |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-opening-brief.pdf` (Third Dept, NYSCEF Doc. 39, filed 2024-03-29; see `usage/SOURCE.md`) |
| render | ok: `sh tools/render.sh courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/opening-brief usage/INPUT-opening-brief.md`, 11 pages, EB Garamond only, no typst warnings (2026-10-16) |
| overlay | ok: `sh tools/overlay.sh …/opening-brief synthetic-opening-brief`, wrote `usage/OVERLAY-synthetic-opening-brief.pdf` and `.txt` (2026-10-16) |
| pages reviewed | 11 of 11 (every page rasterized at 60 dpi and viewed, 2026-10-16). Exemplar: pages 1–48 viewed as contact sheets (2026-10-15); 49–93 not viewed |

## Exemplar

The only filed opening brief found in a public source is a Third Department appellant's brief, *People v. Hussain*, CR-23-1493. It is a real text-layer PDF, 93 pages, copied from a news site that republished the NYSCEF filing. The court folder covers all four Departments, so the doc type matches; the Department does not. The Fourth Department's own filings are not public from this box (nycourts.gov and NYSCEF return 403).

What the exemplar settled (and what the template now does):

1. **Front matter numbering.** TOC and TOA are numbered in lowercase roman (`i`, `ii`); the body restarts at arabic `1`. The template did this wrong (arabic from the TOC). Fixed in `typst/nyappdiv-opening-brief.typ`, "Front matter is numbered in lowercase roman".
2. **Statement heading.** The exemplar heading is "STATEMENT OF FACTS". The template's required-sections check accepted only "statement of the case". Widened to accept "facts" (1250.8(b)(4) allows either). Fixed in `required-sections`.
3. **Cover.** Title block, court name in two lines, caption with "A.D. No." on the right, counsel block lower left; the template's cover is consistent with this. The NYSCEF header line is not generated (a filing artifact). The "To Be Argued By / Time Requested" block is required by 1250.8(a) and is generated since 2026-10-16 (item 6).
4. **POINT headings.** "POINT I" centred bold above a centred bold title; sub-headings lettered A., B. (template matches).
5. **Block quotations.** Single-spaced and indented from both sides (template matches).
6. **Argued/submitted notation** (added 2026-10-16). 22 NYCRR 1250.8(a) puts it in the upper right-hand section of the cover; the exemplar's cover carries "To Be Argued By / Time Requested" at the top. The template had no such field. It now requires `argument:` in the frontmatter (`presenter` and `time_requested`, or no `presenter` for "Submitted") and prints it at the upper right, opposite the docket.
7. **Filing attorney's email** (added 2026-10-16). 1250.8(a) asks for the name, address, telephone number and email address in the lower right-hand section. The cover printed no email. It now requires `email:` and prints it under the telephone number.

## Known gaps (not fixed here)

1. **Exemplar is from another Department.** Rule choices (cover fields, word-count statement, the Fourth Department's Part 1000 limits) are still unverified against Fourth Department sources. A Fourth Department opening brief would replace or join this exemplar.
2. **Sample is synthetic.** It follows the exemplar's structure but transcribes none of its text, so the overlay's word overlap is low (9–27%) and only the layout of matching page types (cover, TOC, TOA) can be compared.
3. **Questions presented.** The Third Department exemplar has no "Statement of Questions" section; 1250.8(b)(3) requires one, so the template keeps it. The two-page limit of 1250.8(b)(3) is not checked.
4. **Table of authorities** lists the printed page (arabic body page) where each `toa:` link starts. Every listed authority must be cited by a link (the build stops otherwise), and the template does not detect unlinked citations.
5. **Word count** in the printing statement is the template's whitespace count of the markdown body, headings included (1,442 for the sample), not a word-processor count. The 14,000-word limit is a hard stop. The page limit (1250.8(g)(2), typewritten briefs) is not checked.
6. **Footnotes** are refused by the template. The rule comes from a 2012 secondary source on Part 1000; confirm it against the current Part 1000 before relying on it.
7. **Type size** is 14 pt (1250.8(f)(1)(i) for proportional faces). **Line spacing** is double (1250.8(h)); `body-leading` was set by measurement against the rendered page, not against the exemplar.
8. **Font**: no face is named by the rule. 1250.8(f)(1) requires "a serifed, proportionally spaced typeface such as Times Roman"; "such as" is an example, so EB Garamond is kept. Typeface row: face required none named; substitute none; fit n/a. Checked 2026-10-15 against the LII copy. No system font is used.
9. **Cover colour** (blue, §1000.8(a)) is not produced. The paper rule does not settle the e-filed copy.
10. **Form of the printing statement.** §1250.8(b)(6) asks for a certification "on a form approved by the court". That form was not obtained; the statement carries the §1250.8(j) content.
11. **Certificate of service** is not generated.
12. **Fourth Department e-filing** (22 NYCRR Part 1245) was not checked.
13. **Exemplar pages 49–93** were not viewed in contact sheets.

## Verification pass 2026-10-16 (fb-595.26.22)

- Render: `sh tools/render.sh …/opening-brief usage/INPUT-opening-brief.md`, exit 0, no typst warnings, 11 pages, EB Garamond Regular/Bold/Italic only (`pdffonts`). The committed PDF before this pass was stale (9 pages); the README's 11 pages was right.
- Pages viewed: 11 of 11 at 60 dpi, before and after the fixes. Exemplar page 1 viewed against our cover. Overlay pages viewed as a 40 dpi contact sheet and page 1 singly.
- Overlay: `sh tools/overlay.sh …/opening-brief synthetic-opening-brief`, exit 0. Pairs cover, TOC and TOA with exemplar pages 1–3 (13–27% overlap); body pages pair with unrelated exemplar pages (9–19%), as expected for a synthetic sample.
- Defects fixed:
  1. **TOA page numbers were physical PDF pages** (Terry "6, 7", Brady "9" for citations on printed pages 3–4 and 6). Tier 1 (1250.8(b)(2)). `toa-entry` now prints the page label from the page counter.
  2. **An uncited authority (CPL 710.60) was listed with no page.** It is removed from the sample, and the template now stops the build when an authority has no `toa:` citation.
  3. **No argued/submitted notation on the cover** (tier 1, 1250.8(a)); added, see Exemplar item 6.
  4. **No email address on the cover** (tier 1, 1250.8(a)); added, see Exemplar item 7.
  5. **Cover spacing.** The cover inherited the body's double leading and paragraph indent, so the counsel lines were indented and, with the notation added, the date spilled to page 2. The cover is now single-spaced with no first-line indent and fits one page.
- Remaining: the gaps above. Not fixed: the signature-block and printing-statement lines are spaced as separate paragraphs (wider than single spacing); page 1 (body) ends half empty because the Statement of Facts heading, its first sub-heading and paragraph are kept together.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `nyappdiv-brief`. |
| `typst/nyappdiv-opening-brief.typ` | Template. Parameter block at the top: `court-lines`, `word-limit` (14,000), `footnotes-allowed` (false), `required-sections`. |
| `usage/INPUT-opening-brief.md` | Markdown contract sample, invented parties and record cites; structure follows the exemplar; labelled SYNTHETIC in its frontmatter. |
| `usage/OUTPUT-opening-brief.typst.pdf` | Render output, 11 pages. |
| `usage/OVERLAY-synthetic-opening-brief.pdf`, `.txt` | Overlay of our render on the exemplar, page map in `.txt`. |
| `usage/FILED-EXAMPLE-opening-brief.pdf` | The filed exemplar (Third Dept). |
| `usage/SOURCE.md` | URL, case, docket, filer, filing date, date fetched, sha256, and what the exemplar shows. |

[Formbook index](../../../../../../README.md) | [Court folder](../README.md)

## Engines

**docx** (`docx/build-reference.sh`, `docx/reference.docx`, `docx/nyappdiv-opening-brief.lua`; output `usage/OUTPUT-<id>.docx`).

- Matches the typst form: letter, 1 in margins, EB Garamond 14 pt body, double-spaced body with a 0.5 in first-line indent, single-spaced headings, block quotations, signature block and printing statement; centered page number in the footer, none on the cover.
- Differs: "double" is Word's double spacing (`w:line="480"`), not the typst leading, so line breaks and page counts differ. Word and LibreOffice also paginate differently from each other.
- Differs: the contents is a TOC field with cached entries and no page numbers; Word or LibreOffice must update fields. The authorities list has no page references (a TOA field needs the same update, and LibreOffice does not honor TA/TOA fields).
- The cover is a centered layout, not the caption table of the typst form. Footnotes are refused by the filter, as the typst template refuses them.
- The word count and the word limit are computed by the filter from the markdown source, not by Word.
- Validated: `tools/render.sh --engine docx` writes the `.docx`; `unzip -tq` and `xmllint --noout` pass on every XML part of the output and of `reference.docx`.

- Not updated in the 2026-10-16 pass: the docx filter does not read the new `argument:` and `email:` fields, so the committed `.docx` has no argued/submitted notation and no cover email. Open item for the docx engine.

BLOCKED (docx engine, not passable on this box):

- **docx.pdf gates (Gates 0 and 1, `tools/check.sh --engine docx`): BLOCKED.** LibreOffice (`soffice`) is not installed on this box, so no `usage/OUTPUT-<id>.docx.pdf` exists and the check cannot run. Stamp `usage/.check-docx.txt` not written.
- **Pages reviewed: 0.** No `.docx` page was rendered or looked at, and the file was not opened in Word or LibreOffice, so no "no repair prompt" result is recorded.
