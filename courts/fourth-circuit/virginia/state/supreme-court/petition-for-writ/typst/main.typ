// Entry point. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "va-petition-for-writ.typ": va-petition-for-writ, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-writ.md"))
#let (meta, body) = split-frontmatter(src)
#va-petition-for-writ(meta, body)
