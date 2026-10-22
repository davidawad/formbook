// Court of Appeals of Kansas (kanctapp): opening-brief, on the shared document model: the layout is data (layout.yaml, every
// number with its source), set by lib/typst/xdoc.typ here and by the latex and docx engines `fb engines gen`
// generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured coordinates or forced
// breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// KANCTAPP-FORM-002: the exemplars set Times; Times New Roman (Liberation Serif its metric twin), docs/FONTS.md.
#let font-family = ("Times New Roman", "Liberation Serif")

#let kanctapp-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
