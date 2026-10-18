// Entry point. tools/render.sh compiles it with the doc-type folder as --root:
//   sh tools/render.sh courts/first-circuit/maine/federal/district/complaint usage/INPUT-<id>.md
#import "med-complaint.typ": med-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-med-complaint-tacobarr.md"))
#let (meta, body) = split-frontmatter(src)
#med-complaint(meta, body)
