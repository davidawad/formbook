# Fourth Department (nyappdiv): brief for the appellant (opening brief)

- Court: `nyappdiv`, Supreme Court of the State of New York, Appellate Division, Fourth Judicial Department (`courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/`)
- Doc type: `opening-brief`. The appellant's brief (22 NYCRR 1250.8(b)). One self-contained folder, no shared files.
- Status: template built, rendered, every page reviewed. **BLOCKED: no exemplar.** No filed Fourth Department opening brief was found (see "Exemplar"), so the sample is synthetic and the overlay cannot run.
- `court.json` and the court-root `typst/` and `samples/` are untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `nyappdiv-brief`. |
| `typst/nyappdiv-opening-brief.typ` | Template. Parameter block at the top: `court-lines`, `word-limit` (14,000), `footnotes-allowed` (false), `required-sections`. |
| `samples/INPUT-synthetic-opening-brief.md` | Markdown contract sample, invented parties and record cites, real authorities. Labelled SYNTHETIC in its frontmatter. |
| `samples/OUTPUT-synthetic-opening-brief.pdf` | `sh tools/render.sh courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/opening-brief samples/INPUT-synthetic-opening-brief.md` (9 pages, EB Garamond only). |
| `samples/synthetic-opening-brief-overlay.pdf`, `-overlay.txt` | Not produced: `tools/overlay.sh` exits 1 with "no exemplar pdf in .../exemplars" (see below). |
| `exemplars/SOURCE.md` | The search log. There is no exemplar PDF. |

## Exemplar

**No exemplar found, so this doc type is BLOCKED: no exemplar.** Searches tried on 2026-10-14:

1. WebSearch (standard): Fourth Department "brief for defendant-appellant" with public-defender terms (Erie, Monroe, Onondaga). Returned decisions and calendars only.
2. WebSearch (standard): "brief for plaintiff-appellant" / "appellant's brief" with "table of authorities" and "preliminary statement". Returned the Part 1000 rules, a blank form, and a Fourth Department decision list.
3. WebSearch (standard): courtlistener nyappdiv brief appellant pdf. Returned A.D.2d/A.D.3d citation indexes and motion orders that mention briefs without containing them.
4. WebSearch (extended): "Fourth Department" brief with "Point I", "Statement of the Case" and "Preliminary Statement", 2024-2025. Returned a 2026 decision listing public defenders as counsel, and the NYLJ/Duane Morris article. No brief.
5. WebFetch of the NYLS digital commons (`digitalcommons.nyls.edu/maynard_briefs/2`): a 1971 First Department brief, outside this court and period.
6. CourtListener: its RECAP archive covers federal dockets; state appellate briefs were not in the results.

The Fourth Department's own pages (nycourts.gov, including the Part 1000 PDF) returned HTTP 403 to both the browser fetch and curl from this box, so the court's website could not be searched for filed briefs. Next step: a filed Fourth Department opening brief from a public-defender or appellate counsel, or the NYSCEF public docket of a closed appeal. Save it as `exemplars/FILED-EXAMPLE-<case>-<docket>-opening-brief.pdf` and transcribe it into the sample.

## Governing rules

Primary sources were not reachable (see the 403 note above). Each rule below was read from a mirror of the official text, or from a secondary source, on 2026-10-14. The "Source" column says which.

