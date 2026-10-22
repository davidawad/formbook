// Supreme Court of South Carolina (sc): amicus curiae brief (SCACR 213, 208(b), 211, 267), on the shared document
// model: the layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex
// and docx engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific
// text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// SC-FORM-003: the rules set no face; the template declares Times New Roman (Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let sc-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
