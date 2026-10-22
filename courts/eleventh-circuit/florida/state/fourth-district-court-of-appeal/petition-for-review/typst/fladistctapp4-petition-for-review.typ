// Florida Fourth District Court of Appeal (fladistctapp4): petition for review of non-final agency action, on the
// shared document model: the layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here
// and by the latex and docx engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no
// case-specific text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// FLADISTCTAPP4-FORM-005 (Rule 9.045(b)): Arial 14 point; Liberation Sans is its metric twin (docs/FONTS.md).
#let font-family = "Liberation Sans"

#let fladistctapp4-petition-for-review(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
