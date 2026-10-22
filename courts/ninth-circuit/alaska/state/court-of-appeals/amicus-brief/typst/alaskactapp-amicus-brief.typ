// Court of Appeals of the State of Alaska (alaskactapp): amicus curiae brief, on the shared document model: the
// layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx
// engines `fb engines gen` generates from this folder (fb-595.54.12). Requirement IDs (ALASKACTAPP-...) refer to
// ../../rules.md. Content-agnostic: no case-specific text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// ALASKACTAPP-FORM-003: proportionally spaced Times New Roman (Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let alaskactapp-amicus-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
