// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   sh tools/render.sh courts/tenth-circuit/wyoming/federal/bankruptcy-district/motion-brief usage/INPUT-wyb-motion-brief-teardropmemo.md
#import "wyb-motion-brief.typ": wyb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-wyb-motion-brief-teardropmemo.md"))
#let (meta, body) = split-frontmatter(src)
#wyb-motion-brief(meta, body)
