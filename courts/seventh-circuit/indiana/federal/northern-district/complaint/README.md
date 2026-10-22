# innd: complaint

Doc type: **complaint** in the United States District Court for the Northern District of Indiana (`innd`).
Folder: `courts/seventh-circuit/indiana/federal/northern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (sampled; 13 pages), plus `usage/FILED-EXAMPLE-complaint-2.pdf` (second filer, 16 pages). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-complaint.md`: the whole 13-page filing transcribed (caption, headings, 66 numbered paragraphs, lettered subparagraphs, prayer, jury demand, signature). |
| typeface | No face named by the rule: Times New Roman (vendored), the house standard (`docs/FONTS.md`), in typst and docx alike. Embedded per `pdffonts`: Times New Roman regular and bold. See Known gaps 1. |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 16 pages, typst 0.15.0, vendored fonts only, no warnings (re-rendered 2026-10-22, fb-595.68.28); docx `usage/OUTPUT-complaint.docx` and `.docx.pdf`, 16 pages |
| overlay | ok: `usage/OVERLAY-blackman-complaint.pdf` and `OVERLAY-blackman-complaint.txt` (rebuilt 2026-10-15) |
| pages reviewed | 16 of 16, typst and docx (every page rasterized and viewed on the 2026-10-22 build) |

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
| L.R. 5-4(a) (typeface) | No typeface is named. The rule sets only the 12-point and 10-point minimums above. | Times New Roman, the house standard in `docs/FONTS.md`; see Known gaps 1. |
| L.R. 5-4(a)(5) | Double spaced, except headings, footnotes and quoted material. | `pitch-body = 27.6pt` (two 13.8 pt single lines of 12 pt type), exact line boxes on the shared cross-engine model (`lib/typst/xengine.typ`); 19.8 pt between paragraphs (`para-gap`). Headings, caption, counsel and signature are single spaced. Measured on the render: body baselines 27.6 pt apart. |
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
- Body: numbered paragraphs `1.` onward, the number at the 0.5 in indent in a 0.5 in box, the text from 1 in; lists lettered `a.` at 0.5 in, their lines hanging at 1 in; headings centered bold caps (level 1), centered bold (level 2, e.g. COUNT I and its parenthetical), bold left (level 3, e.g. "Plaintiff's Experience").
- Prayer items keep their capital letters (A., B., ...); the jury demand is an unnumbered paragraph.
- The signature block is kept on one page with the last body paragraph (the last chunk is kept whole and with the signature), so a signature never stands alone.

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

