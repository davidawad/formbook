// Entry point. tools/render.sh compiles it with the doc-type folder as --root:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md typst/main.typ out.pdf
#import "nywd-motion-brief.typ": nywd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-nywd-motion-brief-kerrick.md"))
#let (meta, body) = split-frontmatter(src)
#nywd-motion-brief(meta, body)
