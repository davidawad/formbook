# United States Bankruptcy Appellate Panel of The Eighth Circuit

- Alias: `bap8`
- CourtListener: [bap8](https://www.courtlistener.com/?court=bap8)
- Level: bap
- Circuit: `ca8`
- Status: **todo** (0%); manual status in `court.json`: `todo`
- Typeface: face required by the rules: none named. FRBP 8015(a)(5)(A) requires a proportional face with serifs (sans-serif allowed in headings and captions) at 14 pt or larger, or a monospaced face at most 10½ characters per inch. Substitute: **EB Garamond** (kept; the rules name no face, so no vendored substitute is needed). Metric: n/a. Checked 2026-10-14 against the rule text (courtrules.net; official text not re-read). No court-local typeface rule was found in this folder. All three doc types use EB Garamond at 14 pt; `pdffonts` on each OUTPUT shows only EB Garamond embedded.

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

[Formbook index](../../../README.md) | [Status table](../../../STATUS.md)
