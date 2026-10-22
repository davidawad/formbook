// Montana Supreme Court (mont): amicus curiae brief (MRAP 12(7)), on the shared document model: the layout is data
// (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks. Cover unnumbered, contents in roman, the brief from 1, the two certificates after it.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// MRAP 11(2) (MONT-FORM-003): Times New Roman, the declared face; Liberation Serif its metric twin (docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let mont-brief-amicus(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
