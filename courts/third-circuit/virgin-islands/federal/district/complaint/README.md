# vid: complaint

Doc type: **complaint** in the District Court of the Virgin Islands (`vid`, Division of St. Thomas and St. John, and the other divisions by frontmatter). Folder: `courts/third-circuit/virgin-islands/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-vid-complaint-henry326cv00038.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-vid-complaint-henry.md` (a partial transcription: see Known gaps 6) |
| typeface | none required by the rules (VI-FONT-001): EB Garamond kept, no substitute needed |
| render | ok: `usage/OUTPUT-vid-complaint-henry.typst.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh` treats any warning as failure) |
| overlay | ok: `usage/OVERLAY-henry-complaint.pdf` and `OVERLAY-henry-complaint.txt` |
| pages reviewed | 12 of 12 (each page rendered at 70 dpi and viewed; see the review record below) |

## Governing rules

Court: District Court of the Virgin Islands. The rules below are the local rules of civil procedure (LRCi) and the Federal Rules of Civil Procedure. The LRCi text has two sources, and they do not agree on every point.

| ID | Rule | Requirement | Source (fetched 2026-10-14) | Where it lives |
|---|---|---|---|---|
| VI-FORM-001 | LRCi 5.1(a) | All papers double-spaced except quoted material; each page numbered consecutively; 8½ × 11-inch white paper. | VID LRCi PDF, https://www.vid.uscourts.gov/sites/vid/files/local_rules/VID_LRCi_042911.pdf (a July 2011 compilation; the court's current version was not confirmed) | `vid-complaint.typ`: `margin`, `body-leading`, page numbering |
| VI-FORM-002 | LRCi 5.1 (type and margins) | At least 12-point type; at least one-inch margins; footnotes may be 10-point and single-spaced. | Not in the 2011 PDF. Search excerpt of the current LRCi text at courtrules.net (https://www.courtrules.net/courts/federal/district-virgin-islands/local-rules/10791); the page itself returned HTTP 403, so this is an excerpt, not a read page | `type-size = 12pt`, `margin = 1in`. Footnotes are not produced (Known gaps 5). |
| VI-FONT-001 | LRCi 5.1(a) and 5.1 (current) | No typeface named. The current excerpt adds "at least 12-point type", which the template meets. | VID LRCi PDF (as above) names no face. Current text: courtrules.net excerpt (as above), which names no face. Checked 2026-10-15. | `font-family = "EB Garamond"` kept. FONTS.md's "No face named" row applies, so no substitute is used. |
| VI-CONT-001 | LRCi 7.1(d) | No document may exceed 20 pages without leave (2011 text). | VID LRCi PDF (as above) | Not checked by the template. The sample is 12 pages. |
| VI-CONT-002 | LRCi 7.1 (current) | Over 20 substantive pages needs a word-count certificate of compliance. | courtrules.net excerpt (as above) | Not produced. Not needed at this length. |
| FRCP-10(a) | Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number, and a Rule 7(a) designation; the complaint's title names all parties. | https://www.law.cornell.edu/rules/frcp/rule_10 | `court-header`, `caption`, `title` |
| FRCP-10(b) | Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | https://www.law.cornell.edu/rules/frcp/rule_10 | `chunks-of`: body paragraphs are numbered by the template; headings, quotations and lists are not. |
| FRCP-8(a) | Fed. R. Civ. P. 8(a)(2) | Short and plain statement of the claim, and a demand for relief. | https://www.law.cornell.edu/rules/frcp/rule_8 | Author content (the sample's prayer). The template does not check the wording. |

Not produced by this template (separate filings): the civil cover sheet, the summons, the Rule 7.1 disclosure statement, any proposed order, and the exhibits. The Henry filing has a Civil Cover Sheet and exhibits as attachments; they are not part of the complaint.

## Layout

- Court name and division, centered, on the first page (`IN THE DISTRICT COURT OF THE VIRGIN ISLANDS` is the template's constant; the division comes from the frontmatter).
- Caption: parties on the left, closed by a rule on the right and bottom; `Civil Action No.` on the right, blank when the frontmatter `case_number` is empty (as on the filed copy).
- Title centered and bold; an optional unnumbered opening paragraph (`lead_in`).
- Body: a markdown paragraph is a numbered paragraph (first-line indent, number, text). `# Heading` is a centered bold section; `## ` is a bold left heading; `### ` is bold italic. `~ ` marks an unnumbered paragraph (for example the WHEREFORE clause). A list (the prayer) is set as a block that sticks to the signature.
- Signature block: date at left; preamble, `/s/` signer and counsel lines at right, single-spaced. It is unbreakable and stays with the list above it.
- Parameters are named at the top of `typst/vid-complaint.typ`; each names the rule or the layout choice it traces to.

## Markdown contract (for samples)

- YAML frontmatter, then the body, the same shape as the CAND complaint contract (`courts/ninth-circuit/california/federal/northern-district/complaint/`). The ca9 appellate contract does not apply to a district complaint.
- Frontmatter: `title`, `division`, `case_number` (may be empty), `caption` (list of `{names, designation}`; "v." is inserted between parties), `lead_in` (optional), `signature` (`date`, `preamble`, `signer`, `lines`).
- Body: paragraphs, `# `/`## `/`### ` headings, `> ` quotations, one list chunk per prayer, `~ ` for unnumbered paragraphs. Escape a literal `*` (as in `at \*5`) so it is not read as italics.
- Not supported: footnotes (the template has no footnote path), tables, raw typst.
- Numbers are never typed in the text: the template numbers the paragraphs, so a sample numbers from 1.

## Overlay

`usage/OVERLAY-henry-complaint.pdf` and `.txt` are the red/blue test: red is our render, blue is the filed exemplar, black is both agreeing. The pairing is by word overlap, not by index, and the page map is in the `.txt`. Pairs: ours p.1 ↔ filed p.1 (59.8%), p.2 ↔ p.2 (51.3%), p.3 ↔ p.4, p.4 ↔ p.9, p.5 ↔ p.11, p.6 ↔ p.13, p.7 ↔ p.15, p.8 ↔ p.16, p.9 ↔ p.17, p.10 ↔ p.18, p.11 ↔ p.19, p.12 ↔ p.20. Pages 3 to 11 pair with later filed pages because the sample omits filed paragraphs (Known gaps 6). The overlay is a diagnostic, not a score: the exemplar is on Times in a fuller form, and the render uses EB Garamond, so the text lines will not coincide.

## Known gaps and open choices

1. **One exemplar.** LRCi tier 2 asks for two or three filers. The search found a second complaint with storage: Moorhead v. Fawkes, 1:26-cv-00014, ECF 1 (33 pages, filer Lorelei C. Monsanto and Shelley A.H. Moorhead, RECAP `gov.uscourts.vid.42043.1.0.pdf`). It was not saved because the brief asks for one exemplar per doc type. Tier 2 is therefore **not** judged against two filers yet.
2. **Font.** No rule names a typeface (VI-FONT-001), so the template keeps EB Garamond. The exemplar's Times New Roman is one filer's choice, not a requirement; it sits larger on the page than EB Garamond at the same point size, and the 12-point minimum is met. Tier 2's typeface convention is judged against one filer's exemplar (gap 1), so it is not established by two.
3. **Caption.** The party block is closed by a rule (right and bottom), not by a column of ")" marks. Both are seen in D.V.I. filings; recorded as ACCEPTED for tier 2.
4. **Italics.** The exemplar's text layer has no italic markup, so case names are italic in the sample as the author marked them, following the usual convention. Not checked against the exemplar's typeface.
5. **Footnotes.** The filed complaint has eight footnotes (footnote 1 on the Fourteenth Amendment, footnote 2 on the hunting license, and six more). The template has no footnote path, and the sample omits the footnote text and its reference marks. This is a visible difference from the filed page and is OPEN for tier 2.
6. **Partial transcription.** The sample has 58 numbered paragraphs against the filed 76, plus the caption, the lead-in, the three headings of the statement of facts, Count I, the prayer and the signature. Filed ¶¶ 1–10, 13–18, 32, 34, 36–50, 53–76 are transcribed (filed ¶ 11 in part). Not transcribed: filed ¶ 11 (the Solinsky sentence), ¶ 12 (the Massachusetts court), ¶¶ 19–31 (the standing paragraph, the phone calls and the travel plans), ¶ 33 (Gun Owners Foundation), ¶ 35 (the sentence that Commissioner Brooks "shall not issue a license"), ¶¶ 51–52 (the "Period" paragraph and the scope paragraph), and the footnotes. This is deliberate, to keep the sample inside the 8–14 page target; the overlay shows the difference.
7. **Paragraph numbers.** The filed numbering is not reproduced (see 6).
8. **Ragged right.** Body text is left-aligned, not justified. The exemplar's justification could not be read from the text layer; not asserted.
9. **Page 11 is short.** The prayer heading and WHEREFORE line stay on page 11, and the prayer list moves to page 12 with the signature (the sticky list). Page 11 is about two-thirds full. The alternative, a signature alone on a page, was rejected.
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids touching `tools/`. Render and overlay were run; the review below is the Gate 2 equivalent.
11. **Overlay names.** `tools/overlay.sh` reads and writes `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt`. The brief's names (`<id>.pdf`, `<id>-overlay.pdf/.txt`) are applied by renaming after the run; the tool was not changed.
12. **Counsel block.** The exemplar has no counsel block on the first page (counsel appears in the signature). The template follows the exemplar and does not produce a first-page counsel block. The 2011 LRCi text does not require one; the current text was not confirmed.

## Review record (Gate 2 equivalent: every page rendered at 70 dpi and viewed)

Paragraph numbers in this table are the sample's (1–58), as rendered.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court name, division, caption, title, lead-in, ¶¶ 1–4 | OK. Title and lead-in clear of the caption (a block-spacing defect fixed: the title takes a double space below). |
| 2 | ¶¶ 5–9 | OK. Double spacing and numbers at the indent. |
| 3 | ¶¶ 10–16, heading I. PARTIES | OK after the heading fix: the heading has a double space below, so ¶ 13 no longer overlaps it. |
| 4 | ¶¶ 17–22, heading II. JURISDICTION AND VENUE | OK. |
| 5 | heading III. STATEMENT OF FACTS, a. The Second Amendment, ¶¶ 23–28 | OK. |
| 6 | ¶¶ 29–33 | OK. |
| 7 | ¶¶ 34–37 | OK. |
| 8 | ¶¶ 38–42, heading b. | OK. |
| 9 | ¶¶ 43–48 | OK. |
| 10 | ¶¶ 49–55, COUNT I heading and its line | OK. |
| 11 | ¶¶ 56–58, PRAYER FOR RELIEF heading, WHEREFORE line | OK; short page by design (Known gaps 9). |
| 12 | Prayer items 1–6, date, signature block | OK. The signature is with the prayer, not alone. |

Defects found during the review and fixed: (a) a numbered paragraph overlapped the line above it, because paragraph breaks had no space (fixed: paragraph spacing is the double space); (b) the lead-in and the prayer list were blocks, which took no leading (fixed: plain flow); (c) headings had no space below them (fixed); (d) the signature stood alone on page 12 (fixed: the prayer list sticks to it).

[Formbook index](../../../../../../README.md)

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **docx** (`docx/build-reference.sh`, `docx/reference.docx`, `docx/vid.lua`; output `usage/OUTPUT-vid-complaint-henry.docx`): pandoc on a per-court reference.docx, with the caption, title, numbered paragraphs and signature built by the filter from the frontmatter. It matches the typst template in: EB Garamond 12 pt; exact 24 pt (double) line spacing; 1 in margins on letter paper; 0.5 in first-line indent; centered PAGE number in the footer; the court name and division, centered; the caption (parties left, closed by a rule on the right and bottom; `Civil Action No.` at right, blank when `case_number` is empty); the centered bold title; Heading 1 (centered bold), Heading 2 (bold), Heading 3 (bold italic); block quotations single spaced, indented 0.5 in each side; the prayer list kept with the signature block; the signature block as a two-column table that does not split across pages.
- docx differences (pandoc and Word limits): paragraph numbers are text written by the filter, not Word automatic numbering, so Word will not renumber a paragraph inserted by hand. The typst template has no footnote path; a footnote in a docx would be 10 pt, single spaced. Keep-with-next on the prayer items approximates the typst sticky list; page breaks (including the short page 11 of the typst render) are not guaranteed to match. Caption rules and table row heights differ between Word and LibreOffice. No TOC or TOA in this doc type.
- Not verified: pagination and appearance. The docx was checked only as a zip whose entries all read and whose XML parts are well formed (`ziptool`, `xmllint`). It has not been opened in Word or LibreOffice, and no `.docx.pdf` was rendered (LibreOffice is not installed on the build box).
- **BLOCKED** (all checks measured on `usage/OUTPUT-henry-complaint.docx.pdf`): no checks file is readable (this folder and the court folder have no `checks.yaml` or `rules.md`), so the gate check IDs cannot be listed. The rule IDs the template traces to are VI-FORM-001, VI-FORM-002, VI-FONT-001, VI-CONT-001, VI-CONT-002, FRCP-10(a), FRCP-10(b) and FRCP-8(a). Reason for each: LibreOffice cannot run in the build box, so the .docx.pdf cannot be produced or checked.
