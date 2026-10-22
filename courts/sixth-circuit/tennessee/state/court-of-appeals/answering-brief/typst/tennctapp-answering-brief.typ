// Court of Appeals of Tennessee (tennctapp): appellee's principal brief (answering brief, Tenn. R. App. P. 27(b)),
// e-filed PDF, on the shared document model: the layout is data (layout.yaml, every number with its rule), set by
// lib/typst/xdoc.typ here and by the latex and docx engines `fb engines gen` generates from this folder
// (fb-595.54.12). Content-agnostic: no case-specific text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// TENNCTAPP-FORM-002 (Tenn. Sup. Ct. R. 46 § 3.02(3)(a)): any font within the Century family; TeX Gyre Schola is the
// vendored Century Schoolbook (docs/FONTS.md).
#let font-family = "TeX Gyre Schola"

#let tennctapp-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
