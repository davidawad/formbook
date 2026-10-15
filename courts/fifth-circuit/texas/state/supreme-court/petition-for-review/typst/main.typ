#import "tex-petition-for-review.typ": render-doc, split-frontmatter
#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-hawthorne-petition-for-review.md"))
#let (meta, body) = split-frontmatter(src)
#render-doc(meta, body)
