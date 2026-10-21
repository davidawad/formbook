<!-- fb:generated:start -->
# United States Bankruptcy Appellate Panel of The Eighth Circuit

- Alias: `bap8`
- CourtListener: [bap8](https://www.courtlistener.com/?court=bap8)
- Level: bap
- Circuit: `ca8`
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

1 of 3 doc folders with an INPUT pass the typst eval.

| Doc folder | Status | Eval |
|---|---|---|
| [answering-brief](answering-brief) | in progress | not passing |
| [opening-brief](opening-brief) | up for review | pass |
| [reply-brief](reply-brief) | in progress | not passing |

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `usage/` filed examples `FILED-EXAMPLE-<doctype>[-<n>].pdf` from different filers and `SOURCE.md`; sample inputs `INPUT-<doctype>[-<n>].md`; renders `OUTPUT-<doctype>[-<n>].typst.pdf`, `.latex.pdf`, `.docx`, `.docx.pdf` (same id as the INPUT); stamps `.check-<engine>.txt`

[Formbook index](../../../README.md) | [Status table](../../../STATUS.md)
<!-- fb:generated:end -->

- Typeface: face required by the rules: none named. FRBP 8015(a)(5)(A) requires a proportional face with serifs (sans-serif allowed in headings and captions) at 14 pt or larger, or a monospaced face at most 10½ characters per inch. Substitute: **EB Garamond** (kept; the rules name no face, so no vendored substitute is needed). Metric: n/a. Checked 2026-10-14 against the rule text (courtrules.net; official text not re-read). No court-local typeface rule was found in this folder. All three doc types use EB Garamond at 14 pt; `pdffonts` on each OUTPUT shows only EB Garamond embedded.

- [ ] `usage/` has at least 2 filed PDFs (different filers)
- [ ] `usage/` has at least 2 .md samples

- [ ] overlay PDF present (`usage/*-overlay.pdf`)

- `usage/` real filed examples from different filers (PDF) and `SOURCE.md`
- `usage/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`
