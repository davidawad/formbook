// Entrypoint. tools/render.sh compiles it with the doc-type folder as --root:
//   sh tools/render.sh courts/military/court-of-appeals-for-the-armed-forces/opening-brief usage/INPUT-<id>.md
#import "armfor-opening-brief.typ": armfor-opening-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-opening-brief.md"))
#let (meta, body) = split-frontmatter(src)
#armfor-opening-brief(meta, body)
