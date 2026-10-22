// Supreme Court of the State of Alaska (alaska): reply brief, on the shared document model: the layout is data
// (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// ALASKA-FORM-003: Times New Roman, one of the faces ARAP 513.5(c)(1)(A) names (Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let alaska-reply-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
