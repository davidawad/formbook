// Supreme Court of Oklahoma (okla): reply brief (form per R. 1.11), on the shared document model: the layout is data (layout.yaml,
// every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines `fb engines gen`
// generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured coordinates or
// forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// OKLA-FORM-002: clear type; no face is named: Times New Roman (Liberation Serif its metric twin), as the filed
// briefs.
#let font-family = ("Times New Roman", "Liberation Serif")

#let okla-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
