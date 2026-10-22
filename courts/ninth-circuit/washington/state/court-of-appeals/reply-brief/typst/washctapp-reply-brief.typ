// Court of Appeals of the State of Washington (washctapp): reply brief, on the shared document model: the layout is
// data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// WASHCTAPP-FORM-004 (RAP 18.17(a)(2)): a serif face equivalent to Times New Roman; Liberation Serif is its metric
// twin (docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let washctapp-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
