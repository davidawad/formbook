# United States District Court for the Northern District of California

- Alias: `cand`
- CourtListener: [cand](https://www.courtlistener.com/?court=cand)
- Level: district
- Circuit: `ca9`
- State / territory: California
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

Substitutes come from `docs/FONTS.md`. "Metric-compatible" means the substitute should keep line breaks and page count; "visual only" means it does not.

| Doc type | Face the rule names | Vendored substitute (typst family) | Fit | Status |
|---|---|---|---|---|
| complaint | Civil L.R. 3-4(c)(2)(A): standard proportional font, e.g. Times New Roman or Century Schoolbook | Liberation Serif (12 pt) | Metric-compatible | Switched from EB Garamond; `pdffonts` confirms embedding |
| motion-brief | Civil L.R. 3-4(c)(2)(A)-(B): same wording, 12 pt or larger | Liberation Serif (12 pt) | Metric-compatible | Switched from EB Garamond (13 pt); page count 12 to 10 |

No N.D. Cal. rule names a face as a requirement; the examples are "e.g." Reading: the rule's examples name Times New Roman, so the Times substitute is used. Keeping EB Garamond would also satisfy the rule's text (see each doc type's README, Known gaps).

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `exemplars/` real filed examples from different filers (PDF) and `SOURCE.md`
- `samples/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
