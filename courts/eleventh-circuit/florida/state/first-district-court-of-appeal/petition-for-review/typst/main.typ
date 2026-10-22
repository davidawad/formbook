// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it.
// Florida First District Court of Appeal (fladistctapp1): petition-for-review.
#import "fladistctapp1-petition-for-review.typ": fladistctapp1-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-review.md"))
#let (meta, body) = split-frontmatter(src)
#fladistctapp1-brief(meta, body)
