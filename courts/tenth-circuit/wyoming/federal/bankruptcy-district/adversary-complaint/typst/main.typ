// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   sh tools/render.sh courts/tenth-circuit/wyoming/federal/bankruptcy-district/adversary-complaint usage/INPUT-adversary-complaint.md
#import "wyb-adversary-complaint.typ": wyb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-adversary-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#wyb-adversary-complaint(meta, body)
