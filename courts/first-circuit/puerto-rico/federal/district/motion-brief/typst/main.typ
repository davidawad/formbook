#import "prd-motion-brief.typ": prd-motion-brief, split-frontmatter
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#prd-motion-brief(meta, body)
