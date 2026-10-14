// Entry point. tools/render.sh compiles it with the doc-type folder as --root:
//   sh tools/render.sh courts/fifth-circuit/louisiana/federal/eastern-district/complaint samples/INPUT-<id>.md
// Vendored fonts only (--ignore-system-fonts); any typst warning fails the render.
#import "laed-complaint.typ": laed-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-buckles-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#laed-complaint(meta, body)
