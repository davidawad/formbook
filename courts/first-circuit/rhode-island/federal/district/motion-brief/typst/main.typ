#import "rid-motion-brief.typ": rid-motion-brief, split-frontmatter
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#rid-motion-brief(meta, body)
