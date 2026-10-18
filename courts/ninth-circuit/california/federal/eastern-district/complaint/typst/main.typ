// Entry point. tools/render.sh compiles it with this folder as --root, the vendored fonts only:
//   sh tools/render.sh courts/ninth-circuit/california/federal/eastern-district/complaint usage/INPUT-<id>.md
// The sample's frontmatter and body are read from usage/ (see ../README.md for the markdown contract).
#import "caed-complaint.typ": caed-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#caed-complaint(meta, body)
