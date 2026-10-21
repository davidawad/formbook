// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it.
#import "tenncrimapp-motion-brief.typ": tenncrimapp-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#tenncrimapp-brief(meta, body)
