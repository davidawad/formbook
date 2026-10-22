// California Court of Appeal, Fifth Appellate District (calctapp5d): motion, on the shared document model: the layout
// is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// CALCTAPP5D-FORM-002: any conventional font; EB Garamond, a proportionally spaced serif (vendored in /fonts).
#let font-family = "EB Garamond"

#let calctapp5d-motion-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
