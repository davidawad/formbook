// Entry point. tools/render.sh compiles it with the doc-type folder as --root:
//   sh tools/render.sh courts/sixth-circuit/tennessee/federal/bankruptcy-eastern-district/adversary-complaint usage/INPUT-adversary-complaint.md
#import "tneb-adversary-complaint.typ": adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-adversary-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#adversary-complaint(meta, body)
