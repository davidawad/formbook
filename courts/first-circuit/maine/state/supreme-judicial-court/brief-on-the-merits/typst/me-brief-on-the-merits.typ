// Maine Supreme Judicial Court: appellant's brief on the merits (MRAP 7A(a)), on the shared document model: the layout is data (layout.yaml, every number
// with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines `fb engines gen` generates from
// this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// ME-FORM-006: no typeface is named; the exemplars' Times New Roman (Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let me-brief-on-the-merits(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
