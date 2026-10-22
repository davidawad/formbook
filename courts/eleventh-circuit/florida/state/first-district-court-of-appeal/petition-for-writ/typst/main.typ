// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it.
// Florida First District Court of Appeal (fladistctapp1): petition-for-writ.
#import "fladistctapp1-petition-for-writ.typ": fladistctapp1-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-writ.md"))
#let (meta, body) = split-frontmatter(src)
#fladistctapp1-brief(meta, body)
