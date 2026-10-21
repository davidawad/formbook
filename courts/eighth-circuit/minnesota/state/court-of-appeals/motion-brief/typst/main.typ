// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it.
#import "minnctapp-motion-brief.typ": minnctapp-motion, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#minnctapp-motion(meta, body)
