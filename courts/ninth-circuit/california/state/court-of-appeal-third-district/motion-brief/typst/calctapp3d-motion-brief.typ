// California Court of Appeal, Third Appellate District (calctapp3d): motion with memorandum (CRC 8.54, 8.74), on the
// shared document model: the layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here
// and by the latex and docx engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no
// case-specific text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// CALCTAPP3D-FORM-002: Century Schoolbook is preferred by rule 8.74(b)(1); TeX Gyre Schola is its substitute
// (docs/FONTS.md), vendored in /fonts.
#let font-family = "TeX Gyre Schola"

#let calctapp3d-motion-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
