// Entry point. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "pa-petition-for-discretionary-review.typ": pa-petition-for-discretionary-review, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-discretionary-review.md"))
#let (meta, body) = split-frontmatter(src)
#pa-petition-for-discretionary-review(meta, body)
