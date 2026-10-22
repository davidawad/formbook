// Sixth District Court of Appeal of Florida (fladistctapp6): initial brief (Fla. R. App. P. 9.210), on the shared document model: the layout is data
// (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// FLADISTCTAPP6-FORM-003 (Fla. R. App. P. 9.045(b)): Arial 14-point; Liberation Sans is the metric-compatible Arial
// vendored in fonts/liberation-sans (docs/FONTS.md).
#let font-family = "Liberation Sans"

#let fladistctapp6-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
