// Entry point. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "wva-petition-for-review.typ": wva-petition-for-review, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-review.md"))
#let (meta, body) = split-frontmatter(src)
#wva-petition-for-review(meta, body)
