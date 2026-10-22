// California Court of Appeal, First Appellate District (calctapp1d): a petition for rehearing, on the shared document model: the
// layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx
// engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text,
// measured coordinates or forced breaks. The frontmatter schema is the README's "Markdown contract".
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// CALCTAPP1D-FORM-002 (CRC 8.74(b)(1)): a proportionally spaced serif; Century Schoolbook is preferred, TeX Gyre
// Schola is its clone. Vendored in /fonts.
#let font-family = "TeX Gyre Schola"

#let calctapp1d-petition-for-discretionary-review(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
