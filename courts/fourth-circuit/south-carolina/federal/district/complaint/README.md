# District Court, D. South Carolina (`scd`): complaint

Doc type **complaint**, folder `courts/fourth-circuit/south-carolina/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-miller-v-waffle-house-2-26-cv-04339-complaint.pdf` (1 filer: plaintiff's counsel; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-miller-complaint.md` (the full 10-page filing transcribed: caption, all numbered paragraphs, headings, the three causes of action, prayer, jury demand, signature block) |
| render | ok: `samples/OUTPUT-miller-complaint.pdf`, 8 pages, typst 0.15.0, vendored Liberation Serif only (embedded per `pdffonts`), no warnings |
| overlay | ok: `samples/OVERLAY-miller-complaint.pdf` and `samples/OVERLAY-miller-complaint.txt` |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed after the last template change) |
| tier-1 font (L.R. 1.05(B)) | Met: Times New Roman (one of the three faces the rule names) set as its metric-compatible substitute **Liberation Serif** (see Known gaps) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D.S.C. Local Civ. Rule 1.05(A) | Minimum one-inch margins on all sides. | `margin` in `typst/scd-complaint.typ` |
| D.S.C. Local Civ. Rule 1.05(B) | Times New Roman, Arial or Courier New. | `font-family` = `"Liberation Serif"` (Times New Roman substitute, `docs/FONTS.md`) |
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
sh tools/render.sh $D samples/INPUT-miller-complaint.md     # -> samples/OUTPUT-miller-complaint.pdf
sh tools/overlay.sh $D miller-complaint                      # -> samples/OVERLAY-miller-complaint.{pdf,txt}
```

File names follow the tools (`INPUT-`, `OUTPUT-`, `OVERLAY-`), not the `<id>.pdf` / `<id>-overlay.pdf` form in the brief, because `tools/overlay.sh` reads `OUTPUT-<id>.pdf` and writes `OVERLAY-<id>.{pdf,txt}`.

## What the overlay shows

Red is our render, blue is the filed exemplar, black is where they agree. Pages are paired by shared words, not by index: the map in `OVERLAY-miller-complaint.txt` pairs our pages 1 to 8 with filed pages 1, 2, 3, 5, 6, 7, 8 and 9. Word overlap is 45% to 91% per page. That is expected: the filed exemplar is 10 pages and our sample is 8, and the sample's line breaks differ from the filing's. The filed complaint embeds Times New Roman (`pdffonts`), the face Liberation Serif substitutes for, so the two are now the same face in different files. The overlay is a diagnostic for layout and structure, not a score.

## Visual review (Gate 2)

Pages 1 through 8 were rendered at 60 dpi and viewed. Findings during review, all fixed:

| Page | Finding | Fix |
|---|---|---|
| 1 | Paragraphs after the caption and after a heading lost their first-line indent. | `first-line-indent: (amount: para-indent, all: true)` |
| 1-7 | Section headings (THE PARTIES, FIRST CAUSE OF ACTION) rendered left-aligned in a larger size. | Full-width heading blocks, heading text at the body size. |
| 1 | Line pitch was about 19 pt, which is not double spacing. | `double-leading` raised to 1.6em (about 27 pt). |
| 8 | Prayer, jury demand and signature block are on the last page and all fit. | none needed |

Font change (EB Garamond to Liberation Serif, 2026-10-14): all 8 pages re-rendered and viewed at 60 dpi; no new findings.

Open findings: none for layout. The caption's single-spaced block uses stacked lines (about 18.6 pt pitch), which reads correctly and is not a rule issue.

## Known gaps

1. **Font (L.R. 1.05(B)): resolved.** The rule names Times New Roman, Arial or Courier New. This template sets Times New Roman, using `Liberation Serif` (SIL OFL 1.1, vendored in `fonts/liberation-serif/`, metric-compatible per `docs/FONTS.md`). Arial and Courier New were not chosen. The page count is unchanged by the switch (8 pages, from the EB Garamond baseline). The render uses `--ignore-system-fonts`, so no system font can stand in for it.
2. **One exemplar, one filer.** Tier 2 is judged against one filed complaint (plaintiff's counsel, Ehman Law, Charleston Division), not the 2 or 3 the eval loop asks for. The brief asks for one exemplar per doc type; a second complaint filer would tighten tier 2.
3. **Not checked by the court tools.** This folder has no `checks.yaml`, so `tools/check.sh` has not been run here. The render has no typst warnings (`tools/render.sh` fails on warnings).
4. **Page-count and format checks are manual.** The template does not enforce a page limit (none applies to a complaint) or the one-inch margin beyond setting it.

## Exemplar search (for the record)

CourtListener search API, `court=scd`, `type=rd`, query `"COMPLAINT against" "Title VII"`, filed after 2024-01-01, `is_available=true`. Candidates downloaded; page 1 text checked for each: Miller v. Waffle House (10 pp., selected; counsel-filed, text-based, standard caption), Snider v. Mercedes-Benz Vans (8 pp.; caption not in the standard D.S.C. form), Dover v. Charleston County School District (12 pp.; not read past page 1), Brown v. Georgetown Hospital System (15 pp., Florence Division; not read past page 1). Selection criteria: counsel-filed, text-based PDF, 8 to 14 pages, standard caption.
