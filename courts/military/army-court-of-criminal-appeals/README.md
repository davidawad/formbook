# U S Army Court of Criminal Appeals

- Alias: `acca`
- CourtListener: [acca](https://www.courtlistener.com/?court=acca)
- Level: military
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

| Requirement | Rule read | Template face | Status |
|---|---|---|---|
| Face named by the rules | ACCA Rules of Appellate Procedure (eff. 15 Jan 2019) R. 13.2 and 17.1(b): "Times New Roman 14-point", double-spaced, 1-inch margins. Read 2026-10-16 from `https://www.jagcnet.army.mil/Home/assets/pdf/court/RulesofCourt.pdf` (Wayback capture 20250729125903). | Liberation Serif 14 pt (`font-family`, `type-size` in each doc type's typst template) | Applied 2026-10-16 (bead fb-595.20.20), typst only. The docx engine still uses EB Garamond 12 pt and must be updated in a docx pass. |

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `exemplars/` real filed examples from different filers (PDF) and `SOURCE.md`
- `samples/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`

[Formbook index](../../../README.md) | [Status table](../../../STATUS.md)
