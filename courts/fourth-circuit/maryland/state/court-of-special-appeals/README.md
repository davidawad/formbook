<!-- fb:generated:start -->
# Court of Special Appeals of Maryland

- Alias: `mdctspecapp`
- CourtListener: [mdctspecapp](https://www.courtlistener.com/?court=mdctspecapp)
- Level: state-appellate
- Circuit: `ca4`
- State / territory: Maryland
- Status: **up for review** (29%); manual status in `court.json`: `todo`

## Checklist

- [x] `rules.md` present
- [x] `usage/SOURCE.md` names at least 2 FILED-EXAMPLE PDFs (different filers)
- [ ] `usage/` has at least 2 INPUT .md samples
- [ ] typst engine passes (`usage/.check-typst.txt` valid)
- [ ] latex engine passes (`usage/.check-latex.txt` valid)
- [ ] docx engine passes (`usage/.check-docx.txt` valid)
- [ ] a review file in `reviews/`

Engines (doc folders passing / with that template): typst `6/6`, latex `6/6`, docx `6/6`.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and every doc folder under it with a `usage/INPUT-*.md` has a valid `usage/.check-typst.txt` stamp (`just eval` writes them; the default checks are `data/checks-default.yaml`).

## Doc folders

6 of 6 doc folders with an INPUT pass the typst eval.

| Doc type | Status | Typst | LaTeX | DOCX |
|---|---|---|---|---|
| [amicus-brief](amicus-brief) | up for review | pass | pass | pass |
| [answering-brief](answering-brief) | up for review | pass | pass | pass |
| [motion-brief](motion-brief) | up for review | pass | pass | pass |
| [opening-brief](opening-brief) | up for review | pass | pass | pass |
| [petition-for-discretionary-review](petition-for-discretionary-review) | up for review | pass | pass | pass |
| [reply-brief](reply-brief) | up for review | pass | pass | pass |

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `usage/` filed examples `FILED-EXAMPLE-<doctype>[-<n>].pdf` from different filers and `SOURCE.md`; sample inputs `INPUT-<doctype>[-<n>].md`; renders `OUTPUT-<doctype>[-<n>].typst.pdf`, `.latex.pdf`, `.docx`, `.docx.pdf` (same id as the INPUT); stamps `.check-<engine>.txt`

# Generated-engine port status (fb-595.54.58)

The six document folders in this court are not yet on the shared document model. Their Typst covers use `v(1fr)` to distribute the remaining page height around the title and counsel. `typst/layout.yaml` has no page-filling spacer block, so the current generated LaTeX and DOCX model cannot preserve that cover layout. Do not set `params.cross_engine: gate` or report generated-engine checks as passing until the shared model can express this feature in all three engines and all pages have been reviewed:

- `amicus-brief`
- `answering-brief`
- `motion-brief`
- `opening-brief`
- `petition-for-discretionary-review`
- `reply-brief`

No engine was generated or checked in this attempt. This is a recorded model limitation, not a finding that the underlying Maryland template violates its rules.

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
<!-- fb:generated:end -->

- [ ] `usage/` has at least 2 filed PDFs (different filers)
- [ ] `usage/` has at least 2 .md samples

- [ ] overlay PDF present (`usage/*-overlay.pdf`)

- `usage/` real filed examples from different filers (PDF) and `SOURCE.md`
- `usage/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`
