// Court of Appeals of North Carolina (ncctapp): petition for a writ of mandamus or prohibition (N.C. R. App. P. 22), on the shared document
// model: the layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the
// latex and docx engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no
// case-specific text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// NCCTAPP-FORM-001: a proportionally spaced serif face (Rule 26(g)(1)); Times New Roman, Liberation Serif its metric twin.
#let font-family = ("Times New Roman", "Liberation Serif")

#let ncctapp-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
