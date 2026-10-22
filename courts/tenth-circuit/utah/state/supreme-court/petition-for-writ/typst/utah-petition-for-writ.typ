// Utah Supreme Court (utah): petition for writ, on the shared document model: the layout is data (layout.yaml,
// every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines `fb engines gen`
// generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured coordinates or
// forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// UTAH-FORM-003: proportionally spaced, no face is named: Times New Roman (Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let utah-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
