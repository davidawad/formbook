// Entry point. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "va-motion-brief.typ": va-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#va-motion-brief(meta, body)
