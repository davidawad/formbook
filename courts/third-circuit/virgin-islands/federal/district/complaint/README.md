# vid: complaint

Doc type: **complaint** in the District Court of the Virgin Islands (`vid`, Division of St. Thomas and St. John, and the other divisions by frontmatter). Folder: `courts/third-circuit/virgin-islands/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (a partial transcription: see Known gaps 6) |
| typeface | none required by the rules (VI-FONT-001): **Times New Roman** 12 pt (vendored, docs/FONTS.md), the exemplar's face and the house standard, in every engine (`fb lint fonts` does not report the folder) |
| render | ok (2026-10-22): `usage/OUTPUT-complaint.typst.pdf`, 12 pages, and `usage/OUTPUT-complaint.docx` with its LibreOffice PDF, 12 pages; `fb render`, vendored fonts only, no warnings |
| overlay | `just overlay` writes `.overlay/<doc path>/OVERLAY-complaint.pdf` (not committed); a diagnostic, not a score |
| pages reviewed | 12 of 12, both engines, side by side at 50 dpi (2026-10-22, the renders of fb-595.68.35) |

## Governing rules

Court: District Court of the Virgin Islands. The rules below are the local rules of civil procedure (LRCi) and the Federal Rules of Civil Procedure. The LRCi text has two sources, and they do not agree on every point.

| ID | Rule | Requirement | Source (fetched 2026-10-14) | Where it lives |
|---|---|---|---|---|
| VI-FORM-001 | LRCi 5.1(a) | All papers double-spaced except quoted material; each page numbered consecutively; 8½ × 11-inch white paper. | VID LRCi PDF, https://www.vid.uscourts.gov/sites/vid/files/local_rules/VID_LRCi_042911.pdf (a July 2011 compilation; the court's current version was not confirmed) | `vid-complaint.typ`: `margin`, `pitch-body`, the page-number footer |
| VI-FORM-002 | LRCi 5.1 (type and margins) | At least 12-point type; at least one-inch margins; footnotes may be 10-point and single-spaced. | Not in the 2011 PDF. Search excerpt of the current LRCi text at courtrules.net (https://www.courtrules.net/courts/federal/district-virgin-islands/local-rules/10791); the page itself returned HTTP 403, so this is an excerpt, not a read page | `type-size = 12pt`, `margin = 1in`. Footnotes are not produced (Known gaps 5). |
| VI-FONT-001 | LRCi 5.1(a) and 5.1 (current) | No typeface named. The current excerpt adds "at least 12-point type", which the template meets. | VID LRCi PDF (as above) names no face. Current text: courtrules.net excerpt (as above), which names no face. Checked 2026-10-15. | `font-family = ("Times New Roman", "Liberation Serif")`: the exemplar's face, the house standard. |
| VI-CONT-001 | LRCi 7.1(d) | No document may exceed 20 pages without leave (2011 text). | VID LRCi PDF (as above) | Not checked by the template. The sample is 12 pages. |
| VI-CONT-002 | LRCi 7.1 (current) | Over 20 substantive pages needs a word-count certificate of compliance. | courtrules.net excerpt (as above) | Not produced. Not needed at this length. |
| FRCP-10(a) | Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number, and a Rule 7(a) designation; the complaint's title names all parties. | https://www.law.cornell.edu/rules/frcp/rule_10 | `court-header`, `caption`, the title |
| FRCP-10(b) | Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | https://www.law.cornell.edu/rules/frcp/rule_10 | `body-chunks`: body paragraphs are numbered by the template; headings, quotations, lists and `~ ` paragraphs are not. |
| FRCP-8(a) | Fed. R. Civ. P. 8(a)(2) | Short and plain statement of the claim, and a demand for relief. | https://www.law.cornell.edu/rules/frcp/rule_8 | Author content (the sample's prayer). The template does not check the wording. |

Not produced by this template (separate filings): the civil cover sheet, the summons, the Rule 7.1 disclosure statement, any proposed order, and the exhibits. The Henry filing has a Civil Cover Sheet and exhibits as attachments; they are not part of the complaint.

## Layout

- Letter paper, one-inch margins, Times New Roman 12 pt (LRCi 5.1(a)). Footer: the page number centred in a single-pitch line ending 0.5 in above the page edge.
- The cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line a box of its pitch, 24 pt for the body (LRCi 5.1(a) double spacing), 13.8 pt for single lines (court title, caption, quotations, signature, footer); the spaces between blocks explicit.
- Court name (bold) and division, centred single lines, on the first page (`IN THE DISTRICT COURT OF THE VIRGIN ISLANDS` is the template's constant; the division comes from the frontmatter).
- Caption, a blank single line below: parties on the left (a 3.5 in column), closed by a 0.75 pt rule on the right and bottom; each name single-spaced, its designation 6 pt below and 1.2 in in, "v." centred 7 pt from both parties; `Civil Action No.` 0.3 in into the right column, blank when `case_number` is empty (as on the filed copy).
- Title centred and bold on the body pitch, a blank double line below the caption; an optional unnumbered opening paragraph (`lead_in`).
- Body: a markdown paragraph is a numbered paragraph (the number at the half-inch indent in a 0.5 in box, the text from 1 in; a tab in the docx). Headings at the type size on the body pitch with no space of their own, kept with the next block: `# ` centred bold, `## ` bold, `### ` bold italic. `~ ` marks an unnumbered paragraph (the count's sub-title, the WHEREFORE clause). `> ` quotations single-spaced, 0.5 in in from both margins, 12 pt above and below. Prayer items keep the author's numbers, half an inch in, the text hanging at 1 in.
- Signature block, 24 pt below the last paragraph and kept with it (never alone on a page): "Dated:" and the date at the left of the first line, then the preamble, `/s/` signer (7 pt lower) and counsel lines in a column from 3.4 in, single-spaced.
- Parameters are named at the top of `typst/vid-complaint.typ`; each names the rule or the layout choice it traces to.

