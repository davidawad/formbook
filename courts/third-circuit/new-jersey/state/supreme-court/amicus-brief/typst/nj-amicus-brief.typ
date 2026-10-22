// Supreme Court of New Jersey (nj): amicus curiae letter brief (R. 2:6-2(b)), on the shared document model: the layout
// is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// NJ-FORM-003: Times New Roman or a similar face (Liberation Serif its metric twin); the exemplar is set in Times.
#let font-family = ("Times New Roman", "Liberation Serif")

#let nj-amicus-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
