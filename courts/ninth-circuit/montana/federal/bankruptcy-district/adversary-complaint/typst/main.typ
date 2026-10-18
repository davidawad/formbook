// Entrypoint. tools/render.sh compiles it with this doc-type folder as --root:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "mtb-adversary-complaint.typ": mtb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-mtb-adversary-complaint-bachenoblecomplaint.md"))
#let (meta, body) = split-frontmatter(src)
#mtb-adversary-complaint(meta, body)
