// Entrypoint. tools/render.sh compiles with the doc-type folder as --root:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "alsb-adversary-complaint.typ": alsb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-generic-adversary-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#alsb-adversary-complaint(meta, body)
