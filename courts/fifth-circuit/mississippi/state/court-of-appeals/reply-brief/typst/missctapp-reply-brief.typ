// Court of Appeals of Mississippi (missctapp): reply brief (MRAP 28(d)), on the shared document model: the layout is
// data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// MISSCTAPP-FORM-005: MRAP 32(a) names no typeface; Times New Roman (Liberation Serif its metric twin), the face
// MISSCTAPP-FORM-006 names for an e-filed brief's title.
#let font-family = ("Times New Roman", "Liberation Serif")

// The PDF title: the case number (the frontmatter's brief_title is a list of lines).
#let missctapp-filing(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta + (title: meta.case_number), body)
