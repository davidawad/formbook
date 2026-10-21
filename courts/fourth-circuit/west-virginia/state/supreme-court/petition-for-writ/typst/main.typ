// Entry point. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "wva-petition-for-writ.typ": wva-petition-for-writ, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-writ.md"))
#let (meta, body) = split-frontmatter(src)
#wva-petition-for-writ(meta, body)
