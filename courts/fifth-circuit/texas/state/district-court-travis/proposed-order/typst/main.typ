// Entrypoint. tools/render.sh compiles it with the repository as --root:
//   typst compile --root <repo> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=<court dir>/usage/NAME.md typst/main.typ out.pdf
#import "txdistrict-travis-proposed-order.typ": txdistrict-travis-proposed-order, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-proposed-order.md"))
#let (meta, body) = split-frontmatter(src)
#txdistrict-travis-proposed-order(meta, body)