1. **Font.** No typeface is named by N.D. Ind. L.R. 5-4(a) (checked 2026-10-15 against the 2016 local-rules compilation; see Governing rules), so the template sets Times New Roman, the house standard in `docs/FONTS.md` and the filers' face. The 12-point minimum is met.
2. **Caption.** The party column is closed by a rule instead of the column of ")" marks used by the sampled filer. Both styles appear in N.D. Ind. filings (the second exemplar uses a different caption again); recorded as ACCEPTED.
3. **Paragraph numbering.** The template numbers from 1 and the sample's numbers are the filed ones. The sampled filing numbers 1–66 with no gaps; the template reproduces this.
4. **Run-in sub-items.** Paragraph 50 of the filing lists the DCSA purposes as (1)–(3) on separate lines. The sample runs them into the paragraph: the template has no sub-item form for "(1)" lists and the text is unchanged.
5. **Typos preserved.** The sample reproduces the filing as filed, including "ChagePoint", "Fed. R Civ. P.", "Fed. R. Civ 23(a)(4)" and "24-5-0.5-2" printed without its hyphen in the text layer (corrected to the statute's form). These are transcription choices, not template behaviour.
6. **Second exemplar not compared page by page.** The Nowak complaint is in `usage/` and its text layer and signature block were read, but it was not rendered side by side with our output. Tier-2 for the complaint therefore rests on the sampled filing and the rules; the second filer is a structural cross-check, not a page-level review.
7. **Gate scripts.** Since fb-595.68.28: `sh tools/check.sh <this folder>` and `--engine docx` both exit 0 (typst 9, docx 13 checks passed, 0 failed).
8. **Current local rules unverified** (see Governing rules). The rule text is from the 2016 compilation.

## Review of the rendered pages (final build)

Gate 2 on the 2026-10-22 build (fb-595.68.28), all 16 pages of the typst and the docx render rasterized at 50 dpi and viewed; the docx breaks every line and page as typst does (XENG-001..003), so one row serves both.

| Page | What it is | Finding |
|---|---|---|
| 1 | Court lines, division, caption (party column ruled at right and foot, `Case No.:`, `JURY TRIAL DEMANDED`), title, the lead-in, INTRODUCTION, paragraphs 1-2 | OK |
| 2 | Paragraphs 3-7, PARTIES, JURISDICTION AND VENUE | OK |
| 3 | Paragraphs 7 (end)-12, FACTUAL ALLEGATIONS | OK |
| 4 | Paragraphs 12 (end)-17, "Plaintiff's Experience" (level 3, bold at the margin) | OK |
| 5 | Paragraphs 18-24 | OK |
| 6 | Paragraphs 24 (end)-27, CLASS ACTION ALLEGATIONS, the class definitions as unnumbered `^ ` paragraphs | OK |
| 7 | Paragraphs 28-34 | OK |
| 8 | Items a-e of paragraph 34 (lettered, hanging at 1 in), paragraphs 35-36 | OK |
| 9 | Paragraphs 37-41 | OK |
| 10 | Paragraphs 41 (end)-44, CAUSES OF ACTION, COUNT I and its parenthetical (centered) | OK |
| 11 | Paragraphs 45-50, COUNT II with its parenthetical | OK |
| 12 | Paragraphs 51-55 | OK |
| 13 | Paragraph 56 with items a-c, paragraphs 57-59 | OK |
| 14 | Paragraphs 59 (end)-64, COUNT III | OK |
| 15 | Paragraphs 65-66, PRAYER FOR RELIEF, items A-D | OK |
| 16 | Items E-G, JURY DEMAND, the signature block (Dated, Respectfully submitted, party, By, role, counsel), kept with the jury demand | OK |

The render is 16 pages (13 before the port): the filed exemplars are 13 and 16 pages; N.D. Ind. sets no page limit for a complaint.

## Engines

DOCX (`docx/`): `reference.xml` (the Word styles: `base="xengine"` in the typst face `{font}`, Times New Roman, 12 pt, 552-twip body and 276-twip single line boxes, headings 552 above and 396 below, 10 pt footnotes in 230-twip lines, Body Note and List Note for a paragraph that carries a footnote, the 12 pt page-number footer 0.5 in above the page edge; `fb render` builds the reference document from it) and `innd.lua` (reads the sample chunk by chunk as the typst template does and writes the cover, caption, numbered paragraphs, lists, prayer items, headings, quotations and signature as WordprocessingML on `lib/docx/xengine.lua`). No script: `fb render` runs pandoc with the filter and packs the archive (fb-595.68.28; were `build-reference.sh` and a committed `reference.docx` naming EB Garamond, which failed DEF-FONT-002). Output: `usage/OUTPUT-complaint.docx` and `.docx.pdf` (LibreOffice conversion, 16 pages).

- Cross-engine (fb-595.68.28): typst and docx share the layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`). `check.sh --engine docx`: XENG-001..003 PASS (16 = 16 pages, every line breaks after the same word); `params.cross_engine: gate` in `eval.yaml`. The sample has no footnote; a footnote was checked once with a scratch sample (both engines 16 pages, every line alike).
- The `.docx` converts in LibreOffice without error (the check's conversion); not opened in Word.
- No table of contents or table of authorities in this doc type, so no field update is needed.
