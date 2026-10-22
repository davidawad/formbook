// Court of Appeals of Wisconsin (wisctapp): motion (Wis. Stat. 809.14), on the shared document model: the layout is
// data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// Wis. Stat. 809.19(8)(b)3.c names no face; docs/FONTS.md gives a court that names none Liberation Serif.
#let font-family = ("Liberation Serif",)

#let wisctapp-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
