# District Court, D. Minnesota

- Alias: `mnd`
- CourtListener: [mnd](https://www.courtlistener.com/?court=mnd)
- Level: district
- Circuit: `ca8`
- State / territory: Minnesota
- Status: **todo** (0%); manual status in `court.json`: `todo`

## Typeface

Checked against D. Minn. LR 7.1(h)(1) (complete set, PDF dated June 10, 2026; text read 2026-10-14). The rule sets a 13-point size and names no typeface, so no court-named substitute applies (`docs/FONTS.md`, rule 3). Both doc types keep EB Garamond.

| Doc type | Face required by rule | Font in template | Substitute status |
|---|---|---|---|
| `complaint/` | none (size only: LR 7.1(h)(1)) | EB Garamond | n/a: no court-named face |
| `motion-brief/` | none (size only: LR 7.1(h)(1)) | EB Garamond | n/a: no court-named face |

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

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
