// Supreme Court of the Commonwealth of the Northern Mariana Islands (nmi): answering brief (NMI Sup. Ct. R. 28(b),
// 32), on the shared document model: the layout is data (layout.yaml, every number with its rule), set by
// lib/typst/xdoc.typ here and by the latex and docx engines `fb engines gen` generates from this folder
// (fb-595.54.12). Content-agnostic: no case-specific text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// NMI-TMPL-002: plain Times New Roman (Rule 32(a)(6), advisory); Liberation Serif its metric twin (docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let nmi-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
