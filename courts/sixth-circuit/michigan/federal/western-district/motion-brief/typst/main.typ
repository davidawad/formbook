// Entry point. Compile with the repo root as --root; tools/render.sh does it:
//   typst compile --root <repo> --font-path <repo>/fonts --ignore-system-fonts \
#import "miwd-motion-brief.typ": miwd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#miwd-motion-brief(meta, body)
