# ctb: motion brief (memorandum of law supporting a motion)

Doc type: **motion brief**, a memorandum of law supporting a motion in the United States Bankruptcy Court for the District of Connecticut (`ctb`). The exemplar is a Rule 12(b)(6) memorandum in an adversary proceeding, filed under FRBP 7012 (which incorporates Fed. R. Civ. P. 12); the same layout serves a contested-matter motion under FRBP 9013, with the differences listed under gap 4.
Folder: `courts/second-circuit/connecticut/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-ctb-motion-brief-despinspillsbury2405014.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-ctb-motion-brief-pillsburymemorandum.md` (cover, table of contents and authorities, preliminary statement, facts, legal standard, the first argument heading and paragraphs 10 to 13, conclusion; footnotes omitted) |
| typeface | face required: none by the bankruptcy rules (see "Typeface and size" below). Vendored substitute: **EB Garamond** (kept; no court face to substitute). Fit: n/a. The district Arial order is an open question (gap 2 in `../adversary-complaint/README.md`). |
| render | ok: `usage/OUTPUT-ctb-motion-brief-pillsburymemorandum.typst.pdf`, 8 pages (cover, 2 front-matter pages numbered i and ii, 5 body pages numbered 1 to 5), typst 0.15.0, vendored EB Garamond only, no warnings, exit 0 (re-rendered 2026-10-15; `pdffonts` shows only the three EB Garamond faces, all embedded) |
| overlay | ok: `usage/OVERLAY-pillsbury-memorandum.pdf` and `OVERLAY-pillsbury-memorandum.txt` (re-run 2026-10-15 against the saved exemplar) |
| pages reviewed | 8 of 8 (every page rendered at 70 dpi and viewed on 2026-10-15, after the re-render) |

File names follow the repo's convention (`INPUT-` markdown, `OUTPUT-` our render, `OVERLAY-` comparison), because `tools/render.sh` and `tools/overlay.sh` read and write those names.

## Governing rules

