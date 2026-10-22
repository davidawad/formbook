// Court of Appeals of the State of Nevada (nevapp): motion (NRAP 27), on the shared document model: the layout is
// data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// NEVAPP-FORM-004 (NRAP 32(a)(5)(A), applied to motions by NRAP 27(d)(1)(E)): Times New Roman is named as a
// proportionally spaced face; Liberation Serif is its metric twin (docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let nevapp-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
