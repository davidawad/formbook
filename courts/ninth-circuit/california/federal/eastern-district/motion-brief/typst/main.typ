// Entry point. tools/render.sh compiles it with this folder as --root, the vendored fonts only:
//   sh tools/render.sh courts/ninth-circuit/california/federal/eastern-district/motion-brief usage/INPUT-<id>.md
// The sample's frontmatter and body are read from usage/ (see ../README.md for the markdown contract).
#import "caed-motion-brief.typ": caed-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-caed-motion-brief-wine.md"))
#let (meta, body) = split-frontmatter(src)
#caed-motion-brief(meta, body)
