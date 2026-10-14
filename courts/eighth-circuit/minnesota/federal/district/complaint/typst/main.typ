// Entry point. tools/render.sh compiles it with this folder as --root:
//   sh tools/render.sh courts/eighth-circuit/minnesota/federal/district/complaint samples/<id>.md samples/<id>.pdf
#import "mnd-complaint.typ": mnd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-3m-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#mnd-complaint(meta, body)
