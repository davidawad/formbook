// Supreme Court of Georgia: petition for certiorari (Ga. Sup. Ct. R. 38-45), on the shared document model: the layout
// is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// GA-SC-FONT-001, -002: Rule 16(1) names the Century family and Rule 16(2) sizes the text by Century Schoolbook;
// TeX Gyre Schola is the vendored Century Schoolbook (docs/FONTS.md).
#let font-family = "TeX Gyre Schola"

#let ga-petition-for-discretionary-review(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
