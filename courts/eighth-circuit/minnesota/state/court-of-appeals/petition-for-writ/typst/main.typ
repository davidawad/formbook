// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it.
#import "minnctapp-petition-for-writ.typ": minnctapp-petition, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-writ.md"))
#let (meta, body) = split-frontmatter(src)
#minnctapp-petition(meta, body)
