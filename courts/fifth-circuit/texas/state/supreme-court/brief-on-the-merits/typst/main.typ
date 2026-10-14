#import "tex-brief-on-the-merits.typ": render, split-frontmatter
#let src = read("/" + sys.inputs.at("sample", default: "samples/brief-on-the-merits.md"))
#let (meta, body) = split-frontmatter(src)
#render(meta, body)
