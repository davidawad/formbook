// Entry point. tools/render.sh compiles it with the doc-type folder as --root:
//   sh tools/render.sh courts/fifth-circuit/texas/federal/western-district/motion-brief usage/INPUT-<id>.md
// Vendored fonts only (--ignore-system-fonts); any typst warning fails the render.
#import "txwd-motion-brief.typ": txwd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#txwd-motion-brief(meta, body)
