// Entry point. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "md-petition-for-rehearing.typ": md-petition-for-rehearing, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-rehearing.md"))
#let (meta, body) = split-frontmatter(src)
#md-petition-for-rehearing(meta, body)
