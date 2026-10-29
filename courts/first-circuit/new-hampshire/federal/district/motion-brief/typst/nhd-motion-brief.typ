// Motion brief on the FRCP base with D.N.H. local rules overlaid in layout.yaml.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter
#let font-family = ("Times New Roman", "Liberation Serif")
#let nhd-motion-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
