<!-- fb:generated:start -->
# United States District Court for the Northern District of California

- Alias: `cand`
- CourtListener: [cand](https://www.courtlistener.com/?court=cand)
- Level: district
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

Engines (doc folders passing / with that template): typst `2/2`, latex `—`, docx `2/2`.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and every doc folder under it with a `usage/INPUT-*.md` has a valid `usage/.check-typst.txt` stamp (`just eval` writes them; the default checks are `data/checks-default.yaml`).

## Doc folders

2 of 2 doc folders with an INPUT pass the typst eval.

| Doc type | Status | Typst | LaTeX | DOCX |
|---|---|---|---|---|
| [complaint](complaint) | up for review | pass | — | pass |
| [motion-brief](motion-brief) | up for review | pass | — | pass |

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

## Typeface

Substitutes come from `docs/FONTS.md`. "Metric-compatible" means the substitute should keep line breaks and page count; "visual only" means it does not.

| Doc type | Face the rule names | Vendored substitute (typst family) | Fit | Status |
|---|---|---|---|---|
| complaint | Civil L.R. 3-4(c)(2)(A): standard proportional font, e.g. Times New Roman or Century Schoolbook | Times New Roman (12 pt; Liberation Serif fallback) | Exact (the pinned Times New Roman install) | Switched from EB Garamond, then from Liberation Serif to Times New Roman (docs/FONTS.md rule 6); `pdffonts` confirms embedding |
| motion-brief | Civil L.R. 3-4(c)(2)(A)-(B): same wording, 12 pt or larger | Times New Roman (12 pt; Liberation Serif fallback) | Exact (the pinned Times New Roman install) | Switched from EB Garamond (13 pt; page count 12 to 10 on Liberation Serif), then to Times New Roman (docs/FONTS.md rule 6) |

No N.D. Cal. rule names a face as a requirement; the examples are "e.g." Reading: the rule's examples name Times New Roman, so Times New Roman is used (the house standard, docs/FONTS.md rule 6). Keeping EB Garamond would also satisfy the rule's text (see each doc type's README, Known gaps).

- `usage/` real filed examples from different filers (PDF) and `SOURCE.md`
- `usage/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`
