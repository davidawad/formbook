# United States Bankruptcy Court, W.D. Arkansas

- Alias: `arwb`
- CourtListener: [arwb](https://www.courtlistener.com/?court=arwb)
- Level: bankruptcy
- Circuit: `ca8`
- State / territory: Arkansas
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

Typeface: no face is named by the rules read (2026-10-14), so both doc types keep EB Garamond; see the typeface row in each doc-type README.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and the typst engine passes `tools/check.sh` (valid stamp).

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `exemplars/` real filed examples from different filers (PDF) and `SOURCE.md`
- `samples/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
