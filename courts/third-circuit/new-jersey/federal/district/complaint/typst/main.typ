// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   sh tools/render.sh courts/third-circuit/new-jersey/federal/district/complaint usage/<id>.md
#import "njd-complaint.typ": njd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-njd-complaint-dglgroup.md"))
#let (meta, body) = split-frontmatter(src)
#njd-complaint(meta, body)
