// Florida Fifth District Court of Appeal (fladistctapp5): amicus curiae brief, on the shared document model: the layout is data
// (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// FLADISTCTAPP5-FORM-005 (Rule 9.045(b)): Bookman Old Style 14 point; TeX Gyre Bonum is its vendored clone (docs/FONTS.md).
#let font-family = "TeX Gyre Bonum"

#let fladistctapp5-amicus-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
