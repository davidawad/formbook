// Supreme Court of the State of Delaware (del): a motion, an answer to a motion, or a reply (Rules 13(b), 30), on the
// shared document model: the layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here
// and by the latex and docx engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no
// case-specific text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// Rule 13(a)(i) (../../rules.md DEL-FORM-001, DEL-TPL-002): Times New Roman; Liberation Serif its metric twin.
#let font-family = ("Times New Roman", "Liberation Serif")

#let del-motion(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
