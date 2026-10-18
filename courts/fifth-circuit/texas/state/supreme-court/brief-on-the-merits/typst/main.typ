#import "tex-brief-on-the-merits.typ": render-doc, split-frontmatter
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-tex-brief-on-the-merits-hawthorne.md"))
#let (meta, body) = split-frontmatter(src)
#render-doc(meta, body)
