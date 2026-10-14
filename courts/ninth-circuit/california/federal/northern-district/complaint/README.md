# cand: complaint

Doc type: **complaint** in the United States District Court for the Northern District of California (`cand`).
Folder: `courts/ninth-circuit/california/federal/northern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-superhuman-3-26-cv-11711-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/superhuman-complaint.md` (a portion of the filing, see below) |
| render | ok: `samples/superhuman-complaint.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/superhuman-complaint-overlay.pdf` and `-overlay.txt` |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

Primary source: N.D. Cal. Civil Local Rules, fetched 2026-10-14 from https://www.cand.uscourts.gov/rules/civil-local-rules/ (the page's "Civil L.R." text; the page carries no separate revision date, so the version is "as posted 2026-10-14").

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Civil L.R. 3-4(a)(1) | Counsel's name, address, telephone, email and state bar number in the upper left of the first page. | `counsel` frontmatter, lines 1 onward. |
| Civil L.R. 3-4(a)(3) | From the eighth line of the first page: court title (with division), title of the action, case number with judge initials, title of the paper. | `court-title`, `caption`. Line 8 starts the court title unless counsel needs more room (the rule allows that). |
| Civil L.R. 3-4(a)(5) | "Class Action" legend under the title, if the complaint is a class action. | `legend` frontmatter (not used by the sample; the sample is not a class action). |
| Civil L.R. 3-4(c)(1) | 8½ × 11 inch white paper with numbered lines. | `page-w`, `page-h`, `line-numbers()`. |
| Civil L.R. 3-4(c)(2) | Text double-spaced, no more than 28 lines per page, except counsel block, title, footnotes and quotations. | `pitch = 24pt`, `lines-per-page = 28`, `body-leading = 1.35em` (24 pt baseline pitch at 12 pt). |
| Civil L.R. 3-4(c)(2)(A) | Standard proportionally spaced font (e.g. Times New Roman or Century Schoolbook). | `font-family = "EB Garamond"`, vendored in `fonts/` (see Known gaps). |
| Civil L.R. 3-4(c)(2)(B) | 12-point type or larger. | `type-size = 12pt`, everywhere including footer (10 pt, see Known gaps). |
| Civil L.R. 3-4(c)(2)(C) | No more than 10 characters per horizontal inch. | Not asserted (see Known gaps). |
| Civil L.R. 3-4(c)(3) | Footer on each page with the paper's title, and the case number once assigned. | `footer-block` (title from `footer_title`, `CASE NO.` from `case_number`). |
| Civil L.R. 3-5(a), (b) | Separate "Jurisdiction" and "Divisional Assignment" paragraphs. | Author content (the sample has "Jurisdiction and Venue" and "Divisional Assignment" headings). The template does not check the wording. |
| Civil L.R. 3-6 | Demand for jury trial: "DEMAND FOR JURY TRIAL" in the caption right after the title; the demand at the end of the pleading. | `jury_demand: true` puts the caption line; the demand paragraph is in the body. |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, file number and Rule 7(a) designation. | As Civil L.R. 3-4(a) above. Fetched from https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Each body paragraph is numbered by the template (`allegations()`); headings and lists are not. |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44); the Certification of Interested Entities or Persons (Civil L.R. 3-15); the Rule 7.1 disclosure statement; the summons. Any of these may be required with the first filing.

## Layout