## Markdown contract (for samples)

- YAML frontmatter, then the body, the same shape as the CAND complaint contract (`courts/ninth-circuit/california/federal/northern-district/complaint/`). The ca9 appellate contract does not apply to a district complaint.
- Frontmatter: `title`, `division`, `case_number` (may be empty), `caption` (list of `{names, designation}`; "v." is inserted between parties), `lead_in` (optional), `signature` (`date`, `preamble`, `signer`, `lines`).
- Body: paragraphs, `# `/`## `/`### ` headings, `> ` quotations, one list chunk per prayer, `~ ` for unnumbered paragraphs. Escape a literal `*` (as in `at \*5`) so it is not read as italics.
- Not supported: footnotes (the template has no footnote path), tables, raw typst.
- Numbers are never typed in the text: the template numbers the paragraphs, so a sample numbers from 1.

## Overlay

`just overlay courts/third-circuit/virgin-islands/federal/district/complaint` writes the red/blue overlay (red is our render, blue the filed exemplar, black both) to the gitignored `.overlay/`. Pages pair by word overlap; pages 3 to 11 pair with later filed pages because the sample omits filed paragraphs (Known gaps 6). The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **One exemplar.** LRCi tier 2 asks for two or three filers. The search found a second complaint with storage: Moorhead v. Fawkes, 1:26-cv-00014, ECF 1 (33 pages, filer Lorelei C. Monsanto and Shelley A.H. Moorhead, RECAP `gov.uscourts.vid.42043.1.0.pdf`). It was not saved because the brief asks for one exemplar per doc type. Tier 2 is therefore **not** judged against two filers yet.
2. **Font.** No rule names a typeface (VI-FONT-001). Times New Roman 12 pt, the face of the filed exemplar and the house standard, in every engine; the 12-point minimum is met.
3. **Caption.** The party block is closed by a rule (right and bottom), not by a column of ")" marks. Both are seen in D.V.I. filings; recorded as ACCEPTED for tier 2.
4. **Italics.** The exemplar's text layer has no italic markup, so case names are italic in the sample as the author marked them, following the usual convention. Not checked against the exemplar's typeface.
5. **Footnotes.** The filed complaint has eight footnotes (footnote 1 on the Fourteenth Amendment, footnote 2 on the hunting license, and six more). The template has no footnote path, and the sample omits the footnote text and its reference marks. This is a visible difference from the filed page and is OPEN for tier 2.
6. **Partial transcription.** The sample has 58 numbered paragraphs against the filed 76, plus the caption, the lead-in, the three headings of the statement of facts, Count I, the prayer and the signature. Filed ¶¶ 1–10, 13–18, 32, 34, 36–50, 53–76 are transcribed (filed ¶ 11 in part). Not transcribed: filed ¶ 11 (the Solinsky sentence), ¶ 12 (the Massachusetts court), ¶¶ 19–31 (the standing paragraph, the phone calls and the travel plans), ¶ 33 (Gun Owners Foundation), ¶ 35 (the sentence that Commissioner Brooks "shall not issue a license"), ¶¶ 51–52 (the "Period" paragraph and the scope paragraph), and the footnotes. This is deliberate, to keep the sample inside the 8–14 page target; the overlay shows the difference.
7. **Paragraph numbers.** The filed numbering is not reproduced (see 6).
8. **Ragged right.** Body text is left-aligned, not justified (the cross-engine model sets every engine ragged right).
9. **Page 11 is short.** The PRAYER FOR RELIEF heading, the WHEREFORE line and the six prayer items move to page 12 with the signature (the last item and the signature are kept together, the heading with its text). The alternative, a signature alone on a page, was rejected.
10. **Selftest.** `tools/check-selftest.sh` needs a `court.json`, which this doc-type folder does not have; `tools/check.sh` runs on it (typst and docx, 0 failed).
11. **Transcription fix.** The sample had a straight `"` after "everyone else." (¶ 37) that typst set as an opening quote and pandoc as a closing one; the filed page has a closing quote, now written `”` in the sample (fb-595.68.35).
12. **Counsel block.** The exemplar has no counsel block on the first page (counsel appears in the signature). The template follows the exemplar and does not produce a first-page counsel block. The 2011 LRCi text does not require one; the current text was not confirmed.

