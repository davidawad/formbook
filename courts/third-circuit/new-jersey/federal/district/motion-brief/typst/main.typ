// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   sh tools/render.sh courts/third-circuit/new-jersey/federal/district/motion-brief usage/<id>.md
#import "njd-motion-brief.typ": njd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-njd-motion-brief-karremotiontodismiss.md"))
#let (meta, body) = split-frontmatter(src)
#njd-motion-brief(meta, body)
