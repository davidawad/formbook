// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   sh tools/render.sh courts/sixth-circuit/michigan/federal/western-district/motion-brief usage/<id>.md
#import "miwd-motion-brief.typ": miwd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#miwd-motion-brief(meta, body)
