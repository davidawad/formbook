// New York Supreme Court, Appellate Division (nyappdiv): amicus curiae brief, on the shared document model: the
// layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx
// engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text,
// measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// NYAPPDIV-FORM-001 (1250.8(f)(1)): a serifed, proportionally spaced face; Times New Roman, the exemplar's, and its
// metric twin Liberation Serif.
#let font-family = ("Times New Roman", "Liberation Serif")

#let nyappdiv-amicus-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
