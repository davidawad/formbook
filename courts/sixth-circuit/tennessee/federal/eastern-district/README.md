# District Court, E.D. Tennessee

- Alias: `tned`
- CourtListener: [tned](https://www.courtlistener.com/?court=tned)
- Level: district
- Circuit: `ca6`
- State / territory: Tennessee
- Status: **todo** (0%); manual status in `court.json`: `todo`

## Checklist

- [ ] `rules.md` present
- [ ] `exemplars/` has at least 2 filed PDFs (different filers)
- [ ] `samples/` has at least 2 .md samples
- [ ] typst engine passes (`samples/.check-typst.txt` valid)
- [ ] latex engine passes (`samples/.check-latex.txt` valid)
- [ ] docx engine passes (`samples/.check-docx.txt` valid)
- [ ] overlay PDF present (`samples/*-overlay.pdf`)
- [ ] a review file in `reviews/`

Engines: typst `—`, latex `—`, docx `—`.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and the typst engine passes `tools/check.sh` (valid stamp).

## Typeface

| Doc type | Face required (rule) | Substitute (`docs/FONTS.md`) | Fit |
|---|---|---|---|
| complaint | none: E.D. Tenn. LR 5.1 sets a 12-pt minimum and names no face | none; EB Garamond kept ("No face named") | n/a (visual only vs. the exemplar's Times-like face) |
| motion-brief | none: E.D. Tenn. LR 5.1 (same) | none; EB Garamond kept | n/a (same) |

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `exemplars/` real filed examples from different filers (PDF) and `SOURCE.md`
- `samples/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
