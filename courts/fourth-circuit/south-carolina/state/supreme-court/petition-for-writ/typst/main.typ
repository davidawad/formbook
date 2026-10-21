// Entrypoint. tools/render.sh compiles it with --root <court-dir> and --input sample=usage/NAME.md.
#import "sc-petition-for-writ.typ": sc-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-writ.md"))
#let (meta, body) = split-frontmatter(src)
#sc-brief(meta, body)
