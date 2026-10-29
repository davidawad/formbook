// Entry point. tools/render.sh compiles it with this folder as --root:
//   sh tools/render.sh courts/third-circuit/new-jersey/federal/district/motion-brief usage/<id>.md usage/<id>.pdf
#import "njd-motion-brief.typ": njd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#njd-motion-brief(meta, body)
