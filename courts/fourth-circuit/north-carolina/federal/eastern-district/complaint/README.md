# nced: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of North Carolina (`nced`).
Folder: `courts/fourth-circuit/north-carolina/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (a portion of the 49-page filing; see its frontmatter comment) |
| typeface | no face named by the rule: Times New Roman 12 pt, the house standard (`docs/FONTS.md` rule 6; Liberation Serif as fallback; recorded as `template_face` in `data/exemplar-fonts.json`), on typst and docx (fb-595.68.18) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 10 pages, typst 0.15.0, Times New Roman only (`pdffonts`), no warnings |
| overlay | ok: `usage/OVERLAY-powell-complaint.pdf` (red = our render, blue = filed page, black = agreement) and `usage/OVERLAY-powell-complaint.txt` (the page map) |
| pages reviewed | 9 of 9 on the earlier EB Garamond render, before fb-595.68, every page rendered at 60 dpi and viewed (table below) |
| tier 2 | not judged against a second filer: see "Known gaps", item 1 |

## Governing rules

Primary source: United States District Court, Eastern District of North Carolina, **Local Civil Rules, May 2023 edition**, https://www.nced.uscourts.gov/pdfs/Local%20Civil%20Rules%202023.pdf (fetched 2026-10-14; the newest edition found in search; no later edition was located). Rule text quoted from that PDF.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 10.1(a) | Double-spaced, single-sided, standard letter paper; all typed matter in at least 11-point type; one-inch margin on all sides. | `type-size = 12pt`, `margin = 1in`, `pitch-double` (27.6 pt, 2 x the 13.8 pt single line). Footnotes are 12 pt too. |
| LR 10.1(a) typeface | Names no typeface: "all typed matter appearing in at least 11 point font size". Text checked in the 2023 local rules PDF (`pdftotext`, 2026-10-14). | Times New Roman, the house standard where no face is named (`docs/FONTS.md` rule 6). |
| LR 10.1(b) | State the court and division. | `court-title()`: "IN THE UNITED STATES DISTRICT COURT / FOR THE EASTERN DISTRICT OF NORTH CAROLINA / <DIVISION> DIVISION"; the division is frontmatter `division`. |
| LR 10.1(c) | Bear the case number, except for the initial filing. | `case-number-line()`: "No. ______" when `case_number` is absent (a new complaint), otherwise "No. <number>". |
| LR 10.1(d) | Caption of the case. | `caption()`: one row per frontmatter line, each with a ")" in the next column (the form the rule's own example uses). |
| LR 10.1(e) | Title, and the federal statute or rule relied on. | `title-block()`: frontmatter `brief_title`; the title states the rule or statute (author text). |
| LR 10.1(f) | Name, firm, address, telephone, fax, e-mail and state bar number of each attorney. | `signature-block()`: `firm`, `signers` (name, bar number, e-mail), `address` (address, telephone). Fax is not in the sample: add it to `address` if the filer uses one. |
| LR 10.1(g) | Date the document was signed. | "This the <date>." from frontmatter `date`. |
| LR 10.1(h), (i) | Signed by an attorney, with the typed name in the same form below the signature. | "BY: /s/ <by>" (or "/s/ <by>" without a firm), then each signer's name in capitals. |
| LR 10.1(j) | Each page numbered sequentially. | `page-number()`, centered in the footer. |
| Fed. R. Civ. P. 8(a) | Short and plain statement of grounds for jurisdiction, of the claim, and a demand for relief. | Author content. The template checks nothing here. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | As LR 10.1(b) to (e) above. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: every text paragraph is numbered 1, 2, ...; headings and lists are not. |
| Fed. R. Civ. P. 38(b) | A jury demand may be included in a pleading. | `jury_demand: true` adds "(JURY TRIAL DEMANDED)" under the title; the demand paragraph is author text. |

Verified against https://www.law.cornell.edu/rules/frcp/rule_8, `rule_10` on 2026-10-14 (text read from the page).

Not produced by this template (separate papers that the filer may need with the first filing): the civil cover sheet (JS-44); the summons; the Rule 7.1 disclosure statement; and the LR 7.3(a) corporate affiliate and financial interest disclosure statement, which LR 7.3(a) requires of "all parties ... whether or not they are covered by the terms of Fed. R. Civ. P. 7.1".

## Layout

- Letter paper; one-inch margins; Times New Roman 12 pt; double spacing (27.6 pt between baselines, a blank double line between paragraphs).
- Cover: court and division centered at the top; "No." line; the caption (party column, ")" column, title block to the right and centered on the caption); then the body starts on the same page, as in the rule's example and the filed exemplar.
- Body: the lead-in (unnumbered); headings (level 1 centered bold capitals, level 2 centered bold, level 3 bold italic at the left); numbered paragraphs (first-line indent, number, text); lists lettered A., B., ... (the prayer). A WHEREFORE paragraph is unnumbered.
- Signature block: date line, then the firm, the "BY" line, the signers, the address and the party represented, in single spacing at 3 inches from the left.
- No line numbers and no pleading rules: the N.D. Cal. complaint in this repository is on pleading paper because that court requires it; this court does not.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `case_number` (optional), `division` (required), `caption.lines` (list; each entry is a string, or `{t: text, i: indent}` with `i` in half inches; each line must fit on one line: the template asserts it), `brief_title` (required), `jury_demand` (optional), `lead_in` (optional), `date` (required, e.g. `"12th day of September, 2026"`), `signature` (`firm` optional list, `by` optional, `signers` list of `{name, lines}`, `address` list, `counsel_for` list).
- Body: blank-line-separated chunks. `#` heading (level 1), `##` (level 2), `###` (level 3), a list (`1.` items, lettered by the template; the items must be on consecutive lines, with no blank lines between them), or a paragraph (numbered by the template). Do not type paragraph numbers: the template numbers them, and a line that starts with a bare number is read as a list.
- Footnotes: `text[^key]` and `[^key]: text` (anywhere in the body; the template carries the definitions with each chunk so the reference resolves).
- Not supported: tables, raw typst, forced line breaks.

