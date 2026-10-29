// Entry point. tools/render.sh compiles it with this folder as --root:
//   sh tools/render.sh courts/seventh-circuit/illinois/federal/central-district/motion-brief usage/<id>.md usage/<id>.pdf
#import "ilcd-motion-brief.typ": ilcd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ilcd-motion-brief(meta, body)
