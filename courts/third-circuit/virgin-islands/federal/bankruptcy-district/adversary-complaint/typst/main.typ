// Entrypoint. tools/render.sh compiles it with the document-type folder as --root:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-NAME.md typst/main.typ out.pdf
#import "vib-adversary-complaint.typ": complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-adversary-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#complaint(meta, body)
