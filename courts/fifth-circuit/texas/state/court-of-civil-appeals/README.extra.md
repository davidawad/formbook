# Generated-engine port status (fb-595.54.69)

The five document folders are not yet fully on the shared document model. The current Typst templates and unchanged INPUT frontmatter require model features that are not supported:

- `amicus-brief`: the cover uses two page-filling `v(1fr)` spacers to place the title and counsel; layout blocks cannot currently distribute remaining page height.
- `motion-brief`: the caption uses a three-column grid with a standalone `)` separator between the left and right caption columns; the model has no separator column between two independently sized caption sides.
- `answering-brief`, `opening-brief`, and `reply-brief`: their templates attach signatures to the final body paragraph or quote through custom body parsing and keep blocks (for example, `signature-block(meta.signer)` after `md(piece.slice(at))`); the model cannot express keeping the final paragraph with the closing signature. Their authority frontmatter uses `authorities[].items`, while the model accepts `authorities[].entries`.
- All five inputs with tables of authorities use Texas-specific authority schemas (`items` for three briefs and `entries` without a model-compatible `heading` contract in the amicus brief). The shared model and its generated LaTeX/DOCX renderers need to preserve these source shapes or provide a tested normalization layer.

The court root has filed examples but no `typst/` template or `usage/INPUT-*.md`, so it has no document render to generate or compare.

The currently checked DOCX artifacts in `answering-brief`, `opening-brief`, and `reply-brief` do not satisfy this bead's requirement to generate engines from the common layout model; no LaTeX templates exist. No `layout.yaml` or generated LaTeX/DOCX engine was written, and no cross-engine gate was set. Existing Typst baselines rendered successfully, but no engine comparison, check, or page review was completed. No engine check result is claimed. This records model limitations, not a finding that the Texas templates violate their rules.
