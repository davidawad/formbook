// Entry point. tools/render.sh compiles it with this folder as --root:
//   sh tools/render.sh courts/eighth-circuit/minnesota/federal/district/motion-brief usage/<id>.md usage/<id>.pdf
#import "mnd-motion-brief.typ": mnd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#mnd-motion-brief(meta, body)
