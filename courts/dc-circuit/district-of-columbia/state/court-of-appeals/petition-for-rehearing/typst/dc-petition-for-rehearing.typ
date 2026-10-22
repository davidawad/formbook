// District of Columbia Court of Appeals (dc): petition for division rehearing or rehearing en banc (Rule 40; form per Rule 32), on the shared document model: the layout is data
// (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// DC-FORM-004 (Rule 32 (a) (4)), DC-FORM-005 (Rule 27 (d) (1) (C)): Times New Roman, the face the rules name
// (Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let dc-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
