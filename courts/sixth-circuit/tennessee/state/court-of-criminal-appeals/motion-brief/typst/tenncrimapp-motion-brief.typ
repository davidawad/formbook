// Court of Criminal Appeals of Tennessee (tenncrimapp): motion-brief (e-filed form), on the shared document model:
// the layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and
// docx engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text,
// measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// TENNCRIMAPP-FORM-004 (SCT-46 3.02(3)(a)): any font in the Century family; TeX Gyre Schola is the vendored Century
// Schoolbook clone (docs/FONTS.md).
#let font-family = "TeX Gyre Schola"

#let tenncrimapp-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
