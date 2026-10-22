# ctb: motion brief (memorandum of law supporting a motion)

Doc type: **motion brief**, a memorandum of law supporting a motion in the United States Bankruptcy Court for the District of Connecticut (`ctb`). The exemplar is a Rule 12(b)(6) memorandum in an adversary proceeding, filed under FRBP 7012 (which incorporates Fed. R. Civ. P. 12); the same layout serves a contested-matter motion under FRBP 9013, with the differences listed under gap 4.
Folder: `courts/second-circuit/connecticut/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (Green & Sklarz LLC and Pillsbury Winthrop Shaw Pittman LLP) and `-2` (Lazare Potter Giacovas & Moyle LLP); see `usage/SOURCE.md` |
| sample md | `usage/INPUT-motion-brief.md` (cover, table of contents and authorities, preliminary statement, facts, legal standard, the first argument heading and paragraphs 10 to 13, conclusion; footnotes omitted) |
| typeface | face required: none by the bankruptcy rules (see "Typeface and size" below). Vendored face: **Times New Roman** (the house face, docs/FONTS.md), the same in the typst and docx engines. The district Arial order is an open question (gap 2 in `../adversary-complaint/README.md`). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` and `usage/OUTPUT-motion-brief.docx.pdf`, 8 pages each (cover, contents and authorities numbered i and ii, 5 body pages numbered 1 to 5), on the cross-engine layout model (fb-595.68.25): every line and page breaks alike (XENG-001..003 PASS, 186/186 lines; `params.cross_engine: gate` in `eval.yaml`) |
| overlay | `just overlay` writes it to the gitignored `.overlay/` (a diagnostic, not committed) |
| pages reviewed | 8 of 8 in both engines (rendered at 50 dpi and viewed on 2026-10-22) |

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

