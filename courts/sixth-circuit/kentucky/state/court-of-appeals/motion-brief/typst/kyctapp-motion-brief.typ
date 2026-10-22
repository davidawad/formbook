// Kentucky Court of Appeals (kyctapp): a motion with its argument (RAP 7, RAP 21; RAP 5 form), on the shared document
// model: the layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex
// and docx engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific
// text, measured coordinates or forced line breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// KYCTAPP-FORM-005 (RAP 31 (A) (2)): a readable serif face is recommended; Times New Roman is one named. Liberation
// Serif is its metric twin (docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let kyctapp-motion(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
