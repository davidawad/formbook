// Supreme Court of Mississippi (miss): motion for rehearing (Rule 40), on the shared document model: the layout is
// data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// MISS-FORM-005: the rule names no typeface: Times New Roman (Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

// The PDF title: the case number, as before (the frontmatter's brief_title is a list of lines).
#let miss-filing(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), (title: meta.case_number) + meta, body)
