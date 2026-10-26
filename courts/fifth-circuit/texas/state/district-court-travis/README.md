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
