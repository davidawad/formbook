// Tennessee Supreme Court (tenn): motion, Tenn. R. App. P. 22 and 30, on the shared document model: the
// layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx
// engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text,
// measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// TENN-FORM-004 (Tenn. Sup. Ct. R. 46 § 3.02.3(a)): any font within the Century family; TeX Gyre Schola is the
// vendored Century Schoolbook.
#let font-family = "TeX Gyre Schola"

#let tenn-motion-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
