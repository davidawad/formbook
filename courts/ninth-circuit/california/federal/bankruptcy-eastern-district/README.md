<!-- fb:generated:start -->
# United States Bankruptcy Court, E.D. California

- Alias: `caeb`
- CourtListener: [caeb](https://www.courtlistener.com/?court=caeb)
- Level: bankruptcy
- Circuit: `ca9`
- State / territory: California
- Status: **up for review** (14%); manual status in `court.json`: `todo`

## Checklist

- [x] `rules.md` present
- [ ] `usage/SOURCE.md` names at least 2 FILED-EXAMPLE PDFs (different filers)
- [ ] `usage/` has at least 2 INPUT .md samples
- [ ] typst engine passes (`usage/.check-typst.txt` valid)
- [ ] latex engine passes (`usage/.check-latex.txt` valid)
- [ ] docx engine passes (`usage/.check-docx.txt` valid)
- [ ] a review file in `reviews/`

Engines (doc folders passing / with that template): typst `1/1`, latex `—`, docx `1/1`.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and every doc folder under it with a `usage/INPUT-*.md` has a valid `usage/.check-typst.txt` stamp (`just eval` writes them; the default checks are `data/checks-default.yaml`).

## Doc folders

1 of 1 doc folders with an INPUT pass the typst eval.

| Doc type | Status | Typst | LaTeX | DOCX |
|---|---|---|---|---|
| [adversary-complaint](adversary-complaint) | up for review | pass | — | pass |

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (`reference.xml`, or a committed `reference.docx`, plus `*.lua` filters; `fb render --engine docx` builds it)
- `usage/` filed examples `FILED-EXAMPLE-<doctype>[-<n>].pdf` from different filers and `SOURCE.md`; sample inputs `INPUT-<doctype>[-<n>].md`; renders `OUTPUT-<doctype>[-<n>].typst.pdf`, `.latex.pdf`, `.docx`, `.docx.pdf` (same id as the INPUT); stamps `.check-<engine>.txt`

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
<!-- fb:generated:end -->

- [ ] `usage/` has at least 2 filed PDFs (different filers)
- [ ] `usage/` has at least 2 .md samples

- [ ] overlay PDF present (`usage/*-overlay.pdf`)

- `usage/` real filed examples from different filers (PDF) and `SOURCE.md`
- `usage/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`
