# Supreme Court of the United States: brief on the merits

Doc type `merits-brief`: the brief of a petitioner or appellant on the merits (Rule 24.1). The respondent's brief (Rule 24.2) and the reply brief (Rule 24.4) are not built here; the template lays out the same booklet but no respondent or reply metadata is modeled.

## Governing rules

Source: Rules of the Supreme Court of the United States, adopted February 17, 2026, effective March 16, 2026. Primary text: https://www.supremecourt.gov/filingandrules/2026RulesoftheCourt_WEB.pdf (read in full on 2026-10-14). Word-limit and cover-color chart: https://www.supremecourt.gov/casehand/BookletFormatSpecificChart2026.pdf (effective March 16, 2026; read on 2026-10-14).

| Rule | Requirement | Where it lives in the template |
|---|---|---|
| 33.1(a) | 6 1/8 by 9 1/4 inch booklet | `booklet-width`, `booklet-height` (441 x 666 pt) |
| 33.1(b) | Century-family face, 12-point text, 2-point or more leading, 10-point footnotes | `body-size`, `note-size`, `leading-value` (2.5 pt), `font-family` (**see gap 1**) |
| 33.1(c) | Margins at least 3/4 inch; text field, footnotes included, not over 4 1/8 by 7 1/8 inches | `margin-x` 1 in, `margin-top` 1 in, `margin-bottom` 1.125 in: text field exactly 4.125 x 7.125 in; asserted in the template |
| 33.1(d) | Word limit; limits exclude QP, parties, TOC, TOA, counsel list, appendix; include footnotes | `count-words` counts the body markdown including footnote text; asserted against `word-limit` |
| 33.1(e) | Cover color: light blue for a petitioner's merits brief (chart) | not rendered: paper-copy color (**see gap 4**) |
| 33.1(g)(v) | 13,000 words for a brief on the merits for a petitioner or appellant | `word-limit = 13000` |
| 33.1(h) | Certificate of word count, separate from the brief | `word-certificate` (last page; **see gap 5**) |
| 24.1(a) | Questions presented on the first page after the cover; nothing else on that page | `questions-page` |
| 24.1(b) | Parties and stock ticker symbols; amended disclosure under Rule 29.6 | `parties-page` (text from frontmatter) |
| 24.1(c) | TOC and TOA if the brief exceeds 1,500 words | `toc-section`, `toa-section` (always generated) |
| 24.1(e)-(j) | Jurisdiction, provisions, statement of the case, summary, argument, conclusion | body markdown; the sample carries an excerpt (see below) |
| 24.1(f) | Verbatim provisions set out in the brief or an appendix | body markdown (no appendix generated) |
| 34.1(a)-(f) | Cover order: docket number, court, caption, nature of proceeding, title, counsel of record with notation "Counsel of Record" | `cover` |
| 34.1(g) | Nothing smaller than 11-point except identification of counsel | `counsel-size` 10 pt, the only smaller type |
| 34.2 | TOC and TOA, every page listed, no "passim", ranges allowed | `toa-section` lists every page; no passim |
| 34.3 | Counsel's name at the close of the body | `signature-block` |

## Layout

- `typst/main.typ` entry; `typst/merits-brief.typ` the template (content-agnostic; all numbers are named parameters at the top).
- `samples/INPUT-in-re-grand-jury.md` the sample (markdown with a YAML frontmatter). Its contract, in brief:
  - frontmatter: `docket`, `caption` (lines), `proceeding`, `brief_title`, `counsel` (groups of `names` and `lines`; put `*Counsel of Record*` as a name line under the counsel of record), `questions`, `parties`, optional `disclosure`, `authorities` (key: `{kind, name, cite}`; `cite` optional; kinds `case`, `constitution`, `statute`, `regulation`, `rule`, `other`), `signature` (`signer`, `lines`), optional `date`.
  - body: `# HEADING` is a centered bold section heading; `## I. Point` and `### A. Subpoint` are hanging-indent headings. Type the numbers yourself (not generated). Headings are typed in capitals by the author.
  - citations: `[*Upjohn Co. v. United States*, 449 U.S. 383, 389 (1981)](toa:upjohn)`. Every `toa:` key must be in `authorities`, and every authority must be cited (the template panics otherwise).
  - footnotes `[^n]` and `[^n]: text`; block quotations `> text`; ordinary lists.
- The sample is named `INPUT-…` / `OUTPUT-…` / `OVERLAY-…` so `tools/render.sh` and `tools/overlay.sh` read and write it by default.