## Review record (Gate 2: every page of both renders, typst and docx side by side at 50 dpi, 2026-10-22)

Paragraph numbers in this table are the sample's (1–58), as rendered.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court name, division, caption, title, lead-in, ¶¶ 1–3 | OK, both engines alike (the caption also compared at 100 dpi: rules, columns and line breaks the same). |
| 2 | ¶¶ 4–8 | OK. |
| 3 | ¶¶ 9–15, heading I. PARTIES | OK. |
| 4 | ¶¶ 15–19 | OK. |
| 5 | ¶¶ 20–26, II. JURISDICTION AND VENUE, III. STATEMENT OF FACTS, a. The Second Amendment | OK. |
| 6 | ¶¶ 27–32 | OK. |
| 7 | ¶¶ 32–35 | OK. |
| 8 | ¶¶ 36–39 | OK. |
| 9 | ¶¶ 40–44, heading b. | OK. |
| 10 | ¶¶ 45–49, COUNT I and its sub-title | OK. |
| 11 | ¶¶ 50–58 | OK; short by design (Known gaps 9). |
| 12 | PRAYER FOR RELIEF, WHEREFORE, items 1–6, date and signature block | OK. The signature is with the prayer, not alone. |

The docx PDF breaks every line and page where the typst PDF does (XENG-001..003: 336/336 lines, 12/12 pages).

Defects of the earlier template (fixed by the cross-engine port, fb-595.68.35): em leadings with the paragraph spacing as the double space, the number 0.1 in before the text, a double space around every heading, the signature as a two-column grid; a docx in EB Garamond with blank paragraphs and auto line spacing for the single lines.

[Formbook index](../../../../../../README.md)

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): the docx render breaks every line and every page where the typst render does, and `eval.yaml` gates it (`params.cross_engine: gate`, fb-595.68.35).

- **typst** (primary, `typst/vid-complaint.typ`): the reference.
- **docx** (`docx/`): `docx/reference.xml` (`base="xengine"`, the typst face `{font}` = Times New Roman, 12 pt; Body Text in exact 24 pt line boxes with a 0.5 in first-line indent, single lines 13.8 pt; the heading levels at the type size on the body pitch; "Numbered Paragraph" with a tab 1 in from the margin; "Numbered Item" hanging at 1 in; letter page, 1 in margins, the footer 0.5 in above the edge) and `docx/vid-complaint.lua` on `lib/docx/xengine.lua`, which writes the court title, the caption table (the party column's bottom padding less the rule, which LibreOffice sets below the row), the title, the lead-in, the numbered paragraphs, quotations and prayer items (numbers typed, as typst types them), the signature kept with the last item, the footer (`$FORMBOOK_FOOTERS`) and the last section (`$FORMBOOK_FINAL`). `fb render` builds the reference and runs the passes; no shell script (fb-595.68).
- Checks (2026-10-22): typst 9 passed, 0 failed; docx 13 passed, 0 failed, XENG-001..003 PASS (336/336 lines, 12/12 pages).
- Word: not available here. The file converts in LibreOffice with no error; Word may paginate slightly differently (docs/DOCX.md).
