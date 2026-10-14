// Entry point. tools/render.sh compiles it with the court folder as --root:
//   sh tools/render.sh courts/eighth-circuit/iowa/federal/bankruptcy-southern-district/motion-brief samples/<id>.md
#import "iasb-motion-brief.typ": iasb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample"))
#let (meta, body) = split-frontmatter(src)
#iasb-motion-brief(meta, body)
