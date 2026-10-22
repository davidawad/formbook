// Court of Appeal of Louisiana (lactapp): one filing of a Louisiana Court of Appeal, on the shared document model: the
// layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx
// engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text,
// measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// LACTAPP-FORM-002 (ULCA 2-12.2(D)(2)): "Roman or Times New Roman" (Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let lactapp-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
