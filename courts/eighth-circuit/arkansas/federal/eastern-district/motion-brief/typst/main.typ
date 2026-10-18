// Entry point. tools/render.sh compiles it with the doc-type folder as --root:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ared-motion-brief.typ": ared-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ared-motion-brief-campbell.md"))
#let (meta, body) = split-frontmatter(src)
#ared-motion-brief(meta, body)
