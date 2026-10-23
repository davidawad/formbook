// Ohio Supreme Court (ohio): motion for reconsideration (RoP 18.02), on the shared document model: the layout is data (layout.yaml,
// every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines `fb engines gen`
// generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured coordinates or forced
// breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// OHIO-FORM-003: Times New Roman, the face RoP 3.09(B)(1)(b) lists first and the exemplars use; Liberation Serif its
// metric twin (docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let ohio-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
