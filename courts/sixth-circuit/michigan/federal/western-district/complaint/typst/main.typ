// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   sh tools/render.sh courts/sixth-circuit/michigan/federal/western-district/complaint usage/<id>.md
#import "miwd-complaint.typ": miwd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#miwd-complaint(meta, body)
