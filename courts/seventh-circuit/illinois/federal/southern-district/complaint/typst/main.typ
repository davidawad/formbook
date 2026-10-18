// Entry point. Compile through tools/render.sh, which passes the court folder as --root,
// the repo's vendored fonts only, and fails on any typst warning.
#import "ilsd-complaint.typ": ilsd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ilsd-complaint-prolife.md"))
#let (meta, body) = split-frontmatter(src)
#ilsd-complaint(meta, body)
