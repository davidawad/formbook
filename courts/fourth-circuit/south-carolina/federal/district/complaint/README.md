# District Court, D. South Carolina (`scd`): complaint

Doc type **complaint**, folder `courts/fourth-circuit/south-carolina/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer: plaintiff's counsel; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (the full 10-page filing transcribed: caption, all numbered paragraphs, headings, the three causes of action, prayer, jury demand, signature block) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 8 pages, typst 0.15.0, Times New Roman only (embedded per `pdffonts`), no warnings |
| overlay | ok: `usage/OVERLAY-miller-complaint.pdf` and `usage/OVERLAY-miller-complaint.txt` |
| pages reviewed | 8 of 8 on the earlier Liberation Serif render (every page rendered at 60 dpi and viewed) |
| tier-1 font (L.R. 1.05(B)) | Met: **Times New Roman** (one of the three faces the rule names), set in the face itself (the pinned files of `docs/FONTS.md` rule 1; Liberation Serif only as fallback) on typst and docx (see Known gaps) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D.S.C. Local Civ. Rule 1.05(A) | Minimum one-inch margins on all sides. | `margin` in `typst/scd-complaint.typ` |
| D.S.C. Local Civ. Rule 1.05(B) | Times New Roman, Arial or Courier New. | `font-family` = `("Times New Roman", "Liberation Serif")` |
| D.S.C. Local Civ. Rule 1.05(C) | Minimum 12-point type for caption, text and footnotes. | `type-size` |
| D.S.C. Local Civ. Rule 1.05(D) | Only page numbers and document identification may be in margins or smaller than 12 pt. | page number only, centered at the foot |
| D.S.C. Local Civ. Rule 1.05(E) | Double space text, except indented quotations and footnotes. | `double-leading` (calibrated to about 27 pt baseline pitch at 12 pt) |
| FRCP 8(a) | Short and plain statement of jurisdiction, claim and demand for relief. | Sample content only; the template does not number or order sections |
| FRCP 10(a) | Caption: court name, title of the action with all parties, case number, designation of the paper. | `court-heading`, `caption`, document title |
| FRCP 10(b) | Claims in numbered paragraphs, each limited as far as practicable to one set of circumstances. | Sample numbers its paragraphs literally (`1\.`); the template keeps first-line indent on every paragraph |
| FRCP 11(a) | Every filed paper is signed by an attorney of record, with name, address, phone and email. | `signature` block (`s/` signature, lines from frontmatter) |

Sources: D.S.C. Local Civil Rules (February 22, 2023), https://www.scd.uscourts.gov/Rules/Civil%20Rules%20-%20Current.pdf, fetched 2026-10-14; Local Civ. Rule 1.05 text read from that PDF with pdftotext. The same text appears in the May 15, 2017 edition at https://www.scd.uscourts.gov/Rules/2017/Civil%20Rules%20-%20May%2015,%202017.pdf. The FRCP rules are cited from the rule text as known and were not re-fetched in this session; verify before relying on the pin cites.

## Template and sample contract

- `typst/main.typ` reads the sample named by `--input sample=` and calls `scd-complaint(meta, body)`.
- `typst/scd-complaint.typ` holds all rule parameters at the top, the caption, the signature block and the heading styles. Nothing case-specific and no coordinates measured off the exemplar.
- Frontmatter: `court` (list of lines), `case_number` (blank pre-filing; the exemplar's caption shows "CASE NO.:" with the number left blank), `parties` (each `{text, indent}`), `doc_title`, `signature` (`dated`, `signer`, `lines`). Body: markdown. `#` is the document title line if used (the template already prints the title, so the sample omits it); `##` is a section heading (centered, bold capitals); `###` is a cause-of-action subtitle (centered, bold).

Render and overlay (from the repo root; the doc-type folder is the court dir):

```sh
export PATH="$HOME/tb/bin:$PATH"
D=courts/fourth-circuit/south-carolina/federal/district/complaint
sh tools/render.sh $D usage/INPUT-complaint.md     # -> usage/OUTPUT-complaint.typst.pdf
sh tools/overlay.sh $D miller-complaint                      # -> usage/OVERLAY-miller-complaint.{pdf,txt}
```

File names follow the tools (`INPUT-`, `OUTPUT-`, `OVERLAY-`), not the `<id>.pdf` / `<id>-overlay.pdf` form in the brief, because `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.{pdf,txt}`.

## What the overlay shows

Red is our render, blue is the filed exemplar, black is where they agree. Pages are paired by shared words, not by index: the map in `OVERLAY-miller-complaint.txt` pairs our pages 1 to 8 with filed pages 1, 2, 3, 5, 6, 7, 8 and 9. Word overlap is 45% to 91% per page. That is expected: the filed exemplar is 10 pages and our sample is 8, and the sample's line breaks differ from the filing's. The filed complaint embeds Times New Roman (`pdffonts`), the face Liberation Serif substitutes for; the map above was made on the earlier Liberation Serif render, and the template now sets Times New Roman itself. The overlay is a diagnostic for layout and structure, not a score.

## Visual review (Gate 2)

Pages 1 through 8 of the earlier render (EB Garamond, then Liberation Serif; before fb-595.68) were rendered at 60 dpi and viewed. Findings during review, all fixed:

