<!-- fb:generated:start -->
# District Courts of Travis County, Texas (Austin)

- Alias: `txdistrict-travis`
- CourtListener: none (not a CourtListener id)
- Level: state-trial
- Circuit: `ca5`
- State / territory: Texas
- Status: **up for review** (14%); manual status in `court.json`: `todo`

## Checklist

- [x] `rules.md` present
- [ ] `usage/SOURCE.md` names at least 2 FILED-EXAMPLE PDFs (different filers)
- [ ] `usage/` has at least 2 INPUT .md samples
- [ ] typst engine passes (`usage/.check-typst.txt` valid)
- [ ] latex engine passes (`usage/.check-latex.txt` valid)
- [ ] docx engine passes (`usage/.check-docx.txt` valid)
- [ ] a review file in `reviews/`

Engines (doc folders passing / with that template): typst `5/5`, latex `—`, docx `—`.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and every doc folder under it with a `usage/INPUT-*.md` has a valid `usage/.check-typst.txt` stamp (`just eval` writes them; the default checks are `data/checks-default.yaml`).

## Doc folders

5 of 5 doc folders with an INPUT pass the typst eval.

| Doc type | Status | Typst | LaTeX | DOCX |
|---|---|---|---|---|
| [motion-brief](motion-brief) | up for review | pass | — | — |
| [notice-of-appearance](notice-of-appearance) | up for review | pass | — | — |
| [notice-of-hearing](notice-of-hearing) | up for review | pass | — | — |
| [original-answer](original-answer) | up for review | pass | — | — |
| [proposed-order](proposed-order) | up for review | pass | — | — |

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (`reference.xml`, or a committed `reference.docx`, plus `*.lua` filters; `fb render --engine docx` builds it)
- `usage/` filed examples `FILED-EXAMPLE-<doctype>[-<n>].pdf` from different filers and `SOURCE.md`; sample inputs `INPUT-<doctype>[-<n>].md`; renders `OUTPUT-<doctype>[-<n>].typst.pdf`, `.latex.pdf`, `.docx`, `.docx.pdf` (same id as the INPUT); stamps `.check-<engine>.txt`

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
<!-- fb:generated:end -->

# District Courts of Travis County, Texas (txdistrict-travis)

Doc types: `original-answer`, `motion-brief`, `proposed-order`, `notice-of-hearing`, `notice-of-appearance`. Rules, sources and date read: `rules.md`. Shared template code: `/lib/typst/txdistrict-travis-common.typ`. Alias choice: the Texas district courts have no CourtListener id; the alias follows the `calsuperct-sandiego` pattern (`tx` + `district` + county). Status is `todo` (never set `done`; the owner does).

## Typeface (noted 2026-10-25; decision: stay with Times)

No Texas rule or Travis local rule names a typeface (rules.md). The templates use the vendored Liberation Serif, which has the same letter widths as Times New Roman, at one size throughout. That matches what most filers use. The embedded fonts of the filed examples (`pdffonts`, page 1, 2026-10-25):

| Exemplar | Fonts |
|---|---|
| original-answer-2 (Evertson & Sanchez, SCC Oaks v. TCAD) | Garamond and Garamond-Bold, about 14 pt, for the cause number and caption; Times New Roman 12 pt for the title and body |
| motion-brief, notice-of-hearing 1-3, proposed-order-3 | Times New Roman |
| motion-brief-5, notice-of-appearance, proposed-order-2 (Texas AG) | Equity Text A |
| original-answer, motion-brief-2, proposed-order (Dobson), notice-of-appearance-2 | scans; OCR font only, original face unknown |

Arial and Liberation Sans appear only in the clerk's e-file stamp. The Garamond caption is one filer's style (tier 3), so it is not reproduced. Garamond itself is a licensed Monotype face, and the repo bars system fonts. If a Garamond caption is ever wanted, the route is a vendored open face (EB Garamond, SIL OFL) behind an opt-in caption option. It would not be the default.

## Open questions (conservative default taken)

`rules.md` refers to this section.

1. Embedded fonts vs. Technology Standards 3.1(E) ("Documents may not contain embedded fonts"): every Typst PDF here embeds its fonts (rules.md TXTRAVIS-FORM-003, M, not met). Default: keep the project's vendored embedded fonts and mark each document README "Not ready to e-file as rendered". Open: a conforming un-embedding workflow, or confirmation from the e-filing service provider that it accepts the output.
2. Engines: only typst ships for these five document types. Default: typst only; latex and docx parity (AGENTS.md "three engines") is the owner's call and is not started.
3. Local rules: the county has until 2026-10-31 to amend its local rules; the Standing Order on Master Calendar (2026-07-01) and the summary-judgment standing order (2026-06-29) are not read (rules.md, Sources). Re-read before filing.
4. CourtListener id: none (state district courts); the alias follows the `calsuperct-sandiego` pattern.
