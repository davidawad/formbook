// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it.
#import "tenncrimapp-amicus-brief.typ": tenncrimapp-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-amicus-brief.md"))
#let (meta, body) = split-frontmatter(src)
#tenncrimapp-brief(meta, body)
