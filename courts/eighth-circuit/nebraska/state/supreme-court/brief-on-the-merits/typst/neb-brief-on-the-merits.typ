// Nebraska Supreme Court (neb): appellant's brief (brief on the merits), on the shared document model (lib/typst/xdoc.typ; the layout in
// layout.yaml, every number with its rule, ../../rules.md).
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// NEB-FORM-006 (§ 2-103(A)(4)): Century Schoolbook preferred; TeX Gyre Schola is its vendored clone (docs/FONTS.md).
#let font-family = "TeX Gyre Schola"

#let neb-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
