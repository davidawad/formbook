<!-- fb:generated:start -->
# U S Army Court of Criminal Appeals

- Alias: `acca`
- CourtListener: [acca](https://www.courtlistener.com/?court=acca)
- Level: military
- Status: **in progress** (14%); manual status in `court.json`: `todo`

## Checklist

- [x] `rules.md` present
- [ ] `usage/SOURCE.md` names at least 2 FILED-EXAMPLE PDFs (different filers)
- [ ] `usage/` has at least 2 INPUT .md samples
- [ ] typst engine passes (`usage/.check-typst.txt` valid)
- [ ] latex engine passes (`usage/.check-latex.txt` valid)
- [ ] docx engine passes (`usage/.check-docx.txt` valid)
- [ ] a review file in `reviews/`

Engines: typst `—`, latex `—`, docx `—`.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and every doc folder under it with a `usage/INPUT-*.md` has a valid `usage/.check-typst.txt` stamp (`just eval` writes them; the default checks are `data/checks-default.yaml`).

## Doc folders

0 of 2 doc folders with an INPUT pass the typst eval.

| Doc folder | Status | Eval |
|---|---|---|
| [answering-brief](answering-brief) | in progress | not passing |
| [opening-brief](opening-brief) | in progress | not passing |

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `usage/` filed examples `FILED-EXAMPLE-<doctype>[-<n>].pdf` from different filers and `SOURCE.md`; sample inputs `INPUT-<doctype>[-<n>].md`; renders `OUTPUT-<doctype>[-<n>].typst.pdf`, `.latex.pdf`, `.docx`, `.docx.pdf` (same id as the INPUT); stamps `.check-<engine>.txt`

[Formbook index](../../../README.md) | [Status table](../../../STATUS.md)
<!-- fb:generated:end -->

- [ ] `usage/` has at least 2 filed PDFs (different filers)
- [ ] `usage/` has at least 2 .md samples

- [ ] overlay PDF present (`usage/*-overlay.pdf`)

## Typeface

| Requirement | Rule read | Template face | Status |
|---|---|---|---|
| Face named by the rules | ACCA Rules of Appellate Procedure (eff. 15 Jan 2019) R. 13.2 and 17.1(b): "Times New Roman 14-point", double-spaced, 1-inch margins. Read 2026-10-16 from `https://www.jagcnet.army.mil/Home/assets/pdf/court/RulesofCourt.pdf` (Wayback capture 20250729125903). | Liberation Serif 14 pt (`font-family`, `type-size` in each doc type's typst template) | Applied 2026-10-16 (bead fb-595.20.20), typst only. The docx engine still uses EB Garamond 12 pt and must be updated in a docx pass. |

- `usage/` real filed examples from different filers (PDF) and `SOURCE.md`
- `usage/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`
