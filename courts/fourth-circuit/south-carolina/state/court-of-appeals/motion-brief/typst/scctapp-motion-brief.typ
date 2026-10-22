// Court of Appeals of South Carolina (scctapp): motion, return or memorandum (R240(c)), on the shared document model: the layout
// is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// SCCTAPP-FORM-003: R267(c) sets a size, not a face; Times New Roman (Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let scctapp-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