Read on 2026-10-14. Bankruptcy local rules: the 2025 revision on the court's site (https://www.ctb.uscourts.gov/sites/ctb/files/Local%20Rules_2021%20Revisions%20with%20Appendices_appdixE-revisions_2025_09_12.pdf). District local rules: the version posted on the district's site (https://www.ctd.uscourts.gov/sites/default/files/Current-Revised-Local-Rules-9.4.26.pdf; Rule 7 amended January 12, 2024; Rule 10 amended November 7, 2016). FRBP text from Cornell LII.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| FRBP 9013(a) (https://www.law.cornell.edu/rules/frbp/rule_9013) | A request for an order must be made by written motion unless an exception applies. | Not checked by the template; the motion is a separate filing (the exemplar's Doc. 11). |
| Local Bankr. R. 9013-1 (2025 PDF) | "Motions for relief ... shall conform to FRBP 9013." | Same as above. |
| Local Bankr. R. 7007-1 (2025 PDF) | Adversary motion practice follows D. Conn. L. Civ. R. 7 and 56. | Sets the oral-argument legend and the 12 point text minimum below. |
| Local Bankr. R. 7007-2(a) (2025 PDF) | A brief shall not exceed 25 pages, excluding the table of contents and table of authorities. A reply shall not exceed 10 pages. | Not enforced by the template. The sample body is 5 pages (an excerpt); the exemplar's body runs 17 pages. A page count check is in gap 3. |
| D. Conn. L. Civ. R. 7(a)(1) (district rules) | A motion involving disputed issues of law is accompanied by a memorandum of law, and the lower margin of the motion says whether oral argument is requested. | `cover()`: "ORAL ARGUMENT REQUESTED" or "ORAL ARGUMENT NOT REQUESTED" in the lower margin of the first page, from the frontmatter field `oral_argument`. |
| D. Conn. L. Civ. R. 7(a)(5) (district rules) | Memoranda double-spaced (except headings, footnotes and block quotes); 40-page limit unless the court orders otherwise; text at least 12 point; footnotes at least 10 point. | Double spacing at 24 pt pitch; 12 point text throughout. The 25-page limit of Local Bankr. R. 7007-2(a) is the bankruptcy rule and is used instead (gap 2). Footnotes are not in the sample (gap 5). |
| D. Conn. L. Civ. R. 7(d) (district rules) | Reply memoranda not more than 10 pages. | Not in the sample. |
| Local Bankr. R. 5005-1 adopting D. Conn. L. Civ. R. 10 (district rules) | Double-spaced; 8½ x 11; margins at least 1 inch; page numbers in the bottom margin after page 1; name, office address, telephone and email under the signature; federal bar number beneath the signature; complete docket number with the judge's initials on each pleading; date in the caption. | `main.typ` page setup (1 inch margins, 24 pt pitch, docket number and judge in the header on every page after the cover, page numbers from page 2 onward); `signature()` (one block per firm, side by side); caption's "Dated" line. |
| FRBP 9004(a)-(b) (https://www.law.cornell.edu/rules/frbp/rule_9004) | (a) clearly legible. (b) caption: court, case title, case and adversary number, designation of the document. | `caption()`; the title line on the cover. |
| FRBP 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010) | Caption substantially conforms to Official Form 416. | `caption()`. |
| Local Bankr. R. 9014-1(e), (g) (contested matters, 2025 PDF) | A response to a contested matter is at most 10 pages; a reply at most 5 pages. | Not applicable to an adversary Rule 12 memorandum; noted for a contested-matter version (gap 4). |

Typeface and size: no rule that governs this court sets a typeface. Local Bankr. R. 5005-1 (effective March 16, 2026) adopts D. Conn. L. Civ. R. 10, which sets no face. The district Electronic Filing Order (revised 1/17/2018, https://ctd.uscourts.gov/sites/default/files/Electronic%20Filing%20Order%2C%20revised%201.17.2018.pdf) names Arial bold 12 point, but it is one judge's order "in this case", not a bankruptcy rule. The template keeps EB Garamond. See `../adversary-complaint/README.md`, gap 2, which is the same question.

## Layout

- Cover (page 1, no number, no header): the caption and title, and the oral-argument legend in the lower margin.
- Front matter (roman numerals, header with the adversary number and judge from page 2): table of contents generated from the headings (`outline`, two levels), and the table of authorities, grouped as statutes, rules and cases, with the page references from the frontmatter.
- Body (arabic numerals from 1): `#` headings centred bold; `##` headings bold and left; numbered paragraphs from 1 (the template numbers); lettered sub-items ("a.", "b.") indented and not numbered; the signature block at the end, one column per firm.
- Headings are typst headings, so the table of contents lists them. The heading text is plain (no markdown in headings) so that the outline entry is one line.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `title`, `court`, `district`, `division`, `chapter`, `main_case`, `jointly_administered`, `debtors`, `judge`, `adv_number`, `caption.parties`, `date`, `oral_argument` (`requested` or `not requested`), `authorities` (list of `{category, items: [{cite, pages}]}`), `signature.esigners` (list of `{firm, esigner, lines}`).
- Body: blank-line-separated chunks. `#` and `##` headings; a list for numbered items; a chunk starting with a lowercase letter and a period ("a. ") is a lettered sub-item; any other chunk is one numbered paragraph.
- The table of authorities' page references are sample data. They are computed from our render (pdftotext search of each authority's short form in the body pages), not copied from the exemplar. Repeat the computation after any change to the body.
- Not supported: footnotes, tables in the body, raw typst.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one filed document per doc type, so tier 2 is not judged against two or three filers. The second candidate is the Hamilton memorandum (Adv. Pro. 24-05249, Doc. 86-1, Michael T. Conway), listed in `usage/SOURCE.md`; it was read but not saved.
2. **25 pages or 40 pages.** Local Bankr. R. 7007-2(a) sets 25 pages (excluding the table of contents and authorities) for a brief in this court. D. Conn. L. Civ. R. 7(a)(5), which Local Bankr. R. 7007-1 applies to adversary motions, sets 40 pages. The bankruptcy rule is the more specific one, so the template uses 25 pages. **Question for David** if the 40-page limit is meant to govern here too. The template does not count pages; the exemplar's body is 17 pages, within either limit.
3. **Page-count check.** No check asserts the 25-page limit. Count the pages after the table of authorities, excluding the cover; the body must stay at or below 25.
4. **Motion versus memorandum.** The exemplar is the memorandum (Doc. 11-1), not the motion (Doc. 11), and it is a Rule 12(b)(6) memorandum under FRBP 7012. A contested matter under FRBP 9013 would also need the notice, proposed order and certificate of service (Local Bankr. R. 9014-1(c)-(d)), and a response or reply would be under Local Bankr. R. 9014-1(e) and (g) with its shorter page limits. None of these is produced here.
5. **Footnotes.** The exemplar has four footnotes (the debtor identification, the defined terms, the list of other adversary proceedings, and the note on other rulings). The markdown contract has no footnote syntax, so the sample omits them. D. Conn. L. Civ. R. 7(a)(5) requires at least 10 point for footnotes; the template has no footnote style yet.
6. **Oral-argument legend.** The exemplar has none. D. Conn. L. Civ. R. 7(a)(1) (applied by Local Bankr. R. 7007-1) calls for one. The sample's value, "requested", is a placeholder chosen for the sample, not a fact of the filing. Counsel chooses.
7. **Table of authorities.** The sample lists only the authorities cited in the transcribed text (§§ 327, 330, 549; FRBP 7010, 7012; FRCP 10(c), 12(b)(6); *Iqbal*, *Twombly*, *Neitzke*, *Howland*). The exemplar's table lists more. The sample's page references are recomputed from our render of the transcribed text.
8. **Two-line headings.** Argument headings may run to two lines (the exemplar's point I does). The heading is kept with the paragraph after it.
9. **Check scripts.** As in `../adversary-complaint/README.md` (gap 9): `tools/check.sh` expects `court.json` and `rules.md`, which this doc-type folder does not have, and `tools/` is out of scope for this box. The gates were not run.
10. **Table of contents weight.** The outline entries come out bold, because typst repeats the heading's show rule in the outline. The exemplar's entries are regular weight. A cosmetic difference, not a rule point; fixing it needs an outline entry show rule in `main.typ`.

## Review of the rendered pages (`usage/OUTPUT-ctb-motion-brief-pillsburymemorandum.typst.pdf`, 8 pages)

Re-viewed 2026-10-15 at 70 dpi after the re-render (no template change; same EB Garamond layout, same 8 pages). Findings below stand.

- Page 1 (cover, no number): caption; title centred; the legend "ORAL ARGUMENT REQUESTED" in the lower margin. No header or number. Pass.
- Page i (table of contents): header with the adversary number and judge; "TABLE OF CONTENTS"; the two-level entries with dot leaders and page numbers, the argument sub-heading on two lines; the "Page" label. Entries are bold (gap 10). Pass.
- Page ii (table of authorities): statutes, rules and cases with the page references in a right column; "passim" for § 549. Pass.
- Page 1 of the body: the introduction paragraph, "PRELIMINARY STATEMENT" centred bold, paragraphs 1 and 2 with lettered item a. Pass.
- Page 2 of the body: items b. and c. (indented, not numbered), paragraph 3. Pass.
- Page 3 of the body: paragraphs 4 to 5, "FACTS PLED IN THE COMPLAINT" centred bold, paragraphs 6 to 8. Pass.
- Page 4 of the body: "APPLICABLE LEGAL STANDARD" and paragraph 9; "ARGUMENT"; the point I heading on two lines; paragraphs 10 to 12. Pass.
- Page 5 of the body: paragraph 13, "CONCLUSION", paragraph 14, "RESPECTFULLY SUBMITTED," and the two signature blocks (Green & Sklarz LLC; Pillsbury Winthrop Shaw Pittman LLP), each with its `/s/` line, names with bar numbers, email addresses. The firm name of the second block wraps to two lines. Pass, with the wrap noted.

Overlay: pages pair with the exemplar's pages 1, 2, 5, 6, 8, 10, 12 and 22 by shared words (word overlap 14% to 88%). Page 3 of our render (the table of authorities) pairs poorly (14.5%) because the exemplar's page 5 is body text. The overlay is a diagnostic, not a score.

## Engines

**docx** (`docx/`: `reference.docx`, `build-reference.sh`, `ctb-motion-brief.lua`, `render.sh`, `pagemap.awk`; output `usage/OUTPUT-ctb-motion-brief-pillsburymemorandum.docx` and `usage/OUTPUT-ctb-motion-brief-pillsburymemorandum.docx.pdf`, the LibreOffice conversion):

- Matches the typst output: letter, 1 inch margins; EB Garamond 12 point (embedded, only EB Garamond in `pdffonts`); double spacing at 24 pt; caption box; title; the cover's footer carries "ORAL ARGUMENT REQUESTED" in the lower margin; three sections as in typst (cover without number; table of contents and authorities in lower roman; body from 1); the docket line and page number from page 2 on; numbered paragraphs from the first heading, with lettered items at 0.5 inch and not numbered; centred `#` and bold left `##` headings; the signature blocks side by side.
- The table of contents page numbers come from a first pass (`render.sh` converts it, finds each heading's page in the PDF text, and checks the second pass gives the same map). The table of authorities uses the frontmatter pages, as typst does.
- Differs (tier 2, accepted): no blank line between body paragraphs (typst leaves about 16 pt); the table of contents entries are regular weight (typst's are bold); the authorities have no leader dots; the body runs one page longer (6 pages against typst's 5), because the header takes more of the top margin and the signature block moves to its own page. Pages 4 to 9 of the docx PDF are body and signature, and the total is 9 pages against typst's 8.
- Word has not been run here. The `.docx` was checked only by LibreOffice (converts without error; every XML part well-formed).
- BLOCKED: `tools/check.sh` (Gates 0 to 3, every check ID): cannot run on this doc-type folder. It reads `court.json` and `checks.yaml` at the court level (`courts/second-circuit/connecticut/federal/bankruptcy-district/`), and this box does not produce those files. No `usage/.check-docx.txt` was written.
- Pages reviewed: all 9 pages of `OUTPUT-ctb-motion-brief-pillsburymemorandum.docx.pdf` were rendered at 60 dpi and viewed, and compared with all 8 pages of the typst render.
