// Supreme Court of Alabama (ala): reply brief (ARAP 28(c)).
// On the shared document model: the layout is data
// (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// ALA-FORM-004, -005 (ARAP 32(a)(7)): Century Schoolbook 14; TeX Gyre Schola is its clone (docs/FONTS.md).
#let font-family = "TeX Gyre Schola"

#let ala-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
