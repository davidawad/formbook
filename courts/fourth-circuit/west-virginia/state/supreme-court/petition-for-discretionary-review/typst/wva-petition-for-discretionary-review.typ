// Supreme Court of Appeals of West Virginia (wva): petition for discretionary review of an Intermediate Court of
// Appeals decision, filed as a Rule 10 brief (RAP 10, 38, 38A; see ../../rules.md, WVA-FORM and WVA-CONT rows). On
// the shared document model: the layout is data (layout.yaml, every number with its source), set by
// lib/typst/xdoc.typ here and by the latex and docx engines `fb engines gen` generates from this folder
// (fb-595.54.12). Content-agnostic: no case-specific text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// WVA-TPL-002: Times New Roman, Liberation Serif its metric twin (RAP 38(a) names no face; docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let wva-petition-for-discretionary-review(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
