<!-- fb:generated:start -->
# District Court, D. Minnesota

- Alias: `mnd`
- CourtListener: [mnd](https://www.courtlistener.com/?court=mnd)
- Level: district
- Circuit: `ca8`
- State / territory: Minnesota
- Status: **up for review** (14%); manual status in `court.json`: `todo`

## Checklist

- [x] `rules.md` present
- [ ] `usage/SOURCE.md` names at least 2 FILED-EXAMPLE PDFs (different filers)
- [ ] `usage/` has at least 2 INPUT .md samples
- [ ] typst engine passes (`usage/.check-typst.txt` valid)
- [ ] latex engine passes (`usage/.check-latex.txt` valid)
- [ ] docx engine passes (`usage/.check-docx.txt` valid)
- [ ] a review file in `reviews/`

Engines (doc folders passing / with that template): typst `2/2`, latex `1/1`, docx `2/2`.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and every doc folder under it with a `usage/INPUT-*.md` has a valid `usage/.check-typst.txt` stamp (`just eval` writes them; the default checks are `data/checks-default.yaml`).

## Doc folders

2 of 2 doc folders with an INPUT pass the typst eval.

| Doc type | Status | Typst | LaTeX | DOCX |
|---|---|---|---|---|
| [complaint](complaint) | up for review | pass | — | pass |
| [motion-brief](motion-brief) | up for review | pass | pass | pass |

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (`reference.xml`, or a committed `reference.docx`, plus `*.lua` filters; `fb render --engine docx` builds it)
- `usage/` filed examples `FILED-EXAMPLE-<doctype>[-<n>].pdf` from different filers and `SOURCE.md`; sample inputs `INPUT-<doctype>[-<n>].md`; renders `OUTPUT-<doctype>[-<n>].typst.pdf`, `.latex.pdf`, `.docx`, `.docx.pdf` (same id as the INPUT); stamps `.check-<engine>.txt`

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
<!-- fb:generated:end -->

## Typeface

Checked against D. Minn. LR 7.1(h)(1) (complete set, PDF dated June 10, 2026; text read 2026-10-14). The rule sets a 13-point size and names no typeface, so no court-named substitute applies (`docs/FONTS.md`, rule 3). Both doc types are set in Times New Roman 13 pt, the house standard (`docs/FONTS.md`, rule 6; EB Garamond until then).

| Doc type | Face required by rule | Font in template | Substitute status |
|---|---|---|---|
| `complaint/` | none (size only: LR 7.1(h)(1)) | Times New Roman | n/a: no court-named face |
| `motion-brief/` | none (size only: LR 7.1(h)(1)) | Times New Roman | n/a: no court-named face |

- [ ] `usage/` has at least 2 filed PDFs (different filers)
- [ ] `usage/` has at least 2 .md samples

- [ ] overlay PDF present (`usage/*-overlay.pdf`)

- `usage/` real filed examples from different filers (PDF) and `SOURCE.md`
- `usage/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`
