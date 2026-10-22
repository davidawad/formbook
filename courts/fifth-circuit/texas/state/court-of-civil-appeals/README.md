<!-- fb:generated:start -->
# Court of Civil Appeals of Texas

- Alias: `texapp`
- CourtListener: [texapp](https://www.courtlistener.com/?court=texapp)
- Level: state-appellate
- Circuit: `ca5`
- State / territory: Texas
- Status: **up for review** (29%); manual status in `court.json`: `todo`

## Checklist

- [x] `rules.md` present
- [x] `usage/SOURCE.md` names at least 2 FILED-EXAMPLE PDFs (different filers)
- [ ] `usage/` has at least 2 INPUT .md samples
- [ ] typst engine passes (`usage/.check-typst.txt` valid)
- [ ] latex engine passes (`usage/.check-latex.txt` valid)
- [ ] docx engine passes (`usage/.check-docx.txt` valid)
- [ ] a review file in `reviews/`

Engines (doc folders passing / with that template): typst `5/5`, latex `2/2`, docx `4/5`.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and every doc folder under it with a `usage/INPUT-*.md` has a valid `usage/.check-typst.txt` stamp (`just eval` writes them; the default checks are `data/checks-default.yaml`).

## Doc folders

5 of 5 doc folders with an INPUT pass the typst eval.

| Doc type | Status | Typst | LaTeX | DOCX |
|---|---|---|---|---|
| [amicus-brief](amicus-brief) | up for review | pass | pass | fail |
| [answering-brief](answering-brief) | up for review | pass | — | pass |
| [motion-brief](motion-brief) | up for review | pass | pass | pass |
| [opening-brief](opening-brief) | up for review | pass | — | pass |
| [reply-brief](reply-brief) | up for review | pass | — | pass |

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `usage/` filed examples `FILED-EXAMPLE-<doctype>[-<n>].pdf` from different filers and `SOURCE.md`; sample inputs `INPUT-<doctype>[-<n>].md`; renders `OUTPUT-<doctype>[-<n>].typst.pdf`, `.latex.pdf`, `.docx`, `.docx.pdf` (same id as the INPUT); stamps `.check-<engine>.txt`

# Generated-engine port status (fb-595.54.69)

The five document folders are not yet fully on the shared document model. The current Typst templates and unchanged INPUT frontmatter require model features that are not supported:

- `amicus-brief`: the cover uses two page-filling `v(1fr)` spacers to place the title and counsel; layout blocks cannot currently distribute remaining page height.
- `motion-brief`: the caption uses a three-column grid with a standalone `)` separator between the left and right caption columns; the model has no separator column between two independently sized caption sides.
- `answering-brief`, `opening-brief`, and `reply-brief`: their templates attach signatures to the final body paragraph or quote through custom body parsing and keep blocks (for example, `signature-block(meta.signer)` after `md(piece.slice(at))`); the model cannot express keeping the final paragraph with the closing signature. Their authority frontmatter uses `authorities[].items`, while the model accepts `authorities[].entries`.
- All five inputs with tables of authorities use Texas-specific authority schemas (`items` for three briefs and `entries` without a model-compatible `heading` contract in the amicus brief). The shared model and its generated LaTeX/DOCX renderers need to preserve these source shapes or provide a tested normalization layer.

The court root has filed examples but no `typst/` template or `usage/INPUT-*.md`, so it has no document render to generate or compare.

The currently checked DOCX artifacts in `answering-brief`, `opening-brief`, and `reply-brief` do not satisfy this bead's requirement to generate engines from the common layout model; no LaTeX templates exist. No `layout.yaml` or generated LaTeX/DOCX engine was written, and no cross-engine gate was set. Existing Typst baselines rendered successfully, but no engine comparison, check, or page review was completed. No engine check result is claimed. This records model limitations, not a finding that the Texas templates violate their rules.

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
<!-- fb:generated:end -->

- [ ] `usage/` has at least 2 filed PDFs (different filers)
- [ ] `usage/` has at least 2 .md samples

- [ ] overlay PDF present (`usage/*-overlay.pdf`)

- `usage/` real filed examples from different filers (PDF) and `SOURCE.md`
- `usage/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`