Typeface and size: no rule that governs this court sets a typeface. Local Bankr. R. 5005-1 (effective March 16, 2026) adopts D. Conn. L. Civ. R. 10, which sets no face. The district Electronic Filing Order (revised 1/17/2018, https://ctd.uscourts.gov/sites/default/files/Electronic%20Filing%20Order%2C%20revised%201.17.2018.pdf) names Arial bold 12 point, but it is one judge's order "in this case", not a bankruptcy rule. The template sets Times New Roman, the house face. See `../adversary-complaint/README.md`, gap 2, which is the same question.

## Layout

- Cover (page 1, no number): the court, the caption boxes and the title (single-spaced, bold, centred); the oral-argument legend in the lower margin (the cover's footer line, bold, at the left).
- Front matter (lower roman from i): the table of contents generated from the `#` and `##` headings (level 2 half an inch in; a long title wraps before the page column with its next line hanging; dot leaders), and on a page of its own the table of authorities, grouped by the frontmatter's categories, with the page references the frontmatter gives and dot leaders.
- Body (arabic numerals from 1): double-spaced 12 point (24 pt line pitch); `#` headings centred bold, `##` headings bold and left, on the body pitch with no extra space; numbered paragraphs from 1 (the template numbers; the number at the 0.5 inch indent, the text from 1 inch); lettered sub-items ("a.", "b.") indented 0.5 inch and not numbered; "RESPECTFULLY SUBMITTED," and the signature blocks at the end, one column per firm.
- Footer from page i on: the page number centred and the docket line (Adv. Pro. No. and the judge's initials, 10 pt) at the right, 0.5 inch above the page edge (L. Civ. R. 10).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `title`, `court`, `district`, `division`, `chapter`, `main_case`, `jointly_administered`, `debtors`, `judge`, `adv_number`, `caption.parties`, `date`, `oral_argument` (`requested` or `not requested`), `authorities` (list of `{category, items: [{cite, pages}]}`), `signature.esigners` (list of `{firm, esigner, lines}`).
- Body: blank-line-separated chunks. `#` and `##` headings; a list for numbered items; a chunk starting with a lowercase letter and a period ("a. ") is a lettered sub-item; any other chunk is one numbered paragraph.
- The table of authorities' page references are sample data. They are computed from our render (pdftotext search of each authority's short form in the body pages), not copied from the exemplar. Repeat the computation after any change to the body.
- Not supported: footnotes, tables in the body, raw typst.

## Known gaps and open choices

1. **Exemplars.** Two filers (`usage/SOURCE.md`): exemplar 1 (Green & Sklarz LLC and Pillsbury Winthrop Shaw Pittman LLP, the sample's source) and 2 (Lazare Potter Giacovas & Moyle LLP, the Hamilton memorandum, Adv. Pro. 24-05249, Doc. 86-1); tier 2 is judged against both (see the review below).
2. **25 pages or 40 pages.** Local Bankr. R. 7007-2(a) sets 25 pages (excluding the table of contents and authorities) for a brief in this court. D. Conn. L. Civ. R. 7(a)(5), which Local Bankr. R. 7007-1 applies to adversary motions, sets 40 pages. The bankruptcy rule is the more specific one, so the template uses 25 pages. **Question for David** if the 40-page limit is meant to govern here too. The template does not count pages; the exemplar's body is 17 pages, within either limit.
3. **Page-count check.** No check asserts the 25-page limit. Count the pages after the table of authorities, excluding the cover; the body must stay at or below 25.
4. **Motion versus memorandum.** The exemplar is the memorandum (Doc. 11-1), not the motion (Doc. 11), and it is a Rule 12(b)(6) memorandum under FRBP 7012. A contested matter under FRBP 9013 would also need the notice, proposed order and certificate of service (Local Bankr. R. 9014-1(c)-(d)), and a response or reply would be under Local Bankr. R. 9014-1(e) and (g) with its shorter page limits. None of these is produced here.
5. **Footnotes.** The exemplar has four footnotes (the debtor identification, the defined terms, the list of other adversary proceedings, and the note on other rulings). The markdown contract has no footnote syntax, so the sample omits them. D. Conn. L. Civ. R. 7(a)(5) requires at least 10 point for footnotes; the template has no footnote style yet.
6. **Oral-argument legend.** The exemplar has none. D. Conn. L. Civ. R. 7(a)(1) (applied by Local Bankr. R. 7007-1) calls for one. The sample's value, "requested", is a placeholder chosen for the sample, not a fact of the filing. Counsel chooses.
7. **Table of authorities.** The sample lists only the authorities cited in the transcribed text (§§ 327, 330, 549; FRBP 7010, 7012; FRCP 10(c), 12(b)(6); *Iqbal*, *Twombly*, *Neitzke*, *Howland*). The exemplar's table lists more. The sample's page references are recomputed from our render of the transcribed text.
8. **Two-line headings.** Argument headings may run to two lines (the exemplar's point I does). The heading is kept with the paragraph after it.
9. **Check scripts.** `sh tools/check.sh <this folder> --engine typst|docx` runs the default checks (Gates 0, 1 and 4); both pass (2026-10-22). DEF-LEN-001 is SKIP: no `params.page_limit` (gap 3).

## Review of the rendered pages (typst and docx, 8 pages each)

Every page of `usage/OUTPUT-motion-brief.typst.pdf` and `usage/OUTPUT-motion-brief.docx.pdf` rendered at 50 dpi and viewed on 2026-10-22, after the port to the cross-engine model (fb-595.68.25). The two renders break every line and page alike (`fb diff --engines`: 186/186 lines, 0 of 8 page ends differ; the contents' page numbers 1, 3, 4, 4, 4, 5 in both), so each row holds for both.

| Page | Content | Gate 2 |
|---|---|---|
| 1 (cover) | court, the two caption boxes, the title; "ORAL ARGUMENT REQUESTED" in the lower margin; no page number. | PASS |
| i | TABLE OF CONTENTS, "Page"; five level 1 rows and the point I row (two lines, hanging), dot leaders, pages 1 to 5; footer i and the docket line. | PASS |
| ii | TABLE OF AUTHORITIES, "Page(s)"; statutes, rules, cases (italic case names), dot leaders, "passim". | PASS |
| 1 | the introduction; PRELIMINARY STATEMENT; paragraphs 1 and 2; lettered item a. | PASS |
| 2 | items a. (end), b. and c., indented and not numbered; paragraph 3. | PASS |
| 3 | paragraphs 3 to 5; FACTS PLED IN THE COMPLAINT; paragraphs 6 and 7. | PASS |
| 4 | paragraph 8; APPLICABLE LEGAL STANDARD; paragraph 9; ARGUMENT; the point I heading on two lines; paragraphs 10 and 11. | PASS |
| 5 | paragraphs 11 to 13; CONCLUSION; paragraph 14; "RESPECTFULLY SUBMITTED," and the two firms' blocks side by side (the Pillsbury firm name wraps to two lines in its 3.1 inch column). | PASS |

Tier 2 against the two exemplars (two filers): caption boxes, bold single-spaced title, contents and authorities with dot leaders on roman-numbered pages, centred bold section headings, double-spaced numbered paragraphs, signature blocks with bar numbers. ACCEPTED: the typst contents and authorities stop the leader at the page column, the docx runs it to the number (Word's right tab); the exemplars indent the contents' point labels in a column ("I." then a tab), ours keep the label in the heading text; the docket line repeats in the footer (the template's reading of L. Civ. R. 10). OPEN: the authorities' pages come from the frontmatter, not from the render (gap 7).

## Engines

**docx** (`docx/reference.xml` and `docx/ctb-motion-brief.lua`, built by `fb render`; no shell): output `usage/OUTPUT-motion-brief.docx` and its LibreOffice PDF `usage/OUTPUT-motion-brief.docx.pdf`.

- The styles are the cross-engine recipe (`base="xengine"`) in the typst face (`{font}`: Times New Roman; was EB Garamond in the old `build-reference.sh`, a tier-1 DEF-FONT-002 failure), 12 pt, exact 24 pt body lines (480 twips) and 13.8 pt single lines (276 twips).
- The filter writes the cover, the tables, the headings, the numbered paragraphs, the signature blocks, the three sections and their footers (`$FORMBOOK_FOOTERS`: the cover's legend; the page number with the docket line, which was a header and failed DEF-CONT-001). The contents' page numbers come from `fb render`'s passes: needles for the contents' title, the first body paragraph and each heading with the words after it (a numbered paragraph's number included), looked up in the LibreOffice PDF until they settle (was `render.sh` and `pagemap.awk`).
- XENG-001..003 PASS (8 pages each; 186/186 lines break after the same word); `eval.yaml` gates them.
- Word itself has not been run here; LibreOffice converts the file and `DEF-DOCX-OPEN` passes.
