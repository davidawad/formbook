// Entry point. Compile through tools/render.sh, which passes the court folder as --root,
// the repo's vendored fonts only, and fails on any typst warning.
#import "ilnd-motion-brief.typ": ilnd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ilnd-motion-brief(meta, body)
