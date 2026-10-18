# United States Bankruptcy Court, D. Montana

- Alias: `mtb`
- CourtListener: [mtb](https://www.courtlistener.com/?court=mtb)
- Level: bankruptcy
- Circuit: `ca9`
- State / territory: Montana
- Status: **todo** (0%); manual status in `court.json`: `todo`

## Checklist

- [ ] `rules.md` present
- [ ] `usage/` has at least 2 filed PDFs (different filers)
- [ ] `usage/` has at least 2 .md samples
- [ ] typst engine passes (`usage/.check-typst.txt` valid)
- [ ] latex engine passes (`usage/.check-latex.txt` valid)
- [ ] docx engine passes (`usage/.check-docx.txt` valid)
- [ ] overlay PDF present (`usage/*-overlay.pdf`)
- [ ] a review file in `reviews/`

Engines: typst `—`, latex `—`, docx `—`.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and the typst engine passes `tools/check.sh` (valid stamp).

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `usage/` real filed examples from different filers (PDF) and `SOURCE.md`
- `usage/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`

## Typeface

Read from the court's PDF (Mont. LBR, December 1, 2025) on 2026-10-15:

- Mont. LBR 9013-1(k)(6)(A): "All proposed Orders shall be submitted in Times New Roman size 12 font." This names a face for **proposed orders only**.
- Mont. LBR 5005-2(a)(2) sets only the 12-point floor. No other LBR or Fed. R. Bankr. P. rule read names a face for complaints or motions.

| Doc type | Face required by the rules | Vendored substitute (`docs/FONTS.md`) | Fit | Used |
|---|---|---|---|---|
| `adversary-complaint` | none | n/a | n/a | EB Garamond |
| `motion-brief` | none | n/a | n/a | EB Garamond |
| (proposed order, no template here) | Times New Roman 12 | `Liberation Serif` | metric-compatible | not built |

A proposed-order template, if one is added, uses `Liberation Serif` (not EB Garamond).

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
