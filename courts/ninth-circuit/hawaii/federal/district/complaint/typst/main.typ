// Entrypoint. tools/render.sh compiles it with this folder as --root:
//   sh tools/render.sh courts/ninth-circuit/hawaii/federal/district/complaint usage/INPUT-<id>.md
// The sample is read from the folder; the template lives in hid-complaint.typ.
#import "hid-complaint.typ": hid-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#hid-complaint(meta, body)
