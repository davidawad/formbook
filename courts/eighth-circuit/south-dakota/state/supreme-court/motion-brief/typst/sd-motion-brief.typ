// Supreme Court of South Dakota (sd): motion (motion-brief), on the shared document model: the layout is data
// (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// SD-FORM-006 (SDCL 15-26A-66(b)): a proportionally spaced face with serifs, none named: Times New Roman (the house
// standard, docs/FONTS.md), Liberation Serif its metric twin.
#let font-family = ("Times New Roman", "Liberation Serif")

#let sd-motion(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
