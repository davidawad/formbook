// Supreme Court of Texas (tex): brief on the merits, on the shared document model: the layout is data (layout.yaml,
// every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines `fb engines gen`
// generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured coordinates or forced
// breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// TEX-FORM-002: Times New Roman, the face of the filed exemplars (TRAP 9.4(e) names none; Liberation Serif its metric
// twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let render-doc(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
