<!-- fb:generated:start -->
# Court of Appeals of Mississippi

- Alias: `missctapp`
- CourtListener: [missctapp](https://www.courtlistener.com/?court=missctapp)
- Level: state-appellate
- Circuit: `ca5`
- State / territory: Mississippi
- Status: **up for review** (29%); manual status in `court.json`: `todo`

## Checklist

- [x] `rules.md` present
- [x] `usage/SOURCE.md` names at least 2 FILED-EXAMPLE PDFs (different filers)
- [ ] `usage/` has at least 2 INPUT .md samples
- [ ] typst engine passes (`usage/.check-typst.txt` valid)
- [ ] latex engine passes (`usage/.check-latex.txt` valid)
- [ ] docx engine passes (`usage/.check-docx.txt` valid)
- [ ] a review file in `reviews/`

Engines (doc folders passing / with that template): typst `5/5`, latex `5/5`, docx `1/5`.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and every doc folder under it with a `usage/INPUT-*.md` has a valid `usage/.check-typst.txt` stamp (`just eval` writes them; the default checks are `data/checks-default.yaml`).

## Doc folders

5 of 5 doc folders with an INPUT pass the typst eval.

| Doc type | Status | Typst | LaTeX | DOCX |
|---|---|---|---|---|
| [amicus-brief](amicus-brief) | up for review | pass | pass | fail |
| [answering-brief](answering-brief) | up for review | pass | pass | fail |
| [motion-brief](motion-brief) | up for review | pass | pass | fail |
| [opening-brief](opening-brief) | up for review | pass | pass | fail |
| [reply-brief](reply-brief) | up for review | pass | pass | pass |

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (`reference.xml`, or a committed `reference.docx`, plus `*.lua` filters; `fb render --engine docx` builds it)
- `usage/` filed examples `FILED-EXAMPLE-<doctype>[-<n>].pdf` from different filers and `SOURCE.md`; sample inputs `INPUT-<doctype>[-<n>].md`; renders `OUTPUT-<doctype>[-<n>].typst.pdf`, `.latex.pdf`, `.docx`, `.docx.pdf` (same id as the INPUT); stamps `.check-<engine>.txt`

# Generated-engine port status (fb-595.54.69)

The five document folders need shared model support for the existing Mississippi authority contract before the Typst templates can move to `xdoc`. Their INPUT frontmatter stores authorities as a keyed map (`key: {kind, name, cite}`), and body citations mark those keys with links such as `[...](toa:mrap40)`. The current shared model accepts grouped authority arrays with `entries` and `find` strings, then derives marks by searching the body. It cannot preserve the current keyed authority ordering, grouping by `kind`, or explicit `toa:KEY` references. Add this normalization/marking behavior once in the shared model for Typst, LaTeX, and DOCX, with tests, before porting these folders.

- `amicus-brief`
- `answering-brief`
- `motion-brief`
- `opening-brief`
- `reply-brief`

The court root has filed examples but no `typst/` template or `usage/INPUT-*.md`, so it has no document render to generate or compare. Existing Typst baselines for the five document folders rendered successfully. No `layout.yaml` or generated LaTeX/DOCX engine was written, no cross-engine gate was set, and no engine comparison, check, or page review was completed. No engine check result is claimed. This records model limitations, not a finding that the Mississippi templates violate their rules.

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
<!-- fb:generated:end -->

- [ ] `usage/` has at least 2 filed PDFs (different filers)
- [ ] `usage/` has at least 2 .md samples

- [ ] overlay PDF present (`usage/*-overlay.pdf`)

- `usage/` real filed examples from different filers (PDF) and `SOURCE.md`
- `usage/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`
