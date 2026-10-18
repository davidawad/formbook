// Entry point. tools/render.sh compiles it with the doc-type folder as --root:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-<id>.md \
//     typst/main.typ out.pdf
#import "txeb-motion-brief.typ": txeb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#txeb-motion-brief(meta, body)
