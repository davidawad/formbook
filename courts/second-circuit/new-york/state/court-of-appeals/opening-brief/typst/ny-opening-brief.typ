// New York Court of Appeals (ny): appellant's principal (opening) brief, normal course appeal, on the shared document model: the layout
// is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// NY-FORM-001: serif, proportional; 22 NYCRR 500.1(i) names Times New Roman as its example face (Liberation Serif its
// metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let ny-opening-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