| Page | Finding | Fix |
|---|---|---|
| 1 | Paragraphs after the caption and after a heading lost their first-line indent. | `first-line-indent: (amount: para-indent, all: true)` |
| 1-7 | Section headings (THE PARTIES, FIRST CAUSE OF ACTION) rendered left-aligned in a larger size. | Full-width heading blocks, heading text at the body size. |
| 1 | Line pitch was about 19 pt, which is not double spacing. | `double-leading` raised to 1.6em (about 27 pt). |
| 8 | Prayer, jury demand and signature block are on the last page and all fit. | none needed |

Font change (EB Garamond to Liberation Serif, 2026-10-14): all 8 pages re-rendered and viewed at 60 dpi; no new findings.

Open findings: none for layout. The caption's single-spaced block uses stacked lines (about 18.6 pt pitch), which reads correctly and is not a rule issue.

## Known gaps

1. **Font (L.R. 1.05(B)): resolved.** The rule names Times New Roman, Arial or Courier New. This template sets Times New Roman itself (the pinned files of `docs/FONTS.md` rule 1), with `Liberation Serif` (SIL OFL 1.1, vendored in `fonts/liberation-serif/`) only as fallback; it used Liberation Serif as the substitute before. Arial and Courier New were not chosen. The page count stayed at 8 pages through both switches (from the EB Garamond baseline). The render uses `--ignore-system-fonts`, so no system font can stand in for it.
2. **One exemplar, one filer.** Tier 2 is judged against one filed complaint (plaintiff's counsel, Ehman Law, Charleston Division), not the 2 or 3 the eval loop asks for. The brief asks for one exemplar per doc type; a second complaint filer would tighten tier 2.
3. **Default checks only.** This folder has no `eval.yaml` or `checks.yaml`; `tools/check.sh` runs the default checks (`data/checks-default.yaml`) and its stamps pass (`usage/.check-typst.txt`, `usage/.check-docx.txt`: PASS). The render has no typst warnings (`tools/render.sh` fails on warnings).
4. **Page-count and format checks are manual.** The template does not enforce a page limit (none applies to a complaint) or the one-inch margin beyond setting it.

## Exemplar search (for the record)

CourtListener search API, `court=scd`, `type=rd`, query `"COMPLAINT against" "Title VII"`, filed after 2024-01-01, `is_available=true`. Candidates downloaded; page 1 text checked for each: Miller v. Waffle House (10 pp., selected; counsel-filed, text-based, standard caption), Snider v. Mercedes-Benz Vans (8 pp.; caption not in the standard D.S.C. form), Dover v. Charleston County School District (12 pp.; not read past page 1), Brown v. Georgetown Hospital System (15 pp., Florence Division; not read past page 1). Selection criteria: counsel-filed, text-based PDF, 8 to 14 pages, standard caption.

## Engines

typst (`typst/`) is the reference. The docx engine (`docx/`) was built to its form and every page was compared with the typst page.

| Engine | Output (`usage/`) | Status |
|---|---|---|
| typst | `OUTPUT-complaint.typst.pdf` (8 pp.) | reference |
| docx | `OUTPUT-complaint.docx` and `OUTPUT-complaint.docx.pdf` (9 pp.) | ok: LibreOffice converts it without error; all 9 pages of the `.docx.pdf` viewed at 60 dpi, set beside the typst pages |

```sh
sh tools/render.sh --engine docx courts/fourth-circuit/south-carolina/federal/district/complaint usage/INPUT-complaint.md
```

- *Build:* `fb render --engine docx` builds the reference document from `docx/reference.xml` (styles, US Letter, 1-inch margins, centered PAGE field in the footer; extracted from the former `make-reference.sh` output by `fb docx-reference --extract`, which retired that script, and set in the typst face as `{font}`), then runs pandoc with `docx/scd-complaint.lua`, which writes the court heading, caption table, document title and signature table from the frontmatter. No `eval.yaml` or `checks.yaml`.
- *Font:* declared as Times New Roman (`{font}`, the typst template's face, which L.R. 1.05(B) names); `pdffonts` on `usage/OUTPUT-complaint.docx.pdf` shows only Times New Roman. (The earlier docx PDF, made where LibreOffice mapped Times New Roman to Liberation Serif, showed only LiberationSerif.)
- *Matches typst:* 12 pt type; 1-inch margins; page number centered at the foot; court heading in capitals; the caption (parties with their indents, the column of ")" marks, CASE NO.) at the typst row pitch (about 18.7 pt); the title; headings (levels 1 and 2 bold, centered, capitals; level 3 bold, centered); half-inch first-line indent on body paragraphs; the signature block.
- *Differs:*
  - Body pitch: Word's double (2.0 times the 13.8 pt single line, 27.6 pt) against typst's 27.06 pt. The difference adds up to about a line a page, so the docx runs to 9 pages against typst's 8 and page breaks differ from page 2 on. The complaint has no page limit. Double spacing is kept at Word's definition rather than set to an exact 27.06 pt.
  - Single lines (court heading, signature block) are Word's 13.8 pt; typst's are tighter (about 10 pt for the court heading). The docx reads more openly.
  - Page 2 of the docx keeps "STATEMENT OF FACTS" with paragraph 9 and moves them to page 3; typst keeps the heading at the foot of page 2.
- *Not verified:* opening in Microsoft Word (no Word on this box). The `.docx` is a valid zip with well-formed XML parts (`unzip -tq`, `xmllint --noout`), and LibreOffice converts it without a conversion error.
- *BLOCKED:* none. Only the default checks run on the docx (gap 3); the review below the build is by eye.
