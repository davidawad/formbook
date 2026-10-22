// Supreme Court of Wyoming (wyo): reply brief (reply-brief), on the shared document model: the layout
// is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// WYO-FORM-005: an easily readable font; Times New Roman, the face of the filed exemplars (WYO-FORM-008; Liberation
// Serif its metric twin, docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let wyo-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
