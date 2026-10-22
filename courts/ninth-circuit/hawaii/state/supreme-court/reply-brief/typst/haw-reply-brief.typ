// Supreme Court of Hawaii (haw): reply brief, on the shared document model: the layout is data
// (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// HAW-FORM-003: 12-point Times New Roman is deemed to satisfy HRAP 32(b); Liberation Serif is its metric twin.
#let font-family = ("Times New Roman", "Liberation Serif")

#let haw-reply-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
