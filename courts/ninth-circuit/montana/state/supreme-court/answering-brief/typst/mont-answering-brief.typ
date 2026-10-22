// Montana Supreme Court (mont): answer brief (appellee's principal brief, MRAP 12(2)), on the shared document model: the
// layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx
// engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// MRAP 11(2) (MONT-FORM-003): Times New Roman, the declared face; Liberation Serif its metric twin (docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let mont-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
