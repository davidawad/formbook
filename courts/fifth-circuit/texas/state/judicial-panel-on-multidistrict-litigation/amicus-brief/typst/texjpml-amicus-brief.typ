// Texas Judicial Panel on Multidistrict Litigation (texjpml): amicus curiae letter brief (amicus-brief), on the shared
// document model: the layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by
// the latex and docx engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no
// case-specific text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// TEXJPML-FORM-006: no retrieved rule names a face; Times New Roman (the exemplars' face and the house standard,
// docs/FONTS.md), Liberation Serif its metric twin.
#let font-family = ("Times New Roman", "Liberation Serif")

#let texjpml-letter(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
