// Entrypoint. tools/render.sh compiles it with the repository as --root:
//   typst compile --root <repo> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=<court dir>/usage/NAME.md typst/main.typ out.pdf
#import "txdistrict-travis-notice-of-appearance.typ": txdistrict-travis-notice-of-appearance, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-notice-of-appearance.md"))
#let (meta, body) = split-frontmatter(src)
#txdistrict-travis-notice-of-appearance(meta, body)
