// Connecticut Supreme Court (conn): petition for certification (Practice Book § 84-5), on the shared document model: the layout is data
// (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// CONN-PET-005, CONN-FORM-002 (P.B. 84-5(b), 67-2A(b)): a serif face; Times New Roman (its metric twin vendored).
#let font-family = ("Times New Roman", "Liberation Serif")

#let conn-petition-for-discretionary-review(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
