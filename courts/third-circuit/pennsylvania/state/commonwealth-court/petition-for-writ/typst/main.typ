// Entrypoint. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "pacommwct-petition-for-writ.typ": pacommwct-writ, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-writ.md"))
#let (meta, body) = split-frontmatter(src)
#pacommwct-writ(meta, body)