- Numbered lines 1 to 28 down the left margin, a double rule at the text's left edge and a single rule at its right (the pleading form).
- Top margin 1 inch: line 1 sits on the top margin, so the 28 lines end at 10.33 inches and the footer is in the bottom margin.
- Counsel block single-spaced on lines 1 to 7 (the template grows the block for longer counsel lists, pushing the court title down).
- Every block of text is a whole number of 24 pt rows (`on-grid`), so headings, paragraphs and signature blocks land on the numbered lines.
- Paragraphs are numbered 1, 2, ... by the template; a heading stays with the paragraph after it (`heading-line` + the grouping in `allegations()`).
- Prayer items (markdown list) are lettered (a), (b), ...; the list may break across pages.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1 centered caps; level 2 centered bold; level 3 bold italic left), a list (`1.` items, lettered by the template), or a paragraph (numbered by the template).
- Frontmatter fields: `case_number`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `footer_title`, `counsel` (lines), `lead_in` (unnumbered lead-in paragraph, optional), `jury_demand`, `legend` (optional), `division` (optional), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Not supported: tables, footnotes in the body (none used), raw typst.
- The sample must not put the numbering in the text: the template numbers the allegations.

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The search (CourtListener RECAP, `type=r`, `court=cand`, complaints filed 2026-10-02 to 2026-10-13) also found Saflor v. Every, Inc. (3:26-cv-11467, 10 pages, Times New Roman, pleading paper, counsel Clapp) and SK hynix Inc. v. Longhorn IP LLC (3:26-cv-11609, 35 pages). Those were downloaded and checked for text and format but not saved, because the brief asks for one exemplar per doc type. Tier 2 is therefore **not** judged against two filers yet.
2. **Font.** The rule names Times New Roman or Century Schoolbook as examples; this template uses EB Garamond (vendored, the only font vendored in `fonts/`). EB Garamond at 12 pt has a smaller x-height than Times at 12 pt, so the text looks smaller than the exemplar. The 12-point minimum is met; whether the court wants a larger apparent size is a question for David (a vendored Times-metric font would remove the difference).
3. **Characters per inch (Civil L.R. 3-4(c)(2)(C)).** Not asserted. The rule is written as a pitch limit (10 cpi), which reads as the monospace case; the exemplar is proportional Times 12 pt. Taking the rule to apply to proportional text would require a different font size and is a reading question, not a template defect.
4. **Footer type size.** The footer is 10 pt; the rule's 12-point requirement is written for "text", and footers are not text in the rule's terms (3-4(c)(3)). Logged as an interpretation.
5. **Caption.** The party column is closed by a rule (right and bottom) rather than a column of ")" marks used in the exemplar. This is a tier-2 convention choice (both are seen in N.D. Cal. filings); recorded as ACCEPTED.
6. **Case names are not italic in the sample.** The text layer of the exemplar has no italic markup, so the transcription is roman. The template does italicize `*...*` markdown, so future samples can carry italics.
7. **Overlay pairing.** The sample is a portion of the 29-page filing (pages 2 to 7, 17 to 18, 22 to 23 of the exemplar, with the lead-in, the caption and the signature from pages 1 and 23 to 24). Pages 6 and 10 of the overlay pair with exemplar pages that have little overlap because the sample skips pages (the text pairs with the page that shares most words). The overlay is a diagnostic, not a score.
8. **Paragraph numbers differ.** The sample numbers its allegations from 1 (the template numbers them). The filed paragraph numbers are not transcribed.
9. **Ragged right.** Body text is left-aligned, not justified. The exemplar's justification could not be read from the text layer; this is a tier-2/3 choice and is not asserted.
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and a `rules.md` in the court directory, and this doc-type folder is not that shape; the brief forbids touching `tools/`, so the gates were not run. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.
11. **Headings must fit one line.** `heading-line` asserts a single numbered line (its height is fixed at one pitch); a two-line heading fails the build with a message. A two-line count heading needs a shorter title or a template change.

## Review of the rendered pages (current PDF)

- Page 1: counsel on lines 1 to 7, court title on line 8 and 9, caption on lines 11 to 15, title and jury demand legend at the right. Footer: title and case number. No spill. Pass.
- Page 2: lead-in (unnumbered), INTRODUCTION heading, paragraphs 1 to 3; body text on the numbered lines. Pass.
- Pages 3 to 7: numbered paragraphs at 0.5 inch indent; THE PARTIES, JURISDICTION AND VENUE, DIVISIONAL ASSIGNMENT and FACTUAL BACKGROUND centered bold caps; the cause headings (FIRST CAUSE OF ACTION, the centered bold sub-heading) on line 1 and line 2 of page 7; no heading at the foot of a page. Pass.
- Page 8: REQUEST FOR RELIEF heading, WHEREFORE paragraph, item (a) with its wrapped lines. Pass.
- Page 9: items (b) to (l), line-aligned. Pass.
- Page 10: item (l) continues, item (m), DEMAND FOR JURY TRIAL heading with paragraph 35, the date, signature block (single-spaced, firm, "By: /s/" and the signer). Pass.

Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).
