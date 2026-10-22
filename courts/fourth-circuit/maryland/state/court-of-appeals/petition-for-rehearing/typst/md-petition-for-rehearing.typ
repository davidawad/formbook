// Court of Appeals of Maryland (Supreme Court of Maryland, md): motion for reconsideration (petition for rehearing), on the shared document
// model: the layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex
// and docx engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific
// text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// MD-FORM-003: a face on the Court's approved list (Administrative Order of Sept. 27, 2023): Times New Roman
// (Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let md-petition-for-rehearing(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
