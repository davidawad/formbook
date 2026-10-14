// Entry point. tools/render.sh compiles it with the court folder as --root:
//   sh tools/render.sh courts/eighth-circuit/iowa/federal/bankruptcy-southern-district/adversary-complaint samples/<id>.md
#import "iasb-adversary-complaint.typ": iasb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample"))
#let (meta, body) = split-frontmatter(src)
#iasb-adversary-complaint(meta, body)
