# District Court, N.D. Indiana

- Alias: `innd`
- CourtListener: [innd](https://www.courtlistener.com/?court=innd)
- Level: district
- Circuit: `ca7`
- State / territory: Indiana
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

| Doc type | Face required by the rule | Vendored substitute | Fit |
|---|---|---|---|
| complaint | none named (N.D. Ind. L.R. 5-4(a) sets 12-pt body, 10-pt footnotes) | EB Garamond (the no-face default, `docs/FONTS.md`) | n/a |
| motion-brief | none named (same rule) | EB Garamond (the no-face default, `docs/FONTS.md`) | n/a |

The rule text checked on 2026-10-15 (2016 compilation, the most recent I could retrieve) names no face, so neither template switches font. The filers use Times New Roman; that is a tier-2 difference recorded in each doc type's Known gaps. Checked and recorded: the L.R. 5-4 text is unverified against the current revision.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and the typst engine passes `tools/check.sh` (valid stamp).

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `exemplars/` real filed examples from different filers (PDF) and `SOURCE.md`
- `samples/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
