# arwd: complaint

Doc type: **complaint** in the United States District Court for the Western District of Arkansas (`arwd`).
Folder: `courts/eighth-circuit/arkansas/federal/western-district/complaint/` (self-contained; the court-root `typst/` and `samples/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-little-5-26-cv-05256-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-little-complaint.md` (the whole 10-page filing, transcribed; paragraph numbers are the template's) |
| typeface | face required: **none**. LR 5.5(a) says "type not less than elite" and names no face (searched the consolidated local rules, 66 pp., 2026-10-14). Vendored substitute: **not needed**; kept **EB Garamond** (`fonts/eb-garamond/`), as the fonts policy allows for a court that names no face. Metric class: n/a. The filed exemplar is Times New Roman with Century Schoolbook headings (tier 2, not chased; see gap 1). |
| render | ok (re-rendered 2026-10-14): `samples/OUTPUT-little-complaint.pdf`, 9 pages, typst 0.15.0, `--ignore-system-fonts`, no warnings; `pdffonts`: EBGaramond Regular/Bold/Italic only |
| overlay | ok (regenerated 2026-10-14): `samples/OVERLAY-little-complaint.pdf` and `OVERLAY-little-complaint.txt`, against the filed exemplar re-fetched from the URL in `exemplars/SOURCE.md` (the PDF is not committed in this tree; see gap 10) |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed on 2026-10-14) |

File names follow the repo's roles (`INPUT-`, `OUTPUT-`, `OVERLAY-`) because `tools/render.sh` and `tools/overlay.sh` read and write those names.

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Civ. P. 8(a) | Short and plain statement of the grounds for jurisdiction, of the claim, and a demand for the relief sought. Fetched from https://www.law.cornell.edu/rules/frcp/rule_8 on 2026-10-14. | Author content. The template does not check the wording. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and the Rule 7(a) designation. Fetched from https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14. | `court` and `division` lines, `caption` (with `case_number`), `title` (the Rule 7(a) designation "COMPLAINT"). |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Each body paragraph is numbered by the template; headings, lists and `^ ` paragraphs are not. |
| W.D./E.D. Ark. Local Rule 5.5(a) | Pleadings typewritten or printed "in type not less than elite, in double space, letter size, using only one side of the page", unfolded, no manuscript covers; case number on every paper. Source: consolidated "Local Rules of the United States District Court for the Eastern and Western Districts of Arkansas", https://www.arwd.uscourts.gov/sites/arwd/files/ARWD%20Local%20Rules.pdf (PDF dated 2019-12-04; the rule text is the same as the individual LR 5.5 PDF at https://www.arwd.uscourts.gov/sites/arwd/files/5.5.pdf, dated 2014). Read 2026-10-14. | `page` (US letter), `text` 12 pt, `body-leading` (double space, 27.6 pt pitch), one-sided. |
| LR 5.5(c)(1) | Signature of at least one attorney of record in his or her individual name, with address, zip code, telephone number and Arkansas Supreme Court identification number "or other Supreme Court identification number, if applicable". | `signature` (`firm`, `signer`, `lines`). The ID is an author-supplied line; the template does not enforce it. |
| LR 5.5(d) | Civil cover sheet, Federal Form JS-44, submitted at the time of filing. | Not generated: a separate filing (see gaps). |
| LR 5.1 | Counsel must file electronically; case-initiating documents (complaints) are the usual exception. | Not a template matter. Recorded for the filer. |
| LR 23.1 | A class action complaint carries the caption "Complaint - Class Action" and a "Class Action Allegations" paragraph. | Not implemented (see gaps). |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44), the Rule 7.1 disclosure statement (a corporate party; in a diversity case, the citizenship disclosure of Rule 7.1(a)(2)), the summons, and the ECF header that the court's system adds to each page. The Little exemplar carries that ECF header; the render does not, so the overlay shows it in blue.

## Layout

