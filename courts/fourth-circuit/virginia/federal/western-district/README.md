# District Court, W.D. Virginia

- Alias: `vawd`
- CourtListener: [vawd](https://www.courtlistener.com/?court=vawd)
- Level: district
- Circuit: `ca4`
- State / territory: Virginia
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

Typeface (both doc types, checked 2026-10-14): face required: none (the W.D. Va. Local Civil Rules name no typeface, font size or spacing). Font: EB Garamond, unchanged. No vendored substitute is needed. Exemplars are Times New Roman by habit only.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and the typst engine passes `tools/check.sh` (valid stamp).

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `exemplars/` real filed examples from different filers (PDF) and `SOURCE.md`
- `samples/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
