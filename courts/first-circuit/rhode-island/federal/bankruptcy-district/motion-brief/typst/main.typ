// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-<id>.md \
//     typst/main.typ out.pdf
#import "rib-motion-brief.typ": rib-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-rib-motion-brief-hidalgoastrue.md"))
#let (meta, body) = split-frontmatter(src)
#rib-motion-brief(meta, body)
