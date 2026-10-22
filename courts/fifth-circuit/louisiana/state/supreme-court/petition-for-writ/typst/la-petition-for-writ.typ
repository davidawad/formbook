// Supreme Court of Louisiana (la): a writ application under Rule X, on the shared document model: the layout is data
// (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// LA-FORM-006, LA-TPL-002: the rules name no face; the filed exemplars are Times New Roman (Liberation Serif its
// metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let la-petition-for-writ(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
