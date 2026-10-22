# Generated-engine port status (fb-595.54.69)

The five document folders need shared model support for the existing Mississippi authority contract before the Typst templates can move to `xdoc`. Their INPUT frontmatter stores authorities as a keyed map (`key: {kind, name, cite}`), and body citations mark those keys with links such as `[...](toa:mrap40)`. The current shared model accepts grouped authority arrays with `entries` and `find` strings, then derives marks by searching the body. It cannot preserve the current keyed authority ordering, grouping by `kind`, or explicit `toa:KEY` references. Add this normalization/marking behavior once in the shared model for Typst, LaTeX, and DOCX, with tests, before porting these folders.

- `amicus-brief`
- `answering-brief`
- `motion-brief`
- `opening-brief`
- `reply-brief`

The court root has filed examples but no `typst/` template or `usage/INPUT-*.md`, so it has no document render to generate or compare. Existing Typst baselines for the five document folders rendered successfully. No `layout.yaml` or generated LaTeX/DOCX engine was written, no cross-engine gate was set, and no engine comparison, check, or page review was completed. No engine check result is claimed. This records model limitations, not a finding that the Mississippi templates violate their rules.
