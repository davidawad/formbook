// Nebraska Court of Appeals (nebctapp): appellee's brief (answering-brief), on the shared document model: the layout is
// data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines
// `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text, measured
// coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// NEBCTAPP-FORM-006: Century or Century Schoolbook preferred, Times New Roman allowed; Times New Roman is the house
// standard where the rule allows it (docs/FONTS.md, David 2026-10-17), Liberation Serif its metric twin.
#let font-family = ("Times New Roman", "Liberation Serif")

#let nebctapp-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
