// Entry point. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "md-petition-for-review.typ": md-petition-for-review, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-review.md"))
#let (meta, body) = split-frontmatter(src)
#md-petition-for-review(meta, body)
