# innd: complaint

Doc type: **complaint** in the United States District Court for the Northern District of Indiana (`innd`).
Folder: `courts/seventh-circuit/indiana/federal/northern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (sampled; 13 pages), plus `usage/FILED-EXAMPLE-complaint-2.pdf` (second filer, 16 pages). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-complaint.md`: the whole 13-page filing transcribed (caption, headings, 66 numbered paragraphs, lettered subparagraphs, prayer, jury demand, signature). |
| typeface | No face named by the rule: EB Garamond (vendored), per `docs/FONTS.md` ("No face named"). Embedded per `pdffonts`: EBGaramond Regular and Bold. See Known gaps 1. |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 13 pages, typst 0.15.0, vendored fonts only, no warnings (re-rendered 2026-10-15) |
| overlay | ok: `usage/OVERLAY-blackman-complaint.pdf` and `OVERLAY-blackman-complaint.txt` (rebuilt 2026-10-15) |
| pages reviewed | 13 of 13 (every page rasterized and viewed on the 2026-10-15 build) |

File names follow `CLAUDE.md` and the `tools/` defaults (`INPUT-` for the markdown, `OUTPUT-` for our render,
`OVERLAY-` for the comparison). The brief's shorter names (`<id>.md`, `<id>-overlay.pdf`) would not be read by
`tools/overlay.sh`, which takes its input names from the `OUTPUT-` convention.

## Governing rules

Primary sources. Sources checked on 2026-10-14:

- **N.D. Ind. L.R. 5-4(a)** (format of papers), text from the court's Local Rules compilation, `LocalRulesMaster2016Jan19(rev2).pdf`, at https://www.innd.uscourts.gov/sites/innd/files/LocalRulesMaster2016Jan19%28rev2%29.pdf, pp. 12. This is the most recent version I could retrieve. The court's current local-rules page (innd.uscourts.gov/local-rules) returned 404 to the fetch tool, and courtrules.net returned 403. **The current revision has not been checked; the rule text must be verified against the court's current rules before this template is treated as final.**
- **Fed. R. Civ. P. 10(a), (b)**, from https://www.law.cornell.edu/rules/frcp/rule_10 (amended Apr. 30, 2007, eff. Dec. 1, 2007), fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| L.R. 5-4(a)(1) | Plainly typewritten, printed, or clearly legible. | Typeset output; no rule needed. |
| L.R. 5-4(a)(2) | 8.5 × 11 inch pages. | `page-w`, `page-h` (`paper: "us-letter"`). |
| L.R. 5-4(a)(3) | At least 1-inch margins. | `margin = 1in` on all four sides. |
| L.R. 5-4(a)(4) | At least 12-point type in the body; at least 10-point in footnotes. | `type-size = 12pt`; `note-size = 10pt` for footnotes (no footnotes in this sample). |
| L.R. 5-4(a) (typeface) | No typeface is named. The rule sets only the 12-point and 10-point minimums above. | EB Garamond, the default in `docs/FONTS.md`; see Known gaps 1. |
| L.R. 5-4(a)(5) | Double spaced, except headings, footnotes and quoted material. | `pitch = 27.6pt` (two 13.8 pt single lines of 12 pt type); `body-leading = 1.65em`. Headings, caption, counsel and signature are single spaced. Measured on the render: body baselines 27.6 pt apart. |
| L.R. 5-4(a)(6) | Consecutively numbered pages. | Centered arabic footer on every page, page 1 included. |
| L.R. 5-4(a)(7) | A title on the first page. | `paper-title(meta)` under the caption: "CLASS ACTION COMPLAINT". |
| L.R. 5-4(a)(8) | Separate exhibit index if more than four exhibits. | Not in the sample (no exhibits). |
| L.R. 5-4(a)(9) | Filer's name, address, telephone, fax (if any), e-mail (except proposed orders and affidavits). | The signature block (`signature.counsel`) carries the counsel block. A fax line is not in the exemplar; add it when the firm has one. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | Court lines (`court`), division, `Case No.`, the party block, the title. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Each body chunk that is not a heading, list, unnumbered `^ ` chunk or prayer item is numbered by the template (`body-blocks`). Lists are lettered (a., b., ...). |

