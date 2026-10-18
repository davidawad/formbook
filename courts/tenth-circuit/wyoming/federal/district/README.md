# District Court, D. Wyoming

- Alias: `wyd`
- CourtListener: [wyd](https://www.courtlistener.com/?court=wyd)
- Level: district
- Circuit: `ca10`
- State / territory: Wyoming
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

## Typeface (fonts pass, 2026-10-15)

| Doc type | Face required by the rule | Vendored substitute | Fit | Template font |
|---|---|---|---|---|
| `complaint` | none named (D. Wyo. LR 10.1(a): "not less than 12 point font") | none needed (`docs/FONTS.md`, "No face named") | n/a | EB Garamond 13 pt |
| `motion-brief` | none named (same rule) | none needed | n/a | EB Garamond 13 pt |

Both doc types keep EB Garamond. Neither rule names a face, so the template stays on the default; the filed exemplars use Times-family (complaint) and Century Schoolbook (brief) type, a filer convention recorded as an accepted tier-2 difference in each doc-type README. `complaint/README.md` and `motion-brief/README.md` each carry the same table and the open decision for David.

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
