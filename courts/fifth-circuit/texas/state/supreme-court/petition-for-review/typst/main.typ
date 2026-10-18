#import "tex-petition-for-review.typ": render-doc, split-frontmatter
#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-tex-petition-for-review-hawthorne.md"))
#let (meta, body) = split-frontmatter(src)
#render-doc(meta, body)
