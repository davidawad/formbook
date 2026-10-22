// Nevada Supreme Court (nev): brief on the merits (appellant's opening brief), on the shared document model: the
// layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx
// engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text,
// measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// NEV-FORM-004 (NRAP 32(a)(5)(A)): a proportionally spaced face such as Times New Roman, 14-point or larger; Liberation
// Serif is its metric-compatible substitute (docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let nev-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
