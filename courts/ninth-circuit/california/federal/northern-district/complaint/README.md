# cand: complaint

Doc type: **complaint** in the United States District Court for the Northern District of California (`cand`).
Folder: `courts/ninth-circuit/california/federal/northern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | listed in `usage/SOURCE.md` (1 filer), but the PDF is **not in this snapshot**: `usage/` holds only `SOURCE.md` |
| sample md | `usage/INPUT-complaint.md` (a portion of the filing, see below) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 11 pages, typst 0.15.0, vendored Times New Roman only, no warnings (fb-595.68.22) |
| overlay | **fail**: `tools/overlay.sh` exits 1 ("no exemplar pdf in usage/"). `usage/OVERLAY-superhuman-complaint.txt` is the stale page map from the EB Garamond render; no `.pdf` overlay exists |
| pages reviewed | 10 of 10 of the earlier Liberation Serif render (every page rendered at 70 dpi and viewed). The 11-page Times New Roman render has not been re-reviewed page by page (fb-595.68.22). |

Typeface: Civil L.R. 3-4(c)(2)(A) names Times New Roman and Century Schoolbook as examples of a standard proportional font. The template uses vendored **Times New Roman** 12 pt, in typst and docx alike (fb-595.68.22; was Liberation Serif, and EB Garamond before that). The filed exemplar is Times. The render is 11 pages (fb-595.68.22).

## Governing rules

Primary source: N.D. Cal. Civil Local Rules, fetched 2026-10-14 from https://www.cand.uscourts.gov/rules/civil-local-rules/ (the page's "Civil L.R." text; the page carries no separate revision date, so the version is "as posted 2026-10-14").

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Civil L.R. 3-4(a)(1) | Counsel's name, address, telephone, email and state bar number in the upper left of the first page. | `counsel` frontmatter, lines 1 onward. |
| Civil L.R. 3-4(a)(3) | From the eighth line of the first page: court title (with division), title of the action, case number with judge initials, title of the paper. | `court-title`, `caption`. Line 8 starts the court title unless counsel needs more room (the rule allows that). |
| Civil L.R. 3-4(a)(5) | "Class Action" legend under the title, if the complaint is a class action. | `legend` frontmatter (not used by the sample; the sample is not a class action). |
| Civil L.R. 3-4(c)(1) | 8½ × 11 inch white paper with numbered lines. | `page-w`, `page-h`, `line-numbers()`. |
| Civil L.R. 3-4(c)(2) | Text double-spaced, no more than 28 lines per page, except counsel block, title, footnotes and quotations. | `pitch = 24pt`, `lines-per-page = 27` (fb-595.68.22); counsel, caption and signature at `pitch-single = 12pt`. |
| Civil L.R. 3-4(c)(2)(A) | Standard proportionally spaced font (e.g. Times New Roman or Century Schoolbook). | `font-family` Times New Roman (vendored; see Typeface above) (fb-595.68.22). |
| Civil L.R. 3-4(c)(2)(B) | 12-point type or larger. | `type-size = 12pt`, everywhere including footer (10 pt, see Known gaps). |
| Civil L.R. 3-4(c)(2)(C) | No more than 10 characters per horizontal inch. | Not asserted (see Known gaps). |
| Civil L.R. 3-4(c)(3) | Footer on each page with the paper's title, and the case number once assigned. | `footer-block` (title from `footer_title`, `CASE NO.` from `case_number`). |
| Civil L.R. 3-5(a), (b) | Separate "Jurisdiction" and "Divisional Assignment" paragraphs. | Author content (the sample has "Jurisdiction and Venue" and "Divisional Assignment" headings). The template does not check the wording. |
| Civil L.R. 3-6 | Demand for jury trial: "DEMAND FOR JURY TRIAL" in the caption right after the title; the demand at the end of the pleading. | `jury_demand: true` puts the caption line; the demand paragraph is in the body. |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, file number and Rule 7(a) designation. | As Civil L.R. 3-4(a) above. Fetched from https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Each body paragraph is numbered by the template (`allegations()`); headings and lists are not. |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44); the Certification of Interested Entities or Persons (Civil L.R. 3-15); the Rule 7.1 disclosure statement; the summons. Any of these may be required with the first filing.

## Layout

- Numbered lines 1 to 27 down the left margin (fb-595.68.22), a double rule at the text's left edge and a single rule at its right (the pleading form).
- Top margin 1 inch: line 1 sits on the top margin, so the 27 lines end at 10 inches and the footer is in the 1 inch bottom margin (fb-595.68.22).
- Counsel block single-spaced on lines 1 to 7 (the template grows the block for longer counsel lists, pushing the court title down).
- Body text, headings and prayer items sit in exact 24 pt line boxes on the numbered lines; counsel, caption and signature lines in 12 pt boxes, two to a numbered line (fb-595.68.22).
- Paragraphs are numbered 1, 2, ... by the template (the number in a half-inch box after the indent); a heading is sticky (kept with what follows it), and the last block is kept with the signature block (fb-595.68.22).
- Prayer items (markdown list) are lettered (a), (b), ...; the list may break across pages.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1 centered caps; level 2 centered bold; level 3 bold italic left), a list (`1.` items, lettered by the template), or a paragraph (numbered by the template).
- Frontmatter fields: `case_number`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `footer_title`, `counsel` (lines), `lead_in` (unnumbered lead-in paragraph, optional), `jury_demand`, `legend` (optional), `division` (optional), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Not supported: tables, footnotes in the body (none used), raw typst.
- The sample must not put the numbering in the text: the template numbers the allegations.

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The search (CourtListener RECAP, `type=r`, `court=cand`, complaints filed 2026-10-02 to 2026-10-13) also found Saflor v. Every, Inc. (3:26-cv-11467, 10 pages, Times New Roman, pleading paper, counsel Clapp) and SK hynix Inc. v. Longhorn IP LLC (3:26-cv-11609, 35 pages). Those were downloaded and checked for text and format but not saved, because the brief asks for one exemplar per doc type. Tier 2 is therefore **not** judged against two filers yet.
2. **Font.** The rule names Times New Roman and Century Schoolbook as examples of a standard proportional font. The template uses vendored Times New Roman 12 pt in typst and docx (fb-595.68.22; it was Liberation Serif, and EB Garamond before that), the filed exemplar's face. Reading choice: the rule's text ("standard proportionally spaced font", "e.g.") would also allow other faces.
3. **Characters per inch (Civil L.R. 3-4(c)(2)(C)).** Not asserted. The rule is written as a pitch limit (10 cpi), which reads as the monospace case; the exemplar is proportional Times 12 pt. Taking the rule to apply to proportional text would require a different font size and is a reading question, not a template defect.
4. **Footer type size.** The footer is 10 pt; the rule's 12-point requirement is written for "text", and footers are not text in the rule's terms (3-4(c)(3)). Logged as an interpretation.
5. **Caption.** The party column is closed by a rule (right and bottom) rather than a column of ")" marks used in the exemplar. This is a tier-2 convention choice (both are seen in N.D. Cal. filings); recorded as ACCEPTED.
6. **Case names are not italic in the sample.** The text layer of the exemplar has no italic markup, so the transcription is roman. The template does italicize `*...*` markdown, so future samples can carry italics.
7. **Overlay pairing.** The sample is a portion of the 29-page filing (pages 2 to 7, 17 to 18, 22 to 23 of the exemplar, with the lead-in, the caption and the signature from pages 1 and 23 to 24). Pages 6 and 10 of the overlay pair with exemplar pages that have little overlap because the sample skips pages (the text pairs with the page that shares most words). The overlay is a diagnostic, not a score.
8. **Paragraph numbers differ.** The sample numbers its allegations from 1 (the template numbers them). The filed paragraph numbers are not transcribed.
9. **Ragged right.** Body text is left-aligned, not justified. The exemplar's justification could not be read from the text layer; this is a tier-2/3 choice and is not asserted.
10. **Checks.** `sh tools/check.sh <this folder>` runs on this folder (`eval.yaml`): typst `RESULT: 9 checks passed, 0 failed`; docx `RESULT: 13 checks passed, 0 failed` (fb-595.68.22). No `tools/check-selftest.sh` result is recorded here.
11. **Headings.** A heading is sticky (kept with what follows it); the single-line `heading-line` assertion is gone with the shared layout model (fb-595.68.22).

## Review of the rendered pages (the 10-page Liberation Serif render, before fb-595.68.22; not re-verified against the 11-page Times New Roman render)

- Page 1: counsel on lines 1 to 7, court title on line 8 and 9, caption on lines 11 to 15, title and jury demand legend at the right. Footer: title and case number. No spill. Pass.
- Page 2: lead-in (unnumbered), INTRODUCTION heading, paragraphs 1 to 3; body text on the numbered lines. Pass.
- Pages 3 to 7: numbered paragraphs at 0.5 inch indent; THE PARTIES, JURISDICTION AND VENUE, DIVISIONAL ASSIGNMENT and FACTUAL BACKGROUND centered bold caps; the cause headings (FIRST CAUSE OF ACTION, the centered bold sub-heading) on line 1 and line 2 of page 7; no heading at the foot of a page. Pass.
- Page 8: REQUEST FOR RELIEF heading, WHEREFORE paragraph, item (a) with its wrapped lines. Pass.
- Page 9: items (b) to (l), line-aligned. Pass.
- Page 10: item (l) continues, item (m), DEMAND FOR JURY TRIAL heading with paragraph 35, the date, signature block (single-spaced, firm, "By: /s/" and the signer). Pass.

Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate") and set Times New Roman 12 pt (Civil L.R. 3-4(c)(2)): body text, headings and prayer items in exact 24 pt line boxes on the 27 numbered lines; counsel, caption and signature lines in 12 pt boxes, two to a numbered line, every second baseline a numbered line's. The docx breaks every line and page where typst does (`eval.yaml`: `params.cross_engine: gate`; XENG-001..003 pass, 332 of 332 lines).

Docx engine (fb-595.68.22): `docx/reference.xml` (the cross-engine style recipe, `base="xengine"`, in the typst face) and `docx/cand.lua`, no shell. The filter writes the cover (counsel, court title on line 8, the caption with the parties in a table ruled at its right and bottom), the numbered allegations (the number in a half-inch box after the indent, as typst), the headings, the lettered prayer items and the signature block (one row that does not split, kept with the last paragraph); and through fb render's `$FORMBOOK_FOOTERS` and `$FORMBOOK_FINAL` the page (letter, 1 in top, 1.5 in left, 1 in right) and its footer: the page number, the paper's title and the case number (Civil L.R. 3-4(c)(3)), with the line numbers 1 to 27 in a page-anchored VML text box and the pleading rules as page-high VML boxes behind the text. LibreOffice keeps a VML text box's default inset whatever `inset` says, so the box is moved by the measured difference (`BOX_DX`, `BOX_DY` in the filter); Word may set the numbers a few points off.

Open: the WHEREFORE lead-in and the jury-demand sentence are numbered like every body paragraph (both engines alike).
