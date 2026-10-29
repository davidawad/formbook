// Entry point. tools/render.sh compiles it with this folder as --root:
//   sh tools/render.sh courts/third-circuit/delaware/federal/district/motion-brief usage/<id>.md usage/<id>.pdf
#import "ded-motion-brief.typ": ded-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ded-motion-brief(meta, body)