## How it was built

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick
sh tools/render.sh courts/supreme-court-of-the-united-states/merits-brief samples/INPUT-in-re-grand-jury.md
sh tools/overlay.sh courts/supreme-court-of-the-united-states/merits-brief in-re-grand-jury
```

`render.sh` ran with `--ignore-system-fonts` and produced no typst warnings. Output: `samples/OUTPUT-in-re-grand-jury.pdf`, 13 pages at 441 x 666 pt. Fonts embedded: EBGaramond Regular, Bold, Italic only.

## Exemplar

- `exemplars/FILED-EXAMPLE-in-re-grand-jury-21-1397-merits-brief.pdf`: "Brief for the Petitioner", *In re Grand Jury*, No. 21-1397, filed by the petitioner (counsel of record Daniel B. Levin, Munger, Tolles & Olson LLP). 53 pages. Text layer present. Set in New Century Schoolbook (embedded Type 1C), the Rule 33.1(b) family. Source and fetch record in `exemplars/SOURCE.md`.
- Only one filer. A second merits brief (a respondent's, or a different petitioner's) was not located, so the tier-2 comparison is against one exemplar. This is a gap against the two-or-three-filers bar in the tier rules.

Exemplar format facts (for comparison, not copied): the e-filed PDF is US Letter (612 x 792 pt) with the booklet-proportioned text block centered on the page. The template renders the booklet size itself, as Rule 33.1(a) requires.

## Overlay (`samples/OVERLAY-in-re-grand-jury.pdf` / `.txt`)

Red is our render, blue is the filed exemplar, black is agreement. The page map (ours to filed, by word overlap):

```
ours p.1  filed p.1   85.2%   cover
ours p.2  filed p.2  100.0%   questions presented
ours p.3  filed p.3  100.0%   parties / disclosure
ours p.4  filed p.4   60.4%   TOC (exemplar's TOC is the filed one; ours is generated)
ours p.5  filed p.8   19.2%   TOA (our TOA lists only the sample's authorities)
ours p.6  filed p.12  91.6%   Opinions below / jurisdiction / Rule 501
ours p.7  filed p.13  61.5%   introduction
ours p.8  filed p.16  53.1%   statement
ours p.9  filed p.17  60.9%   statement, footnotes
ours p.10 filed p.19  58.0%   statement, summary
ours p.11 filed p.24  55.7%   summary, argument I (point heading)
ours p.12 filed p.1   24.6%   conclusion + signature (no matching filed page: sample ends early)
ours p.13 filed p.1   23.1%   certificate (no matching filed page)
```

The overlay is a diagnostic, not a score. The low pairings on pages 5, 12 and 13 are expected: the sample is an excerpt, its TOA covers only the authorities transcribed, and the certificate and signature are generated.

## Gate 2: page-by-page visual review

Every page of `OUTPUT-in-re-grand-jury.pdf` was rendered at 60 dpi and looked at, after the final change to the template (pages 1-13).

- p.1 cover: docket top, court, caption, proceeding, title, three counsel groups in two columns at the foot. Fits on one page. Accepted.
- p.2 questions presented: alone on the page, as Rule 24.1(a) requires. Accepted.
- p.3 parties and disclosure: accepted.
- p.4 TOC: entries with dot leaders and right-hand page numbers; Question Presented, Parties, Corporate Disclosure, body headings, indented argument point. Fixed in review: entries had printed the page number twice.
- p.5 TOA: cases, statutes, rules, page lists. Accepted. Its entries reflect only the sample's authorities.
- p.6 (body 1) Opinions below, Jurisdiction, Federal Rule of Evidence heading, block quotation with list. Fixed in review: the heading hyphenated ("IN-VOLVED") and justified-spread; both now off. Accepted.
- p.7 (body 2) Introduction, justified body text, first-line indent. Accepted.
- p.8 (body 3) Statement, citations italic, links; footnote 2 at the foot. Accepted.
- p.9 (body 4) Statement continues; footnote 2 text. Accepted.
- p.10 (body 5) Statement end, Summary heading. Accepted.
- p.11 (body 6) Summary end, Argument heading, point I. heading with hanging indent, Conclusion heading. Accepted.
- p.12 (body 7) Conclusion, "Respectfully submitted", counsel name block, date. Accepted. Note: the conclusion's last line and the signature share this page.
- p.13 certificate of compliance (unnumbered, separate page). Accepted for layout; the count is the sample's count (gap 5).

## Open tier-1 gaps (BLOCKED items)

1. **Font: BLOCKED (no Century-family face is vendored).** Rule 33.1(b) requires New Century Schoolbook, Century Schoolbook, or Century Expanded. Only EB Garamond is vendored under `fonts/`, and `fonts/` is out of scope for this box. The template sets EB Garamond as a stand-in, so the typeface does not meet the rule. The fix needs a Century-family font vendored under `fonts/` (for example TeX Gyre Schola or C059, both with redistributable licenses), then `font-family` changes to that family and the README and checks are updated. No other tier-1 item depends on this.
2. **Exemplar count: one filer.** Tier-2 conventions were judged against one filed brief, not two or three. A second exemplar is needed for the tier-2 bar.
3. **Sample is an excerpt.** The sample carries about 2,270 words of body text (opinions below through the conclusion, with the Summary and the start of Argument I transcribed, the rest omitted), not the full brief. The full brief is about 13,000 words. The TOA lists only the authorities transcribed.
4. **Cover color (Rule 33.1(e)) not rendered.** Light blue for a petitioner's merits brief, per the chart. It applies to the paper copy; the PDF has no color.
5. **Certificate of word count.** Rule 33.1(h) requires the certificate to be separate from the brief and to state the word count the filer's word processor reports. The template's count is the template's mechanical count of the sample body (about 2,270), so it is not a filing certificate. The template prints the certificate on its own last page; the filer prints it on a separate sheet.
6. **Appendix (Rule 24.1(f)) not generated.** Verbatim provisions are cited in the body, not set out in an appendix.
7. **Keep-with-next for signatures.** The signature block is kept whole, but a short last paragraph is not kept with it.

## Not covered by this doc type

- Respondent's brief (Rule 24.2) and reply brief (Rule 24.4): different cover colors and word limits (chart); not built.
- Amicus briefs (Rule 37), appendices, and the 8 1/2 by 11 format (Rule 33.2).
