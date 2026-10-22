// Supreme Court of Iowa (iowa): petition for rehearing, on the shared document model: the layout is data (layout.yaml, every number
// with its rule), set by lib/typst/xdoc.typ here and by the latex and docx engines `fb engines gen` generates from this
// folder (fb-595.54.12). Content-agnostic: no case-specific text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// IOWA-FORM-004 (6.903(1)(g)(1)): serif, proportional; Times New Roman is a listed example (Liberation Serif its
// metric twin, docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")

// The PDF title: the document title, its lines joined (the frontmatter may give it as a list of lines).
#let title-of(meta) = { let t = meta.at("brief_title", default: ""); if type(t) == array { t.join(" ") } else { t } }

#let iowa-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta + (title: title-of(meta)), body)
