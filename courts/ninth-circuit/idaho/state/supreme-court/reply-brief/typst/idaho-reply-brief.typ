// Supreme Court of Idaho (idaho): reply brief, on the shared document model: the layout is data (layout.yaml,
// every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines `fb engines gen`
// generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured coordinates or forced
// breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// IDAHO-FORM-005 (I.A.R. 36(b)(2)) names Times New Roman; Liberation Serif is its metric twin (docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let idaho-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
