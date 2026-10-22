// Intermediate Court of Appeals of West Virginia (wvactapp): respondent's brief, on the shared document model: the
// layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx
// engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text,
// measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// RAP 38(a) (WVACTAPP-FORM-002): proportionally spaced serif; no face is named: Times New Roman (Liberation Serif its
// metric twin, docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

#let wvactapp-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