## Overlay

`tools/overlay.sh` pairs each rendered page with the filed page that shares the most words (Jaccard overlap, shown in `OVERLAY-powell-complaint.txt`). The pairing is by text, not by position, so a page can pair with a page far away in the filing (page 8, count IX and the start of the prayer, paired with filed page 45, count IX, at 41% word overlap on the earlier EB Garamond render, before fb-595.68). Read the overlay as a diagnostic for layout and spacing, not as a score.

## Known gaps and open choices

1. **Only one exemplar; tier 2 is not judged against two filers.** Searches, all on 2026-10-14: CourtListener RECAP search (`type=r`, `court=nced`, `filed_after=2026-01-01`, queries "complaint" and "motion to dismiss" memorandum); the nced local rules (2023 PDF); a web search for EDNC complaints. The six most recent EDNC complaints in the results (filed 2026-10-08 to 2026-10-13) had no available PDF (`is_available: false`). Powell v. N.C. DOT (5:26-cv-00667, filed 2026-09-12, counsel-filed, text layer) is the one available complaint found. No second filer was downloaded, so tier 2 (two or three filers) is not met.
2. **Font (ACCEPTED).** LR 10.1(a) requires at least 11 point and names no typeface, so the template is Times New Roman at 12 pt, the house standard (`docs/FONTS.md` rule 6, David 2026-10-17). The filed exemplar is Century Schoolbook: that is one filer's choice (tier 3), not a court requirement. Before fb-595.68.18 the template was EB Garamond, then TeX Gyre Schola.
3. **Jury demand paragraph is numbered.** The exemplar's "JURY DEMAND" paragraph is unnumbered. The template numbers every text paragraph except a WHEREFORE clause, so the demand is numbered 39. Rule 10(b) is satisfied either way; this is a tier-2 difference, accepted.
4. **Caption lines are one per line.** The exemplar's caption wraps party names; the sample reflows them into the caption lines. The template asserts that each line fits, so a longer line fails the build with a message rather than misaligning the ")" column.
5. **Paragraph numbers in the sample run from 1**, not the filed numbers (the sample is a portion; paragraphs 17, 21 and 24 of the filing, which hold a quotation and bulleted lists, are omitted).
6. **Ragged right.** Body text is left-aligned, not justified; the exemplar's alignment is not asserted.
7. **Headings wrap double-spaced.** A heading that runs to two lines (the "IV. ADMINISTRATIVE EXHAUSTION" heading) keeps the body's double spacing. Setting the wrapped heading single-spaced overlapped the next paragraph in this typst build, so the template keeps the simpler form.
8. **File names.** The brief's literal names (`usage/<id>.md`, `<id>-overlay.pdf`) are replaced by the repository's tool names (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`), because `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.pdf`, and `tools/` is out of scope for this unit.
9. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court root (a `court.json` and `rules.md`); this doc-type folder is not that shape, and the brief forbids touching `tools/`. The render (no warnings, vendored font only) and the overlay were run; the review below is the Gate 2 equivalent.

## Review of the rendered pages (the earlier 9-page EB Garamond render, before fb-595.68)

| Page | What was checked | Result |
|---|---|---|
| 1 | Court title and division; "No." line; caption rows and ")" column; title block centered on the caption; lead-in; heading I; paragraphs 1 and 2; footnote 1. | Pass. |
| 2 | Paragraph numbering and first-line indent; double spacing; no overlap between paragraphs. | Pass. |
| 3 | Paragraphs 8 to 12; a heading-free run of text. | Pass. |
| 4 | Paragraphs 13 to 21. | Pass. |
| 5 | Paragraphs 22 to 28. | Pass. |
| 6 | Paragraphs 29 to 31; heading II (parties); heading III at the foot of the page with its paragraph on the same page. | Pass. |
| 7 | Paragraphs 32 to 35; heading IV (wraps to two double-spaced lines); paragraph 36. White space at the foot: count IX's heading is kept with its paragraph and moves to page 8 (the sticky heading). | Pass; the white space is accepted. |
| 8 | Count IX heading (three lines, centered); paragraphs 37, 38; heading VII; the WHEREFORE clause (unnumbered); prayer items A to D, lettered. | Pass. |
| 9 | Prayer items E to K; "JURY DEMAND" heading; paragraph 39; date; signature block (firm, BY line, typed name, bar number, e-mail, address, telephone, party). No spill. | Pass. |

## Engines

The same markdown renders through the typst engine (`typst/`, the reference) and the docx engine (`docx/`). The docx output is `usage/OUTPUT-complaint.docx` with its LibreOffice PDF `usage/OUTPUT-complaint.docx.pdf`. Build: `sh tools/render.sh --engine docx <this folder> usage/INPUT-complaint.md`; `fb render --engine docx` builds the reference document from `docx/reference.xml` (the shared cross-engine recipe in the typst face) and runs pandoc with `docx/nced-complaint.lua` (`make-reference.sh` and `reference.docx` were retired into fb render in fb-595.68.18). Both engines are 10 pages; XENG-001..003 pass and `usage/.check-docx.txt` is PASS (typst 9 and docx 13 checks passed).

- *Matches typst (checked on the PDF of the earlier EB Garamond docx; the face is now Times New Roman 12 pt on both, the only face in the PDF):* letter paper with 1-inch margins (all text inside 72 to 540 pt); body double-spaced at the typst baseline pitch of 27.6 pt, with no space between paragraphs and a 0.5 in first-line indent; the cover (court and division, the "No." line, the caption with its ")" column, the title block and the jury legend); allegations numbered 1, 2, ... with headings and the WHEREFORE clause unnumbered; the prayer lettered A., B., ... with a hanging indent; headings bold, centered at level 1 and 2, bold italic at level 3, at typst's sizes; the date line and signature block at 3 in; footnote at 12 pt, single-spaced; the page number centered in the footer, sequential from the cover. Page count was the same as typst (9 pages then; 10 now).
- *Differs* (on that earlier docx; not re-checked here): LibreOffice and typst break some lines at different words, so a few pages hold one line more or less, and the text sits about 3 pt lower on each page than in typst. Measured against the typst page: the caption, headings and signature block fall within about 3 pt. The paragraph numbers and prayer letters are typed by the template, not Word list numbering, so editing the docx in Word does not renumber them. Heading sizes (about 17 pt and 14.5 pt) are set as sizes, because typst's 1.4 em and 1.2 em come from its defaults.
- *Not checked:* Word. The `.docx` is a valid zip with well-formed XML parts (checked with `unzip -tq` and `xmllint`), and LibreOffice converts it without error. It has not been opened in Word, so the no-repair check is not done here.
- *BLOCKED:* none. Every requirement of the template that a docx can express is built; nothing is missing from the render.
- *Pages reviewed:* the earlier EB Garamond docx PDF, pages 1 to 9 of 9, each viewed at 60 dpi beside the typst page of the same number.
