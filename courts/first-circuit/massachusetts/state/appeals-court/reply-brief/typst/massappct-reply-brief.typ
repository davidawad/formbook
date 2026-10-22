// Massachusetts Appeals Court (massappct): reply brief (MRAP 16(c), 20), on the shared document model: the
// layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx
// engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text,
// measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// Times New Roman, the face MRAP 20(a)(4)(B)(ii) gives as its example; Liberation Serif its metric twin.
#let font-family = ("Times New Roman", "Liberation Serif")

#let massappct-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
