// Entrypoint. tools/render.sh compiles it with --root <court-dir> and --input sample=usage/NAME.md.
#import "sc-motion-brief.typ": sc-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#sc-motion-brief(meta, body)
