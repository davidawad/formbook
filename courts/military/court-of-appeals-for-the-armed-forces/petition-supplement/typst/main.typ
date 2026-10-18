// Entrypoint. tools/render.sh compiles it with the doc-type folder as --root:
//   sh tools/render.sh courts/military/court-of-appeals-for-the-armed-forces/petition-supplement usage/INPUT-<id>.md
#import "armfor-petition-supplement.typ": armfor-petition-supplement, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-armfor-petition-supplement-coopersupplement.md"))
#let (meta, body) = split-frontmatter(src)
#armfor-petition-supplement(meta, body)
