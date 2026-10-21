# Typst Universe packaging scope

The packaging task asks for one Typst Universe package named `formbook-<alias>` for each finished court template. In this checkout, 492 `typst/main.typ` entrypoints belong to court ids, and 227 ids have more than one entrypoint. A court id therefore does not identify one document template.

Typst package manifests declare one `[template]` section with one `path` and one `entrypoint`. The package can expose other library code, but `typst init` has one template project to instantiate. See the [Typst package manifest documentation](https://github.com/typst/packages/blob/main/docs/manifest.md#templates).

Before packaging, choose how the requested package name maps to those templates:

1. One package per court id, with one court-wide starter project that dispatches among document types.
2. One package per document type, extending the name with a stable document-type suffix (for example, `formbook-ca9-opening-brief`).

Also define “finished” for this task. Court metadata remains `todo` until David changes it, while tracker readiness is derived from template checks and does not mark a court `done`.

No package files have been created yet: either mapping would discard or redesign part of the requested scope without that decision.
