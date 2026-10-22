// Minnesota Court of Appeals (minnctapp): petition for declaratory judgment on an agency rule (petition-for-review),
// on the shared document model: the layout is data (layout.yaml, every number with its rule), set by
// lib/typst/xdoc.typ here and by the latex and docx engines `fb engines gen` generates from this folder
// (fb-595.54.12). A captioned document without cover or contents (Rule 132.02 subd. 2). Content-agnostic: no
// case-specific text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// Rule 132.02 names no face; Times New Roman is the exemplar's (MINNCTAPP-FORM-007; Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let minnctapp-petition(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