Not produced by this template (separate filings): the civil cover sheet (JS-44), the summons, the Rule 7.1
disclosure statement and any N.D. Ind. filing-fee form. None is part of the pleading.

## Layout

- Court lines and the division centered in bold at the top of page 1 (single spaced).
- Caption: party block left (3.2 in), closed by a right rule and a bottom rule; "v." between parties; designations indented. Right column: `Case No.: ...` and, when `jury_demand: true`, `JURY TRIAL DEMANDED`.
- Title: centered bold caps, after the caption.
- Body: first-line indent 0.5 in; numbered paragraphs `1.` onward; headings centered bold caps (level 1), centered bold (level 2, e.g. COUNT I and its parenthetical), bold left (level 3, e.g. "Plaintiff's Experience").
- Prayer items keep their capital letters (A., B., ...); the jury demand is an unnumbered paragraph.
- The signature block is kept on one page with the last body paragraph (`body-blocks(..., tail)`), so a signature never stands alone.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `case_number`; `court` (list of lines); `division` (optional); `caption.parties` (list of `{names: [...], designation}`; "v." is inserted between parties); `jury_demand` (bool); `title`; `signature` (`dated`, `party` (optional), `by`, `role` (optional), `counsel` (lines; `""` is a blank line)).
- Body chunks are separated by blank lines:
  - `# TEXT` is a level 1 heading (centered bold caps). `## TEXT` is a level 2 heading (centered bold). `### TEXT` is a level 3 heading (bold, left).
  - A list (`1.`, `-`) is lettered (a., b., ...) by the template.
  - A chunk starting with `^ ` is an unnumbered paragraph (lead-in, jury demand, class definitions set off from the text).
  - A chunk starting with a capital letter and a period (`A. `) is a prayer item: it keeps its letter.
  - Any other chunk is a numbered paragraph. Do not type the numbers into the sample.
- Not supported: tables, raw typst, italic footnotes (none in the sample). Footnote markers and definitions use the memorandum's `[^n]` syntax (see `../motion-brief/README.md`) and are typeset as real footnotes.

## Known gaps and open choices

