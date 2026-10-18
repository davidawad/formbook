# United States District Court for the Northern District of Florida

- Alias: `flnd`
- CourtListener: [flnd](https://www.courtlistener.com/?court=flnd)
- Level: district
- Circuit: `ca11`
- State / territory: Florida
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

N.D. Fla. Loc. R. 5.1(C) requires "at least 14-point font" and names no face (text read 2026-10-14 from the court's local rules PDF, `https://flnd.uscourts.gov/sites/flnd/files/local_rules/local_rules_0.pdf`). Under `docs/FONTS.md` ("No face named") both doc types keep the vendored **EB Garamond** at 14 pt. The filed exemplars are Times New Roman; that is the filer's choice, not a court requirement, so no Liberation Serif substitute is used. Each doc-type README carries its own typeface row.

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `usage/` real filed examples from different filers (PDF) and `SOURCE.md`
- `usage/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
