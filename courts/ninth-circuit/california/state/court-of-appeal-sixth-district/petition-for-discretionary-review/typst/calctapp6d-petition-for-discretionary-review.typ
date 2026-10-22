// California Court of Appeal, Sixth Appellate District (calctapp6d): a petition for rehearing, on the shared document model: the
// layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx
// engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text,
// measured coordinates or forced breaks. The frontmatter schema is the README's "Markdown contract".
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// CALCTAPP6D-FORM-002 (CRC 8.74(b)(1)): any proportionally spaced serif; the filed exemplar is Times New Roman
// (usage/SOURCE.md). Vendored faces.
#let font-family = ("Times New Roman", "Liberation Serif")

#let calctapp6d-petition-for-discretionary-review(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
