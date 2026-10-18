// Entry point. tools/render.sh compiles it with the doc-type folder as --root:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "wawb-motion-brief.typ": wawb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-wawb-motion-brief-smithmotionmemorandum.md"))
#let (meta, body) = split-frontmatter(src)
#wawb-motion-brief(meta, body)
