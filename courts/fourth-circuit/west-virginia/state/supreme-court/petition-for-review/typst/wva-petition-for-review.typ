// Supreme Court of Appeals of West Virginia (wva): petition for review of a Public Service Commission order, a brief
// of the petitioner in Rule 10 form (RAP 14(d), 38, 38A; see ../../rules.md, WVA-FORM, -COVER, -CONT, -LEN, -CERT
// rows). On the shared document model: the layout is data (layout.yaml, every number with its source), set by
// lib/typst/xdoc.typ here and by the latex and docx engines `fb engines gen` generates from this folder
// (fb-595.54.12). Content-agnostic: no case-specific text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// WVA-TPL-002: Times New Roman, Liberation Serif its metric twin (RAP 38(a) names no face; docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let wva-petition-for-review(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
