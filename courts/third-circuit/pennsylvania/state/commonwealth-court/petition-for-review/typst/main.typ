// Entrypoint. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "pacommwct-petition-for-review.typ": pacommwct-petition, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-review.md"))
#let (meta, body) = split-frontmatter(src)
#pacommwct-petition(meta, body)
