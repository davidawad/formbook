// California Court of Appeal, Fifth Appellate District (calctapp5d): motion, on the shared document model: the layout
// is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// CALCTAPP5D-FORM-002: any conventional font; EB Garamond, a proportionally spaced serif (vendored in /fonts).
#let font-family = ("Times New Roman", "Liberation Serif") // CRC 8.204(b)(2) allows any conventional font (Century Schoolbook only preferred, 8.74(b)(1)); the exemplar is Times New Roman, the house face (docs/FONTS.md rule 6; fb-9fyu)

#let calctapp5d-motion-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
