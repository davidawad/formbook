// Court of Criminal Appeals of Texas (texcrimapp): the motion for rehearing (TRAP 79, 9.4), on the shared document
// model: the layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex
// and docx engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific
// text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// TRAP 9.4(e) names no typeface (TEXCRIMAPP-FORM-006): Times New Roman, Liberation Serif its metric twin.
#let font-family = ("Times New Roman", "Liberation Serif")

#let texcrimapp-petition-for-rehearing(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
