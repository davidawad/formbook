// Supreme Court of Virginia (va): amicus curiae brief (Rule 5:30), on the shared document model: the
// layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx
// engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text,
// measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// Rule 5:6(a)(3) and the Court's List of Acceptable Fonts (../rules.md VA-FORM-002): Times New Roman; Liberation Serif
// its metric twin.
#let font-family = ("Times New Roman", "Liberation Serif")

#let va-amicus-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