- US letter, 1-inch margins on all four sides (the exemplar's margins measured with `pdftotext -bbox`: 72 pt left and right, first line at 72 pt).
- No pleading paper and no line numbers: LR 5.5 does not call for them, and the exemplar has none.
- Double spacing: 12 pt EB Garamond, baseline pitch 27.6 pt (`pitch` = 0.65 em line + `body-leading` 1.65 em). The exemplar's pitch is 28.9 pt; this is a tier-2 difference, not a rule.
- Court title single-spaced and centered (one line per `court` entry, then `division`). Caption: party names on the left with the designation right-aligned on the first name line; "v." and `CASE NO. ...` share the row between the parties.
- Title centered and bold, in capitals. A `subtitle` line is optional.
- Headings: level 1 centered bold capitals; level 2 centered bold as typed; level 3 bold, left. A heading is set off by one blank double-spaced line above and below and is kept with the paragraph after it.
- Paragraphs: first-line indent 0.5 in, number at the indent, text after a 0.3 in gap; consecutive lines one pitch apart. Lists (markdown `1.` items) are lettered `(a)`-style by the template: the sample's `1.` items render as `a.`, `b.`, ... as in the exemplar's prayer.
- Unnumbered paragraph: a chunk beginning with `^ ` (the exemplar's WHEREFORE clauses) is indented like a numbered one but not counted.
- Signature block: "Dated:" on the left; the firm, then `/s/ Signer` and the signer's lines on the right, single spaced.
- Footer: centered page number (the exemplar's footer is the ECF header plus the number; the template prints only the number).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `case_number` (string); `court` (list of lines, upper-cased by the template); `division` (optional string); `caption.parties` (list of `{names: [...], designation: "..."}`; exactly two parties, "v." and `CASE NO.` are placed between them); `title`; `subtitle` (optional); `lead_in` (optional, unnumbered paragraph under the title); `date`; `signature` (`firm`: list of lines, optional; `signer`: name, printed as `/s/ Name` and again as the first signature line; `lines`: the lines under the name).
- Body: blank-line-separated chunks. `#` = level 1, `##` = level 2, `###` = level 3 headings (type the heading text in the case the filing uses; level 1 is capitalised by the template). A chunk that is a single line of plain text is a numbered paragraph (do NOT type the number). A chunk that begins `^ ` is unnumbered. A chunk of markdown list items (`1.` ... consecutive lines) is a lettered list. Italics `*...*` for case names and bracketed notes.
- Not supported: tables, footnotes (none in the exemplar), raw typst, pleading-paper line numbers.

## What the overlay shows

`samples/OVERLAY-little-complaint.pdf`: red = our render, blue = the filed exemplar, black = both. Pages are paired by word overlap (`OVERLAY-little-complaint.txt`): ours 1-3 ↔ filed 1-3 (84 %, 74 %, 91 %), ours 4 ↔ filed 5 (89 %), ours 5-9 ↔ filed 6-10 (62 % to 91 %). The exemplar is on a 28.9-pt pitch with an ECF header; our render is on 27.6 pt with no header, so text lines do not coincide and the blue ECF header never matches. The overlay is a diagnostic, not a score.


## Gate 2: visual review (every page rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title (three lines), caption with "v." and `CASE NO.`, COMPLAINT, lead-in, heading NATURE OF THE CASE, paragraphs 1-3 | OK. Court title lines no longer overlap (the first render stacked the division line over the court line; fixed by one stack). |
| 2 | Paragraphs 3-8, heading PLAINTIFF JOHN DAVID LITTLE | OK. Blank line above and below headings. |
| 3 | Paragraphs 9-13, JURISDICTION AND VENUE | OK. |
| 4 | FACTUAL ALLEGATIONS, paragraphs 14-19 | OK. Bracketed screenshot note in italics. |
| 5 | Paragraph 20, CLAIMS FOR RELIEF, COUNT I heading, paragraphs 21-27 | OK. Stacked headings COUNT I / STRICT LIABILITY one line apart. |
| 6 | Count I items (a)-(f), paragraph 28, WHEREFORE (unnumbered) | OK. |
| 7 | COUNT II, paragraphs 29-33, items (a)-(e) | OK. |
| 8 | Paragraph 34, WHEREFORE, INJURIES & DAMAGES, paragraphs 35-37 | OK. |
| 9 | PRAYER FOR RELIEF, items (a)-(e), Dated line, signature block | OK. The signature block carries no Arkansas ID line, as in the exemplar (pro hac vice counsel). |

Bugs found and fixed during review (kept here so the next change does not reintroduce them): (1) numbered paragraphs were typed as markdown `1.` items and rendered as lettered lists, so the sample now types no numbers; (2) block boundaries added no vertical gap, so each paragraph's first line sat on the last line of the one before; the template now sets every gap explicitly (`pitch` and the leading); (3) the court title lines were not spaced like the division line.

## Known gaps and open choices

1. **Font and "elite".** LR 5.5(a) says "type not less than elite" and names no typeface, so the fonts policy (`docs/FONTS.md`) keeps EB Garamond here; no substitute is substituted. Elite is a 12-characters-per-inch typewriter pitch; for a proportional face the usual reading is a 12-point type size. The template uses EB Garamond at 12 pt. EB Garamond sets smaller than Times New Roman at the same size; the filed exemplar is Times New Roman (body) with Century Schoolbook (headings). Choosing Liberation Serif or TeX Gyre Schola would be a tier-2 convention choice, not a rule requirement, so it is not made here. **Needs David's call** if the clerk reads "elite" as a pitch limit for proportional type, or if the court wants the exemplar's faces.
2. **One exemplar.** Tier 2 asks for 2 or 3 filers; only Little v. Church & Dwight is saved. Other complaints found (Sullivan v. Goodyear, Kiefer Sage v. Pro-Gard, Saeidi) are listed in `exemplars/SOURCE.md`. Tier 2 is therefore judged against one filer.
3. **Class actions.** LR 23.1 requires the caption legend "Complaint - Class Action" and a "Class Action Allegations" paragraph. Not implemented: no `legend` field exists yet. Add it to the template before using it for a class complaint.
4. **Jury demand.** The exemplar demands a jury inside the prayer (item d). The template adds no separate jury-demand caption line. Fed. R. Civ. P. 38(b) requires only a demand in a pleading, which the prayer provides; no W.D. Ark. local rule was found that sets a separate form (LR 5.5 and the consolidated rules were read).
5. **Counsel block at the top of page 1.** The exemplar has none (the Arkansas form does not call for one); the template has none.
6. **Margins and footer.** 1-inch margins and a centered page number are conventions, not rules; the LR 5.5 text sets no margin. Footer text is the page number only; the exemplar's ECF header is not reproduced.
7. **Exemplar typos transcribed as printed**: "FAYETTEVILLE DIVISON" and "distribute and cleaner" (paragraphs 3 and 17), and a missing final period in paragraph 12. The sample keeps them so the overlay compares like with like.
8. **Not checked by the template**: the 14-day deadline (LR 7.2(b)) and the rules on separate filings. The template produces the complaint only.
9. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` at the court root; this doc-type folder is not that shape, and the brief forbids editing `tools/`. The Gate 2 table above is the review for this doc type.
10. **Exemplar PDF not in the tree.** `exemplars/SOURCE.md` records the CourtListener URL, but the `FILED-EXAMPLE-*.pdf` file was never committed (the exemplar row above said it was). On 2026-10-14 it was re-fetched from that URL into a scratch directory (`/work/artifacts/arwd-exemplars/`), not the repo, and used for the overlay. Commit it to `exemplars/` if the repo is to rebuild the overlay offline.
