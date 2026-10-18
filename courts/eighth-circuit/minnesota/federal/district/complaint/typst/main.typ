// Entry point. tools/render.sh compiles it with this folder as --root:
//   sh tools/render.sh courts/eighth-circuit/minnesota/federal/district/complaint usage/<id>.md usage/<id>.pdf
#import "mnd-complaint.typ": mnd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#mnd-complaint(meta, body)
