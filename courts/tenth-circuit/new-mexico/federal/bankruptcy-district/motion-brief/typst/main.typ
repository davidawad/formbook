// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   sh tools/render.sh courts/tenth-circuit/new-mexico/federal/bankruptcy-district/motion-brief usage/<id>.md
#import "nmb-motion-brief.typ": nmb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-nmb-motion-brief-fictional.md"))
#let (meta, body) = split-frontmatter(src)
#nmb-motion-brief(meta, body)
