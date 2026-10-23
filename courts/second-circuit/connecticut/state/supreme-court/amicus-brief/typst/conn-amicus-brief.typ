// Connecticut Supreme Court (conn): amicus curiae brief (P.B. 67-7A), on the shared document model: the layout is data
// (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks. Requirement IDs (CONN-...) refer to ../../rules.md.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// CONN-FORM-002 (P.B. 67-2A(b)): a serif face; Times New Roman (Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let conn-amicus-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
