// Entrypoint. tools/render.sh compiles it with this folder as --root:
//   sh tools/render.sh courts/ninth-circuit/hawaii/federal/district/motion-brief usage/INPUT-<id>.md
// The sample is read from the folder; the template lives in hid-motion-brief.typ.
#import "hid-motion-brief.typ": hid-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#hid-motion-brief(meta, body)
