// Connecticut Appellate Court (connappct): petition for review, on the shared document model: the
// layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx
// engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text,
// measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// CONNAPPCT-PET-003, CONNAPPCT-FORM-010: a 12 point serif face; the rule names none, the template declares Times New Roman
// (Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let connappct-petition-for-review(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
