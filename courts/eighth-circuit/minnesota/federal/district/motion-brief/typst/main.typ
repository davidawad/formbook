// Entry point. tools/render.sh compiles it with this folder as --root:
//   sh tools/render.sh courts/eighth-circuit/minnesota/federal/district/motion-brief samples/<id>.md samples/<id>.pdf
#import "mnd-motion-brief.typ": mnd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-adams-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#mnd-motion-brief(meta, body)
