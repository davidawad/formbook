#import "tex-petition-for-review.typ": render, split-frontmatter
#let src = read("/" + sys.inputs.at("sample", default: "samples/petition-for-review.md"))
#let (meta, body) = split-frontmatter(src)
#render(meta, body)
