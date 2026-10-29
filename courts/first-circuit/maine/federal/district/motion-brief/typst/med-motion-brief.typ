// Motion brief on the FRCP base with D. Me. local rules overlaid in layout.yaml.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter
#let font-family = ("Times New Roman", "Liberation Serif")
#let med-motion-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
