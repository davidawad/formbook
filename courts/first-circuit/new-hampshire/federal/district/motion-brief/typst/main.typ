#import "nhd-motion-brief.typ": nhd-motion-brief, split-frontmatter
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#nhd-motion-brief(meta, body)
