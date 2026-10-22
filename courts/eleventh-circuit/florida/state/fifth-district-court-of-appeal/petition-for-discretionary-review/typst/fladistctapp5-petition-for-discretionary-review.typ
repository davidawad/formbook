// Florida Fifth District Court of Appeal (fladistctapp5): petition for discretionary review, on the shared document model: the layout is data
// (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// FLADISTCTAPP5-FORM-005 (Rule 9.045(b)): Arial 14 point; Liberation Sans is its metric twin (docs/FONTS.md).
#let font-family = "Liberation Sans"

#let fladistctapp5-petition(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
