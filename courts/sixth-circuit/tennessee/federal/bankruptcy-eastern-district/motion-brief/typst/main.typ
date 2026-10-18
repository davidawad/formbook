// Entry point. tools/render.sh compiles it with the doc-type folder as --root:
//   sh tools/render.sh courts/sixth-circuit/tennessee/federal/bankruptcy-eastern-district/motion-brief usage/INPUT-motion-brief.md
#import "tneb-motion-brief.typ": motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#motion-brief(meta, body)
