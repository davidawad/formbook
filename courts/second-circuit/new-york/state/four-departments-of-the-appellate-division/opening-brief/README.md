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
1. **No exemplar** (BLOCKED). The sample is synthetic. The overlay cannot run, and no page has been compared with a filed brief.
2. **Footnotes** are refused by the template. The rule comes from a 2012 secondary source; confirm it against the current Part 1000 before relying on it.
3. **Type size** is 14 pt, chosen above the 11-point minimum in the secondary source, because the template should not guess a smaller size. Confirm the current minimum; the printing statement reports the size used.
4. **Line spacing** (double), **margins** (1 inch) and the **cover layout** are conventions. No primary-source Fourth Department rule was found for them.
5. **Cover colour** (blue, §1000.8(a)) is not produced. The hard-copy rule applies to paper; the e-filed rule says "to the extent practicable", which is not settled here.
6. **Form of the printing statement.** §1250.8(b)(6) requires a certification "on a form approved by the court". That form was not obtained. The template's statement carries the §1250.8(j) content and is a stand-in until the approved form is checked.
7. **Word count** is the markdown body, headings included, computed by `count-words` (1,267 words for the sample). It is not cross-checked against the PDF text in this box. The 14,000-word limit is checked as a hard stop.
8. **Statement of questions**: the two-page limit (§1250.8(b)(3)) is not checked.
9. **Page limit** (§1250.8(g)(2), 50 pages typewritten) is not checked; only words are.
10. **Certificate of service** is not generated. Add a proof-of-service block if the filer needs one.
11. **TOA tracking** records the page where each `toa:` link starts. A citation that starts at the top of a page and continues is still listed on its starting page. Every citation to be listed must be a link, and the template does not detect citations.
12. **TOC long titles**: a point title that fills its last line can push the page number onto a new line. Shorter titles avoid it; the template does not wrap around the number.
13. **Font**: no face is named by the rule. 22 NYCRR 1250.8(f)(1) requires "a serifed, proportionally spaced typeface such as Times Roman" (or a serifed monospaced face such as Courier); "such as" is an example, so EB Garamond is kept, as the template's `font-family` sets. Typeface row: face required none named; substitute none; fit n/a. Checked 2026-10-15 against the LII copy. No system font is used.
14. **Fourth Department e-filing** (22 NYCRR Part 1245) was not checked.

## Engines

**docx** (`docx/build-reference.sh`, `docx/reference.docx`, `docx/nyappdiv-opening-brief.lua`; output `samples/OUTPUT-<id>.docx`).

- Matches the typst form: letter, 1 in margins, EB Garamond 14 pt body, double-spaced body with a 0.5 in first-line indent, single-spaced headings, block quotations, signature block and printing statement; centered page number in the footer, none on the cover.
- Differs: "double" is Word's double spacing (`w:line="480"`), not the typst leading, so line breaks and page counts differ. Word and LibreOffice also paginate differently from each other.
- Differs: the contents is a TOC field with cached entries and no page numbers; Word or LibreOffice must update fields. The authorities list has no page references (a TOA field needs the same update, and LibreOffice does not honor TA/TOA fields).
- The cover is a centered layout, not the caption table of the typst form. Footnotes are refused by the filter, as the typst template refuses them.
- The word count and the word limit are computed by the filter from the markdown source, not by Word.
- Validated: `tools/render.sh --engine docx` writes the `.docx`; `unzip -tq` and `xmllint --noout` pass on every XML part of the output and of `reference.docx`.

BLOCKED (docx engine, not passable on this box):

- **docx.pdf gates (Gates 0 and 1, `tools/check.sh --engine docx`): BLOCKED.** LibreOffice (`soffice`) is not installed on this box, so no `samples/OUTPUT-<id>.docx.pdf` exists and the check cannot run. Stamp `samples/.check-docx.txt` not written.
- **Pages reviewed: 0.** No `.docx` page was rendered or looked at, and the file was not opened in Word or LibreOffice, so no "no repair prompt" result is recorded.
