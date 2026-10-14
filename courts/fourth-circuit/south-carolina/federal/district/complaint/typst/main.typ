// Entrypoint. tools/render.sh compiles it with the doc-type folder as --root:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/INPUT-<id>.md typst/main.typ out.pdf
#import "scd-complaint.typ": scd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-miller-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#scd-complaint(meta, body)
