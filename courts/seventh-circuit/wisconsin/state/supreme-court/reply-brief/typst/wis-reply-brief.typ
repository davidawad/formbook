// Supreme Court of Wisconsin (wis): reply brief (Wis. Stat. 809.19(4), 809.63), on the shared document model: the layout
// is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// SUPCT-FORM-003 (809.19(8)(b)3.b-c, 809.81(3)): a proportional serif face; none is named: Times New Roman
// (Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let wis-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
