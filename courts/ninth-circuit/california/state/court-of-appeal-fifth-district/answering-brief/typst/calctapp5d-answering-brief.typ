// California Court of Appeal, Fifth Appellate District: appellee's answering brief, on the shared document model
// (lib/typst/xdoc.typ): every number and block is in layout.yaml, each with its rule.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

#let font-family = ("Times New Roman", "Liberation Serif")   // CRC 8.204(b)(2) allows any conventional font (Century Schoolbook only preferred, 8.74(b)(1)); the exemplar is Times New Roman, the house face (docs/FONTS.md rule 6; fb-9fyu)

#let calctapp5d-answering-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
