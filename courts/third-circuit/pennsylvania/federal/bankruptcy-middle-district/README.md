# United States Bankruptcy Court, M.D. Pennsylvania

- Alias: `pamb`
- CourtListener: [pamb](https://www.courtlistener.com/?court=pamb)
- Level: bankruptcy
- Circuit: `ca3`
- State / territory: Pennsylvania
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

## Typeface

| Doc type | Face required (rule) | Vendored substitute | Fit |
|---|---|---|---|
| motion-brief | none named (L.B.R. full text checked 2026-10-15; FRBP 9004(a) legibility only) | none; EB Garamond kept | n/a |
| adversary-complaint | none named (same check) | none; EB Garamond kept | n/a |

The local rules name no typeface for pleadings, so both doc types keep EB Garamond (`docs/FONTS.md`, "No face named").

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and the typst engine passes `tools/check.sh` (valid stamp).

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `exemplars/` real filed examples from different filers (PDF) and `SOURCE.md`
- `samples/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
