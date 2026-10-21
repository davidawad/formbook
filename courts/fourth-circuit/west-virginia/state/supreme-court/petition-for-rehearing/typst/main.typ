// Entry point. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "wva-petition-for-rehearing.typ": wva-petition-for-rehearing, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-rehearing.md"))
#let (meta, body) = split-frontmatter(src)
#wva-petition-for-rehearing(meta, body)
