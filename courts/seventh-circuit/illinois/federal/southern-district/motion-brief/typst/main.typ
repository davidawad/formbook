// Entry point. Compile through tools/render.sh, which passes the court folder as --root,
// the repo's vendored fonts only, and fails on any typst warning.
#import "ilsd-motion-brief.typ": ilsd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ilsd-motion-brief-sheltonmotiontodismiss.md"))
#let (meta, body) = split-frontmatter(src)
#ilsd-motion-brief(meta, body)
