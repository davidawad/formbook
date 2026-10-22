// Court of Appeals of Ohio (ohioctapp): motion with its memorandum in support (App.R. 15 (A)), on the shared document
// model: the layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex
// and docx engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific
// text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// OHIOCTAPP-FORM-004: no face is named by App.R. 19; Times New Roman is declared and the filed example uses it.
// Liberation Serif is its metric twin (docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let ohioctapp-motion-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
