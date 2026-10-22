// Supreme Court of New Hampshire: motion-brief, on the shared document model: the layout is data (layout.yaml, every
// number with its rule; requirement IDs NH-... refer to ../../rules.md), set by lib/typst/xdoc.typ here and by the
// latex and docx engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no
// case-specific text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// FONT STANDARD: Times New Roman (no court rule names another face; Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let nh-motion-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
