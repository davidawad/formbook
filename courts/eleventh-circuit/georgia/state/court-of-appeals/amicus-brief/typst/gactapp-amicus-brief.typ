// Court of Appeals of Georgia (gactapp): amicus curiae brief, on the shared document model: the layout is data
// (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// GACTAPP-FORM-002, -003 (Rule 2 (c) (3)): a serif face; Times New Roman is named as compliant (Liberation Serif its
// metric twin, docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let gactapp-amicus-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
