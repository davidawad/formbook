# United States Bankruptcy Court, District of Columbia

- Alias: `dcb`
- CourtListener: [dcb](https://www.courtlistener.com/?court=dcb)
- Level: bankruptcy
- Circuit: `cadc`
- State / territory: District of Columbia
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

## Typeface

Checked 2026-10-15 against the court's Local Bankruptcy Rules (General Order 2025-01, text layer): no rule names a typeface or point size. Both doc types keep EB Garamond (`docs/FONTS.md`, "no face named" row), at 12 pt.

| Doc type | Face required | Font in template | Notes |
|---|---|---|---|
| `adversary-complaint/` | none | EB Garamond | see that folder's README, gap 2 |
| `motion-brief/` | none | EB Garamond | see that folder's README, gap 2 |

No `latex/` or `docx/` engine exists for this court.

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `usage/` real filed examples from different filers (PDF) and `SOURCE.md`
- `usage/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
