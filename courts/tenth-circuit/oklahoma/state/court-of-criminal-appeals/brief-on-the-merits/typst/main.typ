#import "oklacrimapp-brief-on-the-merits.typ": render-doc, split-frontmatter
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-brief-on-the-merits.md"))
#let (meta, body) = split-frontmatter(src)
#render-doc(meta, body)
