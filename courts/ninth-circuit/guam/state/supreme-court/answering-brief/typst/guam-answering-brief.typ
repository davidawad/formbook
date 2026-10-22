// Supreme Court of Guam (guam): answering brief (GRAP 16), on the shared document model: the layout is data (layout.yaml,
// every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines `fb engines gen`
// generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured coordinates or
// forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// GUAM-FORM-003 (GRAP 16(a)(5)(A)): a proportionally spaced serif face; Times New Roman (Liberation Serif its metric
// twin, docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let guam-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
