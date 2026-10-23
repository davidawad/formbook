// Mississippi chancery courts (misschanceryct): memorandum in support of a motion (motion-brief), on the shared
// document model. Every number and block of the layout is in layout.yaml, each with its rule (../../rules.md); this file
// names the face.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

#let font-family = ("Times New Roman", "Liberation Serif")  // no retrieved rule names a face (MISSCHANCERYCT-FORM-003); docs/FONTS.md

#let misschanceryct-motion-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
