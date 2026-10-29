#import "mad-motion-brief.typ": mad-motion-brief, split-frontmatter
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#mad-motion-brief(meta, body)