1. **Font.** No typeface is named by N.D. Ind. L.R. 5-4(a) (checked 2026-10-15 against the 2016 local-rules compilation; see Governing rules), so the template keeps EB Garamond, the no-face default in `docs/FONTS.md`. The filers use Times New Roman, but the rules do not require it, so that is a tier-2 difference: EB Garamond at 12 pt has a smaller x-height than Times at 12 pt, and the text looks smaller than the exemplar. The 12-point minimum is met. If the court's current rules name a face, switch to that face's substitute from `docs/FONTS.md` (Liberation Serif for Times New Roman).
2. **Caption.** The party column is closed by a rule instead of the column of ")" marks used by the sampled filer. Both styles appear in N.D. Ind. filings (the second exemplar uses a different caption again); recorded as ACCEPTED.
3. **Paragraph numbering.** The template numbers from 1 and the sample's numbers are the filed ones. The sampled filing numbers 1–66 with no gaps; the template reproduces this.
4. **Run-in sub-items.** Paragraph 50 of the filing lists the DCSA purposes as (1)–(3) on separate lines. The sample runs them into the paragraph: the template has no sub-item form for "(1)" lists and the text is unchanged.
5. **Typos preserved.** The sample reproduces the filing as filed, including "ChagePoint", "Fed. R Civ. P.", "Fed. R. Civ 23(a)(4)" and "24-5-0.5-2" printed without its hyphen in the text layer (corrected to the statute's form). These are transcription choices, not template behaviour.
6. **Second exemplar not compared page by page.** The Nowak complaint is in `usage/` and its text layer and signature block were read, but it was not rendered side by side with our output. Tier-2 for the complaint therefore rests on the sampled filing and the rules; the second filer is a structural cross-check, not a page-level review.
7. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, not a doc-type folder, and the brief forbids touching `tools/`. Render, overlay and the page review above are the checks for this doc type.
8. **Current local rules unverified** (see Governing rules). The rule text is from the 2016 compilation.

## Review of the rendered pages (final build)

- Page 1: court lines, division, caption with party block and case number, `JURY TRIAL DEMANDED`, title, Introduction heading, paragraphs 1–3. Pass. The division line overlapped the second court line in the 2026-10-14 build (it sat outside the stack in `cover()`, with no gap); it is now in the same single-spaced stack and checked at 110 dpi.
- Page 2: Parties, Jurisdiction and Venue, paragraphs 4–8. Pass.
- Page 3: Factual Allegations, paragraphs 9–15. Pass.
- Page 4: "Plaintiff’s Experience" (level 3, bold left), paragraphs 17–24. Pass.
- Page 5: paragraphs 24–31, CLASS ACTION ALLEGATIONS heading, the class definition as unnumbered `^ ` paragraphs. Pass.
- Page 6: paragraphs 32–35 with lettered items a–e (the list is double spaced, the items do not run into the next paragraph). Pass.
- Page 7: paragraphs 36–41. Pass.
- Page 8: paragraphs 42–46, CAUSES OF ACTION, COUNT I and its parenthetical (level 2, centered). Pass.
- Page 9: paragraphs 47–53, COUNT II and its long parenthetical wrapping onto two centered lines. Pass.
- Page 10: paragraphs 54–59, lettered items a–c in paragraph 56. Pass.
- Page 11: paragraphs 59 (continued)–66, COUNT III. Pass.
- Page 12: PRAYER FOR RELIEF with items A–G. Pass.
- Page 13: JURY DEMAND (unnumbered) with the signature block (Dated, Respectfully submitted, party, By, role, counsel). No page holds the signature alone. Pass.

Earlier builds had two defects, both fixed and re-rendered: (a) paragraph blocks did not carry the leading after their last line, so each paragraph ran into the next (fixed: `below: body-leading` on every block); (b) the cover's court lines were set at zero spacing and overlapped (fixed: single spacing); and the signature block once stood alone on page 13 (fixed: kept with the last body chunk).

Overlay: `usage/OVERLAY-blackman-complaint.txt` pairs our pages 1–13 one to one with filed pages 1–13 (word overlap 47–95%; the overlap falls on the later pages because our page breaks drift from the filing's). The overlay is a diagnostic, not a score.

## Engines

DOCX (`docx/`): pandoc on `docx/reference.docx` (built by `sh docx/build-reference.sh docx/reference.docx`) with the filter `docx/innd.lua`. Output: `usage/OUTPUT-complaint.docx`.

- Matches the typst form: EB Garamond 12 pt body, exact 27.6 pt double line pitch, 0.5 in first-line indent, 1 in margins on letter paper, 10 pt single-spaced footnotes, 13.8 pt single lines in the caption and signature, centered page-number footer, numbered paragraphs counted in the filter, "a." lettered lists, "A." prayer items, caption table with a right and bottom rule on the party column.
- Differs or unverified: paragraph gap (19.8 pt) is set as space-after; the signature block is a table, so it is not kept on one page with the last paragraph as typst does (no keep-with-next); the numbered-paragraph tab stop (1 in) approximates typst's label gap; table border weights and cell padding are not compared against the typst layout.
- BLOCKED on this box: the `.docx.pdf` (LibreOffice conversion) was not produced because `soffice` is not installed. No page was rendered or reviewed, so no Gate 0/1 result exists for docx. Checked: the `.docx` zip is intact and every XML part is well-formed. Word and LibreOffice open-without-repair is not verified.
- No table of contents or table of authorities in this doc type, so no field update is needed.
