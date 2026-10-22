// Kentucky Court of Appeals (kyctapp): appellant's reply brief (RAP 32 (C)), on the shared document model: the layout
// is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// KYCTAPP-FORM-005 (RAP 31 (A) (2)): an easily readable serif face; Times New Roman is one the rule names. Liberation
// Serif is its metric twin (docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let kyctapp-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
