<!-- fb:generated:start -->
# United States Bankruptcy Court, W.D. Texas

- Alias: `txwb`
- CourtListener: [txwb](https://www.courtlistener.com/?court=txwb)
- Level: bankruptcy
- Circuit: `ca5`
- State / territory: Texas
- Status: **up for review** (14%); manual status in `court.json`: `todo`

## Checklist

- [x] `rules.md` present
- [ ] `usage/SOURCE.md` names at least 2 FILED-EXAMPLE PDFs (different filers)
- [ ] `usage/` has at least 2 INPUT .md samples
- [ ] typst engine passes (`usage/.check-typst.txt` valid)
- [ ] latex engine passes (`usage/.check-latex.txt` valid)
- [ ] docx engine passes (`usage/.check-docx.txt` valid)
- [ ] a review file in `reviews/`

Engines (doc folders passing / with that template): typst `2/2`, latex `—`, docx `2/2`.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and every doc folder under it with a `usage/INPUT-*.md` has a valid `usage/.check-typst.txt` stamp (`just eval` writes them; the default checks are `data/checks-default.yaml`).

## Doc folders

2 of 2 doc folders with an INPUT pass the typst eval.

| Doc type | Status | Typst | LaTeX | DOCX |
|---|---|---|---|---|
| [adversary-complaint](adversary-complaint) | up for review | pass | — | pass |
| [motion-brief](motion-brief) | up for review | pass | — | pass |

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `usage/` filed examples `FILED-EXAMPLE-<doctype>[-<n>].pdf` from different filers and `SOURCE.md`; sample inputs `INPUT-<doctype>[-<n>].md`; renders `OUTPUT-<doctype>[-<n>].typst.pdf`, `.latex.pdf`, `.docx`, `.docx.pdf` (same id as the INPUT); stamps `.check-<engine>.txt`

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
<!-- fb:generated:end -->

- [ ] `usage/` has at least 2 filed PDFs (different filers)
- [ ] `usage/` has at least 2 .md samples

- [ ] overlay PDF present (`usage/*-overlay.pdf`)

## Typeface

Checked 2026-10-14 against FRBP 9004(a) and the W.D. Tex. local rules (2014 redline on txwb.uscourts.gov; see the doc-type READMEs). No rule names a face for pleadings, so no substitute is used and each template keeps EB Garamond (`docs/FONTS.md`, "No face named").

| Doc type | Face required by rule | Vendored substitute | Typeface used |
|---|---|---|---|
| `adversary-complaint` | none | none needed | EB Garamond |
| `motion-brief` | none | none needed | EB Garamond |

- `usage/` real filed examples from different filers (PDF) and `SOURCE.md`
- `usage/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`
