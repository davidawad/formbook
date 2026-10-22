// Supreme Court of Georgia: petition for certiorari (Ga. Sup. Ct. R. 38-45), on the shared document model: the layout
// is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// GA-SC-FONT-001: a proportionally spaced serif (Rule 16(1)); Times New Roman, the filed exemplars' face (docs/FONTS.md
// rule 6); Liberation Serif its metric twin.
#let font-family = ("Times New Roman", "Liberation Serif")

#let ga-petition-for-review(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
