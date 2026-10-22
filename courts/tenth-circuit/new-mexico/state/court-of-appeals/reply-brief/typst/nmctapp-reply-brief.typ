// New Mexico Court of Appeals (nmctapp): reply brief, on the shared document model: the layout is data (layout.yaml,
// every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines `fb engines gen`
// generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured coordinates or forced
// breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// NMCTAPP-FORM-004 (NMRA 12-305(D)(1)): proportionally spaced, with serifs, such as Times New Roman (Liberation Serif
// its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let nmctapp-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
