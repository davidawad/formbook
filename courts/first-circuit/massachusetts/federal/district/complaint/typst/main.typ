// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   sh tools/render.sh courts/first-circuit/massachusetts/federal/district/complaint usage/INPUT-complaint.md
#import "mad-complaint.typ": mad-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#mad-complaint(meta, body)
