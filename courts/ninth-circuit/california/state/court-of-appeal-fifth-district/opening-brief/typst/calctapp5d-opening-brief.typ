// California Court of Appeal, Fifth Appellate District: appellant's opening brief, on the shared document model
// (lib/typst/xdoc.typ): every number and block is in layout.yaml, each with its rule.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

#let font-family = "EB Garamond"   // CALCTAPP5D-FORM-002 (CRC 8.204(b)(2), 8.74(b)(1)): a proportionally spaced serif; vendored in /fonts

#let calctapp5d-opening-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
