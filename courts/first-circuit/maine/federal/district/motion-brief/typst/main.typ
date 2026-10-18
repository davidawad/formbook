// Entry point. tools/render.sh compiles it with the doc-type folder as --root:
//   sh tools/render.sh courts/first-circuit/maine/federal/district/motion-brief usage/INPUT-<id>.md
#import "med-motion-brief.typ": med-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-med-motion-brief-ngiramahoromotiontodismiss.md"))
#let (meta, body) = split-frontmatter(src)
#med-motion-brief(meta, body)
