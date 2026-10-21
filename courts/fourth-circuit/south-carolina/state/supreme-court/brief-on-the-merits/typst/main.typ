// Entrypoint. tools/render.sh compiles it with --root <court-dir> and --input sample=usage/NAME.md.
#import "sc-brief-on-the-merits.typ": sc-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-brief-on-the-merits.md"))
#let (meta, body) = split-frontmatter(src)
#sc-brief(meta, body)
