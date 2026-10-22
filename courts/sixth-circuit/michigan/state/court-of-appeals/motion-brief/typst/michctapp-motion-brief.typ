// Michigan Court of Appeals (michctapp): supporting brief for a motion (MCR 7.211(A)(3), 7.212(B)-(C)), on the shared document model: the layout is data
// (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// Times New Roman, the face of every Michigan exemplar (../rules.md); Liberation Serif its metric twin.
#let font-family = ("Times New Roman", "Liberation Serif")

#let michctapp-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
