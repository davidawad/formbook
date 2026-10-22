// Court of Criminal Appeals of Texas (texcrimapp): motion for stay of execution (TRAP 10.1; 9.4), on the shared
// document model: the layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by
// the latex and docx engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no
// case-specific text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// TRAP 9.4(e) names no typeface: Times New Roman, the default per docs/FONTS.md; Liberation Serif its metric twin.
#let font-family = ("Times New Roman", "Liberation Serif")

#let texcrimapp-motion-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
