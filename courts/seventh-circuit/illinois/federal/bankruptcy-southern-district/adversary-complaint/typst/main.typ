// Entry point. tools/render.sh compiles it with the doc-type folder as --root:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ilsb-adversary-complaint.typ": ilsb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ilsb-adversary-complaint-gargula.md"))
#let (meta, body) = split-frontmatter(src)
#ilsb-adversary-complaint(meta, body)
