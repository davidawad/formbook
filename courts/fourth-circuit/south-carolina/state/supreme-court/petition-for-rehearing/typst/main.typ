// Entrypoint. tools/render.sh compiles it with --root <court-dir> and --input sample=usage/NAME.md.
#import "sc-petition-for-rehearing.typ": sc-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-rehearing.md"))
#let (meta, body) = split-frontmatter(src)
#sc-brief(meta, body)
