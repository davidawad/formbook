#import "med-motion-brief.typ": med-motion-brief, split-frontmatter
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#med-motion-brief(meta, body)