| Rule | Requirement | Used by | Source, verified |
|---|---|---|---|
| CPLR 5529(a) | Briefs on white paper, 11 inches along the bound edge by 8½ inches; black image; margins, type, line spacing and length are set by each appellate court's rules (5529(a)(3)). | `page` (letter, 1-inch margins), delegation noted | Statute text: jdbar.com/statutes/cplr-5529/ (mirror; nycourts.gov 403). |
| 22 NYCRR 1250.8(b) | Appellant's brief, in order: (1) table of contents, with point headings; (2) table of cases, statutes and other authorities; (3) statement of the questions involved, not exceeding two pages, each followed by the answer; (4) statement of the nature of the case and facts; (5) argument, divided into points with distinctive headings; (6) printing-requirements certification on the court's form. | `required-sections`, TOC and TOA order, printing statement | Cornell LII, law.cornell.edu/regulations/new-york/22-NYCRR-1250.8 (current text; mirror). Page limit for 1250.8(b)(3) not checked by the template. |
| 22 NYCRR 1250.8(f)(2) | Computer-generated appellant's brief: not more than 14,000 words, inclusive of point headings and footnotes; excludes signature blocks, the tables, the proof of service, the certificate, and any addendum. | `word-limit` = 14000; `count-words` counts the markdown body, headings included | Cornell LII, as above. |
| 22 NYCRR 1250.8(g)(2) | Typewritten appellant's brief: not more than 50 pages (tables, proof of service and certificate excluded). | Not checked; the template counts words, not pages. | Cornell LII. |
| 22 NYCRR 1250.8(j) | Printing specifications statement at the end of the brief (except handwritten): for a computer-generated brief, the typeface name, point size, line spacing and word count; signing under 22 NYCRR 130-1.1-a(a) also represents its accuracy. | Last page: `Printing Specifications Statement`, generated with the typeface, size, spacing and count | Cornell LII, as above. |
| 22 NYCRR Part 1000, §1000.8(a) (Fourth Dept local rules) | Hard-copy cover of an appellant's brief is blue; covers of electronically filed briefs are coloured "to the extent practicable". | Not produced; see Known gaps. | jdbar.com/statutes/22-nycrr-1000/ (mirror of the Part 1000 text; the nycourts.gov PDF returned 403). |
| Part 1000, "no footnotes" | "A brief shall contain no footnotes." | `footnotes-allowed = false`: a footnote panics the build (mutation-tested: a footnote fails the render). | **Secondary only.** Duane Morris article (Newman and Ahmuty, NYLJ, 2012), and a vLex excerpt of the same article; the search snippet of Part 1000 also quoted it. Not confirmed in the current primary text. |
| Part 1000 / NYLJ, "all words no less than 11 point" | Minimum 11-point type in the Fourth Department. | `type-size = 14pt`, above the minimum. | **Secondary only**, and from 2012. The First and Second Departments' 14-point proportional minimum is noted but does not apply here. |

Not found in any source: a Fourth Department double-spacing rule, a margin rule, a typeface rule, and a cover-content rule. The template uses double spacing, 1-inch margins, and a cover modelled on NY convention (court name, docket number, caption, proceeding, title, counsel). These are conventions, marked as such in the template, and are the first things to check against the primary text.

## Overlay

`tools/overlay.sh courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/opening-brief synthetic-opening-brief` exits 1: `no exemplar pdf in .../exemplars`. Result: **overlay=fail (no exemplar)**. Nothing was paired, so there is no overlay PDF.

## Page review (Gate 2)

Every page of `samples/OUTPUT-synthetic-opening-brief.pdf` was rendered at 60 dpi (`pdftoppm -r 60`) and viewed (9 of 9). Typst printed no warnings. Fonts embedded: EB Garamond (Regular, Italic, Bold) only.

| Page | Content | Result |
|---|---|---|
| 1 | Cover: docket top right, court, caption, Ind. No., proceeding, title, counsel block, date | OK. Fits one page. The proceeding line wraps and leaves "2026" alone on its own line: ACCEPTED (cosmetic, from the sample's wording). |
| 2 | Table of contents | OK. Point labels are on one line; page numbers align. Long point titles can wrap, and the page number can move to a new line (see Known gaps). |
| 3 | Table of authorities (cases, statutes) | OK. Pages from the `toa:` links match the body (checked against the TOC on pp. 4-8). |
| 4 | Statement of questions involved; statement of the case A-B | OK. |
| 5 | Statement of the case C; Argument, POINT I heading | OK. |
| 6 | Point I A-B; POINT II heading | OK. |
| 7 | Point II A-B; POINT III heading | OK. |
| 8 | Point III A-B; conclusion; signature block | OK. |
| 9 | Printing specifications statement; signature | OK. The statement's paragraphs are separated; the signature block is not indented. |

Tier-2 findings (OPEN or ACCEPTED): the cover proceeding wraps to an orphan "2026" (ACCEPTED, sample wording). The first paragraph after a heading is not indented, while later paragraphs are (ACCEPTED, convention). No page is left with an unexplained blank area.

## Known gaps

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
