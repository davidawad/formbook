# txdistrict-travis: proposed-order

Doc type `proposed-order` for the civil district courts of Travis County, Texas: a proposed order (or a signed order) as its own paper. Template: `typst/txdistrict-travis-proposed-order.typ` over `/lib/typst/txdistrict-travis-common.typ` (caption, body paragraphs, page setup); entry `typst/main.typ`. Engines: typst only. Rules: `../rules.md` (TXTRAVIS-ORD-001 to -004). Provenance of exemplars: `usage/SOURCE.md`.

**Not ready to e-file as rendered.** Technology Standards 3.1(E) says an e-filed PDF "may not contain embedded fonts"; every PDF this template renders embeds its fonts (rules.md TXTRAVIS-FORM-003, kind M, not met), and no un-embedding step ships with formbook. A green `fb check` does not test TS 3.1(E) and does not make the output filing-compliant. Before filing, check the PDF with `pdffonts`, and run it through a conforming PDF workflow or confirm with the e-filing service provider. Do not file the output directly.

## Rules carried (tier 1)

| Rule | What the template does |
|---|---|
| Local Rule 11.4 (ORD-001, ORD-002) | caption with cause number, style and court; the order is its own paper (no motion, certificate of service); the last paragraph is kept on the page with the judge's signature line |
| Local Rule 11.5 (ORD-003) | date line reads "SIGNED on this ___ day of ___, 20__." or (`date_line: so-ordered`) "SO ORDERED on this ..."; never "entered" |
| Local Rule 11.1; Technology Standards 3.1(E) | the order is rendered from its own sample, its own PDF; it must not be filed stand-alone, only as an attachment to the motion or other pleading (author responsibility) |
| Local Rule 2.5 (ORD-004) | an order setting a case (a show-cause order) is a separate page not combined with a pleading: satisfied, the order is always its own paper; the setting itself (Court Administrator) is the filer's responsibility, kind A |
| TRCP 21, 21a, 57 | not applied: an order has no filer's signature and no certificate of service; optional "approved as to form" blocks carry the TRCP 57 data of each approving attorney |

## Markdown contract

Required frontmatter: `cause_number`, `judicial_district` (e.g. "459th"), `caption` (list of `{names, designation}`), `title` (typed as the filer wants it, e.g. with "[Proposed]"). Optional: `date_line` (`signed` default | `so-ordered`), `month`, `year` (otherwise blank), `judge_title` (default "Judge Presiding"), `judge_court` (default true: "<district> DISTRICT COURT / TRAVIS COUNTY, TEXAS" under the line), `choices_intro` and `choices` (list; one check box each, printed after the body, for example with/without prejudice), `approved` (list of `{firm, name, bar_no, lines, phone, email, for}`; two-column "approved as to form" blocks) and `approved_heading`, `footer_title`. Body: paragraphs (recitals, findings), `#`/`##` headings (no numbering added), and `1.` / `-` lists (decretal paragraphs, double spaced). No paragraph numbering by default.

## Samples

| INPUT | Source | Pages | Shows |
|---|---|---|---|
| `INPUT-proposed-order.md` | Dobson signed order (201st, 2023) | 1 | single decretal paragraph |
| `INPUT-proposed-order-2.md` | State defendants' [Proposed] order (459th, 2026) | 2 | bracketed title, recital and ORDERED paragraphs; last paragraph moves with the signature |
| `INPUT-proposed-order-3.md` | Arnold & Itkin proposed order (459th, 2026) | 1 | long caption, bold DENIED/ORDERED |
| `INPUT-proposed-order-4.md` | fictional | 2 | Rule 91a motion granted, 91a.7 fee paragraph, with/without prejudice choice, two approval blocks |

## Page review (done, every page of every OUTPUT viewed; overlays for 1-3 run with `just overlay`)

| Page | Result |
|---|---|
| OUTPUT 1 p.1 | caption, rules, body, SIGNED line, judge block: OK; title is bold caps (exemplar: roman bold, two lines) |
| OUTPUT 2 p.1-2 | OK; p.1 ends with white space because the last paragraph stays with the signature (LR 11.4); the exemplar fits on one page |
| OUTPUT 3 p.1 | OK |
| OUTPUT 4 p.1-2 | OK; "It is therefore ORDERED that:" ends p.1, its list starts p.2 |

## Known gaps (tier 2/3, ACCEPTED)

- Caption names are bold capitals (shared lib), exemplar 2 uses small caps and exemplar 3 plain caps; the court column is bold. Exemplar 2 therefore needs 2 pages where the filed one needs 1.
- Exemplar 1's clerk stamp and printed judge name, exemplar 3's underlined title and footer "1" (ours: "Page 1") are not reproduced.
- The judge block does not repeat "PRESIDING JUDGE" wording of exemplar 2 unless `judge_title` is set.
- Lib candidates: a non-bold small-caps caption option; `order-paper` in the lib is superseded by this template for new orders. Nothing in lib was changed.
- Not read: the Standing Orders and individual judges' proposed-order procedures (rules.md gap).
- `data/doctypes.json` already lists `proposed-order`; not edited.

Option `title_underline: true` (added 2026-10-25): the title prints underlined, with no rules, so a set of papers in one case can match (the original-answer template has the same key).
