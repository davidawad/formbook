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
| `samples/OUTPUT-synthetic-opening-brief.pdf` | `sh tools/render.sh courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/opening-brief samples/INPUT-synthetic-opening-brief.md` (10 pages, EB Garamond only; re-rendered 2026-10-15 after the template fixes in "Page review"). |
| `samples/synthetic-opening-brief-overlay.pdf`, `-overlay.txt` | Not produced: `tools/overlay.sh` exits 1 with "no exemplar pdf in .../exemplars" (see below). |
| `exemplars/SOURCE.md` | The search log. There is no exemplar PDF. |

## Exemplar

**No exemplar found, so this doc type is BLOCKED: no exemplar.** Searches tried on 2026-10-14 (items 1-6) and 2026-10-15 (items 7-10):

1. WebSearch (standard): Fourth Department "brief for defendant-appellant" with public-defender terms (Erie, Monroe, Onondaga). Returned decisions and calendars only.
2. WebSearch (standard): "brief for plaintiff-appellant" / "appellant's brief" with "table of authorities" and "preliminary statement". Returned the Part 1000 rules, a blank form, and a Fourth Department decision list.
3. WebSearch (standard): courtlistener nyappdiv brief appellant pdf. Returned A.D.2d/A.D.3d citation indexes and motion orders that mention briefs without containing them.
4. WebSearch (extended): "Fourth Department" brief with "Point I", "Statement of the Case" and "Preliminary Statement", 2024-2025. Returned a 2026 decision listing public defenders as counsel, and the NYLJ/Duane Morris article. No brief.
5. WebFetch of the NYLS digital commons (`digitalcommons.nyls.edu/maynard_briefs/2`): a 1971 First Department brief, outside this court and period.
6. CourtListener: its RECAP archive covers federal dockets; state appellate briefs were not in the results.

The Fourth Department's own pages (nycourts.gov, including the Part 1000 PDF) returned HTTP 403 to both the browser fetch and curl from this box, so the court's website could not be searched for filed briefs.

Second search, 2026-10-15 (after the first pass found nothing). Nothing below is a Fourth Department opening brief:

7. WebSearch (standard) x3: "Fourth Department" with "brief for defendant-appellant", the Fourth Judicial Department caption line with "brief for defendant-appellant", and "brief for plaintiff-appellant" with Monroe, Erie, Onondaga and Oneida. Returned Fourth Department decisions and motion orders (including an order allowing a corrected brief in *Lavine v. State of New York*, 2024), and counsel listings, not briefs.
8. WebSearch (standard) x2 and (extended) x2: writing-sample, digital-commons, law-school-clinic and Center for Appellate Litigation / Legal Aid Bureau of Buffalo / Monroe County Public Defender phrasings. Returned the Buffalo CLE materials on Fourth Department rules, a law-firm article on Fourth Department appeals (`hselaw.com`, 8 pages, checked: no brief in it), Brooklyn and Columbia clinic pages, and out-of-state briefs.
9. CourtListener REST search, type RECAP (`type=r`), for "Fourth Department" with "Brief for Defendant-Appellant": 20 hits, all federal dockets (habeas petitions in `nywd`, `nynd`, `nysd`, `nyed`, and Second Circuit filings). The one state brief attachment found, *Harrell v. Miller* (`nysd` 1:21-cv-06714), is an appendix to a First Department habeas petition (county of conviction: New York), so it is outside this court. CourtListener's opinion search found nothing in `nyappdiv` for the same phrase.
10. Reachability: `iapps.courts.state.ny.us/nyscef` (NYSCEF) and `nycourts.gov/courts/ad4/library/recordsbriefs.html` (Fourth Department Records & Briefs) both returned HTTP 403 (Cloudflare challenge) to curl from this box. The Records & Briefs page says the Fourth Department library holds briefs only in print and microfiche, so a PDF is unlikely to be public there either.

Next step: a filed Fourth Department opening brief from a public-defender or appellate counsel who will share one, or a NYSCEF public copy of a closed appeal (KA/CA docket number), fetched from a box that can reach NYSCEF. Save it as `exemplars/FILED-EXAMPLE-<case>-<docket>-opening-brief.pdf` and transcribe it into the sample.

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

Reviewed 2026-10-15 on the current `samples/OUTPUT-synthetic-opening-brief.pdf` (10 pages). Every page was rendered with `pdftoppm -r 70 -png` and viewed (10 of 10). Typst printed no warnings. Fonts embedded: EB Garamond (Regular, Italic, Bold) only.

Two template fixes came out of the first review of the 9-page render, and the render was then re-reviewed in full:

- `single-leading` went from 0.25em to 0.65em (Typst's default leading). Two-line point headings had their second line crowding the line above.
- The conclusion and the signature block are one unbreakable block. Before this, the old render's page 9 held only `Respectfully submitted` and the signature, with no text above it.

| Page | Content | Result |
|---|---|---|
| 1 | Cover: docket top right, court, caption, Ind. No., proceeding, title, counsel block, date | OK. The proceeding line wraps and leaves "2026" alone on its own line: ACCEPTED (cosmetic, from the sample's wording). |
| 2 | Table of contents | OPEN. The `POINT I` row has no leader dots before its page number ("...Founded Suspicion ." with a stray dot), and the `POINT III` title wraps so "Relief" and its page number start a new line (known gap 12). The page numbers themselves match the headings. |
| 3 | Table of authorities (cases, statutes) | OK. Page numbers match the body: Brady 8, Strickland 7, De Bour 6, Terry 6, CPL 470.15(6)(a) 8, CPL 710.60 4. |
| 4 | Statement of questions involved; statement of the case A-B | OK. |
| 5 | Statement of the case C; Argument, POINT I heading | OK. Two-line point heading now leads correctly. |
| 6 | Point I A-B | OK. |
| 7 | POINT II heading; Point II A-B | OK. |
| 8 | POINT III heading; Point III A-B | OK. Half-page white space at the foot, because the conclusion moved to p. 9 with the signature. |
| 9 | Conclusion; signature block | OK. The conclusion and the signature sit together. |
| 10 | Printing specifications statement; signature | OK. |

Tier-2 findings (OPEN or ACCEPTED): the TOC `POINT I` leader is OPEN (table row above, page 2). The TOC `POINT III` wrap is OPEN in the same way as known gap 12. The cover proceeding wraps to an orphan "2026" (ACCEPTED, sample wording). The first paragraph after a heading is not indented, while later paragraphs are (ACCEPTED, convention). Page 8 ends with white space, because the conclusion block is kept with the signature (ACCEPTED).

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
